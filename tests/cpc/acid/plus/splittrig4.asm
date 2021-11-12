;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

;; screen shows same line repeated
;; split happens in this range:
;; 35a-352
;; and covers the remainder of the screen

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,26
ld c,b
call scr_set_border

;; set the screen mode
ld a,2
call scr_set_mode

ld h,1
ld l,1
call &bb75

ld bc,24*80
ld d,'-'
l1:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1

ld h,1
ld l,1
call &bb75

ld b,24
ld a,'A'
l1a:
push bc
push af
call &bb5a
ld a,10
call &bb5a
ld a,13
call &bb5a
pop af
pop bc
inc a
djnz l1a

ld hl,&c000
ld de,&4000
ld bc,&4000
ldir
ld hl,&4000
ld bc,&4000
l1b:
ld a,(hl)
cpl
ld (hl),a
inc hl
dec bc
ld a,b
or c
jr nz,l1b

call asic_enable
ld bc,&7fb8
out (c),c


call write_text_init

ld bc,&bc0c
out (c),c
ld bc,&bd00+&30
out (c),c
ld bc,&bc0d
out (c),c
ld bc,&bd00+0
out (c),c
ld bc,&bc01
out (c),c
ld bc,&bd00+&ff
out (c),c

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

ld bc,&bc07
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+18
out (c),c
ld h,&00
ld l,&18
ld (&6802),hl
ld a,148
ld (&6800),a
ld a,151
halt
jp_addr:
jp addrs
addre:
defs 64*16
addrs:

ld bc,&7f00
out (c),c
ld de,&544b
out (c),e
out (c),d
ld (&6801),a
defs 4
xor a
ld (&6801),a


ld a,15
ld (&6800),a
halt
ld bc,&bc04
out (c),c
ld bc,&bd00+19
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
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
