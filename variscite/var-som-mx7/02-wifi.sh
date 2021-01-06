#!/bin/bash -e

. /etc/wifi/variscite-wifi.conf
. /etc/wifi/variscite-wifi-common.sh

wifi_should_be_down_in_suspend || exit 0

case $1 in

"suspend")
	wifi_down
	;;
"resume")
	wifi_up
	;;
esac

