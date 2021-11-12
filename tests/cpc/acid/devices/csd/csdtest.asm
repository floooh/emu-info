
include "lib/testdef.asm"

;; CSD tester
org &0000

start:
di

im 1

call init_crtc

call cls
call write_text_init

ld ix,tests
call run_tests



ld bc,&7f10
out (c),c
ld a,0
loop:
inc a
and &1f
or &40
out (c),a
defs 64-1-2-2-4
jp loop


;;--------------------------------------------------------
init_crtc:
ld hl,crtc_regs
ld c,&0f
ld de,&bcbe
ic1:
;; select register
ld b,d
out (c),c
ld b,e
outd
jp po,ic1
ret

;;--------------------------------------------------------
;; crtc regs in reverse order
crtc_regs:
defb &00 ;; R15
defb &c0 ;; R14
defb &00 ;; R13
defb &30 ;; R12
defb &00 ;; R11
defb &00 ;; R10
defb &07  ;; R9
defb &00 ;; R8
defb &1e ;; R7
defb &19 ;; R6
defb &00 ;; R5
defb &26 ;; R4
defb &0e ;; R3
defb &2e ;; R2
defb &28 ;; R1
defb &3f  ;; R0


;;-----------------------------------------------------

tests:
DEFINE_TEST "CSD port fbe0 r test", fbe0_r_test
DEFINE_TEST "CSD port fbe1 r test", fbe1_r_test
DEFINE_TEST "CSD port fbe2 r test", fbe2_r_test
DEFINE_TEST "CSD port fbe3 r test", fbe3_r_test

DEFINE_TEST "CSD port fbe0 r/w test", fbe0_rw_test
DEFINE_TEST "CSD port fbe1 r/w test", fbe1_rw_test
DEFINE_TEST "CSD port fbe2 r/w test", fbe2_rw_test
DEFINE_TEST "CSD port fbe3 r/w test", fbe3_rw_test
DEFINE_END_TEST


fbe0_r_test:
ld bc,&fbe0
jr csd_port_r_test

;;-----------------------------------------------------
fbe1_r_test:
ld bc,&fbe1
jr csd_port_r_test

;;-----------------------------------------------------
fbe2_r_test:
ld bc,&fbe2
jr csd_port_r_test

;;-----------------------------------------------------
fbe3_r_test:
ld bc,&fbe3
jr csd_port_r_test


fbe0_rw_test:
ld bc,&fbe0
jr csd_port_rw_test

;;-----------------------------------------------------
fbe1_rw_test:
ld bc,&fbe1
jr csd_port_rw_test

;;-----------------------------------------------------
fbe2_rw_test:
ld bc,&fbe2
jr port_rw_test

;;-----------------------------------------------------
fbe3_rw_test:
ld bc,&fbe3
jr port_rw_test

csd_port_r_test:
di
ld ix,result_buffer
ld de,512
call port_r_test

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


csd_port_rw_test:
di
ld ix,result_buffer
ld e,&ff
call port_rw_test

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

;;-----------------------------------------------------

include "lib/mem.asm"
include "lib/report.asm"
include "lib/test.asm"
include "lib/outputmsg.asm"
include "lib/outputhex.asm"
include "lib/output.asm"
include "lib/hw/psg.asm"
include "lib/hw/writetxt2.asm"
include "lib/hw/scr.asm"
include "lib/hw/keyfn.asm"
include "lib/hw/readkeys.asm"
include "lib/hw/printtext.asm"

font_data:
incbin "lib/hw/sysfont.bin"

;; in ram!
result_buffer: equ &8000

end start
