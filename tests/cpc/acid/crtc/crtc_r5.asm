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

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c


ld bc,&bc07
out (c),c
ld bc,&bd00+18
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+20-1
out (c),c

rept 12
halt
endm

;; type 1 is as expected, gap (no leak into r5)
;; r5 normal lines starting {|} etc
;; r6 works during r5
;; 
;; type 2 is the same as type 1 
;;
;; type 0: 2 lines ok, then 2 lines repeat. r6 doesn't work during r5 (check with 1??)
;;
;; type 3: 1 line ok, 3 repeated
;; r6 doesn't work during r5
;;
;; type 4:  gap (no leak into r5) 1 line ok, {|} etc 3 repeated (DEF)
;; r6 doesn't work during r5
loop:
ld b,&f5
l2:
in a,(c)    
rra
jr nc,l2
ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+10-3
out (c),c

ld bc,&bc05
out (c),c
ld bc,&bd00+24
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+10-3
out (c),c

halt
halt
ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c
halt
halt
ld bc,&bc06
out (c),c
ld bc,&bd00+10-3+2
out (c),c
halt
defs 12*64
ld bc,&bc04
out (c),c
ld bc,&bd00+7-1
out (c),c
ld bc,&bc05
out (c),c
ld bc,&bd00+2
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

jp loop



end start
