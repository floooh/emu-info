;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; disp skew for plus includes border cover from soft scroll
org &8000
nolist

scr_set_pen equ &bc32
scr_set_border equ &bc38
txt_set_cursor equ &bb75
scr_set_mode equ &bc0e
txt_output equ &bb5a
km_wait_char equ &bb06

start:

;; ensure it's disabled
call asic_enable
call asic_ram_enable

ld a,1
call scr_set_mode

ld a,"A"
ld b,24

txt_row:

ld c,40
txt_line:
push af
push bc
call txt_output
pop bc
pop af
dec c
jr nz,txt_line
inc a
djnz txt_row

ld b,26
ld c,b
call scr_set_border

xor a
ld b,13
ld c,b
call scr_set_pen

ld a,1
ld b,18
ld c,b
call scr_set_pen

ld b,6*3
wait_col:
halt
djnz wait_col

di
ld hl,&c9fb
ld (&0038),hl
ei

loop:
ld b,&f5
l1:
in a,(c)
rra
jr nc,l1

halt

halt
halt
exx
ld hl,&6804
exx
ld bc,&bc08
out (c),c
inc b
ld d,%000000
ld e,%010000
ld h,%100000
ld l,%110000
;; d,d
;; d,e
;; d,h
;; d,l
;; e,d
;; e,e
;; e,h
;; e,l
;; h,d
;; h,e
;; h,h
;; h,l
;; l,d
;; l,e
;; l,h
;; l,l

defs 25
;;--------------------------------------
exx
ld (hl),&00
exx
rept 4
out (c),d
call mid_delay
out (c),d
call long_delay
endm

rept 4
out (c),d
call mid_delay
out (c),e
call long_delay
endm

rept 4
out (c),d
call mid_delay
out (c),h
call long_delay
endm

;;--------------------------------------

rept 4
out (c),e
call mid_delay
out (c),d
call long_delay
endm

rept 4
out (c),e
call mid_delay
out (c),e
call long_delay
endm

rept 4
out (c),e
call mid_delay
out (c),h
call long_delay
endm

;;--------------------------------------

rept 4
out (c),h
call mid_delay
out (c),d
call long_delay
endm

rept 4
out (c),h
call mid_delay
out (c),e
call long_delay
endm

rept 4
out (c),h
call mid_delay
out (c),h
call long_delay
endm


;;--------------------------------------
exx
ld (hl),&80
exx
rept 4
out (c),d
call mid_delay
out (c),d
call long_delay
endm

rept 4
out (c),d
call mid_delay
out (c),e
call long_delay
endm

rept 4
out (c),d
call mid_delay
out (c),h
call long_delay
endm

;;--------------------------------------

rept 4
out (c),e
call mid_delay
out (c),d
call long_delay
endm

rept 4
out (c),e
call mid_delay
out (c),e
call long_delay
endm

rept 4
out (c),e
call mid_delay
out (c),h
call long_delay
endm

;;--------------------------------------

rept 4
out (c),h
call mid_delay
out (c),d
call long_delay
endm

rept 4
out (c),h
call mid_delay
out (c),e
call long_delay
endm

rept 4
out (c),h
call mid_delay
out (c),h
call long_delay
endm



xor a
out (c),a
jp loop


;; [3] -> ret
;; [5] -> call
mid_delay:
defs 32-4-3-5
ret 

; [4]
; [32]
; [4]
; [24]

long_delay:
defs 24-3-5+4
ret

asic_ram_enable:
ld bc,&7fb8
out (c),c
ret

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