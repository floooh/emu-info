#!/bin/sh
pasmo --equ CPC=1 --equ SPEC=0 --amsdos drivetest.asm drivetest.bin
if [ "$?" != "0" ]; then
    exit 1
fi
2cdt -n drivetest.bin drivetest.cdt
if [ "$?" != "0" ]; then
    exit 1
fi
playtzx drivetest.cdt -au
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs -f -e format -f "DATA" cpc_drivetest.dsk
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs	cpc_drivetest.dsk -f -b -p drivetest.bin
if [ "$?" != "0" ]; then
    exit 1
fi
