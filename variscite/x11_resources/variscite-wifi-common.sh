MX7_5G_FILE=/etc/wifi/wifi-5g

# Check is SOM is DART-6UL-5G
som_is_dart_6ul_5g()
{
   if ! grep -q MX6UL /sys/devices/soc0/soc_id; then
      return 1
   fi

   SOM_INFO=`i2cget -y 1 0x51 0xfd`
   if [[ $(($(($SOM_INFO >> 3)) & 0x3)) == 1 ]] ; then
      return 0
   fi

   return 1
}

# Check is SOM is VAR-SOM-MX7-5G
som_is_mx7_5g()
{
	# Check is SoC is i.MX7
	grep -q MX7 /sys/devices/soc0/soc_id || return -1

	# If WIFI type was already detected, use it
	[ -f $MX7_5G_FILE ] && return 0

	# Check that WIFI SDIO ID file exists
	if  [ ! -f ${WIFI_SDIO_ID_FILE} ]; then
		return 1
	fi

	# Check WIFI chip SDIO ID
	WIFI_SDIO_ID=`cat ${WIFI_SDIO_ID_FILE}`
	if [ "${WIFI_SDIO_ID}" != "${WIFI_5G_SDIO_ID}" ]; then
		return 1
	else
		return 0
	fi
}

cache_mx7_5g()
{
	grep -q MX7 /sys/devices/soc0/soc_id || return

	for i in `seq 1 5`; do
		if [ -f ${WIFI_SDIO_ID_FILE} ]; then
			WIFI_SDIO_ID=`cat ${WIFI_SDIO_ID_FILE}`
			if [ "${WIFI_SDIO_ID}" = "${WIFI_5G_SDIO_ID}" ]; then
				touch $MX7_5G_FILE; sync
			fi
			break
		fi

		sleep 1
	done
}

# Power up WIFI chip
wifi_up()
{
	# Unbind WIFI device from MMC controller
	if [ -e /sys/bus/platform/drivers/sdhci-esdhc-imx/${WIFI_MMC_HOST} ]; then
		echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind
	fi

	if som_is_dart_6ul_5g; then
		# WIFI power up
		echo 1 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
		usleep 10000

		# WLAN_EN up
		echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN up
		echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

		# Wait 150ms at least
		usleep 200000

		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	else
		# WLAN_EN up
		echo 1 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN up
		echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

		# Wait 150ms at least
		usleep 200000

		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	fi

	# Bind WIFI device to MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/bind

	# If found MX7-5G remember it
	cache_mx7_5g

	# Load WIFI driver
	modprobe brcmfmac
}

# Power down WIFI chip
wifi_down()
{
	# Unload WIFI driver
	modprobe -r brcmfmac

	# Unbind WIFI device from MMC controller
	echo ${WIFI_MMC_HOST} > /sys/bus/platform/drivers/sdhci-esdhc-imx/unbind

	if som_is_dart_6ul_5g; then
		# WLAN_EN down
		echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
		usleep 10000

		# WIFI power down
		echo 0 > /sys/class/gpio/gpio${WIFI_PWR_GPIO}/value
	else
		# WLAN_EN down
		echo 0 > /sys/class/gpio/gpio${WIFI_EN_GPIO}/value

		# BT_EN down
		echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	fi
}
