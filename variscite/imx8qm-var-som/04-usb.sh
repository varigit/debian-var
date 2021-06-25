#!/bin/sh

MODULE="usb3503"

case $1 in

"suspend")
        modinfo $MODULE >/dev/null 2>/dev/null && modprobe -r $MODULE
        ;;
"resume")
        modinfo $MODULE >/dev/null 2>/dev/null && modprobe $MODULE
        ;;
esac
