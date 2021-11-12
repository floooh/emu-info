;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; better but frame needs to be longer on real plus
org &8000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

;; purple
;;---------------------------------------------------------------------------------------
;; A reversed
;; B reversed but last line not reversed
;; A reversed
;; B reversed but last line not reversed
;;---------------------------------------------------------------------------------------
;; A reversed
;; C reversed near middle
;; C not reversed (except first scanline)
;; E not reversed
;;---------------------------------------------------------------------------------------
;; C not reversed except first scanline
;; C not reversed
;; C not reversed except first scanline
;; C not reversed
;;---------------------------------------------------------------------------------------
;; C not reversed except first scanline
;; D not reversed
;; C not reversed except first scanline
;; C not reversed
;;---------------------------------------------------------------------------------------
;; C not reversed except first scanline
;; D not reversed
;;---------------------------------------------------------------------------------------
;; C not reversed except first scanline
;; border
;; A reversed
;; border
;;---------------------------------------------------------------------------------------
;; A reversed
;; border
;; A reversed
;; border
;;---------------------------------------------------------------------------------------
;; A reversed
;; border
;; single scanline reversed then B not reversed with B mid way
;; border
;; single scanline reversed then B not reversed with B mid way
;; border
;;---------------------------------------------------------------------------------------
;; purple


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
ld bc,&bd00+1
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld b,32
l3:
ld de,2000
l2a:
dec de
ld a,d
or e
jr nz,l2a
;;halt
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
defs 40

;; on arnold passes without the wait
ld bc,&bc04
out (c),c
ld bc,&bd00+1;; 2 scans 16 lines	
out (c),c


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split on scan-line before last 
ld a,&0f
ld (&6420),a

ld a,14
ld (&6801),a

ld l,&30
ld h,20
ld (&6802),hl

;; 4 then 4 seems to trigger on the same line!
ld a,4
ld (&6800),a
halt
ld a,3
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HDISP = HTOT-1, split on last scanline
ld a,&00
ld (&6420),a

ld bc,&bc01
out (c),c
ld bc,&bd00+&3f
out (c),c

ld a,15
ld (&6801),a

ld l,&30
ld h,80
ld (&6802),hl

ld a,4
ld (&6800),a
halt
ld a,3
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HDISP = HTOT, split on last scanline
ld a,&0f
ld (&6420),a

ld bc,&bc01
out (c),c
ld bc,&bd00+&40
out (c),c

ld a,15
ld (&6801),a

ld l,&30
ld h,80
ld (&6802),hl

ld a,4
ld (&6800),a
halt
ld a,3
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split last scanline R1>R0
ld a,&0
ld (&6420),a

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld a,15
ld (&6801),a

;; 0 = A
;; 40 = b
;; 80 = c
;; 120 = d
ld l,&30
ld h,80
ld (&6802),hl

ld a,14
ld (&6800),a
halt
;; happens on split line, hdisp not reached


;; 62/64
;; 50+3+4+3+4
ld bc,&bc01
out (c),c
ld bc,&bd00+&7f
out (c),c
ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split last scanline R1>R0 then restore R1=40
ld a,&0f
ld (&6420),a

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld a,15
ld (&6801),a

;; 00 = a
;; 40 = b
;; 80 = c
ld l,&30
ld h,80
ld (&6802),hl

ld a,14
ld (&6800),a
halt
ld bc,&bc01
out (c),c
ld bc,&bd00+&7f
out (c),c
defs 64*2
ld c,40	;; restore hdisp
out (c),c
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split before border
ld a,&00
ld (&6420),a

ld a,7
ld (&6801),a

ld l,&30
ld h,20
ld (&6802),hl

ld bc,&bc06
out (c),c
ld bc,&bd00+1
out (c),c

ld a,15
ld (&6800),a
halt
ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split inside border

ld a,&0f
ld (&6420),a

ld a,9
ld (&6801),a

ld l,&30
ld h,20
ld (&6802),hl

ld bc,&bc06
out (c),c
ld bc,&bd00+1
out (c),c

ld a,15
ld (&6800),a
halt
ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split last line inside border

ld a,&00
ld (&6420),a

ld a,15
ld (&6801),a

ld l,&30
ld h,20
ld (&6802),hl

ld bc,&bc06
out (c),c
ld bc,&bd00+1
out (c),c

ld a,15
ld (&6800),a
halt
ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

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
ld bc,&bc04
out (c),c
ld bc,&bd03
out (c),c
ld a,15
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
