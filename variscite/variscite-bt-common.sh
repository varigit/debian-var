# Check if WIFI+BT combo chip is available
bt_found()
{
	# Use different ID file on DART-MX6
	if [ "${BT_CHIP}" = "wl18xx" ] && grep -q DART /sys/devices/soc0/machine; then
		WIFI_SDIO_ID_FILE=${WIFI_SDIO_ID_FILE_DART}
	fi

	for i in $(seq 1 5); do
		if [ -f ${WIFI_SDIO_ID_FILE} ]; then
			echo "BT found"
			return 0
	else
		sleep 1
	fi
	done

	echo "No BT found"
	return 1
}

# Return true if SoC is from NXP i.MX8 family
soc_is_imx8()
{
	grep -q MX8 /sys/devices/soc0/soc_id
}

# Return true if SOM is VAR-SOM-MX8M-MINI
som_is_var_som_mx8mm()
{
	grep -q VAR-SOM-MX8MM /sys/devices/soc0/machine
}

# Return true if SOM is VAR-SOM-MX8M-PLUS
som_is_var_som_mx8mp()
{
	grep -q VAR-SOM-MX8M-PLUS /sys/devices/soc0/machine
}

# Enable BT via GPIO(s)
enable_bt()
{
	if som_is_var_som_mx8mp; then
		BT_EN_GPIO=${BT_EN_GPIO_SOM}
		BT_BUF_GPIO=${BT_BUF_GPIO_SOM}
		BT_TTY_DEV=${BT_TTY_DEV_SOM}
	fi

	if [ ! -d /sys/class/gpio/gpio${BT_EN_GPIO} ]; then
		echo ${BT_EN_GPIO} >/sys/class/gpio/export
		echo "out" > /sys/class/gpio/gpio${BT_EN_GPIO}/direction
	fi

	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
	sleep 1
	echo 1 > /sys/class/gpio/gpio${BT_EN_GPIO}/value

	if soc_is_imx8 ; then
		if ! som_is_var_som_mx8mm && [ ! -d /sys/class/gpio/gpio${BT_BUF_GPIO} ]; then
			echo ${BT_BUF_GPIO} >/sys/class/gpio/export
			echo "out" > /sys/class/gpio/gpio${BT_BUF_GPIO}/direction
		fi
		if ! som_is_var_som_mx8mm; then
			echo 0 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
		fi
	fi
}

# Get maximum of N numbers
max()
{
	printf "%s\n" "$@" | sort -g -r | head -n1
}

# Get BT MAC address
get_bt_macaddr()
{
	eth0_addr=$(cat /sys/class/net/eth0/address | sed 's/\://g')
	eth1_addr=$(cat /sys/class/net/eth1/address | sed 's/\://g')
	bt_addr=$(max $eth0_addr $eth1_addr)
	bt_addr=$((0x$bt_addr+1))
	bt_addr=$(printf '%012X' $bt_addr)

	echo $bt_addr | sed 's/\(..\)/\1:/g;s/:$//'
}

# Return true if SOM has 5G WIFI chip
som_has_5g_wifi()
{
	if [ "`cat ${WIFI_SDIO_ID_FILE}`" = "${WIFI_5G_SDIO_ID}" ]; then
		return 0
	fi

	return 1
}

# Start BT hardware
bt_start()
{
	# Exit if BT is not available
	bt_found || exit 0

	# Enable BT hardware
	enable_bt

	if [ "${BT_CHIP}" = "wl18xx" ]; then
		# Attach UART to bluetooth stack
		hciattach -t 10 -s 115200 ${BT_TTY_DEV} texas 3000000
		# Enable SCO over HCI
		hcitool cmd 0x3f 0x210 0x01 0x00 0x00 0xff
	else
		# Get BT MAC address
		if ! soc_is_imx8; then
			BT_MACADDR=$(get_bt_macaddr)
		fi

		# On SOMs with 5G WIFI use different firmware binary
		if som_has_5g_wifi; then
			BT_FIRMWARE=${BT_FIRMWARE_5G}
		fi

		# On VAR-SOM-MX8M-MINI use different UART
		if som_is_var_som_mx8mm; then
			BT_TTY_DEV=${BT_TTY_DEV_SOM}
		fi

		# Load BT firmware and set MAC address (if necessary)
		kill -9 $(pidof brcm_patchram_plus) 2>/dev/null || true
		if soc_is_imx8; then
			brcm_patchram_plus \
				--patchram ${BT_FIRMWARE} \
				--enable_hci \
				--no2bytes \
				--baudrate 3000000 \
				--scopcm=1,0,0,0,0,0,0,0,0,0 \
				--tosleep 1000 ${BT_TTY_DEV} &
		else
			brcm_patchram_plus \
				--patchram ${BT_FIRMWARE} \
				--enable_hci \
				--bd_addr ${BT_MACADDR} \
				--no2bytes \
				--baudrate 3000000 \
				--scopcm=1,0,0,0,0,0,0,0,0,0 \
				--tosleep 1000 ${BT_TTY_DEV} &
		fi
	fi
}

# Stop BT hardware
bt_stop()
{
	if som_is_var_som_mx8mp; then
		BT_EN_GPIO=${BT_EN_GPIO_SOM}
		BT_BUF_GPIO=${BT_BUF_GPIO_SOM}
		BT_TTY_DEV=${BT_TTY_DEV_SOM}
	fi

	hciconfig hci0 down

	if [ "${BT_CHIP}" = "wl18xx" ]; then
		kill -9 $(pidof hciattach) 2>/dev/null || true
	else
		kill -9 $(pidof brcm_patchram_plus) 2>/dev/null || true
	fi

	# BT_BUF down
	if soc_is_imx8 && ! som_is_var_som_mx8mm; then
		echo 1 > /sys/class/gpio/gpio${BT_BUF_GPIO}/value
	fi

	# BT_EN down
	echo 0 > /sys/class/gpio/gpio${BT_EN_GPIO}/value
}
