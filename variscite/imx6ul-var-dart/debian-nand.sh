#!/bin/bash
#
# Flash Debian into NAND for DART-MX6UL
#

#### global constants ####
readonly UBOOT_IMAGE='u-boot.img.nand'
readonly SPL_IMAGE='SPL.nand'
readonly KERNEL_IMAGE='zImage'
readonly ROOTFS_IMAGE='rootfs.ubi.img'
readonly IMAGES_PATH="/opt/images/Debian"
readonly UBI_SUB_PAGE_SIZE=2048
readonly UBI_VID_HDR_OFFSET=2048

echo "================================="
echo " Variscite DART-6UL/VAR-SOM-6UL"
echo " Installing Debian to NAND flash"
echo "================================="

usage() {
	echo "usage: $(basename $0) <wifi|sd>"
}

[[ $EUID -ne 0 ]] && {
	echo "This script must be run with super-user privileges"
	exit 1
}

if [ $# -ne 1 ]; then
	usage
	exit 1
fi

if [ "$1" != "wifi" -a "$1" != "sd" ]; then
	usage
	exit 1
fi

MX6UL_MMC0_DEV=$1
if [[ $MX6UL_MMC0_DEV == "sd" ]] ; then
	mx6ul_mmc0_dev="sd-card"
elif [[ $MX6UL_MMC0_DEV == "wifi" ]] ; then
	mx6ul_mmc0_dev="wifi"
fi

SOC=`cat /sys/bus/soc/devices/soc0/soc_id`
if [[ $SOC == i.MX6UL ]] ; then
	soc="imx6ul"
elif [[ $SOC == i.MX6ULL ]] ; then
	soc="imx6ull"
elif [[ $SOC == i.MX6ULZ ]] ; then
	soc="imx6ulz"
fi
if grep -iq DART /sys/devices/soc0/machine ; then
	som="var-dart"
	carrier="6ulcustomboard"
else
	som="var-som"
	carrier="concerto-board"
fi

function install_bootloader()
{
	[ ! -f ${IMAGES_PATH}/$UBOOT_IMAGE ] && {
		echo "\"${IMAGES_PATH}/$UBOOT_IMAGE\"" does not exist! exit.
		exit 1
	};

	[ ! -f ${IMAGES_PATH}/$SPL_IMAGE ] && {
		echo "\"${IMAGES_PATH}/$SPL_IMAGE\"" does not exist! exit.
		exit 1
	};

	echo
	echo "Installing SPL from \"${IMAGES_PATH}/$SPL_IMAGE\"... "
	flash_erase /dev/mtd0 0 0 2>/dev/null
	kobs-ng init -x ${IMAGES_PATH}/$SPL_IMAGE --search_exponent=1 -v > /dev/null

	echo
	echo "Installing U-BOOT from \"${IMAGES_PATH}/$UBOOT_IMAGE\"..."
	flash_erase /dev/mtd1  0 0  2>/dev/null
	nandwrite -p /dev/mtd1 ${IMAGES_PATH}/$UBOOT_IMAGE; sync

	# delete uboot env
	flash_erase /dev/mtd2 0 0 2>/dev/null
}

function install_kernel()
{
	[ ! -f ${IMAGES_PATH}/$KERNEL_IMAGE ] && {
		echo "\"${IMAGES_PATH}/$KERNEL_IMAGE\"" does not exist! exit.
		exit 1
	};

	echo
	echo "Installing Kernel"
	flash_erase /dev/mtd3 0 0 2>/dev/null
	nandwrite -p /dev/mtd3 ${IMAGES_PATH}/$KERNEL_IMAGE > /dev/null

	dtb=${soc}-${som}-${carrier}-nand-${mx6ul_mmc0_dev}.dtb
	nandwrite -p /dev/mtd3 -s 0x7e0000 ${IMAGES_PATH}/$dtb > /dev/null
}

function install_rootfs()
{
	[ ! -f ${IMAGES_PATH}/$ROOTFS_IMAGE ] && {
		echo "\"${IMAGES_PATH}/$ROOTFS_IMAGE\"" does not exist! exit.
		exit 1
	};

	echo
	echo "Installing UBI rootfs"
	ubiformat /dev/mtd4 -f ${IMAGES_PATH}/$ROOTFS_IMAGE -s $UBI_SUB_PAGE_SIZE -O $UBI_VID_HDR_OFFSET -y
}


#Creating 5 MTD partitions on "gpmi-nand":
#0x000000000000-0x000000200000 : "spl"
#0x000000200000-0x000000400000 : "uboot"
#0x000000400000-0x000000600000 : "uboot-env"
#0x000000600000-0x000000e00000 : "kernel"
#0x000000e00000-0x000040000000 : "rootfs"

echo "Flashing..."

install_bootloader

install_kernel

install_rootfs


read -p "Debian Flashed in NAND. Press any key to continue... " -n1
