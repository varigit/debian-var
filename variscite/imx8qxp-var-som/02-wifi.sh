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
        if [ -f /etc/init.d/connman ]; then
                killall -9 wpa_supplicant
                /etc/init.d/connman restart
        fi
        if [ -f /etc/systemd/system/multi-user.target.wants/connman.service ]; then
                killall -9 wpa_supplicant
                systemctl restart connman.service
        fi
        ;;
esac

