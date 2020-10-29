#!/bin/sh

. /etc/wifi/variscite-wifi.conf
. /etc/wifi/variscite-wifi-common.sh

# Exit if WIFI is not available
if wifi_should_not_be_stopped; then
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

