# make U-Boot for i.MX
# $1 U-Boot path
# $2 Output dir
function make_uboot()
{
	pr_info "Make U-Boot: ${G_UBOOT_DEF_CONFIG_MMC}"

	# clean work directory
	make ARCH=${ARCH_ARGS} -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION} mrproper

	# make U-Boot mmc defconfig
	make ARCH=${ARCH_ARGS} -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION} ${G_UBOOT_DEF_CONFIG_MMC}

	# make U-Boot
	make -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION}

	# make fw_printenv
	make envtools -C ${1} \
		CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
		${G_CROSS_COMPILER_JOPTION}

	cp ${1}/tools/env/fw_printenv ${2}

	if [ "${MACHINE}" = "imx8qxp-var-som" ]; then
		if [ "${IS_QXP_B0}" = true ]; then
			#Compile B0 bootloader

			# scfw
			make_imx_sc_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"
			# imx-atf
			cd ${DEF_SRC_DIR}/imx-atf
			LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
					PLAT=imx8qx bl31
			cd -
			cp ${DEF_SRC_DIR}/imx-atf/build/imx8qx/release/bl31.bin \
				src/imx-mkimage/iMX8QX/bl31.bin
			# imx-seco
			make_imx_seco_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"

			cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cd ${DEF_SRC_DIR}/imx-mkimage
			make REV=B0 SOC=iMX8QX flash_spl
			cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/flash.bin \
				${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
			cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		else
			#Compile C0 bootloader

			# scfw
			make_imx_sc_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"
			# imx-atf
			cd ${DEF_SRC_DIR}/imx-atf
			LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
					PLAT=imx8qx bl31
			cd -
			cp ${DEF_SRC_DIR}/imx-atf/build/imx8qx/release/bl31.bin \
				src/imx-mkimage/iMX8QX/bl31.bin
			# imx-seco
			make_imx_seco_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QX/"

			cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/
			cd ${DEF_SRC_DIR}/imx-mkimage
			make REV=C0 SOC=iMX8QX flash_spl
			cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QX/flash.bin \
				${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
			cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		fi
	elif [ "${MACHINE}" = "imx8mq-var-dart" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8mq bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8mq/release/bl31.bin \
			${DEF_SRC_DIR}/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/signed_hdmi_imx8m.bin \
			src/imx-mkimage/iMX8M/signed_hdmi_imx8m.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/signed_dp_imx8m.bin \
			src/imx-mkimage/iMX8M/signed_dp_imx8m.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_imem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_imem.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_dmem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_dmem.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_imem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_imem.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_dmem.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_dmem.bin
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MQ dtbs=${UBOOT_DTB} flash_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		make SOC=iMX8M clean
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		make SOC=iMX8M dtbs=${UBOOT_DTB} flash_dp_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC_DP}
		cp ${G_UBOOT_NAME_FOR_EMMC_DP} ${2}/${G_UBOOT_NAME_FOR_EMMC_DP}
	elif [ "${MACHINE}" = "imx8mm-var-dart" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8mm bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8mm/release/bl31.bin \
			${DEF_SRC_DIR}/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_1d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_2d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_1d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_2d.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_dmem.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_imem.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_dmem.bin \
			src/imx-mkimage/iMX8M/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_imem.bin \
			src/imx-mkimage/iMX8M/
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		if [ ! -z "${UBOOT_DTB_EXTRA}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		if [ ! -z "${UBOOT_DTB_EXTRA2}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA2} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MM dtbs=${UBOOT_DTB} flash_lpddr4_ddr4_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8mp-var-dart" ]; then
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/bl31-imx8mp.bin \
			src/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_dmem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_dmem_202006.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_1d_imem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_1d_imem_202006.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_dmem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_dmem_202006.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_pmu_train_2d_imem_202006.bin \
			src/imx-mkimage/iMX8M/lpddr4_pmu_train_2d_imem_202006.bin
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		if [ ! -z "${UBOOT_DTB_EXTRA}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		if [ ! -z "${UBOOT_DTB_EXTRA2}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA2} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MP flash_evk
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8mn-var-som" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8mn bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8mn/release/bl31.bin \
			src/imx-mkimage/iMX8M/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_1d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_imem_1d_201810.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_1d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_dmem_1d_201810.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_imem_2d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_imem_2d_201810.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/ddr4_dmem_2d_201810.bin \
			src/imx-mkimage/iMX8M/ddr4_dmem_2d_201810.bin
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/u-boot-nodtb.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		if [ ! -z "${UBOOT_DTB_EXTRA}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		if [ ! -z "${UBOOT_DTB_EXTRA2}" ]; then
			cp ${1}/arch/arm/dts/${UBOOT_DTB_EXTRA2} ${DEF_SRC_DIR}/imx-mkimage/iMX8M/
		fi
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX8M/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8MN dtbs="${UBOOT_DTB}" ${IMXBOOT_TARGETS}
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8M/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx8qm-var-som" ]; then
		# scfw
		make_imx_sc_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QM/"
		# imx-atf
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx8qm bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx8qm/release/bl31.bin \
			src/imx-mkimage/iMX8QM/bl31.bin
		# imx-seco
		make_imx_seco_fw "${DEF_SRC_DIR}/imx-mkimage/iMX8QM/"

		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX8QM flash_spl
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX8QM/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
		cp ${1}/tools/env/fw_printenv ${2}
	elif [ "${MACHINE}" = "imx93-var-som" ]; then
		cd ${DEF_SRC_DIR}/imx-atf
		LDFLAGS="" make CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
				PLAT=imx93 bl31
		cd -
		cp ${DEF_SRC_DIR}/imx-atf/build/imx93/release/bl31.bin \
			${DEF_SRC_DIR}/imx-mkimage/iMX9/bl31.bin
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_imem_1d_v202201.bin \
			src/imx-mkimage/iMX9/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_dmem_1d_v202201.bin \
			src/imx-mkimage/iMX9/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_imem_2d_v202201.bin \
			src/imx-mkimage/iMX9/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/lpddr4_dmem_2d_v202201.bin \
			src/imx-mkimage/iMX9/
		cp ${G_VARISCITE_PATH}/${MACHINE}/imx-boot-tools/mx93a0-ahab-container.img \
			src/imx-mkimage/iMX9/
		cp ${1}/u-boot.bin ${DEF_SRC_DIR}/imx-mkimage/iMX9/
		cp ${1}/spl/u-boot-spl.bin ${DEF_SRC_DIR}/imx-mkimage/iMX9/
		cp ${1}/arch/arm/dts/${UBOOT_DTB} ${DEF_SRC_DIR}/imx-mkimage/iMX9/
		cp ${1}/tools/mkimage ${DEF_SRC_DIR}/imx-mkimage/iMX9/mkimage_uboot
		cd ${DEF_SRC_DIR}/imx-mkimage
		make SOC=iMX9 dtbs="${UBOOT_DTB}" ${IMXBOOT_TARGETS}
		cp ${DEF_SRC_DIR}/imx-mkimage/iMX9/flash.bin \
			${DEF_SRC_DIR}/imx-mkimage/${G_UBOOT_NAME_FOR_EMMC}
		cp ${G_UBOOT_NAME_FOR_EMMC} ${2}/${G_UBOOT_NAME_FOR_EMMC}
	elif [ "${MACHINE}" = "imx6ul-var-dart" ] ||
	     [ "${MACHINE}" = "var-som-mx7" ]; then
		mv ${2}/fw_printenv ${2}/fw_printenv-mmc
		#copy MMC SPL, u-boot, SPL binaries
		cp ${1}/SPL ${2}/${G_SPL_NAME_FOR_EMMC}
		cp ${1}/u-boot.img  ${2}/${G_UBOOT_NAME_FOR_EMMC}

		# make nand make NAND U-Boot
		pr_info "Make SPL & u-boot: ${G_UBOOT_DEF_CONFIG_NAND}"
		# clean work directory
		make ARCH=arm -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			${G_CROSS_COMPILER_JOPTION} mrproper

		# make uboot config for nand
		make ARCH=arm -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			 ${G_CROSS_COMPILER_JOPTION} ${G_UBOOT_DEF_CONFIG_NAND}

		# make uboot
		make ARCH=arm -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			 ${G_CROSS_COMPILER_JOPTION}

		# make fw_printenv
		make envtools -C ${1} \
			CROSS_COMPILE=${G_CROSS_COMPILER_PATH}/${G_CROSS_COMPILER_PREFIX} \
			${G_CROSS_COMPILER_JOPTION}

		# copy NAND SPL, u-boot binaries
		cp ${1}/SPL ${2}/${G_SPL_NAME_FOR_NAND}
		cp ${1}/u-boot.img ${2}/${G_UBOOT_NAME_FOR_NAND}
		cp ${1}/tools/env/fw_printenv ${2}/fw_printenv-nand
	fi
}
