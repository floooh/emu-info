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

di
ld hl,&c9fb
ld (&0038),hl
ei

;; enable map mod; disable blacks
ld a,%00001100
ld bc,&fabf
out (c),a
l1:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
ld d,64
ld hl,colours
ld bc,&7f00
out (c),c
l3:
ld a,(hl)
inc hl
out (c),a
defs 64-2-2-4-1-3
dec d
jp nz,l3
ld a,&40
out (c),a

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
include "genlumtable/genlumtable/alestelum.txt"
end_colours:

increment:
defw 2

message:
defb "This is a visual test.",13,10,13,10
defb "This test shows all the Aleste 520EX colours in luminance order",13,10
defb "(dark to light, black to white)",13,10,13,10
defb "This test must be run on a monochrome monitor",13,10,13,10
defb "THIS TEST NEEDS CONFIRMING ON A REAL ALESTE",13,10,13,10

defb "Press a key to start",0

end start