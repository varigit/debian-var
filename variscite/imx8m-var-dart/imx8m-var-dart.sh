## LINUX kernel: git, config, paths and etc
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_4.14.78_1.0.0_ga_var01"
readonly G_LINUX_KERNEL_REV="46154327d2f77467428d2263030506fb2c8fb077"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/fsl-imx8mq-var-dart-sd-emmc-lvds.dtb
	freescale/fsl-imx8mq-var-dart-sd-emmc-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-sd-emmc-dual-display.dtb
	freescale/fsl-imx8mq-var-dart-emmc-wifi-lvds.dtb
	freescale/fsl-imx8mq-var-dart-emmc-wifi-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-emmc-wifi-dual-display.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-emmc-lvds.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-emmc-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-emmc-dual-display.dtb
	freescale/fsl-imx8mq-var-dart-m4-emmc-wifi-lvds.dtb
	freescale/fsl-imx8mq-var-dart-m4-emmc-wifi-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-m4-emmc-wifi-dual-display.dtb
	freescale/fsl-imx8mq-var-dart-sd-emmc-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-sd-emmc-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-sd-emmc-dual-display-cb12.dtb
	freescale/fsl-imx8mq-var-dart-emmc-wifi-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-emmc-wifi-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-emmc-wifi-dual-display-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-emmc-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-emmc-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-emmc-dual-display-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-emmc-wifi-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-emmc-wifi-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-emmc-wifi-dual-display-cb12.dtb"

## uboot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2018.03_4.14.78_1.0.0_ga_var01"
readonly G_UBOOT_REV="0e734b6c1c83aa80ade185471ef0aee5bc11c8b0"
G_UBOOT_DEF_CONFIG_MMC="imx8m_var_dart_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

## Broadcom BT/WIFI firmware ##
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="6.0.0.121"
readonly G_BCM_FW_GIT_REV="7bce9b69b51ffd967176c1597feed79305927370"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.2.4.p2.3"
readonly GST_MM_VERSION="MM_04.04.04_1811_L4.14.78_GA"
readonly IMX_FIRMWARE_VERSION="8.0"
readonly WESTON_PACKAGE_DIR="imx8mq-vivante"

IMXGSTPLG="imx-gst1.0-plugin-mx8mq"
##Flashing Variables
BOOTLOADER_OFFSET=33

BOOT_DTB="fsl-imx8mq-var-dart.dtb"
DEFAULT_BOOT_DTB="fsl-imx8mq-var-dart-sd-emmc-lvds.dtb"

BOOT_DTB2="fsl-imx8mq-var-dart-cb12.dtb"
DEFAULT_BOOT_DTB2="fsl-imx8mq-var-dart-sd-emmc-lvds-cb12.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="git://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_4.14.78_1.0.0_ga"
readonly G_IMXBOOT_REV="2cf091c075ea1950afa22a56e224dc4e448db542"
HDMI=yes
TEE_LOAD_ADDR=0xfe000000
ATF_LOAD_ADDR=0x00910000
UBOOT_DTB="fsl-imx8mq-var-dart.dtb"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mq.bin"
