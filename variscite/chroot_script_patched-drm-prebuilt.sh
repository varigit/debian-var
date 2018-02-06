echo "I: install imx xorg dependencies"
apt-get install -y libxext-dev libgl1-mesa-dri xserver-xorg-dev

cd /usr/local/src/deb/libdrm
echo "I: installing libdrm with arm patch"
dpkg -i libdrm2_2.4.74-1_armhf.deb
dpkg -i libdrm-amdgpu1_2.4.74-1_armhf.deb libdrm-exynos1_2.4.74-1_armhf.deb libdrm-freedreno1_2.4.74-1_armhf.deb libdrm-nouveau2_2.4.74-1_armhf.deb libdrm-omap1_2.4.74-1_armhf.deb libdrm-radeon1_2.4.74-1_armhf.deb libdrm-tegra0_2.4.74-1_armhf.deb
dpkg -i libdrm-dev_2.4.74-1_armhf.deb

cd /usr/local/src/deb/mesa
echo "I: installing mesa against patched libdrm"
dpkg -i libgbm1_13.0.6-1_armhf.deb libgl1-mesa-dri_13.0.6-1_armhf.deb libglapi-mesa_13.0.6-1_armhf.deb libxatracker2_13.0.6-1_armhf.deb mesa-common-dev_13.0.6-1_armhf.deb
dpkg -i libegl1-mesa_13.0.6-1_armhf.deb libgl1-mesa-glx_13.0.6-1_armhf.deb libgles2-mesa_13.0.6-1_armhf.deb libwayland-egl1-mesa_13.0.6-1_armhf.deb

cd /usr/local/src/deb/xorg-server
echo "I: installing xorg-server against patched libdrm"
dpkg -i xserver-common_1.19.2-1_all.deb xserver-xorg-dev_1.19.2-1_armhf.deb
dpkg -i xserver-xorg-core_1.19.2-1_armhf.deb xserver-xorg-legacy_1.19.2-1_armhf.deb

cd /usr/local/src/deb/imx-gpu-viv
echo "I: installing imx-gpu-viv"
dpkg -i imx-gpu-viv-s13-all_6.2.2.p0-2_armhf.deb
dpkg -i imx-x11-default-s13_6.2.2.p0-2_armhf.deb

echo "I: holding packages with patched libdrm"
apt-mark hold  libdrm-amdgpu1 libdrm-dev libdrm-exynos1 libdrm-freedreno1 libdrm-nouveau2 libdrm-omap1 libdrm-radeon1 libdrm-tegra0 libdrm2 libegl1-mesa libgbm1 libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa libgles2-mesa libwayland-egl1-mesa libxatracker2 mesa-common-dev xserver-common xserver-xorg-core xserver-xorg-dev xserver-xorg-legacy

sync
