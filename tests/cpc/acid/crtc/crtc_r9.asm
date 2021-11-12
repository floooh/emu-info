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
halt
di
defs 64*3
defs 64-3-4-3-4-4-3-3-4-1-3

;; r9 doesn't seem to be latched.
;; around r1 it determines if ma is reloaded or not
;; around r0 it determines if go next line or not

;; type 3:
;; 68-64 inclusive (double up to 16 tall) (7->16)
;; 50-4c inclusive (one extra line) (16->7?) (greater or equal??)
;;
;; type 2:
;; 65-62 inclusive (double up to 16 tall) (38-42 ra=7) (r1)
;; 4e-4a shows all 31 (3d-00  ra=7) (r0)
;;
;; type 1:
;; 65-61 inclusive (double up)
;; 4e-4a shows all 31
;;
;; type 0:
;; 65-62 inclusive (double up)
;; 4e-4b shows all 31
;; 4a jumps up and down (almost like interlace)
;;
;; type 4: same as type 3
;;
jp_addr:
jp addrs
addre:
defs 64*3
addrs:


ld bc,&7f00
out (c),c
ld de,&544b
out (c),e
out (c),d
ld de,&070f
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
