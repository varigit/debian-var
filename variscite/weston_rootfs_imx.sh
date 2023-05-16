# copy common packages
function copy_common_packages() {
	# imx-firmware
	if [ ! -z "${IMX_FIRMWARE_VERSION}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/imx-firmware-${IMX_FIRMWARE_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi
}

# copy display and gpu packages
function copy_packages_display() {
	# cairo
	if [ ! -z "${CAIRO_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${CAIRO_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# libdrm
	if [ ! -z "${LIBDRM_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${LIBDRM_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# waylandprotocols
	if [ ! -z "${WAYLAND_PROTOCOL_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${WAYLAND_PROTOCOL_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# weston
	if [ ! -z "${WESTON_PACKAGE_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/weston/${WESTON_PACKAGE_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# G2D_Packages
	if [ ! -z "${G2D_PACKAGE_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G2D_PACKAGE_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# Vivante GPU libgbm1 libraries
	if [ ! -z "${G_GPU_IMX_VIV_GBM_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_GPU_IMX_VIV_GBM_DIR}/* \
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
}

# copy gstreamer and multimedia packages only if distro feature enabled
function copy_packages_mm() {
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

	# imxvpuhantro-vc
	if [ ! -z "${G_IMX_VPU_HANTRO_VC_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_VPU_HANTRO_VC_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# imx-vpuwrap
	if [ ! -z "${G_IMX_VPU_WRAPPER_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_VPU_WRAPPER_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# gstreamer-libav for SW codecs
	if [ ! -z "${G_SW_GST_CODEC_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_SW_GST_CODEC_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# use gstpluginsbad dir if available
	if [ ! -z "${G_GST_PLUGINS_BAD_DIR}" ]; then
		# gstpluginsbad
		cp -r ${G_VARISCITE_PATH}/deb/gstpluginsbad/${G_GST_PLUGINS_BAD_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	else
		# gstpluginsbad
		if [ ! -z "${GST_MM_VERSION}" ]; then
			cp -r ${G_VARISCITE_PATH}/deb/gstpluginsbad/${GST_MM_VERSION}/* \
				${ROOTFS_BASE}/srv/local-apt-repository
		fi
	fi

	if [ ! -z "${GST_MM_VERSION}" ]; then
		# gstpluginsbase
		cp -r ${G_VARISCITE_PATH}/deb/gstpluginsbase/${GST_MM_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository

		# gstpluginsgood
		cp -r ${G_VARISCITE_PATH}/deb/gstpluginsgood/${GST_MM_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository

		# gstreamer
		cp -r ${G_VARISCITE_PATH}/deb/gstreamer/${GST_MM_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository

		# imxgstplugin
		cp -r ${G_VARISCITE_PATH}/deb/imxgstplugin/${GST_MM_VERSION}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi

	# opencv
	if [ ! -z "${G_OPENCV_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_OPENCV_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi
}

# copy machine lerning packages
copy_packages_ml() {
	# imx-nn
	if [ ! -z "${G_IMX_NN_DIR}" ]; then
		cp -r ${G_VARISCITE_PATH}/deb/${G_IMX_NN_DIR}/* \
			${ROOTFS_BASE}/srv/local-apt-repository
	fi
}
