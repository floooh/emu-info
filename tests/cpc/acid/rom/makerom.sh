pasmo --bin shortrom.s short.bin
addhead -s 0xc000 short.bin shorthdr.bin
pasmo --bin normrom.s norm.bin
addhead -s 0xc000 norm.bin normhdr.bin
pasmo --bin longrom.s long1.bin
pasmo --bin longrom2.s long2.bin
cat long1.bin long2.bin >long.bin
addhead -s 0xc000 long.bin longhdr.bin
cat short.bin message.txt > shortextra.bin
cat shorthdr.bin message.txt > shorthdrextra.bin
cat norm.bin message.txt > normextra.bin
cat normhdr.bin message.txt > normhdrextra.bin
cat long.bin message.txt > longextra.bin
cat longhdr.bin message.txt > longhdrextra.bin

