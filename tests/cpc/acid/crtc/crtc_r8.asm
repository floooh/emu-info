;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; mix all r8 interlace values
org &8000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,26
ld c,b
call scr_set_border

;; type 4 shrinks pixels in green area, no jumping up and down

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
ld bc,&bc07
out (c),c
ld bc,&bd00+35
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+35
out (c),c

mainloop:
ld b,&f5
ml1:
in a,(c)
rra
jr nc,ml1
halt
ld bc,&7f10	;; normal
out (c),c
ld bc,&7f43
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c
halt
ld bc,&7f10	;; normal
out (c),c
ld bc,&7f40
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd01	;; will cause screen to shake if near start
out (c),c
halt
ld bc,&7f10	;; no change
out (c),c
ld bc,&7f4b
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd02
out (c),c
halt
ld bc,&7f10	;; skip lines (has immediate result); lines do not change always same
			;; frame
out (c),c
ld bc,&7f52
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd03
out (c),c
halt
ld bc,&7f10	;; normal
out (c),c
ld bc,&7f54
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c

jp mainloop

end start