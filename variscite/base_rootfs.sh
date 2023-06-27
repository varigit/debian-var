# Must be called after make_prepare in main script
# generate base rootfs in input dir
# $1 - rootfs base dir
function make_debian_base_rootfs() {
	local ROOTFS_BASE=$1

	pr_info "Make Debian (${DEB_RELEASE}) rootfs start..."

	# umount previus mounts (if fail)
	cleanup_mounts

	pr_info "rootfs: debootstrap"
	if [ ! -d "${ROOTFS_BASE}" ]; then
		sudo mkdir -p ${ROOTFS_BASE}
		sudo chown -R root:root ${ROOTFS_BASE}
	fi

	pr_info "rootfs: debootstrap in rootfs (first-stage)"
	if [ "${MACHINE}" = "var-som-mx6" ] ||
	   [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		check_step "debootstrap first-stage" || debootstrap --verbose --no-check-gpg --foreign --arch armhf ${DEB_RELEASE} \
			${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}
		# prepare qemu 32bit
		cp ${G_VARISCITE_PATH}/qemu_32bit/qemu-arm-static ${ROOTFS_BASE}/usr/bin/qemu-arm-static
	else
		check_step "debootstrap first-stage" || debootstrap --verbose --no-check-gpg --foreign --arch arm64 ${DEB_RELEASE} \
			${ROOTFS_BASE}/ ${PARAM_DEB_LOCAL_MIRROR}
		# prepare qemu 64bit
		cp ${G_VARISCITE_PATH}/qemu_64bit/qemu-aarch64-static ${ROOTFS_BASE}/usr/bin/qemu-aarch64-static
	fi
	save_step "debootstrap first-stage"

	# prepare qemu
	pr_info "rootfs: debootstrap in rootfs (second-stage)"
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
}
