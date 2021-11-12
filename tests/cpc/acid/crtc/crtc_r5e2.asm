;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; change r4 during r5
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

ld hl,&c000
ld e,l
ld d,h
ld (hl),&ff
inc de
ld bc,79
ldir

ld hl,&c000+(6*80)+(7*&800)
ld e,l
ld d,h
ld (hl),&ff
inc de
ld bc,79
ldir

call write_text_init
di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+76-1
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+60
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+3
out (c),c

ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c

loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
;;halt
di
defs 64*3
jp_addr:
jp addrs-&300
addre:
defs 64*24
addrs:

;; type 0: 4ae-4a7 flicker screen distorted. 485-480 (all lines space !" etc),
;; 46e-46a all space !" etc, 406-401 all "# etc, (400-3ff etc all 1234 etc).
;; 385-380 all space !, 
;; 
;; type 1:305-301 ma update, 2ff-2f9?, 285-281 repeat, 26f- 269all "# etc like 31 lines (
;; does as expected with r9 respected.
;; type 2: about the same as type 1
;;
;; type 4: same as type 3. nothing
ld bc,&7f00
out (c),c
ld de,&544b
out (c),e
out (c),d
ld de,0+(3*256)+1
ld bc,&bc09
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
ld l,1
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
