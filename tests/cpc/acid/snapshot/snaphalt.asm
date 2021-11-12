;; Run this program and make a snapshot when the
;; border turns grey.
;;
;; Load the snapshot. The background should remain
;; grey. If the background changes to yellow then
;; snapshot taken when CPC is halted is incorrect.
;; 
;; CPC should remain halted after snapshot taken
;; execution should not continue.
org &8000
start:
ld bc,&7f00+%10001100
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c
halt
halt
halt
ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c
di
halt
ld bc,&7f10
out (c),c
ld bc,&7f43
out (c),c
loop: 
jp loop

end start