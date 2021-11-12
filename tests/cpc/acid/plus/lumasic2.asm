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
ld bc,&bd00+35
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+33
out (c),c

call asic_enable
call asic_ram_enable
di
ld hl,&c9fb
ld (&0038),hl
ei
ld hl,&888
ld (&6420),hl
ld a,1
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
defs 38
ld hl,&6400
ld de,colours
ld b,0
lp:
ld a,(de)
ld (hl),a
inc de
inc l
ld a,(de)
ld (hl),a
inc de
dec l
ld a,e
add a,16-2
ld e,a
ld a,d
adc a,0
ld d,a
dec b
defs 64-3-1-2-1-1-2-1-1-1-2-2-2-1-2-2-2
jp nz,lp
ld de,0
ld (&6400),de

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
defb "This test shows some (256 out of 4096) of the asic colours in luminance order",13,10
defb "(dark to light, black to white)",13,10,13,10
defb "NOTE: The luminance mapping is not fully monotonic which",13,10
defb "means that more than 1 asic colour maps onto 1 luminance.",13,10,13,10
defb "This test must be run on a MM14 monitor",13,10,13,10
defb "Press a key to start",0

include "../lib/hw/asic.asm"

end start