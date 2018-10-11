#!/bin/bash

export VERSION=$(dpkg-query -f '${source:Version}\n' -W xserver-xorg-core)
export PKGVERSION=${VERSION#*:}
export BASEVERSION=${PKGVERSION%-*}
export DEBPATH="/usr/local/src/deb/xorg-server"
export SRCPATH="${DEBPATH}/xorg-server-${BASEVERSION}"
export PTCPATH="${DEBPATH}/patches"

cd ${DEBPATH}

if [ ! -f xserver-common_${PKGVERSION}_all.deb ] ; then

	echo "################################################"
	echo "# no xorg-server ${PKGVERSION} packages found  #"
	echo "# please notify this condition at              #"
	echo "# https://github.com/varigit/debian-var/issues #"
	echo "# reporting the above message                  #"
	echo "# Thanks                                       #"
        echo "# Variscite R&D Team                           #"
	echo "################################################"

	echo "I: get xorg-server ${VERSION} and build deps"
	apt install -y libbsd-dev
	apt source xorg-server=${VERSION}
	apt build-dep -y xorg-server=${VERSION}

	echo "I: apply ARM DRM patch"
	cd /usr/include/
	patch -p1 < ${PTCPATH}/libdrm/drm-update-arm.patch

	if [ -d ${PTCPATH}/${BASEVERSION} ] ; then
		echo "I: adding patches for xorg-server ${BASEVERSION}"
		cd ${PTCPATH}/${BASEVERSION}
		cp *.patch ${SRCPATH}/debian/patches
		ls >> ${SRCPATH}/debian/patches/series
	fi
	if [ -d ${PTCPATH}/common ] ; then
		echo "I: adding misc patches for xorg-server"
		cd ${PTCPATH}/common
		cp *.patch ${SRCPATH}/debian/patches
		ls >> ${SRCPATH}/debian/patches/series
	fi

	cd ${SRCPATH}
	echo "I: rebuild xorg-server ${VERSION} against ARM DRM patch"
	dpkg-buildpackage -b -j4 -us -uc
	cd ${DEBPATH}
else
	echo "I: install distro xorg-server deps"
	apt install -y xserver-common xserver-xorg-core xserver-xorg-dev xserver-xorg-legacy
fi

echo "I: install and hold packages with patched ARM DRM"
suffix="all"
pkg="xserver-common"
dpkg -i ${pkg}_${PKGVERSION}_${suffix}.deb; apt-mark hold ${pkg}
suffix="armhf"
pkgs=("xserver-xorg-core" "xserver-xorg-dev" "xserver-xorg-legacy")
for pkg in "${pkgs[@]}" ; do
	dpkg -i ${pkg}_${PKGVERSION}_${suffix}.deb; apt-mark hold ${pkg}
done
sync
