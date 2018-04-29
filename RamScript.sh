#!/bin/bash

if [ "$3" = "0" ]; then
	selinux=Permissive
fi
if [ "$3" = "1" ]; then
	selinux=Enforcing
fi

if [ "$5" = "1" ]; then
	adb=_Debugging
fi

for i in $(pwd)/ramkernel/AIK-Linux-v3.2/cleanup.sh
do
"$i" &
done
wait

cp ramkernel/stock_bootimg/$1$2/boot.img $(pwd)/ramkernel/AIK-Linux-v3.2

for i in $(pwd)/ramkernel/AIK-Linux-v3.2/unpackimg.sh
do
"$i" &
done
wait

rm $(pwd)/ramkernel/AIK-Linux-v3.2/split_img/boot.img-zImage
cp $(pwd)/output/arch/arm/boot/zImage $(pwd)/ramkernel/AIK-Linux-v3.2/split_img/boot.img-zImage

patch $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/default.prop $(pwd)/ramkernel/patches/defualt.prop/$1.default.prop.patch
rm $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/init.environ.rc
rm $(pwd)/ramkernel/AIK-Linux-v3.2/split_img/boot.img-dtb
cp $(pwd)/ramkernel/patches/environ-rc/N7 $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/init.environ.rc
cp $(pwd)/ramkernel/boot.img-dtb $(pwd)/ramkernel/AIK-Linux-v3.2/split_img/boot.img-dtb
patch $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/init.rc $(pwd)/ramkernel/patches/init.d/init.rc.patch
#patch $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/init.target.rc $(pwd)/ramkernel/patches/F2FS/init.target.rc.patch
cp $(pwd)/ramkernel/patches/init.d/initd-support.sh $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/sbin
cp $(pwd)/ramkernel/patches/init.d/init.d_support.sh $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk
if [ "$5" = "1" ]; then
	patch $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/default.prop $(pwd)/ramkernel/patches/bootimg_debugging_patch/adb.default.prop.patch
	rm $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/sbin/adbd
	cp $(pwd)/ramkernel/patches/bootimg_debugging_patch/adbd $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/sbin/adbd
fi
#cp -r $(pwd)/ramkernel/patches/Synapse_support/ramdisk/* $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/
#patch $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/ueventd.rc $(pwd)/ramkernel/patches/Synapse_support/ueventd.rc.patch
#cp $(pwd)/ramkernel/patches/Synapse_support/ramdisk_fix_permissions.sh $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk/ramdisk_fix_permissions.sh
#cd $(pwd)/ramkernel/AIK-Linux-v3.2/ramdisk
#chmod 0777 ramdisk_fix_permissions.sh
#./ramdisk_fix_permissions.sh 2>/dev/null
#rm -f ramdisk_fix_permissions.sh
#cd -

for i in $(pwd)/ramkernel/AIK-Linux-v3.2/repackimg.sh
do
"$i" &
done
wait
cp $(pwd)/ramkernel/AIK-Linux-v3.2/image-new.img $(pwd)/ramkernel/zips/template/ram/boot.img

for i in $(pwd)/ramkernel/AIK-Linux-v3.2/cleanup.sh
do
"$i" &
done
wait
rm $(pwd)/ramkernel/AIK-Linux-v3.2/boot.img

mv $(pwd)/ramkernel/zips/template/ram/system/lib/modules/placeholder $(pwd)/ramkernel/
find ./ -name '*.ko' -exec cp '{}' "$(pwd)/ramkernel/zips/template/ram/system/lib/modules" ";"

7z a -tzip -mx5 $(pwd)/ramkernel/zips/RamKernel_$1$2_RC$4_$selinux$adb.zip $(pwd)/ramkernel/zips/template/META-INF $(pwd)/ramkernel/zips/template/ram
rm $(pwd)/ramkernel/zips/template/ram/boot.img
rm $(pwd)/ramkernel/zips/template/ram/system/lib/modules/*.*
mv $(pwd)/ramkernel/placeholder $(pwd)/ramkernel/zips/template/ram/system/lib/modules/
echo "$selinux zip made for $1$2"
