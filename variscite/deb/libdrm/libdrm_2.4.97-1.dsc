-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 1.0
Source: libdrm
Binary: libdrm-dev, libdrm2, libdrm-common, libdrm2-udeb, libdrm-intel1, libdrm-nouveau2, libdrm-radeon1, libdrm-omap1, libdrm-freedreno1, libdrm-exynos1, libdrm-tegra0, libdrm-amdgpu1, libdrm-etnaviv1
Architecture: linux-any kfreebsd-any any-arm all
Version: 2.4.97-1
Maintainer: Debian X Strike Force <debian-x@lists.debian.org>
Uploaders: Andreas Boll <aboll@debian.org>
Homepage: https://cgit.freedesktop.org/mesa/drm/
Standards-Version: 4.1.4
Vcs-Browser: https://salsa.debian.org/xorg-team/lib/libdrm
Vcs-Git: https://salsa.debian.org/xorg-team/lib/libdrm
Build-Depends: debhelper (>= 11), meson, quilt, xsltproc, docbook-xsl, libx11-dev, pkg-config, xutils-dev (>= 1:7.6+2), libudev-dev [linux-any], libpciaccess-dev, valgrind [amd64 armhf i386 mips mipsel powerpc s390x]
Package-List:
 libdrm-amdgpu1 deb libs optional arch=linux-any,kfreebsd-any
 libdrm-common deb libs optional arch=all
 libdrm-dev deb libdevel optional arch=linux-any,kfreebsd-any
 libdrm-etnaviv1 deb libs optional arch=armhf,arm64
 libdrm-exynos1 deb libs optional arch=any-arm
 libdrm-freedreno1 deb libs optional arch=any-arm,arm64
 libdrm-intel1 deb libs optional arch=amd64,i386,kfreebsd-amd64,kfreebsd-i386,x32
 libdrm-nouveau2 deb libs optional arch=linux-any
 libdrm-omap1 deb libs optional arch=any-arm
 libdrm-radeon1 deb libs optional arch=linux-any,kfreebsd-any
 libdrm-tegra0 deb libs optional arch=any-arm,arm64
 libdrm2 deb libs optional arch=linux-any,kfreebsd-any
 libdrm2-udeb udeb debian-installer optional arch=linux-any,kfreebsd-any
Checksums-Sha1:
 af778f72d716589e9eacec9336bafc81b447cc42 1124510 libdrm_2.4.97.orig.tar.gz
 87ffdc7a7eb2475ec3b2d933a04d769383a3ff52 51561 libdrm_2.4.97-1.diff.gz
Checksums-Sha256:
 8c6f4d0934f5e005cc61bc05a917463b0c867403de176499256965f6797092f1 1124510 libdrm_2.4.97.orig.tar.gz
 8d92b18a722618ac3d800241a992d6438c82ed9009023f677ed332523cf800bd 51561 libdrm_2.4.97-1.diff.gz
Files:
 a8bb09d6f4ed28191ba6e86e788dc3a4 1124510 libdrm_2.4.97.orig.tar.gz
 8eb6abd2a1aa4216bf002e00dad85de1 51561 libdrm_2.4.97-1.diff.gz

-----BEGIN PGP SIGNATURE-----

iQJFBAEBCgAvFiEE45C5cAWC+uqVmsrUHu9T04o6nGcFAlxIU/8RHGFib2xsQGRl
Ymlhbi5vcmcACgkQHu9T04o6nGd20A/8C1W42WvzE5o43HCDXS8f98nJilHPIaa+
6/BVIauIPqWG5a2FVry744e5N+DIAWhN32ymXxwuFNznFR1LBN6TAbonVU9BMWeU
U+2zz9MeHx5sLFlqG6iETSn23Jy/13StK0rIbfYFAEBGf+wCDcqo+TGVSl384BpO
IfE3qMHK6a7uLG3KFUkeR9pOYRJ71epMxUWUUbVdRcwk7cb1+6jsa0NZGu4ibDYp
5W7MSuTTcQ5HJnBCUuZgKyYBS/zEMGG82DpxCJz44sSbNPBDi6UpjuhgvRe+LrxH
tyzA2D0crnmg6xAAk7Ysbvdvzc4crItOj6gmKi/tO1z1bIRT3l2wmcVE6/5+wfEL
1aK+KKreHNTmE8Wofkk6kTFN2qA8Y3bg42S5DFPH5L/XNcu4Vdhj0YgnLM5HrWEa
xW0onZYymSwjskGd5HzqSDQf1LTMUHUGkRL8BZ0EHltOJSAJa44o9r8S0HXxo1ws
zswQ0h5KS3TQ5eWgrnT/MQVQhmCkt1pMQOr/1IGbck/BMwY3DM2ZcwroPIKeW6pO
LiG7Tu4ewS3qIbUL2lZTMiNa+OGTubVNolqk73SycIXU0rhOfCjBVMrKGhvWPQJ6
9P5pEziNS4osi7fkeiZthC03DHrU+x5I467oxTSSt7SbuaaGK2ZIJ1o61+hxcC3I
J+R1mI0MNCQ=
=oJZl
-----END PGP SIGNATURE-----
