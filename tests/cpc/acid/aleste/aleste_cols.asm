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

di
ld hl,&c9fb
ld (&0038),hl
ei

;; enable map mod; disable blacks
ld a,%00001100
ld bc,&fabf
out (c),a

xor a
ld b,&7f
ld hl,colours
sp1:
push af
out (c),a ;; sel pen
ld a,(hl)
inc hl
out (c),a ;; set colour
pop af
inc a
djnz sp1
ld bc,&7f10
out (c),c
ld bc,&7f00+%01010101
out (c),c

;; now toggle map mod, does the colours change?
ld a,%00001100
ld (mapmod),a


loop:
ld e,50
start3:
ld b,&f5
start2:
in a,(c)
rra
jr nc,start2
halt
halt
dec e
jr nz,start3

ld a,(mapmod)
xor %00000100
ld (mapmod),a
ld bc,&fabf
out (c),a
jp loop

mapmod:
defb 0

display_text:
ld a,(hl)
or a
ret z
inc hl
call &bb5a
jr display_text

colours:
defb %000000
defb %010101
defb %101010
defb %111111
defb %010000
defb %100000
defb %110000
defb %000100
defb %001000
defb %001100
defb %000001
defb %000010
defb %000011
defb %111111
defb %100111



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
defb "This test displays text with all 16 pens. MAPMOD is turned on/off.",13,10,13,10
defb "In this test you should see the colours changing between 64-colour",13,10
defb "mode and CPC colour mode.",13,10,13,10
defb "MAPMOD is bit 2 of port fabf.",13,10,13,10
defb "THIS TEST NEEDS CONFIRMING ON A REAL ALESTE",13,10,13,10
defb "Press a key to start",0

end start