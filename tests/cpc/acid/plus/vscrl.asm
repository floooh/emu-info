;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

;; 00
;; 01
;; 02
;; 03
;; 04
;;----------------------------
;; GAP
;; 05
;; 06
;; 07
;; ----------------------------
;; 08
;; ----------------------------
;; GAP
;; 08
;; ----------------------------
;; 08?
;; ----------------------------
;; GAP
;; 09
;; ----------------------------
;; 0a (shrunk)
;; 0b (shrunk)
;; ----------------------------
;; GAP
;; 0c
;; ----------------------------
;; ? (0d,0e,0f,10,11,12,13)
;; ?
;; ?
;; ----------------------------
;; GAP
;; partial 14
;; 15
;; ----------------------------
;; (partial 16?)
;;16
;;17
;;partial 17



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

ld bc,&bc00+6
out (c),c
ld bc,&bd00+35
out (c),c
ld bc,&bc00+7
out (c),c
ld bc,&bd00+35
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

di
ld hl,&c9fb
ld (&0038),hl
ei
ld bc,&bc0c
out (c),c
ld bc,&bd00+&30+%1100
out (c),c

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld a,0
ld (&6804),a
ld a,1
ld (&6800),a
ld bc,&7f00
out (c),c
halt
ld bc,&7f40
out (c),c
defs 64-4-3
ld a,(vscrl)
ld hl,&6804
and &7
add a,a
add a,a
add a,a
add a,a
ld e,16
v1:
ld (hl),a
defs 4
ld (hl),0
defs 64-2-2-4-2-3
dec e
jp nz,v1
ld bc,&7f54
out (c),c
defs 128-4-3-3-4
ld bc,&7f40
out (c),c
ld a,(hscrl)
and &f
ld e,16
h1:
ld (hl),a
defs 4
ld (hl),0
defs 64-2-2-4-2-3
dec e
jp nz,h1
ld bc,&7f54
out (c),c

ld a,62
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),%00000000	;; 0+0->0
defs 64-3
ld (hl),%01110000	;; 1+7->8 -> 0
defs 64-3
ld (hl),%01100000
defs 64-3
ld (hl),%01010000
defs 64-3
ld (hl),%01000000
defs 64-3
ld (hl),%00110000
defs 64-3
ld (hl),%00100000
defs 64-3
ld (hl),%00010000
defs 64-3
ld (hl),0
ld bc,&7f54
out (c),c

ld a,78
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),0
defs 64-3
ld (hl),%01110000
defs 64-3
ld (hl),0
defs 64-3
ld (hl),%01110000
defs 64-3
ld (hl),0
defs 64-3
ld (hl),%01110000
defs 64-3
ld (hl),0
defs 64-3
ld (hl),%01110000
defs 64-3
ld (hl),0
ld bc,&7f54
out (c),c

ld a,94
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),%00010000
defs 64-3
ld (hl),%00100000
defs 64-3
ld (hl),%00110000
defs 64-3
ld (hl),%01000000
defs 64-3
ld (hl),%01010000
defs 64-3
ld (hl),%01100000
defs 64-3
ld (hl),%01110000
defs 64-3
ld (hl),%0
defs 64-3
ld (hl),0
ld bc,&7f54
out (c),c

ld a,111
ld (&6800),a
halt
;; 46 + 
;; 4 + 2 + 3
defs 4
ld bc,&bc09
out (c),c
ld bc,&bd00+3
out (c),c
ld bc,&7f40
out (c),c
;+6
ld hl,&6804
ld (hl),%01010000
ld a,128
ld (&6800),a



;; 0+5 = 5
;; 1+5 = 6
;; 2+5 = 7
;; 3+5 = 8



halt
ld bc,&7f54
out (c),c
ld (hl),0
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld a,143
ld (&6800),a
halt
defs 4
ld bc,&bc09
out (c),c
ld bc,&bd00+15
out (c),c
ld bc,&7f40
out (c),c
;+4
ld hl,&6804
ld (hl),%01000000

ld a,159
ld (&6800),a
halt
ld bc,&7f54
out (c),c
ld (hl),0
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+36
out (c),c

ld a,(delay)
dec a
ld (delay),a
jr nz,vs2
ld a,(vscrl)
inc a
ld (vscrl),a
ld a,(hscrl)
inc a
ld (hscrl),a
ld a,50
ld (delay),a
vs2:

jp loop

vscrl:
defb 0

hscrl:
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
