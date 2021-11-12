;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; turn on/off aleste black

org &8000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
scr_set_border equ &bc38

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,1
call scr_set_mode
ld b,26
ld c,b
call scr_set_border

;; type 4 shrinks pixels in green area, no jumping up and down

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1
di
ld hl,&c9fb
ld (&0038),hl
ei

mainloop:
ld b,&f5
ml1:
in a,(c)
rra
jr nc,ml1
halt
call do_black
halt
halt
call do_black
jp mainloop

do_black:
ld h,%00000000 ;; active low
ld l,%00001000
ld bc,&fabf
rept 8
out (c),h
out (c),l
out (c),h
out (c),l
out (c),h
out (c),l
out (c),h
out (c),l
defs 64-32
endm
ret


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test turns on/off the BLACK output which blanks the graphics to black.",13,10,13,10
defb "Black is Bit 3, port fabf",13,10,13,10
defb "In this test you should see vertical stripes of black and pixels in ",13,10
defb "the upper border and within the graphics",13,10,13,10
defb "THIS TEST NEEDS CONFIRMING ON A REAL ALESTE",13,10,13,10
defb "Press a key to start",0

end start