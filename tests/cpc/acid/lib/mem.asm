;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

clear_ram:
xor a
jr fill_ram

fill_ram:
;; clear area so we get zero if address is wrong.
ld e,l
ld d,h
inc de
ld (hl),a
ldir
ret


;; C = bit value (0-7)
;; A = or mask
to_or_mask:
push bc
ld a,1
tom1:
dec c
jp m,tom2
add a,a
jr tom1
tom2:
pop bc
ret

to_and_mask:
call to_or_mask
cpl
ret

;;---------------------------------------------------------------------------------

;; IX = result buffer
;; BC = port number 
;; E = mask
port_rw_test:
ld d,0				;; initial value


loop_port_rw_test:
;; write value
out (c),d

;; read it back
in a,(c)
and e				;; mask it
ld (ix+0),a			;; got
inc ix
ld (ix+0),d			;; expected
inc ix

inc d
jr nz,loop_port_rw_test
ret
;;---------------------------------------------------------------------------------


;; IX = result buffer
;; BC = port number upper 8-bits
;; DE = number of iterations
port_r_test:
loop_port_r_test:
in a,(c)
ld (ix+0),a
inc ix
dec de
ld a,d
or e
jr nz,loop_port_r_test
ret


