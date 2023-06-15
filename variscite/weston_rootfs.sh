function run_rootfs_stage() {
	STAGE="${1}"
	DESCRIPTION="${2}"
	pr_info "${DESCRIPTION}"
	cp ${G_VARISCITE_PATH}/${STAGE} ${ROOTFS_BASE}
	chmod +x ${ROOTFS_BASE}/${STAGE}
	chroot ${ROOTFS_BASE} /${STAGE}
}

function rootfs_copy_packages() {
	# copy common packages
	[[ $(type -t copy_common_packages) == function ]] && copy_common_packages

	# copy display and gpu packages only if distro feature enabled
	if [ "${G_DEBIAN_DISTRO_FEATURE_GRAPHICS}" = "y" ]; then
		[[ $(type -t copy_packages_display) == function ]] && copy_packages_display
	fi

	# copy gstreamer and multimedia packages only if distro feature enabled
	if [ "${G_DEBIAN_DISTRO_FEATURE_MM}" = "y" ]; then
		[[ $(type -t copy_packages_mm) == function ]] && copy_packages_mm
	fi

	# copy machine lerning packages only if distro feature enabled
	if [ "${G_DEBIAN_DISTRO_FEATURE_ML}" = "y" ]; then
		[[ $(type -t copy_packages_ml) == function ]] && copy_packages_ml
	fi
}

function rootfs_configure() {
# add mirror to source list
echo "deb ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free-firmware
deb-src ${DEF_DEBIAN_MIRROR} ${DEB_RELEASE} main contrib non-free-firmware
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

echo "
/dev/root            /                    auto       defaults              1  1
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
}

function rootfs_install_kernel() {
	# install kernel image in rootfs
	cp ${PARAM_OUTPUT_DIR}/${KERNEL_IMAGE_TYPE} ${ROOTFS_BASE}/boot

	# install kernel dtbs
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

	# install kernel modules in rootfs
	install_kernel_modules \
		${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_LINUX_KERNEL_DEF_CONFIG} ${G_LINUX_KERNEL_SRC_DIR} \
		${ROOTFS_BASE}

	# copy all kernel headers for development
	mkdir -p ${ROOTFS_BASE}/usr/local/src/linux-imx
	if [ ! -z "${UAPI_PATH}" ]; then
		mkdir -p ${ROOTFS_BASE}/usr/local/src/linux-imx/${UAPI_PATH}
		cp ${G_LINUX_KERNEL_SRC_DIR}/drivers/staging/android/uapi/* \
		${ROOTFS_BASE}/usr/local/src/linux-imx/drivers/staging/android/uapi
	fi
	cp -r ${G_LINUX_KERNEL_SRC_DIR}/include \
		${ROOTFS_BASE}/usr/local/src/linux-imx/
}

function rootfs_install_var_bt {
	# install variscite-bt service
	install -m 0755 ${G_VARISCITE_PATH}/brcm_patchram_plus \
		${ROOTFS_BASE}/usr/bin
	install -d ${ROOTFS_BASE}/etc/bluetooth
	install -m 0755 ${BRCM_UTILS_DIR}/${MACHINE}/variscite-bt \
		${ROOTFS_BASE}/etc/bluetooth
	install -m 0644 ${BRCM_UTILS_DIR}/variscite-bt.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -sf /lib/systemd/system/variscite-bt.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-bt.service
}

function rootfs_install_var_wifi() {
	# install variscite-wifi service
	install -d ${ROOTFS_BASE}/etc/wifi
	install -m 0755 ${BRCM_UTILS_DIR}/${MACHINE}/variscite-wifi \
		${ROOTFS_BASE}/etc/wifi
	install -m 0644 ${BRCM_UTILS_DIR}/variscite-wifi.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -sf /lib/systemd/system/variscite-wifi.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/variscite-wifi.service
}

function rootfs_install_config_bt() {
	# install BT audio and main config
	install -m 0644 ${BLUEZ5_DIR}/audio.conf \
		${ROOTFS_BASE}/etc/bluetooth/
	install -m 0644 ${BLUEZ5_DIR}/main.conf \
		${ROOTFS_BASE}/etc/bluetooth/

	# install obexd configuration
	install -m 0644 ${BLUEZ5_DIR}/obexd.conf \
		${ROOTFS_BASE}/etc/dbus-1/system.d

	install -m 0644 ${BLUEZ5_DIR}/obex.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -sf /lib/systemd/system/obex.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/obex.service
}

function rootfs_install_config_pulseaudio() {
	# install pulse audio configuration
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/pulseaudio.service \
		${ROOTFS_BASE}/lib/systemd/system
	ln -sf /lib/systemd/system/pulseaudio.service \
		${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/pulseaudio.service
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/pulseaudio-bluetooth.conf \
		${ROOTFS_BASE}/etc//dbus-1/system.d
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/system.pa \
		${ROOTFS_BASE}/etc/pulse/
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/pulseaudio/client.conf \
		${ROOTFS_BASE}/etc/pulse/

	rm -rf ${ROOTFS_BASE}/etc/systemd/user/sockets.target.wants/pulseaudio.socket
	rm -rf ${ROOTFS_BASE}/etc/systemd/user/default.target.wants/pulseaudio.service
	
	rm -f ${ROOTFS_BASE}/etc/xdg/autostart/pulseaudio.desktop
}

function rootfs_install_config_blacklist() {
	# install blacklist.conf
	install -d ${ROOTFS_BASE}/etc/modprobe.d/
	install -m 0644 ${G_VARISCITE_PATH}/${MACHINE}/blacklist.conf \
		${ROOTFS_BASE}/etc/modprobe.d/
}

function rootfs_install_config_securetty() {
	#install securetty
	install -m 0644 ${G_VARISCITE_PATH}/securetty \
		${ROOTFS_BASE}/etc/securetty
}

function rootfs_install_config_weston_service() {
	if [ "${G_DEBIAN_DISTRO_FEATURE_GRAPHICS}" = "y" ]; then
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
		ln -sf /lib/systemd/system/weston.service \
			${ROOTFS_BASE}/etc/systemd/system/multi-user.target.wants/weston.service
	fi
}

function rootfs_install_config_pm_utils() {
	# install freertos-variscite
	if [ ! -z "${PM_UTILS_DIR}" ]; then
		# remove pm-utils default scripts and install wifi / bt pm-utils script
		rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/sleep.d/
		rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/module.d/
		rm -rf ${ROOTFS_BASE}/usr/lib/pm-utils/power.d/
		install -m 0755 ${PM_UTILS_DIR}/01-bt.sh \
			${ROOTFS_BASE}/etc/pm/sleep.d/
		install -m 0755 ${PM_UTILS_DIR}/02-wifi.sh \
			${ROOTFS_BASE}/etc/pm/sleep.d/
		if [ -f ${PM_UTILS_DIR}/03-eth.sh ]; then
			install -m 0755 ${PM_UTILS_DIR}/03-eth.sh \
				${ROOTFS_BASE}/etc/pm/sleep.d/
		fi
		if [ -f ${PM_UTILS_DIR}/04-usb.sh ]; then
			install -m 0755 ${PM_UTILS_DIR}/04-usb.sh \
				${ROOTFS_BASE}/etc/pm/sleep.d/
		fi
	fi
}

function rootfs_install_config_logind() {
	# we don't want systemd to handle the power key
	echo "HandlePowerKey=ignore" >> ${ROOTFS_BASE}/etc/systemd/logind.conf
}

function rootfs_build_kernel_headers() {
	#Build kernel headers on the target
	cp -ar ${PARAM_OUTPUT_DIR}/kernel-headers ${ROOTFS_BASE}/tmp/
	run_rootfs_stage "rootfs-stage-header" "rootfs: Building kernel-headers"
}

function rootfs_install_user_packages() {
	#Install user pacakges if any
	if [ "${G_USER_PACKAGES}" != "" ] ; then
		pr_info "rootfs: install user defined packages (user-stage)"
		run_rootfs_stage "rootfs-stage-user" "rootfs: G_USER_PACKAGES \"${G_USER_PACKAGES}\""
	fi
}

function rootfs_install_config_alsa() {
	# Add alsa default configs
	install -m 0644 ${G_VARISCITE_PATH}/asound.state \
		${ROOTFS_BASE}/var/lib/alsa/
	install -m 0644 ${G_VARISCITE_PATH}/asound.conf ${ROOTFS_BASE}/etc/
}

function rootfs_install_freertos_variscite() {
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
		if [ "${MACHINE}" = "imx8mp-var-dart" ]; then
			# Build all boards in CM_BOARD
			for cm_board in ${CM_BOARD}; do

				case "$cm_board" in
				dart_mx8mp) :
				    CM_FW_SUFFIX="dart"
				;;
				som_mx8mp) :
				    CM_FW_SUFFIX="som"
				;;
				esac

				# Install all demos in CM_DEMOS
				for CM_DEMO in ${CM_DEMOS}; do
				    DIR_GCC="${G_FREERTOS_VAR_BUILD_DIR}/boards/${cm_board}/${CM_DEMO}/armgcc"
				    # Install all build targets
				    for CM_BUILD_TARGET in ${CM_BUILD_TARGETS}; do
					# Install elf
					FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.elf)"
					install -m 0644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${ROOTFS_BASE}/lib/firmware/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}_${CM_FW_SUFFIX}
					# Install bin
					FILE_CM_FW="$(basename ${DIR_GCC}/${CM_BUILD_TARGET}/*.bin)"
					install -m 644 ${DIR_GCC}/${CM_BUILD_TARGET}/${FILE_CM_FW} ${ROOTFS_BASE}/boot/cm_${FILE_CM_FW}.${CM_BUILD_TARGET}_${CM_FW_SUFFIX}
				    done
				done
			done
		else
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
		fi

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

# function configure_apt() {
# }

# Must be called after make_prepare in main script
# generate weston rootfs in input dir
# $1 - rootfs base dir
function make_debian_weston_rootfs()
{
	local ROOTFS_BASE=$1

	pr_info "Make Debian (${DEB_RELEASE}) rootfs start..."

	# umount previus mounts (if fail)
	cleanup_mounts

	pr_info "rootfs: debootstrap"
	if [ ! -d "${ROOTFS_BASE}" ]; then
		sudo mkdir -p ${ROOTFS_BASE}
		sudo chown -R root:root ${ROOTFS_BASE}
	fi
	check_step "debootstrap first-stage" || debootstrap --verbose --no-check-gpg --foreign --arch arm64 ${DEB_RELEASE} \
		${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}
	save_step "debootstrap first-stage"

	# prepare qemu
	pr_info "rootfs: debootstrap in rootfs (second-stage)"
	cp ${G_VARISCITE_PATH}/qemu_64bit/qemu-aarch64-static ${ROOTFS_BASE}/usr/bin/qemu-aarch64-static
	mount -o bind /proc ${ROOTFS_BASE}/proc
	mount -o bind /dev ${ROOTFS_BASE}/dev
	mount -o bind /dev/pts ${ROOTFS_BASE}/dev/pts
	mount -o bind /sys ${ROOTFS_BASE}/sys
	check_step "debootstrap second-stage" || chroot $ROOTFS_BASE /debootstrap/debootstrap --second-stage --verbose
	save_step "debootstrap second-stage"

	# delete unused folder
	chroot $ROOTFS_BASE rm -rf ${ROOTFS_BASE}/debootstrap

	pr_info "rootfs: generate default configs"
	mkdir -p ${ROOTFS_BASE}/etc/sudoers.d/
	echo "user ALL=(root) /usr/bin/apt-get, /usr/bin/dpkg, /usr/bin/vi, /sbin/reboot" > ${ROOTFS_BASE}/etc/sudoers.d/user
	chmod 0440 ${ROOTFS_BASE}/etc/sudoers.d/user
	mkdir -p ${ROOTFS_BASE}/srv/local-apt-repository

	run_step "rootfs_copy_packages"

	run_step "rootfs_configure"

	run_step "run_rootfs_stage" "rootfs-stage-base" "rootfs: install selected Debian packages (console-only-stage)"

	if [ "${G_DEBIAN_DISTRO_FEATURE_GRAPHICS}" = "y" ]; then
		run_step "run_rootfs_stage" "rootfs-stage-graphics" "rootfs: install selected Debian packages (Graphics - GPU/Weston)"
	else
		rm -f ${ROOTFS_BASE}/rootfs-stage-graphics
	fi

	if [ "${G_DEBIAN_DISTRO_FEATURE_MM}" = "y" ]; then
		run_step "run_rootfs_stage" "rootfs-stage-gstreamer" "rootfs: install selected Debian packages (MM Gstreamer)"
	else
		rm -f ${ROOTFS_BASE}/rootfs-stage-gstreamer
	fi

	if [ "${G_DEBIAN_DISTRO_FEATURE_ML}" = "y" ]; then
		run_step "run_rootfs_stage" "rootfs-stage-ml" "rootfs: install selected Debian packages (Machine Learning)"
	else
		rm -f ${ROOTFS_BASE}/rootfs-stage-ml
	fi

	run_step "rootfs_install_var_bt"
	run_step "rootfs_install_var_wifi"
	run_step "rootfs_install_config_bt"
	run_step "rootfs_install_config_pulseaudio"
	run_step "rootfs_install_config_blacklist"
	run_step "rootfs_install_config_securetty"
	run_step "rootfs_install_config_weston_service"
	run_step "rootfs_install_config_pm_utils"
	run_step "rootfs_install_config_logind"
	run_step "rootfs_build_kernel_headers"
	run_step "rootfs_install_kernel"
	run_step "rootfs_install_user_packages"
	run_step "rootfs_install_config_alsa"
	run_step "rootfs_install_freertos_variscite"

	# binaries rootfs patching
	install -m 0644 ${G_VARISCITE_PATH}/issue ${ROOTFS_BASE}/etc/
	install -m 0644 ${G_VARISCITE_PATH}/issue.net ${ROOTFS_BASE}/etc/
	install -m 0755 ${G_VARISCITE_PATH}/rc.local ${ROOTFS_BASE}/etc/
	install -d ${ROOTFS_BASE}/boot/
	install -m 0644 ${G_VARISCITE_PATH}/splash.bmp ${ROOTFS_BASE}/boot/
	echo "kernelargs=net.ifnames=0" >> ${ROOTFS_BASE}/boot/uEnv.txt

	mkdir -p ${ROOTFS_BASE}/usr/share/images/desktop-base/
	install -m 0644 ${G_VARISCITE_PATH}/wallpaper_hd.png \
		${ROOTFS_BASE}/usr/share/images/desktop-base/default

	# Revert regular booting
	rm -f ${ROOTFS_BASE}/usr/sbin/policy-rc.d

	# copy custom files
	cp ${UBOOT_FW_UTILS_DIR}/fw_env.config ${ROOTFS_BASE}/etc
	cp ${PARAM_OUTPUT_DIR}/fw_printenv ${ROOTFS_BASE}/usr/bin
	ln -sf fw_printenv ${ROOTFS_BASE}/usr/bin/fw_setenv
	cp ${G_VARISCITE_PATH}/10-imx.rules ${ROOTFS_BASE}/etc/udev/rules.d
	cp ${G_VARISCITE_PATH}/automount.rules ${ROOTFS_BASE}/etc/udev/rules.d

	if [ "${MACHINE}" = "imx8m-var-dart" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/*.rules ${ROOTFS_BASE}/etc/udev/rules.d
	fi

	#clenup command
	echo "#!/bin/bash
	apt-get clean
	rm -rf /tmp/*
	rm -f cleanup
	" > cleanup

	# clean all packages
	pr_info "rootfs: clean"
	chmod +x cleanup
	chroot ${ROOTFS_BASE} /cleanup
	cleanup_mounts

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
function make_weston_sdcard_imx()
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

# make SD card for device
# $1 -- block device
# $2 -- output images dir
function make_weston_sdcard_am6() {
	EMMC_BLOCK=$(basename "$1")
	IMGS_PATH="$2"
	PART=""
	INSTALL_OS="Debian"
	. ${G_META_VARISCITE_SDK_SRC_DIR}/scripts/variscite/am6_install_yocto.sh
}

# make SD card for device
# $1 -- block device
# $2 -- output images dir
function make_weston_sdcard() {
	# Make SD card according to SOC_FAMILY
	case "${SOC_FAMILY}" in
		am6)
			make_weston_sdcard_am6  "$1" "$2"
			;;
		imx*)
			make_weston_sdcard_imx "$1" "$2"
			;;
		*)
			echo "E: make_weston_sdcard: Unknown SOC_FAMILY \"${SOC_FAMILY}\"";
			exit 1
			;;
	esac
}
