;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

if 0
jr_macro macro _space
jr $f1

defs _space

$l1
jr l1

defs _space

$b1
jr $f2

defs _space

$l2
jr $l2

defs _space

$f1
jr $b1

defs _space

$l3
jr $l3

defs _space

$f2:
endm

jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro
jr_macro


endif