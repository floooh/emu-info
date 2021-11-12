;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38
km_wait_char equ &bb06


start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,2
call scr_set_mode

ld b,0
ld c,b
call scr_set_border

xor a
ld b,0
ld c,0
call scr_set_border

ld a,1
ld b,26
ld c,26
call scr_set_border

ld hl,&c000
ld e,l
ld d,h
inc de
ld bc,&3fff
ld (hl),&aa
ldir

;; now copy each pen into the screen
ld b,end_lines-lines
srl b
ld hl,lines
dl1:
push bc
ld e,(hl)
inc hl
ld d,(hl)
inc hl
push hl
ex de,hl
ld e,l
ld d,h
inc de
ld bc,80-1
ld (hl),&ff
ldir
pop hl
pop bc
djnz dl1

ld b,12
l3:
halt
djnz l3


di
ld hl,&c9fb
ld (&0038),hl
ei
loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
ld bc,&7f00+%10001110
out (c),c

ld bc,&7f10
out (c),c
ld bc,&7f46
out (c),c
halt
halt
di
ld d,20
l1a:
defs 64-1-3
dec d
jp nz,l1a
defs 64-2
;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f52
out (c),c

;; 0->1
ld h,%10001100
ld l,%10001101
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10

;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c

;; 1->0
ld h,%10001101
ld l,%10001100
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10





;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f52
out (c),c

;; 0->2
ld h,%10001100
ld l,%10001110
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10

;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c


;; 2->0
ld h,%10001110
ld l,%10001100
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10




;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f52
out (c),c

;; 0->3
ld h,%10001100
ld l,%10001111
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10




;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c


;; 3->0
ld h,%10001111
ld l,%10001100
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10




;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f52
out (c),c

;; 1->2
ld h,%10001101
ld l,%10001110
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10




;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c


;; 2->1
ld h,%10001110
ld l,%10001101
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10



;;-----------------------------------------------------------------------------------------------------

ld bc,&7f10
out (c),c
ld bc,&7f52
out (c),c


;; 1->3
ld h,%10001101
ld l,%10001111
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7
endm
out (c),h
out (c),l
defs 10




;;-----------------------------------------------------------------------------------------------------
ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c

;; 3->1
ld h,%10001111
ld l,%10001101
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10

;;-----------------------------------------------------------------------------------------------------
ld bc,&7f10
out (c),c
ld bc,&7f52
out (c),c

;; 2->3
ld h,%10001110
ld l,%10001111
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10

ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c

;; 3->2
ld h,%10001111
ld l,%10001110
defs 13
rept 15
out (c),h
out (c),l
call wait_64_7

endm
out (c),h
out (c),l
defs 10

;;-----------------------------------------------------------------------------------------------------
ld bc,&7f10
out (c),c
ld bc,&7f46
out (c),c
ld bc,&7f00+%10011110
out (c),c

ei

jp loop

wait_64_7:
defs 64-7-5-3
ret


lines:
defw &c000+(1*80)+(3*&800)
defw &c000+(2*80)+(0*&800)
defw &c000+(3*80)+(3*&800)
defw &c000+(4*80)+(0*&800)
defw &c000+(5*80)+(3*&800)
defw &c000+(6*80)+(0*&800)
defw &c000+(7*80)+(3*&800)
defw &c000+(8*80)+(0*&800)
defw &c000+(9*80)+(3*&800)
defw &c000+(10*80)+(0*&800)
defw &c000+(11*80)+(3*&800)
defw &c000+(12*80)+(0*&800)
defw &c000+(13*80)+(3*&800)
defw &c000+(14*80)+(0*&800)
defw &c000+(15*80)+(3*&800)
defw &c000+(16*80)+(0*&800)
defw &c000+(17*80)+(3*&800)
defw &c000+(18*80)+(0*&800)
defw &c000+(19*80)+(3*&800)
defw &c000+(20*80)+(0*&800)
defw &c000+(21*80)+(3*&800)
defw &c000+(22*80)+(0*&800)
defw &c000+(23*80)+(3*&800)
defw &c000+(24*80)+(0*&800)
end_lines:

display_msg:
ld a,(hl)
cp '$'
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test changes the mode to indicate the exact time when the ",13,10
defb "Gate-Array accepts and performs the change.",13,10,13,10
defb "The test changes rapidly from a mode to another and tests all mode combinations",13,10
defb "excluding two modes of the same number",13,10,13,10
defb "A solid line is drawn on the line before AND the line after where each mode",13,10
defb "takes effect. Between these lines the graphics should be different so you can",13,10
defb "see it is a different mode",13,10,13,10
defb "in order: 1->0, 0->1, 2->0, 0->2, 3->0, 0->3, 1->2, 2->1, 1->3",13,10
defb "3->1,2->3,3->2",13,10,13,10
defb "Press a key to start",'$'


end start
