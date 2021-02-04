# Must be called after make_prepare in main script
# generate weston rootfs in input dir
# $1 - rootfs base dir
function make_debian_weston_rootfs()
{
	local ROOTFS_BASE=$1

	pr_info "Make Debian (${DEB_RELEASE}) rootfs start..."

	# umount previus mounts (if fail)
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null || true

	# clear rootfs dir
	rm -rf ${ROOTFS_BASE}/*

	pr_info "rootfs: debootstrap"
	debootstrap --verbose --no-check-gpg --foreign --arch arm64 ${DEB_RELEASE} \
		${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}

	# prepare qemu
	pr_info "rootfs: debootstrap in rootfs (second-stage)"
	cp ${G_VARISCITE_PATH}/qemu_64bit/qemu-aarch64-static ${ROOTFS_BASE}/usr/bin/qemu-aarch64-static
	mount -o bind /proc ${ROOTFS_BASE}/proc
	mount -o bind /dev ${ROOTFS_BASE}/dev
	mount -o bind /dev/pts ${ROOTFS_BASE}/dev/pts
	mount -o bind /sys ${ROOTFS_BASE}/sys
	chroot $ROOTFS_BASE /debootstrap/debootstrap --second-stage

	# delete unused folder
	chroot $ROOTFS_BASE rm -rf ${ROOTFS_BASE}/debootstrap

	pr_info "rootfs: generate default configs"
	mkdir -p ${ROOTFS_BASE}/etc/sudoers.d/
	echo "user ALL=(root) /usr/bin/apt-get, /usr/bin/dpkg, /usr/bin/vi, /sbin/reboot" > ${ROOTFS_BASE}/etc/sudoers.d/user
	chmod 0440 ${ROOTFS_BASE}/etc/sudoers.d/user
	mkdir -p ${ROOTFS_BASE}/srv/local-apt-repository

	# imx-firmware
	cp -r ${G_VARISCITE_PATH}/deb/imx-firmware-${IMX_FIRMWARE_VERSION}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# cairo
	cp -r ${G_VARISCITE_PATH}/deb/cairo/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# libdrm
	cp -r ${G_VARISCITE_PATH}/deb/libdrm/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# waylandprotocols
	cp -r ${G_VARISCITE_PATH}/deb/waylandprotocols/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# G2D_Packages
	if [ ! -z "${G2D_PACKAGE_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G2D_PACKAGE_DIR}/* \
		${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# Vivante GPU libraries
	if [ ! -z "${G_GPU_IMX_VIV_PACKAGE_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_GPU_IMX_VIV_PACKAGE_DIR}/* \
		${ROOTFS_BASE}/srv/local-apt-repository
	fi
	# Vivante GPU SDK Binaries
	if [ ! -z "${G_GPU_IMX_VIV_SDK_PACKAGE_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_GPU_IMX_VIV_SDK_PACKAGE_DIR}/* \
		${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# imxcodec
	if [ ! -z "${G_IMX_CODEC_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_CODEC_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# imxparser
	if [ ! -z "${G_IMX_PARSER_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_PARSER_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# imxvpuhantro
	if [ ! -z "${G_IMX_VPU_HANTRO_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_VPU_HANTRO_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# gstpluginsbad
	cp -r ${G_VARISCITE_PATH}/deb/gstpluginsbad/${GST_MM_VERSION}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# gstpluginsbase
	cp -r ${G_VARISCITE_PATH}/deb/gstpluginsbase/${GST_MM_VERSION}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# gstpluginsgood
	cp -r ${G_VARISCITE_PATH}/deb/gstpluginsgood/${GST_MM_VERSION}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# gstreamer
	cp -r ${G_VARISCITE_PATH}/deb/gstreamer/${GST_MM_VERSION}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# imx-vpuwrap
	if [ ! -z "${G_IMX_VPU_WRAPPER_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_VPU_WRAPPER_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# imxgstplugin
	cp -r ${G_VARISCITE_PATH}/deb/imxgstplugin/${GST_MM_VERSION}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# weston
	cp -r ${G_VARISCITE_PATH}/deb/weston/${WESTON_PACKAGE_DIR}/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# opencv
	if [ ! -z "${G_OPENCV_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_OPENCV_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

# add mirror to source list
echo "deb ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free
deb-src ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free
deb ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE}-backports main contrib non-free
deb-src ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE}-backports main contrib non-free
deb ${DEF_DEBIAN_MIRROR} bullseye main contrib non-free
deb-src ${DEF_DEBIAN_MIRROR} bullseye main contrib non-free
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

echo "
# /dev/mmcblk0p1  /boot           vfat    defaults        0       0
" > etc/fstab

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

# third packages stage
cat > third-stage << EOF
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

# maximize local repo priority
echo "Package: *
Pin: origin ""
Pin-Priority: 1000
" > etc/apt/preferences.d/local

echo "Package: *
Pin: release n=${DEB_RELEASE}
Pin-Priority: 990
" > etc/apt/preferences.d/buster
# raise backports priority
echo "Package: *
Pin: release n=${DEB_RELEASE}-backports
Pin-Priority: 500
" > etc/apt/preferences.d/backports

# raise backports priority
echo "Package: *
Pin: release n=bullseye
Pin-Priority: 90
" > etc/apt/preferences.d/bullseye

# Don't check valid until for snapshot releases
echo "Acquire::Check-Valid-Until no;" > etc/apt/apt.conf.d/99no-check-valid-until

# update packages and install base
apt-get update

protected_install locales
apt-get install libc-bin/bullseye -y --allow-remove-essential

apt-get install libc6/bullseye -y --allow-remove-essential
protected_install ntp
protected_install openssh-sftp-server/bullseye
protected_install runit-helper/bullseye
protected_install ncurses-term/bullseye
protected_install xauth/bullseye
protected_install openssh-server/bullseye
protected_install nfs-common

# packages required when flashing emmc
protected_install dosfstools

# fix config for sshd (permit root login)
sed -i -e 's/#PermitRootLogin.*/PermitRootLogin\tyes/g' /etc/ssh/sshd_config

# net-tools (ifconfig, etc.)
protected_install net-tools
protected_install network-manager

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

# graphical packages
protected_install libdrm-vivante1
protected_install imx-gpu-viv-core
protected_install dpkg-dev
protected_install imx-gpu-viv-wl


if [ ! -z "${G2DPACKAGE}" ]
then
	protected_install ${G2DPACKAGE}
fi
protected_install weston

# alsa & gstreamer
protected_install alsa-utils
protected_install gstreamer1.0-alsa
protected_install gstreamer1.0-plugins-bad
protected_install gstreamer1.0-plugins-base
protected_install gstreamer1.0-plugins-base-apps
protected_install gstreamer1.0-plugins-ugly
protected_install gstreamer1.0-plugins-good
protected_install gstreamer1.0-tools
protected_install ${IMXGSTPLG}

# i2c tools
protected_install i2c-tools

# usb tools
protected_install usbutils

# net tools
protected_install iperf

protected_install rng-tools

# mtd
protected_install mtd-utils

# bluetooth
protected_install bluetooth
protected_install bluez-obexd
protected_install bluez-tools
protected_install blueman
protected_install gconf2

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

apt-get -y autoremove

# GPU SDK
if [ ! -z "${G_GPU_IMX_VIV_SDK_PACKAGE_DIR}" ]
then
       protected_install libtirpc-dev/bullseye
       protected_install libnsl-dev/bullseye
       protected_install libc6-dev/bullseye
       protected_install zlib1g-dev/bullseye
       protected_install libtiff5/bullseye
       protected_install libtiff-dev/bullseye
       protected_install libassimp-dev/bullseye
       protected_install libjpeg-dev/bullseye
       protected_install libdevil-dev/bullseye
       protected_install libwayland-egl-backend-dev/buster
       protected_install glslang-tools/bullseye
       protected_install imx-gpu-sdk-console
       protected_install imx-gpu-sdk-gles2
       protected_install imx-gpu-sdk-gles3
       protected_install imx-gpu-sdk-opencl
       protected_install imx-gpu-sdk-window
       dpkg-reconfigure imx-gpu-viv-wl
fi
protected_install build-essential/bullseye
protected_install gcc/bullseye

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

# sado kill
rm -f third-stage
EOF

	pr_info "rootfs: install selected Debian packages (third-stage)"
	chmod +x third-stage
	chroot ${ROOTFS_BASE} /third-stage

	# fourth-stage
	# install variscite-bt service
	install -m 0755 ${G_VARISCITE_PATH}/brcm_patchram_plus \
		${ROOTFS_BASE}/usr/bin
	install -d ${ROOTFS_BASE}/etc/bluetooth
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-bt.conf \
		${ROOTFS_BASE}/etc/bluetooth
	install -m 0755 ${G_VARISCITE_PATH}/variscite-bt \
		${ROOTFS_BASE}/etc/bluetooth
	install -m 0755 ${G_VARISCITE_PATH}/variscite-bt-common.sh \
		${ROOTFS_BASE}/etc/bluetooth
	install -m 0644 ${G_VARISCITE_PATH}/variscite-bt.service \
		${ROOTFS_BASE}/lib/systemd/system
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
		${ROOTFS_BASE}/etc//dbus-1/system.d
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/system.pa \
		${ROOTFS_BASE}/etc/pulse/

	# install blacklist.conf
	install -d ${ROOTFS_BASE}/etc/modprobe.d/
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/blacklist.conf \
		${ROOTFS_BASE}/etc/modprobe.d/

	# install variscite-wifi service
	install -d ${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-wifi.conf \
		${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-wifi-common.sh \
		${ROOTFS_BASE}/etc/wifi
	install -m 0755 ${G_VARISCITE_PATH}/variscite-wifi \
		${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/variscite-wifi.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/variscite-wifi.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-wifi.service

	#install securetty
	install -m 0644 ${G_VARISCITE_PATH}/securetty \
		${ROOTFS_BASE}/etc/securetty

	# install weston service
	install -d ${ROOTFS_BASE}/etc/xdg/weston
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/weston.ini \
		${ROOTFS_BASE}/etc/xdg/weston
	install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/weston.config \
		${ROOTFS_BASE}/etc/default/weston
	install -m 0755 ${G_VARISCITE_PATH}/weston-start \
		${ROOTFS_BASE}/usr/bin/weston-start
	install -m 0755 ${G_VARISCITE_PATH}/weston.profile \
		${ROOTFS_BASE}/etc/profile.d/weston.sh
	install -m 0644 ${G_VARISCITE_PATH}/weston.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/weston.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/weston.service

	# remove pm-utils default scripts and install wifi / bt pm-utils script
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/sleep.d/
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/module.d/
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/power.d/
	install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/01-bt.sh \
		${ROOTFS_BASE}/etc/pm/sleep.d/
	install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/02-wifi.sh \
		${ROOTFS_BASE}/etc/pm/sleep.d/

	#Build kernel headers on the target
	pr_info "rootfs: Building kernel-headers"
	cp -ar ${ROOTFS_BASE}/../output/kernel-headers ${ROOTFS_BASE}/tmp/

	echo "#!/bin/bash
	# update packages
	apt-get install -y python3-distutils/bullseye
	apt-get install -y libdebhelper-perl/bullseye
	apt-get install -y debhelper/bullseye
	apt-get install -y execstack/bullseye
	apt-get install -y dh-python/bullseye
	apt-get install -y apt-src/bullseye
	cd /tmp/kernel-headers
	dpkg-buildpackage -b -j4 -us -uc
	cp -ar /tmp/*.deb /srv/local-apt-repository/
	dpkg-reconfigure local-apt-repository
	rm -rf /var/cache/apt/*
	rm -f header-stage
	" > header-stage

	chmod +x header-stage
	chroot ${ROOTFS_BASE} /header-stage

	## end packages stage ##
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
	install -m 0755 ${G_VARISCITE_PATH}/rc.local ${ROOTFS_BASE}/etc/
	install -d ${ROOTFS_BASE}/boot/
	install -m 0644 ${G_VARISCITE_PATH}/splash.bmp ${ROOTFS_BASE}/boot/
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
		fi
	fi

	mkdir -p ${ROOTFS_BASE}/usr/share/images/desktop-base/
	install -m 0644 ${G_VARISCITE_PATH}/wallpaper_hd.png \
		${ROOTFS_BASE}/usr/share/images/desktop-base/default

	# Add alsa default configs
	install -m 0644 ${G_VARISCITE_PATH}/asound.state \
		${ROOTFS_BASE}/var/lib/alsa/
	install -m 0644 ${G_VARISCITE_PATH}/asound.conf ${ROOTFS_BASE}/etc/

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
	cp ${G_VARISCITE_PATH}/${MACHINE}/fw_env.config ${ROOTFS_BASE}/etc
	cp ${PARAM_OUTPUT_DIR}/fw_printenv ${ROOTFS_BASE}/usr/bin
	ln -sf fw_printenv ${ROOTFS_BASE}/usr/bin/fw_setenv
	cp ${G_VARISCITE_PATH}/10-imx.rules ${ROOTFS_BASE}/etc/udev/rules.d
	cp ${G_VARISCITE_PATH}/mount.blacklist ${ROOTFS_BASE}/etc/udev/rules.d
	cp ${G_VARISCITE_PATH}/automount.rules ${ROOTFS_BASE}/etc/udev/rules.d
	mkdir -p ${ROOTFS_BASE}/etc/udev/scripts/
	install -m 0755 ${G_VARISCITE_PATH}/mount.sh \
		${ROOTFS_BASE}/etc/udev/scripts/mount.sh

	if [ "${MACHINE}" = "imx8m-var-dart" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/*.rules ${ROOTFS_BASE}/etc/udev/rules.d
	fi

## clenup command
echo "#!/bin/bash
apt-get clean
rm -f cleanup
" > cleanup

	# clean all packages
	pr_info "rootfs: clean"
	chmod +x cleanup
	chroot ${ROOTFS_BASE} /cleanup
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null || true

	# kill latest dbus-daemon instance due to qemu-aarch64-static
	QEMU_PROC_ID=$(ps axf | grep dbus-daemon | grep qemu-aarch64-static | awk '{print $1}')
	if [ -n "$QEMU_PROC_ID" ]
	then
		kill -9 $QEMU_PROC_ID
	fi

	rm -f ${ROOTFS_BASE}/usr/bin/qemu-aarch64-static
}

# make SD card for device
# $1 -- block device
# $2 -- output images dir
function make_weston_sdcard()
{
	readonly local LPARAM_BLOCK_DEVICE=${1}
	readonly local LPARAM_OUTPUT_DIR=${2}
	readonly local P1_MOUNT_DIR="${G_TMP_DIR}/p1"
	readonly local DEBIAN_IMAGES_TO_ROOTFS_POINT="opt/images/Debian"

	readonly local BOOTLOAD_RESERVE_SIZE=8
	readonly local SPARE_SIZE=4

	[ "${LPARAM_BLOCK_DEVICE}" = "na" ] && {
		pr_error "No valid block device: ${LPARAM_BLOCK_DEVICE}"
		return 1;
	};

	local part=""
	if [ `echo ${LPARAM_BLOCK_DEVICE} | grep -c mmcblk` -ne 0 ] \
		|| [[ ${LPARAM_BLOCK_DEVICE} == *"loop"* ]] ; then
		part="p"
	fi

	# Check that we're using a valid device
	if ! check_sdcard ${LPARAM_BLOCK_DEVICE}; then
		return 1
	fi

	for ((i=0; i<10; i++))
	do
		if [ `mount | grep -c ${LPARAM_BLOCK_DEVICE}${part}$i` -ne 0 ]; then
			umount ${LPARAM_BLOCK_DEVICE}${part}$i
		fi
	done

	function format_sdcard
	{
		pr_info "Formating SD card partitions"
		mkfs.ext4 ${LPARAM_BLOCK_DEVICE}${part}1 -L rootfs
	}

	function flash_u-boot
	{
		pr_info "Flashing U-Boot"
		dd if=${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_EMMC} \
		of=${LPARAM_BLOCK_DEVICE} bs=1K seek=${BOOTLOADER_OFFSET}; sync
	}

	function flash_sdcard
	{
		pr_info "Flashing \"rootfs\" partition"
		tar -xpf ${LPARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBALL_NAME} \
			-C ${P1_MOUNT_DIR}/
	}

	function copy_debian_images
	{
		mkdir -p ${P1_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}

		pr_info "Copying Debian images to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBALL_NAME} \
			${P1_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/${DEF_ROOTFS_TARBALL_NAME}

		pr_info "Copying MMC U-Boot to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		if [ ${MACHINE} = "imx8mq-var-dart" ]; then
			cp ${LPARAM_OUTPUT_DIR}/imx-boot-* \
				${P1_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		else
			cp ${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_EMMC} \
				${P1_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		fi
	}

	function copy_scripts
	{
		pr_info "Copying scripts to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${G_VARISCITE_PATH}/mx8_install_debian.sh \
			${P1_MOUNT_DIR}/usr/sbin/install_debian.sh
	}

	function ceildiv
	{
		local num=$1
		local div=$2
		echo $(( (num + div - 1) / div ))
	}

	# Delete the partitions
	for ((i=0; i<=10; i++))
	do
		if [ -e ${LPARAM_BLOCK_DEVICE}${part}${i} ]; then
			dd if=/dev/zero of=${LPARAM_BLOCK_DEVICE}${part}$i bs=512 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | \
		fdisk ${LPARAM_BLOCK_DEVICE} &> /dev/null) || true
	sync

	dd if=/dev/zero of=${LPARAM_BLOCK_DEVICE} bs=1M count=${BOOTLOAD_RESERVE_SIZE}
	sync; sleep 2

	# Create a new partition table
	pr_info "Creating new partitions"

	# Get total card size
	TOTAL_SIZE=`sfdisk -s ${LPARAM_BLOCK_DEVICE}`
	TOTAL_SIZE=`expr ${TOTAL_SIZE} / 1024`
	ROOTFS_SIZE=`expr ${TOTAL_SIZE} - ${BOOTLOAD_RESERVE_SIZE} - ${SPARE_SIZE}`

	pr_info "ROOT SIZE=${ROOTFS_SIZE} TOTAl SIZE=${TOTAL_SIZE}"

	BLOCK=`echo ${LPARAM_BLOCK_DEVICE} | cut -d "/" -f 3`
	SECT_SIZE_BYTES=`cat /sys/block/${BLOCK}/queue/physical_block_size`

	BOOTLOAD_RESERVE_SIZE_BYTES=$((BOOTLOAD_RESERVE_SIZE * 1024 * 1024))
	ROOTFS_SIZE_BYTES=$((ROOTFS_SIZE * 1024 * 1024))

	PART1_START=`ceildiv ${BOOTLOAD_RESERVE_SIZE_BYTES} ${SECT_SIZE_BYTES}`
	PART1_SIZE=`ceildiv ${ROOTFS_SIZE_BYTES} ${SECT_SIZE_BYTES}`

sfdisk --force -uS ${LPARAM_BLOCK_DEVICE} &> /dev/null << EOF
${PART1_START},${PART1_SIZE},83
EOF

	sleep 2; sync;
	fdisk -l ${LPARAM_BLOCK_DEVICE}

	sleep 2; sync;

	# Format the partitions
	format_sdcard
	sleep 2; sync;

	flash_u-boot
	sleep 2; sync;

	# Mount the partitions
	mkdir -p ${P1_MOUNT_DIR}
	sync

	mount ${LPARAM_BLOCK_DEVICE}${part}1  ${P1_MOUNT_DIR}
	sleep 2; sync;

	flash_sdcard
	copy_debian_images
	copy_scripts

	pr_info "Syncing to SD card..."
	sync
	umount ${P1_MOUNT_DIR}

	rm -rf ${P1_MOUNT_DIR}

	pr_info "The SD card is ready"
}
