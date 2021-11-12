;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; For CRTC type 2 only.
;; not conclusive.
org &8000
nolist

scr_set_pen equ &bc32
scr_set_border equ &bc38
txt_set_cursor equ &bb75
scr_set_mode equ &bc0e
txt_output equ &bb5a
km_wait_char equ &bb06

start:
ld a,1
call scr_set_mode

ld a,"A"
ld b,24

txt_row:

ld c,40
txt_line:
push af
push bc
call txt_output
pop bc
pop af
dec c
jr nz,txt_line
inc a
djnz txt_row

ld b,26
ld c,b
call scr_set_border

xor a
ld b,13
ld c,b
call scr_set_pen

ld a,1
ld b,18
ld c,b
call scr_set_pen

call km_wait_char
cp 'Y'
ld c,1
jr z,use_r6
cp 'y'
ld c,1
jr z,use_r6
ld c,0
use_r6
ld a,c
ld (use_r6),a
di

ld a,(use_r6)
or a
jr z,use_r1

ld bc,&bc06
out (c),c
ld bc,&bd00
out (c),c
ld l,25
jr do_wait

use_r1:
ld bc,&bc01
out (c),c
ld bc,&bd00
out (c),c
ld l,40

do_wait:
ld h,10
dw2:
ld de,65535
dw1:
dec de
ld a,d
or e
jr nz,dw1
dec h
jr nz,dw2
out (c),l

do_wait2:
jp do_wait2


end start