;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;
include "../../lib/testdef.asm"

kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_l_rom_enable equ &b906
kl_l_rom_disable equ &b909
kl_rom_restore equ &b90c
kl_rom_select equ &b90f
txt_output equ &bb5a



org &8000
start:
ld a,2
call scr_set_mode
ld hl,intro_message
call display_msg
call &bb06

ld a,2
call &bc0e
ld ix,tests
call run_tests
call &bb06
ret

intro_message:
defb "Brunword MK2 tester (after reset,power on/off, soft reset)",13,10,13,10
defb "This is an automatic test",13,10,13,10
defb "Please test on *CPC* with Brunword Mk 2 expansion ONLY connected.",13,10,13,10
defb "Tested on a 6128 with Brunword mk2 connected",13,10,13,10
defb "Press any key to continue",13,10,13,10
defb 0


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

tests:
DEFINE_TEST "after reset, power on/off, soft reset",reset_test
DEFINE_END_TEST

reset_test:
ld ix,result_buffer

;; read current value
ld hl,&7000
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),0	;; initialised ram state (i.e. disabled)
inc ix

;;;; read actual state
;;di
;;ld bc,&df00+%01100000
;;out (c),c
;;ld a,(hl)
;;ld (ix+0),a
;;inc ix
;;ld bc,&df00+%01100100
;;out (c),c
;;ei
ld c,0
call kl_rom_select
call kl_u_rom_enable

ld ix,result_buffer
ld bc,1
jp simple_results

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
include "../../lib/hw/crtc.asm"
include "../../lib/portdec.asm"

result_buffer: equ $

end start
