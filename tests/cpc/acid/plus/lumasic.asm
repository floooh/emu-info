;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;

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

ld bc,&bc07
out (c),c
ld bc,&bd00+33
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+27
out (c),c

call asic_enable
call asic_ram_enable
di
ld hl,&c9fb
ld (&0038),hl
ei

ld a,8
ld (&6800),a
l1:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
ld de,&0000
ld hl,&6400
ld (hl),e
inc l
ld (hl),d
dec l
halt
defs 36
ld hl,&6400
ld de,(colour_ptr)
ld b,200
lp:
ld a,(de)
ld (hl),a
inc de
inc l
ld a,(de)
ld (hl),a
inc de
dec l
dec b
defs 64-1-2-1-2-2-2-2-2-1-3
jp nz,lp
ld de,0
ld (&6400),de
ld hl,(colour_ptr)
ld bc,(increment)
add hl,bc
ld (colour_ptr),hl

ld hl,(colour_ptr)
ld bc,colours
or a
sbc hl,bc
jr nz,lp4
ld hl,2
ld (increment),hl
lp4:
ld hl,(colour_ptr)
ld bc,end_colours-(200*2)
or a
sbc hl,bc
jr nz,lp5
ld hl,-2
ld (increment),hl
lp5:

jp l1


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

colour_ptr:
defw colours

colours:
include "genlumtable/genlumtable/asiclum.txt"
end_colours:

increment:
defw 2

message:
defb "This is a visual test.",13,10,13,10
defb "This test shows all the asic colours in luminance order",13,10
defb "(dark to light, black to white)",13,10,13,10
defb "NOTE: The luminance mapping is not fully monotonic which",13,10
defb "means that more than 1 asic colour maps onto 1 luminance.",13,10,13,10
defb "This test must be run on a MM14 monitor",13,10,13,10
defb "Press a key to start",0

include "../lib/hw/asic.asm"

end start