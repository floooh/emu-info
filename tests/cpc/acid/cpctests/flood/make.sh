pasmo --amsdos flood2.asm flood2.bin
2cdt -n flood2.bin flood2.cdt
cpcxfs -f -nd flood2.dsk
cpcxfs flood2.dsk -f -p flood2.bin
playtzx flood2.cdt -au
