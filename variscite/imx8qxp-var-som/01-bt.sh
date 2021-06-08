#!/bin/sh

. /etc/bluetooth/variscite-bt.conf
. /etc/bluetooth/variscite-bt-common.sh

case $1 in

"suspend")
        bt_stop
        ;;
"resume")
        bt_start
        ;;
esac

