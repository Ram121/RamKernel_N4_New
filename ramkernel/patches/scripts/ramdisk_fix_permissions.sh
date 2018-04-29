#!/bin/bash
chmod 644 file_contexts
chmod 644 se*
chmod 644 *.rc
chmod 750 init*
chmod 640 fstab*
chmod 644 default.prop
chmod 771 data
chmod 755 dev
chmod 755 proc
chmod 755 res
chmod 750 res/*
chmod 755 sbin
chmod 750 sbin/*
cd sbin
chmod 755 su
chmod 664 su/*
chmod 644 *.sh
chmod 750 uci
cd ../
chmod 755 init
chmod 755 sys
chmod 755 system

echo "Fixed ramdisk permissions"
