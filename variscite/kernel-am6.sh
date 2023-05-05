# make external Linux kernel modules
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function make_kernel_modules_ext() {
	# PowerVR Rogue GPU
	make -C ${G_TI_IMG_ROGUE_DRV_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} \
		ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} KERNELDIR=${3} \
		BUILD=release PVR_BUILD_DIR=am62_linux WINDOW_SYSTEM=wayland
}

# install the external Linux kernel modules
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function install_kernel_modules_ext() {
	# PowerVR Rogue GPU
	make ${G_CROSS_COMPILER_JOPTION} \
		ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} KERNELDIR=${3} \
		BUILD=release PVR_BUILD_DIR=am62_linux WINDOW_SYSTEM=wayland \
		-C ${3} M=${G_TI_IMG_ROGUE_DRV_SRC_DIR}/binary_am62_linux_wayland_release/target_aarch64/kbuild \
		INSTALL_MOD_PATH=${4} INSTALL_MOD_STRIP=1 \
		modules_install
}

# install the external Linux kernel modules
# $1 -- Linux dir path
function clean_kernel_modules_ext()
{
	# PowerVR Rogue GPU
	make -C ${G_TI_IMG_ROGUE_DRV_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} \
		ARCH=${ARCH_ARGS} KERNELDIR=${3} \
		BUILD=release PVR_BUILD_DIR=am62_linux WINDOW_SYSTEM=wayland \
		clean
}
