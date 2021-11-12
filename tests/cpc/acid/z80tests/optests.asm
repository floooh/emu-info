;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000

start:

defb &dd
defb &dd
defb &dd
nop
defb &fd
defb &fd
defb &fd
nop
defb &dd
defb &fd
defb &dd
defb &fd
nop
defb &dd
nop

defb &dd
ld bc,&1234

end start