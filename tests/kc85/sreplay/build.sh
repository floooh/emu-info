#!/bin/bash

# z80asm: https://www.nongnu.org/z80asm/
/opt/z80asm/bin/z80asm main.asm -I include -o sreplay.bin
./create-kcc.py sreplay.bin SREPLAY COM 200H > SREPLAY.KCC
