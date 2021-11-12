org &4000

scr_set_mode equ &bc0e
scr_set_ink equ &bc32

incbin "pattern_mode1.bin"

;; top two patterns are the same
;; 3rd has obvious lines
;; 4th with vertical lines is ok

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
ld hl,&4000
ld de,&c000
ld bc,&4000
ldir
loop:
jp loop

end start

