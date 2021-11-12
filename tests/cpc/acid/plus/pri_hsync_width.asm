;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; Change HSYNC width with PRI active. 

;; line positions:
;; P
;; A
;; 2
;; #
;; s
;; d
;; U
;; F
;; 7
;; (
;; x
;; i
;; ALL same.


org &8000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
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

;; output various widths and see if the position changes
;; if it doesn't then it isn't dependent on the end of the hsync
ld bc,&bc03
out (c),c
inc b
ld c,6	;; initial hsync width
ld d,10	;; initial pri
ld e,16-6 	;; count
pri:
ld a,c		;; set hsync length
or &80		;; force vsync length
out (c),a
defs 8*64

;; set int location
ld a,d
ld (&6800),a
halt			;; wait for it
inc c
ld a,d
add a,16
ld d,a
dec e
jp nz,pri

jp loop

int_function:
push bc
ld bc,&7f00
out (c),c
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
