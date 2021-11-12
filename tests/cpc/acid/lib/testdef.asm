;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

DEFINE_TEST macro _name, _addr
defb _name
defb 0
defw _addr
endm

DEFINE_MESSAGE macro _message
defb _message
defb 0
defw 0
endm

DEFINE_END_TEST macro
defb 0
defw 0
endm

