# Return true if board is VAR-SOM-MX8M-PLUS
board_is_var_som_mx8m_plus()
{
	grep -q VAR-SOM-MX8M-PLUS /sys/devices/soc0/machine
}

# Configure VAR-SOM-MX8M-PLUS WIFI/BT pins
config_pins()
{
	if board_is_var_som_mx8m_plus; then
		WIFI_PWR_GPIO=${WIFI_PWR_GPIO_SOM}
		WIFI_EN_GPIO=${WIFI_EN_GPIO_SOM}
		BT_BUF_GPIO=${BT_BUF_GPIO_SOM}
		BT_EN_GPIO=${BT_EN_GPIO_SOM}
	fi
}

# Setup WIFI control GPIOs
wifi_pre_up()
{
	# Configure WIFI/BT pins
	config_pins

	if [ ! -d /sys/class/gpio/gpio${WIFI_PWR_GPIO} ]; then
		echo ${WIFI_PWR_GPIO} > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/direction
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
	# Configure WIFI/BT pins
	config_pins

	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	# WIFI_PWR up
	echo 1 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
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
	# Configure WIFI/BT pins
	config_pins

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

	# WIFI_PWR down
	echo 0 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
}

# Return true if SOM has WIFI module assembled
wifi_is_available()
{
	# Read SOM options EEPROM field
	opt=$(i2cget -f -y 0x0 0x52 0x20)

	# Check WIFI bit in SOM options
	if [ $((opt & 0x1)) -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

# Return true if WIFI should be started
wifi_should_not_be_started()
{
	# Do not start WIFI if it is not available
	if ! wifi_is_available; then
		return 0
	fi

	# Do not start WIFI if it is already started
	[ -d /sys/class/net/wlan0 ] && return 0

	return 1
}

# Return true if WIFI should not be stopped
wifi_should_not_be_stopped()
{
	# Do not stop WIFI if it is not available
	if ! wifi_is_available; then
		return 0
	fi

	return 1
}
