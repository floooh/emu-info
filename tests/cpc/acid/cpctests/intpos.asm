;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; Set each of im 0, im 1, im 2
;; set colour when int handler executed.
;; Shows relative timing of ints.
org &4000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1

di
ld a,&c3
ld hl,int_handler
ld (&0038),a
ld (&0039),hl
ld hl,&a1a1
ld e,l
ld d,h
ld bc,257
ld (hl),&a2
inc hl
ldir
ld a,&c3
ld hl,int_handler
ld (&a2a2),a
ld (&a2a3),hl
ei

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
im 0
halt
im 1
halt
im 2
halt
im 1
jr loop

int_handler:
push bc
ld bc,&7f00
out (c),c
ld bc,&7f4b
out (c),c
ld bc,&7f54
out (c),c
pop bc
reti

end start
