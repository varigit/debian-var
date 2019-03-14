echo "I: fix BT exception"
chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper

echo "I: update packages repositories"
apt-get update
apt-get upgrade -y

echo "I: install building dependencies"
apt-get install -y autoconf automake build-essential libtool pkg-config python

echo "I: install virtual keyboard"
apt-get install -y onboard

sync
