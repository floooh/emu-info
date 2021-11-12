;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e


start:
ld bc,1
call scr_set_mode

ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,0
call scr_set_mode

ld hl,pen_colour_msg
call display_msg

di 
ld hl,&c9fb
ld (&0038),hl
ei

call set_pal

l1:
ld b,&f5
l2: 
in a,(c)
rra
jr nc,l2
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&7f01
out (c),c
ld bc,&7f54
out (c),c
halt

halt

halt

ld b,&7f
ld a,(pen)
out (c),a
ld a,(colour)
and &1f
or %01000000
out (c),a
halt
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&7f01
out (c),c
ld bc,&7f54
out (c),c

halt

ld b,&7f
ld a,(pen)
or %00100000
out (c),a
ld a,(colour)
and &1f
or %01000000
out (c),a

halt
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c

ld a,(colour)
inc a
ld (colour),a

ld a,(cycle)
dec a
ld (cycle),a
jr nz,l3
ld a,100
ld (cycle),a
ld a,(pen)
inc a
cp 17
jr nz,l3b
xor a
l3b:
ld (pen),a
call set_pal
l3:

jp l1

cycle:
defb 100

pen:
defb 0

colour:
defb 0

set_pal:
ld hl,inks
ld b,&7f
ld e,0
ld d,17
sp1:
out (c),e
ld a,(hl)
inc hl
out (c),a
inc e
dec d
jr nz,sp1
ret

inks:
defb &44,&4a,&53,&4c,&4b,&54,&55,&4d,&46,&5e,&5f,&47,&52,&59,&56,&43,&44


display_msg:
ld a,(hl)
cp '$'
ret z
inc hl
call txt_output
jr display_msg

pen_colour_msg:
defb 31,1,4
defb "Bit 5=0"
defb 31,1,17
defb "Bit 5=1"
defb 31,1,8
defb 14,0," "
defb 14,1," "
defb 14,2," "
defb 14,3," "
defb 14,4," "
defb 14,5," "
defb 14,6," "
defb 14,7," "
defb 14,8," "
defb 14,9," "
defb 14,10," "
defb 14,11," "
defb 14,12," "
defb 14,13," "
defb 14,14," "
defb 14,15," "
defb 31,1,20
defb 14,0," "
defb 14,1," "
defb 14,2," "
defb 14,3," "
defb 14,4," "
defb 14,5," "
defb 14,6," "
defb 14,7," "
defb 14,8," "
defb 14,9," "
defb 14,10," "
defb 14,11," "
defb 14,12," "
defb 14,13," "
defb 14,14," "
defb 14,15," "
defb '$'

message:
defb "This is a visual test.",13,10,13,10
defb "This test cycles through flashing each pen (and border) in turn and",13,10
defb " checks all 16 pens can be used.",13,10,13,10
defb "'Palette pointer register' (bit 7=0, bit 6=0, port &7fxx) is used.",13,10,13,10
defb "Top bar has bit 5 of pen set to 0. Bottom bar has bit 5 of pen set to 1 and",13,10
defb "both show the same result",13,10,13,10
defb "This test does the same on CPC and Plus",13,10,13,10
defb "Press a key to start",'$'


end start