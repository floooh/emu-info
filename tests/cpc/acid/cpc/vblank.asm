;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
scr_set_border equ &bc38

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,2
call scr_set_mode

ld b,&1a
ld c,b
call scr_set_border

ld hl,vblank_msg
call display_msg

ld hl,&c000+(3*80)+(2*&800)
ld e,l
ld d,h
inc de
ld (hl),&ff
ld bc,80-1
ldir

ld hl,&c000+(18*80)+(7*&800)
ld e,l
ld d,h
inc de
ld (hl),&ff
ld bc,80-1
ldir


;; vsync is 1 mode 1 char
;;
;; kc compact: border is black, but see graphics throughout no blanking
;; graphics are distorted

di
ld hl,&c9fb
ld (&0038),hl
ei
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+18
out (c),c
ld bc,&bc03
out (c),c
inc b
ld a,&8e
out (c),a

loop: 
jp loop

vblank_msg:
defb 31,1,16,&f2,&f2,&f2," VBLANK extends past the left border"

defb 31,1,18
defb &f1,&f1,"VBLANK starts below the solid line. VBLANK is black",&f1,&f1

defb 31,42,7,"VBLANK extends past the right border",&f3,&f3,&f3

defb 31,1,5
defb &f0,&f0,"VBLANK ends above the solid line. VBLANK is black",&f0,&f0
defb 0


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test causes a vsync to happen in the middle of the screen",13,10
defb "The Gate-Array will generate blanking lines which are black",13,10
defb "and blank graphics and the border",13,10,13,10
defb "The solid lines show the top and bottom of the vblank",13,10,13,10
defb "Press a key to start",0

end start