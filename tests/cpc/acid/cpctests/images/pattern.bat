bmp2cpc m1.txt pattern_mode1.bmp pattern_mode1.bin
bmp2cpc m2.txt pattern_mode2.bmp pattern_mode2.bin
pasmo --amsdos pattern_m1.asm pattern_m1.bin
pasmo --amsdos pattern_m2.asm pattern_m2.bin

bmp2cpc m1fa.txt pattern_mode1f.bmp pattern_mode1fa.bin
bmp2cpc m1fb.txt pattern_mode1f.bmp pattern_mode1fb.bin
bmp2cpc m2fa.txt pattern_mode2f.bmp pattern_mode2fa.bin
bmp2cpc m2fb.txt pattern_mode2f.bmp pattern_mode2fb.bin
pasmo --amsdos pattern_m1f.asm pattern_m1f.bin
pasmo --amsdos pattern_m2f.asm pattern_m2f.bin