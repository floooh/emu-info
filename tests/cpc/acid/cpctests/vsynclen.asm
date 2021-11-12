;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

start:
di 
ld hl,&c000
ld e,l
ld d,h
inc de
ld bc,&3fff
ld (hl),0
ldir
ld bc,&7f00+%10001110
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f00+&54
out (c),c
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&8e
out (c),c
ld a,8
ld (vsynclen),a
call write_text_init


mainloop:
ld b,&f5
ml:
in a,(c)
rra
jr nc,ml

ld h,1
ld l,1
call set_char_coords
ld a,(vsynclen)
and &f
call display_hex

call readkeys



ld bc,&bc03
out (c),c
inc b
ld a,(vsynclen)
and &f
add a,a
add a,a
add a,a
add a,a
or &8
out (c),a


ld ix,old_matrix_buffer
ld iy,matrix_buffer
bit 0,(ix+9)
jr z,noup
bit 0,(iy+9)
jr nz,noup

ld a,(vsynclen)
dec a 
ld (vsynclen),a

noup:
bit 1,(ix+9)
jr z,nodown
bit 1,(iy+9)
jr nz,nodown

ld a,(vsynclen)
inc a
ld (vsynclen),a

nodown:
jp mainloop


display_hex:
push af
rrca
rrca
rrca
rrca
call display_hex_digit
pop af
display_hex_digit:
and &f
cp 10
jr c,dhd1
add a,'A'-10
jp writechar
dhd1:
add a,'0'
jp writechar

vsynclen:
defb 0

include "lib/hw/readkeys.asm"
include "lib/hw/writetext.asm"
include "lib/hw/scr.asm"

sysfont:
incbin "lib/hw/sysfont.bin"
end start