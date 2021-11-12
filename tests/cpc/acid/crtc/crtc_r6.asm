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
di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc04
out (c),c
ld bc,&bd00+3
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
rept 12
halt
endm


loop:
ld b,&f5
l2:
in a,(c)    
rra
jr nc,l2

ld bc,&bc04
out (c),c
ld bc,&bd00+3
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c
ld bc,&bc06
out (c),c
inc b

;; not stable on type 1; need to fix
;; lines flicker indicating change is immediate

;; type 2 shows:
;; 1 whole line
;; gap
;; 1 whole line with a sligfht flicker
;; gap
;; 2 lines with a slight flicker
;; 2 lines
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline dotted
;; gap
;; now it shows 1 scanline with dotted on end
;;; gap
;; now it shows 2 lines 
;; gap
;;
;; type 0 same as type 2
;;
;; type 3 shows:
;; 1 whole line
;; gap
;; 2 whole lines
;; 2 whole lines
;; 2 whole lines
;; large gap (no other scanlines here)
;;
;; type 4: same as type 3
;;
;; HD6845R: similar to type 2 without dotted lines and change is immediate
ld c,&2
out (c),c
call wait_4_char_lines

ld c,&3
out (c),c
call wait_4_char_lines

ld c,&4
out (c),c
call wait_4_char_lines

ld bc,&bc04
out (c),c
ld bc,&bd01
out (c),c
ld bc,&bc06
out (c),c
inc b
ld de,&0102

out (c),d
ld d,8
call wait_x_lines
out (c),e
defs 64
defs 64-4-4
defs 16
ld d,6
call wait_x_lines

rept 11
out (c),d		
ld d,6
call wait_x_lines
defs 64-4
out (c),e
defs 64-4
ld d,7
call wait_x_lines
endm
ld bc,&bc04
out (c),c
ld bc,&bd04
out (c),c
ld d,16
call wait_x_lines

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
jp loop

wait_4_char_lines:
defs 64-2-3-5
ld d,4*8
w4cl:
defs 64-1-3
dec d
jp nz,w4cl
ret

wait_x_lines:
defs 64-2-3-5
wxl:
defs 64-1-3
dec d
jp nz,wxl
ret



end start
