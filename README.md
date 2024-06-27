fork from Variscite debian bullseye repo ([release notes](https://variwiki.com/index.php?title=VAR-SOM-MX8M-NANO_Release_Notes&release=RELEASE_BULLSEYE_5.4.142_V1.0_VAR-SOM-MX8M-NANO)) that will have any modifications we have to their image
# Building Device Trees
1. First you may need to run `sudo MACHINE=imx8mn-var-som ./var_make_debian.sh -c deploy` to pull the relevant repos into this one so we can build using our kernel which contains our device trees
2. once you've done that run `sudo MACHINE=imx8mn-var-som ./var_make_debian.sh -c kernel`
3. The device trees should show up in the output folder which you can then copy over to your variscite device in the `/boot` directory and reboot
	1. Do make sure that `fw_printenv fdt_file` prints out the file that you are putting in boot
	2. If it doesn't then run `fw_setenv fdt_file <your dtb file>`
 
