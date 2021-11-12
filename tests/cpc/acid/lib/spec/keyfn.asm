;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; scan keyboard before checking

;; A = 0 if no key pressed, !=0 otherwise
is_key_pressed:
push hl
push bc
ld hl,matrix_buffer
ld b,8
;; this assumes bit is set if key pressed, clear otherwise
xor a
kp1:
or (hl)
inc hl
djnz kp1
or a
;; A = 0 if no key pressed, !=0 otherwise
pop bc
pop hl
ret

wait_key:
push bc
push hl
push de
wait_key2:
	halt
	call readkeys
	call is_key_pressed
	jr z,wait_key2
	pop de
	pop hl
	pop bc
	ret
	
