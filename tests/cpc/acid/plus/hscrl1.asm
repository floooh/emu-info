;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

;; 10 80 f0 - 0001 0000 1000 0000 11110000
;; 0001 0000 1000 0000
;; 0000 0000 1100 0000 



;; 01 08 0f - 0000 0001 0000 1000 0000ffff
;; 11 88 ff - 0001 0001 1000 1000 ffffffff

;; 13 c8 ff - 0001 0011 1100 1000 ffffffff

;; 0001 0001 1000 1000
;; 0000 0000 1100 1100 
;; 0001 0001
;; 1000 1000 -> 0100 0100

;; pen 1 is ok
;; pen 2 is blue and a bit distorted can't tell pens
;; pen 3 is red, yellow grey one side, blue the other (1,2)

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
txt_set_pen equ &bb90

start:
ld a,1
call scr_set_mode

ld b,4
ld a,0
s1:
push af
push bc

call txt_set_pen
ld b,80
ld a,'A'
s2:
push af
call txt_output
pop af
inc a
djnz s2
pop bc
pop af
inc a
djnz s1

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
ld a,14
ld (&6800),a
halt
defs 64-3-1-48
rept 4
call do_all_hscrl
endm

jp main_loop

do_all_hscrl:
ld hl,&6804
xor a
rept 15
ld (hl),a
inc a
defs 64-1-2
endm
ld (hl),a
defs 64-2-1-3-5
ret

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
