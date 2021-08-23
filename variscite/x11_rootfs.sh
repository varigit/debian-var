# Must be called after make_prepare in main script
# function generate rootfs in input dir
# $1 - rootfs base dir
function make_debian_x11_rootfs() {
	local ROOTFS_BASE=$1

	pr_info "Make debian(${DEB_RELEASE}) rootfs start..."

	# umount previus mounts (if fail)
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null || true

	# clear rootfs dir
	rm -rf ${ROOTFS_BASE}/*

	pr_info "rootfs: debootstrap"
	sudo mkdir -p ${ROOTFS_BASE}
	sudo chown -R root:root ${ROOTFS_BASE}
	debootstrap --verbose --no-check-gpg --foreign --arch armhf ${DEB_RELEASE} \
		${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}

	# prepare qemu
	pr_info "rootfs: debootstrap in rootfs (second-stage)"
	cp ${G_VARISCITE_PATH}/qemu_32bit/qemu-arm-static ${ROOTFS_BASE}/usr/bin/qemu-arm-static
	mount -o bind /proc ${ROOTFS_BASE}/proc
	mount -o bind /dev ${ROOTFS_BASE}/dev
	mount -o bind /dev/pts ${ROOTFS_BASE}/dev/pts
	mount -o bind /sys ${ROOTFS_BASE}/sys
	chroot $ROOTFS_BASE /debootstrap/debootstrap --second-stage --verbose

	# delete unused folder
	chroot $ROOTFS_BASE rm -rf  ${ROOTFS_BASE}/debootstrap

	pr_info "rootfs: generate default configs"
	mkdir -p ${ROOTFS_BASE}/etc/sudoers.d/
	echo "user ALL=(root) /usr/bin/apt-get, /usr/bin/dpkg, /usr/bin/vi, /sbin/reboot" > ${ROOTFS_BASE}/etc/sudoers.d/user
	chmod 0440 ${ROOTFS_BASE}/etc/sudoers.d/user
	mkdir -p ${ROOTFS_BASE}/srv/local-apt-repository

	# gstreamer-imx
	cp -r ${G_VARISCITE_PATH}/deb/gstreamer-imx/* \
		${ROOTFS_BASE}/srv/local-apt-repository

	# bluez-alsa
	cp -r ${G_VARISCITE_PATH}/deb/bluez-alsa/* \
		${ROOTFS_BASE}/srv/local-apt-repository

# add mirror to source list
echo "deb ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free
deb-src ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free
" > etc/apt/sources.list

# Don't check valid until for snapshot releases
echo "Acquire::Check-Valid-Until no;" > etc/apt/apt.conf.d/99no-check-valid-until

# raise backports priority
echo "Package: *
Pin: release n=${DEB_RELEASE}-backports
Pin-Priority: 500
" > etc/apt/preferences.d/backports

# maximize local repo priority
echo "Package: *
Pin: origin ""
Pin-Priority: 1000
" > etc/apt/preferences.d/local

# raise backports priority
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

function protected_install() {
    local _name=\${1}
    local repeated_cnt=5;
    local RET_CODE=1;

    for (( c=0; c<\${repeated_cnt}; c++ ))
    do
        apt-get install -y \${_name} && {
            RET_CODE=0;
            break;
        };

        echo ""
        echo "###########################"
        echo "## Fix missing packeges ###"
        echo "###########################"
        echo ""

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
protected_install reprepro

reprepro rereference
# update packages and install base
apt-get update || apt-get upgrade

protected_install locales
protected_install ntp
protected_install openssh-server
protected_install nfs-common

# packages required when flashing emmc
protected_install dosfstools

# fix config for sshd (permit root login)
sed -i -e 's/#PermitRootLogin.*/PermitRootLogin\tyes/g' /etc/ssh/sshd_config

#rng-tools
protected_install rng-tools

#udisk2
protected_install udisks2

#gvfs
protected_install gvfs

#gvfs-daemons
protected_install gvfs-daemons

# network manager
#protected_install network-manager-gnome

# net-tools (ifconfig, etc.)
protected_install net-tools

# enable graphical desktop
protected_install xorg
protected_install xfce4
protected_install xfce4-goodies


#network manager
protected_install network-manager-gnome

# net-tools (ifconfig, etc.)
protected_install net-tools

## fix lightdm config (added autologin x_user) ##
sed -i -e 's/\#autologin-user=/autologin-user=x_user/g' /etc/lightdm/lightdm.conf
sed -i -e 's/\#autologin-user-timeout=0/autologin-user-timeout=0/g' /etc/lightdm/lightdm.conf

# added alsa & alsa utilites
protected_install alsa-utils
protected_install gstreamer1.0-alsa

protected_install gstreamer1.0-plugins-bad
protected_install gstreamer1.0-plugins-base
protected_install gstreamer1.0-plugins-ugly
protected_install gstreamer1.0-plugins-good
protected_install gstreamer1.0-tools

# added gstreamer-imx
protected_install gstreamer-imx

# added i2c tools
protected_install i2c-tools

# added usb tools
protected_install usbutils

# added net tools
protected_install iperf3

# mtd
protected_install mtd-utils

# bluetooth
protected_install bluetooth
protected_install bluez-obexd
protected_install bluez-tools
protected_install bluez-alsa-utils

#shared-mime-info
protected_install shared-mime-info

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

# killall
protected_install psmisc

# libgpiod
protected_install gpiod

# remove pulseaudio
apt-get -y remove pulseaudio

apt-get -y autoremove
#update iptables alternatives to legacy
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

apt-get install -y --reinstall libgdk-pixbuf2.0-0

# create users and set password
useradd -m -G audio -s /bin/bash user
useradd -m -G audio -s /bin/bash x_user
usermod -a -G video user
usermod -a -G video x_user
echo "user:user" | chpasswd
echo "root:root" | chpasswd
passwd -d x_user

# sado kill
rm -f third-stage
EOF

	pr_info "rootfs: install selected debian packages (third-stage)"
	chmod +x third-stage
	LANG=C chroot ${ROOTFS_BASE} /third-stage
	# fourth-stage
	# install variscite-bt service
	install -m 0755 ${G_VARISCITE_PATH}/x11_resources/brcm_patchram_plus \
		${ROOTFS_BASE}/usr/bin
	install -d ${ROOTFS_BASE}/etc/bluetooth
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-bt.conf \
		${ROOTFS_BASE}/etc/bluetooth
	install -m 0755 ${G_VARISCITE_PATH}/x11_resources/variscite-bt \
		${ROOTFS_BASE}/etc/bluetooth
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/variscite-bt.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/variscite-bt.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-bt.service

	# install BT audio and main config
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/bluez5/files/audio.conf \
		${ROOTFS_BASE}/etc/bluetooth/
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/bluez5/files/main.conf \
		${ROOTFS_BASE}/etc/bluetooth/

	# install obexd configuration
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/bluez5/files/obexd.conf \
		${ROOTFS_BASE}/etc/dbus-1/system.d

	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/bluez5/files/obex.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/obex.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/obex.service

	# install bluez-alsa configuration
	install -m 0644 ${G_VARISCITE_PATH}/bluez-alsa.service \
		${ROOTFS_BASE}/lib/systemd/system
	install -m 0755 ${G_VARISCITE_PATH}/bluez-alsa \
		${ROOTFS_BASE}/etc/bluetooth/

	# Add alsa default configs
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/asound.state \
		${ROOTFS_BASE}/var/lib/alsa/
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/asound.conf ${ROOTFS_BASE}/etc/

	# install variscite-wifi service
	install -d ${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/blacklist.conf \
		${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/variscite-wifi.conf \
		${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/variscite-wifi-common.sh \
		${ROOTFS_BASE}/etc/wifi
	install -m 0755 ${G_VARISCITE_PATH}/x11_resources/variscite-wifi \
		${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/variscite-wifi.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -s /lib/systemd/system/variscite-wifi.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-wifi.service

	# remove pm-utils default scripts and install wifi / bt pm-utils script
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/sleep.d/
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/module.d/
	rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/power.d/
	install -m 0755 ${G_VARISCITE_PATH}/${MACHINE}/wifi.sh \
		${ROOTFS_BASE}/etc/pm/sleep.d/

	tar -xzf ${G_VARISCITE_PATH}/deb/shared-mime-info/mime_image_prebuilt.tar.gz -C \
		${ROOTFS_BASE}/
## end packages stage ##
[ "${G_USER_PACKAGES}" != "" ] && {

	pr_info "rootfs: install user defined packages (user-stage)"
	pr_info "rootfs: G_USER_PACKAGES \"${G_USER_PACKAGES}\" "

echo "#!/bin/bash
# update packages
apt-get update

# install all user packages
apt-get -y install ${G_USER_PACKAGES}

rm -f user-stage
" > user-stage

	chmod +x user-stage
	LANG=C chroot ${ROOTFS_BASE} /user-stage

};

	# binaries rootfs patching
	install -m 0644 ${G_VARISCITE_PATH}/issue ${ROOTFS_BASE}/etc/
	install -m 0644 ${G_VARISCITE_PATH}/issue.net ${ROOTFS_BASE}/etc/
	install -m 0755 ${G_VARISCITE_PATH}/x11_resources/rc.local ${ROOTFS_BASE}/etc/
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/hostapd.conf ${ROOTFS_BASE}/etc/
	install -d ${ROOTFS_BASE}/boot/
	install -m 0644 ${G_VARISCITE_PATH}/splash.bmp ${ROOTFS_BASE}/boot/
	install -m 0644 ${G_VARISCITE_PATH}/wallpaper.png \
		${ROOTFS_BASE}/usr/share/images/desktop-base/default

	# disable light-locker
	install -m 0755 ${G_VARISCITE_PATH}/x11_resources/disable-lightlocker \
		${ROOTFS_BASE}/usr/local/bin/
	install -m 0644 ${G_VARISCITE_PATH}/x11_resources/disable-lightlocker.desktop \
		${ROOTFS_BASE}/etc/xdg/autostart/

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
	cp ${G_VARISCITE_PATH}/${MACHINE}/kobs-ng ${ROOTFS_BASE}/usr/bin
	cp ${PARAM_OUTPUT_DIR}/fw_printenv-mmc ${ROOTFS_BASE}/usr/bin
	cp ${PARAM_OUTPUT_DIR}/fw_printenv-nand ${ROOTFS_BASE}/usr/bin
	ln -sf fw_printenv-nand ${ROOTFS_BASE}/usr/bin/fw_printenv
	ln -sf fw_printenv ${ROOTFS_BASE}/usr/bin/fw_setenv
	cp ${G_VARISCITE_PATH}/${MACHINE}/fw_env.config ${ROOTFS_BASE}/etc
	cp ${G_VARISCITE_PATH}/automount.rules ${ROOTFS_BASE}/etc/udev/rules.d

## clenup command
echo "#!/bin/bash
apt-get clean
rm -rf /tmp/*
rm -f cleanup
" > cleanup

	# clean all packages
	pr_info "rootfs: clean"
	chmod +x cleanup
	chroot ${ROOTFS_BASE} /cleanup
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null || true

	# kill latest dbus-daemon instance due to qemu-arm-static
	QEMU_PROC_ID=$(ps axf | grep dbus-daemon | grep qemu-arm-static | awk '{print $1}')
	if [ -n "$QEMU_PROC_ID" ]
	then
		kill -9 $QEMU_PROC_ID
	fi

	rm ${ROOTFS_BASE}/usr/bin/qemu-arm-static
}

# Must be called after make_debian_x11_rootfs in main script
# function generate ubi rootfs in input dir
# $1 - rootfs ubifs base dir
function prepare_x11_ubifs_rootfs() {
	local UBIFS_ROOTFS_BASE=$1
	pr_info "Make debian(${DEB_RELEASE}) rootfs for UBIFS start..."

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
# make sdcard for device
# $1 -- block device
# $2 -- output images dir
function make_x11_sdcard() {
	readonly local LPARAM_BLOCK_DEVICE=${1}
	readonly local LPARAM_OUTPUT_DIR=${2}
	readonly local P1_MOUNT_DIR="${G_TMP_DIR}/p1"
	readonly local P2_MOUNT_DIR="${G_TMP_DIR}/p2"
	readonly local DEBIAN_IMAGES_TO_ROOTFS_POINT="opt/images/Debian"

	readonly local BOOTLOAD_RESERVE=4
	readonly local BOOT_ROM_SIZE=12
	readonly local SPARE_SIZE=0

	[ "${LPARAM_BLOCK_DEVICE}" = "na" ] && {
		pr_warning "No valid block device: ${LPARAM_BLOCK_DEVICE}"
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
		pr_info "Formating SDCARD partitions"
		mkfs.vfat ${LPARAM_BLOCK_DEVICE}${part}1 -n BOOT-VARSOM
		mkfs.ext4 ${LPARAM_BLOCK_DEVICE}${part}2 -L rootfs
	}

	function flash_u-boot
	{
		pr_info "Flashing U-Boot"
		dd if=${LPARAM_OUTPUT_DIR}/${G_SPL_NAME_FOR_EMMC} \
		of=${LPARAM_BLOCK_DEVICE} bs=1K seek=1; sync
		dd if=${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_EMMC} \
		of=${LPARAM_BLOCK_DEVICE} bs=1K seek=69; sync
	}

	function flash_sdcard
	{
		pr_info "Flashing \"BOOT-VARSOM\" partition"
		cp ${LPARAM_OUTPUT_DIR}/*.dtb	${P1_MOUNT_DIR}/
		cp ${LPARAM_OUTPUT_DIR}/${BUILD_IMAGE_TYPE} \
			${P1_MOUNT_DIR}/${BUILD_IMAGE_TYPE}
		sync

		pr_info "Flashing \"rootfs\" partition"
		tar -xpf ${LPARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBALL_NAME} \
			 -C ${P2_MOUNT_DIR}/
	}

	function copy_debian_images
	{
		mkdir -p ${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}

		pr_info "Copying Debian images to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/${BUILD_IMAGE_TYPE} \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
		   [ "${MACHINE}" = "var-som-mx7" ]; then
			cp ${LPARAM_OUTPUT_DIR}/rootfs.ubi.img \
			${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		fi
		cp ${LPARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBALL_NAME} \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/${DEF_ROOTFS_TARBALL_NAME}

		cp ${LPARAM_OUTPUT_DIR}/*.dtb \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/

		pr_info "Copying NAND U-Boot to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/${G_SPL_NAME_FOR_NAND} \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		cp ${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_NAND} \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/

		pr_info "Copying MMC U-Boot to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/${G_SPL_NAME_FOR_EMMC} \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		cp ${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_EMMC} \
		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/

		return 0;
	}

	function copy_scripts
	{
		pr_info "Copying scripts to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
		   [ "${MACHINE}" = "var-som-mx7" ]; then
			cp ${G_VARISCITE_PATH}/mx6ul_mx7_install_debian.sh \
				${P2_MOUNT_DIR}/usr/sbin/install_debian.sh
		fi
	}

	function ceildiv
	{
		local num=$1
		local div=$2
		echo $(( (num + div - 1) / div ))
	}

	# Delete the partitions
	for ((i=0; i<10; i++))
	do
		if [ -e ${LPARAM_BLOCK_DEVICE}${part}${i} ]; then
			dd if=/dev/zero of=${LPARAM_BLOCK_DEVICE}${part}$i bs=512 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk ${LPARAM_BLOCK_DEVICE} &> /dev/null) || true
	sync

	dd if=/dev/zero of=${LPARAM_BLOCK_DEVICE} bs=1024 count=4096
	sleep 2; sync;

	pr_info "Creating new partitions"

	# Create a new partition table
fdisk ${LPARAM_BLOCK_DEVICE} <<EOF
n
p
1
8192
32767
t
c
n
p
2
32768

p
w
EOF
	sleep 2; sync;

	# Get total card size
	total_size=`sfdisk -s ${LPARAM_BLOCK_DEVICE}`
	total_size=`expr ${total_size} / 1024`
	boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
	rootfs_size=`expr ${total_size} - ${boot_rom_sizeb} - ${SPARE_SIZE}`

	pr_info "ROOT SIZE=${rootfs_size} TOTAl SIZE=${total_size} BOOTROM SIZE=${boot_rom_sizeb}"
	sleep 2; sync;

	# Format the partitions
	format_sdcard
	sleep 2; sync;

	flash_u-boot
	sleep 2; sync;

	# Mount the partitions
	mkdir -p ${P1_MOUNT_DIR}
	mkdir -p ${P2_MOUNT_DIR}
	sync

	mount ${LPARAM_BLOCK_DEVICE}${part}1  ${P1_MOUNT_DIR}
	mount ${LPARAM_BLOCK_DEVICE}${part}2  ${P2_MOUNT_DIR}
	sleep 2; sync;

	flash_sdcard
	copy_debian_images
	copy_scripts

	pr_info "Sync sdcard..."
	sync
	umount ${P1_MOUNT_DIR}
	umount ${P2_MOUNT_DIR}

	rm -rf ${P1_MOUNT_DIR}
	rm -rf ${P2_MOUNT_DIR}

	pr_info "Done make sdcard!"
}
