#!/bin/bash
# It is designed to build Debian Linux for Variscite iMX modules
# prepare host OS system:
#  sudo apt-get install binfmt-support qemu qemu-user-static debootstrap kpartx
#  sudo apt-get install lvm2 dosfstools gpart binutils git lib32ncurses5-dev python-m2crypto
#  sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev
#  sudo apt-get install autoconf libtool libglib2.0-dev libarchive-dev
#  sudo apt-get install python-git xterm sed cvs subversion coreutils texi2html
#  sudo apt-get install docbook-utils python-pysqlite2 help2man make gcc g++ desktop-file-utils libgl1-mesa-dev
#  sudo apt-get install libglu1-mesa-dev mercurial automake groff curl lzop asciidoc u-boot-tools mtd-utils
#

# -e  Exit immediately if a command exits with a non-zero status.
set -e

SCRIPT_NAME=${0##*/}

#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}
readonly SCRIPT_START_DATE=`date +%Y%m%d`
readonly LOOP_MAJOR=7

# default mirror
readonly DEB_RELEASE="bullseye"
readonly DEF_ROOTFS_TARBALL_NAME="rootfs.tar.gz"
readonly DEF_CONSOLE_ROOTFS_TARBALL_NAME="console_rootfs.tar.gz"

# base paths
readonly DEF_BUILDENV="${ABSOLUTE_DIRECTORY}"
readonly DEF_SRC_DIR="${DEF_BUILDENV}/src"
readonly G_ROOTFS_DIR="${DEF_BUILDENV}/rootfs"
readonly G_TMP_DIR="${DEF_BUILDENV}/tmp"
readonly G_TOOLS_PATH="${DEF_BUILDENV}/toolchain"
readonly G_VARISCITE_PATH="${DEF_BUILDENV}/variscite"

#64 bit CROSS_COMPILER config and paths
readonly G_CROSS_COMPILER_64BIT_NAME="gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu"
readonly G_CROSS_COMPILER_ARCHIVE_64BIT="${G_CROSS_COMPILER_64BIT_NAME}.tar.xz"
readonly G_EXT_CROSS_64BIT_COMPILER_LINK="http://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/aarch64-linux-gnu/${G_CROSS_COMPILER_ARCHIVE_64BIT}"
readonly G_CROSS_COMPILER_64BIT_PREFIX="aarch64-linux-gnu-"

#32 bit CROSS_COMPILER config and paths
readonly G_CROSS_COMPILER_32BIT_NAME="gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf"
readonly G_CROSS_COMPILER_ARCHIVE_32BIT="${G_CROSS_COMPILER_32BIT_NAME}.tar.xz"
readonly G_EXT_CROSS_32BIT_COMPILER_LINK="http://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/${G_CROSS_COMPILER_ARCHIVE_32BIT}"
readonly G_CROSS_COMPILER_32BIT_PREFIX="arm-linux-gnueabihf-"

readonly G_CROSS_COMPILER_JOPTION="-j 4"

#### user rootfs packages ####
readonly G_USER_PACKAGES=""

export LC_ALL=C

#### Input params ####
PARAM_OUTPUT_DIR="${DEF_BUILDENV}/output"
PARAM_DEBUG="0"
PARAM_CMD="all"
PARAM_BLOCK_DEVICE="na"

IS_QXP_B0=false

### usage ###
function usage()
{
	echo "Make Debian ${DEB_RELEASE} image and create a bootabled SD card"
	echo
	echo "Usage:"
	echo " MACHINE=<imx8mq-var-dart|imx8mm-var-dart|imx8mp-var-dart|imx8qxp-var-som|imx8qxpb0-var-som|imx8qm-var-som|imx8mn-var-som|imx6ul-var-dart|var-som-mx7> ./${SCRIPT_NAME} options"
	echo
	echo "Options:"
	echo "  -h|--help   -- print this help"
	echo "  -c|--cmd <command>"
	echo "     Supported commands:"
	echo "       deploy      -- prepare environment for all commands"
	echo "       all         -- build or rebuild kernel/bootloader/rootfs"
	echo "       bootloader  -- build or rebuild U-Boot"
	echo "       freertosvariscite - build or rebuild freertos for M4/M7 core"
	echo "       kernel      -- build or rebuild the Linux kernel"
	echo "       kernelheaders -- build or rebuild Linux kernel headers"
	echo "       modules     -- build or rebuild the Linux kernel modules & headers and install them in the rootfs dir"
	echo "       rootfs      -- build or rebuild the Debian root filesystem and create rootfs.tar.gz"
	echo "                       (including: make & install Debian packages, firmware and kernel modules & headers)"
	echo "       rubi        -- generate or regenerate rootfs.ubi.img image from rootfs folder "
	echo "       rtar        -- generate or regenerate rootfs.tar.gz image from the rootfs folder"
	echo "       clean       -- clean all build artifacts (without deleting sources code or resulted images)"
	echo "       sdcard      -- create a bootable SD card"
	echo "  -o|--output -- custom select output directory (default: \"${PARAM_OUTPUT_DIR}\")"
	echo "  -d|--dev    -- specify SD card device (exmple: -d /dev/sde)"
	echo "  --debug     -- enable debug mode for this script"
	echo "Examples of use:"
	echo "  deploy and build:                 ./${SCRIPT_NAME} --cmd deploy && sudo ./${SCRIPT_NAME} --cmd all"
	echo "  make the Linux kernel only:       sudo ./${SCRIPT_NAME} --cmd kernel"
	echo "  make rootfs only:                 sudo ./${SCRIPT_NAME} --cmd rootfs"
	echo "  create SD card:                   sudo ./${SCRIPT_NAME} --cmd sdcard --dev /dev/sdX"
	echo
}

if [ "${MACHINE}" = "imx8qxpb0-var-som" ]; then
	MACHINE="imx8qxp-var-som"
	IS_QXP_B0=true
fi

if [ ! -e ${G_VARISCITE_PATH}/${MACHINE}/${MACHINE}.sh ]; then
	echo "Illegal MACHINE: ${MACHINE}"
	echo
	usage
	exit 1
fi

source ${G_VARISCITE_PATH}/${MACHINE}/${MACHINE}.sh
# freertos-variscite globals
if [ ! -z "${G_FREERTOS_VAR_SRC_DIR}" ]; then
	readonly G_FREERTOS_VAR_BUILD_DIR="${G_FREERTOS_VAR_SRC_DIR}.build"
fi

# Setup cross compiler path, name, kernel dtb path, kernel image type, helper scripts
if [ "${ARCH_CPU}" = "64BIT" ]; then
	G_CROSS_COMPILER_NAME=${G_CROSS_COMPILER_64BIT_NAME}
	G_EXT_CROSS_COMPILER_LINK=${G_EXT_CROSS_64BIT_COMPILER_LINK}
	G_CROSS_COMPILER_ARCHIVE=${G_CROSS_COMPILER_ARCHIVE_64BIT}
	G_CROSS_COMPILER_PREFIX=${G_CROSS_COMPILER_64BIT_PREFIX}
	ARCH_ARGS="arm64"
	BUILD_IMAGE_TYPE="Image.gz"
	KERNEL_BOOT_IMAGE_SRC="arch/arm64/boot/"
	KERNEL_DTB_IMAGE_PATH="arch/arm64/boot/dts/freescale/"
	# Include weston backend rootfs helper
	source ${G_VARISCITE_PATH}/weston_rootfs.sh
	source ${G_VARISCITE_PATH}/linux-headers_debian_src/create_kernel_tree.sh
elif [ "${ARCH_CPU}" = "32BIT" ]; then
	G_CROSS_COMPILER_NAME=${G_CROSS_COMPILER_32BIT_NAME}
	G_EXT_CROSS_COMPILER_LINK=${G_EXT_CROSS_32BIT_COMPILER_LINK}
	G_CROSS_COMPILER_ARCHIVE=${G_CROSS_COMPILER_ARCHIVE_32BIT}
	G_CROSS_COMPILER_PREFIX=${G_CROSS_COMPILER_32BIT_PREFIX}
	ARCH_ARGS="arm"
	# Include x11 backend rootfs helper
	source ${G_VARISCITE_PATH}/console_rootfs.sh
	source ${G_VARISCITE_PATH}/linux-headers_debian_src/create_kernel_tree_arm.sh
	source ${G_VARISCITE_PATH}/x11_rootfs.sh
else
	echo " Error unknown CPU type"
	exit 1
fi

PARAM_DEB_LOCAL_MIRROR="${DEF_DEBIAN_MIRROR}"
G_CROSS_COMPILER_PATH="${G_TOOLS_PATH}/${G_CROSS_COMPILER_NAME}/bin"

## parse input arguments ##
readonly SHORTOPTS="c:o:d:h"
readonly LONGOPTS="cmd:,output:,dev:,help,debug"

ARGS=$(getopt -s bash --options ${SHORTOPTS}  \
  --longoptions ${LONGOPTS} --name ${SCRIPT_NAME} -- "$@" )

eval set -- "$ARGS"

while true; do
	case $1 in
		-c|--cmd ) # script command
			shift
			PARAM_CMD="$1";
			;;
		-o|--output ) # select output dir
			shift
			PARAM_OUTPUT_DIR="$1";
			;;
		-d|--dev ) # SD card block device
			shift
			[ -e ${1} ] && {
				PARAM_BLOCK_DEVICE=${1};
			};
			;;
		--debug ) # enable debug
			PARAM_DEBUG=1;
			;;
		-h|--help ) # get help
			usage
			exit 0;
			;;
		-- )
			shift
			break
			;;
		* )
			shift
			break
			;;
	esac
	shift
done

# enable trace option in debug mode
[ "${PARAM_DEBUG}" = "1" ] && {
	echo "Debug mode enabled!"
	set -x
};

echo "=============== Build summary ==============="
if [ "${IS_QXP_B0}" = true ]; then
	echo "Building Debian ${DEB_RELEASE} for imx8qxpb0-var-som"
else
	echo "Building Debian ${DEB_RELEASE} for ${MACHINE}"
fi
echo "Building Debian ${DEB_RELEASE} for ${MACHINE}"
echo "U-Boot config:      ${G_UBOOT_DEF_CONFIG_MMC}"
echo "Kernel config:      ${G_LINUX_KERNEL_DEF_CONFIG}"
echo "Default kernel dtb: ${DEFAULT_BOOT_DTB}"
echo "kernel dtbs:        ${G_LINUX_DTB}"
echo "============================================="
echo

## declarate dynamic variables ##
readonly G_ROOTFS_TARBALL_PATH="${PARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBALL_NAME}"
readonly G_CONSOLE_ROOTFS_TARBALL_PATH="${PARAM_OUTPUT_DIR}/${DEF_CONSOLE_ROOTFS_TARBALL_NAME}"

###### local functions ######

### printing functions ###

# print error message
# $1 - printing string
function pr_error()
{
	echo "E: $1"
}

# print warning message
# $1 - printing string
function pr_warning()
{
	echo "W: $1"
}

# print info message
# $1 - printing string
function pr_info()
{
	echo "I: $1"
}

# print debug message
# $1 - printing string
function pr_debug() {
	echo "D: $1"
}

### work functions ###

# get sources from git repository
# $1 - git repository
# $2 - branch name
# $3 - output dir
# $4 - commit id
function get_git_src()
{
	# clone src code
	git clone ${1} -b ${2} ${3}
	cd ${3}
	git reset --hard ${4}
	cd -
}

# get remote file
# $1 - remote file
# $2 - local file
# $3 - optional sha256sum
function get_remote_file()
{
	# download remote file
	wget -c ${1} -O ${2}

	# verify sha256sum
	if [ -n "${3}" ]; then
		echo "${3} ${2}" | sha256sum -c
	fi
}

function make_prepare()
{
	# create src dir
	mkdir -p ${DEF_SRC_DIR}

	# create toolchain dir
	mkdir -p ${G_TOOLS_PATH}

	# create rootfs dir
	mkdir -p ${G_ROOTFS_DIR}

	# create out dir
	mkdir -p ${PARAM_OUTPUT_DIR}

	# create tmp dir
	mkdir -p ${G_TMP_DIR}
}


# make tarball from footfs
# $1 -- packet folder
# $2 -- output tarball file (full name)
function make_tarball()
{
	cd $1

	chown root:root .
	pr_info "make tarball from folder ${1}"
	pr_info "Remove old tarball $2"
	rm -f $2

	pr_info "Create $2"

	RETVAL=0
	tar czf $2 . || {
		RETVAL=1
		rm -f $2
	};

	cd -
	return $RETVAL
}

# make Linux kernel image & dtbs
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dtb files
# $4 -- Linux dirname
# $5 -- out path
function make_kernel()
{
	pr_info "make kernel .config"
	make ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${4}/ ${2}

	pr_info "make kernel"
	if [ ! -z "${UIMAGE_LOADADDR}" ]; then
		IMAGE_EXTRA_ARGS="LOADADDR=${UIMAGE_LOADADDR}"
	fi
	make CROSS_COMPILE=${1} ARCH=${ARCH_ARGS} ${G_CROSS_COMPILER_JOPTION} ${IMAGE_EXTRA_ARGS}\
			-C ${4}/ ${BUILD_IMAGE_TYPE}

	pr_info "make ${3}"
	make CROSS_COMPILE=${1} ARCH=${ARCH_ARGS} ${G_CROSS_COMPILER_JOPTION} -C ${4} ${3}

	pr_info "Copy kernel and dtb files to output dir: ${5}"
	cp ${4}/${KERNEL_BOOT_IMAGE_SRC}/${BUILD_IMAGE_TYPE} ${5}/;
	cp ${4}/${KERNEL_DTB_IMAGE_PATH}*.dtb ${5}/;
}

# clean kernel
# $1 -- Linux dir path
function clean_kernel()
{
	pr_info "Clean the Linux kernel"

	make ARCH=${ARCH_ARGS} -C ${1}/ mrproper
}

# make Linux kernel modules
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function make_kernel_modules()
{
	pr_info "make kernel defconfig"
	make ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} ${2}

	pr_info "Compiling kernel modules"
	make ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} modules
}

# make Linux kernel headers package
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function make_kernel_headers_package()
{
	pr_info "make kernel defconfig"
	create_debian_kernel_headers_package ${3} \
		${PARAM_OUTPUT_DIR}/kernel-headers ${G_VARISCITE_PATH}
	pr_info "Installing kernel modules to ${4}"
	make ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} \
		${G_CROSS_COMPILER_JOPTION} -C ${3} \
		INSTALL_MOD_PATH=${4} modules_install
}
# install the Linux kernel modules
# $1 -- cross compiler prefix
# $2 -- Linux defconfig file
# $3 -- Linux dirname
# $4 -- out modules path
function install_kernel_modules()
{
	pr_info "Installing kernel headers to ${4}"
	make ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} \
		INSTALL_HDR_PATH=${4}/usr/local headers_install

	pr_info "Installing kernel modules to ${4}"
	make ARCH=${ARCH_ARGS} CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} \
		INSTALL_MOD_PATH=${4} modules_install
}

compile_fw() {
    DIR_GCC="$1"
    cd ${DIR_GCC}
    ./clean.sh
    ./build_all.sh > /dev/null
}

# build freertos_variscite
# $1 -- output directory
function make_freertos_variscite()
{
    export ARMGCC_DIR=${G_TOOLS_PATH}/${G_CM_GCC_OUT_DIR}

    # Clean previous build
    rm -rf ${G_FREERTOS_VAR_BUILD_DIR}
    cp -r ${G_FREERTOS_VAR_SRC_DIR} ${G_FREERTOS_VAR_BUILD_DIR}

    # Copy and patch hello_world demo to disable_cache demo
    if [[ -f "${G_VARISCITE_PATH}/${MACHINE}/${DISABLE_CACHE_PATCH}" ]]; then
        # Copy hello_world demo
        cp -r ${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/demo_apps/hello_world/ ${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/demo_apps/disable_cache
        # Rename hello_world strings to disable_cache
        grep -rl hello_world ${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/demo_apps/disable_cache | xargs sed -i 's/hello_world/disable_cache/g'
        # Rename hello_world files to disable_cache
        find ${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/demo_apps/disable_cache/ -name '*hello_world*' -exec sh -c 'mv "$1" "$(echo "$1" | sed s/hello_world/disable_cache/)"' _ {} \;
    fi

    for cm_board in ${CM_BOARD}; do
        # Build all demos in CM_DEMOS
        for CM_DEMO in ${CM_DEMOS}; do
            compile_fw "${G_FREERTOS_VAR_BUILD_DIR}/boards/${cm_board}/${CM_DEMO}/armgcc"
        done
    done

    # Build firmware to reset cache
    if [[ -f "${G_VARISCITE_PATH}/${MACHINE}/${DISABLE_CACHE_PATCH}" ]]; then
        # Apply patch to disable cache for machine
        cd $G_FREERTOS_VAR_BUILD_DIR && git apply ${G_VARISCITE_PATH}/${MACHINE}/${DISABLE_CACHE_PATCH}

        # Build the firmware
        for CM_DEMO in ${CM_DEMOS_DISABLE_CACHE}; do
                compile_fw "${G_FREERTOS_VAR_BUILD_DIR}/boards/${CM_BOARD}/${CM_DEMO}/armgcc"
        done
        fi
    cd -
}

# build sc firmware
# $1 -- output directory
function make_imx_sc_fw()
{
    cd ${G_IMX_SC_FW_SRC_DIR}/src/scfw_export_${G_IMX_SC_MACHINE_NAME}
    TOOLS=${G_TOOLS_PATH} make clean-${G_IMX_SC_FW_FAMILY}
    TOOLS=${G_TOOLS_PATH} make ${G_IMX_SC_FW_FAMILY} R=B0 B=var_som V=1
    cp build_${G_IMX_SC_MACHINE_NAME}/scfw_tcm.bin $1
	cd -
}

# generate seco firmware
# $1 -- output directory
function make_imx_seco_fw()
{
	# Cleanup
	rm -rf ${G_IMX_SECO_SRC_DIR}
	mkdir -p ${G_IMX_SECO_SRC_DIR}

	# Fetch
	cd ${G_IMX_SECO_SRC_DIR}
	get_remote_file ${G_IMX_SECO_URL} ${G_IMX_SECO_SRC_DIR}/${G_IMX_SECO_BIN} ${G_IMX_SECO_SHA256SUM}

	# Build
	chmod +x ${G_IMX_SECO_SRC_DIR}/${G_IMX_SECO_BIN}
	${G_IMX_SECO_SRC_DIR}/${G_IMX_SECO_BIN} --auto-accept
	cp ${G_IMX_SECO_IMG} $1
	cd -
}

# make U-Boot
# $1 U-Boot path
# $2 Output dir
function make_uboot()
{
	pr_info "Make U-Boot: ${G_UBOOT_DEF_CONFIG_MMC}"

	# clean work directory
	make ARCH=${ARCH_ARGS} -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION} mrproper

	# make U-Boot mmc defconfig
	make ARCH=${ARCH_ARGS} -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION} ${G_UBOOT_DEF_CONFIG_MMC}

	# make U-Boot
	make -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION}

	# make fw_printenv
	make envtools -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION}

	cp ${1}/tools/env/fw_printenv ${2}

	if [ "${MACHINE}" = "imx8qxp-var-som" ]; then
		if [ "${IS_QXP_B0}" = true ]; then
			#Compile B0 bootloader

			# scfw
			make_imx_sc_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"
			# imx-atf
			cd ${DEF_SRC_DIR}/imx-atf
			LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
					PLAT=imx8qx bl31
			cd -
			cp ${DEF_SRC_DIR}/imx-atf/build/imx8qx/release/bl31.bin \
				src/imx-mkimage/iMX8QX/bl31.bin
			# imx-seco
			make_imx_seco_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"

			cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cd ${DEF_SRC_DIR}/imx-mkimage
			make REV=B0 SOC=iMX8QX flash_spl
			cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/flash.bin \
				${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
			cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		else
			#Compile C0 bootloader

			# scfw
			make_imx_sc_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"
			# imx-atf
			cd ${DEF_SRC_DIR}/imx-atf
			LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
					PLAT=imx8qx bl31
			cd -
			cp ${DEF_SRC_DIR}/imx-atf/build/imx8qx/release/bl31.bin \
				src/imx-mkimage/iMX8QX/bl31.bin
			# imx-seco
			make_imx_seco_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"

			cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cd ${DEF_SRC_DIR}/imx-mkimage
			make REV=C0 SOC=iMX8QX flash_spl
			cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/flash.bin \
				${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
			cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		fi
	elif [ "${MACHINE}" = "imx8mq-var-dart" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8mq bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8mq/release/bl31.bin \
			${DEF_SRC_DIR}/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/signed_hdmi_imx8m.bin \
			src/imx-mkimage/iMX8M/signed_hdmi_imx8m.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/signed_dp_imx8m.bin \
			src/imx-mkimage/iMX8M/signed_dp_imx8m.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_imem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_imem.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_dmem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_dmem.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_imem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_imem.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_dmem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_dmem.bin
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MQ dtbs=${UBOOT_DTB} flash_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		make SOC=iMX8M clean
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		make SOC=iMX8M dtbs=${UBOOT_DTB} flash_dp_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC_DP}
		cp ${G_UBOOT_NAME_FOR_EMMC_DP} ${2}/${G_UBOOT_NAME_FOR_EMMC_DP}
	elif [ "${MACHINE}" = "imx8mm-var-dart" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8mm bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8mm/release/bl31.bin \
			${DEF_SRC_DIR}/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_1d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_2d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_1d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_2d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_dmem.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_imem.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_dmem.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_imem.bin \
			src/imx-mkimage/iMX8M/
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		if [ ! -z "${UBOOT_DTB_EXTRA}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		if [ ! -z "${UBOOT_DTB_EXTRA2}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA2} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MM dtbs=${UBOOT_DTB} flash_lpddr4_ddr4_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8mp-var-dart" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/bl31-imx8mp.bin \
			src/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_dmem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_dmem_202006.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_imem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_imem_202006.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_dmem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_dmem_202006.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_imem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_imem_202006.bin
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		if [ ! -z "${UBOOT_DTB_EXTRA}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		if [ ! -z "${UBOOT_DTB_EXTRA2}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA2} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MP flash_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8mn-var-som" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8mn bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8mn/release/bl31.bin \
			src/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_1d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_imem_1d_201810.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_1d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_dmem_1d_201810.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_2d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_imem_2d_201810.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_2d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_dmem_2d_201810.bin
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		if [ ! -z "${UBOOT_DTB_EXTRA}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		if [ ! -z "${UBOOT_DTB_EXTRA2}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA2} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MN dtbs="${UBOOT_DTB}" ${IMXBOOT_TARGETS}
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8qm-var-som" ]; then
		# scfw
		make_imx_sc_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QM/"
		# imx-atf
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8qm bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8qm/release/bl31.bin \
			src/imx-mkimage/iMX8QM/bl31.bin
		# imx-seco
		make_imx_seco_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QM/"

		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8QM flash_spl
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		cp ${1}/tools/env/fw_printenv ${2}
	elif [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	     [ "${MACHINE}" = "var-som-mx7" ]; then
		mv ${2}/fw_printenv ${2}/fw_printenv-mmc
		#copy MMC SPL, u-boot, SPL binaries
		cp ${1}/SPL ${2}/${G_SPL_NAME_FOR_EMMC}
		cp ${1}/u-boot.img  ${2}/${G_UBOOT_NAME_FOR_EMMC}

		# make nand make NAND U-Boot
		pr_info "Make SPL & u-boot: ${G_UBOOT_DEF_CONFIG_NAND}"
		# clean work directory
		make ARCH=arm -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			${G_CROSS_COMPILER_JOPTION} mrproper

		# make uboot config for nand
		make ARCH=arm -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			 ${G_CROSS_COMPILER_JOPTION} ${G_UBOOT_DEF_CONFIG_NAND}

		# make uboot
		make ARCH=arm -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			 ${G_CROSS_COMPILER_JOPTION}

		# make fw_printenv
		make envtools -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			${G_CROSS_COMPILER_JOPTION}

		# copy NAND SPL, u-boot binaries
		cp ${1}/SPL ${2}/${G_SPL_NAME_FOR_NAND}
		cp ${1}/u-boot.img ${2}/${G_UBOOT_NAME_FOR_NAND}
		cp ${1}/tools/env/fw_printenv ${2}/fw_printenv-nand
	fi
}

# make *.ubi image from rootfs
# params:
#  $1 -- path to rootfs dir
#  $2 -- tmp dir
#  $3 -- output dir
#  $4 -- ubi file name
function make_ubi() {
	readonly local _rootfs=${1};
	readonly local _tmp=${2};
	readonly local _output=${3};
	readonly local _ubi_file_name=${4};

	readonly local UBI_CFG="${_tmp}/ubi.cfg"
	readonly local UBIFS_IMG="${_tmp}/rootfs.ubifs"
	readonly local UBI_IMG="${_output}/${_ubi_file_name}"
	readonly local UBIFS_ROOTFS_DIR="${DEF_BUILDENV}/rootfs_ubi_tmp"

	rm -rf ${UBIFS_ROOTFS_DIR}
	cp -a ${_rootfs} ${UBIFS_ROOTFS_DIR}

## ubifs rootfs clenup command
echo "#!/bin/bash
apt-get clean
rm -rf /tmp/*
rm -f cleanup
" > ${UBIFS_ROOTFS_DIR}/cleanup

	# clean all packages
	pr_info "ubifs rootfs: clean"
	chmod +x ${UBIFS_ROOTFS_DIR}/cleanup
	chroot ${UBIFS_ROOTFS_DIR} /cleanup
	rm ${UBIFS_ROOTFS_DIR}/usr/bin/qemu-arm-static

	prepare_ubifs_rootfs ${UBIFS_ROOTFS_DIR}
	# gnerate ubifs file
	pr_info "Generate ubi config file: ${UBI_CFG}"
cat > ${UBI_CFG} << EOF
[ubifs]
mode=ubi
image=${UBIFS_IMG}
vol_id=0
vol_type=dynamic
vol_name=rootfs
vol_flags=autoresize
EOF
	# delete previus images
	rm -f ${UBI_IMG}
	rm -f ${UBIFS_IMG}

	pr_info "Creating $UBIFS_IMG image"
	mkfs.ubifs -x zlib -m 2048  -e 124KiB -c 3965 -r ${UBIFS_ROOTFS_DIR} $UBIFS_IMG

	pr_info "Creating $UBI_IMG image"
	ubinize -o ${UBI_IMG} -m 2048 -p 128KiB -s 2048 -O 2048 ${UBI_CFG}

	# delete unused file
	rm -f ${UBIFS_IMG}
	rm -f ${UBI_CFG}
	return 0;
}

# clean U-Boot
# $1 -- U-Boot dir path
function clean_uboot()
{
	pr_info "Clean U-Boot"
	make ARCH=${ARCH_ARGS} -C ${1}/ mrproper
}

# verify the SD card
# $1 -- block device
function check_sdcard()
{
	# Check that parameter is a valid block device
	if [ ! -b "$1" ]; then
		pr_error "$1 is not a valid block device, exiting"
		return 1
	fi

	local dev=$(basename $1)

	# Check that /sys/block/$dev exists
	if [ ! -d /sys/block/$dev ]; then
		pr_error "Directory /sys/block/${dev} missing, exiting"
		return 1
	fi

	# Get device parameters
	local removable=$(cat /sys/block/${dev}/removable)
	local block_size=$(cat /sys/class/block/${dev}/queue/physical_block_size)
	local size_bytes=$((${block_size}*$(cat /sys/class/block/${dev}/size)))
	local size_gib=$(bc <<< "scale=1; ${size_bytes}/(1024*1024*1024)")

	# Non removable SD card readers require additional check
	if [ "${removable}" != "1" ]; then
		local drive=$(udisksctl info -b /dev/${dev}|grep "Drive:"|cut -d"'" -f 2)
		local mediaremovable=$(gdbus call --system --dest org.freedesktop.UDisks2 --object-path ${drive} \
			--method org.freedesktop.DBus.Properties.Get org.freedesktop.UDisks2.Drive MediaRemovable)
		if [[ "${mediaremovable}" = *"true"* ]]; then
			removable=1
		fi
	fi

	# Check that device is either removable or loop
	if [ "$removable" != "1" -a $(stat -c '%t' /dev/$dev) != ${LOOP_MAJOR} ]; then
		pr_error "$1 is not a removable device, exiting"
		return 1
	fi

	# Check that device is attached
	if [ ${size_bytes} -eq 0 ]; then
		pr_error "$1 is not attached, exiting"
		return 1
	fi

	pr_info "Device: ${LPARAM_BLOCK_DEVICE}, ${size_gib}GiB"
	echo "============================================="
	read -p "Press Enter to continue"

	return 0
}

# make imx sdma firmware
# $1 -- linux-firmware directory
# $2 -- rootfs output dir
function make_imx_sdma_fw() {
	pr_info "Install imx sdma firmware"
	install -d ${2}/lib/firmware/imx/sdma
	if [ "${MACHINE}" = "imx6ul-var-dart" ]; then
		install -m 0644 ${1}/imx/sdma/sdma-imx6q.bin \
		${2}/lib/firmware/imx/sdma
	elif  [ "${MACHINE}" = "var-som-mx7" ]; then
		install -m 0644 ${1}/imx/sdma/sdma-imx7d.bin \
		${2}/lib/firmware/imx/sdma
	fi
	install -m 0644 ${1}/LICENSE.sdma_firmware ${2}/lib/firmware/
}

# make firmware for wl bcm module
# $1 -- bcm git directory
# $2 -- rootfs output dir
function make_bcm_fw()
{
	pr_info "Make and install bcm configs and firmware"

	install -d ${2}/lib/firmware/bcm
	install -d ${2}/lib/firmware/brcm
	install -m 0644 ${1}/brcm/* ${2}/lib/firmware/brcm/
	if [ "${MACHINE}" != "imx8mn-var-som" ] &&
	   [ "${MACHINE}" != "imx8mq-var-dart" ] &&
	   [ "${MACHINE}" != "imx8mp-var-dart" ]; then
		install -m 0644 ${1}/brcm/*.hcd ${2}/lib/firmware/bcm/
		install -m 0644 ${1}/LICENSE ${2}/lib/firmware/bcm/
	fi
	install -m 0644 ${1}/LICENSE ${2}/lib/firmware/brcm/
}

################ commands ################
kernel_is_5_10()
{
        grep -q 'PATCHLEVEL = 10' ${G_LINUX_KERNEL_SRC_DIR}/Makefile
}

function cmd_make_deploy()
{
	# get linaro toolchain
	(( `ls ${G_CROSS_COMPILER_PATH} 2>/dev/null | wc -l` == 0 )) && {
		pr_info "Get and unpack cross compiler";
		get_remote_file ${G_EXT_CROSS_COMPILER_LINK} \
			${DEF_SRC_DIR}/${G_CROSS_COMPILER_ARCHIVE}
		tar -xJf ${DEF_SRC_DIR}/${G_CROSS_COMPILER_ARCHIVE} \
			-C ${G_TOOLS_PATH}/
	};

	# get scfw dependencies
	if [ -n ${G_IMX_SC_FW_REV} ]; then
		# get scfw toolchain
		readonly G_SCFW_CROSS_COMPILER_PATH="${G_TOOLS_PATH}/${G_IMX_SC_FW_TOOLCHAIN_NAME}"
		(( `ls ${G_SCFW_CROSS_COMPILER_PATH} 2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get and unpack scfw cross compiler";
			get_remote_file ${G_IMX_SC_FW_TOOLCHAIN_LINK} \
				${DEF_SRC_DIR}/${G_IMX_SC_FW_TOOLCHAIN_ARCHIVE} \
				${G_IMX_SC_FW_TOOLCHAIN_SHA256SUM}
			tar -xf ${DEF_SRC_DIR}/${G_IMX_SC_FW_TOOLCHAIN_ARCHIVE} \
				-C ${G_TOOLS_PATH}/
		};

		# get scfw src
		(( `ls ${G_IMX_SC_FW_SRC_DIR} 2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get scfw repository";
			get_git_src ${G_IMX_SC_FW_GIT} ${G_IMX_SC_FW_BRANCH} \
				${G_IMX_SC_FW_SRC_DIR} ${G_IMX_SC_FW_REV}
		};

	fi

	# get U-Boot repository
	(( `ls ${G_UBOOT_SRC_DIR} 2>/dev/null | wc -l` == 0 )) && {
		pr_info "Get U-Boot repository";
		get_git_src ${G_UBOOT_GIT} ${G_UBOOT_BRANCH} \
			${G_UBOOT_SRC_DIR} ${G_UBOOT_REV}
	};

	# get kernel repository
	(( `ls ${G_LINUX_KERNEL_SRC_DIR} 2>/dev/null | wc -l` == 0 )) && {
		pr_info "Get kernel repository";
		get_git_src ${G_LINUX_KERNEL_GIT} ${G_LINUX_KERNEL_BRANCH} \
			${G_LINUX_KERNEL_SRC_DIR} ${G_LINUX_KERNEL_REV}
		if kernel_is_5_10; then
			patch -p1 < ${G_VARISCITE_PATH}/0001-linux-kernel-headers-Fix-missing-scripts-module-comm.patch
		fi
	};
	if [ ! -z "${G_BCM_FW_GIT}" ]; then
		# get bcm firmware repository
		(( `ls ${G_BCM_FW_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get bcmhd firmware repository";
			get_git_src ${G_BCM_FW_GIT} ${G_BCM_FW_GIT_BRANCH} \
			${G_BCM_FW_SRC_DIR} ${G_BCM_FW_GIT_REV}
		};
	fi
	if [ ! -z "${G_IMXBOOT_GIT}" ]; then
		# get IMXBoot Source repository
		(( `ls ${G_IMXBOOT_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get imx-boot";
			get_git_src ${G_IMXBOOT_GIT} \
			${G_IMXBOOT_BRACH} ${G_IMXBOOT_SRC_DIR} ${G_IMXBOOT_REV}
		# patch IMX boot
		if [ "${MACHINE}" = "imx8mn-var-som" ]; then
			cd ${G_IMXBOOT_SRC_DIR}
			patch -p1 < ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/imx-boot/imx-mkimage-imx8m-soc.mak-add-var-som-imx8m-nano-support.patch
			cd -
		fi
		# patch IMX boot for imx8mm-var-dart
		if [ "${MACHINE}" = "imx8mm-var-dart" ]; then
			cd ${G_IMXBOOT_SRC_DIR}
			patch -p1 < ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/imx-boot/imx-mkimage-imx8m-soc.mak-add-variscite-imx8mm-suppo.patch
			cd -
		fi
		# patch IMX boot for imx8mq-var-dart
		if [ "${MACHINE}" = "imx8mq-var-dart" ]; then
			cd ${G_IMXBOOT_SRC_DIR}
			patch -p1 < ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/imx-boot/imx-mkimage-imx8m-soc.mak-add-dart-mx8m-support.patch
			cd -
		fi
		# patch IMX boot for imx8mp-var-dart
		if [ "${MACHINE}" = "imx8mp-var-dart" ]; then
			cd ${G_IMXBOOT_SRC_DIR}
			patch -p1 < ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/imx-boot/imx-mkimage-imx8m-soc.mak-add-dart-imx8mp-support.patch
			cd -
		fi
		};
	fi

	# get imx-atf repository
	if [ ! -z "${G_IMX_ATF_GIT}" ]; then
		(( `ls ${G_IMX_ATF_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get IMX ATF repository";
			get_git_src ${G_IMX_ATF_GIT} ${G_IMX_ATF_BRANCH} \
			${G_IMX_ATF_SRC_DIR} ${G_IMX_ATF_REV}
		};
	fi

	# SDMA firmware
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# get linux-firmware source repository
		(( `ls ${G_IMX_SDMA_FW_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get Linux-Firmware";
			get_git_src ${G_IMX_SDMA_FW_GIT} \
				${G_IMX_SDMA_FW_GIT_BRANCH} ${G_IMX_SDMA_FW_SRC_DIR} \
				${G_IMX_SDMA_FW_GIT_REV}
		};
	fi

	# get freertos-variscite dependencies
	if [ ! -z "${G_FREERTOS_VAR_SRC_DIR}" ]; then
		# get Cortex-M toolchain
		readonly G_CM_GCC_PATH="${G_TOOLS_PATH}/${G_CM_GCC_NAME}"
		(( `ls ${G_CM_GCC_PATH} 2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get and unpack Cortex-M cross compiler";
			get_remote_file ${G_CM_GCC_LINK} \
				${DEF_SRC_DIR}/${G_CM_GCC_ARCHIVE} \
				${G_CM_GCC_SHA256SUM}
			mkdir -p ${G_TOOLS_PATH}/${G_CM_GCC_OUT_DIR}
			tar -xf ${DEF_SRC_DIR}/${G_CM_GCC_ARCHIVE} --strip-components=1 \
				-C ${G_TOOLS_PATH}/${G_CM_GCC_OUT_DIR}/
		};

		# get freertos-variscite repository
		(( `ls ${G_FREERTOS_VAR_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get freertos-variscite source repository";
			get_git_src ${G_FREERTOS_VAR_SRC_GIT} \
				${G_FREERTOS_VAR_SRC_BRANCH} ${G_FREERTOS_VAR_SRC_DIR} \
				${G_FREERTOS_VAR_SRC_REV}
		};
	fi

	return 0
}

function cmd_make_rootfs()
{
	make_prepare;

	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# make debian console rootfs
		cd ${G_ROOTFS_DIR}
		make_debian_console_rootfs ${G_ROOTFS_DIR}
		# make imx sdma firmware
		make_imx_sdma_fw ${G_IMX_SDMA_FW_SRC_DIR} ${G_ROOTFS_DIR}
		cd -
	else
		# make debian weston backend rootfs for imx8 family
		cd ${G_ROOTFS_DIR}
		make_debian_weston_rootfs ${G_ROOTFS_DIR}
		cd -
	fi

	# make bcm firmwares
	if [ ! -z "${G_BCM_FW_GIT}" ]; then
		make_bcm_fw ${G_BCM_FW_SRC_DIR} ${G_ROOTFS_DIR}
	fi

	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# pack to ubi
		make_ubi ${G_ROOTFS_DIR} ${G_TMP_DIR} ${PARAM_OUTPUT_DIR} \
				${G_UBI_FILE_NAME}
		# pack console rootfs
		make_tarball ${UBIFS_ROOTFS_DIR} ${G_CONSOLE_ROOTFS_TARBALL_PATH}
		rm -rf ${UBIFS_ROOTFS_DIR}
	fi

	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# make debian x11 backend rootfs
		cd ${G_ROOTFS_DIR}
		make_debian_x11_rootfs ${G_ROOTFS_DIR}
		cd -
	fi

	# pack full rootfs
	make_tarball ${G_ROOTFS_DIR} ${G_ROOTFS_TARBALL_PATH}
}

function cmd_make_freertos_variscite()
{
	if [ ! -z "${G_FREERTOS_VAR_SRC_DIR}" ]; then
		make_freertos_variscite ${G_FREERTOS_VAR_SRC_DIR} ${PARAM_OUTPUT_DIR}
	fi
}

function cmd_make_uboot()
{
	make_uboot ${G_UBOOT_SRC_DIR} ${PARAM_OUTPUT_DIR}
}

function cmd_make_kernel()
{
	make_kernel ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_LINUX_KERNEL_DEF_CONFIG} "${G_LINUX_DTB}" \
		${G_LINUX_KERNEL_SRC_DIR} ${PARAM_OUTPUT_DIR}
}

function cmd_make_kernel_header_deb()
{
	make_kernel_headers_package \
		${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_LINUX_KERNEL_DEF_CONFIG} ${G_LINUX_KERNEL_SRC_DIR} \
		${PARAM_OUTPUT_DIR}/kernel-headers/kernel

}

function cmd_make_kmodules()
{
	rm -rf ${G_ROOTFS_DIR}/lib/modules/*

	make_kernel_modules ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_LINUX_KERNEL_DEF_CONFIG} ${G_LINUX_KERNEL_SRC_DIR} \
		${G_ROOTFS_DIR}

	install_kernel_modules ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_LINUX_KERNEL_DEF_CONFIG} \
		${G_LINUX_KERNEL_SRC_DIR} ${G_ROOTFS_DIR}
}

function cmd_make_rfs_ubi() {
	make_ubi ${G_ROOTFS_DIR} ${G_TMP_DIR} ${PARAM_OUTPUT_DIR} \
				${G_UBI_FILE_NAME}
}

function cmd_make_rfs_tar()
{
	# pack rootfs
	make_tarball ${G_ROOTFS_DIR} ${G_ROOTFS_TARBALL_PATH}
}

function cmd_make_sdcard()
{
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		make_x11_sdcard ${PARAM_BLOCK_DEVICE} ${PARAM_OUTPUT_DIR}
	else
		make_weston_sdcard ${PARAM_BLOCK_DEVICE} ${PARAM_OUTPUT_DIR}
	fi
}

function cmd_make_bcmfw()
{
	make_bcm_fw ${G_BCM_FW_SRC_DIR} ${G_ROOTFS_DIR}
}

function cmd_make_firmware() {
	make_imx_sdma_fw ${G_IMX_SDMA_FW_SRC_DIR} ${G_ROOTFS_DIR}
}

function cmd_make_clean()
{
	# clean kernel, dtb, modules
	clean_kernel ${G_LINUX_KERNEL_SRC_DIR}

	# clean U-Boot
	clean_uboot ${G_UBOOT_SRC_DIR}

	# delete tmp dirs and etc
	pr_info "Delete tmp dir ${G_TMP_DIR}"
	rm -rf ${G_TMP_DIR}

	pr_info "Delete rootfs dir ${G_ROOTFS_DIR}"
	rm -rf ${G_ROOTFS_DIR}
}

################ main function ################

# test for root access support
[ "$PARAM_CMD" != "deploy" ] && [ "$PARAM_CMD" != "bootloader" ] &&
[ "$PARAM_CMD" != "kernel" ] && [ "$PARAM_CMD" != "modules" ] &&
[ ${EUID} -ne 0 ] && {
	pr_error "this command must be run as root (or sudo/su)"
	exit 1;
};

pr_info "Command: \"$PARAM_CMD\" start..."

make_prepare

case $PARAM_CMD in
	deploy )
		cmd_make_deploy
		;;
	rootfs )
		cmd_make_rootfs
		;;
	bootloader )
		cmd_make_uboot
		;;
	kernel )
		cmd_make_kernel
		;;
	modules )
		cmd_make_kmodules
		;;
	kernelheaders )
		cmd_make_kernel_header_deb
		;;
	bcmfw )
		cmd_make_bcmfw
		;;
	firmware )
		cmd_make_firmware
		;;

	sdcard )
		cmd_make_sdcard
		;;
	rubi )
		cmd_make_rfs_ubi
		;;
	rtar )
		cmd_make_rfs_tar
		;;
	freertosvariscite )
		cmd_make_freertos_variscite
		;;
	all )
		cmd_make_uboot  &&
		cmd_make_kernel &&
		cmd_make_kmodules &&
		cmd_make_kernel_header_deb &&
		cmd_make_freertos_variscite &&
		cmd_make_rootfs
		;;
	clean )
		cmd_make_clean
		;;
	* )
		pr_error "Invalid input command: \"${PARAM_CMD}\"";
		;;
esac

echo
pr_info "Command: \"$PARAM_CMD\" end."
echo
