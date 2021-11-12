;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; from Inky's code
scr_next_line:
inc	h
ld	a,h
and	7
ret	nz

ld	a,l
add	a,&20
ld	l,a
ret	c

ld	a,&f8
add	a,h
ld	h,a
ret

wait_vsync_start:
halt
ret

cls:
;; clear pixels and attributes
ld hl,&4000
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&5b00-&4000-1
ldir
;; set attributes
ld hl,&5800
ld e,l
ld d,h
inc de
ld (hl),%111
ld bc,&5b00-&5800-1
ldir

ret
