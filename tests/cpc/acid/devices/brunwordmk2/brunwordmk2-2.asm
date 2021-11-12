;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f
txt_output equ &bb5a
scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
ld hl,intro_message
call display_msg
call &bb06

ld a,2
call scr_set_mode

ld hl,&7000
di
ld bc,&df00+%01100000
out (c),c
ei
ld c,0
call kl_rom_select
call kl_u_rom_enable

ld hl,reset_message
call display_msg

call &bb06
rst 0

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

reset_message:
defb "There are 3 things you can test now:",13,10,13,10
defb "1. Use a reset button to reset the CPC.",13,10
defb "2. Press space and do a soft reset.",13,10
defb "3. Use the power switch to turn the computer OFF then ON. ",13,10,13,10
defb "After you have done one of these then run brunwordmk2-3 test to confirm the state",13,10,13,10
defb 0

intro_message:
defb "Brunword Mk2 tester",13,10,13,10
defb "This test is interactive.",13,10,13,10
defb "This test is used to check the power on/off and reset actions.",13,10,13,10
defb "Please test on *CPC* with Brunword mk2 expansion ONLY connected.",13,10,13,10
defb "This was tested on a CPC6128 with Brunword mk2 connected.",13,10,13,10
defb "Press a key to continue"
defb 0

end start