;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e


;; set colour with bit 5 set
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

l1:
ld b,&f5
l2: 
in a,(c)
rra
jr nc,l2
ld bc,&7f40
out (c),c

halt

halt

halt

;; pen 0
ld bc,&7f00
out (c),c
;; set grey
ld bc,&7f43
out (c),c
halt
ld bc,&7f40
out (c),c
halt
;; select pen 1
ld bc,&7f01
out (c),c
;; if this works, we go back to pen 0
ld bc,&7f00+%00100000
out (c),c
ld bc,&7f43
out (c),c
halt
ld bc,&7f40
out (c),c
jp l1


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
defb 31,1,17
defb "Bit 5=1"
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
defb "This shows bit 5 is ignored when setting the pen number.",13,10
defb "'Palette pointer register' (bit 7=0, bit 6=0, port &7fxx).",13,10,13,10
defb "This test sets pen 0 to show two yellow bars with grey between them",13,10,13,10
defb "Top bar has bit 5 of value set to 0. Bottom bar has bit 5 set to 1 ",13,10
defb "of value and both show the same.",13,10,13,10
defb "No other pens should change",13,10,13,10
defb "This test does the same on CPC and Plus",13,10,13,10
defb "Press a key to start",'$'


end start