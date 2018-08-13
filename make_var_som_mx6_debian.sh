#!/bin/bash
# It is designed to build Debian linux for Variscite MX6 modules
# script tested in OS debian (jessie)
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
readonly SCRIPT_VERSION="0.2"


#### Exports Variables ####
#### global variables ####
readonly ABSOLUTE_FILENAME=`readlink -e "$0"`
readonly ABSOLUTE_DIRECTORY=`dirname ${ABSOLUTE_FILENAME}`
readonly SCRIPT_POINT=${ABSOLUTE_DIRECTORY}
readonly SCRIPT_START_DATE=`date +%Y%m%d`
readonly LOOP_MAJOR=7
readonly DEF_ROOTFS_TARBAR_NAME="rootfs.tar.bz2"

## base paths 
readonly DEF_BUILDENV="${ABSOLUTE_DIRECTORY}"
readonly DEF_SRC_DIR="${DEF_BUILDENV}/src"
readonly G_ROOTFS_DIR="${DEF_BUILDENV}/rootfs"
readonly G_TMP_DIR="${DEF_BUILDENV}/tmp"
readonly G_TOOLS_PATH="${DEF_BUILDENV}/toolchain"
readonly G_VARISCITE_PATH="${DEF_BUILDENV}/variscite"


## LINUX kernel: git, config, paths and etc
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-2.6-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx-rel_imx_4.1.15_2.0.0_ga-var02"
readonly G_LINUX_KERNEL_DEF_CONFIG="imx_v7_var_defconfig"
readonly G_LINUX_DTB="imx6dl-var-som-cap.dtb imx6dl-var-som-res.dtb imx6dl-var-som-solo-cap.dtb imx6dl-var-som-solo-res.dtb imx6dl-var-som-solo-vsc.dtb imx6dl-var-som-vsc.dtb imx6q-var-dart.dtb imx6q-var-som-cap.dtb imx6q-var-som-res.dtb imx6q-var-som-vsc.dtb"

## uboot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2015.04_4.1.15_1.1.0_ga_var03"
readonly G_UBOOT_DEF_CONFIG_MMC="mx6var_som_sd_config"
readonly G_UBOOT_NAME_FOR_EMMC="u-boot.img.mmc"
readonly G_SPL_NAME_FOR_EMMC="SPL.mmc"
readonly G_UBOOT_DEF_CONFIG_NAND="mx6var_som_nand_config"
readonly G_UBOOT_NAME_FOR_NAND="u-boot.img.nand"
readonly G_SPL_NAME_FOR_NAND="SPL.nand"

## wilink8 ##
readonly G_WILINK8_GIT="git://git.ti.com/wilink8-wlan"
readonly G_WILINK8_BACKPORTS_SRC_DIR="${DEF_SRC_DIR}/wilink8/backports"
readonly G_WILINK8_BACKPORTS_GIT="${G_WILINK8_GIT}/backports.git"
readonly G_WILINK8_BACKPORTS_GIT_BRANCH="upstream_44"
readonly G_WILINK8_BACKPORTS_GIT_SRCREV="d4777ef8ac84a855b7e385b01a6690874460f536"
readonly G_WILINK8_WL18XX_SRC_DIR="${DEF_SRC_DIR}/wilink8/wl18xx"
readonly G_WILINK8_WL18XX_GIT="${G_WILINK8_GIT}/wl18xx.git"
readonly G_WILINK8_WL18XX_GIT_BRANCH="upstream_44"
readonly G_WILINK8_WL18XX_GIT_SRCREV="5c94cc59baf694fb0aa5c5af6c6ae2a9b2d0e8fb"
readonly G_WILINK8_COMPAT_WIRELESS_SRC_DIR="${DEF_SRC_DIR}/wilink8/compat-wireless"
readonly G_WILINK8_UTILS_SRC_DIR="${DEF_SRC_DIR}/wilink8/utils"
readonly G_WILINK8_UTILS_GIT="${G_WILINK8_GIT}/18xx-ti-utils.git"
readonly G_WILINK8_UTILS_GIT_BRANCH="master"
readonly G_WILINK8_UTILS_GIT_SRCREV="5040274cae5e88303e8a895c2707628fa72d58e8"
readonly G_WILINK8_FW_WIFI_SRC_DIR="${DEF_SRC_DIR}/wilink8/fw_wifi"
readonly G_WILINK8_FW_WIFI_GIT="${G_WILINK8_GIT}/wl18xx_fw.git"
readonly G_WILINK8_FW_WIFI_GIT_BRANCH="master"
readonly G_WILINK8_FW_WIFI_GIT_SRCREV="f659be25473e4bde8dc790bff703ecacde6e21da"
readonly G_WILINK8_FW_BT_SRC_DIR="${DEF_SRC_DIR}/wilink8/fw_bt"
readonly G_WILINK8_FW_BT_GIT="git://git.ti.com/ti-bt/service-packs.git"
readonly G_WILINK8_FW_BT_GIT_BRANCH="master"
readonly G_WILINK8_FW_BT_GIT_SRCREV="0ee619b598d023fffc77679f099bc2a4815510e4"

## imx accelerations ##
# much more standard replacement for Freescale's imx-gst1.0-plugin
readonly G_IMX_GPU_DRV_SRC_DIR="${DEF_SRC_DIR}/imx/kernel-module-imx-gpu-viv"
readonly G_IMX_GPU_DRV_GIT="git://github.com/Freescale/kernel-module-imx-gpu-viv.git"
readonly G_IMX_GPU_DRV_GIT_BRANCH="master"
readonly G_IMX_GPU_DRV_GIT_SRCREV="a05d9b23b9902f6ce87d23772de2fdb2ecfb37a7"
# Freescale mirror
readonly G_FSL_MIRROR="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO"
# apt-get install gstreamer1.0-x gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa
# sh firmware-imx-5.4.bin --auto-accept
readonly G_IMX_FW_PKG="firmware-imx-5.4"
readonly G_IMX_FW_LOCAL_DIR="${DEF_SRC_DIR}/imx/${G_IMX_FW_PKG}"
readonly G_IMX_FW_LOCAL_PATH="${DEF_SRC_DIR}/imx/${G_IMX_FW_PKG}.bin"
readonly G_IMX_FW_REMOTE_LINK="${G_FSL_MIRROR}/${G_IMX_FW_PKG}.bin"
# sh imx-vpu-5.4.33.bin --auto-accept
readonly G_IMX_VPU_PKG="imx-vpu-5.4.35"
readonly G_IMX_VPU_LOCAL_DIR="${DEF_SRC_DIR}/imx/${G_IMX_VPU_PKG}"
readonly G_IMX_VPU_LOCAL_PATH="${DEF_SRC_DIR}/imx/${G_IMX_VPU_PKG}.bin"
readonly G_IMX_VPU_REMOTE_LINK="${G_FSL_MIRROR}/${G_IMX_VPU_PKG}.bin"
# sh imx-codec-4.0.9.bin --auto-accept
readonly G_IMX_CODEC_PKG="imx-codec-4.1.4"
readonly G_IMX_CODEC_LOCAL_DIR="${DEF_SRC_DIR}/imx/${G_IMX_CODEC_PKG}"
readonly G_IMX_CODEC_LOCAL_PATH="${DEF_SRC_DIR}/imx/${G_IMX_CODEC_PKG}.bin"
readonly G_IMX_CODEC_REMOTE_LINK="${G_FSL_MIRROR}/${G_IMX_CODEC_PKG}.bin"

readonly G_IMX_GPU_SW_VER="8.6"
# sh imx-gpu-viv-5.0.11.pX.Y-hfp.bin --auto-accept
readonly G_IMX_GPU_PKG="imx-gpu-viv-5.0.11.p${G_IMX_GPU_SW_VER}-hfp"
readonly G_IMX_GPU_LOCAL_DIR="${DEF_SRC_DIR}/imx/${G_IMX_GPU_PKG}"
readonly G_IMX_GPU_LOCAL_PATH="${DEF_SRC_DIR}/imx/${G_IMX_GPU_PKG}.bin"
readonly G_IMX_GPU_REMOTE_LINK="${G_FSL_MIRROR}/${G_IMX_GPU_PKG}.bin"
# sh imx-gpu-viv-5.0.11.pX.Y-hfp.bin --auto-accept
readonly G_IMX_XORG_PKG="xserver-xorg-video-imx-viv-5.0.11.p${G_IMX_GPU_SW_VER}"
readonly G_IMX_XORG_LOCAL_DIR="${DEF_SRC_DIR}/imx/${G_IMX_XORG_PKG}"
readonly G_IMX_XORG_LOCAL_PATH="${DEF_SRC_DIR}/imx/${G_IMX_XORG_PKG}.tar.gz"
readonly G_IMX_XORG_REMOTE_LINK="${G_FSL_MIRROR}/${G_IMX_XORG_PKG}.tar.gz"
# replacement for Freescale's closed-development libfslvapwrapper library
readonly G_IMX_VPU_API_SRC_DIR="${DEF_SRC_DIR}/imx/libimxvpuapi"
readonly G_IMX_VPU_API_GIT="git://github.com/Freescale/libimxvpuapi.git"
readonly G_IMX_VPU_API_GIT_BRANCH="master"
readonly G_IMX_VPU_API_GIT_SRCREV="4afb52f97e28c731c903a8538bf99e4a6d155b42"
# much more standard replacement for Freescale's imx-gst1.0-plugin
readonly G_IMX_GSTREAMER_SRC_DIR="${DEF_SRC_DIR}/imx/gstreamer-imx"
readonly G_IMX_GSTREAMER_GIT="git://github.com/Freescale/gstreamer-imx.git"
readonly G_IMX_GSTREAMER_GIT_BRANCH="master"
readonly G_IMX_GSTREAMER_GIT_SRCREV="eb03bfab6f1f3eb854df247af0da308d1d1e2090"

## CROSS_COMPILER config and paths
readonly G_CROSS_COMPILER_VERSION="4.9-2016.02"
readonly G_CROSS_COMPILER_PATH="${G_TOOLS_PATH}/gcc-linaro-${G_CROSS_COMPILER_VERSION}-x86_64_arm-linux-gnueabihf/bin"
readonly G_CROSS_COMPILER_PREFIX="arm-linux-gnueabihf-"
readonly G_CROSS_COMPILER_JOPTION="-j 4"
readonly G_EXT_CROSS_COMPILER_NAME="gcc-linaro-${G_CROSS_COMPILER_VERSION}-x86_64_arm-linux-gnueabihf.tar.xz"
readonly G_EXT_CROSS_COMPILER_LINK="http://releases.linaro.org/components/toolchain/binaries/${G_CROSS_COMPILER_VERSION}/arm-linux-gnueabihf/${G_EXT_CROSS_COMPILER_NAME}"

## ROOTFS config and paths
#readonly G_ROOTFS_REMOTE_LINK="http://releases.linaro.org/debian/images/developer-armhf/17.02/linaro-jessie-developer-20161117-32.tar.gz"
readonly G_LINARO_ROOTFS_REMOTE_LINK="http://releases.linaro.org/debian/images/alip-armhf/17.02/linaro-jessie-alip-20161117-32.tar.gz"
readonly G_LINARO_ROOTFS_LOCAL_PATH="${DEF_SRC_DIR}/linaro-jessie.tar.gz"

############## user rootfs packages ##########
readonly G_USER_PACKAGES=""

#### Input params #####
PARAM_OUTPUT_DIR="${DEF_BUILDENV}/output"
PARAM_DEBUG="0"
PARAM_CMD="all"
PARAM_BLOCK_DEVICE="na"


### usage ###
function usage() {
	echo "This program version ${SCRIPT_VERSION}"
	echo " Used for make debian image for \"var-som-mx6\" board"
	echo " and create booted sdcard"
	echo ""
	echo "Usage:"
	echo " ./${SCRIPT_NAME} options"
	echo ""
	echo "Options:"
	echo "  -h|--help   -- print this help"
	echo "  -c|--cmd <command>"
	echo "     Supported commands:"
	echo "       deploy      -- prepare environment for all commands"
	echo "       all         -- build or rebuild kernel/bootloader/rootfs"
	echo "       bootloader  -- build or rebuild bootloader (u-boot+SPL)"
	echo "       kernel      -- build or rebuild linux kernel for this board"
	echo "       modules     -- build or rebuild linux kernel modules and install in rootfs directory for this board"
	echo "       rootfs      -- build or rebuild debian rootfs filesystem (includes: make debian apks, make and install kernel moduled,"
	echo "                       make and install extern modules (wifi/bt), create rootfs.tar.bz2)"
	echo "       rtar        -- generate or regenerate rootfs.tar.bz2 image from rootfs folder "
	echo "       clean       -- clean all build artifacts (not delete sources code and resulted images (output folder))"
	echo "       sdcard      -- create bootting sdcard for this device"
	echo "  -o|--output -- custom select output directory (default: \"${PARAM_OUTPUT_DIR}\")"
	echo "  -d|--dev    -- select sdcard device (exmple: -d /dev/sde)"
	echo "  --debug     -- enable debug mode for this script"
	echo "Examples of use:"
	echo "  make only linux kernel for board: sudo ./${SCRIPT_NAME} --cmd kernel"
	echo "  make only rootfs for board:       sudo ./${SCRIPT_NAME} --cmd rootfs"
	echo "  create boot sdcard:               sudo ./${SCRIPT_NAME} --cmd sdcard --dev /dev/sdX"
	echo "  deploy and build:                 ./${SCRIPT_NAME} --cmd deploy && sudo ./${SCRIPT_NAME} --cmd all"
	echo ""
}

###### parse input arguments ##
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
		-d|--dev ) # block device (for create sdcard)
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

## enable tarce options in debug mode
[ "${PARAM_DEBUG}" = "1" ] && {
	echo "Debug mode enabled!"
	set -x
};

## declarate dinamic variables ##
readonly G_ROOTFS_TARBAR_PATH="${PARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBAR_NAME}"

###### local functions ######

### printing functions ###

# print error message
# $1 - printing string
function pr_error() {
	echo "E: $1"
}

# print warning message
# $1 - printing string
function pr_warning() {
	echo "W: $1"
}

# print info message
# $1 - printing string
function pr_info() {
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
function get_git_src() {
	# clone src code
	git clone -b ${2} ${1} ${3}
	return $?
} 

# get remote file
# $1 - remote file
# $2 - local file
function get_remote_file() {
	# download remote file
	wget -c ${1} -O ${2}
	return $?
} 

# unpack fsl package
# $1 - package
function unpack_imx_package() {
	cd ${DEF_SRC_DIR}/imx
	/bin/sh ${1} --auto-accept
	cd -
	return $?
} 

# function generate rootfs in input dir
# $1 - rootfs base dir
function make_debian_rootfs() {
	pr_info "Make debian rootfs start..."
	local ROOTFS_BASE=$1

## umount previously mount points
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null && :;

## clear rootfs dir
	rm -rf ${ROOTFS_BASE}/* && :;

## extract linaro rootfs
	pr_info "extracting linaro rootfs"
	tar zxf ${G_LINARO_ROOTFS_LOCAL_PATH} -C ${ROOTFS_BASE}
	mv ${ROOTFS_BASE}/binary/* ${G_ROOTFS_DIR}
	rmdir ${ROOTFS_BASE}/binary
	sync

## install kernel modules in rootfs
	install_kernel_modules ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_LINUX_KERNEL_DEF_CONFIG} ${G_LINUX_KERNEL_SRC_DIR} ${ROOTFS_BASE} || {
		pr_error "Failed #$? in function install_kernel_modules"
		return 2;
	}

## install wl18xx stuff
	install_wl18xx_packages ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX}

## copy imx sources to rootfs for native compilation
	install_imx_packages


## prepare qemu
	pr_info "chroot in rootfs"
	mount -o bind /proc ${ROOTFS_BASE}/proc
	mount -o bind /sys ${ROOTFS_BASE}/sys
	mount -o bind /dev ${ROOTFS_BASE}/dev
	mount -o bind /dev/pts ${ROOTFS_BASE}/dev/pts
	cp /usr/bin/qemu-arm-static ${ROOTFS_BASE}/usr/bin/
	cp ${G_VARISCITE_PATH}/chroot_script* ${ROOTFS_BASE}

## copy custom files
	cp ${G_VARISCITE_PATH}/issue ${ROOTFS_BASE}/etc
	cp ${G_VARISCITE_PATH}/issue.net ${ROOTFS_BASE}/etc
	cp ${G_VARISCITE_PATH}/fw_env.config ${ROOTFS_BASE}/etc
	cp ${G_VARISCITE_PATH}/kobs-ng ${ROOTFS_BASE}/usr/bin
	cp ${PARAM_OUTPUT_DIR}/fw_printenv ${ROOTFS_BASE}/usr/bin
	ln -sf fw_printenv ${ROOTFS_BASE}/usr/bin/fw_setenv
	cp ${G_VARISCITE_PATH}/variscite-bluetooth ${ROOTFS_BASE}/etc/init.d
	cp ${G_VARISCITE_PATH}/10-imx.rules ${ROOTFS_BASE}/etc/udev/rules.d
	cp ${G_VARISCITE_PATH}/background.png ${ROOTFS_BASE}/usr/share/linaro/wallpapers/linaro-default-wallpaper.jpg
	cp ${G_VARISCITE_PATH}/rc.local ${ROOTFS_BASE}/etc/
	cp ${G_VARISCITE_PATH}/splash.bmp ${ROOTFS_BASE}/boot
	install -m 0644 ${G_VARISCITE_PATH}/systemd-hostnamed.service ${ROOTFS_BASE}/lib/systemd/system

	LANG=C LC_ALL=C chroot ${ROOTFS_BASE} /chroot_script_base.sh
	sleep 1; sync

## apply drm-update-arm.patch
	LANG=C LC_ALL=C chroot ${ROOTFS_BASE} /chroot_script_patched-drm-prebuilt.sh
	sleep 1; sync

## install iMX GPU libs
	cp ${G_VARISCITE_PATH}/xorg.conf ${ROOTFS_BASE}/etc/X11
	cp ${G_VARISCITE_PATH}/rc.autohdmi ${ROOTFS_BASE}/etc/init.d
	LANG=C LC_ALL=C chroot ${ROOTFS_BASE} /chroot_script_xorg.sh
	sleep 1; sync

## install iMX VPU libs 
	LANG=C LC_ALL=C chroot ${ROOTFS_BASE} /chroot_script_gst.sh

## kill latest dbus-daemon instance due to qemu-arm-static
	QEMU_PROC_ID=$(ps axf | grep dbus-daemon | grep qemu-arm-static | awk '{print $1}')
	if [ -n "$QEMU_PROC_ID" ]
	then
		kill -9 $QEMU_PROC_ID
	fi

## umount previously mount points
	umount ${ROOTFS_BASE}/{sys,proc,dev/pts,dev} 2>/dev/null && :;

	rm ${ROOTFS_BASE}/usr/bin/qemu-arm-static
	rm ${ROOTFS_BASE}/chroot_script*
	rm ${ROOTFS_BASE}/md5sum.txt
	rm -rf ${ROOTFS_BASE}/usr/local/src/*

	return 0;
}

# make tarbar arx from footfs
# $1 -- packet folder
# $2 -- output arx full name
function make_tarbar() {
	cd $1

	pr_info "make tarbar arx from folder ${1}"
	pr_info "Remove old arx $2"
	rm $2 > /dev/null 2>&1 && :;

	pr_info "Create $2"

	tar jcf $2 .
	success=$?
	[ $success -eq 0 ] || {
	# fail
	    rm $2 > /dev/null 2>&1 && :;
	};

	cd -
}

# make linux kernel modules
# $1 -- cross compiler prefix
# $2 -- linux defconfig file
# $3 -- linux dtb files
# $4 -- linux dirname
# $5 -- out patch
function make_kernel() {
	pr_info "make kernel .config"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${4}/ ${2}
	echo "# CONFIG_MXC_GPU_VIV is not set" >> ${4}/.config

	pr_info "make kernel"
	make CROSS_COMPILE=${1} ARCH=arm ${G_CROSS_COMPILER_JOPTION} LOADADDR=0x10008000 -C ${4}/ uImage

	pr_info "make ${3} dtbs"
	make CROSS_COMPILE=${1} ARCH=arm ${G_CROSS_COMPILER_JOPTION} -C ${4} ${3}

	pr_info "Copy kernel and dtb files to output dir: ${5}"
	cp ${4}/arch/arm/boot/uImage ${5}/;
	cp ${4}/arch/arm/boot/dts/*.dtb ${5}/;

	return 0;
}

# clean kernel
# $1 -- linux dir path
function clean_kernel() {
	pr_info "Clean linux kernel"

	make ARCH=arm -C ${1}/ mrproper

	return 0;
}

# make linux kernel modules
# $1 -- cross compiler prefix
# $2 -- linux defconfig file
# $3 -- linux dirname
# $4 -- out modules path
function make_kernel_modules() {
	pr_info "make kernel defconfig"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} ${2}

	pr_info "Compiling kernel modules"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} modules

	# presently not a module but built in the kernel
	pr_info "Compiling iMX GPU kernel module"
	cd ${G_IMX_GPU_DRV_SRC_DIR}
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} M=${G_IMX_GPU_DRV_SRC_DIR}/kernel-module-imx-gpu-viv-src AQROOT=${G_IMX_GPU_DRV_SRC_DIR}/kernel-module-imx-gpu-viv-src
	cd -

	pr_info "make wl18xx defconfig"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} KLIB_BUILD=${3} KLIB=${4} -C ${G_WILINK8_COMPAT_WIRELESS_SRC_DIR} defconfig-wl18xx

	pr_info "Compiling wl18xx modules"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} KLIB_BUILD=${3} KLIB=${4} -C ${G_WILINK8_COMPAT_WIRELESS_SRC_DIR} modules
}

# install linux kernel modules
# $1 -- cross compiler prefix
# $2 -- linux defconfig file
# $3 -- linux dirname
# $4 -- out modules path
function install_kernel_modules() {
	pr_info "Installing kernel headers to ${4}"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} INSTALL_HDR_PATH=${4}/usr/local headers_install

	pr_info "Installing kernel modules to ${4}"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} INSTALL_MOD_PATH=${4} modules_install

	pr_info "Installing iMX GPU kernel module"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} -C ${3} M=${G_IMX_GPU_DRV_SRC_DIR}/kernel-module-imx-gpu-viv-src AQROOT=${G_IMX_GPU_DRV_SRC_DIR}/kernel-module-imx-gpu-viv-src INSTALL_MOD_PATH=${4} modules_install

	pr_info "Installing wl18xx modules to ${4}"
	make ARCH=arm CROSS_COMPILE=${1} ${G_CROSS_COMPILER_JOPTION} KLIB_BUILD=${3} KLIB=${4} -C ${G_WILINK8_COMPAT_WIRELESS_SRC_DIR}/ INSTALL_MOD_PATH=${4} modules_install


	return 0;
}

function install_wl18xx_packages() {
	local WL18XX_FW_DIR=${G_ROOTFS_DIR}/lib/firmware/ti-connectivity
	local WLCONF_DIR=${G_ROOTFS_DIR}/usr/sbin/wlconf

	mkdir -p ${WL18XX_FW_DIR}
	mkdir -p ${WLCONF_DIR}

	pr_info "Compiling wl18xx wlconf"
	make CC=${1}gcc ${G_CROSS_COMPILER_JOPTION} -C ${G_WILINK8_UTILS_SRC_DIR}/wlconf

	pr_info "Installing wl18xx bt firmware"
	cp ${G_WILINK8_FW_BT_SRC_DIR}/initscripts/*.bts ${WL18XX_FW_DIR}
	
	pr_info "Installing wl18xx wifi firmware"
	cp ${G_WILINK8_FW_WIFI_SRC_DIR}/*.bin ${WL18XX_FW_DIR}
	cp ${G_VARISCITE_PATH}/wl1271-nvs.bin ${WL18XX_FW_DIR}

	pr_info "Installing wl18xx wlconf"
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/configure-device.sh ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/default.conf ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/dictionary.txt ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/example.* ${WLCONF_DIR}
	cp -r ${G_WILINK8_UTILS_SRC_DIR}/wlconf/official_inis ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/README ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/*.bin ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/wlconf ${WLCONF_DIR}
	cp ${G_WILINK8_UTILS_SRC_DIR}/wlconf/wl18xx-conf-default.bin ${WL18XX_FW_DIR}/wl18xx-conf.bin

	return 0;
}

function install_imx_packages() {
	local VPU_FW_DIR=${G_ROOTFS_DIR}/lib/firmware/vpu
	local IMX_DIR=${G_ROOTFS_DIR}/usr/local/src/imx
	local DEB_DIR=${G_ROOTFS_DIR}/usr/local/src/deb

	mkdir -p ${VPU_FW_DIR}
	mkdir -p ${IMX_DIR}
	mkdir -p ${DEB_DIR}

	pr_info "Installing vpu firmware"
	cp ${G_IMX_FW_LOCAL_DIR}/firmware/vpu/vpu_fw_imx6*.bin ${VPU_FW_DIR}

	cp -r ${G_IMX_VPU_LOCAL_DIR} ${IMX_DIR}
	cp -r ${G_IMX_CODEC_LOCAL_DIR} ${IMX_DIR}
	cp -r ${G_IMX_GPU_LOCAL_DIR} ${IMX_DIR}
	cp -r ${G_IMX_XORG_LOCAL_DIR} ${IMX_DIR}
	cp -r ${G_IMX_VPU_API_SRC_DIR} ${IMX_DIR}
	cp -r ${G_IMX_GSTREAMER_SRC_DIR} ${IMX_DIR}

	cp -r ${G_VARISCITE_PATH}/deb/* ${DEB_DIR}

	return 0;
}

# make uboot
# $1 uboot path
# $2 outputdir
function make_uboot() {
### make emmc uboot ###
	pr_info "Make SPL & u-boot: ${G_UBOOT_DEF_CONFIG_MMC}"
	# clean work directory 
	make ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION} mrproper

	# make uboot config for mmc
	make ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION} ${G_UBOOT_DEF_CONFIG_MMC}

	# make uboot
	make ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION}

	# copy images
	cp ${1}/SPL ${2}/${G_SPL_NAME_FOR_EMMC}
	cp ${1}/u-boot.img ${2}/${G_UBOOT_NAME_FOR_EMMC}

### make nand uboot ###
	pr_info "Make SPL & u-boot: ${G_UBOOT_DEF_CONFIG_NAND}"
	# clean work directory
	make ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION} mrproper

	# make uboot config for nand
	make ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION} ${G_UBOOT_DEF_CONFIG_NAND}

	# make uboot
	make ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION}

	# copy images
	cp ${1}/SPL ${2}/${G_SPL_NAME_FOR_NAND}
	cp ${1}/u-boot.img ${2}/${G_UBOOT_NAME_FOR_NAND}

	# make fw_printenv
	make env ARCH=arm -C ${1} CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_CROSS_COMPILER_JOPTION}
	cp ${1}/tools/env/fw_printenv ${2}

	return 0;
}

# clean uboot
# $1 -- u-boot dir path
function clean_uboot() {
	pr_info "Clean uboot"

	make ARCH=arm -C ${1}/ mrproper

	return 0;
}

# make sdcard for device
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
	pr_info "================================================"
	read -p "Press Enter to continue"

	return 0
}

# make sdcard for device
# $1 -- block device
# $2 -- output images dir
function make_sdcard() {
	readonly local LPARAM_BLOCK_DEVICE=${1}
	readonly local LPARAM_OUTPUT_DIR=${2}
	readonly local P1_MOUNT_DIR="${G_TMP_DIR}/p1"
	readonly local P2_MOUNT_DIR="${G_TMP_DIR}/p2"
	readonly local DEBIAN_IMAGES_TO_ROOTFS_POINT="opt/images/Debian"

	readonly local BOOTLOAD_RESERVE=4
	readonly local BOOT_ROM_SIZE=8
	readonly local SPARE_SIZE=0

	[ "${LPARAM_BLOCK_DEVICE}" = "na" ] && {
		pr_warning "No valid block device: ${LPARAM_BLOCK_DEVICE}"
		return 1;
	};

	local part=""
	if [ `echo ${LPARAM_BLOCK_DEVICE} | grep -c mmcblk` -ne 0 ]; then
		part="p"
	fi

	# Check that we're using a valid device
	if ! check_sdcard ${LPARAM_BLOCK_DEVICE}; then
		return 1
	fi

	for ((i=0; i<10; i++))
	do
		if [ `mount | grep -c ${LPARAM_BLOCK_DEVICE}${part}$i` -ne 0 ]; then
			umount ${LPARAM_BLOCK_DEVICE}${part}$i
		fi
	done

	# Call sfdisk to get total card size
	local TOTAL_SIZE=`sfdisk -s ${LPARAM_BLOCK_DEVICE}`
	local TOTAL_SIZE=`expr ${TOTAL_SIZE} / 1024`

	function format_sdcard
	{
		pr_info "Formating SDCARD partitions"
		mkfs.vfat ${LPARAM_BLOCK_DEVICE}${part}1 -n BOOT-VARSOM
		mkfs.ext4 ${LPARAM_BLOCK_DEVICE}${part}2 -L rootfs
	}

	function flash_u-boot
	{
		pr_info "Flashing U-Boot"
		dd if=${LPARAM_OUTPUT_DIR}/${G_SPL_NAME_FOR_EMMC} of=${LPARAM_BLOCK_DEVICE} bs=1K seek=1; sync
		dd if=${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_EMMC} of=${LPARAM_BLOCK_DEVICE} bs=1K seek=69; sync
	}

	function flash_sdcard
	{
		pr_info "Flashing \"BOOT-VARSOM\" partition"
		cp ${LPARAM_OUTPUT_DIR}/*.dtb	${P1_MOUNT_DIR}/
		cp ${LPARAM_OUTPUT_DIR}/uImage	${P1_MOUNT_DIR}/uImage
		sync

		pr_info "Flashing \"rootfs\" partition"
		tar -xjf ${LPARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBAR_NAME} -C ${P2_MOUNT_DIR}/
	}

	function copy_debian_images
	{
		mkdir -p ${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}

		pr_info "Copying Debian images to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/uImage 						${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/
		cp ${LPARAM_OUTPUT_DIR}/${DEF_ROOTFS_TARBAR_NAME}	${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/${DEF_ROOTFS_TARBAR_NAME}

		cp ${LPARAM_OUTPUT_DIR}/*.dtb						${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/

		pr_info "Copying MMC U-Boot to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/${G_SPL_NAME_FOR_EMMC}		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/SPL.mmc
		cp ${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_EMMC}	${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/u-boot.img.mmc

		pr_info "Copying NAND U-Boot to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${LPARAM_OUTPUT_DIR}/${G_SPL_NAME_FOR_NAND}		${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/SPL.nand
		cp ${LPARAM_OUTPUT_DIR}/${G_UBOOT_NAME_FOR_NAND}	${P2_MOUNT_DIR}/${DEBIAN_IMAGES_TO_ROOTFS_POINT}/u-boot.img.nand

		return 0;
	}

	function copy_scripts
	{
		pr_info "Copying scripts to /${DEBIAN_IMAGES_TO_ROOTFS_POINT}"
		cp ${G_VARISCITE_PATH}/debian-emmc.sh	${P2_MOUNT_DIR}/usr/sbin/
		cp ${G_VARISCITE_PATH}/debian-install.sh ${P2_MOUNT_DIR}/usr/sbin/
	}

	function ceildiv
	{
	    local num=$1
	    local div=$2
	    echo $(( (num + div - 1) / div ))
	}

	# Delete the partitions
	for ((i=0; i<10; i++))
	do
		if [ `ls ${LPARAM_BLOCK_DEVICE}${part}$i 2> /dev/null | grep -c ${LPARAM_BLOCK_DEVICE}${part}$i` -ne 0 ]; then
			dd if=/dev/zero of=${LPARAM_BLOCK_DEVICE}${part}$i bs=512 count=1024
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk ${LPARAM_BLOCK_DEVICE} &> /dev/null) || true
	sync

	dd if=/dev/zero of=${LPARAM_BLOCK_DEVICE} bs=1024 count=4096
	sleep 2; sync;

	pr_info "Creating new partitions"

	# Create a new partition table
fdisk ${LPARAM_BLOCK_DEVICE} <<EOF
n
p
1
8192
24575
t
c
n
p
2
24576

p
w
EOF
	sleep 2; sync;

	# Get total card size
	total_size=`sfdisk -s ${LPARAM_BLOCK_DEVICE}`
	total_size=`expr ${total_size} / 1024`
	boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
	rootfs_size=`expr ${total_size} - ${boot_rom_sizeb} - ${SPARE_SIZE}`

	pr_info "ROOT SIZE=${rootfs_size} TOTAl SIZE=${total_size} BOOTROM SIZE=${boot_rom_sizeb}"
	sleep 2; sync;

	# Format the partitions
	format_sdcard
	sleep 2; sync;

	flash_u-boot
	sleep 2; sync;

	# Mount the partitions
	mkdir -p ${P1_MOUNT_DIR}
	mkdir -p ${P2_MOUNT_DIR}
	sync

	mount ${LPARAM_BLOCK_DEVICE}${part}1  ${P1_MOUNT_DIR}
	mount ${LPARAM_BLOCK_DEVICE}${part}2  ${P2_MOUNT_DIR}
	sleep 2; sync;

	flash_sdcard
	copy_debian_images
	copy_scripts

	pr_info "Sync sdcard..."
	sync
	umount ${P1_MOUNT_DIR}
	umount ${P2_MOUNT_DIR}

	rm -rf ${P1_MOUNT_DIR}
	rm -rf ${P2_MOUNT_DIR}

	pr_info "Done make sdcard!"

	return 0;
}

#################### commands ################

function cmd_make_deploy() {
	mkdir -p ${DEF_SRC_DIR}/imx
	mkdir -p ${DEF_SRC_DIR}/wilink8/fw
	mkdir -p ${G_TOOLS_PATH}
	mkdir -p ${G_ROOTFS_DIR}
	mkdir -p ${G_TMP_DIR}
	mkdir -p ${PARAM_OUTPUT_DIR}

	# get linaro toolchain
	(( `ls ${G_CROSS_COMPILER_PATH} | wc -l` == 0 )) && {
		pr_info "Get and unpack cross compiler";
		get_remote_file ${G_EXT_CROSS_COMPILER_LINK} ${DEF_SRC_DIR}/${G_EXT_CROSS_COMPILER_NAME}
		tar -xJf ${DEF_SRC_DIR}/${G_EXT_CROSS_COMPILER_NAME} -C ${G_TOOLS_PATH}/
	};

	# get linaro rootfs
	(( `ls ${G_LINARO_ROOTFS_LOCAL_PATH} | wc -l` == 0 )) && {
		pr_info "Get Linaro rootfs";
		get_remote_file ${G_LINARO_ROOTFS_REMOTE_LINK} ${G_LINARO_ROOTFS_LOCAL_PATH}
	};

	# get uboot repository
	(( `ls ${G_UBOOT_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get uboot repository";
		get_git_src ${G_UBOOT_GIT} ${G_UBOOT_BRANCH} ${G_UBOOT_SRC_DIR}
	};

	# get kernel repository
	(( `ls ${G_LINUX_KERNEL_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get kernel repository";
		get_git_src ${G_LINUX_KERNEL_GIT} ${G_LINUX_KERNEL_BRANCH} ${G_LINUX_KERNEL_SRC_DIR};
	};

	# get imx gpu driver repository
	(( `ls ${G_IMX_GPU_DRV_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get iMX GPU driver repository";
		get_git_src ${G_IMX_GPU_DRV_GIT} ${G_IMX_GPU_DRV_GIT_BRANCH} ${G_IMX_GPU_DRV_SRC_DIR}
		cd ${G_IMX_GPU_DRV_SRC_DIR}
		git checkout ${G_IMX_GPU_DRV_GIT_SRCREV}
		cd -
	};

	# get wilink8 backports repository
	(( `ls ${G_WILINK8_BACKPORTS_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get wilink8 backports repository";
		get_git_src ${G_WILINK8_BACKPORTS_GIT} ${G_WILINK8_BACKPORTS_GIT_BRANCH} ${G_WILINK8_BACKPORTS_SRC_DIR}
		cd ${G_WILINK8_BACKPORTS_SRC_DIR}
		git checkout ${G_WILINK8_BACKPORTS_GIT_SRCREV}
		cd -
	};

	# get wilink8 wl18xx repository
	(( `ls ${G_WILINK8_WL18XX_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get wilink8 wl18xx repository";
		get_git_src ${G_WILINK8_WL18XX_GIT} ${G_WILINK8_WL18XX_GIT_BRANCH} ${G_WILINK8_WL18XX_SRC_DIR}
		cd ${G_WILINK8_WL18XX_SRC_DIR}
		git checkout ${G_WILINK8_WL18XX_GIT_SRCREV}
		cd -
	};

	# generate compat-wireless
	(( `ls ${G_WILINK8_COMPAT_WIRELESS_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Generate compat-wireless"
		cd ${G_WILINK8_BACKPORTS_SRC_DIR}
		python ./gentree.py --clean ${G_WILINK8_WL18XX_SRC_DIR} ${G_WILINK8_COMPAT_WIRELESS_SRC_DIR}
		cd -
	};

	# get wilink8 utils repository
	(( `ls ${G_WILINK8_UTILS_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get wilink8 utils repository";
		get_git_src ${G_WILINK8_UTILS_GIT} ${G_WILINK8_UTILS_GIT_BRANCH} ${G_WILINK8_UTILS_SRC_DIR}
		cd ${G_WILINK8_UTILS_SRC_DIR}
		git checkout ${G_WILINK8_UTILS_GIT_SRCREV}
		patch -p1 < ${DEF_BUILDENV}/patches/wilink8/utils/config_sh.patch
		cd -
	};

	# get wilink8 firmware repository
	(( `ls ${G_WILINK8_FW_WIFI_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get wilink8 wifi firmware repository";
		get_git_src ${G_WILINK8_FW_WIFI_GIT} ${G_WILINK8_FW_WIFI_GIT_BRANCH} ${G_WILINK8_FW_WIFI_SRC_DIR}
		cd ${G_WILINK8_FW_WIFI_SRC_DIR}
		git checkout ${G_WILINK8_FW_WIFI_GIT_SRCREV}
		cd -
	};

	# get bt firmware repository
	(( `ls ${G_WILINK8_FW_BT_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get wilink8 bt firmware repository";
		get_git_src ${G_WILINK8_FW_BT_GIT} ${G_WILINK8_FW_BT_GIT_BRANCH} ${G_WILINK8_FW_BT_SRC_DIR}
		cd ${G_WILINK8_FW_BT_SRC_DIR}
		git checkout ${G_WILINK8_FW_BT_GIT_SRCREV}
		cd -
	};

	# get imx firmware
	(( `ls ${G_IMX_FW_LOCAL_PATH} | wc -l` == 0 )) && {
		pr_info "Get and unpack iMX firmware";
		get_remote_file ${G_IMX_FW_REMOTE_LINK} ${G_IMX_FW_LOCAL_PATH}
		unpack_imx_package ${G_IMX_FW_LOCAL_PATH}
	};

	# get imx vpu library
	(( `ls ${G_IMX_VPU_LOCAL_PATH} | wc -l` == 0 )) && {
		pr_info "Get and unpack iMV VPU library";
		get_remote_file ${G_IMX_VPU_REMOTE_LINK} ${G_IMX_VPU_LOCAL_PATH}
		unpack_imx_package ${G_IMX_VPU_LOCAL_PATH}
	};

	# get imx codec libraries
	(( `ls ${G_IMX_CODEC_LOCAL_PATH} | wc -l` == 0 )) && {
		pr_info "Get and unpack iMV CODEC libraries";
		get_remote_file ${G_IMX_CODEC_REMOTE_LINK} ${G_IMX_CODEC_LOCAL_PATH}
		unpack_imx_package ${G_IMX_CODEC_LOCAL_PATH}
	};

	# get imx gpu libraries
	(( `ls ${G_IMX_GPU_LOCAL_PATH} | wc -l` == 0 )) && {
		pr_info "Get and unpack iMV GPU libraries";
		get_remote_file ${G_IMX_GPU_REMOTE_LINK} ${G_IMX_GPU_LOCAL_PATH}
		unpack_imx_package ${G_IMX_GPU_LOCAL_PATH}
	};

	# get imx xorg libraries
	(( `ls ${G_IMX_XORG_LOCAL_PATH} | wc -l` == 0 )) && {
		pr_info "Get and unpack iMV XORG libraries";
		get_remote_file ${G_IMX_XORG_REMOTE_LINK} ${G_IMX_XORG_LOCAL_PATH}
		echo "tar -xvf ${G_IMX_XORG_LOCAL_PATH} -C ${G_IMX_XORG_LOCAL_DIR}"
		tar -xvf ${G_IMX_XORG_LOCAL_PATH} -C ${DEF_SRC_DIR}/imx
		cd ${G_IMX_XORG_LOCAL_DIR}
		patch -p1 < ${DEF_BUILDENV}/patches/imx/xserver-xorg-video-imx-viv-5.0.11.p${G_IMX_GPU_SW_VER}/Stop-using-Git-to-write-local-version.patch
		cd -
	};

	# get imx vpu api repository
	(( `ls ${G_IMX_VPU_API_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get iMX VPU API repository";
		get_git_src ${G_IMX_VPU_API_GIT} ${G_IMX_VPU_API_GIT_BRANCH} ${G_IMX_VPU_API_SRC_DIR}
		cd ${G_IMX_VPU_API_SRC_DIR}
		git checkout ${G_IMX_VPU_API_GIT_SRCREV}
		cd -
	};

	# get gstreamer-imx repository
	(( `ls ${G_IMX_GSTREAMER_SRC_DIR} | wc -l` == 0 )) && {
		pr_info "Get gstreamer-imx repository";
		get_git_src ${G_IMX_GSTREAMER_GIT} ${G_IMX_GSTREAMER_GIT_BRANCH} ${G_IMX_GSTREAMER_SRC_DIR}
		cd ${G_IMX_GSTREAMER_SRC_DIR}
		git checkout ${G_IMX_GSTREAMER_GIT_SRCREV}
		cd -
	};

	return 0;
}

function cmd_make_rootfs() {
	## make debian rootfs
	cd ${G_ROOTFS_DIR}
	make_debian_rootfs ${G_ROOTFS_DIR} || {
		pr_error "Failed #$? in function make_debian_rootfs"
		cd -;
		return 1;
	}
	cd -

	return 0;
}

function cmd_make_uboot() {
	make_uboot ${G_UBOOT_SRC_DIR} ${PARAM_OUTPUT_DIR} || {
		pr_error "Failed #$? in function make_uboot"
		return 1;
	};

	return 0;
}

function cmd_make_kernel() {
	make_kernel ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_LINUX_KERNEL_DEF_CONFIG} "${G_LINUX_DTB}" ${G_LINUX_KERNEL_SRC_DIR} ${PARAM_OUTPUT_DIR} || {
		pr_error "Failed #$? in function make_kernel"
		return 1;
	};

	return 0;
}


function cmd_make_kmodules() {
	make_kernel_modules ${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} ${G_LINUX_KERNEL_DEF_CONFIG} ${G_LINUX_KERNEL_SRC_DIR} ${G_ROOTFS_DIR} || {
		pr_error "Failed #$? in function make_kernel_modules"
		return 2;
	};

	return 0;
}

function cmd_make_rfs_tar() {
	## pack rootfs
	make_tarbar ${G_ROOTFS_DIR} ${G_ROOTFS_TARBAR_PATH} || {
		pr_error "Failed #$? in function make_tarbar"
		return 1;
	}

	return 0;
}

function cmd_make_sdcard() {
	make_sdcard ${PARAM_BLOCK_DEVICE} ${PARAM_OUTPUT_DIR} || {
		pr_error "Failed #$? in function make_sdcard"
		return 1;
	};

	return 0;
}

function cmd_make_clean() {

	## clean kernel, dtb, modules
	clean_kernel ${G_LINUX_KERNEL_SRC_DIR} || {
		pr_error "Failed #$? in function clean_kernel"
		return 1;
	};

	## clean u-boot
	clean_uboot ${G_UBOOT_SRC_DIR} || {
		pr_error "Failed #$? in function clean_uboot"
		return 2;
	};

	## delete tmp dirs and etc
	pr_info "Delete tmp dir ${G_TMP_DIR}"
	rm -rf ${G_TMP_DIR} && :;

	pr_info "Delete rootfs dir ${G_ROOTFS_DIR}"
	rm -rf ${G_ROOTFS_DIR} && :;

	return 0;
}

#################### main function #######################

## test for root access support (msrc not allowed)
[ "$PARAM_CMD" != "deploy" ] && [ "$PARAM_CMD" != "bootloader" ] && [ "$PARAM_CMD" != "kernel" ] && [ "$PARAM_CMD" != "modules" ] && [ ${EUID} -ne 0 ] && {
	pr_error "this command must be run as root (or sudo/su)"
	exit 1;
};

V_RET_CODE=0;

pr_info "Command: \"$PARAM_CMD\" start..."

case $PARAM_CMD in
	deploy )
		cmd_make_deploy || {
			V_RET_CODE=1;
		};
		;;
	rootfs )
		cmd_make_rootfs || {
			V_RET_CODE=1;
		};
		;;
	bootloader )
		cmd_make_uboot || {
			V_RET_CODE=1;
		}
		;;
	kernel )
		cmd_make_kernel || {
			V_RET_CODE=1;
		};
		;;
	modules )
		cmd_make_kmodules || {
			V_RET_CODE=1;
		};
		;;
	sdcard )
		cmd_make_sdcard || {
			V_RET_CODE=1;
		};
		;;
	rtar )
		cmd_make_rfs_tar || {
			V_RET_CODE=1;
		};
		;;
	all )
		(cmd_make_uboot  &&
		 cmd_make_kernel &&
		 cmd_make_kmodules &&
		 cmd_make_rootfs &&
		 cmd_make_rfs_tar
		) || {
			V_RET_CODE=1;
		};
		;;
	clean )
		cmd_make_clean || {
			V_RET_CODE=1;
		};
		;;
	* )
		pr_error "Invalid input command: \"${PARAM_CMD}\"";
		V_RET_CODE=1;
		;;
esac

pr_info ""
pr_info "Command: \"$PARAM_CMD\" end. Exit code: ${V_RET_CODE}"
pr_info ""


exit ${V_RET_CODE};
