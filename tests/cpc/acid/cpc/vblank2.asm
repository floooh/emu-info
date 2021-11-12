;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000
nolist

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

ld a,2
call scr_set_mode

ld b,3
ld c,3
call &bc38

xor a
ld b,5
ld c,5
call &bc32


ld a,1
ld b,13
ld c,13
call &bc32

ld b,6*3
l2:
halt
djnz l2

di
ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld b,&f5
loop2a:
in a,(c)
rra
jr nc,loop2a
loop2b:
in a,(c)
rra
jr nc,loop2b

loop: 
ld b,&f5
loop2:
in a,(c)
rra
jr nc,loop2

ld bc,&bc07
out (c),c
ld bc,&bd00+2
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd0e
out (c),c
call wait

ld bc,&bc07
out (c),c
ld bc,&bd00+3
out (c),c

call wait
ld bc,&bc03
out (c),c
ld bc,&bd2e
out (c),c
call wait
ld bc,&bc03
out (c),c
ld bc,&bd3e
out (c),c
call wait
ld bc,&bc03
out (c),c
ld bc,&bd4e
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c
jp loop

wait:
ld de,2048
w1:
dec de	;; [2]
nop ;; [1]
ld a,d	;; [1]
or e	;; [1]
jp nz,w1	;; [3]
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
defb "This test sets each vsync height. This test must be run on a type 0, 3 or",13,10
defb "4 because these are the only CRTC that allows vsync height to be programmed",13,10,13,10
defb "Press a key to start",0

end start