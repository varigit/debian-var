# copy common packages
function copy_common_packages() {
	# k3conf
	copy_optional_package "${G_K3CONF_PACKAGE_DIR}"
}

# copy display and gpu packages
function copy_packages_display() {
	# PowerVR Rogue GPU SDK Binaries
	copy_optional_package "${G_TI_IMG_ROGUE_UMLIBS_PACKAGE_DIR}"

	# PowerVR Graphics SDK
	copy_optional_package "${G_TI_POWERVR_GRAPHICS}"
}

# copy machine lerning packages
function copy_packages_ml() {
	:
}

# copy ti remote cores packages
function copy_packages_remote_cores() {
	copy_optional_package "${G_TI_REMOTE_CORES_PACKAGE_DIR}"
}
