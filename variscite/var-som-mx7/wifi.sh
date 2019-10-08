#!/bin/sh

. /etc/wifi/variscite-wifi.conf
. /etc/wifi/variscite-wifi-common.sh

wifi_suspend()
{
   wifi_down
}

wifi_resume()
{
   wifi_up
   sleep 5
   /etc/bluetooth/variscite-bt
}

som_is_mx7_5g || exit 0

case $1 in

"suspend")
        wifi_suspend
        ;;
"resume")
        wifi_resume
        ;;
esac
