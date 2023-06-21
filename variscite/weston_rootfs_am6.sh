# copy common packages
function copy_common_packages() {
	:
}

# copy display and gpu packages
function copy_packages_display() {
	# PowerVR Rogue GPU SDK Binaries
	if [ ! -z "${G_TI_IMG_ROGUE_UMLIBS_PACKAGE_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_TI_IMG_ROGUE_UMLIBS_PACKAGE_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# PowerVR Graphics SDK
	if [ ! -z "${G_TI_POWERVR_GRAPHICS}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_TI_POWERVR_GRAPHICS}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi
}

# copy machine lerning packages
function copy_packages_ml() {
	:
}
