;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

readkeys:
;; store previous values
ld hl,matrix_buffer
ld de,old_matrix_buffer
ld bc,8
ldir

ld hl,matrix_buffer        ; buffer to store matrix data
ld e,8
ld bc,&fefe
rk1:
in a,(c)
cpl
and %11111
ld (hl),a
inc hl
ld a,b
rlca
ld b,a
dec e
jr nz,rk1
ret

if 0
wait_key:
halt

call readkeys
;; key matrix
ld hl,matrix_buffer
;; number of lines
ld b,8
;; initial state
xor a
wk3:
;; 0 for no key pressed
or (hl)
inc hl
djnz wk3
or a
jr z,wait_key
ret 
endif

matrix_buffer:
defs 8
old_matrix_buffer:
defs 8
