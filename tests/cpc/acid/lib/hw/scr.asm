;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

scr_next_line:
ld a,h
add a,8
ld h,a
ret nc
ld a,l
add a,&50
ld l,a
ld a,h
adc a,&c0
ld h,a
ret

wait_vsync_start:
ld b,&f5
wvs1:
in a,(c)
rra
jr nc,wvs1
ret

cls:
ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&3fff
ldir
ld h,0
ld l,0
jp set_text_coords
