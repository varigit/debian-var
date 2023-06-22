readonly ARCH_CPU="64BIT"

# SOC
readonly SOC="mx93"
readonly SOC_SERIES="imx9"
readonly SOC_FAMILY="imx93"

#64 bit CROSS_COMPILER config and paths
readonly G_CROSS_COMPILER_64BIT_NAME="arm-gnu-toolchain-12.2.rel1-x86_64-aarch64-none-linux-gnu"
readonly G_CROSS_COMPILER_ARCHIVE_64BIT="${G_CROSS_COMPILER_64BIT_NAME}.tar.xz"
readonly G_EXT_CROSS_64BIT_COMPILER_LINK="https://developer.arm.com/-/media/Files/downloads/gnu/12.2.rel1/binrel/${G_CROSS_COMPILER_ARCHIVE_64BIT}"
readonly G_CROSS_COMPILER_64BIT_PREFIX="aarch64-none-linux-gnu-"
readonly G_CROSS_COMPILER_64BIT_PATH="${G_TOOLS_PATH}/${G_CROSS_COMPILER_64BIT_NAME}/bin"

# GIT repositories to fetch
git_repos=(
	"G_UBOOT"
	"G_LINUX_KERNEL"
	"G_IMX_ATF"
	"G_IMXBOOT"
	"G_ETHOSU_FIRMWARE"
	"G_META_VARISCITE_BSP"
)

# meta-variscite-bsp
readonly G_META_VARISCITE_BSP_SRC_DIR="${DEF_SRC_DIR}/meta-variscite-bsp"
readonly G_META_VARISCITE_BSP_GIT="https://github.com/varigit/meta-variscite-bsp"
readonly G_META_VARISCITE_BSP_BRANCH="langdale-var01"
readonly G_META_VARISCITE_BSP_REV="2713315693f3b4339a6ec27299a18de3a1604b95"

#imx-atf
readonly G_IMX_ATF_SRC_DIR="${DEF_SRC_DIR}/imx-atf"
readonly G_IMX_ATF_GIT="https://github.com/varigit/imx-atf.git"
readonly G_IMX_ATF_BRANCH="lf_v2.6_var03"
readonly G_IMX_ATF_REV="f21a37b137fd9e85d03cf44f2c2540356dd52fd9"

# imx-mkimage
readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="https://github.com/nxp-imx/imx-mkimage.git"
readonly G_IMXBOOT_BRANCH="lf-6.1.1_1.0.0"
readonly G_IMXBOOT_REV="d489494622585a47b4be88988595b0e4f9598f39"

# Flashing variables
readonly BOOTLOADER_OFFSET=32
readonly UBOOT_DTB="imx93-var-som-symphony.dtb"
readonly IMXBOOT_TARGETS="flash_singleboot"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="lf_v2022.04_var03"
readonly G_UBOOT_REV="8ca7ec9603abcf4254c92f4130ef4786e2b43bd6"
readonly G_UBOOT_DEF_CONFIG_MMC="imx93_var_som_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'
readonly UBOOT_FW_UTILS_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-bsp/u-boot/u-boot-fw-utils/${MACHINE}"

# Linux kernel
readonly KERNEL_IMAGE_TYPE="Image.gz"
readonly KERNEL_BOOT_IMAGE_SRC="arch/arm64/boot/"
readonly KERNEL_DTB_IMAGE_PATH="arch/arm64/boot/dts/freescale/"
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="lf-6.1.y_var01"
readonly G_LINUX_KERNEL_REV="5f3e208e5a7509fb3370584b8830dd2aff2f1811"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
readonly G_LINUX_DTB="freescale/imx93-var-som-symphony.dtb"

# Broadcom BT/WIFI firmware
readonly G_BRCM_FW_SRC_DIR="${DEF_SRC_DIR}/brcmfw"
readonly G_BRCM_FW_REV="10.54.0.13"
readonly MODEL_LIST="${MACHINE}"
readonly G_BRCM_LWB_FW_ARCHIVE="laird-lwb-fcc-firmware-${G_BRCM_FW_REV}.tar.bz2"
readonly G_BRCM_LWB_FW_LINK="https://github.com/LairdCP/Sterling-LWB-and-LWB5-Release-Packages/releases/download/LRD-REL-${G_BRCM_FW_REV}/${G_BRCM_LWB_FW_ARCHIVE}"
readonly G_BRCM_LWB_FW_SHA256SUM="8faa105e036a9f8bffe2857f5d9f5ce539521ef8624b59069290579440228ac5"
readonly G_BRCM_LWB5_FW_ARCHIVE="laird-lwb5-fcc-firmware-${G_BRCM_FW_REV}.tar.bz2"
readonly G_BRCM_LWB5_FW_LINK="https://github.com/LairdCP/Sterling-LWB-and-LWB5-Release-Packages/releases/download/LRD-REL-${G_BRCM_FW_REV}/${G_BRCM_LWB5_FW_ARCHIVE}"
readonly G_BRCM_LWB5_FW_SHA256SUM="583e2b328a185f545e1c5de55acaf3ae092cdbc791a62ff005c5559515488f7f"

#ethos-u-firmware
readonly G_ETHOSU_FIRMWARE_SRC_DIR="${DEF_SRC_DIR}/ethosu_firmware"
readonly G_ETHOSU_FIRMWARE_GIT="https://github.com/varigit/ethos-u-firmware.git"
readonly G_ETHOSU_FIRMWARE_BRANCH="lf-5.15.71_2.2.0_var01"
readonly G_ETHOSU_FIRMWARE_REV="3265ff6bfe2ff3e9e6dbbb6c4d8fec73560946ed"

# pm utils
readonly PM_UTILS_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-bsp/pm-utils/pm-utils"

# BRCM Utils
readonly BRCM_UTILS_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-connectivity/bcm43xx-utils/bcm43xx-utils"

# BlueZ
readonly BLUEZ5_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-connectivity/bluez5/files"

# default mirror
readonly DEF_DEBIAN_MIRROR="https://snapshot.debian.org/archive/debian/20230611T210420Z/"

#rootfs package group control
#Default compilation of rootfs (Console Base + Multimedia + Graphics)
#set package group below from G_DEBIAN_DISTRO_FEATURE_XX="n" to disable it

#Multimedia - GStreamer Packages - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_MM="y"

#Graphics - Full Graphics and GPU SDK - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_GRAPHICS="y"
