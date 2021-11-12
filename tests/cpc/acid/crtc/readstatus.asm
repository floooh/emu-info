;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000
nolist

di
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd1f
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&ee
out (c),c

ld bc,&bc02
out (c),c
ld bc,&bd00
out (c),c

ld hl,val_tab

ld bc,&bc0a
out (c),c

ld b,&f5
v1:
in a,(c)
rra
jr nc,v1
v2:
in a,(c)
rra
jr c,v2

v3:
in a,(c)
rra
jr nc,v3
ld b,&bf

ld e,0
get_v:
in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

defs 8

defs 8-3-1

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

in a,(c)
ld (hl),a
inc hl

dec e
jp nz,get_v
ei
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c
ld bc,&bc02
out (c),c
ld bc,&bd00+46
out (c),c
ret

val_tab:
defs 312
