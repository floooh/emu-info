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

call asic_enable
ld bc,&7fb8
out (c),c

di
ld hl,&c9fb
ld (&0038),hl
ei

ld l,&30
ld h,&00
ld (&6802),hl

ld a,10
ld (&6800),a

loop1:
ld b,&f5
l3:
in a,(c)
rra
jr nc,l3

ld hl,vals

loop3:
ld a,(hl)
or a
jr z,loop2
ld (&6800),a
inc hl
ld a,(hl)
ld (&6801),a
inc hl
ld d,(hl)
inc hl
ld e,(hl)
inc hl
ld (&6802),de
halt
jr loop3

loop2:
jp loop1

vals:
defb 10
defb 12
defw &3000

defb 20
defb 22
defw &c000

defb 30
defb 32
defw &1800

defb 40
defb 42
defb &ff
defb &03+%1100+&30

defb 0
end_vals:



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
