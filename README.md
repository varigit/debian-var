/*
 * Copyright (C) 2020 CompeGPS Team S.L.
 * All rights reserved
 *
 */


# #############################################################
# Intro
# #############################################################
Orchestraion script for uboot & kernel & rootfs generation for twonav devices

- "<device>"" parameter can be: <os,twonav>-<trail,aventura,crosstop>-2018
- "-o <output_folder>"" is always optional. Default is "output"

# #############################################################
# Deploy 
# #############################################################

Deploys uboot, kernel and toolchain from it's repositories

$ ./make_var_mx6ul_dart_debian.sh -c deploy

# #############################################################
# Make all
# #############################################################

Generate full environment (uboot & kernel & rootfs). Needs deploy step

$ sudo ./make_var_mx6ul_dart_debian.sh -c all

# #############################################################
# Make only uboot
# #############################################################

Generate only u-boot binary for one device type. It will generate a binary with name "u-boot_<device>.imx".

$ sudo ./make_var_mx6ul_dart_debian.sh -c bootloader -t <device> [optional] -o <output_folder>

# #############################################################
# Make only kernel package (review once kernel is unified)
# #############################################################

Generate only kernel package forone device type. It will generate a zImage of the kernel and make the package with proper modules installed named "linux-<image,headers>-4.1.15-<device>.deb".

$ sudo ./make_var_mx6ul_dart_debian.sh -c package -t <device> [optional] -o <output_folder>

Modules instlaled on deb package will be:

- imx6ull-var-dart-<device>.dtb

# #############################################################
# Make only kernel modules (dtb)
# #############################################################

Generate only all  "*.dtb" files

$ sudo ./make_var_mx6ul_dart_debian.sh -c modules [optional] -o <output_folder>

Modules deployed will be:

- imx6ull-var-dart-<device>.dtb

# #############################################################
# How uboot and kernel work together
# #############################################################

U-boot is the resposible of identifing which <device> is the current hardware, so u-boot has to be properly installed at first on target harware.

Once u-boot is installed, kernel will identify which hardware is with "fdt_file" parameter from u-boot and will load proper dtb from availables.

Caution: If selected dtb is not present, kernel load will FAIL, so try to always ensure that u-boot and kernel are up to date.