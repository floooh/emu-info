;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../../lib/testdef.asm"

org &8000

txt_output equ &bb5a

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

tests:
;;DEFINE_TEST "Kempston I/O decode (X)",kempston_X
;;DEFINE_TEST "Kempston I/O decode (Y)",kempston_Y
DEFINE_TEST "Kempston I/O decode (buttons)",kempston_buttons
DEFINE_END_TEST

kempston_buttons:

ld de,&0510
ld hl,&faef
ld bc,kemp_no_action
ld ix,kemp_button_io_decode_action
ld iy,kemp_no_action
jp io_decode

kemp_no_action:
ret

kemp_button_io_decode_action:
in a,(c)
cp %11111101
ret

kempston_X:
ld de,&0511
ld hl,&fbee
ld bc,kemp_no_action
ld ix,kemp_x_io_decode_action
ld iy,kemp_x_io_decode_init
jp io_decode

kemp_x_io_decode_init:
ld bc,&fbee
in a,(c)
ld (kemp_x),a
ret

kemp_x_io_decode_action:
push de
ld a,(kemp_x)
in e,(c)
cp e
pop de
ret

kemp_x:
defb 0

kempston_Y:
ld de,&0511
ld hl,&fbef
ld bc,kemp_no_action
ld ix,kemp_y_io_decode_action
ld iy,kemp_y_io_decode_init
jp io_decode

kemp_y_io_decode_init:
ld bc,&fbef
in a,(c)
ld (kemp_y),a
ret

kemp_y_io_decode_action:
push de
ld a,(kemp_y)
in e,(c)
cp e
pop de
ret

kemp_y:
defb 0


;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "../../lib/int.asm"
include "../../lib/hw/crtc.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/cpc.asm"


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is an interactive test.",13,10,13,10
defb "This test checks the port decoding for Kempston mouse.",13,10,13,10
defb "Disconnect all other hardware before running this test",13,10,13,10
defb "Please PRESS and HOLD the LEFT mouse button during the test.",13,10,13,10
defb "Press a key to start",0


result_buffer: equ $

end start
