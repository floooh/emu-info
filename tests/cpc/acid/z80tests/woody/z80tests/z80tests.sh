pasmo --alocal --amsdos z80tests.asm bin/z80tests.bin z80tests.lst
2cdt -n bin/z80tests.bin z80tests.cdt
playtzx z80tests.cdt -au
