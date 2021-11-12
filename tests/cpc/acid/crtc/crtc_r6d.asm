;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; change R6=0 and back to 25 on char line 0.
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
loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
di
defs 64*12
jp_addr:
jp addrs-&200
addre:
defs 64*24
addrs:

;; type 0,1,2 don't seem to do anything when you move them past the start of the display

;; type 0: same as type 2

;; type 1: on char line 0 it works immediate (like r6c test) border change extends for remainder of frame.
;; 4ae is first. 
;; on char line 1, it shows a small part of border (length of OUT - like using r8) it doesn't extend.
;;
;; type 2: on char line 0, scan line 0, shows a small part of border (length of OUT like using R8 to show border), it is also
;; dotted, gfx and border, The rest of the frame has graphics.
;; dotted has border at 0, then gfx at 1, then border at 2 then gfx. 5 bits of border.
;;
;; On scan line 1 and above, then change is immediate and for the entire frame. On char line 1, no effect.
;;
;; type 3: 4ac-4b0
;;
;; type 4: same as type 3
ld bc,&7f00
out (c),c
ld de,&544b
out (c),e
out (c),d
ld de,0+(255*256)+0
ld bc,&bc06
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
