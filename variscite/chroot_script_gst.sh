#!/bin/bash

# ref https://github.com/Freescale/gstreamer-imx/blob/master/docs/debian-ubuntu.md
echo "I: install gstreamer-imx dependencies"
apt-get install -y gstreamer1.0-x gstreamer1.0-plugins-base-apps libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev
apt-get install -y gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-plugins-good
apt-get install -y autoconf automake build-essential libtool pkg-config python libpango1.0-dev

echo "I: install libvpu"
cd /usr/local/src/imx/imx-vpu*
make PLATFORM=IMX6Q INCLUDE="-I/usr/local/include/uapi -I/usr/local/include" all > /dev/null
make PLATFORM=IMX6Q install > /dev/null

echo "I: install imx codecs"
cd /usr/local/src/imx/imx-codec*
./autogen.sh --prefix=/usr --enable-fhw --enable-vpu
make all > /dev/null
make install > /dev/null
mv /usr/lib/imx-mm/video-codec/lib* /usr/lib
mv /usr/lib/imx-mm/audio-codec/lib* /usr/lib
rm -rf /usr/lib/imx-mm

sync; sleep 1

echo "I: install libimxvpuapi"
cd /usr/local/src/imx/libimxvpuapi
./waf configure --prefix=/usr
./waf -j1
./waf install

echo "I: install gstreamer-imx"
cd /usr/local/src/imx/gstreamer-imx
export CFLAGS=-I/usr/include/vivante
export LDFLAGS=-L/usr/lib/arm-linux-gnueabihf/vivante
./waf configure --prefix=/usr --kernel-headers=/usr/local/include
./waf -j1
./waf install
mv /usr/lib/libgstimx* /usr/lib/arm-linux-gnueabihf/
mv /usr/lib/gstreamer-1.0/libgstimx* /usr/lib/arm-linux-gnueabihf/gstreamer-1.0/
rmdir /usr/lib/gstreamer-1.0

sync
