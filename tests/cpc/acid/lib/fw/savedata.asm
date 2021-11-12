cas_out_open equ &bc8c
cas_out_direct equ &bc98
cas_out_close equ &bc8f
cas_out_char equ &bc95

begin_save_data:
ld de,two_k_buffer
call cas_out_open
ld a,1
ld (save_data_active),a
ret

finish_save_data:
call cas_out_close
xor a
ld (save_data_active),a
ret

save_data_active:
defb 0

;; hl = address
;; de = length
save_test_data:
push hl
push de
push bc
push af
push ix

ld a,(save_data_active)
or a
jr z,std1

std2:
ld a,(hl)
inc hl
push hl
push de
call cas_out_char
pop de
pop hl
dec de
ld a,d
or e
jr nz,std2

std1:
pop ix
pop af
pop bc
pop de
pop hl
ret

two_k_buffer:
defs 2048
