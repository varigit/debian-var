#!/bin/bash

echo "I: install xf86-video-imx-vivante deps"
apt-get install -y libxext-dev

echo "I: install gpu libs"
mkdir -p /etc/OpenCL/vendors
mkdir -p /usr/lib/arm-linux-gnueabihf/vivante
mkdir -p /usr/include/vivante
mkdir -p /opt/vivante

cd /usr/local/src/imx/imx-gpu-g2d*
cp -dr g2d/usr/include/* /usr/include/vivante
cp -dr g2d/usr/lib/* /usr/lib/arm-linux-gnueabihf/vivante
cp -dr gpu-demos/opt/* /opt/vivante

cd /usr/local/src/imx/imx-gpu-viv*
cp -dr gpu-core/etc/Vivante.icd /etc/OpenCL/vendors
cp -dr gpu-core/usr/include/* /usr/include/vivante
cp -dr gpu-core/usr/lib/* /usr/lib/arm-linux-gnueabihf/vivante
cp -dr gpu-demos/opt/viv_samples/* /opt/vivante
cp -dr gpu-tools/gmem-info/usr/bin/* /opt/vivante

cd /usr/lib/arm-linux-gnueabihf/vivante
ln -sf libEGL-x11.so libEGL.so
ln -sf libGAL-x11.so libGAL.so
ln -sf libGLESv2-x11.so libGLESv2.so
ln -sf libVDK-x11.so libVDK.so

ln -sf libEGL.so libEGL.so.1
ln -sf libEGL.so.1 libEGL.so.1.0

ln -sf libGLESv2.so libGLESv2.so.2
ln -sf libGLESv2.so.2 libGLESv2.so.2.0
ln -sf libGLESv2.so.2.0 libGLESv2.so.2.0.0

ln -sf libGL.so libGL.so.1
ln -sf libGL.so.1 libGL.so.1.2
ln -sf libGL.so.1.2 libGL.so.1.2.0

ln -sf libOpenVG.3d.so libOpenVG.so

cd /usr/lib/arm-linux-gnueabihf/dri
ln -sf ../vivante/dri/vivante_dri.so vivante_dri.so
cd /usr/lib
ln -sf arm-linux-gnueabihf/dri dri

echo "I: update mesa symbolic links"
cd /usr/lib/arm-linux-gnueabihf
ln -sf libEGL.so.1 libEGL.so
ln -sf libGLESv2.so.2 libGLESv2.so
ln -sf libGL.so.1 libGL.so

echo "/usr/lib/arm-linux-gnueabihf/vivante" > /etc/ld.so.conf.d/00-vivante.conf
ldconfig

echo "I: force mesa symbolic links"
cd /usr/lib/arm-linux-gnueabihf
ln -sf vivante/libEGL.so.1 libEGL.so.1
ln -sf vivante/libGLESv2.so.2 libGLESv2.so.2
ln -sf vivante/libGL.so.1 libGL.so.1

echo "I: install xf86-video-imx-vivante libs"
cd /usr/local/src/imx/xf86-video-imx-vivante
make BUILD_IN_YOCTO=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 prefix=/usr > /dev/null
make BUILD_IN_YOCTO=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 prefix=/usr install > /dev/null

sync
