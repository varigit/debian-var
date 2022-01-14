readonly ARCH_CPU="32BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2018.03_4.14.78_1.0.0_ga_var02"
readonly G_UBOOT_REV="32670c4e21bf8d1de08e1d1b1f9bfe42c23bc6af"
readonly G_UBOOT_DEF_CONFIG_MMC='mx6ul_var_dart_mmc_defconfig'
readonly G_UBOOT_DEF_CONFIG_NAND='mx6ul_var_dart_nand_defconfig'
readonly G_UBOOT_NAME_FOR_EMMC='u-boot.img.mmc'
readonly G_SPL_NAME_FOR_EMMC='SPL.mmc'
readonly G_UBOOT_NAME_FOR_NAND='u-boot.img.nand'
readonly G_SPL_NAME_FOR_NAND='SPL.nand'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="5.4-2.1.x-imx_var01"
readonly G_LINUX_KERNEL_REV="5227ff0e2a5ca08777d926a440244975ffb0d095"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx_v7_var_defconfig'
G_LINUX_DTB="imx6ull-var-dart-6ulcustomboard-emmc-sd-card.dtb
	imx6ull-var-dart-6ulcustomboard-emmc-wifi.dtb
	imx6ull-var-dart-6ulcustomboard-nand-sd-card.dtb
	imx6ull-var-dart-6ulcustomboard-nand-wifi.dtb
	imx6ull-var-som-concerto-board-emmc-sd-card.dtb
	imx6ull-var-som-concerto-board-emmc-wifi.dtb
	imx6ull-var-som-concerto-board-nand-sd-card.dtb
	imx6ull-var-som-concerto-board-nand-wifi.dtb
	imx6ull-var-som-symphony-board-emmc-sd-card.dtb
	imx6ull-var-som-symphony-board-emmc-wifi.dtb
	imx6ull-var-som-symphony-board-nand-sd-card.dtb
	imx6ull-var-som-symphony-board-nand-wifi.dtb
	imx6ul-var-dart-6ulcustomboard-emmc-sd-card.dtb
	imx6ul-var-dart-6ulcustomboard-emmc-wifi.dtb
	imx6ul-var-dart-6ulcustomboard-nand-sd-card.dtb
	imx6ul-var-dart-6ulcustomboard-nand-wifi.dtb
	imx6ul-var-som-concerto-board-emmc-sd-card.dtb
	imx6ul-var-som-concerto-board-emmc-wifi.dtb
	imx6ul-var-som-concerto-board-nand-sd-card.dtb
	imx6ul-var-som-concerto-board-nand-wifi.dtb
	imx6ul-var-som-symphony-board-emmc-sd-card.dtb
	imx6ul-var-som-symphony-board-emmc-wifi.dtb
	imx6ul-var-som-symphony-board-nand-sd-card.dtb
	imx6ul-var-som-symphony-board-nand-wifi.dtb
	imx6ulz-var-dart-6ulcustomboard-emmc-sd-card.dtb
	imx6ulz-var-dart-6ulcustomboard-emmc-wifi.dtb
	imx6ulz-var-dart-6ulcustomboard-nand-sd-card.dtb
	imx6ulz-var-dart-6ulcustomboard-nand-wifi.dtb
	imx6ulz-var-som-concerto-board-emmc-sd-card.dtb
	imx6ulz-var-som-concerto-board-emmc-wifi.dtb
	imx6ulz-var-som-concerto-board-nand-sd-card.dtb
	imx6ulz-var-som-concerto-board-nand-wifi.dtb
	imx6ulz-var-som-symphony-board-emmc-sd-card.dtb
	imx6ulz-var-som-symphony-board-emmc-wifi.dtb
	imx6ulz-var-som-symphony-board-nand-sd-card.dtb
	imx6ulz-var-som-symphony-board-nand-wifi.dtb"

BUILD_IMAGE_TYPE="zImage"
KERNEL_BOOT_IMAGE_SRC="arch/arm/boot/"
KERNEL_DTB_IMAGE_PATH="arch/arm/boot/dts/"

# SDMA Firmware
readonly G_IMX_SDMA_FW_SRC_DIR="${DEF_SRC_DIR}/linux-firmware"
readonly G_IMX_SDMA_FW_GIT="git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
readonly G_IMX_SDMA_FW_GIT_BRANCH="main"
readonly G_IMX_SDMA_FW_GIT_REV="d79c26779d459063b8052b7fe0a48bce4e08d0d9"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="8.2.0.16"
readonly G_BCM_FW_GIT_REV="8081cd2bddb1569abe91eb50bd687a2066a33342"

# ubi
readonly G_UBI_FILE_NAME='rootfs.ubi.img'

# default mirror
readonly DEF_DEBIAN_MIRROR="https://snapshot.debian.org/archive/debian/20210813T203009Z/"
