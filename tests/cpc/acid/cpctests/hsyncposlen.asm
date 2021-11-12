;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; vertical lines on both sides

;; HD6845R: 5,4 for smooth scroll not 6,5

org &8000

start:
di 
ld hl,&c000
ld e,l
ld d,h
inc de
ld bc,&3fff
ld (hl),0
ldir
ld bc,&7f00+%10001110
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f00+&54
out (c),c
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&8e
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+35
out (c),c

ld hl,&c9fb
ld (&0038),hl
ei

mainloop:
ld b,&f5
ml:
in a,(c)
rra
jr nc,ml
halt
halt
ld bc,&bc02
out (c),c
ld bc,&bd00+46
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&84
out (c),c
defs 64-3-4-3-4-3-4-3-4

ld bc,&bc02
out (c),c
ld bc,&bd00+47
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&85
out (c),c
defs 64-3-4-3-4-3-4-3-4

ld bc,&bc02
out (c),c
ld bc,&bd00+48
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&86
out (c),c
defs 64-3-4-3-4-3-4-3-4

jp mainloop

end start