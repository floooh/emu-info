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
DEFINE_TEST "Multiplay I/O decode (buttons)",multiplay_buttons
DEFINE_END_TEST

multiplay_buttons:
ld de,&feff
ld hl,&f990
ld bc,multp_no_action
ld ix,multp_button_io_decode_action
ld iy,multp_no_action
jp io_decode

multp_no_action:
ret

multp_button_io_decode_action:
in a,(c)
cp %10000
ret


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
defb "This test checks the port decoding for Multiplay.",13,10,13,10
defb "Disconnect all other hardware before running this test",13,10,13,10
defb "Please PRESS and HOLD FIRE1 on multiplay joystick A during the test.",13,10,13,10
defb "Press a key to start",0


result_buffer: equ $

end start
