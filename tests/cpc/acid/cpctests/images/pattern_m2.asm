org &4000

scr_set_mode equ &bc0e
scr_set_ink equ &bc32

incbin "pattern_mode2.bin"

;; first two look the same (merged). dots can sometimes be obvious to see in the pattern
;; 3rd is obviously lined
;; 4th has vertical bands stripes but is also merged.
;; 5th is merged on each line
;; 6th is partially merged
;; 7th is diagonals

start:
ld bc,&bc08
out (c),c
ld bc,&bd00+1
out (c),c
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
ld hl,&4000
ld de,&c000
ld bc,&4000
ldir
loop:
jp loop

end start

