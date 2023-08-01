#!/bin/sh

case $1 in

"suspend")
	;;
"resume")
	for eth_interface in /sys/class/net/eth* ; do
		ifconfig $(basename ${eth_interface}) down
		ifconfig $(basename ${eth_interface}) up
	done
	;;
esac
