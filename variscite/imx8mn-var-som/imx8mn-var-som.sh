readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2020.04_5.4.24_2.1.0_var02"
readonly G_UBOOT_REV="48cabcbc64484ca6c201746e526a11b4b43eb359"
G_UBOOT_DEF_CONFIG_MMC="imx8mn_var_som_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="5.4-2.1.x-imx_var01"
readonly G_LINUX_KERNEL_REV="9f39ab0f3ee3a8ef518a07b6c2db847fb5ff4037"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/imx8mn-var-som-symphony.dtb
	freescale/imx8mn-var-som-symphony-root.dtb
	freescale/imx8mn-var-som-symphony-m7.dtb
	freescale/imx8mn-var-som-symphony-legacy.dtb
	freescale/imx8mn-var-som-symphony-legacy-root.dtb
	freescale/imx8mn-var-som-symphony-legacy-m7.dtb
	freescale/imx8mn-var-som-inmate.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="8.2.0.16"
readonly G_BCM_FW_GIT_REV="8081cd2bddb1569abe91eb50bd687a2066a33342"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.0.p2.4"
readonly G_GPU_IMX_VIV_GBM_DIR="libgbm1"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.4.0.p2.0"
readonly GST_MM_VERSION="MM_04.05.03_1911_L5.4.0"

readonly G2D_PACKAGE_DIR="imx-gpu-g2d-6.4.0.p2.0"
readonly IMX_FIRMWARE_VERSION="8.5"
readonly WESTON_PACKAGE_DIR="imx8m-vivante-g2d"

G2DPACKAGE="imx-gpu-g2d"

readonly G_GST_EXTRA_PLUGINS="gstreamer1.0-libav"
readonly G_SW_ENCODER_DECODERS="x265 x264"
readonly G_SW_GST_CODEC_DIR="gstreamer-libav"

# Flashing variables
BOOTLOADER_OFFSET=32

BOOT_DTB="imx8mn-var-som.dtb"
DEFAULT_BOOT_DTB="imx8mn-var-som.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="git://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_5.4.24_2.1.0"
readonly G_IMXBOOT_REV="6745ccdcf15384891639b7ced3aa6ce938682365"

#imx-atf
readonly G_IMX_ATF_SRC_DIR="${DEF_SRC_DIR}/imx-atf"
readonly G_IMX_ATF_GIT="git://github.com/varigit/imx-atf.git"
readonly G_IMX_ATF_BRANCH="imx_5.4.24_2.1.0_var01"
readonly G_IMX_ATF_REV="7575633e03ff952a18c0a2c0aa543dee793fda5f"

HDMI=no
UBOOT_DTB="imx8mn-var-som-symphony.dtb"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mn.bin"
IMXBOOT_TARGETS="flash_ddr4_evk"

#rootfs package group control
#Default compilation of rootfs (Console Base + Multimedia + Graphics)
#set package group below from G_DEBIAN_DISTRO_FEATURE_XX="n" to disable it

#Multimedia - GStreamer Packages - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_MM="y"

#Graphics - Full Graphics and GPU SDK - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_GRAPHICS="y"
