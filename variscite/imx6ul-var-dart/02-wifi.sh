#!/bin/sh

[ -x /etc/wifi/variscite-wifi ] || exit 0

case $1 in

"suspend")
        /etc/wifi/variscite-wifi stop
        ;;
"resume")
        /etc/wifi/variscite-wifi start

        if [ -f /etc/init.d/connman ]; then
                killall -9 wpa_supplicant
                /etc/init.d/connman restart
        fi
        if [ -f /etc/systemd/system/multi-user.target.wants/connman.service ]; then
                killall -9 wpa_supplicant
                systemctl restart connman.service
        fi

        if [ -f /etc/systemd/system/multi-user.target.wants/networking.service ]; then
                killall -9 wpa_supplicant
                systemctl restart networking.service
        elif [ -f /etc/init.d/networking ]; then
                killall -9 wpa_supplicant
                /etc/init.d/networking restart
        fi
        ;;
esac

