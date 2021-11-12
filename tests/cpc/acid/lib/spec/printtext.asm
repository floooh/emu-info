;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;;+3 centronics printer interface
printchar:
ld bc,&07fd
out (c),a
push af
ld bc,&1ffd
xor a
out (c),a
ld a,%10000
out (c),a
pop af
	ret
	
printnl:
ld a,13
call printchar
	ret
	