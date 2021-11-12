;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;;-------------------------------------------------------------------------------
;; display a number as a 8-digit binary number 
;;
;; Entry Conditions:
;;
;; A = number (0-255)
;;
;; Exit Conditions:
;;
;; A

output_bin:
push bc
;; 8 digits in binary number
ld b,8
ob:
;; transfer bit 7 into carry
rlca
push af
ld a,"0"
;; convert to ASCII
;; 0-> "0" and 1-> "1"
adc a,0
;; display digit on the screen
call output_char

pop af
djnz ob
pop bc
ret
