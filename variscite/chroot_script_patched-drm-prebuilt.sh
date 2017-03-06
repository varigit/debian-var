echo "I: install imx xorg dependencies"
apt-get install -y libxext-dev libgl1-mesa-dri xserver-xorg-dev

cd /usr/local/src/deb/libdrm
echo "I: installing libdrm with arm patch"
for pkg in $(ls *.deb | grep -v dbg) ; do dpkg -i $pkg; done

cd /usr/local/src/deb/mesa
echo "I: installing mesa against patched libdrm"
dpkg -i libegl1-mesa_13.0.4-1~bpo8+1_armhf.deb libgbm1_13.0.4-1~bpo8+1_armhf.deb libgl1-mesa-dri_13.0.4-1~bpo8+1_armhf.deb libgl1-mesa-glx_13.0.4-1~bpo8+1_armhf.deb libglapi-mesa_13.0.4-1~bpo8+1_armhf.deb libgles2-mesa_13.0.4-1~bpo8+1_armhf.deb libwayland-egl1-mesa_13.0.4-1~bpo8+1_armhf.deb libxatracker2_13.0.4-1~bpo8+1_armhf.deb mesa-common-dev_13.0.4-1~bpo8+1_armhf.deb

cd /usr/local/src/deb/xorg-server
echo "I: installing xorg-server against patched libdrm"
dpkg -i xserver-common_1.17.3-2.linarojessie.2_all.deb xserver-xorg-core_1.17.3-2.linarojessie.2_armhf.deb xserver-xorg-dev_1.17.3-2.linarojessie.2_armhf.deb

echo "I: holding packages with patched libdrm"
apt-mark hold  libdrm-amdgpu1 libdrm-dev libdrm-exynos1 libdrm-freedreno1 libdrm-nouveau2 libdrm-omap1 libdrm-radeon1 libdrm-tegra0 libdrm2 libegl1-mesa libgbm1 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgles2-mesa libwayland-egl1-mesa libxatracker2 mesa-common-dev xserver-common xserver-xorg-core xserver-xorg-dev

sync
