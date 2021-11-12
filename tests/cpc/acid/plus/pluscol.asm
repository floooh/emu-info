;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; shows red (0-f), green (0-f) and blue (0-f)

org &8000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

;; set colour with bit 5 set
start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

;; set to mode 1, clear screen and reset CRTC base
ld a,1
call scr_set_mode

call asic_enable
call asic_ram_enable
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
ld de,&0000
ld hl,&6400
ld (hl),e
inc l
ld (hl),d
dec l

halt
halt
halt
di

;; red
ld a,0
ld de,0
rept 16
ld (hl),e
inc l
ld (hl),d
dec l
add a,&10
ld e,a
defs 64-1-2-1-1-2-2
defs 64
endm
ld de,0
ld (&6400),de
defs 8*64-5-3

;; green
ld de,0
rept 16
ld (hl),e
inc l
ld (hl),d
dec l
inc d
defs 64-1-1-1-2-2
defs 64
endm
ld de,0
ld (&6400),de
defs 8*64-5-3

;; blue
ld de,0
rept 16
ld (hl),e
inc l
ld (hl),d
dec l
inc e
defs 64-1-1-1-2-2
defs 64
endm

ei
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


message:
defb "This is a visual test.",13,10,13,10
defb "This test shows three bars of colour (changing pen 0). Red (0-f)",13,10
defb "then Green (0-f) then Blue (0-f).",13,10
defb "This can be used to check decoding of the colour registers in the asic ram.",13,10,13,10
defb "This test must be run on a colour monitor",13,10,13,10
defb "Press a key to start",0

include "../lib/hw/asic.asm"

end start