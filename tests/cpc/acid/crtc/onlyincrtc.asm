;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This test uses IN instructions only to write to crtc.
;; Write to F5xx then do in.
;;
;; Works on CPC.
scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

org &4000

test:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,2
call scr_set_mode

ld bc,24*80
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
ld h,1
ld l,1
call &bb75
ld a,'A'
call &bb5a
ld a,'A'
call &bb5a



di
ld hl,&c9fb
ld (&0038),hl
ei

l1a:
ld b,&f5
l2a:
in a,(c)
rra
jr nc,l2a
halt
halt
halt
defs 32

ld bc,&bc01
out (c),c

ld bc,&f700+%10000000
out (c),c

ld hl,regs
ld d,&f6
exx 
ld bc,%1011010111111111
exx 

rept 9
;; read from HL write into F4xx
ld b,d
outi
exx
;; read from f4xx AND CRTC and set the register
in a,(c)
exx
defs 64-1-4-1-5-1
endm

ld bc,&bd00+40
out (c),c
ld bc,&f700+%10000010
out (c),c

jp l1a

regs:
defb 40
defb 39
defb 38
defb 37
defb 36
defb 35
defb 34
defb 33
defb 32


end test
