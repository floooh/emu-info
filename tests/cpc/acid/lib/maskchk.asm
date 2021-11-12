;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; A = value
;; B = mask
check_mask:
	ld c,a
	;; C = value read
	and b
	;; A = value read ANDed with Mask
	;; compare with original
	cp c
	ret
	
