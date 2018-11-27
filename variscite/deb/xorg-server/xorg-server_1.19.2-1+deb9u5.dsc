-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 1.0
Source: xorg-server
Binary: xserver-xorg-core, xserver-xorg-core-udeb, xserver-xorg-dev, xdmx, xdmx-tools, xnest, xvfb, xserver-xephyr, xserver-common, xorg-server-source, xwayland, xserver-xorg-legacy
Architecture: any all
Version: 2:1.19.2-1+deb9u5
Maintainer: Debian X Strike Force <debian-x@lists.debian.org>
Homepage: https://www.x.org/
Standards-Version: 3.9.8
Vcs-Browser: https://anonscm.debian.org/cgit/pkg-xorg/xserver/xorg-server.git
Vcs-Git: https://anonscm.debian.org/git/pkg-xorg/xserver/xorg-server.git
Build-Depends: debhelper (>= 9), dh-autoreconf, po-debconf, dpkg-dev (>= 1.16.1), quilt, lsb-release, pkg-config, bison, flex, xutils-dev (>= 1:7.6+4), xfonts-utils (>= 1:7.5+1), x11proto-bigreqs-dev (>= 1:1.1.0), x11proto-composite-dev (>= 1:0.4), x11proto-core-dev (>= 7.0.31), x11proto-damage-dev (>= 1.1), x11proto-fixes-dev (>= 1:5.0), x11proto-fonts-dev (>= 2.1.3), x11proto-kb-dev (>= 1.0.3), x11proto-xinerama-dev, x11proto-randr-dev (>= 1.5.0), x11proto-record-dev (>= 1.13.99.1), x11proto-render-dev (>= 2:0.11), x11proto-resource-dev (>= 1.2.0), x11proto-scrnsaver-dev, x11proto-video-dev, x11proto-xcmisc-dev (>= 1.2.0), x11proto-xext-dev (>= 7.2.99.901), x11proto-xf86bigfont-dev (>= 1.2.0), x11proto-xf86dga-dev (>= 2.0.99.1), x11proto-xf86vidmode-dev (>= 2.2.99.1), x11proto-present-dev, x11proto-dri3-dev, xtrans-dev (>= 1.3.5), libxau-dev (>= 1:1.0.5-2), x11proto-input-dev (>= 2.3), x11proto-dri2-dev (>= 2.8), libxdmcp-dev (>= 1:0.99.1), libxfont-dev (>= 1:2.0.1), libxkbfile-dev (>= 1:0.99.1), libpixman-1-dev (>= 0.27.2), libpciaccess-dev (>= 0.12.901), libgcrypt-dev, nettle-dev, libudev-dev (>= 151-3) [linux-any], libselinux1-dev (>= 2.0.80) [linux-any], libaudit-dev [linux-any], x11proto-xf86dri-dev (>= 2.1.0), libdrm-dev (>= 2.4.46) [!hurd-i386], x11proto-gl-dev (>= 1.4.17), libgl1-mesa-dev (>= 9.2), libxmuu-dev (>= 1:0.99.1), libxext-dev (>= 1:0.99.1), libx11-dev (>= 2:1.6), libxrender-dev (>= 1:0.9.0), libxi-dev (>= 2:1.6.99.1), x11proto-dmx-dev (>= 1:2.2.99.1), libdmx-dev (>= 1:1.0.1), libxpm-dev (>= 1:3.5.3), libxaw7-dev (>= 1:0.99.1), libxt-dev (>= 1:0.99.1), libxmu-dev (>= 1:0.99.1), libxtst-dev (>= 1:0.99.1), libxres-dev (>= 1:0.99.1), libxfixes-dev (>= 1:3.0.0), libxv-dev, libxinerama-dev, libxshmfence-dev (>= 1.1) [!hurd-i386], libepoxy-dev [linux-any kfreebsd-any], libegl1-mesa-dev [linux-any kfreebsd-any], libgbm-dev (>= 10.2) [linux-any kfreebsd-any], libxcb1-dev, libxcb-xkb-dev, libxcb-shape0-dev, libxcb-render0-dev, libxcb-render-util0-dev, libxcb-util0-dev, libxcb-image0-dev, libxcb-icccm4-dev, libxcb-shm0-dev, libxcb-keysyms1-dev, libxcb-randr0-dev, libxcb-xv0-dev, libxcb-glx0-dev, libxcb-xf86dri0-dev (>= 1.6), xkb-data, x11-xkb-utils, libbsd-dev, libwayland-dev [linux-any], wayland-protocols (>= 1.1) [linux-any], libdbus-1-dev (>= 1.0) [linux-any], libsystemd-dev [linux-any]
Package-List:
 xdmx deb x11 optional arch=any
 xdmx-tools deb x11 optional arch=any
 xnest deb x11 optional arch=any
 xorg-server-source deb x11 optional arch=all
 xserver-common deb x11 optional arch=all
 xserver-xephyr deb x11 optional arch=any
 xserver-xorg-core deb x11 optional arch=any
 xserver-xorg-core-udeb udeb debian-installer optional arch=any
 xserver-xorg-dev deb x11 optional arch=any
 xserver-xorg-legacy deb x11 extra arch=any
 xvfb deb x11 optional arch=any
 xwayland deb x11 optional arch=linux-any
Checksums-Sha1:
 3648335593b9d267e44737b89694d38b99e3aee4 8321615 xorg-server_1.19.2.orig.tar.gz
 ce2e9abce7687b28a7047d473a52c3263ffbbbf2 147930 xorg-server_1.19.2-1+deb9u5.diff.gz
Checksums-Sha256:
 191d91d02c059c66747635e145c30bc1004e703fe3b74439e26c0d05d5c4d28b 8321615 xorg-server_1.19.2.orig.tar.gz
 6d7a575445285e976790466b7b9f092f1dcbc300bb10a4d63d0fd57b8db86098 147930 xorg-server_1.19.2-1+deb9u5.diff.gz
Files:
 dfa411de6ce6fe35128d3b2e06941135 8321615 xorg-server_1.19.2.orig.tar.gz
 1f8ec0d26d787268f4071da483e27f55 147930 xorg-server_1.19.2-1+deb9u5.diff.gz

-----BEGIN PGP SIGNATURE-----

iQJFBAEBCgAvFiEE45C5cAWC+uqVmsrUHu9T04o6nGcFAlvcQAARHGFib2xsQGRl
Ymlhbi5vcmcACgkQHu9T04o6nGeN0RAAhNXAVp4Ou4XuphibJ1wBSnc/eCBlL1Jj
c2cqtZUwghp87t/3Kc/c45i9PllCeBCfA7TXPVwhJD2UGOAvMJbkILzqjo1dStHQ
RTZguBr7eKoGFGm9Krz99Kez15F1g4ygflcQVB+kNnuhDJmdndh7dCxbkGhI//Xu
XFuaGYgRkoiH0IfVCyvqG5xrN6eBOatuDmlz+o1uDuKSVZSD7NCm12I7fUtKjUwH
EzYe1DZAoANOJwrLT7lHEWIH4vW57vI/xaLvWLoho4AHa4VD0BaLBvRkeqTJuupZ
aOh6JZ7YJcFc2nlSKbe/ffbbZAm67ANFs1hzt8sS8PglPTTKLBmH9xK4sCOfrvzG
JCK/z75ToGX5wwOCA78PgsgXPn39Wfn6dA+NkINn2aGWEs4MTIo3yoEt68InPMXS
Q3V1RWtHXoUZ+rRANzoHKXD2BAi6jMcwUa6GhEMmom3DTNM31zbCADETovc8j0/k
5Nm/I/249S7PVXMibxX57zt/sggjHXHiHNsDQFXZHROzWw80YpKvnBJ7DkakOjHz
GKRoXCtPCOdYfV36dEsc2Qt1fH2SZafuuiiNJ9he5wVUrVUES+j6PP7ekRr3l4I+
m5b4nsr5li0ij4I9GUkSEPd2cW8EOly1HsOhJF1IQ2ZnfdnMyinooaf+3C316dzs
CqDJfqPurHY=
=ReZe
-----END PGP SIGNATURE-----
