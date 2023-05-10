readonly ARCH_CPU="64BIT"

# SOC
readonly SOC="am62"
readonly SOC_SERIES="am6"
readonly SOC_FAMILY="am6"

git_repos=(
	"G_CORE_SECDEV_K3"
	"G_CORE_K3_IMAGE_GEN"
	"G_CORE_LINUX_FIRMWARE"
	"G_ATF"
	"G_OPTEE"
	"G_UBOOT"
	"G_LINUX_KERNEL"
	"G_TI_IMG_ROGUE_DRV"
)

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