;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

;; abababab

;; 1x0x1x0x 3

;; 10000000 1 
;; 00001000 2


;; pen 1 is fine
;; pen 2 is distorted but no other colour pixels
;; pen 3 has yellow on left and blue on right (1? 2?)
;; pen 4 is distorted but ok
;; pen 5 is white and yellow and broken
;; pen 6 is blue with white on one side and light blue on the other
;; pen 7 is purple with white and light blue on fringes
;; pen 8 is grey and ok
;; pen 9 is green with yellow on the right side and grey on the left
;; pen 10 is blue with light blue on the right and grey on the left
;; pen 11 is pink with grey on both sides? (8)
;; pen 12 is green
;; pen 13 is light green with bits of yellow (1?)
;; pen 14 is grey, green on one side blue on other (12?)
;; pen 15 is white with green and grey - can't tell

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
txt_set_pen equ &bb90
scr_set_ink equ &bc32

start:
ld a,0
call scr_set_mode

ld a,14
ld c,13
ld b,c
call scr_set_ink

ld a,15
ld c,26
ld b,c
call scr_set_ink


ld b,16
xor a
s1:
push af
push bc
call txt_set_pen
ld b,32
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

ld bc,&bc0c
out (c),c
ld bc,&bd30
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc01
out (c),c
ld bc,&bd00+32
out (c),c
ld bc,&bc02
out (c),c
ld bc,&bd00+44
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+32
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+34
out (c),c

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
rept 16
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
