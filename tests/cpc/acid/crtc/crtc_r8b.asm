;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; changing R8 to 3 and 0 mid frame
org &4000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
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


call write_text_init

di
ld hl,&c9fb
ld (&0038),hl
ei
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
halt
halt
halt
halt
halt
halt
loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
halt
di

jp_addr:
jp addrs-&100
addre:
defs 64*16
addrs:

;; type 0: 2ed-2ea jump up and down, 2e9 repeats same line 5 times, 2c5-2c1 jump
;; up and down with ma, 2ae-2a9 jumps up and down, 2aa interlace (whole char line flickers
;; at bottom and it works on the entire screen above and below), 2a9 causes 1 scanline line to flicker,
;; 26d-269 1 scanline flicker, 22d-229 1 scanline flicker, 1ed-1e9 (jumps a bit like it's lost
;; some scanlines), 1af-1a9 1 scanline flicker, 16d-169  (a bit more happens),
;; c5-c2 ma flicker
;;
;; check flicker and which line is repeated.
;;
;; 2e9 flickers a single line and repeats the char line 4 more times
;; 26a, 269 etc repeats - line
;; 22d makes comma into semicolon and dot into colon
;; 1ac seems to show scan 0 again
;; 16d seems to be line 4? on } it shows middle pixel, shows a bit of quotes
;; and final pixel , of apostraphy and middle line of +
;; 12d is showing part of - on =
;; 
;; is immediate?

;; type  1:2ee-2eb double up lines, 2ea whole screen jumps a lot, 2eb-2c5 it's like interlace
;; switching between odd and even (only remainder of screen), 2c5-2c2 interlace + flicker
;; like ma is changing,  2c1 interlace, 2c0-2af jumping, 2ae no interlace, 2ad-2ab interlace 
;; 1 less line, 2aa jumping a lot, 2a9-26e nothing, 26f-26a loose 1 scanline, 269-22f interlace
;; 22f, 22e-22a loose another line, 229-1ef nothing..  this all repeats.. until 105-101 where 
;; ma makes line move up, 
;;
;; all char lines effectively remain at 8 lines tall
;; interlace happens until vsync
;;
;; interlace triggers immediate but lasts rest of frame
;; 2e8 seems to do line 6
;; 15b seems to do top of dot on/off.
;; seems to be every odd/even line that flickers
;; e0 seems to do line 6 on/off, every odd I think
;;
;; type 2: immediate on and off. doesn't effect whole frame.
;; flickers on/off and is adding what looks like 4 scanlines (- before -./ gets repeated a few lines above)
;; (middle of - shows first of .), 1c6-1c1 splits current line and shows another line below
;; it's comparing against 4 I think. (1c6-1c1: HC=HDISP, RC=(R9>>1), (rc<<1)|frame for scan line)
;; scanline incremented normally.
;; 
;; 2e4 seems to do line 6.
;; 290 seems to do line 1.
;; 25d repeats - 
;; 21d turns comma into semicolon and repeats first line of .
;; 1dd turns comma into semicolon and repeats 2nd line of . and removes -
;; when it cuts, line counter remains the same, rc remains the same.
;; it shows lower 4 lines of next char line. screen height doesn't change
;; all below moves up by 1 char line (not rc comparison)
;; 
;; type 3: 2f0-2ec 1 scanline (0)
;; 270-26c loose 1 scanline
;; 231-22b loose 1 scanline
;; continues
;; where rc=r9 no lose of scanline, instead it shows scanline 0
;; 
;; type 4: same as type 3
ld bc,&7f00
out (c),c
ld de,&544b
out (c),e
out (c),d
ld de,0+(0*256)+3
ld bc,&bc08
out (c),c
inc b
out (c),e
nop
out (c),d
ei
call readkeys
call do_dir

jp loop

do_dir:
ld ix,matrix_buffer
ld a,(ix+9)
xor (ix+9+16)
ret z

ld a,(ix+9)
bit 0,a
call nz,do_down
bit 1,a
call nz,do_up
ret

do_down:
ld hl,(jp_addr+1)
or a
ld bc,addre
sbc hl,bc
ret z

ld hl,(jp_addr+1)
dec hl
ld (jp_addr+1),hl
jr update

do_up:
ld hl,(jp_addr+1)
or a
ld bc,addrs
sbc hl,bc
ret z

ld hl,(jp_addr+1)
inc hl
ld (jp_addr+1),hl
jr update

update:
ld h,1
ld l,10
call set_char_coords
ld hl,(jp_addr+1)
or a
ld bc,addre
sbc hl,bc
call outputhex16
ret


include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
include "../lib/int.asm"
;; hardware based output

include "../lib/hw/asic.asm"
include "../lib/hw/readkeys.asm"
include "../lib/hw/writetext.asm"
include "../lib/hw/scr.asm"
include "../lib/hw/printtext.asm"

crtc_data:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
end_crtc_data:

sysfont:
incbin "../lib/hw/sysfont.bin"


end start
