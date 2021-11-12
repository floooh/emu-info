;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; keyboard tester
org &4000

scr_set_mode equ &bc0e
km_wait_char equ &bb06
txt_output equ &bb5a

;; clash seen on cpc6128, cpc464 new keyboard
;; no keyboard clash on cpc664 keyboard

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char


ld a,2
call scr_set_mode

ld hl,key_msg
call display_msg

call write_text_init

ld h,4
ld l,4

ld iy,key_addr
ld e,16
calc_line:
push de
push hl

ld b,8
calc_bit:
push bc
push hl
call set_char_coords
ld (iy+0),l
ld (iy+1),h
inc iy
inc iy
pop hl
inc h
inc h
pop bc
djnz calc_bit

pop hl
inc l
pop de
dec e
jr nz,calc_line

ld h,0
ld l,21
call set_char_coords
call clear_blob

ld h,0
ld l,22
call set_char_coords
call fill_blob

update_loop:
ld b,&f5
ul1:
in a,(c)
rra
jr nc,ul1

call readkeys

ld ix,matrix_buffer
ld iy,key_addr

ld e,16

next_line:
push de

ld b,8
ld a,(ix+0)
inc ix

next_bit:
ld l,(iy+0)
ld h,(iy+1)
inc iy
inc iy

bit 0,a
push af
push bc
call set_blob
pop bc
pop af
rrca
djnz next_bit

pop de
dec e
jr nz,next_line

jp update_loop


set_blob:
jr z,clear_blob
jr fill_blob

fill_blob:
ld c,&ff
jr draw_blob

clear_blob:
ld c,%1001000
jr draw_blob

draw_blob:
ld b,8
db1:
ld (hl),c
call scr_next_line
djnz db1
ret


include "../lib/hw/readkeys.asm"
include "../lib/hw/writetext.asm"
include "../lib/hw/scr.asm"

sysfont:
incbin "../lib/hw/sysfont.bin"

key_addr:
defs 16*8*2

key_msg:
defb 31,1,5
defb "0",13,10
defb "1",13,10
defb "2",13,10
defb "3",13,10
defb "4",13,10
defb "5",13,10
defb "6",13,10
defb "7",13,10
defb "8",13,10
defb "9",13,10
defb "10",13,10
defb "11",13,10
defb "12",13,10
defb "13",13,10
defb "14",13,10
defb "15",13,10
defb 31,5,4
defb "7 6 5 4 3 2 1 0"
defb 31,10,3
defb &f2,"Bit"
defb &f3
defb 31,1,2
defb &f1,"Line (F6xx) bits 3..0"
defb 31,24,5
defb "Cur Up, Cur Right, Cur Down, f9,f6,f3,Enter, f."
defb 31,24,6
defb "Cur Left, Copy, f7,f7,f5,f1,f2,f0"
defb 31,24,7
defb "Clr, {, Ret, }, f4, shift, \, Ctrl"
defb 31,24,8
defb "^,-,@,P,+,*.?.>"
defb 31,24,9
defb "0,9,O,I,L,K,M,<"
defb 31,24,10
defb "8,7,U,Y,H,J,N,Space"
defb 31,24,11
defb "Joy 1 and 6,5,R,T,6,F,B,C"
defb 31,24,12
defb "4,3,E,W,S,D,C,X"
defb 31,24,13
defb "1,2,Esc,Q,Tab,A,Caps,Z"
defb 31,24,14
defb "Joy 0 and DEL"
defb 31,24,15
defb "Unused"
defb 31,24,16
defb "Unused"
defb 31,24,17
defb "Unused"
defb 31,24,18
defb "Unused"
defb 31,24,19
defb "Unused"
defb 31,24,20
defb "Unused"

defb 31,1,22
defb "  Not press",13,10
defb "  Pressed"
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
defb "This test displays the keys (or joystick) when pressed.",13,10
defb "You can use this to confirm:",13,10
defb "* keyboard is working correctly",13,10
defb "* joy 0 and 1 are emulated correctly",13,10
defb "* keyboard clash is emulated",13,10,13,10
defb "NOTE: No keyboard clash exists between Plus keys and Plus digital joysticks",13,10
defb "NOTE: Keyboard clash doesn't exist on CPC664 keyboard",13,10
defb "NOTE: Test keyboard clash with R,T,Y - pressing those shows U",13,10,13,10
defb "Press a key to start",0


end start
