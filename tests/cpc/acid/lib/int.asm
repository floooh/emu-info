;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;;-------------------------------

old_int:
defs 3

store_int:
di
ld hl,&0038
ld de,old_int
ld bc,3
ldir
ei
ret

null_int:
di
ld hl,&c9fb
ld (&0038),hl
ei
ret


restore_int:
di
ld hl,old_int
ld de,&0038
ld bc,3
ldir
ei
ret
