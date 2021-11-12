;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

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

di
ld hl,&c9fb
ld (&0038),hl
ei

call asic_enable
ld bc,&7fb8
out (c),c

loop:
halt
ld hl,&fff
ld de,&0f0
ld bc,&000

;; purple for one nop, white for about 5, yellow for one nop, then red for about 5
rept 8
ld (&6400),hl
ld (&6400),de
ld (&6400),bc
defs 64-5-6-6
endm

defs 64-3-3-4
ld hl,&4043
ld bc,&7f00
out (c),c
rept 8
out (c),h
out (c),l
out (c),h
out (c),l
out (c),h
out (c),l
defs 64-4-4-4-4-4-4
endm
ld bc,&7f54
out (c),c
jp loop

include "../lib/hw/asic.asm"

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


message:
defb "This is a visual test.",13,10,13,10
defb "This test writes to the asic palette registers.",13,10,13,10
defb "The top bar of colour is written direct to 6400",13,10
defb "and writes a 16-bit value at a time.",13,10,13,10
defb "You will see the colour changes taking effect as ",13,10
defb "each byte of the 16-bit value is written to the ram.",13,10,13,10
defb "The top bar shows: purple for 1 nop, white for 5 nops,",13,10
defb "yellow for 1 nop, red for 5 nops",13,10
defb "The bottom bar is programmed using I/O to 7fxx",13,10
defb "using the 'old CPC' method",13,10,13,10
defb "Press a key to start",0

end start
