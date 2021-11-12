;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This test uses IN instructions only to draw a raster bar.
;; Works on Plus.
org &4000

test:
di
ld hl,&c9fb
ld (&0038),hl
ei

l1:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
halt
defs 32
;; set pen
ld bc,&7f00
out (c),c


in d,(c)    ;; [4]    blue
defs 64-4
in d,(c)    ;; [4]    blue
defs 64-4
in e,(c)    ;; [4]     magenta
defs 64-4
in a,(c)    ;; [4]     magenta
defs 64-4
in c,(c)    ;; [4]    purple
defs 64-4
in c,(c)    ;; [4]    purple
defs 64-4
in h,(c)    ;; [4]     grey, same as in b,(c) but without having to re-program B
defs 64-4
in h,(c)    ;; [4]     grey, same as in b,(c) but without having to re-program B
defs 64-4
in c,(c)    ;; [4]    purple
defs 64-4
in c,(c)    ;; [4]    purple
defs 64-4
in a,(c)    ;; [4]     magenta
defs 64-4
in e,(c)    ;; [4]     magenta
defs 64-4
in d,(c)    ;; [4]    blue
defs 64-4
in d,(c)    ;; [4]    blue
defs 64-4

;; yellow
ld a,&43
out (c),a

jp l1

end test
