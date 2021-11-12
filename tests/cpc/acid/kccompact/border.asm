org &4000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char
ld a,2
call scr_set_mode

di
ld hl,&c9fb
ld (&0038),hl
ei

loop:
ld b,&f5
l1:
in a,(c)
rra
jr nc,l1
halt
halt
halt
di
defs 32
ld b,&7f10
out (c),c
ld h,&40
ld l,&54

rept 16 
out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l
endm
ei

jp loop



display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test changes border colour during visible pixel area.",13,10
defb "On a KC compact this causes single line vertical dots at each change to show",13,10
defb "through."
defb "Needs more work to draw where the lines are",13,10
defb "Press a key to start",0

end start