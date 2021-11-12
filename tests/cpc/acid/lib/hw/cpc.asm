;; wait at least 2 lines
wait_x_lines:
dec a		;; [1]
wxl1:
defs 64-1-3
dec a		;; [1]
jp nz,wxl1	;; [3]
defs 64-1-3-5-2	;; for dec, ret, call, and ld a,n
ret			;; [3]

do_restart:
ld hl,restart
ld de,&be00
push de
ld bc,end_restart-restart
ret

restart:
ld bc,&7f89
out (c),c
jp 0
end_restart:
