;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

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
ei

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
halt
;; wait a few lines then force clear 
;; to ensure next int is no closer than 52 lines
di
ld b,4
call wait_b_lines
ld bc,&7f00+%10010000
out (c),c
ei
halt
; delay int by 33 lines and see it jump a bit more
di
ld b,33
call wait_b_lines
ei


jp loop

wait_b_lines:
dec b
w31l:
defs 64-1-3
dec b
jp nz,w31l
defs 64-1-3-5
ret

int_handler:
push bc
ld bc,&7f00
out (c),c
ld bc,&7f4b
out (c),c
ld bc,&7f54
out (c),c
pop bc
ei
ret

end start
