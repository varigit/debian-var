#!/bin/sh

. /etc/wifi/variscite-wifi.conf
. /etc/wifi/variscite-wifi-common.sh

case $1 in

"suspend")
        wifi_down
        ;;
"resume")
        wifi_up
        ;;
esac
