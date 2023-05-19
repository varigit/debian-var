# make U-Boot for TI AM62
# $1 U-Boot path
# $2 Output dir
function make_uboot()
{
	# export PATH=$HOME/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin:$PATH
	# export PATH=$HOME/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH

	##### ATF
	pr_info "Make $(basename ${G_ATF_SRC_DIR})"
	make -C ${G_OPTEE_SRC_DIR} clean
	make -C ${G_ATF_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} ARCH=aarch64 \
		CROSS_COMPILE=${G_CROSS_COMPILER_64BIT_PATH}/${G_CROSS_COMPILER_64BIT_PREFIX} \
		PLAT=k3 TARGET_BOARD=lite SPD=opteed

	##### OPTEE
	pr_info "Make $(basename ${G_OPTEE_SRC_DIR})"
	make -C ${G_OPTEE_SRC_DIR} clean
	make -C ${G_OPTEE_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} \
		CROSS_COMPILE32=${G_CROSS_COMPILER_32BIT_PATH}/${G_CROSS_COMPILER_32BIT_PREFIX} \
		CROSS_COMPILE64=${G_CROSS_COMPILER_64BIT_PATH}/${G_CROSS_COMPILER_64BIT_PREFIX} \
		PLATFORM=k3-am62x CFG_ARM64_core=y

	##### U-Boot R5
	pr_info "Make U-Boot: ${G_UBOOT_DEF_CONFIG_R}"

	# Cleanup
	rm -rf ${G_UBOOT_SRC_DIR}/out
	make -C ${G_UBOOT_SRC_DIR} mrproper

	# Defconfig
	make -C ${G_UBOOT_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} ARCH=arm O=${G_UBOOT_SRC_DIR}/out/r5 \
		CROSS_COMPILE=${G_CROSS_COMPILER_32BIT_PATH}/${G_CROSS_COMPILER_32BIT_PREFIX} \
		${G_UBOOT_DEF_CONFIG_R}

	# Build u-boot-spl.bin for tiboot3.bin. Saved in ${G_UBOOT_SRC_DIR}/out/r5:
	make -C ${G_UBOOT_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} ARCH=arm O=${G_UBOOT_SRC_DIR}/out/r5 \
		CROSS_COMPILE=${G_CROSS_COMPILER_32BIT_PATH}/${G_CROSS_COMPILER_32BIT_PREFIX}

	# Build tiboot3-am62x-gp-evm.bin. Saved in $G_CORE_K3_IMAGE_GEN_SRC_DIR.
	# Requires u-boot-spl.bin and ti-fs-firmware-am62x-gp.bin
	make -C ${G_CORE_K3_IMAGE_GEN_SRC_DIR} mrproper
	make -C ${G_CORE_K3_IMAGE_GEN_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} ARCH=arm \
		CROSS_COMPILE=${G_CROSS_COMPILER_32BIT_PATH}/${G_CROSS_COMPILER_32BIT_PREFIX} \
		SOC=am62x SOC_TYPE=gp SBL=$G_UBOOT_SRC_DIR/out/r5/spl/u-boot-spl.bin \
		SYSFW_DIR=${G_CORE_LINUX_FIRMWARE_SRC_DIR}/ti-sysfw

	##### U-Boot A53
	pr_info "Make U-Boot: ${G_UBOOT_DEF_CONFIG_A}"

	# Cleanup
	make -C ${G_UBOOT_SRC_DIR} mrproper

	# Defconfig
	make -C ${G_UBOOT_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} ARCH=arm O=${G_UBOOT_SRC_DIR}/out/a53 \
		CROSS_COMPILE=${G_CROSS_COMPILER_64BIT_PATH}/${G_CROSS_COMPILER_64BIT_PREFIX} \
		${G_UBOOT_DEF_CONFIG_A}


	# Build tispl.bin and u-boot.img. Saved in $G_UBOOT_SRC_DIR/out/a53
	# Requires bl31.bin, tee-pager_v2.bin, and ipc_echo_testb_mcu1_0_release_strip.xer5f
	make -C ${G_UBOOT_SRC_DIR} ${G_CROSS_COMPILER_JOPTION} ARCH=arm O=${G_UBOOT_SRC_DIR}/out/a53 \
		PATH=${G_CROSS_COMPILER_32BIT_PATH}:$PATH \
		PATH=${G_CROSS_COMPILER_64BIT_PATH}:$PATH \
		CROSS_COMPILE=${G_CROSS_COMPILER_64BIT_PREFIX} \
		ATF=${G_ATF_SRC_DIR}/build/k3/lite/release/bl31.bin \
		TEE=${G_OPTEE_SRC_DIR}/out/arm-plat-k3/core/tee-pager_v2.bin \
		DM=${G_CORE_LINUX_FIRMWARE_SRC_DIR}/ti-dm/am62xx/ipc_echo_testb_mcu1_0_release_strip.xer5f

	# Deploy files
	pr_info "Deploying to ${2}/boot"
	mkdir -p ${2}/boot
	cp ${G_CORE_K3_IMAGE_GEN_SRC_DIR}/tiboot3.bin \
		${G_UBOOT_SRC_DIR}/out/a53/tispl.bin \
		${G_UBOOT_SRC_DIR}/out/a53/u-boot.img \
		${2}/boot
}
