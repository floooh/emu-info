;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
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

ld h,1
ld l,1
call &bb75
ld a,'A'
call &bb5a
ld a,'A'
call &bb5a

call write_text_init

di
ld hl,&c9fb
ld (&0038),hl
ei
ld bc,&bc06
out (c),c
ld bc,&bdff
out (c),c

ld bc,&bc05
out (c),c
ld bc,&bd07
out (c),c

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
;; halt
halt
di
defs 64*2
jp_addr:
jp addrs-&200
addre:
defs 64*42
addrs:

;; type 0: 7 lines. no change
;; type 1: same as r5b; keeps 7 lines all the time, at very end flickers and looses sync
;; type 2: seems to give 8 lines. 6c5-6c1 on rcc=r9 graphics go crazy because it can't set ma for main screen, 6ae-6aa goes up to 31 lines it seems

;; type 0: 6eb-6a7 flicker, 6a8 onwards ok. 7 lines (HCC=HDISP, RCC=R9, VCC=R4 -> HCC=R0, RCC=R9, VCC=R4)
;; (6eb=hdisp from one line to the next)
;; type 1: 6ae-6a9 flicker, 4ef-4ea (hcc=0, rcc=r9, vcc=r4)
;; type 2: 6ae-6a9 flicker, ok after, 7 lines, 4ee-4ea flicker
;; type 3: 6b0-6ac flicker, 670-66b flicker, 630-62b cut to 2 lines, 5f0-5eb 3 lines, 5b0-5ac 4 lines
;; 570-56b 5 lines,530-52c 6 lines,
;; type 4: same as type 3
ld bc,&7f00
out (c),c
ld de,&544b
out (c),e
out (c),d
;;ld de,0+(0*256)+7
ld de,0+(7*256)+0
ld bc,&bc05
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
