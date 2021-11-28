readonly ARCH_CPU="64BIT"

# U-Boot
readonly G_UBOOT_SRC_DIR="${DEF_SRC_DIR}/uboot"
readonly G_UBOOT_GIT="https://github.com/varigit/uboot-imx.git"
readonly G_UBOOT_BRANCH="imx_v2020.04_5.4.70_2.3.2_var01"
readonly G_UBOOT_REV="166c005e984e858f5ee95d242a5b453355bf80d1"
G_UBOOT_DEF_CONFIG_MMC="imx8mp_var_dart_defconfig"
readonly G_UBOOT_NAME_FOR_EMMC='imx-boot-sd.bin'

# Linux kernel
readonly G_LINUX_KERNEL_SRC_DIR="${DEF_SRC_DIR}/kernel"
readonly G_LINUX_KERNEL_GIT="https://github.com/varigit/linux-imx.git"
readonly G_LINUX_KERNEL_BRANCH="imx_5.4.70_2.3.2_var01"
readonly G_LINUX_KERNEL_REV="af7c4d3f2342c6b4179e07c1341405f2f46c010d"
readonly G_LINUX_KERNEL_DEF_CONFIG='imx8_var_defconfig'
G_LINUX_DTB="freescale/imx8mp-var-dart-dt8mcustomboard.dtb
       freescale/imx8mp-var-dart-dt8mcustomboard-legacy.dtb
       freescale/imx8mp-var-som-symphony.dtb
       freescale/imx8mp-var-som-symphony-2nd-ov5640.dtb
       freescale/imx8mp-var-som-symphony-2nd-ov5640-m7.dtb
       freescale/imx8mp-var-som-symphony-m7.dtb
       freescale/imx8mp-var-dart-dt8mcustomboard-legacy-m7.dtb
       freescale/imx8mp-var-dart-dt8mcustomboard-m7.dtb
       "
# Broadcom BT/WIFI firmware
readonly G_BCM_FW_SRC_DIR="${DEF_SRC_DIR}/bcmfw"
readonly G_BCM_FW_GIT="https://github.com/varigit/bcm_4343w_fw.git"
readonly G_BCM_FW_GIT_BRANCH="8.2.0.16"
readonly G_BCM_FW_GIT_REV="8081cd2bddb1569abe91eb50bd687a2066a33342"

readonly G_GPU_IMX_VIV_PACKAGE_DIR="imx-gpu-viv-6.4.3.p1.4"
readonly G_GPU_IMX_VIV_SDK_PACKAGE_DIR="imx-gpu-sdk-6.4.0.p2.0"
readonly GST_MM_VERSION="MM_04.05.07_2011_L5.4.70"
readonly G_GST_PLUGINS_BAD_DIR="MM_04.05.07_2011_L5.4.70_U1"
readonly G2D_PACKAGE_DIR="imx-gpu-g2d-6.4.3.p1.4"
readonly IMX_FIRMWARE_VERSION="8.10"
readonly WESTON_PACKAGE_DIR="imx8m-vivante-g2d/weston-9"
readonly IMX_GPU_VIV_DEFAULT_WL_PACKAGE="imx-gpu-viv-core"

readonly G_IMX_CODEC_DIR="imxcodec-4.5.7"
readonly G_IMX_PARSER_DIR="imxparser-4.5.7"
readonly G_IMX_VPU_HANTRO_DIR="imxvpuhantro-1.20.0"
readonly G_IMX_VPU_HANTRO_VC_DIR="imxvpuhantro-vc-1.3.0"
readonly G_IMX_VPU_WRAPPER_DIR="imxvpuwrap-4.5.7"
readonly G_IMX_NN_DIR="imx-nn-1.1.9"

IMXGSTPLG="imx-gst1.0-plugin-mx8mp"
G2DPACKAGE="imx-gpu-g2d"
readonly G_NO_EXECSTACK="y"

# Flashing variables
BOOTLOADER_OFFSET=32

BOOT_DTB="imx8mp-var-dart-dt8mcustomboard.dtb"
DEFAULT_BOOT_DTB="imx8mp-var-dart-dt8mcustomboard.dtb"

readonly G_IMXBOOT_SRC_DIR="${DEF_SRC_DIR}/imx-mkimage"
readonly G_IMXBOOT_GIT="git://source.codeaurora.org/external/imx/imx-mkimage.git"
readonly G_IMXBOOT_BRACH="imx_5.4.70_2.3.0"
readonly G_IMXBOOT_REV="8947fea369ab3932259630232cfb9f87b8f9dda1"
HDMI=no
TEE_LOAD_ADDR=0x56000000
ATF_LOAD_ADDR=0x00970000
UBOOT_DTB="imx8mp-var-dart-dt8mcustomboard.dtb"
UBOOT_DTB_EXTRA="imx8mp-var-dart-dt8mcustomboard-legacy.dtb"
UBOOT_DTB_EXTRA2="imx8mp-var-som-symphony.dtb"
IMXBOOT_TARGETS="flash_evk"
IMX_BOOT_TOOL_BL_BIN="bl31-imx8mp.bin"

# default mirror
readonly DEF_DEBIAN_MIRROR="https://snapshot.debian.org/archive/debian/20210712T151030Z/"

#freertos-variscite
readonly G_FREERTOS_VAR_SRC_DIR="${DEF_SRC_DIR}/freertos-variscite"
readonly G_FREERTOS_VAR_SRC_GIT="git://github.com/varigit/freertos-variscite.git"
readonly G_FREERTOS_VAR_SRC_BRANCH="mcuxpresso_sdk_2.10.x-var01"
readonly G_FREERTOS_VAR_SRC_REV="db2c47b339ab5ccaa923d4bc3de3a5222439fc15"
readonly CM_BOARD="dart_mx8mp"
readonly CM_DEMOS=" \
	multicore_examples/rpmsg_lite_str_echo_rtos \
	multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote \
	demo_apps/hello_world \
	multicore_examples/rpmsg_lite_str_echo_rtos \
	multicore_examples/rpmsg_lite_pingpong_rtos/linux_remote \
	demo_apps/hello_world \
"
readonly G_CM_GCC_NAME="gcc-arm-none-eabi-10-2020-q4-major"
#
# To avoid scfw compilation errors the Cortex-M gcc toolchain is unpacked in specific folder (G_CM_GCC_OUT_DIR)
# The below line in the scfw Makefile cause the problem selecting a not proper gcc toolchain version
# CROSS_COMPILE = $(TOOLS)/gcc-arm-none-eabi-*/bin/arm-none-eabi-
# https://github.com/varigit/imx-sc-firmware/blob/495e846a5e1ff5d4208c2fb6529397d80c40ebf7/src/scfw_export_mx8qx_b0/Makefile#L343
readonly G_CM_GCC_OUT_DIR="cm-${G_CM_GCC_NAME}"

readonly G_CM_GCC_ARCHIVE="${G_CM_GCC_NAME}-x86_64-linux.tar.bz2"
readonly G_CM_GCC_LINK="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/${G_CM_GCC_ARCHIVE}"
readonly G_CM_GCC_SHA256SUM="21134caa478bbf5352e239fbc6e2da3038f8d2207e089efc96c3b55f1edcd618"

#rootfs package group control
#Default compilation of rootfs (Console Base + Multimedia + Graphics)
#set package group below from G_DEBIAN_DISTRO_FEATURE_XX="n" to disable it

#Multimedia - GStreamer Packages - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_MM="y"

#Graphics - Full Graphics and GPU SDK - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_GRAPHICS="y"

#Machine Learning - Machine learning libraries - Set it to "n" if you want to disable it
readonly G_DEBIAN_DISTRO_FEATURE_ML="y"
