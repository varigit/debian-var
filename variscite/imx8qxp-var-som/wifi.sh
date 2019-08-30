#!/bin/sh

. /etc/wifi/variscite-wifi.conf
. /etc/wifi/variscite-wifi-common.sh

# Exit if WIFI is not available
if grep -q MX8QX /sys/devices/soc0/soc_id && \
   ! grep -q WIFI /sys/devices/soc0/machine ; then
        exit 0
fi

case $1 in

"suspend")
        wifi_down
        ;;
"resume")
        wifi_up
        ;;
esac
