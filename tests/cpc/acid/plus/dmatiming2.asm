;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; attempt to see if cpu is blocked when accessing ppi.

org &8000

;; 8 diagonals (left to right)
;; then rest exactly lined up.


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

di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc01
out (c),c
ld bc,&bd00+64
out (c),c
ld bc,&bc02
out (c),c
ld bc,&bd00+48
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+35
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+34
out (c),c

call asic_enable
ld bc,&7fb8
out (c),c

ld hl,&2000
ld b,200
ld de,&080f	;; write to ay register 8
wdma:
ld (hl),e
inc hl
ld (hl),d
inc hl
djnz wdma
ld de,&4020	;; stop
ld (hl),e
inc hl
ld (hl),d

main_loop:
ld b,&f5
ml1:
in a,(c)
rra
jr nc,ml1

ld bc,&f782
out (c),c

;; raster int
ld a,1
ld (&6800),a

;; dma
ld hl,&2000
ld (&6c00),hl
xor a
ld (&6c02),a


;; when testing writing to ay register

;; select ay register
ld a,8
;; write register index to PPI port A
ld b,&f4
out (c),c

;; set PSG operation -  "select register"
ld bc,&f6c0
out (c),c

;; set PSG operation -  "inactive"
ld bc,&f600
out (c),c
ld bc,&f700+%10000010
out (c),c

;; write to register
ld bc,&f680
out (c),c

ld bc,&7f00	;; select pen 0
out (c),c
halt
ld a,1
ld (&6c0f),a

ld d,&54
ld e,&40
ld b,&7f
exx
ld d,&0f
ld e,&8
ld b,&f4			;; change to f4,f5,f6,f7
exx

rept 32
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
defs 9
endm

exx
ld d,&0f
ld e,&8
ld b,&f5			;; change to f4,f5,f6,f7
exx

rept 32
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
defs 9

endm

exx
ld d,&0f
ld e,&8
ld b,&f6
exx

rept 32
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
defs 9
endm


exx
ld d,&82
ld e,&80
ld b,&f7
exx

rept 32
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
out (c),d	;; colour
out (c),e
exx
out (c),d	;; ppi
out (c),e
exx
defs 9
endm
jp main_loop

asic_enable:

	push af
	push hl
	push bc
	push de
 	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	pop de
	pop bc
	pop hl
	pop af	
	ret
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee


end start
