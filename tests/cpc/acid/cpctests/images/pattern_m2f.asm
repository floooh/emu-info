org &170

;; like mode 1; top two flicker, with visible lines sometimes
;; 4th is worse
;; 5th is ok but still flickers
;; 6th and seventh are ok. seventh is ligher, 6th is darker.
scr_set_mode equ &bc0e
scr_set_ink equ &bc32

start:
ld a,2
call scr_set_mode
xor a
ld b,6
ld c,b
call scr_set_ink
ld a,1
ld b,16
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

