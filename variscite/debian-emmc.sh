#!/bin/bash
#
# Flash Debian into eMMC for DART-MX6UL & VAR-SOM-6UL
#

# Partitions sizes in MiB
BOOTLOAD_RESERVE=4
BOOT_ROM_SIZE=8
SPARE_SIZE=0

echo "================================"
echo " Variscite DART-6UL/VAR-SOM-6UL"
echo "   Installing Debian to eMMC"
echo "================================"

cd /opt/images/Debian
if [ ! -f SPL.mmc ]
then
	echo "SPL does not exist! exit."
	exit 1
fi	
if [ ! -f u-boot.img.mmc ]
then
	echo "u-boot.img does not exist! exit."
	exit 1
fi	


help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h			displays this help message
  -s			only get partition size
EOF

}

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with super-user privileges" 
	exit 1
fi

# Parse command line
moreoptions=1
node="/dev/mmcblk1"
part=p
cal_only=0

if [ ! -e ${node} ]; then
	help
	exit
fi

function format_debian
{
	echo "Formating Debian partitions"
	echo "=========================="
	umount /run/media/mmcblk1p1 2>/dev/null
	umount /run/media/mmcblk1p2 2>/dev/null
	mkfs.vfat ${node}p1 -nBOOT-VARSOM
	mkfs.ext4 ${node}p2 -Lrootfs
	sync
}

function flash_debian
{
	echo "Flashing Debian "
	echo "==============="

	echo "Flashing U-Boot"
	dd if=u-boot.img.mmc of=${node} bs=1K seek=69; sync
	dd if=SPL.mmc of=${node} bs=1K seek=1; sync

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

	echo "Flashing Debian BOOT partition"
	mkdir -p /tmp/media/mmcblk1p1
	mkdir -p /tmp/media/mmcblk1p2
	mount -t vfat ${node}p1  /tmp/media/mmcblk1p1
	mount ${node}p2  /tmp/media/mmcblk1p2

	cp ${soc}-${som}-${carrier}-emmc-*.dtb /tmp/media/mmcblk1p1/
	cp zImage /tmp/media/mmcblk1p1/

	echo "Flashing Debian Root File System"
	rm -rf /tmp/media/mmcblk1p2/*
	printf "Extracting files"
	tar --warning=no-timestamp -xpf rootfs.tar.gz -C /tmp/media/mmcblk1p2/ --checkpoint=.1200
	echo
}


# umount /run/media/mmcblk1p* 2>/dev/null

echo
echo "Deleting the current partitions"

for ((i=0; i<10; i++))
do
	if [ `ls ${node}${part}$i 2> /dev/null | grep -c ${node}${part}$i` -ne 0 ]; then
		dd if=/dev/zero of=${node}${part}$i bs=512 count=1024
	fi
done
sync

((echo d; echo 1; echo d; echo 2; echo d; echo 3; echo d; echo w) | fdisk ${node} &> /dev/null) || true
sync

dd if=/dev/zero of=${node} bs=1024 count=4096
sync

echo
echo "Creating new partitions"
# Create a new partition table
fdisk ${node} <<EOF 
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

# Get total card size
total_size=`sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
rootfs_size=`expr ${total_size} - ${boot_rom_sizeb} - ${SPARE_SIZE}`

echo "ROOT SIZE=${rootfs_size} TOTAl SIZE=${total_size} BOOTROM SIZE=${boot_rom_sizeb}"
echo "======================================================"
# create partitions 
#if [ "${cal_only}" -eq "1" ]; then
#cat << EOF
#BOOT   : ${boot_rom_sizeb}MiB
#ROOT   : ${rootfs_size}MiB
#EOF
#exit
#fi

#sfdisk --force -uM ${node} << EOF
#,${boot_rom_sizeb},c
#,${rootfs_size},83
#EOF

# adjust the partition reserve for bootloader.
# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
# to have 8M space.
# the minimal sylinder for some card is 4M, maybe some was 8M
# just 8M for some big eMMC 's sylinder
#sfdisk --force -uM ${node} -N1 << EOF
#${BOOTLOAD_RESERVE},${BOOT_ROM_SIZE},c
#EOF

sync
sleep 2

format_debian
flash_debian

echo "syncing"
sync
umount /tmp/media/mmcblk1p1
umount /tmp/media/mmcblk1p2

read -p "Debian Flashed. Press any key to continue... " -n1
