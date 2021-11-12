;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000


txt_output equ &bb5a

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,2
call scr_set_mode
ld hl,ps2_msg
call display_msg


mouse_loop:
ld a,(mouse_data)
ld (prev_mouse_data),a

ld bc,&fd10
in a,(c)
ld (mouse_data),a

ld a,(mouse_data)
and %11000000
cp %01000000
jr nz,ml2
ld a,(mouse_data)
and %111111
bit 5,a
jr z,ml3
or %11000000
ml3:
ld c,a
ld a,(x)
add a,c
ld (x),a
jr mldone
ml2:
cp %10000000
jr nz,ml5
ld a,(mouse_data)
and %111111
bit 5,a
jr z,ml4
or %11000000
ml4:
ld c,a
ld a,(y)
add a,c
ld (y),a
jr mldone
ml5:
cp %11000000
jr nz,mldone
ld a,(mouse_data)
bit 5,a
jr z,ml6
ld a,(mouse_data)
and %11111
bit 4,a
jr z,ml8
or %11100000
ml8:
ld c,a
ld a,(wheel)
add a,c
ld (wheel),a
jr mldone
ml6:
ld a,(mouse_data)
and %11111
ld (buttons),a
mldone:

ld h,4
ld l,4
call txt_set_pos
ld a,(x)
call outputhex8
ld h,4
ld l,5
call txt_set_pos
ld a,(y)
call outputhex8
ld h,8
ld l,6
call txt_set_pos
ld a,(wheel)
call outputhex8

ld h,10
ld l,9
call txt_set_pos
ld a,(buttons)
call output_bin

ld h,21
ld l,14
call txt_set_pos
ld a,(mouse_data)
call outputhex8

ld h,24
ld l,14
call txt_set_pos
ld a,(mouse_data)
call output_bin

;;ld a,(mouse_data)
;;and %11000000
;;or a
;;jp z,mla4

ld a,(mouse_data)
ld h,1
ld l,16
call txt_set_pos
ld b,256
ld a,' '
dll:
push bc
push af
call txt_output
pop af
pop bc
djnz dll

ld h,1
ld l,16
call txt_set_pos


ld a,(mouse_data)
and %11000000
or a
ld hl,no_update
jr z,mla1
sub %01000000
ld hl,x_update
jr z,mla1
sub %01000000
ld hl,y_update
jr z,mla1
sub %01000000
ld hl,button_wheel_update
mla1:
call display_msg

ld a,(mouse_data)
and %11000000
cp %01000000
jr nz,mla2
ld hl,signed_offset_msg
call display_msg

ld a,(mouse_data)
bit 5,a
jr z,mla2a
or %11100000
mla2a:
call outputhex8
jp mla4

mla2:
cp %10000000
jr nz,mla3
ld hl,signed_offset_msg
call display_msg

ld a,(mouse_data)
bit 5,a
jr z,mla2b
or %11100000
mla2b:
call outputhex8
jr mla4

mla3:
cp %11000000
jr nz,mla4
ld a,(mouse_data)
bit 5,a
ld hl,button_update
jr z,ml3a
ld hl,wheel_update
ml3a:
call display_msg

ld a,(mouse_data)
bit 3,a
jr z,ml33a

ld hl,signed_offset_msg
call display_msg

ld a,(mouse_data)
and %11111
bit 4,a
jr z,ml3b
or %11100000
ml3b:
call outputhex8
jr mla4

ml33a:
ld a,(mouse_data)
bit 0,a
ld hl,left_pressed_msg
call nz,display_msg

ld a,(mouse_data)
bit 1,a
ld hl,right_pressed_msg
call nz,display_msg

ld a,(mouse_data)
bit 2,a
ld hl,middle_pressed_msg
call nz,display_msg

ld a,(mouse_data)
bit 3,a
ld hl,forward_pressed_msg
call nz,display_msg

ld a,(mouse_data)
bit 4,a
ld hl,back_pressed_msg
call nz,display_msg

mla4:

jp mouse_loop

prev_mouse_data:
defb 0
mouse_data:
defb 0

x:
defb 0
y:
defb 0
buttons:
defb 0
wheel:
defb 0

no_update:
defb "No change,",0
x_update:
defb "X delta,",0
y_update:
defb "Y delta,",0
button_wheel_update:
defb "Button/Wheel update,",0
button_update:
defb "Button update,",0
wheel_update:
defb "wheel update,",0

signed_offset_msg:
defb "Signed offset ",0

left_pressed_msg:
defb "Left PRESSED,",0

right_pressed_msg:
defb "Right PRESSED,",0

middle_pressed_msg:
defb "Middle PRESSED,",0

forward_pressed_msg:
defb "Forward PRESSED,",0

back_pressed_msg:
defb "Forward PRESSED,",0

ps2_msg:
defb 31,1,1
defb "Accumulated values:"
defb 31,1,2
defb "-------------------"
defb 31,1,4
defb "X: "
defb 31,1,5
defb "Y: "
defb 31,1,6
defb "Wheel: "
defb 31,10,8
defb "---BFMRL"
defb 31,1,9
defb "Buttons: "
defb 31,1,11
defb "Last read state:"
defb 31,1,12
defb "----------------"
defb 31,21,13
defb "DD mmdddddd"
defb 31,1,14
defb "Mouse data (FD10): "


defb 31,1,20
defb "Key:",13,10
defb "m - mode    D - data    d - data",13,10
defb "B - back button     F - forward button",13,10
defb "M - middle button   R - right button",13,10
defb "L - left button",13,10
defb 0

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


message:
defb "This is an interactive test.",13,10,13,10
defb "This test is used to test the ps/2 mouse on the symbiface 2.",13,10,13,10
defb "Connect the Symbiface 2 ONLY to a CPC or Plus",13,10,13,10
defb "Connect a PS/2 mouse to the Symbiface 2 and",13,10
defb "then follow the instructions",13,10,13,10
defb "Press a key to start",0

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputbin.asm"
include "../../lib/output.asm"
;; firmware based output
include "../../lib/fw/output.asm"


end start