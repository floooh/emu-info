;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &4000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
scr_set_border equ &bc38
scr_set_ink equ &bc32

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,2
call scr_set_mode

xor a
ld b,13
ld c,b
call scr_set_ink

ld b,&1a
ld c,b
call scr_set_border

ld hl,vblank_msg
call display_msg

ld hl,&c000+(4*80)+(1*&800)
ld e,l
ld d,h
inc de
ld (hl),&ff
ld bc,80-1
ldir
ld hl,&c000+(4*80)+(2*&800)+32+7
ld (hl),&aa

ld hl,&c000+(7*80)+(4*&800)
ld e,l
ld d,h
inc de
ld (hl),&ff
ld bc,80-1
ldir

di
ld hl,&c9fb
ld (&0038),hl
ei


loop:
ld bc,&f700+%10010010
out (c),c

ld b,&f5
lo1:
in a,(c)
rra
jr nc,lo1
halt
halt
halt
ld bc,&f700+%10010000
out (c),c
ld b,&f5
ld a,%1
out (c),a
defs 64*8
ld a,0
out (c),a
jp loop

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


vblank_msg:
defb 31,1,1,&f2,&f2,&f2," VBLANK extends past the left border"

defb 31,1,2
defb &f1,&f1,"VBLANK starts below the solid line. VBLANK is black",&f1,&f1,13,10
defb "Exact pos marked with dotted pixels"

defb 31,42,11,"VBLANK extends past the right border",&f3,&f3,&f3

defb 31,1,9
defb &f0,&f0,"VBLANK ends above the solid line. VBLANK is black",&f0,&f0,13,10
defb "End is not visible. Assume HSYNC"
defb 0

message:
defb "This is a visual test.",13,10,13,10
defb "This test sets PPI port B to *OUTPUT* and then forces a",13,10
defb "VSYNC by outputting 1 to bit 0.",13,10,13,10
defb "The result is a stable screen and visible VBLANK.",13,10,13,10
defb "Works on : 6128, AMSTRAD40010 36AA, HD6845SP, NEC D8255AC-5.",13,10
defb "Z70290 board.",13,10,13,10
defb "Doesn't work on: 6128, AMSTRAD40010 36AA, UM6845, TOSHIBA",13,10
defb "TMP8255AP-5, Z70290 board",13,10
defb "6128,AMSTRAD40010 36AA, MC6845R, TOSHIBA TMP8255AP-5",13,10
defb "Z70210 board",13,10
defb 13,10,"Press a key to start",0


end start
