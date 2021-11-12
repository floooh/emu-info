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

org &8000

start:

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1

di
ld hl,&c9fb
ld (&0038),hl
ei

call asic_enable
call asic_ram_enable


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


;; copy colours into ASIC sprite palette registers
ld hl,sprite_colours
ld de,&6422
ld bc,15*2
ldir

ld hl,&100
ld (&6000),hl

main_loop:
ld a,5-3			;; few lines before sprite
ld (&6800),a
ld a,%0				;; set mag
ld (&6004),a
ld hl,5				;; y coord
ld (&6002),hl
halt
;; now set mag
ld a,%1101
ld (&6004),a
;; skip past sprite
ld a,5+17
ld (&6800),a
halt
ld a,%0000		;; reset mag
ld (&6004),a
ld a,40-3		;; before next sprite
ld (&6800),a
ld hl,40		;; next sprite pos
ld (&6002),hl
halt
ld a,%1101
ld (&6005),a
;; skip past sprite
ld a,40+17
ld (&6800),a
halt
ld a,%0000
ld (&6004),a
ld a,70-3		;; before next sprite
ld (&6800),a
ld hl,70		;; next sprite pos
ld (&6002),hl
halt
ld a,%1101
ld (&6006),a

;; skip past sprite
ld a,70+17
ld (&6800),a
halt
ld a,%0000
ld (&6004),a
ld a,100-3		;; before next sprite
ld (&6800),a
ld hl,100		;; next sprite pos
ld (&6002),hl
halt
ld a,%1101
ld (&6007),a
ld a,100+17
ld (&6800),a
halt
jp main_loop

asic_ram_enable:
ld bc,&7fb8
out (c),c
ret


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

