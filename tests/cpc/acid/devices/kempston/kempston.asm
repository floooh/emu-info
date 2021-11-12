;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

mc_wait_flyback equ &bd19
txt_output equ &bb5a

start:


ld a,2
call scr_set_mode
ld hl,start_message
call display_msg
call km_wait_char

ld a,2
call scr_set_mode
ld hl,kempston_msg
call display_msg

loop:
call mc_wait_flyback

ld bc,&fbee
in a,(c)
ld (x),a

ld bc,&fbef
in a,(c)
ld (y),a

ld bc,&faef
in a,(c)
ld (buttons),a

ld h,12
ld l,1
call txt_set_pos
ld a,(x)
call outputhex8

ld h,12
ld l,2
call txt_set_pos
ld a,(y)
call outputhex8

ld h,18
ld l,3
call txt_set_pos
ld a,(buttons)
call outputhex8

ld h,9
ld l,6
call txt_set_pos
ld a,(buttons)
call output_bin


jp loop


x:
defb 0
y:
defb 0
buttons:
defb 0


include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputbin.asm"
include "../../lib/output.asm"
;; firmware based output
include "../../lib/fw/output.asm"

kempston_msg:
defb 31,1,1
defb "X (&fbee): "
defb 31,1,2
defb "Y (&fbef): "
defb 31,1,3
defb "Buttons (&faef):"
defb 31,1,5
defb "Buttons 111111LR"
defb 31,1,11
defb "Key:",13,10
defb "L - Left mouse button (when pressed will show 0)",13,10
defb "R - Right mouse button (when pressed will show 0)",13,10
defb "$"

display_msg:
ld a,(hl)
cp '$'
ret z
inc hl
call txt_output
jr display_msg

start_message:
defb "This is an interactive test.",13,10,13,10
defb "This test is for testing the Kempston mouse interface.",13,10,13,10
defb "Disconnect all other hardware before running this test",13,10,13,10
defb "Use the mouse and see the data change on the screen.",13,10,13,10
defb "Moving left will decrease the X value, moving right",13,10
defb "will increase the X value. Moving up will decrease the",13,10
defb "Y value and moving down will increase it.",13,10,13,10
defb "Press a key to start","$"



end start
