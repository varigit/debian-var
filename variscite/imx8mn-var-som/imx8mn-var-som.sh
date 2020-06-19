readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2018.03_4.14.98_2.3.0_var01"
readonly G_UBOOT_REV="bbbda1b68065082ca76f95a6c41618a61615e422"
G_UBOOT_DEF_CONFIG_MMC="imx8mn_var_som_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_4.14.98_2.3.0_var01"
readonly G_LINUX_KERNEL_REV="f54b007d1548fdbf9c1fd7c2df3580c16e5cb7dd"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/fsl-imx8mn-var-som.dtb
	freescale/fsl-imx8mn-var-som-m7.dtb
	freescale/fsl-imx8mn-var-som-rev10.dtb
	freescale/fsl-imx8mn-var-som-rev10-m7.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="7.0.0.142"
readonly G_BCM_FW_GIT_REV="7080491e10b82661ca4a67237fdb361190775d2f"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.2.4.p4.0"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.2.4.p4.0"
readonly GST_MM_VERSION="MM_04.04.05_1902_L4.14.98_GA"
readonly G_GST_EXTRA_PLUGINS="gstreamer1.0-libav"
readonly G_SW_ENCODER_DECODERS="x265 x264"

# Install specific version of bad plugins for imx8mn
readonly G_GST_PLUGINS_BAD_VERSION="MM_04.05.02_1911_L4.14.98"
readonly G_GST_PLUGINS_GOOD_VERSION="MM_04.05.02_1911_L4.14.98"
readonly IMX_FIRMWARE_VERSION="8.0"
readonly WESTON_PACKAGE_DIR="imx8mq-vivante"

IMXGSTPLG="imx-gst1.0-plugin-mx8x"

# Flashing variables
BOOTLOADER_OFFSET=32

BOOT_DTB="fsl-imx8mn-var-som.dtb"
DEFAULT_BOOT_DTB="fsl-imx8mn-var-som.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="git://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_4.14.98_2.3.0"
readonly G_IMXBOOT_REV="d7f9440dd5c050cc22cb362d53d4048e689a0c01"
HDMI=no
UBOOT_DTB="fsl-imx8mn-var-som.dtb"
UBOOT_DTB_EXTRA="fsl-imx8mn-var-som-rev10.dtb"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mn.bin"
