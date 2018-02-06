echo "I: install imx xorg dependencies"

mkdir -p /usr/local/src/deb/libdrm
cd /usr/local/src/deb/libdrm
export VERSION=$(dpkg-query -f '${source:Version}\n' -W libdrm-dev)
export BASEVERSION=${VERSION%-*}
echo "I: rebuilding libdrm $VERSION with arm patch"
apt-get source libdrm=$VERSION
apt-get build-dep -y libdrm=$VERSION
cd libdrm-$BASEVERSION
wget https://raw.githubusercontent.com/Freescale/meta-fsl-arm/jethro/recipes-graphics/drm/libdrm/mx6/drm-update-arm.patch -O debian/patches/drm-update-arm.patch
echo drm-update-arm.patch >> debian/patches/series
dpkg-buildpackage -b -j4 -us -uc
cd ..
for pkg in $(ls *.deb | grep -v dbg) ; do dpkg -i $pkg; done

mkdir -p /usr/local/src/deb/mesa
cd /usr/local/src/deb/mesa
export VERSION=$(dpkg-query -f '${source:Version}\n' -W mesa-common-dev)
export BASEVERSION=${VERSION%-*}
echo "I: rebuilding mesa $VERSION against patched libdrm"
apt-get source mesa=$VERSION
apt-get build-dep -y mesa=$VERSION
cd mesa-$BASEVERSION
dpkg-buildpackage -b -j4 -us -uc
cd ..
#for pkg in $(ls *.deb | grep -v dbg) ; do dpkg -i $pkg; done
dpkg -i libegl1-mesa_$VERSION\_armhf.deb libgbm1_$VERSION\_armhf.deb libgl1-mesa-dri_$VERSION\_armhf.deb libgl1-mesa-glx_$VERSION\_armhf.deb libglapi-mesa_$VERSION\_armhf.deb libgles2-mesa_$VERSION\_armhf.deb libwayland-egl1-mesa_$VERSION\_armhf.deb libxatracker2_$VERSION\_armhf.deb mesa-common-dev_$VERSION\_armhf.deb

#mkdir -p /usr/local/src/deb/mesa-demos
#cd /usr/local/src/deb/mesa-demos
#export VERSION=$(dpkg-query -f '${source:Version}\n' -W mesa-utils)
#echo "I: rebuilding mesa-demos $VERSION against patched libdrm"
#apt-get source mesa-demos=$VERSION
#apt-get build-dep -y mesa-demos=$VERSION
#cd mesa-*
#dpkg-buildpackage -b -j4 -us -uc
#cd ..
#for pkg in $(ls *.deb | grep -v dbg) ; do dpkg -i $pkg; done

mkdir -p /usr/local/src/deb/xorg-server
cd /usr/local/src/deb/xorg-server
export VERSION=$(dpkg-query -f '${source:Version}\n' -W xserver-xorg-dev)
export BASEVERSION=${VERSION#*:}
echo "I: rebuilding xorg-server $VERSION against patched libdrm"
apt-get source xorg-server=$VERSION
apt-get build-dep -y xorg-server=$VERSION
export VERSION=$BASEVERSION
export BASEVERSION=${VERSION%-*}
cd xorg-server-$BASEVERSION
dpkg-buildpackage -b -j4 -us -uc
cd ..
#for pkg in $(ls *.deb | grep -v dbg) ; do dpkg -i $pkg; done
dpkg -i xserver-common_$VERSION\_all.deb xserver-xorg-core_$VERSION\_armhf.deb xserver-xorg-dev_$VERSION\_armhf.deb

echo "I: holding packages with patched libdrm"
apt-mark hold  libdrm-amdgpu1 libdrm-dev libdrm-exynos1 libdrm-freedreno1 libdrm-nouveau2 libdrm-omap1 libdrm-radeon1 libdrm-tegra0 libdrm2 libegl1-mesa libgbm1 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgles2-mesa libwayland-egl1-mesa libxatracker2 mesa-common-dev xserver-common xserver-xorg-core xserver-xorg-dev

sync
