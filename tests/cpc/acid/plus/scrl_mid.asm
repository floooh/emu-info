;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000


scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld a,1
call scr_set_mode

ld d,'A'
ld b,25
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

di
ld hl,&c9fb
ld (&0038),hl
ei

main_loop:
ld b,&f5
l2p:
in a,(c)
rra
jr nc,l2p
ld bc,&7f10
out (c),c
ld a,1
ld (&6800),a
halt

ld hl,&6804
ld a,(vscrl)
and &7
add a,a
add a,a
add a,a
add a,a
ld d,a
ld e,&00

rept 16
ld (hl),d
defs 4
ld (hl),e
defs 64-2-2-4
endm

ld a,(hscrl)
and &f
ld d,a
ld e,0


rept 16
ld (hl),d
defs 4
ld (hl),e
defs 64-2-2-4
endm

ld a,(delay)
dec a
ld (delay),a
jp nz,main_loop
ld a,(vscrl)
inc a
ld (vscrl),a
ld a,(hscrl)
inc a
ld (hscrl),a
ld a,50
ld (delay),a
jp main_loop

delay:
defb 50
vscrl:
defb 0
hscrl:
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

display_hex:
push af
srl a
srl a
srl a
srl a
call display_digit
pop af
display_digit:
push bc
and &f
cp 10
ld c,'A'-10
jr nc,ddid
ld c,'0'
ddid:
add a,c 
call txt_output
pop bc
ret
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd



end start
