echo "I: install gpu libs"
cd /usr/local/src/imx/imx-gpu-viv-5.0.11.*
cp -dr g2d/usr/* /usr
cp -dr gpu-core/usr/* /usr
cp -dr gpu-demos/opt/* /opt
cp -dr gpu-tools/gmem-info/usr/* /usr
rm /usr/lib/libGAL.fb.so /usr/lib/libVIVANTE.fb.so
backend=x11
ln -sf libEGL-${backend}.so /usr/lib/libEGL.so
ln -sf libEGL-${backend}.so /usr/lib/libEGL.so.1
ln -sf libEGL-${backend}.so /usr/lib/libEGL.so.1.0
ln -sf libGAL-${backend}.so /usr/lib/libGAL.so
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so.2
ln -sf libGLESv2-${backend}.so /usr/lib/libGLESv2.so.2.0.0
ln -sf libVIVANTE-${backend}.so /usr/lib/libVIVANTE.so
ln -sf libGAL_egl.dri.so /usr/lib/libGAL_egl.so
rm /usr/lib/*-fb.so /usr/lib/*-wl.so
rm /usr/lib/arm-linux-gnueabihf/libGL.so.*                               
rm /usr/lib/arm-linux-gnueabihf/libGLESv2.so.*                           
rm /usr/lib/arm-linux-gnueabihf/libEGL.so.*                              
for i in egl glesv1_cm glesv2 vg; do
cp /usr/lib/pkgconfig/${i}_${backend}.pc /usr/lib/pkgconfig/${i}.pc
done

echo "I: install imx xorg libs"
cd /usr/local/src/imx/xserver-xorg-video-imx-viv-5.0.11.*
#make BUILD_HARD_VFP=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 CFLAGS=-I/usr/local/include/drm prefix=/usr all
#make BUILD_HARD_VFP=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 CFLAGS=-I/usr/local/include/drm prefix=/usr install
make BUILD_IN_YOCTO=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 CFLAGS=-I/usr/local/include/drm prefix=/usr all > /dev/null
make BUILD_IN_YOCTO=1 XSERVER_GREATER_THAN_13=1 BUSID_HAS_NUMBER=1 CFLAGS=-I/usr/local/include/drm prefix=/usr install > /dev/null

echo "I: install rc.autohdmi init.d script"
update-rc.d rc.autohdmi defaults

sync
