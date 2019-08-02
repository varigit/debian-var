# Setup WIFI control GPIOs
wifi_pre_up()
{
	if [ ! -d /sys/class/gpio/gpio${WIFI_3V3_GPIO} ]; then
		echo ${WIFI_3V3_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_3V3_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${WIFI_1V8_GPIO} ]; then
		echo ${WIFI_1V8_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_1V8_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${WIFI_EN_GPIO} ]; then
		echo ${WIFI_EN_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_EN_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${BT_BUF_GPIO} ]; then
		echo ${BT_BUF_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${BT_BUF_GPIO}/direction
	fi

	if [ ! -d /sys/class/gpio/gpio${BT_EN_GPIO} ]; then
		echo ${BT_EN_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	fi
}

# Power up WIFI chip
wifi_up()
{
	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
        fi

	# WIFI_3V3 up
	echo 1 > /sys/class/gpio/gpio${WIFI_3V3_GPIO}/value
	usleep 10000

	# WIFI_1V8 up
	echo 1 > /sys/class/gpio/gpio${WIFI_1V8_GPIO}/value
	usleep 10000

	# WLAN_EN up
	echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_EN up
	echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

	# BT_BUF up
	echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# Wait at least 150ms
	usleep 200000

	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

	# Bind WIFI device to MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind

	# Load WIFI driver
	modprobe brcmfmac
}

# Power down WIFI chip
wifi_down()
{
	# Unload WIFI driver
	modprobe -r brcmfmac

	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
	   echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	# WIFI_EN down
	echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

	# BT_BUF down
	echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value

	# BT_EN down
	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	usleep 10000

	# WIFI_1V8 down
	echo 0 > /sys/class/gpio/gpio${WIFI_1V8_GPIO}/value

	# WIFI_3V3 down
	echo 0 > /sys/class/gpio/gpio${WIFI_3V3_GPIO}/value
}

# Return true if WIFI should not be started
wifi_should_not_be_started()
{
        # Do not enable WIFI if it is already up
        [ -d /sys/class/net/wlan0 ] && return 0

        # Do not enable WIFI if booting from SD on VAR-SOM-MX8X
        if grep -q mmcblk1 /proc/cmdline; then
                return 0
        fi

        # Do not enable WIFI if booting from eMMC without WIFI
        if ! grep -q WIFI /sys/devices/soc0/machine; then
                return 0
        fi

        return 1
}

# Return true if WIFI should not be stopped
wifi_should_not_be_stopped()
{
        # Do not stop WIFI if booting from SD on VAR-SOM-MX8X
        if grep -q mmcblk1 /proc/cmdline; then
                return 0
        fi

        # Do not stop WIFI if booting from eMMC without WIFI
        if ! grep -q WIFI /sys/devices/soc0/machine; then
                return 0
        fi

        return 1
}
