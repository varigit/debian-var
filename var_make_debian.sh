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
readonly DEF_DEBIAN_MIRROR="https://deb.debian.org/debian/"
readonly DEB_RELEASE="bullseye"
readonly DEF_ROOTFS_TARBALL_NAME="rootfs.tar.gz"

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
PARAM_DEB_LOCAL_MIRROR="${DEF_DEBIAN_MIRROR}"
PARAM_OUTPUT_DIR="${DEF_BUILDENV}/output"
PARAM_DEBUG="0"
PARAM_CMD="all"
PARAM_BLOCK_DEVICE="na"

### usage ###
function usage()
{
	echo "Make Debian ${DEB_RELEASE} image and create a bootabled SD card"
	echo
	echo "Usage:"
	echo " MACHINE=<imx8mq-var-dart|imx8mm-var-dart|imx8qxp-var-som|imx8qm-var-som|imx6ul-var-dart|var-som-mx7> ./${SCRIPT_NAME} options"
	echo
	echo "Options:"
	echo "  -h|--help   -- print this help"
	echo "  -c|--cmd <command>"
	echo "     Supported commands:"
	echo "       deploy      -- prepare environment for all commands"
	echo "       all         -- build or rebuild kernel/bootloader/rootfs"
	echo "       bootloader  -- build or rebuild U-Boot"
	echo "       kernel      -- build or rebuild the Linux kernel"
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

if [ ! -e ${G_VARISCITE_PATH}/${MACHINE}/${MACHINE}.sh ]; then
	echo "Illegal MACHINE: ${MACHINE}"
	echo
	usage
	exit 1
fi

source ${G_VARISCITE_PATH}/${MACHINE}/${MACHINE}.sh

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
elif [ "${ARCH_CPU}" = "32BIT" ]; then
	G_CROSS_COMPILER_NAME=${G_CROSS_COMPILER_32BIT_NAME}
	G_EXT_CROSS_COMPILER_LINK=${G_EXT_CROSS_32BIT_COMPILER_LINK}
	G_CROSS_COMPILER_ARCHIVE=${G_CROSS_COMPILER_ARCHIVE_32BIT}
	G_CROSS_COMPILER_PREFIX=${G_CROSS_COMPILER_32BIT_PREFIX}
	ARCH_ARGS="arm"
	# Include x11 backend rootfs helper
	source ${G_VARISCITE_PATH}/x11_rootfs.sh
else
	echo " Error unknown CPU type"
	exit 1
fi

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
echo "Building Debian ${DEB_RELEASE} for ${MACHINE}"
echo "U-Boot config:      ${G_UBOOT_DEF_CONFIG_MMC}"
echo "Kernel config:      ${G_LINUX_KERNEL_DEF_CONFIG}"
echo "Default kernel dtb: ${DEFAULT_BOOT_DTB}"
echo "kernel dtbs:        ${G_LINUX_DTB}"
echo "============================================="
echo

## declarate dynamic variables ##
readonly G_ROOTFS_TARBALL_PATH="${PARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBALL_NAME}"

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
function get_remote_file()
{
	# download remote file
	wget -c ${1} -O ${2}
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
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/scfw_tcm.bin \
			src/imx-mkimage/iMX8QX/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/bl31-imx8qx.bin \
			src/imx-mkimage/iMX8QX/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/mx8qx-ahab-container.img \
			src/imx-mkimage/iMX8QX/
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8QX flash_spl
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
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
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/soc.mak \
			src/imx-mkimage/iMX8M/
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8M flash_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		make SOC=iMX8M clean
		make SOC=iMX8M flash_dp_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC_DP}
		cp ${G_UBOOT_NAME_FOR_EMMC_DP} ${2}/${G_UBOOT_NAME_FOR_EMMC_DP}
	elif [ "${MACHINE}" = "imx8mm-var-dart" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/bl31-imx8mm.bin \
			src/imx-mkimage/iMX8M/bl31.bin
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
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/soc.mak \
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
		make SOC=iMX8MM flash_lpddr4_ddr4_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8qm-var-som" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/scfw_tcm.bin \
			src/imx-mkimage/iMX8QM/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/bl31-imx8qm.bin \
			src/imx-mkimage/iMX8QM/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/mx8qm-ahab-container.img \
			src/imx-mkimage/iMX8QM/
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8QM flash
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
	prepare_x11_ubifs_rootfs ${UBIFS_ROOTFS_DIR}
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
	rm -rf ${UBIFS_ROOTFS_DIR}

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
	install -m 0644 ${1}/*.hcd ${2}/lib/firmware/bcm/
	install -m 0644 ${1}/LICENSE ${2}/lib/firmware/bcm/
	install -m 0644 ${1}/LICENSE ${2}/lib/firmware/brcm/
}

################ commands ################

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
		};
	fi

	# get imx-atf repository
	if [ ! -z "${G_IMX_ATF_GIT}" ]; then
		(( `ls ${G_IMX_ATF_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get IMX ATF repository";
			get_git_src ${G_IMX_ATF_GIT} ${G_IMX_ATF_BRANCH} \
			${G_IMX_ATF_SRC_DIR} ${G_IMX_ATF_REV}
		# patch imx-atf
		if [ "${MACHINE}" = "imx8mq-var-dart" ]; then
			cd ${G_IMX_ATF_SRC_DIR}
			patch -p1 < ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/imx-atf/imx8m-atf-ddr-timing.patch
			patch -p1 < ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/imx-atf/imx8m-atf-fix-derate-enable.patch
			cd -
		fi
		};
	fi

	# SDMA firmware
	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# get linux-frimwrae source repository
		(( `ls ${G_IMX_SDMA_FW_SRC_DIR}  2>/dev/null | wc -l` == 0 )) && {
			pr_info "Get Linux-Firmware";
			get_git_src ${G_IMX_SDMA_FW_GIT} \
				${G_IMX_SDMA_FW_GIT_BRANCH} ${G_IMX_SDMA_FW_SRC_DIR} \
				${G_IMX_SDMA_FW_GIT_REV}
		};
	fi
	return 0
}

function cmd_make_rootfs()
{
	make_prepare;

	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# make debian x11 backend rootfs
		cd ${G_ROOTFS_DIR}
		make_debian_x11_rootfs ${G_ROOTFS_DIR}
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

	# pack rootfs
	make_tarball ${G_ROOTFS_DIR} ${G_ROOTFS_TARBALL_PATH}

	if [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	   [ "${MACHINE}" = "var-som-mx7" ]; then
		# pack to ubi
		make_ubi ${G_ROOTFS_DIR} ${G_TMP_DIR} ${PARAM_OUTPUT_DIR} \
				${G_UBI_FILE_NAME}
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
	all )
		cmd_make_uboot  &&
		cmd_make_kernel &&
		cmd_make_kmodules &&
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
