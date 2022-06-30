readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2018.03_4.14.98_2.0.0_ga_var01"
readonly G_UBOOT_REV="c67389b3e5a88f299809771a8287d0cf01a2738a"
G_UBOOT_DEF_CONFIG_MMC='imx8qm_var_som_defconfig'
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_4.14.98_2.0.0_ga_var01"
readonly G_LINUX_KERNEL_REV="a9dc410e85273f67f8f7bb3840f74f9419944d85"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/fsl-imx8qm-var-som-dp.dtb
	freescale/fsl-imx8qm-var-som-hdmi.dtb
	freescale/fsl-imx8qm-var-som-lvds.dtb
	freescale/fsl-imx8qm-var-spear-dp.dtb
	freescale/fsl-imx8qm-var-spear-hdmi.dtb
	freescale/fsl-imx8qm-var-spear-lvds.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="7.0.0.142"
readonly G_BCM_FW_GIT_REV="7080491e10b82661ca4a67237fdb361190775d2f"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.2.4.p4.0"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.2.4.p4.0"
readonly GST_MM_VERSION="MM_04.04.05_1902_L4.14.98_GA"
readonly G2D_PACKAGE_DIR="imx-dpu-g2d-1.7.0"
readonly IMX_FIRMWARE_VERSION="8.1"
readonly HDMI_FIRMWARE_PACKAGE="imx-firmware-hdmi"
readonly WESTON_PACKAGE_DIR="imx8qxm-dpu-g2d"
IMXGSTPLG="imx-gst1.0-plugin-mx8x"
G2DPACKAGE="imx-dpu-g2d"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="https://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_4.14.98_2.0.0_ga"
readonly G_IMXBOOT_REV="dd0234001713623c79be92b60fa88bc07b07f24f"

# Flashing variables
BOOTLOADER_OFFSET=32

BOOT_DTB="fsl-imx8qm-var-som.dtb"
BOOT_SPEAR8_DTB="fsl-imx8qm-var-spear.dtb"
DEFAULT_BOOT_DTB="fsl-imx8qm-var-som-lvds.dtb"
DEFAULT_BOOT_SPEAR8_DTB="fsl-imx8qm-var-spear-lvds.dtb"
