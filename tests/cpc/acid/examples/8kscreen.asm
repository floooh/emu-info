;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

8k_screen:
;; scanlines
;; will only work correct on ctm monitor

;; others are defaults

;; half the number of lines for each char
ld bc,&bc09
out (c),c
ld bc,&bd00+3
out (c),c

;; twice as many chars horizontally
ld bc,&bc00
out (c),c
ld bc,&bd00+127
out (c),c

;; lines in between will be border
;;
;; screen now takes 8K
ret

;; 38+1 = 39
;; 39*8 = 312
;; 156

;; 19+2

;; 1 char tall
ld bc,&bc04
out (c),c
ld bc,&bc00
out (c),c

;; 1 line tall
ld bc,&bc09
out (c),c
ld bc,&bc00
out (c),c

;; extra line added by vert adjust
;; 8 lines tall
ld bc,&bc05
out (c),c
ld bc,&bc01	
out (c),c
