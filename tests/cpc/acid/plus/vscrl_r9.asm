;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

;; left side
;; ??
;; 04
;; ?


;; 
;; 15
;;; 17
;; 
;; 2thrds accross screen
;; ???? 
;; 00 9
;; 00 9
;; 02 10
;; 03 11
;; 05?
;; 05 12
;; 09
;; 09 13
;; 0D
;; 0D 14
;; 10
;; 10 15
;; 12
;; 12
;; 12 16


scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
scr_set_ink equ &bc32
start:
xor a
ld b,13
ld c,b
call scr_set_ink
ld a,1
ld b,3
ld c,b
call scr_set_ink
ld a,2
ld b,5
ld c,b
call scr_set_ink
ld a,2
ld b,24
ld c,b
call scr_set_ink

ld b,26
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,&bc00+6
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc00+7
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc00+4
out (c),c
ld bc,&bd00+18+16+4-1
out (c),c


xor a
ld b,24
l1:
push af
push bc
call display_hex
ld a,10
call txt_output
ld a,13
call txt_output
pop bc
pop af
inc a
djnz l1


call asic_enable
ld bc,&7fb8
out (c),c

ld b,32
w1:
halt
djnz w1



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
;;ld a,(vscrl)
ld a,3
ld hl,&6804
and &7
add a,a
add a,a
add a,a
add a,a
ld (hl),a

ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&bc09
out (c),c
inc b


ld a,&7
out (c),a

ld a,8*4
ld (&6800),a
halt
;; single scan line
xor a
out (c),a
defs 64-1-4
;; 2 scanlines
ld a,1
out (c),a
defs 64+64-2-4
;; 3 scanlines
ld a,2
out (c),a
ld e,2
call wait_x_lines
defs 64-2-4
;; 4 scanlines
ld a,3
out (c),a
ld e,3
call wait_x_lines
defs 64-2-4
;; 5 scanlines
ld a,4
out (c),a
ld e,4
call wait_x_lines
defs 64-2-4
;; 6 scanlines
ld a,5
out (c),a
ld e,5
call wait_x_lines
defs 64-2-4
;; 7 scanlines
ld a,6
out (c),a
ld e,6
call wait_x_lines
defs 64-2-4
;; 8 scanlines
ld a,7
out (c),a
ld e,7
call wait_x_lines
defs 64-2-4
;; 9 scanlines
ld a,8
out (c),a
ld e,8
call wait_x_lines
defs 64-2-4
;; 10 scanlines
ld a,9
out (c),a
ld e,9
call wait_x_lines
defs 64-2-4
;; 11 scanlines
ld a,10
out (c),a
ld e,10
call wait_x_lines
defs 64-2-4
;; 12 scanlines
ld a,11
out (c),a
ld e,11
call wait_x_lines
defs 64-2-4
;; 13 scanlines
ld a,12
out (c),a
ld e,12
call wait_x_lines
defs 64-2-4
;; 14 scanlines
ld a,13
out (c),a
ld e,13
call wait_x_lines
defs 64-2-4
;; 15 scanlines
ld a,14
out (c),a
ld e,14
call wait_x_lines
defs 64-2-4
;; 16 scanlines
ld a,15
out (c),a
ld e,15
call wait_x_lines
defs 64-2-4

;; 136 lines +32 = 168
;; in 16 chars
ld a,7
out (c),c
ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c


ld a,(delay)
dec a
ld (delay),a
jr nz,vs2
ld a,(vscrl)
inc a
ld (vscrl),a
ld a,50
ld (delay),a
vs2:

jp loop

wait_x_lines:
dec e
defs 64-1-3-5-2
wxl:
defs 64-1-3
dec e
jp nz,wxl
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

vscrl:
defb 0

delay:
defb 50

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
