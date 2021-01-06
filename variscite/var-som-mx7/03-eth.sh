#!/bin/bash -e

case $1 in

"suspend")
	ifconfig eth0 down
	ifconfig eth1 down
	;;
"resume")
	ifconfig eth0 up
	ifconfig eth1 up
	;;
esac
