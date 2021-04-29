#!/bin/sh

case $1 in

"suspend")
        ;;
"resume")
	if [ -d /sys/class/net/eth0 ]; then
		ifconfig eth0 down
		ifconfig eth0 up
	fi
	if [ -d /sys/class/net/eth1 ]; then
		ifconfig eth1 down
		ifconfig eth1 up
	fi
        ;;
esac
