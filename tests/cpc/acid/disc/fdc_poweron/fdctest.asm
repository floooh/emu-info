;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; This test checks fdc at power on

include "../../lib/testdef.asm"

org &1000

;; at power on floppy drive seeks to 0 on plus
start:
ld sp,&c000

ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c

ld bc,&7f01
out (c),c
ld bc,&7f43
out (c),c

ld bc,&df00
out (c),c

ld      bc,&f8ff
out     (c),c

ld      bc,&f782
out     (c),c

ld      bc,&f400			
out     (c),c

ld      bc,&f600			
out     (c),c

ld      bc,&ef7f
out     (c),c

ld bc,&7f00+%10001110
out (c),c

ld hl,copy_result_fn
ld (cr_functions),hl

call set_crtc

ld hl,&c9fb
ld (&0038),hl
im 1
ei

call write_text_init


ld a,1
ld (stop_each_test),a
call cls
ld hl,information
call output_msg
call wait_key

ld a,&40
ld (command_bits),a
xor a
ld (drive),a


call cls
ld ix,tests
call run_tests
jp do_restart

information:
defb "This is an automatic test which checks the configuration of the FDC",13
defb "after power on/off.",13,13
defb "1. Please insert a WRITE ENABLED disc that you are happy will be written",13
defb "into drive A",13
defb "2. Please turn the computer off, wait a few seconds and turn it back on again",13,13
defb "Please run on a 6128Plus.",13,13
defb "Tested on 6128Plus with C4CPC, SED9420, Zilog Z7065A and EME-157.",13,13
defb "If you are using a C4CPC, please copy the CPR into one of the",13
defb "slots and boot the computer without the menu.",13,13
defb "Press a key to continue",0

;; all pass 
tests:
DEFINE_TEST "fdc msr (power on)",msr_po
DEFINE_TEST "fdc data (power on)",data_po
DEFINE_TEST "sense interrupt status (ready during reset) (power on)",sis_po
DEFINE_TEST "sense drive status (ready, trk0) (EME-157) (power on)",sds_po
DEFINE_TEST "step rate time (power on)",srt_po
DEFINE_TEST "dma mode (using format) (power on)",dma_po
DEFINE_TEST "PCN (power on)",pcn_po
DEFINE_END_TEST

res_pcn_po:
defb 2,&c8,&00
defb 2,&ca,&00
defb 1,&80
defb 1,&80
defb &fe,&00

pcn_po:
ld ix,result_buffer

call start_drive_motor
call big_wait
call stop_drive_motor
call big_wait
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results

ld ix,result_buffer
ld hl,res_pcn_po
call copy_results
ld bc,10
ld ix,result_buffer
jp simple_results


res_sis_po:
defb 1,&80
defb 1,&80
defb 1,&80
defb 1,&80
defb &fe,&00

sis_po:
ld ix,result_buffer
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results

ld ix,result_buffer
ld hl,res_sis_po
call copy_results
ld bc,8
ld ix,result_buffer
jp simple_results

res_sds_po:
defb 1,%00000000
defb &fe,&00

sds_po:
ld ix,result_buffer
call sense_drive_status
call get_results

ld ix,result_buffer
ld hl,res_sds_po
call copy_results

ld bc,2
ld ix,result_buffer
jp simple_results

res_dma_po:
defw 0
defb 7
defb &40,&10,&00
defb &fe,&00


dma_po:
ld ix,result_buffer
call go_to_0

ld a,2
ld (format_n),a
ld a,def_format_gap
ld (format_gpl),a
ld a,def_format_filler
ld (format_filler),a

ld hl,sector_buffer
ld (hl),0
inc hl
ld (hl),0
inc hl
ld (hl),&c1
inc hl
ld (hl),2

ld a,1
ld (format_sc),a

call send_format

di
ld de,sector_buffer
call fdc_data_write_count
ei
ld (ix+0),e
inc ix
inc ix
ld (ix+0),d
inc ix
inc ix

call fdc_result_phase
call get_results

ld ix,result_buffer
ld hl,res_dma_po
call copy_results

call do_motor_off

ld bc,4
ld ix,result_buffer
jp simple_results


msr_po:
ld ix,result_buffer
;;ld bc,&fb7e
;;in a,(c)
ld a,(&bdfe)
ld (ix+0),a
inc ix
ld (ix+0),%10000000
inc ix
ld ix,result_buffer
ld bc,1
jp simple_results

data_po:
ld ix,result_buffer
;;ld bc,&fb7f
;;in a,(c)
ld a,(&bdff)
ld (ix+0),a
inc ix
ld (ix+0),%00000000
inc ix
ld ix,result_buffer
ld bc,1
jp simple_results

srt_po:
ld ix,result_buffer
call go_to_0

ld a,20
call send_seek
ld de,0
srt3:
halt
push de
call sense_interrupt_status
pop de
ld a,(fdc_result_data)
cp &80
jr nz,srt2
inc de
jr srt3

srt2:
ld (ix+0),e
ld (ix+1),&c6		;; sometimes c6
ld (ix+2),d
ld (ix+3),0
inc ix
inc ix
inc ix
inc ix
call do_motor_off

ld ix,result_buffer
ld bc,2
jp simple_results

include "../../lib/hw/cpc.asm"
include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
include "../../lib/output.asm"
include "../../lib/hw/fdc.asm"
;;include "../../lib/hw/crtc.asm"
include "../../lib/hw/readkeys.asm"
include "../../lib/hw/writetext.asm"
include "../../lib/hw/scr.asm"
include "../../lib/hw/printtext.asm"

include "../cpc.asm"

set_crtc:
;; set initial CRTC settings (screen dimensions etc)
ld hl,end_crtc_data
ld bc,&bc0f
crtc_loop:
out (c),c
dec hl
ld a,(hl)
inc b
out (c),a
dec b
dec c
jp p,crtc_loop
ret


crtc_data:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
end_crtc_data:


sysfont:
incbin "../../lib/hw/sysfont.bin"

include "../fdchelper.asm"

result_buffer equ $

end start