;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; enable access to asic hardware
;; set it up and then lock it again

scr_set_border equ &bc38
scr_set_mode equ &bc0e
txt_output equ &bb5a
txt_set_pen equ &bb90
km_wait_char equ &bb06

org &8000

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

xor a
ld r,a
ld bc,&4000
ld hl,&4000
s1:
ld a,r
ld (hl),a
inc hl
dec bc
ld a,b
or c
jr nz,s1

;; set the screen mode
ld a,1
call scr_set_mode

ld a,1
call txt_set_pen
ld hl,message2
call display_message

ld a,2
call txt_set_pen
ld hl,message2
call display_message

ld a,3
call txt_set_pen
ld hl,message2
call display_message

di
ld a,&c3
ld hl,int_function
ld (&0038),a
ld (&0039),hl
ei

call asic_enable
call asic_ram_enable

;; set raster interrupt
ld a,50
ld (&6800),a
;; set screen split
ld a,100
ld (&6801),a
;; set screen split address
ld hl,&0010
ld (&6802),hl

;; setup raster data
ld hl,&4000
ld c,16
ld b,16
xor a
ws1:
push bc
ws2:
ld (hl),a
inc hl
dec c
jr nz,ws2
pop bc
inc a
djnz ws1

ld hl,palette_colours
ld de,&6400
ld bc,4*2
ldir
ld hl,(border_colours)
ld (&6420),hl


;; copy colours into ASIC sprite palette registers
ld hl,sprite_colours
ld de,&6422
ld bc,15*2
ldir


;; set x coordinate for sprite 0
ld hl,100
ld (&6000),hl

;; set y coordinate for sprite 0
ld hl,100
ld (&6002),hl

;; set sprite x and y magnification
;; x magnification = 1
;; y magnification = 1
ld a,%0101
ld (&6004),a

call asic_ram_disable
call asic_disable

loop:
jp loop

int_function:
push bc
ld bc,&7f00
out (c),c
ld bc,&7f4b
out (c),c
defs 64*2
ld bc,&7f54
out (c),c
pop bc
ei
reti

display_message:
ld a,(hl)
inc hl
or a
ret z
call txt_output
jr display_message

border_colours:
defw &0436

palette_colours:
defw &0000		
defw &0b75
defw &0372
defw &0bf2			

message2:
defb "Hello",13,10,0

sprite_colours:
defw &0111			;; colour for sprite pen 1
defw &0222			;; colour for sprite pen 2
defw &0333			;; colour for sprite pen 3
defw &0444			;; colour for sprite pen 4
defw &0555			;; colour for sprite pen 5
defw &0666			;; colour for sprite pen 6
defw &0777			;; colour for sprite pen 7
defw &0888			;; colour for sprite pen 8
defw &0999			;; colour for sprite pen 9
defw &0aaa			;; colour for sprite pen 10
defw &0bbb			;; colour for sprite pen 11
defw &0ccc			;; colour for sprite pen 12
defw &0ddd			;; colour for sprite pen 13
defw &0eee			;; colour for sprite pen 14
defw &0fff			;; colour for sprite pen 15

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
defb "This test unlocks the ASIC, enables the register page,",13,10
defb "writes to the registers, disables the register page",13,10
defb "and then locks the ASIC.",13,10
defb "This test shows that the ASIC enhanced features continue",13,10
defb "to operate even when the ASIC is locked.",13,10,13,10
defb "The lock is only to enable and allow access to RMR2.",13,10,13,10
defb "You should see ASIC colours, a raster interrupt,",13,10
defb "a screen split and a hardware sprite",13,10,13,10
defb "Press a key to start",0


end start

