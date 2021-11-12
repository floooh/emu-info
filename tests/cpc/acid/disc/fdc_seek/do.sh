#!/bin/sh
pasmo --equ CPC=1 --equ SPEC=0 --amsdos fdctest.asm fdctest.bin
if [ "$?" != "0" ]; then
    exit 1
fi
2cdt -n fdctest.bin fdctest.cdt
if [ "$?" != "0" ]; then
    exit 1
fi
playtzx fdctest.cdt -au
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs -f -nd cpc_fdctest.dsk
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs	cpc_fdctest.dsk -f -b -p fdctest.bin
if [ "$?" != "0" ]; then
    exit 1
fi
