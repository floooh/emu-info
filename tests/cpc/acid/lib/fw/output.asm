;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

writechar equ &bb5a
printchar equ &bd2b
km_wait_char equ &bb06
km_read_char equ &bb09
scr_set_mode equ &bc0e
txt_set_pos equ &bb75
txt_get_pos equ &bb78

nl_should_wait_key:
ld a,(line_count)
inc a
ld (line_count),a
cp 25
ret nz
xor a
ld (line_count),a
ret


set_text_coords:
inc h
inc l
jp txt_set_pos

printnl:
	ld a,13
	call printchar
	ld a,10
	jp printchar


writenl:
	ld a,13
	call writechar
	ld a,10
	jp writechar

cls:
xor a
ld (line_count),a
	ld a,2
	call scr_set_mode
	ld h,0
	ld l,0
	jp set_text_coords

wait_key:
call flush_keyboard
jp km_wait_char

get_key:
jp km_read_char

	
flush_keyboard:	
call km_read_char
jr c,flush_keyboard
ret

line_count: defb 0