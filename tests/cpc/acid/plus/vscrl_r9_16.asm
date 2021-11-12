;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; similar to vscrl but with r9>7
org &8000



;; 00
;; 00
;; 01
;; 01
;; 02
;; 02
;---------------------------------
;; GAP
; 02 
; 03
; 03
;---------------------------------
; 04
; 05
;---------------------------------
;; GAP
; 06 
; 06
;---------------------------------
; 07 squashed
; 07
; 08 
;---------------------------------
; GAP
; 08
; 09 
;---------------------------------
;; ?
;---------------------------------
; GAP
; 10
; 10 
;---------------------------------
;; 11
;; 11 (squashed)
;; 11


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
ld bc,&bd00+17
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+18
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00+15
out (c),c
ld bc,&bc05
out (c),c
ld bc,&bd00+8
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
ld a,0
ld (&6804),a
ld a,1
ld (&6800),a
ld bc,&7f10
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

ld a,32
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%00000000	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),0
ld bc,&7f54
out (c),c

ld a,48
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),%01000000	;; 
defs 16*64
ld bc,&7f54
out (c),c


ld a,64		
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),%01100000	;; 
defs 64-3
ld (hl),%01010000	;; 
defs 64-3
ld (hl),%01000000	;; 
defs 64-3
ld (hl),%00110000 ;; 
defs 64-3
ld (hl),%00100000
defs 64-3
ld (hl),%00010000
defs 64-3
ld (hl),%00000000
defs 64-3
ld (hl),%01100000	;; 
defs 64-3
ld (hl),%01010000	;; 
defs 64-3
ld (hl),%01000000	;; 
defs 64-3
ld (hl),%00110000 ;; 
defs 64-3
ld (hl),%00100000
defs 64-3
ld (hl),%00010000
defs 64-3
ld (hl),%00000000
defs 64-3

ld bc,&7f54
out (c),c

ld a,80		
ld (&6800),a
halt
ld bc,&7f40
out (c),c
defs 64-3-4
defs 4
ld hl,&6804
ld (hl),%0	;; 
defs 64-3
ld (hl),%0	;; 
defs 64-3
ld (hl),%0	;; 
defs 64-3
ld (hl),%0 ;; 
defs 64-3
ld (hl),%0
defs 64-3
ld (hl),%0
defs 64-3
ld (hl),%0	;; 
defs 64-3
ld (hl),%01110000	;; 
defs 64-3
ld (hl),%0110000	;; 
defs 64-3
ld (hl),%01010000 ;; 
defs 64-3
ld (hl),%010000000
defs 64-3
ld (hl),%001100000
defs 64-3
ld (hl),%00100000
defs 64-3
ld (hl),%00010000
defs 64-3
ld (hl),%00000000
defs 64-3

ld bc,&7f54
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

asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd



end start
