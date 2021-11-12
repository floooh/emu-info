org &8000
nolist

;; works on gx4000 - stable picture
;; 11111110 -> odd when no VSYNC, even when VSYNC
;; not work on 6128+ - not stable picture
;; 11011110 -> even when no VSYNC.
;;
;; on 464+ initially not work then worked, motor on always seems to work?
;; ?1111110 - cassette must be 0
;; 11111110 - cassette must be 1
;;
;; works on 6128.

start:
di
ld hl,&c9fb
ld (&0038),hl
ei
ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&3fff
ldir

ld bc,&f610
out (c),c

loop:
ld b,&f5
l1:
defb &ed,&70
jp po,l1
halt
halt
ld bc,&7f00
out (c),c
ld bc,&7f43
out (c),c
halt
halt
ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c
jp loop

end start