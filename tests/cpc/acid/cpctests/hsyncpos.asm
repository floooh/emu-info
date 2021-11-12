;; use to find min/max monitor will display for line length
;;
;; with this test.
;; imagine a horizontal bar = ears
;; below a black triangle (back of the head)
;; to the right a triangle to make a pointed nose
;; this eventually goes back into a vertical line almost middle of the screen

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
ld hl,hsyncpos
inc b
ld e,200

hloop:
ld a,(hl)	;; [2]
out (c),a	;; [4]
inc hl		;; [2]
dec e		;; [1]
defs 64-2-4-2-1-3
jp nz,hloop	;; [3]
jp mainloop

hsyncpos:
defb 46
defb 47
defb 48
defb 49
defb 50
defb 51
defb 52
defb 53
defb 54
defb 55
defb 56
defb 57
defb 58
defb 59
defb 60
defb 61
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46
defb 46

end start