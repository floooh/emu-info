;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

;; pen 3 different papers

;; red text and yellow paper is ok but distorted
;; red text and blue is ok (perfect)
;; red text and red?
;; red text and white paper shows grey and yellow dots, almost seems to be mode 1
;; pixels?
;; red and black shows yellow left, magenta right
;; red and blue shows cyan on left
;; red and magenta is ok
;; red on grey shows yellow and black
;; red pm green shows yellow pixels
;; red on blue shows cyan on left
;; red on pink is ok
;; red on green has a bit of black and white?
;; red on green has a bit of yellow?
;; red on grey shows light blue
;; red on white is ok

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
txt_set_pen equ &bb90
scr_set_ink equ &bc32
txt_set_paper equ &bb96

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

ld a,3
call txt_set_pen

ld b,16
xor a
s1:
push af
push bc
call txt_set_paper
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
