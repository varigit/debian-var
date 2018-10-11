-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Format: 1.0
Source: xorg-server
Binary: xserver-xorg-core, xserver-xorg-core-udeb, xserver-xorg-dev, xdmx, xdmx-tools, xnest, xvfb, xserver-xephyr, xserver-common, xorg-server-source, xwayland, xserver-xorg-legacy
Architecture: any all
Version: 2:1.19.2-1+deb9u2
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
 c352c5a16c4ff5e8840a5bb638f5c9d04b6eec92 146613 xorg-server_1.19.2-1+deb9u2.diff.gz
Checksums-Sha256:
 191d91d02c059c66747635e145c30bc1004e703fe3b74439e26c0d05d5c4d28b 8321615 xorg-server_1.19.2.orig.tar.gz
 75c8eb9f8ca229e024d41803ba145c563474eae12f0a7672c20e55d607cb233d 146613 xorg-server_1.19.2-1+deb9u2.diff.gz
Files:
 dfa411de6ce6fe35128d3b2e06941135 8321615 xorg-server_1.19.2.orig.tar.gz
 facde1eb6be2a640e313194b803a6b31 146613 xorg-server_1.19.2-1+deb9u2.diff.gz

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEVXgdqzTmGgnvuIvhnbAjVVb4z60FAlnkYVoACgkQnbAjVVb4
z61diA/9EacaIhNqectVPwX/uRVwygj+AeLkaXGIe8AXsO7kChl/J8tPM1Hgishw
yDIIWZl820Ywp/CwP4pw/md0Gmjsj+/qqTx3ST/UGwTkFCKR6Zm2FcjvRJNyPblv
90XRExqdy3iFt/64+4L8ofmwxGnNdJfEIBIxuTYck+iGLJadv1hLLkVcyA3BarGN
D0zdqxt8m0Lg1YVE/j//Z3INwK2VEiIf0i6I+r1RVXEMx/spQX+Mee/03obBpKC7
JdGaK5U3X6f1k8O2fGq5Azbr8bUoutz++9kpyZnSOKyWV0tBqPUfbHmHxS77t3+V
3jdBXPwTbKX06eoN7hO8qfyT1iEVn7K3rFGa0/xiyGM7aOCBr2SxuCpzZrv8nNBJ
hWp6F6x0CUZ9LkptjErgQDNglo2BJQ7i6zcm8G57x7/c6HBCWDxD0X+fTXm3GoRQ
7TiliAQCVaznHazrA0TcZW4081sXR1KpImhq3idsIViOfnOWOXzsT1nOiVxCB4fl
SV50uaU8pQix+GDk62qp8TKGaO3ruhk6KBwg2ruI73jp3kBSd4pzIYrb/YAgG8lg
l/jkfR3xGMgDn887BqX3D+o9sjz92DUPW8Ro4OS5qk2S9YMz02bZwiC3efXBPQTB
F7KZLW1usrLJKBsnfxi48+kefGuJ1qMrIFZFhAOHENxUwuORXpI=
=5VNQ
-----END PGP SIGNATURE-----
