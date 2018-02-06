echo "I: install gpu libs"
mkdir -p /usr/lib/pkgconfig
mkdir -p /usr/include
mkdir -p /usr/bin
mkdir -p /etc/OpenCL/vendors
cd /usr/local/src/imx/imx-gpu-g2d*
cp -dr g2d/usr/* /usr
cp -dr gpu-demos/opt/* /opt
cd /usr/local/src/imx/imx-gpu-viv*
cp -dr gpu-core/usr/lib/*.so* /usr/lib
cp -dr gpu-core/usr/lib/dri /usr/lib
cp -dr gpu-core/usr/include/* /usr/include
cp -dr gpu-demos/opt/* /opt
cp -dr gpu-tools/gmem-info/usr/bin/* /usr/bin

cp -dr gpu-core/usr/lib/pkgconfig/gl_x11.pc /usr/lib/pkgconfig/gl.pc
cp -dr gpu-core/usr/lib/pkgconfig/egl_x11.pc /usr/lib/pkgconfig/egl.pc
cp -dr gpu-core/usr/lib/pkgconfig/glesv1_cm_x11.pc /usr/lib/pkgconfig/glesv1_cm.pc
cp -dr gpu-core/usr/lib/pkgconfig/glesv2_x11.pc /usr/lib/pkgconfig/glesv2.pc
cp -dr gpu-core/usr/lib/pkgconfig/vg_x11.pc /usr/lib/pkgconfig/vg.pc

cp -dr gpu-core/etc/Vivante.icd /etc/OpenCL/vendors/Vivante.icd

rm /usr/lib/libGL.so.* /usr/lib/*-fb.so /usr/lib/*-wl.so
mv /usr/lib/libGL.so /usr/lib/libGL-x11.so

backend=x11
ln -sf libGL-${backend}.so /usr/lib/libEGL.so
ln -sf libGL-${backend}.so /usr/lib/libEGL.so.1
ln -sf libGL-${backend}.so /usr/lib/libEGL.so.1.2
ln -sf libGL-${backend}.so /usr/lib/libEGL.so.1.2.0
ln -sf libEGL-${backend}.so /usr/lib/libEGL.so
ln -sf libEGL-${backend}.so /usr/lib/libEGL.so.1
ln -sf libEGL-${backend}.so /usr/lib/libEGL.so.1.0
ln -sf libGAL-${backend}.so /usr/lib/libGAL.so
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so.2
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so.2.0
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so.2.0.0
ln -sf libVDK-${backend}.so /usr/lib/libVDK.so
ln -sf libGAL_egl.dri.so /usr/lib/libGAL_egl.so
rm /usr/lib/arm-linux-gnueabihf/libGL.so.*                               
rm /usr/lib/arm-linux-gnueabihf/libGLESv2.so.*                           
rm /usr/lib/arm-linux-gnueabihf/libEGL.so.*                              

echo "I: install imx xorg libs"
cd /usr/local/src/imx/xf86-video-imx-vivante
make BUILD_IN_YOCTO=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 CFLAGS=-I/usr/local/include/drm prefix=/usr all > /dev/null
make BUILD_IN_YOCTO=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 CFLAGS=-I/usr/local/include/drm prefix=/usr install > /dev/null

echo "I: install rc.autohdmi init.d script"
update-rc.d rc.autohdmi defaults

sync
