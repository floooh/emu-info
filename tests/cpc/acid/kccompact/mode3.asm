org &4000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
txt_set_pen equ &bb90

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

xor a
call scr_set_mode

ld d,'A'
ld b,25
l2:
ld c,40
l1:
push af
ld a,(pen)
inc a
and &f
ld (pen),a
call txt_set_pen
pop af

ld a,d
call txt_output
dec c
jr nz,l1
inc d
dec b
jr nz,l2

di
ld hl,&c9fb
ld (&0038),hl
ei

loop:
ld b,&f5
l1b:
in a,(c)
rra
jr nc,l1b
halt
halt
halt
di
ld b,&7f
ld h,%10001100
ld l,%10001111

rept 200
out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h
out (c),l

out (c),h

defs 64-35
endm
ei

jp loop

pen:
defb 0

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test changes between mode 0 and mode 3.",13,10
defb "On a KC compact mode 3 causes the pixel clock to ",13,10
defb "stop and the last pixel output to repeat. Bars of colour are seen where mode 3 is active)",13,10,13,10
defb "Needs more work on this test"
defb "Press a key to start",0

end start