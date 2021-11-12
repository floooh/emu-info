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

ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,1
ld bc,&fbf0
out (c),a

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
defb "You should see that the red write enabled LED is LIT.",13,10,13,10
defb "There are 3 things you can test now:",13,10,13,10
defb "1. Press the reset button on the Amram2. Notice that the LED should turn OFF",13,10
defb "2. Press space and do a soft reset. Notice that the LED should stay ON",13,10
defb "3. Use the power switch to turn the computer OFF then ON. Notice the led should turn OFF",13,10,13,10
defb 0

intro_message:
defb "Silicon Systems Amram 2 tester",13,10,13,10
defb "This test is visual.",13,10,13,10
defb "This test is used to check the power on/off and reset actions.",13,10,13,10
defb "Please test on *CPC* with Amram2 expansion ONLY connected.",13,10,13,10
defb "Please enable slots 1 and 2 and ENABLE the write enable switch",13,10,13,10
defb "This was tested on a CPC6128 with Amram2 connected.",13,10,13,10
defb "Press a key to continue"
defb 0

end start