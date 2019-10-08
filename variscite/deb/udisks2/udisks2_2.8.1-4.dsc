-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: udisks2
Binary: udisks2, udisks2-bcache, udisks2-btrfs, udisks2-lvm2, udisks2-vdo, udisks2-zram, udisks2-doc, libudisks2-0, libudisks2-dev, gir1.2-udisks-2.0
Architecture: linux-any all
Version: 2.8.1-4
Maintainer: Utopia Maintenance Team <pkg-utopia-maintainers@lists.alioth.debian.org>
Uploaders: Michael Biebl <biebl@debian.org>, Martin Pitt <mpitt@debian.org>,
Homepage: https://www.freedesktop.org/wiki/Software/udisks
Standards-Version: 4.2.1
Vcs-Browser: https://salsa.debian.org/utopia-team/udisks2
Vcs-Git: https://salsa.debian.org/utopia-team/udisks2.git
Testsuite: autopkgtest
Testsuite-Triggers: cryptsetup-bin, dosfstools, gir1.2-glib-2.0, kpartx, libatasmart-bin, libblockdev-crypto2, lvm2, make, mdadm, policykit-1, python3-dbus, python3-gi, reiserfsprogs, targetcli-fb, xfsprogs
Build-Depends: debhelper (>= 11), gobject-introspection (>= 1.30), gtk-doc-tools, intltool (>= 0.40.0), gnome-common, libacl1-dev, libatasmart-dev (>= 0.17), libblockdev-dev (>= 2.19), libblockdev-btrfs-dev, libblockdev-crypto-dev, libblockdev-fs-dev, libblockdev-kbd-dev, libblockdev-loop-dev, libblockdev-lvm-dev, libblockdev-mdraid-dev, libblockdev-part-dev (>= 2.10), libblockdev-swap-dev, libblockdev-vdo-dev, libmount-dev (>= 2.30), libgirepository1.0-dev (>= 1.30), libglib2.0-dev (>= 2.50), libgudev-1.0-dev (>= 165), libpolkit-agent-1-dev (>= 0.97), libpolkit-gobject-1-dev (>= 0.97), libsystemd-dev (>= 209), pkg-config, udev (>= 147), xsltproc, libglib2.0-doc, policykit-1-doc
Package-List:
 gir1.2-udisks-2.0 deb introspection optional arch=linux-any
 libudisks2-0 deb libs optional arch=linux-any
 libudisks2-dev deb libdevel optional arch=linux-any
 udisks2 deb admin optional arch=linux-any
 udisks2-bcache deb admin optional arch=linux-any
 udisks2-btrfs deb admin optional arch=linux-any
 udisks2-doc deb doc optional arch=all
 udisks2-lvm2 deb admin optional arch=linux-any
 udisks2-vdo deb admin optional arch=linux-any
 udisks2-zram deb admin optional arch=linux-any
Checksums-Sha1:
 e69fc1a417f4d5e116487ca735bbef89e96cc0f4 1354879 udisks2_2.8.1.orig.tar.bz2
 13507a9ae48e8313ab865522fffa7d208dc72058 16284 udisks2_2.8.1-4.debian.tar.xz
Checksums-Sha256:
 4fcf49ef63c071bb35ea6351fdc2208dd6e54dfefd6ee29ee0c414f8dfde461c 1354879 udisks2_2.8.1.orig.tar.bz2
 707eedeba7b9e656df28b8945af5d8073d07df9c7c22ad61cfa98b776866b339 16284 udisks2_2.8.1-4.debian.tar.xz
Files:
 aefebdb5a082f99b4f86cadc41352b3d 1354879 udisks2_2.8.1.orig.tar.bz2
 af7f56d9e72acef115cfaea32c272418 16284 udisks2_2.8.1-4.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEETQvhLw5HdtiqzpaW5mx3Wuv+bH0FAlxvWOQACgkQ5mx3Wuv+
bH3oaA//cpDAh6Mp9N3ObdxF2lu4pre+vCy0RPpyBHcCGf25jVMpJTHYG0m4rI4g
LJmQq76SqDV2ZAPUwRm3RPwvh0B4TwHOotu7J4rDsmWVb8UGABbAh5+bHUpUi7Pk
/cvddlhaYsBwJXJFM2n9lznaeL3td+649v2M9aWO5RuStFxBCBv2TBR5O/zlVeUs
tBSKJohZrIcSIExDMFx2Xia/TjF7Oq+zYsv6g8e0hAPViVOq/ONhKIEGyXUsOZCB
XmHvSMtUCmjk3mGbpr2PoqVVwU9kAhCshmMw8XlfZlW63pxtJBeSyjNqLJ7q/rSX
fcBvN7y1P7kAMMY9hBH21ytV5yrgE6lAhTber3oAV/UJsiSKNtmdz9jQxD6Jfhks
XApM/E5maFC13H2Sh6qWFs6tyJ6bzDgoDE5rP/KcI1HZFIp1pd9+rxYOezixDH0r
+yuHDQPUtRMyXxAeqmc8nhVKEFR9nhQ5yKcOLUHMVJ0oJ5mnST6MWySFRzugz0n8
zZLQBvq6mEhpt2LYz1aHJHPXYFfQF+XF/dZTWukpPf62yl45/s8siTPq7R0IPTPV
1fuTk2ACIxfzqo7llRigFY4UHcOYtrEScC83QCJomoZ4oh9Qq5/Mi6Dl03+7c1XM
BWJj87GgT4ylSW3oNAZdiTulZR0St7x3bAvw0+L2q9pqc4Io7Rc=
=Vr8s
-----END PGP SIGNATURE-----
