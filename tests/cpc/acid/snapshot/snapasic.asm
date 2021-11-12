;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; sprites: various expansion and positions
;; sprite palette (reds)

scr_set_mode equ &bc0e
txt_output equ &bb5a
txt_set_pen equ &bb90
km_wait_char equ &bb06

org &8000

start:

;; set the screen mode
xor a
call scr_set_mode

ld hl,message1
call display_message
ld hl,&c000
ld de,&4000
ld bc,&4000
ldir

xor a
call scr_set_mode
ld hl,message2
call display_message

di
im 2
ld a,&a0
ld i,a
ld bc,257
ld hl,&a000
ld de,int_function
b1:
ld (hl),e
inc hl
ld (hl),d
inc hl
dec bc
ld a,b
or c
jr nz,b1
ei

call asic_enable
call asic_ram_enable

ld a,%11111111
ld (&6804),a

;; TODO: 6805

;; set raster interrupt
ld a,50
ld (&6800),a

;; set screen split
ld a,64-1
ld (&6801),a

;; set screen split address
ld hl,&0010	;; for &4000-&ffff
ld (&6802),hl

ld a,&31
ld (&6805),a

ld hl,&1000
ld (&6c00),hl
ld a,1
ld (&6c02),a

ld hl,&2000
ld (&6c04),hl
ld a,2
ld (&6c06),a

ld hl,&3000
ld (&6c08),hl
ld a,3
ld (&6c0a),a

ld hl,palette_colours
ld de,&6400
ld bc,16*2
ldir
ld hl,&000
ld (&6420),hl

ld hl,sprites
ld de,&4000
ld bc,8*16*16
copy_sprites:
ld a,(hl)
rrca
rrca
rrca
rrca
ld (de),a
inc de
ld a,(hl)
ld (de),a
inc de
inc hl
dec bc
ld a,b
or c
jr nz,copy_sprites

;; copy colours into ASIC sprite palette registers
ld hl,sprite_colours
ld de,&6422
ld bc,15*2
ldir

ld hl,sprite_coords
ld de,&6000
ld b,16
copy_sprite_coords:
push bc
ldi
ldi
ldi
ldi
ldi
ld a,e
add a,8-5
ld e,a
pop bc
djnz copy_sprite_coords

ld hl,&888
ld (&6420),hl

ld bc,&7f00+%10111001 ;; physical page in 0
out (c),c

ld bc,&7f00+%10000000 ;; upper and lower rom on
out (c),c

ld bc,&df00+&81	;; physical page in c000
out (c),c

loop:
ld a,&33
ld (&4000),a
ld a,(&4000)
cp &03
jr nz,loop2
ld a,&45
ld (&4000),a
ld a,(&4000)
cp &5
jr nz,loop2

ld a,&11
ld (&1000),a
ld a,&88
ld (&d000),a

ld a,(&1000)
ld c,a
ld a,(&d000)
cp c
jr nz,loop2

jp loop

loop2:
di
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c
defs 64
ld bc,&7f43
out (c),c
jp loop2


asic_ram_enable:
ld bc,&7fb8
out (c),c
ret

asic_ram_disable:
ld bc,&7fa0
out (c),c
ret

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

message1:
defb 14,0
defb 15,8
defb 31,2,2
defb "SCREEN AT &4000"
defb 31,4,4
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
defb 14,0
defb 15,8
defb 31,20,1,&8a
defb 31,20,2,&8a
defb 31,20,3,&8a
defb 31,20,4,&8a
defb 31,20,5,&8a
defb 31,20,6,&8a

defb '$'

message2:
defb 14,0
defb 15,8
defb 31,2,1
defb "HIDDEN"
defb 31,2,2
defb "SCREEN AT &C000"
defb 31,4,4
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
defb 14,0
defb 15,8
defb 31,2,9
defb "BEFORE SPLIT"
defb 31,2,10
defb "NOT VISIBLE"
defb 31,20,1,&8a
defb 31,20,2,&8a
defb 31,20,3,&8a
defb 31,20,4,&8a
defb 31,20,5,&8a
defb 31,20,6,&8a
defb '$'


display_message:
ld a,(hl)
inc hl
cp '$'
ret z
call txt_output
jr display_message

border_colours:
defw &0436

palette_colours:
defw &000
defw &100
defw &200
defw &300
defw &400
defw &500
defw &600
defw &700
defw &800
defw &900
defw &a00
defw &b00
defw &c00
defw &d00
defw &e00
defw &f00

sprite_coords:
;; 0
defw 16
defw 100
defb %0101 ;; X1 Y1

;; 1
defw 34
defw 100
defb %1001 ;; X2 Y1

;; 2
defw 68
defw 100
defb %1101 ;; X4 Y1

;; 3
defw 134
defw 100
defb %0110 ;; X1 Y2

;; 4
defw 152
defw 100
defb %1010 ;; X2 Y2

;; 5
defw 186
defw 100
defb %1110 ;; X4 Y2

;; 6
defw 252
defw 100
defb %0111 ;; X1 Y4

;; 7
defw 270
defw 100
defb %1011 ;; X2 Y4

;; 8
defw 304
defw 100
defb %1111 ;; X4 Y4

;; 9
defw 370
defw 100
defb %0101

;; 10
defw 388
defw 100
defb %0101

;; 11
defw 406
defw 100
defb %0101

;; 12
defw 424
defw 100
defb %0101

;; 13
defw 442
defw 100
defb %0101

;; 14
defw 460
defw 100
defb %0101

;; 15
defw 478
defw 100
defb %0101

sprites:
incbin "sprites.bin"

sprite_colours:
include "sprite_pal.asm"


asic_enable:
	push af
	push hl
	push bc
	push de
 	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	pop de
	pop bc
	pop hl
	pop af	
	ret
	
asic_disable:
	push af
	push hl
	push bc
	push de
  ld hl,asic_sequence
	ld bc,&bc00
	ld d,15

ad1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ad1
ld a,&a5
out (c),a
pop de
	pop bc
	pop hl
	pop af	
	ret
	
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee



end start

