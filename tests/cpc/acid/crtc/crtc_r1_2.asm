;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1

;; type 1: bit by bit each line disapears, 1 char line on its own (0,1,2,3,4,5 etc) and a gap
;; type 2: same as type 1
;; type 0 same as type 1 and 2
;; type 4: bit by bit each line disapears, 1 char line on it's own (0,1,2,3 etc)
;; a gap, then all filled
;; HD6845R:  bit by bit each line disapears, 1 char line on it's own and a gap of 8 lines then
;; all filled to end (similar to type 4)

di
ld hl,&c9fb
ld (&0038),hl
ei
ld bc,&bc07
out (c),c
ld bc,&bd00+35
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+35
out (c),c

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
di
defs 64*5
defs 45-18
ld bc,&bc01
out (c),c
inc b
ld de,&0000+40
out (c),d
defs 64-4
out (c),e

defs 64*7-4
out (c),d
defs 64
defs 64-4
out (c),e

defs 64*6-4
out (c),d
defs 64
defs 64
defs 64-4
out (c),e

defs 64*5-4
out (c),d
defs 64
defs 64
defs 64
defs 64-4
out (c),e

defs 64*4-4
out (c),d
defs 64
defs 64
defs 64
defs 64
defs 64-4
out (c),e

defs 64*3-4
out (c),d
defs 64
defs 64
defs 64
defs 64
defs 64
defs 64-4
out (c),e

defs 64*2-4
out (c),d
defs 64
defs 64
defs 64
defs 64
defs 64
defs 64
defs 64-4
out (c),e

defs 64*1-4
out (c),d
defs 64
defs 64
defs 64
defs 64
defs 64
defs 64
defs 64
defs 64-4
out (c),e
defs 64*8
out (c),d
defs 64*8
out (c),e

ld bc,&bd00+40
out (c),c
ld bc,&7f00+%10011101
out (c),c
ei

jp loop

end start
