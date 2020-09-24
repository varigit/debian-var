readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="lf-5.4.y_v2019.04_var01"
readonly G_UBOOT_REV="74c22e7054d00f8fd8ac8b00ab89e5c0e0a50f7f"
G_UBOOT_DEF_CONFIG_MMC="imx8mm_var_dart_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="lf-5.4.y_var01"
readonly G_LINUX_KERNEL_REV="050b21f4b39414cc928c5e0537c51e08c80497b8"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/imx8mm-var-dart.dtb
       freescale/imx8mm-var-som.dtb
       freescale/imx8mm-var-som-rev10.dtb
       freescale/imx8mm-var-dart-m4.dtb
       freescale/imx8mm-var-som-m4.dtb
       freescale/imx8mm-var-som-rev10-m4.dtb
       "
# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="7.0.0.142"
readonly G_BCM_FW_GIT_REV="7080491e10b82661ca4a67237fdb361190775d2f"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.0.p2.0"
readonly G_GPU_IMX_VIV_GBM_DIR="libgbm1"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.4.0.p2.0"
readonly GST_MM_VERSION="MM_04.05.03_1911_L5.4.0"
readonly G2D_PACKAGE_DIR="imx-gpu-g2d-6.4.0.p2.0"
readonly IMX_FIRMWARE_VERSION="8.5"
readonly WESTON_PACKAGE_DIR="imx8m-vivante-g2d"

readonly G_IMX_CODEC_DIR="imxcodec-4.5.3"
readonly G_IMX_PARSER_DIR="imxparser-4.5.3"
readonly G_IMX_VPU_HANTRO_DIR="imxvpuhantro-1.16.0"
readonly G_IMX_VPU_WRAPPER_DIR="imxvpuwrap-4.5.3"

IMXGSTPLG="imx-gst1.0-plugin-mx8mm"
G2DPACKAGE="imx-gpu-g2d"

# Flashing variables
BOOTLOADER_OFFSET=33

BOOT_DTB="fsl-imx8mm-var-dart.dtb"
DEFAULT_BOOT_DTB="fsl-imx8mm-var-dart.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="git://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="lf-5.4.y"
readonly G_IMXBOOT_REV="1c2277b95ce59f5d0265f26fec522e2ac2581e59"
HDMI=no
TEE_LOAD_ADDR=0xbe000000
ATF_LOAD_ADDR=0x00920000
UBOOT_DTB="fsl-imx8mm-var-dart.dtb"
UBOOT_DTB_EXTRA="fsl-imx8mm-var-som.dtb"
UBOOT_DTB_EXTRA2="fsl-imx8mm-var-som-rev10.dtb"
IMXBOOT_TARGETS="flash_lpddr4_ddr4_evk"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mm.bin"
