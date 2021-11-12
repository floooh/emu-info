;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; change r4 during r5
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

ld hl,&c000
ld e,l
ld d,h
ld (hl),&ff
inc de
ld bc,79
ldir

ld hl,&c000+(6*80)+(7*&800)
ld e,l
ld d,h
ld (hl),&ff
inc de
ld bc,79
ldir

di
ld hl,&c9fb
ld (&0038),hl
ei

;; type 0: r9 *NOT* fully respected during vadj. 
;; shows:
;; 4 scanlines of #$%
;; then 4 scanlines of  space !" etc
;; then 4 scanlines of )*+ etc
;; then 8 scanlines of )*+ etc
;; then 8 scanlines of )*+ etc
;; then 8 scanlines of )*+ etc
;; then shows new frame, 4 scans of !"# etc
;; type 1: r9 respected during vadj 
;; type 2: r9 respected during vadj 
;; type 3: r9 *NOT* respected during vadj just shows 4 char lins each 8 lines tall (spaces and !" line only)
;; type 4: same as type 3
ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+76-1
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+60
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+3
out (c),c

ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c

loop:
jp loop


end start
