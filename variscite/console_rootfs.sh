# Must be called after make_prepare in main script
# generate weston rootfs in input dir
# $1 - rootfs base dir
function make_debian_console_rootfs()
{
	local ROOTFS_BASE=$1

	pr_info "Make Debian (${DEB_RELEASE}) console rootfs start..."

	# umount previus mounts (if fail)
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null || true

	# clear rootfs dir
	rm -rf ${ROOTFS_BASE}/*

	pr_info "rootfs: debootstrap"
	sudo mkdir -p ${ROOTFS_BASE}
	sudo chown -R root:root ${ROOTFS_BASE}

	pr_info "rootfs: debootstrap in rootfs (second-stage)"
	if [ "${MACHINE}" = "var-som-mx6" ] ||
	   [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		debootstrap --verbose --no-check-gpg --foreign --arch armhf ${DEB_RELEASE} \
			${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}
		# prepare qemu 32bit
		cp ${G_VARISCITE_PATH}/qemu_32bit/qemu-arm-static ${ROOTFS_BASE}/usr/bin/qemu-arm-static
	else
		debootstrap --verbose --no-check-gpg --foreign --arch arm64 ${DEB_RELEASE} \
			${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}
		# prepare qemu 64bit
		cp ${G_VARISCITE_PATH}/qemu_64bit/qemu-aarch64-static ${ROOTFS_BASE}/usr/bin/qemu-aarch64-static
	fi

	mount -o bind /proc ${ROOTFS_BASE}/proc
	mount -o bind /dev ${ROOTFS_BASE}/dev
	mount -o bind /dev/pts ${ROOTFS_BASE}/dev/pts
	mount -o bind /sys ${ROOTFS_BASE}/sys

	chroot $ROOTFS_BASE /debootstrap/debootstrap --second-stage --verbose

	# delete unused folder
	chroot $ROOTFS_BASE rm -rf ${ROOTFS_BASE}/debootstrap

	pr_info "rootfs: generate default configs"
	mkdir -p ${ROOTFS_BASE}/etc/sudoers.d/
	echo "user ALL=(root) /usr/bin/apt-get, /usr/bin/dpkg, /usr/bin/vi, /sbin/reboot" > ${ROOTFS_BASE}/etc/sudoers.d/user
	chmod 0440 ${ROOTFS_BASE}/etc/sudoers.d/user
	mkdir -p ${ROOTFS_BASE}/srv/local-apt-repository

	# imx-firmware
	if [ "${MACHINE}" = "imx8mq-var-dart" ] ||
	   [ "${MACHINE}" = "imx8mm-var-dart" ] ||
	   [ "${MACHINE}" = "imx8mn-var-som" ] ||
	   [ "${MACHINE}" = "imx8mp-var-dart" ] ||
	   [ "${MACHINE}" = "imx8qm-var-som" ] ||
	   [ "${MACHINE}" = "imx8qxp-var-som" ] ||
	   [ "${MACHINE}" = "imx8qxpb0-var-som" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/imx-firmware-${IMX_FIRMWARE_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# cp gstreamer-imx packages without install
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/gstreamer-imx/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# bluez-alsa
		cp -r ${G_VARISCITE_PATH}/deb/bluez-alsa/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

# add mirror to source list
echo "deb ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free
deb-src ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free
" > etc/apt/sources.list

# maximize local repo priority
echo "Package: *
Pin: origin ""
Pin-Priority: 1000
" > etc/apt/preferences.d/local

# raise backports priority
echo "Package: *
Pin: release n=${DEB_RELEASE}-backports
Pin-Priority: 600
" > etc/apt/preferences.d/backports

# Don't check valid until for snapshot releases
echo "Acquire::Check-Valid-Until no;" > etc/apt/apt.conf.d/99no-check-valid-until

if [ "${MACHINE}" = "var-som-mx6" ] ||
   [ "${MACHINE}" = "imx6ul-var-dart" ] ||
   [ "${MACHINE}" = "var-som-mx7" ]; then
	echo "# /dev/mmcblk0p1  /boot           vfat    defaults        0       0" > etc/fstab
else
	echo "/dev/root            /                    auto       defaults              1  1" > etc/fstab
fi

echo "${MACHINE}" > etc/hostname

echo "auto lo
iface lo inet loopback
" > etc/network/interfaces

echo "
locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8
locales locales/default_environment_locale select en_US.UTF-8
console-common	console-data/keymap/policy	select	Select keymap from full list
keyboard-configuration keyboard-configuration/variant select 'English (US)'
openssh-server openssh-server/permit-root-login select true
" > debconf.set

pr_info "rootfs: prepare install packages in rootfs"
# apt-get install without starting
cat > ${ROOTFS_BASE}/usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 101
EOF

chmod +x ${ROOTFS_BASE}/usr/sbin/policy-rc.d

# rootfs packages console only stage
cat > rootfs-stage-console << EOF
#!/bin/bash
# apply debconfig options
debconf-set-selections /debconf.set
rm -f /debconf.set

function protected_install()
{
	local _name=\${1}
	local repeated_cnt=5;
	local RET_CODE=1;

	echo Installing \${_name}
	for (( c=0; c<\${repeated_cnt}; c++ ))
	do
		apt install -y \${_name} && {
			RET_CODE=0;
			break;
		};

		echo
		echo "##########################"
		echo "## Fix missing packages ##"
		echo "##########################"
		echo

		sleep 2;

		apt --fix-broken install -y && {
			RET_CODE=0;
			break;
		};
	done

	return \${RET_CODE}
}

# update packages and install base
apt-get update || apt-get upgrade

# local-apt-repository support
protected_install local-apt-repository

# update packages and install base
apt-get update || apt-get upgrade

#udisk2
protected_install udisks2

protected_install locales
protected_install ntp
protected_install openssh-server
protected_install nfs-common

# packages required when flashing emmc
protected_install dosfstools

# fix config for sshd (permit root login)
sed -i -e 's/#PermitRootLogin.*/PermitRootLogin\tyes/g' /etc/ssh/sshd_config

# net-tools (ifconfig, etc.)
protected_install net-tools
protected_install network-manager

if [ "${MACHINE}" = "imx8mq-var-dart" ] ||
   [ "${MACHINE}" = "imx8mm-var-dart" ] ||
   [ "${MACHINE}" = "imx8mn-var-som" ] ||
   [ "${MACHINE}" = "imx8mp-var-dart" ] ||
   [ "${MACHINE}" = "imx8qm-var-som" ] ||
   [ "${MACHINE}" = "imx8qxp-var-som" ] ||
   [ "${MACHINE}" = "imx8qxpb0-var-som" ]; then
	# sdma package
	protected_install imx-firmware-sdma

	# VPU package
	protected_install imx-firmware-vpu

	# epdc package
	protected_install imx-firmware-epdc

	# hdmi firmware package
	if [ ! -z "${HDMI_FIRMWARE_PACKAGE}" ]
	then
		protected_install ${HDMI_FIRMWARE_PACKAGE}
	fi
fi

# killall
protected_install psmisc

# alsa
protected_install alsa-utils

# i2c tools
protected_install i2c-tools

# usb tools
protected_install usbutils

# libgpiod
protected_install gpiod
protected_install libgpiod2
protected_install python3-libgpiod

# net tools
protected_install iperf3

protected_install rng-tools

# mtd
protected_install mtd-utils

# bluetooth
protected_install bluetooth
protected_install bluez-obexd
protected_install bluez-tools

# install pulseaudio
protected_install pulseaudio
protected_install pulseaudio-module-bluetooth

# wifi support packages
protected_install hostapd
protected_install udhcpd

# disable the hostapd service by default
systemctl disable hostapd.service

# can support
protected_install can-utils

# pmount
protected_install pmount

# pm-utils
protected_install pm-utils

# install dpkg-dev for dpkg-buildpackage
protected_install debhelper
protected_install dh-python
protected_install apt-src
apt-get -y autoremove

#update iptables alternatives to legacy
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

#install usleep busybox applet
ln -sf /bin/busybox /bin/usleep

# create users and set password
useradd -m -G audio -s /bin/bash user
usermod -a -G video user
echo "user:user" | chpasswd
echo "root:root" | chpasswd

# sudo kill rootfs-stage-console
rm -f rootfs-stage-console
EOF

	pr_info "rootfs: install selected Debian packages (console-only-stage)"
	chmod +x rootfs-stage-console
	chroot ${ROOTFS_BASE} /rootfs-stage-console

	# install variscite-bt service
	install -d ${ROOTFS_BASE}/etc/bluetooth
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		install -m 0755 ${G_VARISCITE_PATH}/x11_resources/brcm_patchram_plus \
			${ROOTFS_BASE}/usr/bin
		install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/variscite-bt \
			${ROOTFS_BASE}/etc/bluetooth
		install -m 0644 ${G_VARISCITE_PATH}/x11_resources/variscite-bt.service \
			${ROOTFS_BASE}/lib/systemd/system
	else
		install -m 0755 ${G_VARISCITE_PATH}/brcm_patchram_plus \
			${ROOTFS_BASE}/usr/bin
		install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-bt.conf \
			${ROOTFS_BASE}/etc/bluetooth
		install -m 0755 ${G_VARISCITE_PATH}/variscite-bt \
			${ROOTFS_BASE}/etc/bluetooth
		install -m 0755 ${G_VARISCITE_PATH}/variscite-bt-common.sh \
			${ROOTFS_BASE}/etc/bluetooth
		install -m 0644 ${G_VARISCITE_PATH}/variscite-bt.service \
			${ROOTFS_BASE}/lib/systemd/system
	fi
	ln -s /lib/systemd/system/variscite-bt.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-bt.service

	# install BT audio and main config
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/bluez5/files/audio.conf \
		${ROOTFS_BASE}/etc/bluetooth/
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/bluez5/files/main.conf \
		${ROOTFS_BASE}/etc/bluetooth/

	# install obexd configuration
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/bluez5/files/obexd.conf \
		${ROOTFS_BASE}/etc/dbus-1/system.d

	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/bluez5/files/obex.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/obex.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/obex.service

	# install pulse audio configuration
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/pulseaudio.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/pulseaudio.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/pulseaudio.service
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/pulseaudio-bluetooth.conf \
		${ROOTFS_BASE}/etc/dbus-1/system.d
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/system.pa \
		${ROOTFS_BASE}/etc/pulse/

	rm -f ${ROOTFS_BASE}/etc/systemd/user/sockets.target.wants/pulseaudio.socket
	rm -f ${ROOTFS_BASE}/etc/systemd/user/default.target.wants/pulseaudio.service

	sed -i 's/; default-server =/; default-server = \/var\/run\/pulse\/native/' ${ROOTFS_BASE}/etc/pulse/client.conf
	sed -i 's/; autospawn = yes/; autospawn = no/' ${ROOTFS_BASE}/etc/pulse/client.conf

	chmod -x ${ROOTFS_BASE}/usr/bin/start-pulseaudio-x11

	# install blacklist.conf
	install -d ${ROOTFS_BASE}/etc/modprobe.d/
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/blacklist.conf \
		${ROOTFS_BASE}/etc/modprobe.d/

	# install variscite-wifi service
	install -d ${ROOTFS_BASE}/etc/wifi
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/variscite-wifi \
			${ROOTFS_BASE}/etc/wifi
		install -m 0644 ${G_VARISCITE_PATH}/x11_resources/variscite-wifi.service \
			${ROOTFS_BASE}/lib/systemd/system
	else
		install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-wifi.conf \
			${ROOTFS_BASE}/etc/wifi
		install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-wifi-common.sh \
			${ROOTFS_BASE}/etc/wifi
		install -m 0755 ${G_VARISCITE_PATH}/variscite-wifi \
			${ROOTFS_BASE}/etc/wifi
		install -m 0644 ${G_VARISCITE_PATH}/variscite-wifi.service \
			${ROOTFS_BASE}/lib/systemd/system
	fi
	ln -s /lib/systemd/system/variscite-wifi.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-wifi.service
	
	#install securetty
	install -m 0644 ${G_VARISCITE_PATH}/securetty \
		${ROOTFS_BASE}/etc/securetty

	# remove pm-utils default scripts and install wifi / bt pm-utils script
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/sleep.d/
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/module.d/
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/power.d/
	install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/01-bt.sh \
			${ROOTFS_BASE}/etc/pm/sleep.d/
	install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/02-wifi.sh \
			${ROOTFS_BASE}/etc/pm/sleep.d/
	if [ -f ${G_VARISCITE_PATH}/${MACHINE}/03-eth.sh ]; then
		install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/03-eth.sh \
			${ROOTFS_BASE}/etc/pm/sleep.d/
	fi
	if [ -f ${G_VARISCITE_PATH}/${MACHINE}/04-usb.sh ]; then
		install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/04-usb.sh \
			${ROOTFS_BASE}/etc/pm/sleep.d/
	fi

	# we don't want systemd to handle the power key
	echo "HandlePowerKey=ignore" >> ${ROOTFS_BASE}/etc/systemd/logind.conf

	#Build kernel headers on the target
	pr_info "rootfs: Building kernel-headers"
	cp -ar ${ROOTFS_BASE}/../output/kernel-headers ${ROOTFS_BASE}/tmp/
	echo "#!/bin/bash
	# update packages
	cd /tmp/kernel-headers
	dpkg-buildpackage -b -j4 -us -uc
	cp -ar /tmp/*.deb /srv/local-apt-repository/
	dpkg-reconfigure local-apt-repository
	cd -
	rm -rf /var/cache/apt/*
	rm -f header-stage
	" > header-stage

	chmod +x header-stage
	chroot ${ROOTFS_BASE} /header-stage


	#Install user pacakges if any
	if [ "${G_USER_PACKAGES}" != "" ] ; then
		pr_info "rootfs: install user defined packages (user-stage)"
		pr_info "rootfs: G_USER_PACKAGES \"${G_USER_PACKAGES}\" "

		echo "#!/bin/bash
		# update packages
		apt-get update
		apt-get upgrade

		# install all user packages
		apt-get -y install ${G_USER_PACKAGES}

		rm -f user-stage
		" > user-stage

		chmod +x user-stage
		chroot ${ROOTFS_BASE} /user-stage
	fi

	# binaries rootfs patching
	install -m 0644 ${G_VARISCITE_PATH}/issue ${ROOTFS_BASE}/etc/
	install -m 0644 ${G_VARISCITE_PATH}/issue.net ${ROOTFS_BASE}/etc/
	install -m 0644 ${G_VARISCITE_PATH}/splash.bmp ${ROOTFS_BASE}/boot/
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		install -m 0755 ${G_VARISCITE_PATH}/x11_resources/rc.local ${ROOTFS_BASE}/etc/
		install -m 0644 ${G_VARISCITE_PATH}/x11_resources/hostapd.conf ${ROOTFS_BASE}/etc/
	else
		install -m 0755 ${G_VARISCITE_PATH}/rc.local ${ROOTFS_BASE}/etc/
		install -d ${ROOTFS_BASE}/boot/
		cp ${PARAM_OUTPUT_DIR}/Image.gz ${ROOTFS_BASE}/boot
		cp ${PARAM_OUTPUT_DIR}/*.dtb ${ROOTFS_BASE}/boot
		if [ "$DEFAULT_BOOT_DTB" != "$BOOT_DTB" ]; then
			ln -sf ${DEFAULT_BOOT_DTB} ${ROOTFS_BASE}/boot/${BOOT_DTB}
			if [ ! -z "${BOOT_DTB2}" ]; then
				ln -sf ${DEFAULT_BOOT_DTB2} \
					${ROOTFS_BASE}/boot/${BOOT_DTB2}
			fi
			if [ "${MACHINE}" = "imx8qm-var-som" ]; then
				ln -sf ${DEFAULT_BOOT_SPEAR8_DTB} ${ROOTFS_BASE}/boot/${BOOT_SPEAR8_DTB}
				# i.MX8QP SoC Default DTBs
				ln -sf ${DEFAULT_BOOT_DTB/imx8qm/imx8qp} ${ROOTFS_BASE}/boot/${BOOT_DTB/imx8qm/imx8qp}
				ln -sf ${DEFAULT_BOOT_SPEAR8_DTB/imx8qm/imx8qp} ${ROOTFS_BASE}/boot/${BOOT_SPEAR8_DTB/imx8qm/imx8qp}
			fi
		fi
	fi

		# Add alsa default configs
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		install -m 0644 ${G_VARISCITE_PATH}/x11_resources/asound.state \
			${ROOTFS_BASE}/var/lib/alsa/
		install -m 0644 ${G_VARISCITE_PATH}/x11_resources/asound.conf ${ROOTFS_BASE}/etc/
	else
		install -m 0644 ${G_VARISCITE_PATH}/asound.state \
			${ROOTFS_BASE}/var/lib/alsa/
		install -m 0644 ${G_VARISCITE_PATH}/asound.conf ${ROOTFS_BASE}/etc/
	fi

	# Revert regular booting
	rm -f ${ROOTFS_BASE}/usr/sbin/policy-rc.d

	# install kernel modules in rootfs
	install_kernel_modules \
		${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_LINUX_KERNEL_DEF_CONFIG} ${G_LINUX_KERNEL_SRC_DIR} \
		${ROOTFS_BASE}

	# copy all kernel headers for development
	mkdir -p ${ROOTFS_BASE}/usr/local/src/linux-imx/drivers/staging/android/uapi
	cp ${G_LINUX_KERNEL_SRC_DIR}/drivers/staging/android/uapi/* \
	${ROOTFS_BASE}/usr/local/src/linux-imx/drivers/staging/android/uapi
	cp -r ${G_LINUX_KERNEL_SRC_DIR}/include \
		${ROOTFS_BASE}/usr/local/src/linux-imx/

	# copy custom files
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/kobs-ng ${ROOTFS_BASE}/usr/bin
		cp ${PARAM_OUTPUT_DIR}/fw_printenv-mmc ${ROOTFS_BASE}/usr/bin
		cp ${PARAM_OUTPUT_DIR}/fw_printenv-nand ${ROOTFS_BASE}/usr/bin
		ln -sf fw_printenv-nand ${ROOTFS_BASE}/usr/bin/fw_printenv
	else
		cp ${PARAM_OUTPUT_DIR}/fw_printenv ${ROOTFS_BASE}/usr/bin

	fi
	ln -sf fw_printenv ${ROOTFS_BASE}/usr/bin/fw_setenv
	cp ${G_VARISCITE_PATH}/${MACHINE}/fw_env.config ${ROOTFS_BASE}/etc
	cp ${G_VARISCITE_PATH}/automount.rules ${ROOTFS_BASE}/etc/udev/rules.d

	if [ "${MACHINE}" = "imx8m-var-dart" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/*.rules ${ROOTFS_BASE}/etc/udev/rules.d
	fi

	# install freertos-variscite
	if [ ! -z "${G_FREERTOS_VAR_BUILD_DIR}" ]; then

		# Install FS helper scripts
		install -d ${ROOTFS_BASE}/etc/remoteproc
		install -m 0755 ${G_VARISCITE_PATH}/variscite-rproc-u-boot ${ROOTFS_BASE}/etc/remoteproc
		install -m 0755 ${G_VARISCITE_PATH}/variscite-rproc-linux ${ROOTFS_BASE}/etc/remoteproc
		install -m 0644 ${G_VARISCITE_PATH}/variscite-rproc-common.sh ${ROOTFS_BASE}/etc/remoteproc
		install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-rproc.conf ${ROOTFS_BASE}/etc/remoteproc

		# install freertos demos
		readonly CM_BUILD_TARGETS=" \
		    debug \
		    ddr_debug \
		"
		# Install all demos in CM_DEMOS
		for CM_DEMO in ${CM_DEMOS}; do
		    DIR_GCC="${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
		    # Install all build targets
		    for CM_BUILD_TARGET in ${CM_BUILD_TARGETS}; do
			# Install elf
			FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.elf)"
			install -m 0644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${ROOTFS_BASE}/lib/firmware/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}
			# Install bin
			FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.bin)"
			install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${ROOTFS_BASE}/boot/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}
		    done
		done

		# Install disable_cache demos (all demos in CM_DEMOS_DISABLE_CACHE)
		for CM_DEMO in ${CM_DEMOS_DISABLE_CACHE}; do
		    DIR_GCC="${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
		    # Install all build targets
		    CM_BUILD_TARGET="debug"
		    # Install elf
		    FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.elf)"
		    install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${ROOTFS_BASE}/lib/firmware/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}
		done
	fi
}

# Must be called after make_debian_console_rootfs in main script
# function generate ubi rootfs in input dir
# $1 - rootfs ubifs base dir
function prepare_ubifs_rootfs() {
	local UBIFS_ROOTFS_BASE=$1
	pr_info "Make debian(${DEB_RELEASE}) console rootfs for UBIFS start..."

	# Below removals are to free space to fit in a NAND flash
	# Remove foreign man pages and locales
	rm -rf ${UBIFS_ROOTFS_BASE}/usr/share/man/??
	rm -rf ${UBIFS_ROOTFS_BASE}/usr/share/man/??_*
	rm -rf ${UBIFS_ROOTFS_BASE}/var/cache/man/??
	rm -rf ${UBIFS_ROOTFS_BASE}/var/cache/man/??_*
	(cd ${UBIFS_ROOTFS_BASE}/usr/share/locale; ls | grep -v en_[GU] | xargs rm -rf)

	# Remove document files
	rm -rf ${UBIFS_ROOTFS_BASE}/usr/share/doc

	# Remove deb package lists
	rm -rf ${UBIFS_ROOTFS_BASE}/var/lib/apt/lists/deb.*
}
