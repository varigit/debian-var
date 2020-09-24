MKIMG = mkimage_imx8
OUTIMG = flash.bin

CC ?= gcc
CFLAGS ?= -O2 -Wall -std=c99 -static
INCLUDE = ./lib

WGET = /usr/bin/wget
N ?= latest
SERVER=http://yb2.am.freescale.net
BUILD ?= Linux_IMX_Regression

#DIR = internal-only/Linux_IMX_Rocko_MX8/$(N)/common_bsp
#DIR = internal-only/Linux_IMX_Core/$(N)/common_bsp
DIR = internal-only/$(BUILD)/$(N)/common_bsp
ARCHIVE_PATH ?= ~
ARCHIVE_NAME ?= $(shell cat nightly.txt).tar

BITBUCKET_SERVER=https://bitbucket.sw.nxp.com
DDR_FW_DIR=projects/IMX/repos/linux-firmware-imx/raw/firmware/ddr/synopsys
PAD_IMAGE = ../scripts/pad_image.sh

PRINT_FIT_HAB_OFFSET ?= 0x60000
DEK_BLOB_LOAD_ADDR = 0x40400000

ifeq ($(SOC),iMX8MM)
PLAT = imx8mm
HDMI = no
SPL_LOAD_ADDR = 0x7E1000
SPL_FSPI_LOAD_ADDR = 0x7E2000
TEE_LOAD_ADDR ?= 0xbe000000
ATF_LOAD_ADDR = 0x00920000
VAL_BOARD = val
#define the F(Q)SPI header file
QSPI_HEADER = ../scripts/fspi_header 0
QSPI_PACKER = ../scripts/fspi_packer.sh
VERSION = v1
else ifeq ($(SOC),iMX8MN)
PLAT = imx8mn
HDMI = no
SPL_LOAD_ADDR = 0x912000
SPL_FSPI_LOAD_ADDR = 0x912000
TEE_LOAD_ADDR = 0xbe000000
ATF_LOAD_ADDR = 0x00960000
VAL_BOARD = val
#define the F(Q)SPI header file
QSPI_HEADER = ../scripts/fspi_header
QSPI_PACKER = ../scripts/fspi_packer.sh
VERSION = v2
DDR_FW_VERSION = _201810
else
PLAT = imx8mq
HDMI = yes
SPL_LOAD_ADDR = 0x7E1000
TEE_LOAD_ADDR = 0xfe000000
ATF_LOAD_ADDR = 0x00910000
VAL_BOARD = arm2
#define the F(Q)SPI header file
QSPI_HEADER = ../scripts/qspi_header
QSPI_PACKER = ../scripts/fspi_packer.sh
VERSION = v1
endif


FW_DIR = imx-boot/imx-boot-tools/$(PLAT)

$(MKIMG): mkimage_imx8.c
	@echo "PLAT="$(PLAT) "HDMI="$(HDMI)
	@echo "Compiling mkimage_imx8"
	$(CC) $(CFLAGS) mkimage_imx8.c -o $(MKIMG) -lz

u-boot-spl-ddr.bin: u-boot-spl.bin lpddr4_pmu_train_1d_imem.bin lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_2d_imem.bin lpddr4_pmu_train_2d_dmem.bin
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 lpddr4_pmu_train_1d_imem.bin lpddr4_pmu_train_1d_imem_pad.bin
	@objcopy -I binary -O binary --pad-to 0x1000 --gap-fill=0x0 lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_1d_dmem_pad.bin
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 lpddr4_pmu_train_2d_imem.bin lpddr4_pmu_train_2d_imem_pad.bin
	@cat lpddr4_pmu_train_1d_imem_pad.bin lpddr4_pmu_train_1d_dmem_pad.bin > lpddr4_pmu_train_1d_fw.bin
	@cat lpddr4_pmu_train_2d_imem_pad.bin lpddr4_pmu_train_2d_dmem.bin > lpddr4_pmu_train_2d_fw.bin
	@cat u-boot-spl.bin lpddr4_pmu_train_1d_fw.bin lpddr4_pmu_train_2d_fw.bin > u-boot-spl-ddr.bin
	@rm -f lpddr4_pmu_train_1d_fw.bin lpddr4_pmu_train_2d_fw.bin lpddr4_pmu_train_1d_imem_pad.bin lpddr4_pmu_train_1d_dmem_pad.bin lpddr4_pmu_train_2d_imem_pad.bin

ddr4_imem_1d = ddr4_imem_1d$(DDR_FW_VERSION).bin
ddr4_dmem_1d = ddr4_dmem_1d$(DDR_FW_VERSION).bin
ddr4_imem_2d = ddr4_imem_2d$(DDR_FW_VERSION).bin
ddr4_dmem_2d = ddr4_dmem_2d$(DDR_FW_VERSION).bin

u-boot-spl-ddr4.bin: u-boot-spl.bin $(ddr4_imem_1d) $(ddr4_dmem_1d) $(ddr4_imem_2d) $(ddr4_dmem_2d)
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 $(ddr4_imem_1d) ddr4_imem_1d_pad.bin
	@objcopy -I binary -O binary --pad-to 0x1000 --gap-fill=0x0 $(ddr4_dmem_1d) ddr4_dmem_1d_pad.bin
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 $(ddr4_imem_2d) ddr4_imem_2d_pad.bin
	@cat ddr4_imem_1d_pad.bin ddr4_dmem_1d_pad.bin > ddr4_1d_fw.bin
	@cat ddr4_imem_2d_pad.bin $(ddr4_dmem_2d) > ddr4_2d_fw.bin
	@cat u-boot-spl.bin ddr4_1d_fw.bin ddr4_2d_fw.bin > u-boot-spl-ddr4.bin
	@rm -f ddr4_1d_fw.bin ddr4_2d_fw.bin ddr4_imem_1d_pad.bin ddr4_dmem_1d_pad.bin ddr4_imem_2d_pad.bin

u-boot-spl-lpddr4-ddr4.bin: u-boot-spl.bin lpddr4_pmu_train_1d_imem.bin lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_2d_imem.bin lpddr4_pmu_train_2d_dmem.bin $(ddr4_imem_1d) $(ddr4_dmem_1d) $(ddr4_imem_2d) $(ddr4_dmem_2d)
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 lpddr4_pmu_train_1d_imem.bin lpddr4_pmu_train_1d_imem_pad.bin
	@objcopy -I binary -O binary --pad-to 0x1000 --gap-fill=0x0 lpddr4_pmu_train_1d_dmem.bin lpddr4_pmu_train_1d_dmem_pad.bin
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 lpddr4_pmu_train_2d_imem.bin lpddr4_pmu_train_2d_imem_pad.bin
	@objcopy -I binary -O binary --pad-to 0x1000 --gap-fill=0x0 lpddr4_pmu_train_2d_dmem.bin lpddr4_pmu_train_2d_dmem_pad.bin
	@cat lpddr4_pmu_train_1d_imem_pad.bin lpddr4_pmu_train_1d_dmem_pad.bin > lpddr4_pmu_train_1d_fw.bin
	@cat lpddr4_pmu_train_2d_imem_pad.bin lpddr4_pmu_train_2d_dmem_pad.bin > lpddr4_pmu_train_2d_fw.bin
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 $(ddr4_imem_1d) ddr4_imem_1d_pad.bin
	dd if=$(ddr4_dmem_1d) of=ddr4_dmem_1d_pad.bin bs=1K count=4
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 $(ddr4_imem_2d) ddr4_imem_2d_pad.bin
	@cat ddr4_imem_1d_pad.bin ddr4_dmem_1d_pad.bin > ddr4_1d_fw.bin
	@cat ddr4_imem_2d_pad.bin ddr4_dmem_2d.bin > ddr4_2d_fw.bin
	@cat u-boot-spl.bin lpddr4_pmu_train_1d_fw.bin lpddr4_pmu_train_2d_fw.bin ddr4_1d_fw.bin ddr4_2d_fw.bin > u-boot-spl-lpddr4-ddr4.bin
	@rm -f ddr4_1d_fw.bin ddr4_2d_fw.bin ddr4_imem_1d_pad.bin ddr4_dmem_1d_pad.bin ddr4_imem_2d_pad.bin lpddr4_pmu_train_1d_fw.bin lpddr4_pmu_train_2d_fw.bin lpddr4_pmu_train_1d_imem_pad.bin lpddr4_pmu_train_1d_dmem_pad.bin lpddr4_pmu_train_2d_imem_pad.bin lpddr4_pmu_train_2d_dmem_pad.bin

u-boot-spl-ddr3l.bin: u-boot-spl.bin ddr3_imem_1d.bin ddr3_dmem_1d.bin
	@objcopy -I binary -O binary --pad-to 0x8000 --gap-fill=0x0 ddr3_imem_1d.bin ddr3_imem_1d.bin_pad.bin
	@cat ddr3_imem_1d.bin_pad.bin ddr3_dmem_1d.bin > ddr3_pmu_train_fw.bin
	@cat u-boot-spl.bin ddr3_pmu_train_fw.bin > u-boot-spl-ddr3l.bin
	@rm -f ddr3_pmu_train_fw.bin ddr3_imem_1d.bin_pad.bin

u-boot-atf.bin: u-boot.bin bl31.bin
	@cp bl31.bin u-boot-atf.bin
	@dd if=u-boot.bin of=u-boot-atf.bin bs=1K seek=128

u-boot-atf-tee.bin: u-boot.bin bl31.bin tee.bin
	@cp bl31.bin u-boot-atf-tee.bin
	@dd if=tee.bin of=u-boot-atf-tee.bin bs=1K seek=128
	@dd if=u-boot.bin of=u-boot-atf-tee.bin bs=1M seek=1

.PHONY: clean
clean:
	@rm -f $(MKIMG) u-boot-atf.bin u-boot-atf-tee.bin u-boot-spl-ddr.bin u-boot.itb u-boot.its u-boot-ddr3l.itb u-boot-ddr3l.its u-boot-spl-ddr3l.bin u-boot-ddr4.itb u-boot-ddr4.its u-boot-spl-ddr4.bin u-boot-ddr4-evk.itb u-boot-ivt.itb u-boot-ddr4-evk.its u-boot-spl-lpddr4-ddr4.bin u-boot-lpddr4-ddr4-evk.itb u-boot-lpddr4-ddr4-evk.its $(OUTIMG)

dtbs = fsl-$(PLAT)-var-dart.dtb
u-boot.itb: $(dtbs)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs)
	DEK_BLOB_LOAD_ADDR=$(DEK_BLOB_LOAD_ADDR) TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) ./mkimage_fit_atf.sh $(dtbs) > u-boot.its
	./mkimage_uboot -E -p 0x3000 -f u-boot.its u-boot.itb
	@rm -f u-boot.its

dtbs_ddr3l = fsl-$(PLAT)-ddr3l-$(VAL_BOARD).dtb
u-boot-ddr3l.itb: $(dtbs_ddr3l)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs_ddr3l)
	DEK_BLOB_LOAD_ADDR=$(DEK_BLOB_LOAD_ADDR) TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) ./mkimage_fit_atf.sh $(dtbs_ddr3l) > u-boot-ddr3l.its
	./mkimage_uboot -E -p 0x3000 -f u-boot-ddr3l.its u-boot-ddr3l.itb

dtbs_ddr4 = fsl-$(PLAT)-ddr4-$(VAL_BOARD).dtb
u-boot-ddr4.itb: $(dtbs_ddr4)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs_ddr4)
	DEK_BLOB_LOAD_ADDR=$(DEK_BLOB_LOAD_ADDR) TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) ./mkimage_fit_atf.sh $(dtbs_ddr4) > u-boot-ddr4.its
	./mkimage_uboot -E -p 0x3000 -f u-boot-ddr4.its u-boot-ddr4.itb

dtbs_ddr4_evk = fsl-$(PLAT)-var-som.dtb fsl-$(PLAT)-var-som-rev10.dtb
u-boot-ddr4-evk.itb: $(dtbs_ddr4_evk)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs_ddr4_evk)
	DEK_BLOB_LOAD_ADDR=$(DEK_BLOB_LOAD_ADDR) TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) ./mkimage_fit_atf.sh $(dtbs_ddr4_evk) > u-boot-ddr4-evk.its
	./mkimage_uboot -E -p 0x3000 -f u-boot-ddr4-evk.its u-boot-ddr4-evk.itb

dtbs_lpddr4_ddr4_evk = fsl-$(PLAT)-var-dart.dtb fsl-$(PLAT)-var-som.dtb fsl-$(PLAT)-var-som-rev10.dtb
u-boot-lpddr4-ddr4-evk.itb: $(dtbs_lpddr4_ddr4_evk)
	./$(PAD_IMAGE) bl31.bin
	DEK_BLOB_LOAD_ADDR=$(DEK_BLOB_LOAD_ADDR) TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) ./mkimage_fit_atf.sh $(dtbs_lpddr4_ddr4_evk) > u-boot-lpddr4-ddr4-evk.its
	./mkimage_uboot -E -p 0x3000 -f u-boot-lpddr4-ddr4-evk.its u-boot-lpddr4-ddr4-evk.itb

ifeq ($(HDMI),yes)
flash_evk: $(MKIMG) signed_hdmi_imx8m.bin u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -fit -signed_hdmi signed_hdmi_imx8m.bin -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -second_loader u-boot.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_evk_dual_bootloader: $(MKIMG) signed_hdmi_imx8m.bin u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -fit -signed_hdmi signed_hdmi_imx8m.bin -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -out $(OUTIMG)
	./mkimage_imx8 -fit_ivt u-boot.itb 0x40200000 0x0 -out u-boot-ivt.itb

flash_evk_emmc_fastboot: $(MKIMG) signed_hdmi_imx8m.bin u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -dev emmc_fastboot -fit -signed_hdmi signed_hdmi_imx8m.bin -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -second_loader u-boot.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_dp_evk: $(MKIMG) signed_dp_imx8m.bin u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -fit -signed_hdmi signed_dp_imx8m.bin -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -second_loader u-boot.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_ddr3l_val: $(MKIMG) signed_dp_imx8m.bin u-boot-spl-ddr3l.bin u-boot-ddr3l.itb
	./mkimage_imx8 -fit -signed_hdmi signed_dp_imx8m.bin -loader u-boot-spl-ddr3l.bin $(SPL_LOAD_ADDR) -second_loader u-boot-ddr3l.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_ddr4_val: $(MKIMG) signed_hdmi_imx8m.bin u-boot-spl-ddr4.bin u-boot-ddr4.itb
	./mkimage_imx8 -fit -signed_hdmi signed_hdmi_imx8m.bin -loader u-boot-spl-ddr4.bin $(SPL_LOAD_ADDR) -second_loader u-boot-ddr4.itb 0x40200000 0x60000 -out $(OUTIMG)

else
flash_evk: flash_evk_no_hdmi

flash_evk_emmc_fastboot: flash_evk_no_hdmi_emmc_fastboot

flash_ddr4_evk: flash_ddr4_evk_no_hdmi

flash_lpddr4_ddr4_evk: flash_lpddr4_ddr4_evk_no_hdmi

flash_ddr3l_val: flash_ddr3l_val_no_hdmi

flash_ddr4_val: flash_ddr4_val_no_hdmi

endif

flash_evk_no_hdmi: $(MKIMG) u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -second_loader u-boot.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_evk_no_hdmi_dual_bootloader: $(MKIMG) u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -out $(OUTIMG)
	./mkimage_imx8 -fit_ivt u-boot.itb 0x40200000 0x0 -out u-boot-ivt.itb

flash_evk_no_hdmi_emmc_fastboot: $(MKIMG) u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -version $(VERSION) -dev emmc_fastboot -fit -loader u-boot-spl-ddr.bin $(SPL_LOAD_ADDR) -second_loader u-boot.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_ddr3l_val_no_hdmi: $(MKIMG) u-boot-spl-ddr3l.bin u-boot-ddr3l.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-ddr3l.bin $(SPL_LOAD_ADDR) -second_loader u-boot-ddr3l.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_ddr4_val_no_hdmi: $(MKIMG) u-boot-spl-ddr4.bin u-boot-ddr4.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-ddr4.bin $(SPL_LOAD_ADDR) -second_loader u-boot-ddr4.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_ddr4_evk_no_hdmi: $(MKIMG) u-boot-spl-ddr4.bin u-boot-ddr4-evk.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-ddr4.bin $(SPL_LOAD_ADDR) -second_loader u-boot-ddr4-evk.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_lpddr4_ddr4_evk_no_hdmi: $(MKIMG) u-boot-spl-lpddr4-ddr4.bin u-boot-lpddr4-ddr4-evk.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-lpddr4-ddr4.bin $(SPL_LOAD_ADDR) -second_loader u-boot-lpddr4-ddr4-evk.itb 0x40200000 0x60000 -out $(OUTIMG)

flash_ddr4_evk_no_hdmi_dual_bootloader: $(MKIMG) u-boot-spl-ddr4.bin u-boot-ddr4-evk.itb
	./mkimage_imx8 -version $(VERSION) -fit -loader u-boot-spl-ddr4.bin $(SPL_LOAD_ADDR) -out $(OUTIMG)
	./mkimage_imx8 -fit_ivt u-boot-ddr4-evk.itb 0x40200000 0x0 -out u-boot-ivt.itb

flash_evk_flexspi: $(MKIMG) u-boot-spl-ddr.bin u-boot.itb
	./mkimage_imx8 -version $(VERSION) -dev flexspi -fit -loader u-boot-spl-ddr.bin $(SPL_FSPI_LOAD_ADDR) -second_loader u-boot.itb 0x40200000 0x60000 -out $(OUTIMG)
	./$(QSPI_PACKER) $(QSPI_HEADER)

flash_ddr4_evk_flexspi: $(MKIMG) u-boot-spl-ddr4.bin u-boot-ddr4-evk.itb
	./mkimage_imx8 -version $(VERSION) -dev flexspi -fit -loader u-boot-spl-ddr4.bin $(SPL_FSPI_LOAD_ADDR) -second_loader u-boot-ddr4-evk.itb 0x40200000 0x60000 -out $(OUTIMG)
	./$(QSPI_PACKER) $(QSPI_HEADER)

flash_hdmi_spl_uboot: flash_evk

flash_dp_spl_uboot: flash_dp_evk

flash_spl_uboot: flash_evk_no_hdmi

print_fit_hab: u-boot-nodtb.bin bl31.bin $(dtbs)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs)
	TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) VERSION=$(VERSION) ./print_fit_hab.sh $(PRINT_FIT_HAB_OFFSET) $(dtbs)

print_fit_hab_ddr4: u-boot-nodtb.bin bl31.bin $(dtbs_ddr4_evk)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs_ddr4_evk)
	TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) VERSION=$(VERSION) ./print_fit_hab.sh $(PRINT_FIT_HAB_OFFSET) $(dtbs_ddr4_evk)

print_fit_hab_flexspi: u-boot-nodtb.bin bl31.bin $(dtbs)
	./$(PAD_IMAGE) bl31.bin
	./$(PAD_IMAGE) u-boot-nodtb.bin $(dtbs)
	TEE_LOAD_ADDR=$(TEE_LOAD_ADDR) ATF_LOAD_ADDR=$(ATF_LOAD_ADDR) VERSION=$(VERSION) BOOT_DEV="flexspi" ./print_fit_hab.sh $(PRINT_FIT_HAB_OFFSET) $(dtbs)

nightly :
	@echo "Pulling nightly for $(PLAT) evk board from $(SERVER)/$(DIR)"
	@echo $(BUILD)-$(N)-$(PLAT) > nightly.txt
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/lpddr4_pmu_train_1d_dmem.bin -O lpddr4_pmu_train_1d_dmem.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/lpddr4_pmu_train_1d_imem.bin -O lpddr4_pmu_train_1d_imem.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/lpddr4_pmu_train_2d_dmem.bin -O lpddr4_pmu_train_2d_dmem.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/lpddr4_pmu_train_2d_imem.bin -O lpddr4_pmu_train_2d_imem.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/bl31-$(PLAT).bin -O bl31.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/u-boot-spl.bin-$(PLAT)evk-sd -O u-boot-spl.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/u-boot-nodtb.bin-$(PLAT)evk-sd -O u-boot-nodtb.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/fsl-$(PLAT)-evk.dtb -O fsl-$(PLAT)-evk.dtb
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/signed_hdmi_imx8m.bin -O signed_hdmi_imx8m.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/signed_dp_imx8m.bin -O signed_dp_imx8m.bin
	@$(WGET) -q $(SERVER)/$(DIR)/$(FW_DIR)/mkimage_uboot -O mkimage_uboot

archive :
	git ls-files --others --exclude-standard -z | xargs -0 tar rvf $(ARCHIVE_PATH)/$(ARCHIVE_NAME)
	bzip2 $(ARCHIVE_PATH)/$(ARCHIVE_NAME)

#flash_dcd_uboot: $(MKIMG) $(DCD_CFG) u-boot-atf.bin
#	./mkimage_imx8 -dcd $(DCD_CFG) -loader u-boot-atf.bin 0x40001000 -out $(OUTIMG)

#flash_plugin: $(MKIMG) plugin.bin u-boot-spl-for-plugin.bin
#	./mkimage_imx8 -plugin plugin.bin 0x912800 -loader u-boot-spl-for-plugin.bin 0x7F0000 -out $(OUTIMG)
