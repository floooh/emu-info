;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;;------------------------------------------------
;; Read from a AY-3-8912 register
;;
;; Entry conditions:
;;
;; C = register number
;; PPI port A is assumed to be set to output.
;; PSG operation is assumed to be "inactive"
;;
;; Exit conditions:
;;
;; A = register data
;; BC corrupt
;;
;; This function is compatible with the CPC+.

read_psg_reg:
ld a,c
ld bc,&fffd
out (c),a
ld bc,&fffd
in a,(c)
ret

;;------------------------------------------------
;; Write to a AY-3-8912 register
;;
;; Entry conditions:
;;
;; C = register number
;; A = data 
;; PPI port A is assumed to be set to output.
;; PSG operation is assumed to be "inactive"
;;
;; Exit conditions:
;;
;; BC corrupt
;;
;; This function is compatible with the CPC+.

write_psg_reg:
push af
ld a,c
ld bc,&fffd
out (c),a
pop af
ld bc,&bffd
out (c),a
ret

;; C = register number
select_psg_reg:
ld a,c
ld bc,&fffd
out (c),a
ret

;; not possible on Spectrum
set_psg_write_data:
ret

;; not possible on Spectrum
set_psg_inactive:
ret

;; not possible on Spectrum
set_psg_select_register:
ret

;; not possible on Spectrum
set_psg_read_data:
ret
