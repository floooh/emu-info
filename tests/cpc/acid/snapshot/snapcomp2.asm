org &8000

start:
di

ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

;; 256 of each to check max length
ld hl,&c000
ld b,&40
ld d,&100-&40
s1:
rept 256
ld (hl),d
endm
inc hl
inc d
dec bc
ld a,b
or c
jp nz,s1

;; 4000-ffff is only 01
ld hl,&4000
ld e,l
ld d,h
inc de
ld (hl),&01
ld bc,&3fff
ldir

ld bc,&7f10
out (c),c
ld bc,&7f4b
out (c),c
loop:
jp loop


end start