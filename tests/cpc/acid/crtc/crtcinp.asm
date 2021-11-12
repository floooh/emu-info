;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; same on type 4, whole line repeated. looks like ff

;; happens on HD6845R, same line repeated but with some graphical/horizontal distortion
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

di
ld hl,&c9fb
ld (&0038),hl
ei

loop:
ld b,&f5
lo1:
in a,(c)
rra
jr nc,lo1
halt
halt
halt
ld bc,&bc01
out (c),c
ld b,&bc
in a,(c)
call reset
ld bc,&bc01
out (c),c
ld b,&bd
in a,(c)
call reset
ld bc,&bc01
out (c),c
ld b,&be
in a,(c)
call reset
ld bc,&bc01
out (c),c
ld b,&bf
in a,(c)
call reset
jp loop

reset:
call wait_lines
ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c
call wait_lines
ret

wait_lines:
defs 64*8-3-5
ret

end start
