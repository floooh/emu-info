;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &4000

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
ld hl,&c9fb
ld (&0038),hl
ei

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2

halt
halt
di
ld bc,&bc00+crtc_reg
ld d,val_active
ld e,val_inactive
out (c),c
inc b

;; vertical stripes 16 lines tall
rept 16
out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e
endm

rept 16
out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

out (c),d
out (c),e

defs 64*2
endm

ld a,40
loop2:
out (c),d
out (c),e
defs 16
out (c),d
out (c),e
defs 64-16-8-8-1-3-1
dec a
jp nz,loop2
ei

jp loop

end start
