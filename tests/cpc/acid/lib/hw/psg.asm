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

;; step 1: select register

;; write register index to PPI port A
ld b,&f4
out (c),c

;; set PSG operation -  "select register"
ld bc,&f6c0
out (c),c

;; set PSG operation -  "inactive"
ld bc,&f600
out (c),c

;; PPI port A set to input, PPI port B set to input,
;; PPI port C (lower) set to output, PPI port C (upper) set to output
ld bc,&f700+%10010010
out (c),c

;; set PSG operation -  "read register data"
ld bc,&f640
out (c),c

;; step 2 -  read data from register

;; read PSG register data from PPI port A
ld b,&f4
in a,(c)

;; PPI port A set to output, PPI port B set to input,
;; PPI port C (lower) set to output, PPI port C (upper) set to output
ld bc,&f700+%10000010
out (c),c

;; set PSG operation -  "inactive"
ld bc,&f600
out (c),c
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

;; step 1 -  select register
call select_psg_reg

;; step 2 -  write data to register 

;; write data to PPI port A
ld b,&f4
out (c),a

;; set PSG operation -  "write data to register"
ld bc,&f680
out (c),c

;; set PSG operation -  "inactive"
ld bc,&f600
out (c),c
ret

;; C = register number
select_psg_reg:
;; write register index to PPI port A
ld b,&f4
out (c),c

;; set PSG operation -  "select register"
ld bc,&f6c0
out (c),c

;; set PSG operation -  "inactive"
ld bc,&f600
out (c),c
ret

set_psg_write_data:
push bc
ld bc,&f680
out (c),c
pop bc
ret

set_psg_inactive:
push bc
ld bc,&f600
out (c),c
pop bc
ret

set_psg_select_register:
push bc
ld bc,&f6c0
out (c),c
pop bc
ret

set_psg_read_data:
push bc
ld bc,&f640
out (c),c
pop bc
ret
