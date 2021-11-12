pasmo --amsdos flood2.asm flood2.bin
2cdt -n flood2.bin flood2.cdt
cpcxfsw -f -nd flood2.dsk
cpcxfsw flood2.dsk -f -p flood2.bin
