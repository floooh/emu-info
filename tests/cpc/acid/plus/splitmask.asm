;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

scr_set_border equ &bc38
scr_set_mode equ &bc0e
txt_output equ &bb5a

org &8000
nolist

start:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld d,'A'
ld b,24
l2:
ld c,40
l1:
ld a,d
call txt_output
dec c
jr nz,l1
inc d
dec b
jr nz,l2

di
ld hl,&c9fb
ld (&0038),hl
ei

ld hl,&c000
ld de,&4000
ld bc,&4000
ldir
ld hl,&4000
ld bc,&4000
l3:
ld a,(hl)
cpl
ld (hl),a
inc hl
dec bc
ld a,b
or c
jr nz,l3

ld hl,&c000+(last_byte-&8000)
ld de,last_byte
ld bc,&bf00-last_byte
l4:
ld a,(hl)
or &a0
ld (de),a
inc hl
inc de
dec bc
ld a,b
or c
jr nz,l4

ld hl,&c000+&40
ld de,&40
ld bc,&4000-&40
l5:
ld a,(hl)
or &55
ld (de),a
inc hl
inc de
dec bc
ld a,b
or c
jr nz,l5


call asic_enable
ld bc,&7fb8
out (c),c

loop1:
ld b,&f5
l3a:
in a,(c)
rra
jr nc,l3a
ld a,150
ld (&6800),a

ld a,100
ld (&6801),a

ld hl,(split)
ld (&6802),hl

halt

ld a,(counter)
dec a
ld (counter),a
jr nz,loop1
ld a,50
ld (counter),a

ld hl,(split)
inc hl
ld (split),hl
jr loop1

counter:
defb 50

split:
defw 0

asic_enable:
	push af
	push hl
	push bc
	push de
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,16

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	
	ld a,&ee
	out (c),a
	pop de
	pop bc
	pop hl
	pop af	
	ret
	
	
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd
last_byte:
end start
