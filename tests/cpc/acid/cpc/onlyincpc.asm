;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This test uses IN instructions only to draw a raster bar.
;; Works on CPC.
org &4000

test:

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

l1:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
halt
defs 16

ld bc,&7f00
out (c),c

ld bc,&f700+%10000010
out (c),c
ld hl,raster
ld d,&f5
exx 

ld bc,%0111010011111111
exx 

rept 9
;; read from HL write into F4xx
ld b,d
outi
exx
;; read from f4xx AND GA and set the colour
in a,(c)
exx
defs 64-1-4-1-5-1
endm

ld bc,&7f54
out (c),c

jp l1

;; green and grey raster
raster:
defb &4a
defb &42
defb &41
defb &40
defb &40
defb &40
defb &41
defb &42
defb &4a


display_msg:
ld a,(hl)
cp '$'
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test shows that an I/O read can be used to write",13,10
defb "data into the Gate-Array and that it doesn't check",13,10
defb "the R/W signal from the Z80 when accessing it's registers.",13,10,13,10
defb "This uses the 8255 as a temporary store and selects both",13,10
defb "the 8255 AND GA when the read is done. The 8255 puts the",13,10
defb "data onto the bus which the GA then writes into it's registers.",13,10,13,10
defb "This test displays a coloured bar ('raster') Colours are yellow, green and grey.",13,10,13,10
defb "Press a key to start",'$'

end test
