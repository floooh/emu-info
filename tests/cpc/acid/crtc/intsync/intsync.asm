;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000
nolist

mc_wait_flyback equ &bd19
scr_next_line equ &bc26

start:
ld hl,topscr
ld de,&c000
call dump_scr
ld hl,botscr
ld de,&c800
call dump_scr

ld bc,&bc08
out (c),c
ld bc,&bd03
out (c),c
scrloop:
call mc_wait_flyback
jp scrloop

dump_scr:
ld b,100
dump_scr2:
push bc
push de
ld bc,80
ldir
pop de
ex de,hl
call scr_next_line
call scr_next_line
ex de,hl
pop bc
djnz dump_scr2
ret


topscr:
incbin "imgtop.bin"
botscr:
incbin "imgbot.bin"

end start