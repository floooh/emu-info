;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

;; purple
;;-----------------------------------------------------------------------------------------------
;; A reversed
;; B reversed
;; A first line reversed rest not
;; B not reversed
;;-----------------------------------------------------------------------------------------------
;; A first line reversed rest not
;; B not reversed
;; graphics from? 
;; ----------------------------------------------------------------------------------------------
;; graphics from?
;;-----------------------------------------------------------------------------------------------
;; A reversed
;; B reversed
;; B reversed but at 20 chars in
;; C reversed but at 20 chars in
;;-----------------------------------------------------------------------------------------------
;; B reversed but at 20 chars in
;; A not reversed
;; B reversed but at 20 chars in
;; B reversed but at 30 chars in
;;-----------------------------------------------------------------------------------------------
;; B reversed but at 20 chars in
;; C reversed but at 20 chars in
;; D reversed but at 20 chars in
;; A not reversed (last 6 lines)
;; B not reversed (last 6 lines)
;;
;; few lines reversed but 20 chars in
;; B not reversed (30 chars in)
;; C not reversed (30 chars in)

;; few lines reversed but 20 chars in
;; B not reversed (30 chars in)
;; 
;;---------------------------------------------------------------------------------------------------
;; B reversed just below ---
;; D about 30 chars in
;; B reversed but at 20 chars in
;; D reversed but at 30 chars in
;; B reversed but at 20 chars in
;;------------------------
;; purple.

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
ld bc,&bc04
out (c),c
ld bc,&bd00+1	
out (c),c


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split on last scan-line, change SSA before being used on next frame
ld a,&0f
ld (&6420),a

ld a,15
ld (&6801),a

ld l,&30
ld h,80
ld (&6802),hl

ld a,14
ld (&6800),a
halt
defs 8
ld l,&30
ld h,00
ld (&6802),hl

ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; change R12/R13 on first line
ld a,&0
ld (&6420),a

ld bc,&bc0c
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c
xor a
ld (&6801),a
ld a,15
ld (&6800),a
halt
ld bc,&bc0c
out (c),c
ld bc,&bd00+&20
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c

ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

ld bc,&bc0c
out (c),c
ld bc,&bd00+&18
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; change R13 on first scan-line 
ld a,&0
ld (&6420),a

xor a
ld (&6801),a

ld a,7
ld (&6800),a
halt
ld bc,&bc0d
out (c),c
ld bc,&bd00+31
out (c),c

ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split last line and change split address after
ld a,&0f
ld (&6420),a

ld l,&30
ld h,0
ld (&6802),hl
ld a,7
ld (&6801),a
ld a,7
ld (&6800),a
halt
defs 8
ld l,&18
ld h,23
ld (&6802),hl 

ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split and change  
ld a,&0
ld (&6420),a

ld l,&30
ld h,0
ld (&6802),hl 
ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
ld (&6801),a
halt
ld h,4
ld (&6802),hl 
defs 64-2-5
ld h,8
ld (&6802),hl 
defs 64-2-5
ld h,16
ld (&6802),hl 
defs 64-2-5
ld h,32
ld (&6802),hl 
defs 64-2-5
ld h,48
ld (&6802),hl 
defs 64-2-5
ld h,52
ld (&6802),hl 
defs 64-2-5
ld h,64
ld (&6802),hl 
defs 64-2-5
ld h,3
ld (&6802),hl 
defs 64-2-5
ld h,6
ld (&6802),hl 
defs 64-2-5
ld h,9
ld (&6802),hl 
defs 64-2-5
ld h,12
ld (&6802),hl 
defs 64-2-5
ld h,15
ld (&6802),hl 
defs 64-2-5

ld a,4
ld (&6800),a
halt
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set split after HDISP passed set no split, then set HDISP
ld a,&0
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
defs 40+8-3-4

ld bc,&bc01
out (c),c

ld a,0
ld (&6801),a

ld bc,&bd00+55
out (c),c

ld a,1
ld (&6800),a
halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set split after HDISP passed set new HDISP
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
defs 40+8-3-4

ld bc,&bc01
out (c),c
ld bc,&bd00+55
out (c),c

ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split inside vertical adjust
ld a,&0f
ld (&6420),a

ld bc,&bc05
out (c),c
ld bc,&bd00+8
out (c),c

;; I don't think this works!
;; within vertical adjust
ld a,7+4
ld (&6801),a

ld l,&30
ld h,20
ld (&6802),hl

;; I am not sure this works
ld a,7
ld (&6800),a
halt
defs 8*64
;;ld a,1
;;ld (&6800),a
halt
ld bc,&bc05
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00
out (c),c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split but turn it on mid line
ld a,&00
ld (&6420),a
xor a
ld (&6800),a
ld h,&00
ld l,&30
ld (&6802),a

ld a,8
ld (&6801),a
ld a,9
halt
;; just before start of line
ld (&6800),a
defs 64
ld a,1
ld (&6800),a
halt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; split but turn it on mid line just after HCC=0
ld a,&0f
ld (&6420),a
xor a
ld (&6800),a
ld h,&00
ld l,&30
ld (&6802),a

ld a,8
ld (&6801),a
ld a,9
halt
defs 32
ld (&6800),a
defs 64
ld a,1
ld (&6800),a
halt




ld a,&ff
ld (&6420),a

ld bc,&bc04
out (c),c
ld bc,&bd00+4-1
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
