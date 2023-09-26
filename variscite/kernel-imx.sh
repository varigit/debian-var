# make external Linux kernel modules
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function make_kernel_modules_ext() {
	# Store the default values.
	local _DEFAULT_ARCH=$ARCH
	local _DEFAULT_CROSS_COMPILE=$CROSS_COMPILE
	local _DEFAULT_KERNELDIR=$KERNELDIR
	local _WORK_DIR=$(pwd)

	# Export environment args for drivers with Makefiles that require them
	export ARCH=${ARCH_ARGS}
	export CROSS_COMPILE=${1}
	export KERNELDIR=${3}

	# IW612 Driver
	if [ -n "$G_IW612_DRV_SRC_DIR" ] && [ -d "$G_IW612_DRV_SRC_DIR" ]; then
		pr_info "make_kernel_modules_ext iw612"
		cd ${G_IW612_DRV_WORK_DIR}
		make build ${G_CROSS_COMPILER_JOPTION}
	fi

	# Restore Environment
	cd ${WORK_DIR}
	export ARCH=${_DEFAULT_ARCH}
	export CROSS_COMPILE=$_{DEFAULT_CROSS_COMPILE}
	export KERNELDIR=${_DEFAULT_KERNELDIR}
}

# install the external Linux kernel modules
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function install_kernel_modules_ext() {
	# IW612 Driver
	if [ -n "$G_IW612_DRV_SRC_DIR" ] && [ -d "$G_IW612_DRV_SRC_DIR" ]; then
		pr_info "install_kernel_modules_ext iw612"
		make V=1 ${G_CROSS_COMPILER_JOPTION} \
			ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} KERNELDIR=${3} \
			-C ${3} INSTALL_MOD_PATH=${4} INSTALL_MOD_STRIP=1 \
			M=${G_IW612_DRV_WORK_DIR} \
			modules_install
	fi
}

# install the external Linux kernel modules
# $1 -- Linux dir path
function clean_kernel_modules_ext()
{
	local _WORK_DIR=$(pwd)

	# IW612 Driver
	if [ -n "$G_IW612_DRV_SRC_DIR" ] && [ -d "$G_IW612_DRV_SRC_DIR" ]; then
		pr_info "clean_kernel_modules_ext iw612"
		cd ${G_IW612_DRV_WORK_DIR}
		rm -rf ../bin_wlan
		make clean
		cd ${_WORK_DIR}
	fi
}
