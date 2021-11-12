;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; hl = first buffer
;; de = second buffer
;; bc = length

check_2buf_same:
ld a,(de)		;; read byte
xor (hl)		;; XOR with other byte
ret nz
inc de
inc hl
dec bc
ld a,b
or c
jr nz,check_same
ret

;;-----------------------
;; hl = start of buffer
;; bc = length of buffer
;; zero set = same, not zero = not same

check_1buf_same:
;; get first
ld a,(hl)
inc hl
dec bc

cas1:
;; count over?
ld a,b
or c
ret z
;; get next byte
xor (hl)
ret nz
;; increment buffer ptr
inc hl
dec bc
jr cas1

