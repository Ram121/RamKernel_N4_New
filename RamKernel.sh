#!/bin/bash
#Example to run script ./RamKernel.sh N910 G Y 0 7

rm -r $(pwd)/output
rm arch/arm/boot/zImage
rm ramkernel/boot.img-dtb

file=$(pwd)/ramkernel/G901
if [ -f "$file" ]
then
	echo "G901F Patch found, removing..."
	patch $(pwd)/drivers/battery/max77804k_charger.c $(pwd)/ramkernel/patches/Back_from_G901/Back.max77804k_charger.c.patch
	patch $(pwd)/drivers/battery/sec_board-8084.c $(pwd)/ramkernel/patches/Back_from_G901/Back.sec_board-8084.c.patch
else
	echo "No action required, G901F patch not present.."
fi

if [ "$1" = "N910" ]; then 
	model=trlte
fi
if [ "$1" = "N915" ]; then 
	model=tblte
fi
if [ "$1" = "G901" ]; then 
	model=kccat6
fi

if [[ ( "$2" = "G" ) || ( "$2" = "F" ) || ( "$2" = "FY" ) ]]; then 
	variant=eur
fi
if [ "$2" = "P" ]; then 
	variant=spr
fi
if [ "$2" = "T" ]; then 
	variant=tmo
fi
if [ "$2" = "V" ]; then 
	variant=vzw
fi
if [ "$2" = "W8" ]; then 
	variant=can
fi
if [ "$2" = "D" ]; then 
	variant=dcm
fi
if [ "$2" = "0" ]; then 
	variant=chnzn
fi

if [ "$4" = "0" ]; then 
	sed -i '187s/new_value = 1;/new_value = 0;/' $(pwd)/security/selinux/selinuxfs.c
	echo ""
	echo "Making permissive kernel for $1$2"
	echo ""
fi
if [ "$4" = "1" ]; then 
	sed -i '187s/new_value = 0;/new_value = 1;/' $(pwd)/security/selinux/selinuxfs.c
	echo ""
	echo "Making enforcing kernel for $1$2"
	echo ""
fi

if [ "$1" = "G901" ]; then 
	patch $(pwd)/drivers/battery/max77804k_charger.c $(pwd)/ramkernel/patches/For_G901/G901.max77804k_charger.c.patch
	patch $(pwd)/drivers/battery/sec_board-8084.c $(pwd)/ramkernel/patches/For_G901/G901.sec_board-8084.c.patch
	cd $(pwd)/ramkernel
	>G901
	cd -
fi

sed -i '8s/CONFIG_LOCALVERSION="-RamKernel_RC6"/CONFIG_LOCALVERSION="-RamKernel_RC7"/' $(pwd)/arch/arm/configs/apq8084_sec_"$model"_"$variant"_defconfig

export ARCH=arm
export CROSS_COMPILE=/opt/toolchains/UBERTC-arm-eabi-4.8/bin/arm-eabi-
mkdir output
make -C $(pwd) O=output VARIANT_DEFCONFIG=apq8084_sec_"$model"_"$variant"_defconfig apq8084_sec_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -C $(pwd) O=output
cp output/arch/arm/boot/Image $(pwd)/arch/arm/boot/zImage
./tools/dtbTool -o ./ramkernel/boot.img-dtb -s 4096 -p ./output/scripts/dtc/ ./output/arch/arm/boot/dts/

if [ "$1" = "G901" ]; then 
	patch $(pwd)/drivers/battery/max77804k_charger.c $(pwd)/ramkernel/patches/Back_from_G901/Back.max77804k_charger.c.patch
	patch $(pwd)/drivers/battery/sec_board-8084.c $(pwd)/ramkernel/patches/Back_from_G901/Back.sec_board-8084.c.patch
	cd $(pwd)/ramkernel
	rm G901
	cd -
fi

if [ "$3" = "N" ]; then
    echo "Not making zip"
    exit
else
./RamScript.sh $1 $2 $4 $5 $6
fi

if [ "$2" = "G" ]; then
	./RamScript.sh $1 F $4 $5 $6
fi
if [[ ( "$1" = "910" ) && ( "$2" = "F" ) ]]; then
	./RamScript.sh $1 G $4 $5 $6
fi
if [[ ( "$1" = "915" ) && ( "$2" = "F" ) ]]; then
	./RamScript.sh $1 $2Y $4 $5 $6
	./RamScript.sh $1 G $4 $5 $6
fi
if [[ ( "$1" = "915" ) && ( "$2" = "FY" ) ]]; then
	./RamScript.sh $1 F $4 $5 $6
fi
