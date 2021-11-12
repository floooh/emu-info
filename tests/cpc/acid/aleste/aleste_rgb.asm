;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; flash aleste 520ex caps led


org &8000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,1
call scr_set_mode

di
ld hl,&c9fb
ld (&0038),hl
ei

;; enable map mod; disable blacks
ld a,%00001100
ld bc,&fabf
out (c),a

l1:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2

halt

halt
di

ld bc,&7f00
out (c),c
ld bc,&7f00+%01000000
out (c),c
call delay
ld bc,&7f00+%01010000
out (c),c
call delay
ld bc,&7f00+%01100000
out (c),c
call delay
ld bc,&7f00+%01110000
out (c),c
call delay
ld bc,&7f00+%01000000
out (c),c
call delay

ld bc,&7f00+%01000000
out (c),c
call delay
ld bc,&7f00+%01000100
out (c),c
call delay
ld bc,&7f00+%01001000
out (c),c
call delay
ld bc,&7f00+%01001100
out (c),c
call delay
ld bc,&7f00+%01000000
out (c),c
call delay

ld bc,&7f00+%01000000
out (c),c
call delay
ld bc,&7f00+%01000001
out (c),c
call delay
ld bc,&7f00+%01000010
out (c),c
call delay
ld bc,&7f00+%01000011
out (c),c
call delay
ld bc,&7f00+%01000000
out (c),c
call delay

jp l1

delay:
defs 64*4
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
defb "This test sets MAPMOD and then shows bars of R then G then B",13,10
defb "using the aleste 64-colour mode",13,10,13,10
defb "MAPMOD is bit 2 of port fabf.",13,10,13,10
defb "THIS TEST NEEDS CONFIRMING ON A REAL ALESTE",13,10,13,10
defb "Press a key to start",0

end start