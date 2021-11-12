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

mainloop:
ld b,&f5
ml1:
in a,(c)
rra
jr nc,ml1
ld bc,&bc07	;; steady
out (c),c
ld bc,&bdff
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+15
out (c),c
ld bc,&7f10	;; normal
out (c),c
ld bc,&7f43
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c
halt
halt
ld bc,&bc08		;;few lines where text is skipped. but then flickers after
out (c),c
ld bc,&bd03
out (c),c
halt
;; halt			;; with extra halt the text above flickers; without it
				;; the bottom is normal and the middle is static but missing lines
				;; always the same lines
ld bc,&7f10	;; normal
out (c),c
ld bc,&7f54
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
jp mainloop

end start