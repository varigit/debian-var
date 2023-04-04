readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2019.04_4.19.35_1.1.0-var01"
readonly G_UBOOT_REV="2467eac7a0e55ee52683e62d6cc9c032a360d9bc"
G_UBOOT_DEF_CONFIG_MMC="imx8mq_var_dart_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'
readonly G_UBOOT_NAME_FOR_EMMC_DP='imx-boot-sd-dp.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_4.19.35_1.1.0_var01"
readonly G_LINUX_KERNEL_REV="802a7d1135164e0a0ee4b53861ea7b36f58c1cf8"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/fsl-imx8mq-var-dart-sd-dp.dtb	
	freescale/fsl-imx8mq-var-dart-sd-hdmi.dtb	
	freescale/fsl-imx8mq-var-dart-sd-lvds.dtb	
	freescale/fsl-imx8mq-var-dart-sd-lvds-dp.dtb 
	freescale/fsl-imx8mq-var-dart-sd-lvds-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-sd-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-sd-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-sd-lvds-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-wifi-dp.dtb
	freescale/fsl-imx8mq-var-dart-wifi-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-wifi-lvds.dtb
	freescale/fsl-imx8mq-var-dart-wifi-lvds-dp.dtb
	freescale/fsl-imx8mq-var-dart-wifi-lvds-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-wifi-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-wifi-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-wifi-lvds-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-dp.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-lvds.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-lvds-dp.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-lvds-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-sd-lvds-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-dp.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-lvds.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-lvds-dp.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-lvds-hdmi.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-hdmi-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-lvds-cb12.dtb
	freescale/fsl-imx8mq-var-dart-m4-wifi-lvds-hdmi-cb12.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="8.2.0.16"
readonly G_BCM_FW_GIT_REV="8081cd2bddb1569abe91eb50bd687a2066a33342"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.0.p1.0"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.2.4.p4.0"
readonly GST_MM_VERSION="MM_04.05.01_1909_L4.19.35"
readonly IMX_FIRMWARE_VERSION="8.5"
readonly WESTON_PACKAGE_DIR="imx8mq-vivante"

readonly G_IMX_CODEC_DIR="imxcodec-4.5.1"
readonly G_IMX_PARSER_DIR="imxparser-4.5.1"
readonly G_IMX_VPU_HANTRO_DIR="imxvpuhantro-1.15.0"
readonly G_IMX_VPU_WRAPPER_DIR="imxvpuwrap-4.5.1"

#Have custom OpenCV build
readonly G_OPENCV_DIR="opencv"

IMXGSTPLG="imx-gst1.0-plugin-mx8mq"

# Flashing variables
BOOTLOADER_OFFSET=33

BOOT_DTB="fsl-imx8mq-var-dart.dtb"
DEFAULT_BOOT_DTB="fsl-imx8mq-var-dart-sd-lvds.dtb"

BOOT_DTB2="fsl-imx8mq-var-dart-cb12.dtb"
DEFAULT_BOOT_DTB2="fsl-imx8mq-var-dart-sd-lvds-cb12.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="https://github.com/nxp-imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_4.19.35_1.1.0"
readonly G_IMXBOOT_REV="1c2277b95ce59f5d0265f26fec522e2ac2581e59"

#imx-atf
readonly G_IMX_ATF_SRC_DIR="${DEF_SRC_DIR}/imx-atf"
readonly G_IMX_ATF_GIT="https://source.codeaurora.org/external/imx/imx-atf"
readonly G_IMX_ATF_BRANCH="imx_4.19.35_1.1.0"
readonly G_IMX_ATF_REV="70fa7bcc1a2035ab8402550911b3ae29eff55371"

HDMI=yes
SPL_LOAD_ADDR=0x7E1000
TEE_LOAD_ADDR=0xfe000000
ATF_LOAD_ADDR=0x00910000
UBOOT_DTB="fsl-imx8mq-var-dart.dtb"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mq.bin"
