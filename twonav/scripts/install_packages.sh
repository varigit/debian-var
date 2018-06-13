#!/bin/sh -e
Xorg & 
rm -rf /etc/twonav/DeviceTester.ini
sleep 1
DISPLAY=:0 DeviceInstaller &
pid_installer=$! # Process Id of the previous running command
while kill -0 $pid_installer
do
    sleep 0.1
done
echo "Setting right permissions and owner"
chown syslog:adm /var/log/syslog
chown syslog:adm /var/log/kern.log
sync
reboot
