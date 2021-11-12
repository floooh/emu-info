;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; shows a single line change where rcc=0 and scrl=7
;; and shows how sscr value checked at hdisp time and takes effect the next line
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

loop1:
ld b,&f5
l3:
in a,(c)
rra
jr nc,l3
l4:
in a,(c)
rra
jr c,l4
ld bc,&7f00
out (c),c
exx
ld b,&7f
ld d,&4b
ld e,&54
exx
ld a,7
ld (&6800),a
halt
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




ld a,15
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






ld a,23
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







ld a,31
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







ld a,39
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






ld a,47
ld (&6800),a
halt
ld hl,&6804	;; [3]
ld d,%01100000		;; [2]
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e






ld a,55
ld (&6800),a
halt
ld hl,&6804	;; [3]
ld d,%01110000		;; [2]
ld e,0		;; [2]
defs 64-56+30-1-4-4-1
exx 
out (c),d
out (c),e
exx
ld (hl),d
defs 6
ld (hl),e




jp loop1


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

timer:
defb 0

val:
defb 0

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
