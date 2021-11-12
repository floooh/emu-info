#!/bin/sh
pasmo --equ CPC=0 --equ SPEC=1 --plus3dos fdctest.asm fdctest.bin
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs -f -e format -f "ZX0" spec_fdctest.dsk
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs spec_fdctest.dsk -f -b -p fdctest.bin fdctest
if [ "$?" != "0" ]; then
    exit 1
fi
cpcxfs spec_fdctest.dsk -f -b -p loader
if [ "$?" != "0" ]; then
    exit 1
fi
