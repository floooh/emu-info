;; use to find min/max monitor will display for line length
;; on my cm14:
;; max is 40 (41 sometimes syncs) (15873 approx)
;; min is 3e (15376 approx)
;; below 2d screen blanks.
;; but you can go all the way up to ff without blanking.

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
ld a,63
ld (hsize),a
call write_text_init


mainloop:
ld b,&f5
ml:
in a,(c)
rra
jr nc,ml

ld h,40
ld l,1
call set_char_coords
ld a,(hsize)
call display_hex


call readkeys



ld bc,&bc00
out (c),c
inc b
ld a,(hsize)
out (c),a

ld ix,old_matrix_buffer
ld iy,matrix_buffer
bit 0,(ix+9)
jr z,noup
bit 0,(iy+9)
jr nz,noup

ld a,(hsize)
dec a 
ld (hsize),a

noup:
bit 1,(ix+9)
jr z,nodown
bit 1,(iy+9)
jr nz,nodown

ld a,(hsize)
inc a
ld (hsize),a

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

hsize:
defb 0

include "../lib/hw/readkeys.asm"
include "../lib/hw/writetext.asm"
include "../lib/hw/scr.asm"

sysfont:
incbin "../lib/hw/sysfont.bin"
end start