readonly ARCH_CPU="64BIT"

# SOC
readonly SOC="am62"
readonly SOC_SERIES="am6"
readonly SOC_FAMILY="am6"

#32 bit CROSS_COMPILER config and paths
readonly G_CROSS_COMPILER_32BIT_NAME="gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf"
readonly G_CROSS_COMPILER_ARCHIVE_32BIT="${G_CROSS_COMPILER_32BIT_NAME}.tar.xz"
readonly G_EXT_CROSS_32BIT_COMPILER_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/${G_CROSS_COMPILER_ARCHIVE_32BIT}"
readonly G_CROSS_COMPILER_32BIT_PREFIX="arm-none-linux-gnueabihf-"
readonly G_CROSS_COMPILER_32BIT_PATH="${G_TOOLS_PATH}/${G_CROSS_COMPILER_32BIT_NAME}/bin"

#64 bit CROSS_COMPILER config and paths
readonly G_CROSS_COMPILER_64BIT_NAME="gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu"
readonly G_CROSS_COMPILER_ARCHIVE_64BIT="${G_CROSS_COMPILER_64BIT_NAME}.tar.xz"
readonly G_EXT_CROSS_64BIT_COMPILER_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/${G_CROSS_COMPILER_ARCHIVE_64BIT}"
readonly G_CROSS_COMPILER_64BIT_PREFIX="aarch64-none-linux-gnu-"
readonly G_CROSS_COMPILER_64BIT_PATH="${G_TOOLS_PATH}/${G_CROSS_COMPILER_64BIT_NAME}/bin"

git_repos=(
	"G_CORE_SECDEV_K3"
	"G_CORE_K3_IMAGE_GEN"
	"G_CORE_LINUX_FIRMWARE"
	"G_ATF"
	"G_OPTEE"
	"G_UBOOT"
	"G_LINUX_KERNEL"
	"G_TI_IMG_ROGUE_DRV"
	"G_META_VARISCITE_BSP"
	"G_META_VARISCITE_SDK"
)

# meta-variscite-bsp-ti
readonly G_META_VARISCITE_BSP_SRC_DIR="${DEF_SRC_DIR}/meta-variscite-bsp-ti"
readonly G_META_VARISCITE_BSP_GIT="https://github.com/varigit/meta-variscite-bsp-ti"
readonly G_META_VARISCITE_BSP_BRANCH="dunfell_var01"
readonly G_META_VARISCITE_BSP_REV="a9b9e8057609ceb1bf5de0e8c41783873f15c60e"

# meta-variscite-sdk-ti
readonly G_META_VARISCITE_SDK_SRC_DIR="${DEF_SRC_DIR}/meta-variscite-sdk-ti"
readonly G_META_VARISCITE_SDK_GIT="https://github.com/varigit/meta-variscite-sdk-ti"
readonly G_META_VARISCITE_SDK_BRANCH="dunfell_var01"
readonly G_META_VARISCITE_SDK_REV="dd29a7ed1948c3fdec9194c068fc1b526fcc9614"

# core-secdev-k3 Security Dev Tool
readonly G_CORE_SECDEV_K3_SRC_DIR="${DEF_SRC_DIR}/core-secdev-k3"
readonly G_CORE_SECDEV_K3_GIT="https://git.ti.com/git/security-development-tools/core-secdev-k3"
readonly G_CORE_SECDEV_K3_BRANCH="master"
readonly G_CORE_SECDEV_K3_REV="bba9cabaeee96f7f287385188ff289b46769a4bf"

# ti-k3-image-gen:
readonly G_CORE_K3_IMAGE_GEN_SRC_DIR="${DEF_SRC_DIR}/k3-image-gen"
readonly G_CORE_K3_IMAGE_GEN_GIT="https://git.ti.com/git/k3-image-gen/k3-image-gen"
readonly G_CORE_K3_IMAGE_GEN_BRANCH="master"
readonly G_CORE_K3_IMAGE_GEN_REV="ffae8800a5c81c149835ed1aa5e2fbbe65a49c0d"

# ti-linux-firmware:
readonly G_CORE_LINUX_FIRMWARE_SRC_DIR="${DEF_SRC_DIR}/ti-linux-firmware"
readonly G_CORE_LINUX_FIRMWARE_GIT="https://git.ti.com/git/processor-firmware/ti-linux-firmware"
readonly G_CORE_LINUX_FIRMWARE_BRANCH="master"
readonly G_CORE_LINUX_FIRMWARE_REV="2944354aca1f95525c30d625cb17672930e72572"

# ATF:
readonly G_ATF_SRC_DIR="${DEF_SRC_DIR}/trusted-firmware-a"
readonly G_ATF_GIT="https://git.trustedfirmware.org/TF-A/trusted-firmware-a"
readonly G_ATF_BRANCH="master"
readonly G_ATF_REV="2fcd408bb3a6756767a43c073c597cef06e7f2d5"

# optee-os:
readonly G_OPTEE_SRC_DIR="${DEF_SRC_DIR}/optee_os"
readonly G_OPTEE_GIT="https://github.com/OP-TEE/optee_os"
readonly G_OPTEE_BRANCH="master"
readonly G_OPTEE_REV="8e74d47616a20eaa23ca692f4bbbf917a236ed94"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/ti-u-boot.git"
readonly G_UBOOT_BRANCH="ti-u-boot-2021.01_var01"
readonly G_UBOOT_REV="277c2dd356d8ec77d7a776c420cf9d87f4e65ff1"
readonly G_UBOOT_DEF_CONFIG_R="am62x_var_som_r5_defconfig"
readonly G_UBOOT_DEF_CONFIG_A="am62x_var_som_a53_defconfig"
readonly UBOOT_FW_UTILS_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-bsp/u-boot/u-boot-variscite/${MACHINE}/"

# Linux kernel
readonly KERNEL_IMAGE_TYPE="Image"
readonly KERNEL_BOOT_IMAGE_SRC="arch/arm64/boot/"
readonly KERNEL_DTB_IMAGE_PATH="arch/arm64/boot/dts/ti/"
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/ti-linux-kernel.git"
readonly G_LINUX_KERNEL_BRANCH="ti-linux-5.10.y_var01"
readonly G_LINUX_KERNEL_REV="2d58bcd882abfb558eb5269de1c54245525c590f"
readonly G_LINUX_KERNEL_DEF_CONFIG='am62x_var_defconfig'
readonly G_LINUX_DTB="ti/k3-am625-var-som-symphony.dtb"

# PowerVR Rogue GPU
readonly G_TI_IMG_ROGUE_DRV_SRC_DIR="${DEF_SRC_DIR}/ti-img-rogue-driver"
readonly G_TI_IMG_ROGUE_DRV_GIT="https://git.ti.com/git/graphics/ti-img-rogue-driver "
readonly G_TI_IMG_ROGUE_DRV_BRANCH="linuxws/dunfell/k5.10/1.15.6133109_unified_fw_pagesize"
readonly G_TI_IMG_ROGUE_DRV_REV="1dd6291a5cad4f2b909fc2a14bd717a3bc5f0bb2"

# BRCM Utils
readonly BRCM_UTILS_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-connectivity/bcm43xx-utils/bcm43xx-utils"

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

# BlueZ
readonly BLUEZ5_DIR="${G_META_VARISCITE_BSP_SRC_DIR}/recipes-connectivity/bluez5/files"

#Graphics - Full Graphics and GPU SDK - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_GRAPHICS="y"
readonly G_GPU_TI_POWERVR_ROGUE_GPU="y"
readonly G_TI_IMG_ROGUE_UMLIBS_PACKAGE_DIR="ti-img-rogue-umlibs-1.15.6133109"
readonly G_TI_POWERVR_GRAPHICS="powervr-graphics-5.10"

#Multimedia - GStreamer Packages - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_MM="y"

readonly G_K3CONF_PACKAGE_DIR="k3conf_0.2"
