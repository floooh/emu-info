;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; flash aleste 520ex caps led


org &8000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,1
call scr_set_mode

di
ld hl,&c9fb
ld (&0038),hl
ei

ld a,%01001100
ld (led),a

ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

loop:
ld e,50
start3:
ld b,&f5
start2:
in a,(c)
rra
jr nc,start2
halt
halt
dec e
jr nz,start3

ld a,(led)
xor %00100000
ld (led),a
and %00100000
ld a,&4b
jr nz,start4
ld a,&54
start4:
ld bc,&7f10
out (c),c
out (c),a
jp loop

led:
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
defb "This test flashes the CAPS led on the aleste and the border.",13,10,13,10
defb "CAPS is bit 5 of port 7fxx when bit 7=1, bit 6=0",13,10,13,10
defb "The border should be white when the led is on and black when",13,10
defb "it is off.",13,10,13,10
defb "THIS TEST NEEDS CONFIRMING ON A REAL ALESTE",13,10,13,10

defb "Press a key to start",0


end start