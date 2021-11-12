;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; AAAA repeated
;; BBBB repeated
;; etc but scrolls ok.

scr_set_border equ &bc38
scr_set_mode equ &bc0e
txt_output equ &bb5a
org &8000
nolist

;; screen scrolls ok
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

call asic_enable
ld bc,&7fb8
out (c),c


ld bc,&bc04
out (c),c
ld bc,&bd00+9
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00+31
out (c),c
ld bc,&bc00+7
out (c),c
ld bc,&bd00+0
out (c),c

ld a,50
ld (timer),a

ld a,0
ld (&6804),a

di
ld hl,&c9fb
ld (&0038),hl
ei

loop1:
ld b,&f5
l3:
in a,(c)
rra
jr nc,l3
l4:
in a,(c)
rra
jr c,l4

ld a,(timer)
dec a
ld (timer),a
jr nz,loop2
ld a,50
ld (timer),a

ld a,(val)
inc a
and &7
ld (val),a

ld a,(val)
add a,a
add a,a
add a,a
add a,a
ld (&6804),a
loop2:

jp loop1

timer:
defb 0

val:
defb 0

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

end start
