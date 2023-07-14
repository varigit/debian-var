readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2020.04_5.4.24_2.1.0_var02"
readonly G_UBOOT_REV="a0039ff78ba2acb48d72241bbd5db1b81f080721"
G_UBOOT_DEF_CONFIG_MMC="imx8mq_var_dart_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'
readonly G_UBOOT_NAME_FOR_EMMC_DP='imx-boot-sd-dp.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="5.4-2.1.x-imx_var01"
readonly G_LINUX_KERNEL_REV="3a0c66906337ae09b95c63666ac3bf9be60fdfaa"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8mq_var_dart_defconfig'
G_LINUX_DTB="freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-sd-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-sd-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-sd-lvds-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-sd-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-sd-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-lvds-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-m4-wifi-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-sd-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-sd-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-sd-lvds-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-sd-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-sd-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-wifi-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-wifi-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-wifi-lvds-dp.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-wifi-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-legacy-wifi-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-m4-sd-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-m4-sd-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-m4-sd-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-m4-wifi-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-m4-wifi-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-m4-wifi-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-sd-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-sd-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-sd-lvds-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-wifi-hdmi.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-wifi-lvds.dtb
	freescale/imx8mq-var-dart-dt8mcustomboard-wifi-lvds-hdmi.dtb"

# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="8.2.0.16"
readonly G_BCM_FW_GIT_REV="8081cd2bddb1569abe91eb50bd687a2066a33342"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.0.p2.4"
readonly G_GPU_IMX_VIV_GBM_DIR="libgbm1"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.4.0.p2.0"
readonly GST_MM_VERSION="MM_04.05.05_2005_L5.4.24"

readonly G2D_PACKAGE_DIR="imx-gpu-g2d-6.4.0.p2.0"
readonly IMX_FIRMWARE_VERSION="8.8"
readonly WESTON_PACKAGE_DIR="imx8m-vivante-g2d"

G2DPACKAGE="imx-gpu-g2d"
readonly G_NO_EXECSTACK="y"

readonly G_IMX_CODEC_DIR="imxcodec-4.5.5"
readonly G_IMX_PARSER_DIR="imxparser-4.5.5"
readonly G_IMX_VPU_HANTRO_DIR="imxvpuhantro-1.18.0"
readonly G_IMX_VPU_WRAPPER_DIR="imxvpuwrap-4.5.5"

IMXGSTPLG="imx-gst1.0-plugin-mx8mm"

# Flashing variables
BOOTLOADER_OFFSET=33

#Boot dtb
BOOT_DTB="imx8mq-var-dart-dt8mcustomboard.dtb"
DEFAULT_BOOT_DTB="imx8mq-var-dart-dt8mcustomboard-sd-lvds.dtb"

#Legacy SOM boot device
BOOT_DTB2="imx8mq-var-dart-dt8mcustomboard-legacy.dtb"
DEFAULT_BOOT_DTB2="imx8mq-var-dart-dt8mcustomboard-legacy-sd-lvds.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="https://github.com/nxp-imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_5.4.24_2.1.0"
readonly G_IMXBOOT_REV="6745ccdcf15384891639b7ced3aa6ce938682365"

#freertos-variscite
readonly G_FREERTOS_VAR_SRC_DIR="${DEF_SRC_DIR}/freertos-variscite"
readonly G_FREERTOS_VAR_SRC_GIT="https://github.com/varigit/freertos-variscite.git"
readonly G_FREERTOS_VAR_SRC_BRANCH="mcuxpresso_sdk_2.11.x-var01"
readonly G_FREERTOS_VAR_SRC_REV="400b111535768f7aad0b25d29b09b8a9b352cd5f"
readonly CM_BOARD="dart_mx8mq"
readonly CM_DEMOS=" \
    multicore_examples/rpmsg_lite_str_echo_rtos/ \
    multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/ \
    demo_apps/hello_world \
    multicore_examples/rpmsg_lite_str_echo_rtos \
    multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote/ \
    demo_apps/hello_world \
"
readonly G_CM_GCC_NAME="gcc-arm-none-eabi-10.3-2021.07"
#
# To avoid scfw compilation errors the Cortex-M gcc toolchain is unpacked in specific folder (G_CM_GCC_OUT_DIR)
# The below line in the scfw Makefile cause the problem selecting a not proper gcc toolchain version
# CROSS_COMPILE = $(TOOLS)/gcc-arm-none-eabi-*/bin/arm-none-eabi-
# https://github.com/varigit/imx-sc-firmware/blob/495e846a5e1ff5d4208c2fb6529397d80c40ebf7/src/scfw_export_mx8qx_b0/Makefile#L343
readonly G_CM_GCC_OUT_DIR="cm-${G_CM_GCC_NAME}"

readonly G_CM_GCC_ARCHIVE="${G_CM_GCC_NAME}-x86_64-linux.tar.bz2"
readonly G_CM_GCC_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/${G_CM_GCC_ARCHIVE}"
readonly G_CM_GCC_SHA256SUM="8c5b8de344e23cd035ca2b53bbf2075c58131ad61223cae48510641d3e556cea"

#imx-atf
readonly G_IMX_ATF_SRC_DIR="${DEF_SRC_DIR}/imx-atf"
readonly G_IMX_ATF_GIT="https://github.com/varigit/imx-atf.git"
readonly G_IMX_ATF_BRANCH="imx_5.4.24_2.1.0_var01"
readonly G_IMX_ATF_REV="7575633e03ff952a18c0a2c0aa543dee793fda5f"

HDMI=yes
SPL_LOAD_ADDR=0x7E1000
TEE_LOAD_ADDR=0xfe000000
ATF_LOAD_ADDR=0x00910000
UBOOT_DTB="imx8mq-var-dart-customboard.dtb"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mq.bin"

# default mirror
readonly DEF_DEBIAN_MIRROR="https://snapshot.debian.org/archive/debian/20210712T151030Z/"

#rootfs package group control
#Default compilation of rootfs (Console Base + Multimedia + Graphics)
#set package group below from G_DEBIAN_DISTRO_FEATURE_XX="n" to disable it

#Multimedia - GStreamer Packages - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_MM="y"

#Graphics - Full Graphics and GPU SDK - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_GRAPHICS="y"
