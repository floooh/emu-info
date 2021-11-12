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

call asic_enable
call asic_ram_enable

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
ld hl,&0666
ld (&6400),hl

halt

halt

halt
ld de,(colour)
ld hl,(pen_addr)
ld (hl),e
inc l
ld (hl),d
dec l

halt
ld hl,&0666
ld (&6400),hl

ld hl,(colour)
ld bc,&100
add hl,bc
ld a,h
and &f
ld h,a
ld (colour),hl

ld a,(cycle)
dec a
ld (cycle),a
jr nz,l3
ld a,100
ld (cycle),a
ld a,(pen)
inc a
cp &11
jr nz,l4
xor a
l4:
ld (pen),a
add a,a
ld l,a
ld h,&64
ld (pen_addr),hl
call set_pal
l3:

jp l1

cycle:
defb 100

pen:
defw 0

pen_addr:
defw &6400

colour:
defw 0

set_pal:
ld hl,inks
ld de,&6400
ld bc,end_inks-inks
ldir
ret

inks:
defw &000
defw &001
defw &002
defw &003
defw &004
defw &005
defw &006
defw &007
defw &008
defw &009
defw &00a
defw &00b
defw &00c
defw &00d
defw &00e
defw &00f
defw &000
end_inks:

display_msg:
ld a,(hl)
cp '$'
ret z
inc hl
call txt_output
jr display_msg

pen_colour_msg:
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
defb '$'

message:
defb "This is a visual test.",13,10,13,10
defb "This test cycles through flashing each pen and border in turn",13,10
defb "and checks all 16 pens and the border can be used.",13,10,13,10
defb "Only 1 should flash at a time",13,10,13,10
defb "Press a key to start",'$'

include "../lib/hw/asic.asm"

end start