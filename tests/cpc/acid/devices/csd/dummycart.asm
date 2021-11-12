;; The Amstrad Software Cartridge Demonstrator (CSD)
;; Looks at the cartridge for a specific header.
;; This code implements the minimal cartridge it is looking for
;; in order to determine the functionality it wants.
;; This code will compile with pasmo.
org &0000

start:

;; a standard cartridge is executed here when inserted into
;; a CPC+.

jp start1			;; a JP instruction at &0000
defb "AMS"			;; this is the important identification
jp start2			;; a JP instruction at &0006
jp start3			;; a JP instruction at &0009

start1:
ld bc,&7f00
out (c),c
ld bc,&7f4f
out (c),c
jp start1

start2:
ld bc,&7f00
out (c),c
ld bc,&7f4b
out (c),c
jp start2

start3:
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
jp start3

end start