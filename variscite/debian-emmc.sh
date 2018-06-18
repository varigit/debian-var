#!/bin/bash

set -e

if [ $EUID != 0 ] ; then
	echo "This script must be run with super-user privileges"
	exit 1
fi

while getopts :b: OPTION;
do
	case $OPTION in
		b)
			if [ $OPTARG = dart ] ; then
				is_dart=true
			fi
			;;
	esac
done

if [ "$is_dart" = true ] ; then
	block=mmcblk2
	bootpart=1
	rootfspart=2
else
	block=mmcblk0
	bootpart=none
	rootfspart=1
fi

node=/dev/${block}
part=p
mountdir_prefix=/run/media/${block}${part}
imagesdir=/opt/images/Debian

function check_images
{
	if [ ! -b $node ] ; then
		echo "ERROR: \"$node\" is not a block device"
		exit 1
	fi

	if [ "$is_dart" = true ] ; then
		if [ ! -f ${imagesdir}/SPL.mmc ] ; then
			echo "ERROR: SPL.mmc does not exist"
			exit 1
		fi
		if [ ! -f ${imagesdir}/u-boot.img.mmc ] ; then
			echo "ERROR: u-boot.img.mmc does not exist"
			exit 1
		fi
	fi
}

function delete_device
{
	echo
	echo "Deleting current partitions"
	for ((i=0; i<=10; i++))
	do
		if [ -e ${node}${part}${i} ] ; then
			dd if=/dev/zero of=${node}${part}${i} bs=1024 count=1024 2> /dev/null || true
		fi
	done
	sync

	((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk $node &> /dev/null) || true
	sync

	dd if=/dev/zero of=$node bs=1M count=4
	sync
}

function create_parts
{
	echo
	echo "Creating new partitions"
	if [ "$is_dart" = true ] ; then
		SECT_SIZE_BYTES=`cat /sys/block/${block}/queue/hw_sector_size`
		PART1_FIRST_SECT=`expr 4 \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
		PART2_FIRST_SECT=`expr $((4 + 8)) \* 1024 \* 1024 \/ $SECT_SIZE_BYTES`
		PART1_LAST_SECT=`expr $PART2_FIRST_SECT - 1`

		(echo n; echo p; echo $bootpart; echo $PART1_FIRST_SECT; echo $PART1_LAST_SECT; echo t; echo c; \
		 echo n; echo p; echo $rootfspart; echo $PART2_FIRST_SECT; echo; \
		 echo p; echo w) | fdisk $node > /dev/null
	else
		(echo n; echo p; echo $rootfspart; echo; echo; echo p; echo w) | fdisk $node > /dev/null
	fi
	fdisk -l $node
	sync; sleep 1
}

function format_boot_part
{
	echo
	echo "Formatting BOOT partition"
	mkfs.vfat ${node}${part}${bootpart} -n BOOT-VARSOM
	sync
}

function format_rootfs_part
{
	echo
	echo "Formatting rootfs partition"
	mkfs.ext4 ${node}${part}${rootfspart} -L rootfs
	sync
}

function install_bootloader
{
	echo
	echo "Installing bootloader to eMMC"
	dd if=${imagesdir}/SPL.mmc of=${node} bs=1K seek=1; sync
	dd if=${imagesdir}/u-boot.img.mmc of=${node} bs=1K seek=69; sync
}

function install_kernel
{
	echo
	echo "Installing kernel to BOOT partition"
	mkdir -p ${mountdir_prefix}${bootpart}
	mount -t vfat ${node}${part}${bootpart}		${mountdir_prefix}${bootpart}
	cp -v ${imagesdir}/imx6q-var-dart.dtb	${mountdir_prefix}${bootpart}/imx6q-var-dart.dtb
	cp -v ${imagesdir}/uImage			${mountdir_prefix}${bootpart}/uImage
	sync
	umount ${node}${part}${bootpart}
}

function install_rootfs
{
	echo
	echo "Installing rootfs"
	mkdir -p ${mountdir_prefix}${rootfspart}
	mount ${node}${part}${rootfspart} ${mountdir_prefix}${rootfspart}
	printf "Extracting files"
	tar --warning=no-timestamp -xpf ${imagesdir}/rootfs.tar.gz -C ${mountdir_prefix}${rootfspart} --checkpoint=.1200
	echo
	echo
	sync
	umount ${node}${part}${rootfspart}
}

check_images

umount ${node}${part}*  2> /dev/null || true

delete_device
create_parts
format_rootfs_part
install_rootfs

if [ "$is_dart" = true ] ; then
	format_boot_part
	install_bootloader
	install_kernel
fi

exit 0
