# copy common packages
function copy_common_packages() {
	# var-mii
	copy_required_package "var-mii_1.0"

	# imx-firmware
	if [ ! -z "${IMX_FIRMWARE_VERSION}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/imx-firmware-${IMX_FIRMWARE_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi
}

# copy display and gpu packages
function copy_packages_display() {
	# cairo
	copy_optional_package "${CAIRO_DIR}"

	# libdrm
	copy_optional_package "${LIBDRM_DIR}"

	# waylandprotocols
	copy_optional_package "${WAYLAND_PROTOCOL_DIR}"

	# weston
	copy_optional_package "${WESTON_PACKAGE_DIR}"

	# G2D_Packages
	copy_optional_package "${G2D_PACKAGE_DIR}"

	# Vivante GPU libgbm1 libraries
	copy_optional_package "${G_GPU_IMX_VIV_GBM_DIR}"

	# Vivante GPU libraries
	copy_optional_package "${G_GPU_IMX_VIV_PACKAGE_DIR}"

	# Vivante GPU SDK Binaries
	copy_optional_package "${G_GPU_IMX_VIV_SDK_PACKAGE_DIR}"
}

# copy gstreamer and multimedia packages only if distro feature enabled
function copy_packages_mm() {
	# imxcodec
	copy_optional_package "${G_IMX_CODEC_DIR}"

	# imxparser
	copy_optional_package "${G_IMX_PARSER_DIR}"

	# imxvpuhantro
	copy_optional_package "${G_IMX_VPU_HANTRO_DIR}"

	# imxvpuhantro-vc
	copy_optional_package "${G_IMX_VPU_HANTRO_VC_DIR}"

	# imx-vpuwrap
	copy_optional_package "${G_IMX_VPU_WRAPPER_DIR}"

	# gstreamer-libav for SW codecs
	copy_optional_package "${G_SW_GST_CODEC_DIR}"

	# use gstpluginsbad dir if available
	if [ ! -z "${G_GST_PLUGINS_BAD_DIR}" ]; then
		# gstpluginsbad
		copy_required_package "gstpluginsbad/${G_GST_PLUGINS_BAD_DIR}"
	else
		# gstpluginsbad
		if [ ! -z "${GST_MM_VERSION}" ]; then
			copy_required_package "gstpluginsbad/${GST_MM_VERSION}"
		fi
	fi

	if [ ! -z "${GST_MM_VERSION}" ]; then
		# gstpluginsbase
		copy_required_package "gstpluginsbase/${GST_MM_VERSION}"

		# gstpluginsgood
		copy_required_package "gstpluginsgood/${GST_MM_VERSION}"

		# gstreamer
		copy_required_package "gstreamer/${GST_MM_VERSION}"

		# imxgstplugin
		copy_required_package "imxgstplugin/${GST_MM_VERSION}"
	fi

	# opencv
	copy_optional_package "${G_OPENCV_DIR}"
}

# copy machine lerning packages
copy_packages_ml() {
	# imx-nn
	copy_optional_package "${G_IMX_NN_DIR}"
}
