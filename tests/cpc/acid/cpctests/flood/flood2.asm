;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;;
;; test of R4=0, R9=0

org &4000

start:
ld a,2
call &bc0e

ld hl,&8000
ld e,l
ld d,h
inc de
ld (hl),&ff
ld bc,&a600-&8000
ldir

ld hl,&0040
ld e,l
ld d,h
inc de
ld (hl),&aa
ld bc,&3fff-&40
ldir


ld hl,&c000
ld bc,&4000
ld d,0
s2:
ld (hl),d
inc hl
inc d
dec bc
ld a,b
or c
jr nz,s2

ld hl,table
ld de,&3000
ld bc,200
s1:
ld (hl),d
inc hl
ld (hl),e
inc hl
djnz s1

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+7
out (c),c
ld bc,&bc02
out (c),c
ld bc,&bd00+48
out (c),c
ld bc,&bc01
out (c),c
ld bc,&bd00+48
out (c),c
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
;; ensure counter is reset
ld bc,&7f00+%10011110
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd06-1
out (c),c
halt
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

;; HCC = 4, VCC=0, RA=6
defs 128-10-&c
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd01
out (c),c

defs 64-3-3-3-3-4-4-4-4-3
di
ld hl,table

rept 200
ld bc,&bc04
out (c),c
ld bc,&bd01
out (c),c
ld bc,&bc0c
out (c),c
ld b,&be
outi
ld bc,&bc0d
out (c),c
ld b,&be
outi
defs 64-5-2-3-4-5-2-4-3-4-3-4-3
endm
ei
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+8
out (c),c
ld bc,&bc0c
out (c),c
ld bc,&bd00+&20
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c
halt
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

jp loop

table:
defs 200*2

end start