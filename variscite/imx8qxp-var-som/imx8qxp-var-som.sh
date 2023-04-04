readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2020.04_5.4.24_2.1.0_var02"
readonly G_UBOOT_REV="3b8deb5f75edcd42784abc1c8d313ac65b9cef58"
G_UBOOT_DEF_CONFIG_MMC='imx8qxp_var_som_defconfig'
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="5.4-2.1.x-imx_var01"
readonly G_LINUX_KERNEL_REV="1348e8d7faa1b59ce2de944140253d83122965c4"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/imx8qxp-var-som-symphony-sd.dtb
             freescale/imx8qxp-var-som-symphony-sd-m4.dtb
             freescale/imx8qxp-var-som-symphony-wifi.dtb
             freescale/imx8qxp-var-som-symphony-wifi-m4.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="8.2.0.16"
readonly G_BCM_FW_GIT_REV="8081cd2bddb1569abe91eb50bd687a2066a33342"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.0.p2.4"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.4.0.p2.0"
readonly GST_MM_VERSION="MM_04.05.05_2005_L5.4.24"
readonly G2D_PACKAGE_DIR="imx-dpu-g2d-1.8.7"
readonly IMX_FIRMWARE_VERSION="8.8"
readonly WESTON_PACKAGE_DIR="imx8qxm-dpu-g2d/weston-9"
IMXGSTPLG="imx-gst1.0-plugin-mx8qm"
G2DPACKAGE="imx-dpu-g2d"

readonly G_IMX_CODEC_DIR="imxcodec-4.5.5"
readonly G_IMX_PARSER_DIR="imxparser-4.5.5"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="https://github.com/nxp-imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_5.4.24_2.1.0"
readonly G_IMXBOOT_REV="6745ccdcf15384891639b7ced3aa6ce938682365"

#freertos-variscite
readonly G_FREERTOS_VAR_SRC_DIR="${DEF_SRC_DIR}/freertos-variscite"
readonly G_FREERTOS_VAR_SRC_GIT="https://github.com/varigit/freertos-variscite.git"
readonly G_FREERTOS_VAR_SRC_BRANCH="mcuxpresso_sdk_2.9.x-var01"
readonly G_FREERTOS_VAR_SRC_REV="a8b9a7ea089d791cd30c00cc691c2768f83cc307"
readonly CM_BOARD="som_mx8qx"
readonly DISABLE_CACHE_PATCH="disable_cache_2.9.x.patch"
readonly CM_DEMOS_DISABLE_CACHE="demo_apps/disable_cache"
readonly CM_DEMOS=" \
    multicore_examples/rpmsg_lite_str_echo_rtos \
    multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote \
    demo_apps/hello_world \
"
readonly G_CM_GCC_NAME="gcc-arm-none-eabi-9-2020-q2-update"
#
# To avoid scfw compilation errors the Cortex-M gcc toolchain is unpacked in specific folder (G_CM_GCC_OUT_DIR)
# The below line in the scfw Makefile cause the problem selecting a not proper gcc toolchain version
# CROSS_COMPILE = $(TOOLS)/gcc-arm-none-eabi-*/bin/arm-none-eabi-
# https://github.com/varigit/imx-sc-firmware/blob/495e846a5e1ff5d4208c2fb6529397d80c40ebf7/src/scfw_export_mx8qx_b0/Makefile#L343
readonly G_CM_GCC_OUT_DIR="cm-${G_CM_GCC_NAME}"

readonly G_CM_GCC_ARCHIVE="${G_CM_GCC_NAME}-x86_64-linux.tar.bz2"
readonly G_CM_GCC_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/${G_CM_GCC_ARCHIVE}"
readonly G_CM_GCC_SHA256SUM="5adc2ee03904571c2de79d5cfc0f7fe2a5c5f54f44da5b645c17ee57b217f11f"

#imx-atf
readonly G_IMX_ATF_SRC_DIR="${DEF_SRC_DIR}/imx-atf"
readonly G_IMX_ATF_GIT="http://github.com/varigit/imx-atf.git"
readonly G_IMX_ATF_BRANCH="imx_5.4.24_2.1.0_var01"
readonly G_IMX_ATF_REV="7575633e03ff952a18c0a2c0aa543dee793fda5f"

# imx-sc-firmware
readonly G_IMX_SC_FW_SRC_DIR="${DEF_SRC_DIR}/imx-sc-firmware"
readonly G_IMX_SC_FW_GIT="https://github.com/varigit/imx-sc-firmware.git"
readonly G_IMX_SC_FW_BRANCH="1.5.1"
readonly G_IMX_SC_FW_REV="495e846a5e1ff5d4208c2fb6529397d80c40ebf7"
readonly G_IMX_SC_FW_TOOLCHAIN_NAME="gcc-arm-none-eabi-8-2018-q4-major"
readonly G_IMX_SC_FW_TOOLCHAIN_ARCHIVE="${G_IMX_SC_FW_TOOLCHAIN_NAME}-linux.tar.bz2"
readonly G_IMX_SC_FW_TOOLCHAIN_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/${G_IMX_SC_FW_TOOLCHAIN_ARCHIVE}"
readonly G_IMX_SC_FW_TOOLCHAIN_SHA256SUM="fb31fbdfe08406ece43eef5df623c0b2deb8b53e405e2c878300f7a1f303ee52"
readonly G_IMX_SC_FW_FAMILY="qx"
readonly G_IMX_SC_MACHINE_NAME="mx8${G_IMX_SC_FW_FAMILY}_b0"

# imx-seco
readonly G_IMX_SECO_SRC_DIR="${DEF_SRC_DIR}/imx-seco"
readonly G_IMX_SECO_REV="3.6.3"
readonly G_IMX_SECO_SHA256SUM="52ba07633e0f8707d8c26724b5cd03ef96444c8de1e0e134acac50acacf3e7dd"
readonly G_IMX_SECO_BIN="imx-seco_${G_IMX_SECO_REV}.bin"
if [ "${IS_QXP_B0}" = true ]; then
	readonly G_IMX_SECO_IMG="${G_IMX_SECO_SRC_DIR}/imx-seco-${G_IMX_SECO_REV}/firmware/seco/mx8qxb0-ahab-container.img"
else
	readonly G_IMX_SECO_IMG="${G_IMX_SECO_SRC_DIR}/imx-seco-${G_IMX_SECO_REV}/firmware/seco/mx8qxc0-ahab-container.img"
fi
readonly G_IMX_SECO_URL="https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/imx-seco-${G_IMX_SECO_REV}.bin"

# Flashing variables
BOOTLOADER_OFFSET=32

BOOT_DTB="imx8qxp-var-som-symphony.dtb"
DEFAULT_BOOT_DTB="imx8qxp-var-som-symphony-sd.dtb"

# default mirror
readonly DEF_DEBIAN_MIRROR="https://snapshot.debian.org/archive/debian/20210621T090656Z/"

#rootfs package group control
#Default compilation of rootfs (Console Base + Multimedia + Graphics)
#set package group below from G_DEBIAN_DISTRO_FEATURE_XX="n" to disable it

#Multimedia - GStreamer Packages - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_MM="y"

#Graphics - Full Graphics and GPU SDK - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_GRAPHICS="y"
