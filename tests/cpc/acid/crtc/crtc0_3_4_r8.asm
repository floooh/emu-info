;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

crtc_reg equ 8
val_active equ %110000
val_inactive equ %000000

;; no effect HD6845R

include "../include/crtc_r6_r8.asm"
