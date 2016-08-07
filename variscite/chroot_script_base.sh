echo "I: install bluetooth init.d script"
update-rc.d variscite-bluetooth defaults

echo "I: fix BT exception"
chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper

echo "I: update packages repositories"
apt-get update
apt-get upgrade -y

echo "I: install building dependencies"
apt-get install -y automake libtool

sync
