#!/bin/sh
#
# script to generate FIT image source for i.MX8MQ boards with
# ARM Trusted Firmware and multiple device trees (given on the command line)
#
# usage: $0 <dt_name> [<dt_name> [<dt_name] ...]

[ -z "$BL31" ] && BL31="bl31.bin"
# keep backward compatibility
[ -z "$TEE_LOAD_ADDR" ] && TEE_LOAD_ADDR="0xfe000000"

if [ -z "$ATF_LOAD_ADDR" ]; then
	echo "ERROR: BL31 load address is not set" >&2
	exit 0
fi

if [ ! -f $BL31 ]; then
	echo "ERROR: BL31 file $BL31 NOT found" >&2
	exit 0
else
	echo "bl31.bin size: " >&2
	ls -lct bl31.bin | awk '{print $5}' >&2
fi

BL32="tee.bin"
LOADABLES="\"atf@1\""

if [ ! -f $BL32 ]; then
	BL32=/dev/null
else
	echo "Building with TEE support, make sure your bl31 is compiled with spd. If you do not want tee, please delete tee.bin" >&2
	echo "tee.bin size: " >&2
	ls -lct tee.bin | awk '{print $5}' >&2
	LOADABLES="$LOADABLES, \"tee@1\""
fi

BL33="u-boot-nodtb.bin"
DEK_BLOB="dek_blob_fit_dummy.bin"

if [ ! -f $DEK_BLOB ]; then
	DEK_BLOB=/dev/null
else
	echo "Building with encrypted boot support, make sure to replace DEK Blob in final image." >&2
	LOADABLES="\"dek_blob@1\", $LOADABLES"
fi

if [ ! -f $BL33 ]; then
	echo "ERROR: $BL33 file NOT found" >&2
	exit 0
else

	echo "u-boot-nodtb.bin size: " >&2
	ls -lct u-boot-nodtb.bin | awk '{print $5}' >&2
fi

for dtname in $*
do
	echo "$dtname size: " >&2
	ls -lct $dtname | awk '{print $5}' >&2
done

cat << __HEADER_EOF
/dts-v1/;

/ {
	description = "Configuration to load ATF before U-Boot";

	images {
		uboot@1 {
			description = "U-Boot (64-bit)";
			data = /incbin/("$BL33");
			type = "standalone";
			arch = "arm64";
			compression = "none";
			load = <0x40200000>;
		};
__HEADER_EOF

cnt=1
for dtname in $*
do
	cat << __FDT_IMAGE_EOF
		fdt@$cnt {
			description = "$(basename $dtname .dtb)";
			data = /incbin/("$dtname");
			type = "flat_dt";
			compression = "none";
		};
__FDT_IMAGE_EOF
cnt=$((cnt+1))
done

cat << __HEADER_EOF
		atf@1 {
			description = "ARM Trusted Firmware";
			data = /incbin/("$BL31");
			type = "firmware";
			arch = "arm64";
			compression = "none";
			load = <$ATF_LOAD_ADDR>;
			entry = <$ATF_LOAD_ADDR>;
		};
__HEADER_EOF

if [ -f $BL32 ]; then
cat << __HEADER_EOF
		tee@1 {
			description = "TEE firmware";
			data = /incbin/("$BL32");
			type = "firmware";
			arch = "arm64";
			compression = "none";
			load = <$TEE_LOAD_ADDR>;
			entry = <$TEE_LOAD_ADDR>;
		};
__HEADER_EOF
fi

if [ -f $DEK_BLOB ]; then
cat << __HEADER_EOF
		dek_blob@1 {
			description = "dek_blob";
			data = /incbin/("$DEK_BLOB");
			type = "script";
			compression = "none";
			load = <$DEK_BLOB_LOAD_ADDR>;
		};
__HEADER_EOF
fi

cat << __CONF_HEADER_EOF
	};
	configurations {
		default = "config@1";

__CONF_HEADER_EOF

cnt=1
for dtname in $*
do
if [ -f $BL32 ]; then
if [ $ROLLBACK_INDEX_IN_FIT ]; then
cat << __CONF_SECTION_EOF
		config@$cnt {
			description = "$(basename $dtname .dtb)";
			firmware = "uboot@1";
			loadables = $LOADABLES;
			fdt = "fdt@$cnt";
			rbindex = "$ROLLBACK_INDEX_IN_FIT";
		};
__CONF_SECTION_EOF
else
cat << __CONF_SECTION_EOF
		config@$cnt {
			description = "$(basename $dtname .dtb)";
			firmware = "uboot@1";
			loadables = $LOADABLES;
			fdt = "fdt@$cnt";
		};
__CONF_SECTION_EOF
fi
else
cat << __CONF_SECTION1_EOF
		config@$cnt {
			description = "$(basename $dtname .dtb)";
			firmware = "uboot@1";
			loadables = $LOADABLES;
			fdt = "fdt@$cnt";
		};
__CONF_SECTION1_EOF
fi
cnt=$((cnt+1))
done

cat << __ITS_EOF
	};
};
__ITS_EOF
