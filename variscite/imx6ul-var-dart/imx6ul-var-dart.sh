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
readonly G_LINUX_KERNEL_REV="601330bfa4d56345159cb571f90b0e19adebb1fd"
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
readonly G_IMX_SDMA_FW_GIT_BRANCH="master"
readonly G_IMX_SDMA_FW_GIT_REV="710963fe53ee3f227556d36839df3858daf6e232"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="6.0.0.121"
readonly G_BCM_FW_GIT_REV="7bce9b69b51ffd967176c1597feed79305927370"

# ubi
readonly G_UBI_FILE_NAME='rootfs.ubi.img'
