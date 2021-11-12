;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

outputhex16:
ld a,h
call outputhex8
ld a,l
call outputhex8
ret


outputhex8:
push af
rrca
rrca
rrca
rrca
call outputhexdigit
pop af
outputhexdigit:
and &f
add a,"0"	
cp "0"+10
jr c,oh82
add a,"A"-"0"-10
oh82:
jp output_char
