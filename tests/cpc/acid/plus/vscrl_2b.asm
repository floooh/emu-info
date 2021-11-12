;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

;; 5
;; 6 
;; 7
;; 1 black line (happens on raster line 0 because white bar shows)
;; dark red			;; 09
;; 1 line of yellow		;; 0A (raster line 0?)
;; bright red			;; 0b
;; red/black dots		;; 0c (raster line 0 because white bar interrupted but shows)
;; red/bright red dots	;; 0d
;; 0E
;; 0F

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
scr_set_ink equ &bc32
txt_set_cursor equ &bb75

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
ld bc,&bd00+70
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+77
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00+3
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

ld hl,&c000+8*80
ld a,%0
call fill_block2
ld hl,&c000+9*80
ld a,%11110000
call fill_block2
ld hl,&c000+10*80
ld a,%00001111
call fill_block2
ld hl,&c000+11*80
ld a,%11111111
call fill_block2
ld hl,&c000+12*80
ld a,%00110000
call fill_block2
ld hl,&c000+13*80
ld a,%11110011
call fill_block2

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

ld bc,&7f00
out (c),c
exx
ld b,&7f
ld d,&4b
ld e,&54
exx
ld a,0
ld (&6804),a
halt

;; 6 - no change
ld a,43		
ld (&6800),a
halt		;; 46+1+3
ld hl,&6804	;; [3]
ld d,%00010000 ;; [2]
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e

;; 7 - no change (or 1 line black at bottom?)
ld a,51		;; (4*8)+3 to happen on (5*8)
ld (&6800),a
halt
ld hl,&6804	;; [3]
ld d,%00100000		;; [2]
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e


;; 1 black line (happens on raster line 0 because white bar shows)
;; dark red			;; 09
;; 1 line of yellow		;; 0A (raster line 0?)
;; bright red			;; 0b
;; red/black dots		;; 0c (raster line 0 because white bar interrupted but shows)
;; red/bright red dots	;; 0d
;; 0E
;; 0F

;; 8 - 1 black line of 8
;; 3 black lines of red (9)
;; 0->3 and switch
ld a,59 
ld (&6800),a
halt
ld hl,&6804	;; [3]
ld d,%00110000		;; [2] 
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e


;; counter?


;; 9 1 line of yellow (a)
;; 3 lines bright red
ld a,67		
ld (&6800),a
halt
ld hl,&6804	;; [3]
ld d,%01000000		;; [2]
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e

;; 10 - read black dots
;; bright red and red dots
ld a,75		
ld (&6800),a
halt
ld hl,&6804	;; [3]
ld d,%01010000		;; [2]
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e

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

fill_block:
ld a,%00000000
call fill_line
ld a,h
add a,8
ld h,a

ld a,%11110000
call fill_line
ld a,h
add a,8
ld h,a

ld a,%00001111
call fill_line
ld a,h
add a,8
ld h,a

ld a,%11111111
call fill_line
ld a,h
add a,8
ld h,a

ld a,%00110000
call fill_line
ld a,h
add a,8
ld h,a

ld a,%11000011
call fill_line
ld a,h
add a,8
ld h,a

ld a,%11110011
call fill_line
ld a,h
add a,8
ld h,a

ld a,%10101010
call fill_line
ret

fill_line:
push de
push hl
push bc
ld e,l
ld d,h
inc de
ld (hl),a
ld bc,80-1
ldir
pop bc
pop hl
pop de
ret

fill_block2:
ld b,8
fb:
push af
call fill_line
ld a,h
add a,8
ld h,a
pop af
djnz fb
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

scr_next_line:
ld a,h
add a,8
ld h,a
ret nc
ld a,l
add a,&50
ld l,a
ld a,h
adc a,&c0
ld h,a
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
