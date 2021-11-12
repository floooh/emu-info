;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; last line is 0,1,2,3,4
;; then 1 scanline of new screen
;; then new screen split
;; see 1 char of border on left

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

ld bc,&bc01
out (c),c
ld bc,&bd00+&3f
out (c),c

ld bc,&bc00+6
out (c),c
ld bc,&bd00+35
out (c),c
ld bc,&bc00+7
out (c),c
ld bc,&bd00+35
out (c),c

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
ld hl,&c9fb
ld (&0038),hl
ei

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2

ld hl,&1000
ld (&6802),hl
ld a,151		;; 152 lines per screen; this is one before
ld (&6801),a

ld bc,&bc07
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+18
out (c),c
halt
halt
halt
halt
ld a,0
ld (&6801),a
ld bc,&bc04
out (c),c
ld bc,&bd00+19
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
jp loop

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
