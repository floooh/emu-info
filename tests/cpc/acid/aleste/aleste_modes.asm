;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; switch mapmod to see if colours change between 64colour palette and cpc palette


org &8000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
scr_set_border equ &bc38
mc_set_mode equ &bd1c
scr_set_base equ &bc08

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

xor a
call &bc0e

xor a
ld b,16
t1:
push bc
push af
call &bb90
ld hl,text
call display_text

pop af
inc a
pop bc
djnz t1

ld hl,&1000
ld e,l
ld d,h
ld (hl),&aa
inc de
ld bc,&4000-&1000
ldir


ld hl,&9000
ld e,l
ld d,h
ld (hl),&aa
inc de
ld bc,&a700-&9000

ldir

ld hl,&c000
ld de,&4000
ld bc,&4000
ldir

ld hl,&4000
call scr_set_base

ld b,16
xor a
set_mode:
push bc
push af
push af
;; set mode using firmware
and &3

;; this is mc_set_mode with check for mode 3 removed.
di      
exx     
res     1,c				;; clear mode bits (bit 1 and bit 0)
res     0,c

or      c				;; set mode bits to new mode value
ld      c,a
out     (c),c			;; set mode
ei      
exx     

pop af
;; set hightx, highty
rrca
rrca
and &3
or %1000	;; turn off blacks, turn off map mod
ld bc,&fabf
out (c),a
push af
call km_wait_char
pop af
or %100	;; enable map mod
ld bc,&fabf
out (c),a
call km_wait_char
pop af
pop bc
inc a
djnz set_mode
rst 0

display_text:
ld a,(hl)
or a
ret z
inc hl
call &bb5a
jr display_text

text:
defb "ALESTE 520EX",13,10,0


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test sets all the aleste video modes",13,10
defb "using combinations of mode (7f00, bit 7=1,bit 6=0, bits 1,0)",13,10
defb "and combinations of hightx and highty (fabf, bits 0,1)",13,10
defb "In this test you should see pictures on each of the screens",13,10,10
defb "THIS TEST NEEDS CONFIRMING ON A REAL ALESTE",13,10,13,10
defb "Press a key to start",0

end start