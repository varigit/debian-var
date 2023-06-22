# copy common packages
function copy_common_packages() {
	# var-mii
	copy_required_package "var-mii_1.0"
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
