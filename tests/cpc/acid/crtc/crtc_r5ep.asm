;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; scroll operates during vertical adjust.
;; no scroll has 3 lines of ^_ etc
;; max scroll has 4 lines of ^_ etc

org &8000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
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

call asic_enable
ld bc,&7fb8
out (c),c


di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c

;;ld bc,&bc04
;;out (c),c
;;ld bc,&bd00+76-1
;;out (c),c

;;ld bc,&bc07
;;out (c),c
;;ld bc,&bd00+60
;;out (c),c

;;ld bc,&bc09
;;out (c),c
;;ld bc,&bd00+3
;;out (c),c

ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c



ld a,50
ld (delay),a
xor a
ld (scrl),a

loop:
ld b,&f5
l3:
in a,(c)
rra
jr nc,l3

ld a,(scrl)
and &7
add a,a
add a,a
add a,a
add a,a
ld (&6804),a

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
ld a,(scrl)
or a
ret z

ld a,(scrl)
dec a
ld (scrl),a
jr update

do_up:
ld a,(scrl)
cp 7
ret z

ld a,(scrl)
inc a
ld (scrl),a
jr update

update:
ld h,1
ld l,10
call set_char_coords
ld a,(scrl)
call outputhex8
ret

scrl:
defb 7
delay:
defb 0



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
