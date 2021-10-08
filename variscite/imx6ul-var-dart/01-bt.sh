#!/bin/sh

[ -x /etc/bluetooth/variscite-bt ] || exit 0

case $1 in

"suspend")
        /etc/bluetooth/variscite-bt stop
        ;;
"resume")
        /etc/bluetooth/variscite-bt start
        ;;
esac
