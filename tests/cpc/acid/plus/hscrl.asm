;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000


scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld a,0
call scr_set_mode
call write_lines

ld de,&4000
call copy_lines


ld de,&4000+(6+6+6)*80
call copy_lines

;; set the screen mode
ld a,1
call scr_set_mode
call write_lines

ld de,&4000+(6*80)
call copy_lines

ld a,2
call scr_set_mode
call write_lines

ld de,&4000+((6+6)*80)
call copy_lines

ld hl,&4000
ld de,&c000
ld bc,&4000
ldir

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
ld bc,&7f00+&40
out (c),c
ld bc,&7f00+%10001100
out (c),c
call do_all_hscrl

defs 64-3-5-3-4

ld bc,&7f00+&4b
out (c),c
ld bc,&7f00+%10001101
out (c),c
call do_all_hscrl

defs 64-3-5-3-4

ld bc,&7f00+&53
out (c),c
ld bc,&7f00+%10001110
out (c),c
call do_all_hscrl

defs 64-3-5-3-4

ld bc,&7f00+&4c
out (c),c
ld bc,&7f00+%10001111
out (c),c
call do_all_hscrl

ld bc,&7f00+&54
out (c),c

jp main_loop

copy_lines:
ld hl,&c000
ld b,6
cl1:
push bc
push hl
push de
rept 8
call copy_line
ld a,h
add a,8
ld h,a
ld a,d
add a,8
ld d,a
endm
pop hl
ld bc,80
add hl,bc
ex de,hl
pop hl
ld bc,80
add hl,bc
pop bc
djnz cl1

ret

copy_line:
push hl
push de
push bc
ld bc,80
ldir
pop bc
pop de
pop hl
ret

write_lines:
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
ret

do_all_hscrl:
ld hl,&6804
ld b,16
xor a
do_scrl:
ld (hl),a
defs 64-2
ld (hl),a
defs 64-2
ld (hl),a
inc a
defs 64-2-1-1-3
dec b
jp nz,do_scrl
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
