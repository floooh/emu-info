;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; multiplay tester
org &4000

txt_output equ &bb5a
mc_wait_flyback equ &bd19

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,2
call scr_set_mode

ld hl,multiplay_msg
call display_msg

loop:
call mc_wait_flyback

ld hl,multiplay_data
ld e,6
ld bc,&f990
rmd:
in a,(c)
ld (hl),a
inc hl
inc c
dec e
jr nz,rmd

ld hl,multiplay_hex_pos
ld de,multiplay_data
ld b,6
dhex:
push bc
push de
push hl
ld l,(hl)
push de
ld h,28
call txt_set_pos
pop de

ld a,(de)
call outputhex8
pop hl
inc hl
pop de
inc de
pop bc
djnz dhex


ld hl,multiplay_hex_pos
ld de,multiplay_data
ld b,6
dbin:
push bc
push de
push hl
ld l,(hl)
push de
ld h,34
call txt_set_pos
pop de

ld a,(de)
;; 8 digits in binary number
ld b,8
ob2:
;; transfer bit 7 into carry
rlca
push af
ld a,"0"
;; convert to ASCII
;; 0-> "0" and 1-> "1"
adc a,0
;; display digit on the screen
call output_char
ld a," "
call output_char
ld a," "
call output_char
pop af
djnz ob2

pop hl
inc hl
pop de
inc de
pop bc
djnz dbin

jp loop

multiplay_hex_pos:
defb 3
defb 4
defb 7
defb 8
defb 9
defb 10

multiplay_data:
defs 6

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
;; firmware based output
include "../../lib/fw/output.asm"

multiplay_msg:
defb 31,1,3
defb "F990 (Port A Action Bits):"
defb 31,1,4
defb "F991 (Port B Action Bits):"

defb 31,1,7
defb "F992 (Port A Mouse X):"
defb 31,1,8
defb "F993 (Port A Mouse Y):"
defb 31,1,9
defb "F994 (Port B Mouse Y):"
defb 31,1,10
defb "F995 (Port B Mouse Y):"

defb 31,28,1
defb "DD    00 F3 F2 F1  R  L  D  U (Joy)"
defb 31,28,2
defb "DD    00 MM RM LM D3 D2 D1 D0 (Mouse)"
defb 31,28,6
defb "DD     S  S  S  S V3 V2 V1 V0"


defb 31,1,12
defb "Key:",13,10,13,10
defb "F3 - Fire 3, F2 - Fire 2, F1 - Fire 1",13,10
defb "R - Right, L - Left, U - Up, D - Down",13,10
defb "MM - Middle Mouse Button",13,10
defb "RM - Right Mouse Button",13,10
defb "LM - Left Mouse Button",13,10
defb "D3,D2,D1,D0 - Inputs for mouse",13,10
defb "DD - Hex data from port",13,10
defb "S - Sign",13,10
defb "V3,V2,V1,V0 - Mouse value"
defb '$'

display_msg:
ld a,(hl)
cp '$'
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is an interactive test.",13,10,13,10
defb "This test displays the inputs from ToTO's multiplay.",13,10
defb "This test was written from the specification document",13,10,13,10
defb "Disconnect all other devices and leave Multiplay connected",13,10,13,10
defb "You can use this to confirm:",13,10
defb "* multiplay joysticks are working correctly",13,10
defb "* multiplay mice are working correctly",13,10,13,10
defb "NEEDS CHECKING ON A REAL DEVICE",13,10,13,10
defb "Press a key to start","$"


end start
