;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

outputdec:
push bc
push af
ld b,100                   ;divisor to obtain 100's digit value
call odd   ;display digit
ld b,10                    ;divisor to obtain 10's digit value
call odd   ;display digit
ld b,1                     ;divisor to obtain 1's digit value
call odd
pop af
pop bc
ret

;;------------------------------------------------
;; B = divisor
;; A = dividend

odd:

;;-----------------------------------------------
;; simple division routine
ld c,0                     ;zeroise result 

odd1: 
sub b                      ;subtract divisor
jr c,odd2 ;if dividend is less than divisor, the division
                           ;has finished.

inc c                      ;increment digit value
jr odd1

odd2:
add a,b                   ;add divisor because dividend was negative,
                          ;leaving remainder.

;;--------------------------------------
;; A = dividend
;; C = result of division

;;--------------------------------------
;; digit is a number between 0..9
;; convert this into a ASCII character '0'..'9' then display this

push af
ld a,c                    ;get digit value
add a,"0"                 ;convert value into ASCII character
call output_char           ;display digit
pop af
ret
