readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2018.03_4.14.98_2.0.0_ga_var01"
readonly G_UBOOT_REV="42342c4846a45a950e34bfae198e5e2b19ef6c6e"
G_UBOOT_DEF_CONFIG_MMC='imx8qxp_var_som_defconfig'
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_4.14.98_2.0.0_ga_var01"
readonly G_LINUX_KERNEL_REV="10655422aa2d846ea24bb904712e2fd76b3723ba"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/fsl-imx8qxp-var-som-sd.dtb
             freescale/fsl-imx8qxp-var-som-wifi.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="6.0.0.121"
readonly G_BCM_FW_GIT_REV="7bce9b69b51ffd967176c1597feed79305927370"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.2.4.p4.0"
readonly GST_MM_VERSION="MM_04.04.05_1902_L4.14.98_GA"
readonly G2D_PACKAGE_DIR="imx-dpu-g2d-1.7.0"
readonly IMX_FIRMWARE_VERSION="8.1"
readonly WESTON_PACKAGE_DIR="imx8qxm-dpu-g2d"
IMXGSTPLG="imx-gst1.0-plugin-mx8x"
G2DPACKAGE="imx-dpu-g2d"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="https://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_4.14.98_2.0.0_ga"
readonly G_IMXBOOT_REV="dd0234001713623c79be92b60fa88bc07b07f24f"

# Flashing variables
BOOTLOADER_OFFSET=32

BOOT_DTB="fsl-imx8qxp-var-som.dtb"
DEFAULT_BOOT_DTB="fsl-imx8qxp-var-som-sd.dtb"
