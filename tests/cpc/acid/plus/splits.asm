;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000


;; magenta
;;--------------------------------------------------------------------
;; A reversed
;; B reversed
;; A not reversed (first scanline reversed)
;; B not reversed
;;--------------------------------------------------------------------
;; A reversed
;; B revsersed
;; border
;; border
;;--------------------------------------------------------------------
;; A reversed
;; B revsersed
;; border
;; C not reversed
;;--------------------------------------------------------------------
;; A reversed
;; B revsersed
;; border
;; B not reversed

;;--------------------------------------------------------------------
;; A reversed
;; B revsersed
;; C reversed
;; D reversed
;; C not reversed
;;--------------------------------------------------------------------
;; C not reversed except first line
;; D not reversed
;; E not reversed
;; F not reversed
;; A single scanline repeated all same line
;;--------------------------------------------------------------------
;; A reversed split just below --- line
;; B not reversed about 16 chars from end
;; A reversed just before --- line
;; B not reversed about 2 chars from left
;;--------------------------------------------------------------------
;; A reversed to just below -- line
;; E not reversed
;;--------------------------------------------------------------------
;; A reversed
;; A reversed split after --- line
;; 2 lines not reversed not sure
;;--------------------------------------------------------------------
;; A reversed
;; purple

;;
;;**********************************
;; A (reversed)
;; B (reversed)
;; 2 char lines border
;;**********************************
;; A (reversed)
;; B (reversed)
;; 1 char line border
;; C (not reversed)

;;**********************************
;; A (reversed)
;; B (reversed)
;; 1 char line border
;; B (not reversed)
;;**********************************
;; A (reversed)
;; B (reversed)
;; C (reversed)
;; D (reversed)
;; C (not reversed) <-- vertical adjust

;;**********************************
;; C (not reversed except line 1 scanline, seems to be line 0)
;; rest is not reversed
;; D,E,F (not reversed)


;;**********************************
;; A single line reversed and repeated

;;**********************************
;; A reversed (half) B offset (~20 from end)

;;**********************************
;; B reversed? (half) with B at approx 20.

;;**********************************
; A half reversed with B at 41?

;;**********************************
;;  A reversed full

;;**********************************
;; A reversed (half)

;;**********************************
;; Areversed half x 3.. E at 40? E at 40? B?

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,26
ld c,b
call scr_set_border

;; set the screen mode
ld a,2
call scr_set_mode

ld h,1
ld l,1
call &bb75

ld bc,24*80
ld d,'-'
l1:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1

ld h,1
ld l,1
call &bb75

ld b,24
ld a,'A'
l1a:
push bc
push af
call &bb5a
ld a,10
call &bb5a
ld a,13
call &bb5a
pop af
pop bc
inc a
djnz l1a

ld hl,&c000
ld de,&4000
ld bc,&4000
ldir
ld hl,&4000
ld bc,&4000
l1b:
ld a,(hl)
cpl
ld (hl),a
inc hl
dec bc
ld a,b
or c
jr nz,l1b

call asic_enable
ld bc,&7fb8
out (c),c

di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc0c
out (c),c
ld bc,&bd00+&18
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+4
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld b,32
l3:
halt
djnz l3

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
ld hl,0
ld (&6420),hl
xor a
ld (&6800),a
xor a
ld (&6801),a
ld a,&ff
ld (&6420),a

ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+4-1
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc0c
out (c),c
ld bc,&bd00+&18
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c

ld a,3*8+6
ld (&6800),a

halt

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+3	;; 4 x 8
out (c),c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; normal split middle
ld a,&0f
ld (&6420),a

ld a,16
ld (&6801),a

ld l,&30
ld h,&00
ld (&6802),hl

;; mid way
ld a,15
ld (&6800),a
halt

;; now wait for 2nd line in next split
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split before border
ld a,&0
ld (&6420),a

ld a,15
ld (&6801),a

ld l,&30
ld h,20
ld (&6802),hl

ld bc,&bc06
out (c),c
ld bc,&bd00+2
out (c),c

ld a,15
ld (&6800),a
halt

ld a,1
ld (&6800),a
halt

ld bc,&bc06
out (c),c
ld bc,&bd00+4
out (c),c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split and disable border before it can be used
;; using R1
ld a,&0f
ld (&6420),a

ld l,&30
ld h,40
ld (&6802),hl

ld a,15
ld (&6801),a

ld a,14
ld (&6800),a
halt

ld bc,&bc01
out (c),c
inc b
ld de,&0000+40
rept 8
out (c),d
defs 64-4
endm
out (c),e

ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split and disable border before it can be used
;; using R1
ld a,&0
ld (&6420),a

ld l,&30
ld h,40
ld (&6802),hl

ld a,15
ld (&6801),a

ld a,15
ld (&6800),a
ld bc,&bc01
out (c),c
inc b
halt
ld de,&0000+40
rept 8
out (c),d
defs 64-4
endm
out (c),e

ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split just before vertical adjust
ld a,&0f
ld (&6420),a

ld a,31
ld (&6801),a

ld l,&30
ld h,80
ld (&6802),hl

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc05
out (c),c
ld bc,&bd00+8
out (c),c

ld a,15
ld (&6800),a
halt

ld a,1
ld (&6800),a
halt
;; vcc=0, rc=1
ld bc,&bc05
out (c),c
ld bc,&bd00
out (c),c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split just before r4=0 and r9=0
;;
;; all lines from split, same line repeat
ld a,&0
ld (&6420),a

;; A 00
;; B 40
;; C 80

ld l,&30
ld h,40
ld (&6802),hl


ld a,7+(3*8)
ld (&6801),a
ld a,7+(3*8)
ld (&6800),a
halt
defs 20
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c
defs 64*8

ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split and re-write split address after HDISP
ld a,&0f
ld (&6420),a

ld l,&30
ld h,10
ld (&6802),hl


ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

ld a,4
ld (&6801),a

ld a,3
ld (&6800),a
halt
defs 40+8+2
;; rewrite split address
ld a,23
ld (&6803),a

ld a,1
ld (&6801),a
halt
ld a,0
ld (&6803),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set R1>R0 and trigger split see if it ever triggers
ld a,&00
ld (&6420),a

ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc01
out (c),c
ld bc,&bd00+&7f
out (c),c
ld a,4
ld (&6801),a

ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set split let it capture at HDISP then set R1>R0, see if it prevents it next line
ld a,&0f
ld (&6420),a

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
ld a,40*4
ld (&6803),a

ld a,4
ld (&6801),a
ld a,3
ld (&6800),a
halt
defs 40+8
ld bc,&bc01
out (c),c
ld bc,&bd00+&7f
out (c),c

ld a,1
ld (&6800),a
halt



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wait until HDISP passed then set split to see if it is captured and used 
ld a,&0
ld (&6420),a

xor a
ld (&6801),a
ld a,40*3
ld (&6803),a
ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

ld a,3
ld (&6800),a
halt
defs 40+8

ld a,4
ld (&6801),a

ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set split after HDISP passed set no split
ld a,&0f
ld (&6420),a

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

ld a,4
ld (&6801),a

ld a,3
ld (&6800),a
halt
defs 40+8

ld a,0
ld (&6801),a

ld a,1
ld (&6800),a
halt



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ld hl,0
ld (&6420),hl
xor a
ld (&6800),a
xor a
ld (&6801),a
ld a,&ff
ld (&6420),a
ld bc,&bc01
out (c),c
ld bc,&bd00
out (c),c

;; 110 lines
ld bc,&bc04
out (c),c
ld bc,&bd00+3-1
out (c),c
ld a,16
ld (&6800),a
halt
xor a
ld (&6800),a
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
