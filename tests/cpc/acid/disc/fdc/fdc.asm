;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../../lib/testdef.asm"


kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f
txt_output equ &bb5a


org &4000

start:
;; TODO: need to ask if Plus to check for rom 7 decoding

call detect_fdc

call reset_specify
ml0:
call check_ready_display

ld a,(ready_status)
cp 2
jr nz,ml1
ld hl,disk_not_ready_msg
call output_msg
call wait_key
jr ml0

ml1:

ld a,2
call scr_set_mode
ld hl,intro_message
call output_msg
call wait_key

call detect_fdc
call choose_drive

call cls
ld ix,tests
jp run_tests

include "../../lib/hw/fdc.asm"

;;-----------------------------------------------------


intro_message:
defb "This test is an automatic test.",13,13
defb "This test checks the floppy disc controller port decoding.",13,13
defb "This can be run on a 6128, 6128Plus or a DDI-1",13,13
defb "This test requires a disc in drive A (the data may be destroyed)",13,13
defb "Press any key to start",13,13
defb 0

tests:
;;DEFINE_TEST "fb7e write decoding",fdc_fb7e_w
DEFINE_TEST "fa7e motor (write)",fdc_fa7e_w
DEFINE_TEST "fa7f motor (write)",fdc_fa7f_w
DEFINE_TEST "fa7e motor (read)",fdc_fa7e_r
DEFINE_TEST "fa7f motor (read)",fdc_fa7f_r
DEFINE_TEST "fdc msr i/o decode (fb7e)",fdc_msr_io_decode
DEFINE_TEST "amsdos rom select i/o decode (dfxx) (rom 7)",fdc_romsel_io_decode
;; fails on plus because it maps in two places

;; need to see if I can speed this up TOO SLOW
;;DEFINE_TEST "fa7e data i/o decode(long)",fdc_motor_io_decode
;;DEFINE_TEST "fa7e i/o decode (fa7e) (very very long)",fdc_motor_addr_io_decode

DEFINE_END_TEST

fdc_motor_addr_io_decode:
ld hl,&fa7e
ld de,&0581
ld bc,fdc_mt_addr_restore
ld ix,fdc_mt_addr_dec_test
ld iy,fdc_mt_addr_dec_init
jp io_decode

fdc_motor_io_decode:
ld ix,result_buffer
ld h,&01
ld l,&ff
ld de,&fa7e
ld bc,fdc_mt_data_restore
ld ix,fdc_mt_data_dec_test
ld iy,fdc_mt_data_dec_init
jp data_decode

fdc_mt_addr_dec_init:
fdc_mt_addr_restore:
fdc_mt_data_dec_init:
fdc_mt_data_restore:
xor a
ld bc,&fa7e
out (c),a
call wait_drive_motor
ret

fdc_mt_addr_dec_test:
ld a,1

fdc_mt_data_dec_test:
out (c),a
call wait_drive_motor
call sense_drive_status
ld a,(fdc_result_data)
and %00100000
cp %00100000
ret

fdc_fa7e_w:
call check_ready_ok
ret nz
ld ix,result_buffer
ld a,1
ld (ix+1),a
ld a,%00100000
ld (ix+3),a

call stop_drive_motor

ld a,1
ld bc,&fa7e
out (c),a
call wait_drive_motor

call sense_drive_status
call get_results
ld ix,result_buffer
ld a,(ix+2)	 ;; keep ready
and %00100000
ld (ix+2),a
ld bc,2
call simple_results
ret


fdc_fa7e_r:
call check_ready_ok
ret nz
ld ix,result_buffer
ld a,1
ld (ix+1),a
ld a,0
;;ld a,%00100000
ld (ix+3),a

call stop_drive_motor

ld bc,&fa7e
in a,(c)
call wait_drive_motor

call sense_drive_status
call get_results
ld ix,result_buffer
ld a,(ix+2)	 ;; keep ready
and %00100000
ld (ix+2),a
ld bc,2
call simple_results
ret


fdc_fa7f_r:
call check_ready_ok
ret nz
ld ix,result_buffer
ld a,1
ld (ix+1),a
;;ld a,%00100000
ld a,0
ld (ix+3),a

call stop_drive_motor

ld bc,&fa7f
in a,(c)
call wait_drive_motor

call sense_drive_status
call get_results
ld ix,result_buffer
ld a,(ix+2)	 ;; keep ready
and %00100000
ld (ix+2),a
ld bc,2
call simple_results
ret

fdc_fa7f_w:
call check_ready_ok
ret nz
ld ix,result_buffer
ld a,1
ld (ix+1),a
ld a,%00100000
ld (ix+3),a

call stop_drive_motor

ld a,1
ld bc,&fa7f
out (c),a
call wait_drive_motor

call sense_drive_status
call get_results
ld ix,result_buffer
ld a,(ix+2)	 ;; keep ready
and %00100000
ld (ix+2),a
ld bc,2
call simple_results
ret

;; FIX
fdc_fb7e_w:


call set_mfm

call start_drive_motor
call move2track0
ld a,39
call move2track

ld ix,result_buffer

ld a,39
ld (rw_c),a
ld a,2
ld (rw_n),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
xor a
ld (rw_h),a
ld a,&2a
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld hl,sector_buffer
ld e,l
ld d,h
inc de
ld (hl),&ff
ld bc,511
ldir

call send_write_data
di
ld de,sector_buffer
call fdc_data_write
ei
call fdc_result_phase
call get_results

ld hl,sector_buffer
ld bc,&200
ld d,0
ffw:
ld (hl),d
inc d
dec bc
ld a,b
or c
jr nz,ffw


;; write data
call send_write_data
di
ld de,sector_buffer
;; write using msr port.
;;call fdcnew_data_write
ei
call fdc_result_phase
call get_results

;; read back
call read_data
call get_results

ld hl,sector_buffer
ld bc,&200
ld d,0
ffw2:
ld a,(hl)
cp d
ld a,0
jr nz,ffw3
inc d
dec bc
ld a,b
or c
jr nz,ffw2
ld a,1
ffw3:
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

ld ix,result_buffer
ld bc,end_fb7e_w_results-fb7e_w_results
ld hl,fb7e_w_results
ffw3b:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,ffw3b

ld ix,result_buffer
ld bc,1+(8*3)
jp simple_results

fb7e_w_results:
defb 7,&40,&80,&00,&27,&00,&c1,&02
defb 7,&40,&80,&00,&27,&00,&c1,&02
defb 7,&40,&80,&00,&27,&00,&c1,&02
defb 0
end_fb7e_w_results:

;; before msr:
;; 0-6,5,8-d,4d, writeable in between 

;; 0-0d, 48,0f-31,4c,33-41,4c,43-51,4c, etc
data_reg_rw:
di
ld ix,result_buffer
ld bc,&fb7f
ld d,0
ld e,0
drrw:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
dec d
jr nz,drrw
ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


fdc_msr_io_decode:
ld hl,&fb7e
ld de,&0581
ld bc,fdc_addr_restore
ld ix,fdc_addr_dec_test
ld iy,fdc_addr_dec_init
jp io_decode

fdc_addr_restore:
jp restore_fdc

fdc_addr_dec_init:
ld bc,&fb7e
in a,(c)
ld (val_fb7e),a
ret

val_fb7e:
defb 0

fdc_addr_dec_test:
in a,(c)		
ld c,a
ld a,(val_fb7e)
cp c
ret

fdc_romsel_io_decode:
ld c,7
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (rom7_data),a

ld hl,&dfff
ld de,&2000
ld bc,fdc_romsel_restore
ld ix,fdc_romsel_dec_test
ld iy,fdc_romsel_dec_init
jp io_decode

fdc_romsel_restore:
jp restore_fdc

fdc_romsel_dec_init:
ret

rom7_data:
defb 0

fdc_romsel_dec_test:
push bc
ld a,7
out (c),a
ld bc,&7f00+%10000100
out (c),c
ld a,(&d000)
ld c,a
ld a,(rom7_data)
cp c
pop bc
ret


read_roms:
call kl_u_rom_enable
ld c,0
call kl_rom_select
di
ld hl,rom_data_buffer
ld b,&00
xor a
read_rom:
push bc
push af
ld bc,&df00
out (c),a

ld a,(&d000)
ld (hl),a
inc hl

pop af
inc a
pop bc
djnz read_rom
ld bc,&df00
out (c),c
call kl_u_rom_enable
ld c,0
call kl_rom_select
ei
ret

rom_data_buffer:
defs 256

;;-----------------------------------------------------
include "../cpc.asm"

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/crtc.asm"
include "../fdchelper.asm"

result_buffer equ $

end start
