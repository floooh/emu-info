org &170

;; top two are similar, sometimes horizontal bands can be seen
;; both flicker
; 3rd no flicker
;; 4th is worse than top two.
;; 5th is similar to first

scr_set_mode equ &bc0e
scr_set_ink equ &bc32

start:
ld a,1
call scr_set_mode
xor a
ld b,16
ld c,b
call scr_set_ink
ld a,1
ld b,3
ld c,b
call scr_set_ink
ld a,2
ld b,26
ld c,b
call scr_set_ink
ld a,3
ld b,6
ld c,b
call scr_set_ink
ld b,6*3
wcs:
halt
djnz wcs
ld hl,pat1
ld de,&c000
ld bc,&4000
ldir
ld hl,pat2
ld de,&4000
ld bc,&4000
ldir
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
ld bc,&bc0c
out (c),c
ld a,(scr)
inc b
out (c),a
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c

ld a,(scr)
xor &20
ld (scr),a
halt
halt
halt

jp loop

pat1:
incbin "pattern_mode2fa.bin"
pat2:
incbin "pattern_mode2fb.bin"
end_pat2:

scr:
defb &30

end start

