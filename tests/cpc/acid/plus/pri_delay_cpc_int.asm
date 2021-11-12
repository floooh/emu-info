;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; white at ghijk

;; red at #$% etc
;; white at ^_`abc
;; white at nopqrstu near gap
;; white at ABCDEF 
;;
;; all white line up.
org &8000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
scr_set_ink equ &bc32
start:
ld a,1
ld b,13
ld c,13
call scr_set_ink

ld b,26
ld c,b
call scr_set_border

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

ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

ld b,15
wait:
halt
djnz wait

call asic_enable
ld bc,&7fb8
out (c),c

di
ld a,&c3
ld hl,int_function
ld (&0038),a
ld (&0039),hl
ei

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt	;; +2
halt	;; +54
ld a,&4c
ld (int_fn2+1),a
ld a,62
ld (&6800),a
halt
ld a,&4b
ld (int_fn2+1),a
;; and delay the normal one
ld bc,&7f00+%10010001
out (c),c
ld a,0
ld (&6800),a


jp loop

int_function:
push bc
ld bc,&7f00
out (c),c
int_fn2:
ld bc,&7f4b
out (c),c
ld bc,&7f54
out (c),c
pop bc
ei
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

asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd



end start
