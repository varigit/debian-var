readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2019.04_4.19.35_1.1.0-var01"
readonly G_UBOOT_REV="3e1643239fb11297209254dbaa803425cf0c1702"
G_UBOOT_DEF_CONFIG_MMC="imx8mm_var_dart_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_4.19.35_1.1.0_var01"
readonly G_LINUX_KERNEL_REV="fc07d4d69ee46672b276bc4dbed74e4970debdf6"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/fsl-imx8mm-var-dart.dtb
	freescale/fsl-imx8mm-var-dart-m4.dtb
	freescale/fsl-imx8mm-var-som.dtb
	freescale/fsl-imx8mm-var-som-m4.dtb
	freescale/fsl-imx8mm-var-som-rev10.dtb
	freescale/fsl-imx8mm-var-som-rev10-m4.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="7.0.0.142"
readonly G_BCM_FW_GIT_REV="7080491e10b82661ca4a67237fdb361190775d2f"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.0.p1.0"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.2.4.p4.0"
readonly GST_MM_VERSION="MM_04.05.01_1909_L4.19.35"
readonly G2D_PACKAGE_DIR="imx-gpu-g2d-6.4.0.p1.0"
readonly IMX_FIRMWARE_VERSION="8.5"
readonly WESTON_PACKAGE_DIR="imx8m-vivante-g2d"

readonly G_IMX_CODEC_DIR="imxcodec-4.5.1"
readonly G_IMX_PARSER_DIR="imxparser-4.5.1"
readonly G_IMX_VPU_HANTRO_DIR="imxvpuhantro-1.15.0"
readonly G_IMX_VPU_WRAPPER_DIR="imxvpuwrap-4.5.1"

#Have custom OpenCV build
readonly G_OPENCV_DIR="opencv"

IMXGSTPLG="imx-gst1.0-plugin-mx8mm"
G2DPACKAGE="imx-gpu-g2d"

# Flashing variables
BOOTLOADER_OFFSET=33

BOOT_DTB="fsl-imx8mm-var-dart.dtb"
DEFAULT_BOOT_DTB="fsl-imx8mm-var-dart.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="git://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_4.19.35_1.1.0"
readonly G_IMXBOOT_REV="1c2277b95ce59f5d0265f26fec522e2ac2581e59"
HDMI=no
TEE_LOAD_ADDR=0xbe000000
ATF_LOAD_ADDR=0x00920000
UBOOT_DTB="fsl-imx8mm-var-dart.dtb"
UBOOT_DTB_EXTRA="fsl-imx8mm-var-som.dtb"
UBOOT_DTB_EXTRA2="fsl-imx8mm-var-som-rev10.dtb"
IMXBOOT_TARGETS="flash_lpddr4_ddr4_evk"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mm.bin"
