#!/bin/sh

# Check if Ethernet should be powered down during suspend
eth_should_be_down_in_suspend()
{
	# TODO specifically check for VAR-SOM-6UL
	if [ ! `grep -q DART /sys/devices/soc0/machine` ] ; then
		return 0
	else
		return 1
	fi
}

eth_should_be_down_in_suspend || exit 0

case $1 in

"suspend")
        ifconfig eth1 down
        ;;
"resume")
        ifconfig eth1 up
        ;;
esac

