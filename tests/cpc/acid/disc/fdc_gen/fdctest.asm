;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.


include "../../lib/testdef.asm"

if CPC=1
org &1000
endif
if SPEC=1
org &8000
endif

;;narrow format gaps, try eot stuff, and time to next sector

;;time for data ready to be active between each command byte and each result byte

;;check format timing

;;check read data/write data timing

;;head load/unload

;; read deleted data write to sectors and check bytes read back

;;read data skip and multitrack
;;read data skip start,end,all
;;read data skip missing


;;- read id often will stop head unload?

;;- perhaps seek or other?

;;- format and check seek step rate

;;- do various delay before doing seek to see if that odd step rate problem hits.

;;- check timing for writing to data reg (need 8272 to check)

 

;;- update ppi control test for various 8255.

;;- fix ready timing test

;;- read data and read data dma check when bits go on off for data and execution phase etc.

;;- time head unload (wait a long time to make sure it really does unload and load).

;; read deleted data write to sectors and check bytes read


;;read data eot interrupt in middle of sector(overrun)
;;read data eot interrupt between sectors (o)
;;read data skip and multitrack
;;read data skip start,end,all
;;read data skip missing
;;Test to write/format side 1 and see result. (single sided)
;;
;; Format bdos and fat for hd in Arnold.
;;Test to read side 1 and see result (single sided)

;;read data eot interrupt in middle of sector(overrun)
;;read data eot interrupt between sectors (o)
;;read data skip and multitrack
;;read data skip start,end,all
;;read data skip missing
;;Test to write/format side 1 and see result. (single sided)
;;
;; Format bdos and fat for hd in Arnold.
;;Test to read side 1 and see result (single sided)
;; FDC status bits for all phases

start:
;;---------------------------------------------------------------------------
;; Tested in these tests:
;; - Sense interrupt status
;; - Sense drive status (excluding write protect)
;; - read id
;;
;; See other tests for read, read track, format, write etc
;; See other tests for recalibrate and seek
main_loop:
if SPEC=1
call init
call write_text_init
;;ld h,32
;;ld l,24
;;call set_dimensions
endif
if CPC=1
ld a,2
call &bc0e
endif

ld hl,copy_result_fn
ld (cr_functions),hl

call detect_fdc

call reset_specify

;;ld a,1
;;ld (stop_each_test),a
call cls
ld hl,information
call output_msg
call output_nl
call wait_key

call choose_fdc
call choose_dack

call choose_drive_cfg
call choose_multi_drive
call choose_drive
call choose_drive_type

call cls
ld hl,drive_testing_msg
call output_msg


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
call is_write_protected
jr z,ml2
ld hl,disk_write_protected_msg
call output_msg
call wait_key
jr ml1
ml2:
call check_drv
call check_seek


ld hl,drive_testing_done_msg
call output_msg
call wait_key

call cls
ld hl,initialising_test_msg
call output_msg

call format_test_disk
call dd_test_disk

ld hl,initialising_test_done_msg
call output_msg
call wait_key

ld a,&40
ld (command_bits),a



call cls
ld ix,tests
call run_tests
rst 0


;;-----------------------------------------------------

dd_test_disk:
ld hl,dd_test_disk_data
jp do_dd_test_disk

format_test_disk:
ld hl,test_disk_format_data
jp do_format_test_disk

drive_testing_msg:
defb "Testing drive...",13,0
drive_testing_done_msg:
defb "Testing drive... DONE",13
defb "Press a key to continue",0

initialising_test_msg:
defb "Initialising tests...",13,0
initialising_test_done_msg:
defb "Initialising tests... DONE",13
defb "Press a key to continue",0

information:
defb "This test has been run on a real computer with a real drive.",13,13
defb "Requirements:",13
defb "- Real drive (not HXC or Gotek)",13
defb "- disc is writeable (NOT write protected)",13
defb "- Make sure all other expansions are disconnected",13
defb 0


tests:
DEFINE_TEST "ready change during command",rc_command
DEFINE_TEST "ready change during result",rc_result
DEFINE_TEST "ready change, sense interrupt status, ready change, sense interrupt status (drive 0 best)",rc_sense
DEFINE_TEST "sense drive status (execution phase)",sds_exec
DEFINE_TEST "sense interrupt status (no interrupts) (execution phase)",sis_exec
DEFINE_TEST "read id (execution phase)",read_id_exec
DEFINE_TEST "invalid (execution phase)",invalid_exec

DEFINE_TEST "sense clears fdd busy (only after seek)",seek_busy_sense

DEFINE_TEST "clear ready change",ready_change
DEFINE_TEST "sense drive status (2 drives)",sense2_drive_status
DEFINE_TEST "version",version
DEFINE_TEST "invalid (all)",invalid
;;DEFINE_TEST "read id (formatted unformatted)",read_id_unform	
DEFINE_TEST "read id not ready",read_id_nr	
;;DEFINE_TEST "read id (formatted unformatted) (2)",read2_id_unform	

;; TEST
;;DEFINE_TEST "read id fm on fm",read_id_fm
;; TEST
;;DEFINE_TEST "read id mfm on fm",read_id_mfm_fm
;; TEST
;;DEFINE_TEST "read id fm on mfm",read_id_fm_mfm

;; TEST
;;DEFINE_TEST "read id fm on fm (2)",read2_id_fm
;; TEST
;;DEFINE_TEST "read id mfm on fm (2)",read2_id_mfm_fm
;; TEST
;;DEFINE_TEST "read id fm on mfm (2)",read2_id_fm_mfm

;; TEST
DEFINE_TEST "read id multi-track (side 1) (ds)",read_id_side1_mt
;; TEST
DEFINE_TEST "read id multi-track",read_id_mt
;; TEST

DEFINE_TEST "motor on (wait), sense int, motor off (wait), sense int",sense_intr_motor




;; doesn't see index pulse again and hangs
;; hang - TEST TEST TEST
;;DEFINE_TEST "read id ready change",read_id_rc


DEFINE_TEST "read id",read_id_only
DEFINE_TEST "read id (delay then read)",read_id_delay
DEFINE_TEST "read id (side 1) (ds)",read_id_side1
DEFINE_TEST "read id (side 1) (ss)",read_id_ss_side1
DEFINE_TEST "read id data error",read_id_de			
DEFINE_TEST "read id (wrong cylinder)",read_id_wc
DEFINE_TEST "read id (bad cylinder)",read_id_bc
DEFINE_TEST "read id skip",read_id_sk
DEFINE_TEST "read id (overrun)",read_id_ov

;DEFINE_TEST "sense clears fdd busy (try during seek)",sense_clear_fdd_busy

DEFINE_TEST "fdd busy (seek then read id)",fdd_busy
DEFINE_TEST "drive status (side1) (ds)",drive_side1_status
DEFINE_TEST "drive status (side1) (ss)",drive_side1_ss_status
DEFINE_TEST "drive status (ready)",drive_ready_status
DEFINE_TEST "drive status (track 0)",drive_trk0_status
DEFINE_TEST "drive status (other command bits)",drive_cmd_status
DEFINE_TEST "sense interrupt (other command bits)",sense_cmd_status
DEFINE_TEST "sense interrupt status",sense_intr_no_int

DEFINE_TEST "read id dma mode",read_id_dma	
DEFINE_TEST "read id dma mode (execution phase)",read_id_dma_exec
DEFINE_TEST "drive status (dma mode)",drive_status_dma


DEFINE_END_TEST

did_exec_happen:
ld d,0
deh1:
call fdc_read_main_status_register
bit 5,a
jr z,deh2
ld d,1
jr deh3
deh2:
and %11010000
cp %11010000
jr nz,deh1
deh3:
ld (ix+0),d
inc ix
inc ix
ret


res_sds_exec:
defb &0
defb &fe,&00

sds_exec:
ld hl,res_sds_exec
ld a,%100						;; sense drive status
call send_command_byte	
ld a,(drive)
call send_command_byte
jr do_exec

res_invalid_exec:
defb &0
defb &fe,&00

invalid_exec:
ld hl,res_invalid_exec
ld a,%10000
call send_command_byte
jr do_exec

res_sis_exec:
defb &0
defb &fe,&00

sis_exec:
call clear_fdd_interrupts

ld hl,res_sis_exec
ld a,%1000						;; sense interrupt status
call send_command_byte	
jr do_exec


do_exec:
push hl
ld ix,result_buffer

call did_exec_happen
call fdc_result_phase

ld ix,result_buffer
pop hl
call copy_results

ld bc,1
jp do_results

res_read_id_exec:
defb &1
defb &fe,&00

read_id_exec:
call go_to_0
call send_read_id
ld hl,res_read_id_exec
jp do_exec

res_read_id_dma_exec:
defb &1
defb &fe,&00

read_id_dma_exec:
call go_to_0
call set_dma_mode
call send_read_id
ld hl,res_read_id_dma_exec
jp do_exec

rc_read_command:
defb &46
defb &0
defb &0
defb &0
defb &41
defb &2
defb &41
defb &2a
defb &ff
end_rc_read_command:

send_rc_command:
ld e,end_rc_read_command-rc_read_command
ld hl,rc_read_command
src1:
ld a,(hl)
inc hl
call send_command_byte
dec e
dec d
jr nz,src1
ld a,e
or a
jr z,src3
push hl
push de
call stop_drive_motor
pop de
pop hl
src2:
ld a,(hl)
inc hl
call send_command_byte
dec e
jr nz,src2
src3:
call common_read_data
call get_results

jp sis_with_results

sis_with_results:
call sense_interrupt_status
jp get_results

res_rc_command:
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&48,&00,&00,&00,&00,&41,&2
defb &01,&80
defb &fe,&00

rc_command:
call check_ready_ok
ret nz

call go_to_0

ld ix,result_buffer
ld e,end_rc_read_command-rc_read_command-1
ld d,1
rrc1:
push de
push de
ld a,e
call outputdec
ld a,' '
call output_char

call do_motor_on
pop de
call send_rc_command
pop de
inc d
dec e
jr nz,rrc1


ld ix,result_buffer
ld hl,res_rc_command
call copy_results

ld bc,10*(end_rc_read_command-rc_read_command)
jp do_results


read_rc_result:
ld e,7
rrc11:
call fdc_read_result_byte
ld (ix+0),a
inc ix
inc ix
dec e
dec d
jr nz,rrc11
ld a,e
or a
jr z,rrc33
push hl
push de
call stop_drive_motor
pop de
pop hl
rrc22:
call fdc_read_result_byte
ld (ix+0),a
inc ix
inc ix
dec e
jr nz,rrc22
rrc33:
jp sis_with_results

res_rc_result:
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,&2
defb &01,&80
defb &fe,&00


rc_result:
call check_ready_ok
ret nz

call go_to_0

ld ix,result_buffer
ld d,1
ld e,7
rrc3:
push de
push de
ld a,e
call outputdec
ld a,' '
call output_char

call do_motor_on
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
call send_read_data
di
call fdc_read_data_count
ei
pop de
call read_rc_result
pop de
inc d
dec e
jr nz,rrc3

ld ix,result_buffer
ld hl,res_rc_result
call copy_results

ld bc,12*8
jp do_results

res_rc_sense:
defb &fe,&00

rc_sense:
call check_ready_ok
ret nz

ld ix,result_buffer

call go_to_0

;; ready change
call do_motor_on
call stop_drive_motor

;; sense that change
call sis_with_results
;; repeat again
call do_motor_on
call stop_drive_motor

;; see what got
call sense_interrupt_status
call sense_interrupt_status
call sense_interrupt_status
call sense_interrupt_status

ld ix,result_buffer
ld hl,res_rc_sense
call copy_results

ld bc,12
jp do_results


res_ready_change:
defb &02,&20,&fe,&01,&27
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &fe,&00

;; what is this doing?
ready_change:
call check_ready_ok
ret nz

call go_to_0

call do_motor_off
call stop_drive_motor

call clear_fdd_interrupts

call do_motor_on

ld ix,result_buffer

ld a,39
call send_seek
call wait_fdd_interrupt
call get_results
call sis_with_results
call sis_with_results
call sis_with_results

call go_to_0
call do_motor_off

call clear_fdd_interrupts

call do_motor_on

call read_id

call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results
call do_motor_off

call clear_fdd_interrupts

call do_motor_on

ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
call read_data

call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results

ld ix,result_buffer
ld hl,res_ready_change
call copy_results

ld bc,12*2
jp do_results

res_seek_busy_sense:
defb &00,&fe,&03
defb 2,&20,&fe,&01,&02
defb 0
defb &fe,&00

seek_busy_sense:
call go_to_0

ld ix,result_buffer

di
ld a,2
call send_seek

call big_wait

call get_drive_busy_mask
ld e,a

call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
inc ix

push de
call sis_with_results
pop de

call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
inc ix
ei

ld ix,result_buffer
ld hl,res_seek_busy_sense
call copy_results

ld bc,5
jp do_results

res_drive2_drive_status:
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&10,&fe,&02
defb &01,&12,&fe,&02
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&80
defb &01,&30,&fe,&02
defb &01,&32,&fe,&02
defb &fe,&00

sense2_drive_status:
call check_two_drives
ret nz
call check_ready_ok
ret nz

ld ix,result_buffer
call clear_fdd_interrupts

call do_motor_off

call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results
call sense_drive_status
call get_results
call swap_same_drive

call sense_drive_status
call get_results
call swap_same_drive

call do_motor_on

call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results
call sense_drive_status
call get_results
call swap_same_drive

call sense_drive_status
call get_results
call swap_same_drive


ld ix,result_buffer
ld hl,res_drive2_drive_status
call copy_results

ld bc,12*2
jp do_results

specify_srt:
ld ix,result_buffer

ld b,16
ld c,0
srt1:
push bc

push bc
push bc
call reset_specify

call go_to_0
pop bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc
ld a,c
ld (step_rate),a

call send_specify

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
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix

pop bc
inc c
djnz srt1

ld bc,16
jp do_results


;;----------------------------------------------------------------

sense_clear_fdd_busy:

call go_to_0

di
ld a,15
call send_seek
call short_wait

ld ix,result_buffer

call sense_interrupt_status

call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call big_wait


call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

push de
call sense_interrupt_status
pop de

call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ei

ld bc,3
jp do_results



fdd_busy:
call go_to_0

ld ix,result_buffer

di
ld a,2
call send_seek

call big_wait

call get_drive_busy_mask
ld e,a

call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

push de
call read_id
pop de

call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
ei

ld bc,2
jp do_results

;;-------------------------------------------------------
;
res_sense_cmd:
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &c0,1,&80
defb &fe,&00



sense_cmd_status:
call check_ready_ok
ret nz

ld ix,result_buffer
ld b,15
ld c,1
scs:
push bc

push bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc


push bc
call do_motor_off
call do_motor_on
pop bc


ld a,c
add a,a
add a,a
add a,a
add a,a
or %1000
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%11000000
inc ix
cp &c0
jr nz,scs2
call fdc_result_phase
call get_results
jr scs3

scs2:
call restore_fdc
ld a,&ff
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,&ff
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
scs3:
pop bc
inc c
djnz scs
ld a,'-'
call output_char

ld ix,result_buffer
ld hl,res_sense_cmd
call copy_results

ld bc,15*3
jp do_results


res_sense_intr_no_int:
defb 1,&80
defb 2,&20,&fe,&01,&27
defb 1,&80
defb &fe,&00

sense_intr_no_int:
call go_to_0
call clear_fdd_interrupts

ld ix,result_buffer

call sis_with_results
ld a,39
call send_seek
call get_ready_change
call get_results

call clear_fdd_interrupts
call get_results

ld ix,result_buffer
ld hl,res_sense_intr_no_int
call copy_results

ld bc,7
jp do_results

;;-------------------------------------------------------


res_sense_intr_motor:
defb 2,&c0,&fe,&02,13
defb 2,&c8,&fe,&02,13
defb &fe,&00

sense_intr_motor:
call check_ready_ok
ret nz

call clear_fdd_interrupts

ld a,13
call go_to_track
call stop_drive_motor

call clear_fdd_interrupts

ld ix,result_buffer

call start_drive_motor

call get_ready_change
call get_results

call clear_fdd_interrupts

call stop_drive_motor

call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_sense_intr_motor
call copy_results

ld bc,6
jp do_results



sense_all_drives:
call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results
ret

res_version:
defb 1,&80
defb &fe,&00

version:
ld ix,result_buffer
ld a,%10000
call send_command_byte
call fdc_result_phase
call get_results


ld ix,result_buffer
ld hl,res_version
call copy_results

ld bc,2
jp do_results

invalid:
ld ix,result_buffer
ld b,0
ld c,0
inv:
push bc

push bc
push ix
call clear_fdd_interrupts
pop ix
pop bc

ld a,c
cp &f	;; seek
jr z,inv2
cp &4	;; sense drive status
jr z,inv2
cp 3	;; specify
jr z,inv2
cp 8	;; sense interrupt status
jr z,inv2
cp 7	;; recalibrate
jr z,inv2
and %11111
cp %11101
jr z,inv2
cp %11001
jr z,inv2
cp %10001
jr z,inv2
cp %01101
jr z,inv2
cp %01010
jr z,inv2
cp %00010
jr z,inv2
cp %01001
jr z,inv2
cp %00101
jr z,inv2
cp %01100
jr z,inv2
cp %00110
jr z,inv2
ld a,c
call send_command_byte
call fdc_result_phase
call get_results
ld (ix-3),1
ld (ix-1),&80
jr inv3

inv2:
;; it's valid
ld (ix+0),0
inc ix
ld (ix+0),0
inc ix
jr inv3

inv3:
pop bc
djnz inv

ld bc,256*2
jp do_results
;;----------------------------------------------------------------------

res_drive_ready_status:
defb &1,&10,&fe,&02
defb &1,&30,&fe,&02
defb &fe,&00

drive_ready_status:
call check_ready_ok
ret nz

call do_motor_off

ld ix,result_buffer

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a

call do_motor_on
call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld ix,result_buffer
ld hl,res_drive_ready_status
call copy_results

ld bc,4
jp do_results

res_drive_ss_side1:
res_drive_side1:
defb &1,%00110000,&fe,&02
defb &fe,&00

drive_side1_status:
call check_two_sides
ret z

ld ix,result_buffer

;; track 0 and ready
call go_to_0
;; side 1
call set_side1

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld ix,result_buffer
ld hl,res_drive_side1
call copy_results

ld bc,2
jp do_results

drive_side1_ss_status:
call check_one_sides
ret z

ld ix,result_buffer

;; track 0 and ready
call go_to_0
;; side 1
call set_side1

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld ix,result_buffer
ld hl,res_drive_ss_side1
call copy_results

ld bc,2
jp do_results


;;----------------------------------------------------------------------
 
 res_cmd_drive:
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &c0,&01,&80
 defb &fe,&00
 
drive_cmd_status:
call check_ready_ok
ret nz

ld ix,result_buffer
ld b,15
ld c,1
dcs:
push bc

push bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc


push bc
call do_motor_off
call do_motor_on
pop bc

ld a,c
add a,a
add a,a
add a,a
add a,a
or %100
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%11000000
inc ix
cp &c0
jr nz,dcs2

call fdc_result_phase
call get_results
jr dcs3

dcs2:
call restore_fdc
ld a,&ff
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,&ff
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

dcs3:

pop bc
inc c
djnz dcs

ld a,'-'
call output_char

ld ix,result_buffer
ld hl,res_cmd_drive
call copy_results

ld bc,15*3
jp do_results


;;----------------------------------------------------------------------
;; track0 test
;; 

res_drive_dma:
res_drive_trk0:
defb &1,%00110000,&fe,&02
defb &1,%00100000,&fe,&02
defb &fe,&00

drive_trk0_status:
call go_to_0

ld ix,result_buffer

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld a,1
call go_to_track

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld ix,result_buffer
ld hl,res_drive_trk0
call copy_results

ld bc,4
jp do_results

;;----------------------------------------------------------------------
drive_status_dma:
call go_to_0

ld ix,result_buffer

call set_dma_mode

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld a,1
call go_to_track

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


ld ix,result_buffer
ld hl,res_drive_dma
call copy_results

ld bc,4
jp do_results

res_read_id_de:
defb 7,0,&fe,&02,0,0,&1b,0,1,3
defb &fe,&00

read_id_de:
ld a,27
call go_to_track

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_de
call copy_results

ld bc,8
jp do_results

res_read_id_wc:
defb &7,0,&fe,&02,&0,&0,&1e,&0,&1,&2
defb &fe,&00

read_id_wc:
ld a,26
call go_to_track

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_wc
call copy_results

ld bc,8
jp do_results

res_read_id_bc:
defb &7,0,&fe,&02,&0,&0,&ff,&0,&1,&2
defb &fe,&00

read_id_bc:
ld a,30
call go_to_track

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_bc
call copy_results

ld bc,8
jp do_results

d765a_res_read_id_nr:
defb 7,&40,&fe,&02,&01,&00,&10,8,2,5
defb 7,&40,&fe,&02,&01,&00,&11,8,2,4
defb 7,&40,&fe,&02,&01,&00,&12,8,2,3
defb &fe,&00

u8272_res_read_id_nr:
z0765a_res_read_id_nr:
defb 7,&48,&fe,&02,&00,&00,&1c,0,1,5
defb 7,&48,&fe,&02,&00,&00,&1c,1,1,4
defb 7,&48,&fe,&02,&00,&00,&1c,2,1,3
defb &fe,&00

read_id_nr:
call check_ready_ok
ret nz

ld ix,result_buffer

ld b,3
ld a,16
rinr:
push af
push bc

push af
call do_motor_on
pop af

call go_to_track
call read_id

ld a,28
call go_to_track

call do_motor_off

call read_id
call get_results
pop bc
pop af
inc a
djnz rinr


ld ix,result_buffer
ld a,(fdc_model)
ld hl,z0765a_res_read_id_nr
cp fdc_model_z0765a
jr z,rinr2
ld hl,d765a_res_read_id_nr
cp fdc_model_d765ac2
jr z,rinr2
ld hl,u8272_res_read_id_nr
rinr2:
call copy_results

ld bc,8*3
jp do_results

read_id_rc:
call check_ready_ok
ret nz

ld a,33
call go_to_track

ld ix,result_buffer

di
call read_id
call send_read_id

call short_wait

call stop_drive_motor

call fdc_result_phase
call get_results
ei

ld bc,8
jp do_results

track_wanted:
defb 0

read_id_res:
push hl
ld ix,result_buffer

ld (track_wanted),a
ld b,3
ld a,16
riu:
push af
push bc

call go_to_track
call read_id

ld a,(track_wanted)
call go_to_track
call read_id
call get_results
pop bc
pop af
inc a
djnz riu

ld ix,result_buffer
pop hl
call copy_results

ld bc,8*3
jp do_results


read2_id_res:
push hl
ld ix,result_buffer

ld (track_wanted),a

ld a,16
call go_to_track

ld a,16
ld (rw_c),a
xor a
ld (rw_h),a
ld a,1
ld (rw_r),a
ld (rw_eot),a
ld a,5
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
call read_data


ld a,(track_wanted)
call go_to_track
call read_id
call get_results


ld a,17
call go_to_track

ld a,17
ld (rw_c),a
ld a,1
ld (rw_h),a
ld a,2
ld (rw_r),a
ld (rw_eot),a
ld a,4
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
call read_data

ld a,(track_wanted)
call go_to_track
call read_id
call get_results


ld a,17
call go_to_track


ld a,18
ld (rw_c),a
ld a,2
ld (rw_h),a
ld a,3
ld (rw_r),a
ld (rw_eot),a
ld a,3
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
call read_data

ld ix,result_buffer
pop hl
call copy_results

ld bc,8*3
jp do_results


;; C = previous C
;; H = track
;; R = 2
;; N = previous read N

d765a_res_read_id_unform:
defb 7,&40,&fe,&02,&01,&00,&10,8,2,5
defb 7,&40,&fe,&02,&01,&00,&11,8,2,4
defb 7,&40,&fe,&02,&01,&00,&12,8,2,3
defb &fe,&00

u8272_res_read_id_unform:
defb 7,&40,&fe,&02,&01,&00,&8,0,1,5
defb 7,&40,&fe,&02,&01,&00,&8,1,1,4
defb 7,&40,&fe,&02,&01,&00,&8,2,1,3
defb &fe,&00

z0765a_res_read_id_unform:
defb 7,&40,&fe,&02,&01,&00,&8,0,1,5
defb 7,&40,&fe,&02,&01,&00,&8,1,1,4
defb 7,&40,&fe,&02,&01,&00,&8,2,1,3
defb &fe,&00


read_id_unform:
ld a,(fdc_model)
ld hl,z0765a_res_read_id_unform
cp fdc_model_z0765a
jr z,riu1
ld hl,d765a_res_read_id_unform
cp fdc_model_d765ac2
jr z,riu2
ld hl,u8272_res_read_id_unform
riu1:

ld a,8
jp read_id_res

d765a_res_read2_id_unform:
defb 7,&40,&fe,&02,&01,&00,&10,8,2,5
defb 7,&40,&fe,&02,&01,&00,&11,8,2,4
defb 7,&40,&fe,&02,&01,&00,&12,8,2,3
defb &fe,&00

u8272_res_read2_id_unform:
z0765a_res_read2_id_unform:
defb 7,&40,&fe,&02,&01,&00,&8,0,1,5
defb 7,&40,&fe,&02,&01,&00,&8,1,1,4
;; 07.48,00,00,1c,02,01,03
defb 7,&40,&fe,&02,&01,&00,&8,2,1,3
defb &fe,&00

read2_id_unform:
ld a,(fdc_model)
ld hl,z0765a_res_read2_id_unform
cp fdc_model_z0765a
jr z,riu2
ld hl,d765a_res_read2_id_unform
cp fdc_model_d765ac2
jr z,riu2
ld hl,u8272_res_read2_id_unform
riu2:
ld a,8
jp read2_id_res


res_read_id_dma:
defb %00010000
defb 7,0,&fe,&02,0,0,28,0,1,2
defb &fe,&00

res_read_id_only:
defb 7,0,&fe,&02,0,0,28,0,1,2
defb &fe,&00

res_read_id_delay:
defb 7,0,&fe,&02,0,0,28,0,1,2
defb &fe,&00

res_read_id_ov:
defb 7,0,&fe,&02,0,0,28,0,1,2
defb &fe,&00

res_read_id_side1:
defb 7,0,&fe,&02,0,0,28,1,1,2
defb &fe,&00

read_id_side1:
call check_two_sides
ret z
ld a,28
call go_to_track

call set_side1

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_side1
call copy_results

ld bc,8
jp do_results

res_read_id_ss_side1:
defb 7,0,&fe,&02,0,0,28,0,1,2
defb &fe,&00

read_id_ss_side1:
call check_one_sides
ret z

ld a,28
call go_to_track

call set_side1

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_ss_side1
call copy_results

ld bc,8
jp do_results


read_id_only:
ld a,28
call go_to_track

ld ix,result_buffer

call send_read_id
call fdc_result_phase
call get_results

ld ix,result_buffer
ld hl,res_read_id_only
call copy_results

ld bc,8
jp do_results


read_id_delay:
ld a,28
call go_to_track

ld ix,result_buffer

di
call send_read_id
call big_wait
call fdc_result_phase
call get_results
ei

ld ix,result_buffer
ld hl,res_read_id_delay
call copy_results

ld bc,8
jp do_results


read_id_ov:
ld a,28
call go_to_track

ld ix,result_buffer

di
call send_read_id

call big_wait

call fdc_result_phase
call get_results
ei

ld ix,result_buffer
ld hl,res_read_id_ov
call copy_results

ld bc,8
jp do_results

res_read_id_mt:
defb 7,&00,&fe,&02,0,0,28,0,1,2
defb 7,&00,&fe,&02,0,0,24,&fe,&fe,3,2
defb &fe,&00

read_id_mt:
ld a,28
call go_to_track

call set_mt

ld ix,result_buffer

call read_id
call get_results

ld a,24
call go_to_track

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_mt
call copy_results

ld bc,16
jp do_results

res_read_id_side1_mt:
defb 7,&00,&fe,&02,0,0,28,1,1,2
defb 7,&00,&fe,&02,0,0,24,&ff,3,2
defb &fe,&00

read_id_side1_mt:
call check_two_sides
ret z
ld a,28
call go_to_track

call set_mt
call set_side1

ld ix,result_buffer

call read_id
call get_results

ld a,24
call go_to_track

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_side1_mt
call copy_results

ld bc,16
jp do_results

res_read_id_sk:
defb 7,0,&fe,&02,0,0,&19,0,1,2
defb &fe,&00

read_id_sk:
ld a,25
call go_to_track

call set_skip

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_sk
call copy_results

ld bc,8
jp do_results


read_id_dma:

ld a,28
call go_to_track

ld ix,result_buffer

call set_dma_mode

call send_read_id
call fdc_read_main_status_register
ld (ix+0),a
inc ix
inc ix
call fdc_result_phase

call get_results

ld ix,result_buffer
ld hl,res_read_id_dma
call copy_results

ld bc,8
jp do_results

res_read_id_fm:
defb 7,&40,&fe,&02,&01,&00,&19,&1d,2,2
defb 7,&40,&fe,&02,&01,&00,&19,&1d,2,2
defb 7,&40,&fe,&02,&01,&00,&19,&1d,2,2
defb &fe,&00

u8272_res_read_id_fm:
defb 7,&40,&fe,&02,&01,&00,&1d,&2,1,3
defb 7,&40,&fe,&02,&01,&00,&1d,&2,1,3
defb 7,&40,&fe,&02,&01,&00,&1d,&2,1,3
defb &fe,&00

z0765a_res_read_id_fm:
defb 7,&40,&fe,&02,&01,&00,&19,&00,1,2
defb 7,&40,&fe,&02,&01,&00,&19,&00,1,2
defb 7,&40,&fe,&02,&01,&00,&19,&00,1,2
defb &fe,&00

res_read2_id_fm:
defb 7,&40,&fe,&02,&01,&00,&19,&1d,2,2
defb 7,&40,&fe,&02,&01,&00,&19,&1d,2,2
defb 7,&40,&fe,&02,&01,&00,&19,&1d,2,2
defb &fe,&00


res_read2_id_fm_plus:
defb 7,&40,&fe,&02,&01,&00,&1d,2,1,3
defb 7,&40,&fe,&02,&01,&00,&1d,2,1,3
defb 7,&40,&fe,&02,&01,&00,&1d,2,1,3
defb &fe,&00

res_read_id_fm_mfm:
defb 7,&40,&fe,&02,&01,&00,&12,&1c,2,3
defb 7,&40,&fe,&02,&01,&00,&12,&1c,2,3
defb 7,&40,&fe,&02,&01,&00,&12,&1c,2,3
defb &fe,&00

u8272_res_read_id_fm_mfm:
z0765a_res_read_id_fm_mfm:
defb 7,&40,&fe,&02,&01,&00,&1c,2,1,3
defb 7,&40,&fe,&02,&01,&00,&1c,2,1,3
defb 7,&40,&fe,&02,&01,&00,&1c,2,1,3
defb &fe,&00

read_id_fm:
call set_fm

ld a,(fdc_model)
ld hl,z0765a_res_read_id_fm
cp fdc_model_z0765a
jr z,rif1
ld hl,u8272_res_read_id_fm
cp fdc_model_um8272
jr z,rif1
ld hl,res_read_id_fm
rif1:
ld a,29
ld hl,res_read_id_fm
jp read_id_res

read2_id_fm:
call set_fm

ld a,29
ld hl,res_read2_id_fm
jp read_id_res

res_read_id_mfm_fm:
defb 7,&40,&fe,&02,&01,&00,&10,&1d,2,5
defb 7,&40,&fe,&02,&01,&00,&11,&1d,2,4
defb 7,&40,&fe,&02,&01,&00,&12,&1d,2,3
defb &fe,&00

um8272_res_read_id_mfm_fm:
z0765a_res_read_id_mfm_fm:
defb 7,&40,&fe,&02,&01,&00,&1d,&00,1,5
defb 7,&40,&fe,&02,&01,&00,&1d,&1,1,4
defb 7,&40,&fe,&02,&01,&00,&1d,&2,1,3
defb &fe,&00


res_read2_id_mfm_fm_plus:
defb 7,&40,&fe,&02,&01,&00,&1c,&00,1,5
defb 7,&40,&fe,&02,&01,&00,&1c,&1,1,4
defb 7,&40,&fe,&02,&01,&00,&1c,&2,1,3
defb &fe,&00

;; H = track
;; C = previous C
;; R = 2
;; N = previous N

read_id_mfm_fm:

ld a,(fdc_model)
ld hl,z0765a_res_read_id_mfm_fm
cp fdc_model_z0765a
jr z,rimfmfm1
ld hl,um8272_res_read_id_mfm_fm
cp fdc_model_um8272
jr z,rimfmfm1
ld hl,res_read_id_mfm_fm
rimfmfm1:

ld a,29
ld hl,res_read_id_mfm_fm
jp read_id_res

read2_id_mfm_fm:
ld a,29
ld hl,res_read_id_mfm_fm
jp read2_id_res

read_id_fm_mfm:
call set_fm

ld a,(fdc_model)
ld hl,z0765a_res_read_id_fm_mfm
cp fdc_model_z0765a
jr z,riffmmfm1
ld hl,u8272_res_read_id_fm_mfm
cp fdc_model_um8272
jr z,riffmmfm1
ld hl,res_read_id_fm_mfm
riffmmfm1:

ld a,28
jp read_id_res

read2_id_fm_mfm:
call set_fm

ld a,28
ld hl,res_read_id_fm_mfm
jp read2_id_res


;;-----------------------------------------
test_disk_format_data:
defb 0
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 0,&0,&41,2
defb 0,&0,&42,2
defb 0,&0,&43,2
defb 0,&0,&44,2
defb 0,&0,&45,2
defb 0,&0,&46,2
defb 0,&0,&47,2
defb 0,&0,&48,2
defb 0,&0,&49,2

;;-----------------------------------------
defb 0
defb 1	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 0,&1,&41,2
defb 0,&1,&42,2
defb 0,&1,&43,2
defb 0,&1,&44,2
defb 0,&1,&45,2
defb 0,&1,&46,2
defb 0,&1,&47,2
defb 0,&1,&48,2
defb 0,&1,&49,2

;;-----------------------------------------
defb 4
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 0,0,&aa,3

;;-----------------------------------------
defb 5
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 5,1,1,2
defb 5,1,2,2
defb 5,1,3,2
defb 5,1,4,2
defb 5,1,5,2
defb 5,1,6,2
defb 5,1,7,2
defb 5,1,8,2
defb 5,1,9,2

;;-----------------------------------------
defb 5
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 5,0,1,2
defb 5,0,2,2
defb 5,0,3,2
defb 5,0,4,2
defb 5,0,5,2
defb 5,0,6,2
defb 5,0,7,2
defb 5,0,8,2
defb 5,0,9,2

;;-----------------------------------------
defb 7
defb 0
defb %01000000

defb 7
defb 1
defb def_format_gap
defb def_format_filler
defb 7,0,&c1,&6

;;-----------------------------------------
defb 8
defb 0
defb %01000000

defb 7
defb 1
defb def_format_gap
defb def_format_filler
defb 8,0,0,0




;;-----------------------------------------
defb 11
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 11,&0,&c1,2
defb 11,&0,&c2,2
defb 11,&0,&c3,2
defb 11,&0,&c4,2
defb 11,&0,&c5,2
defb 11,&0,&c6,2
defb 11,&0,&c7,2
defb 11,&0,&c8,2
defb 11,&0,&c9,2

;;-----------------------------------------
defb 11
defb 0	
defb %01000000

defb 1
defb 16
defb def_format_gap
defb def_format_filler
defb 13,&0,&1,1
defb 13,&0,&2,1
defb 13,&0,&3,1
defb 13,&0,&4,1
defb 13,&0,&5,1
defb 13,&0,&6,1
defb 13,&0,&7,1
defb 13,&0,&8,1
defb 13,&0,&9,1
defb 13,&0,&a,1
defb 13,&0,&b,1
defb 13,&0,&c,1
defb 13,&0,&d,1
defb 13,&0,&e,1
defb 13,&0,&f,1
defb 13,&0,&10,1

;;-----------------------------------------
defb 12
defb 0	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb &ff,0,&c1,&2
defb &20,&20,&20,&2

;;-----------------------------------------
defb 13
defb 0	
defb %01000000

defb 1
defb 16
defb def_format_gap
defb def_format_filler
defb 13,&0,&1,1
defb 13,&0,&2,1
defb 13,&0,&3,1
defb 13,&0,&4,1
defb 13,&0,&5,1
defb 13,&0,&6,1
defb 13,&0,&7,1
defb 13,&0,&8,1
defb 13,&0,&9,1
defb 13,&0,&a,1
defb 13,&0,&b,1
defb 13,&0,&c,1
defb 13,&0,&d,1
defb 13,&0,&e,1
defb 13,&0,&f,1
defb 13,&0,&10,1

;;-----------------------------------------
defb 15
defb 0	
defb %01000000

defb 0
defb 16
defb def_format_gap
defb def_format_filler
defb 15,&0,&1,0
defb 15,&0,&2,0
defb 15,&0,&3,0
defb 15,&0,&4,0
defb 15,&0,&5,0
defb 15,&0,&6,0
defb 15,&0,&7,0
defb 15,&0,&8,0
defb 15,&0,&9,0
defb 15,&0,&a,0
defb 15,&0,&b,0
defb 15,&0,&c,0
defb 15,&0,&d,0
defb 15,&0,&e,0
defb 15,&0,&f,0
defb 15,&0,&10,0

;;-------------------------------------------
defb 16
defb 0
defb %01000000

defb 5
defb 1
defb def_format_gap
defb def_format_filler
defb 16,&0,&1,5

;;-------------------------------------------
defb 17
defb 0
defb %01000000

defb 4
defb 1
defb def_format_gap
defb def_format_filler
defb 17,&1,&2,4

;;-------------------------------------------
defb 18
defb 0
defb %01000000

defb 3
defb 1
defb def_format_gap
defb def_format_filler
defb 18,&2,&3,3


;;-----------------------------------------

defb 19
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2
defb 19,&0,&1,2


;;-----------------------------------------
;; used for deleted data test

defb 20
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 20,&0,&1,2
defb 20,&0,&2,2
defb 20,&0,&3,2
defb 20,&0,&4,2
defb 20,&0,&5,2
defb 20,&0,&6,2
defb 20,&0,&7,2
defb 20,&0,&8,2
defb 20,&0,&9,2


;;-----------------------------------------
;; used for deleted data test

defb 21
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 21,&0,&1,2
defb 21,&0,&2,2
defb 21,&0,&3,2
defb 21,&0,&4,2
defb 21,&0,&5,2
defb 21,&0,&6,2
defb 21,&0,&7,2
defb 21,&0,&8,2
defb 21,&0,&9,2


;;--------------------------------
defb 22
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 22,&0,&1,2
defb 22,&0,&2,2
defb 22,&0,&3,2
defb 22,&0,&4,2
defb 22,&0,&5,2
defb 22,&0,&6,2
defb 22,&0,&7,2
defb 22,&0,&8,2
defb 22,&0,&9,2


;;--------------------------------
defb 22
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 22,&1,&1,2
defb 22,&1,&2,2
defb 22,&1,&3,2
defb 22,&1,&4,2
defb 22,&1,&5,2
defb 22,&1,&6,2
defb 22,&1,&7,2
defb 22,&1,&8,2
defb 22,&1,&9,2


;;--------------------------------
defb 23
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 23,&0,&fa,2
defb 23,&0,&fb,2
defb 23,&0,&fc,2
defb 23,&0,&fd,2
defb 23,&0,&fe,2
defb 23,&0,&ff,2
defb 23,&0,&00,2
defb 23,&0,&01,2
defb 23,&0,&02,2

;;-----------------------------------------
defb 23
defb 1	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 23,&1,&fa,2
defb 23,&1,&fb,2
defb 23,&1,&fc,2
defb 23,&1,&fd,2
defb 23,&1,&fe,2
defb 23,&1,&ff,2
defb 23,&1,&00,2
defb 23,&1,&01,2
defb 23,&1,&02,2



;;-----------------------------------------
defb 24
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 24,&fe,3,2

;;-----------------------------------------
defb 24
defb 1
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 24,&ff,3,2

;;-----------------------------------------
defb 25
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 25,0,1,2

;;-----------------------------------------
defb 26
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 30,0,1,2


;;-----------------------------------------
defb 27
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 27,0,1,3

;;-----------------------------------------
defb 28
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 28,0,1,2

;;-----------------------------------------
defb 28
defb 1
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 28,1,1,2

;;-----------------------------------------
defb 29
defb 0
defb %00000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 29,0,1,2

;;-----------------------------------------
defb 30
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb &ff,0,1,2

;;-----------------------------------------
defb 31
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 20,0,1,2

;;-----------------------------------------
defb 32
defb 0	
defb %00000000

defb 1
defb 9
defb &15
defb def_format_filler
defb 1,&0,&a1,1
defb 1,&0,&a2,1
defb 1,&0,&a3,1
defb 1,&0,&a4,1
defb 1,&0,&a5,1
defb 1,&0,&a6,1
defb 1,&0,&a7,1
defb 1,&0,&a8,1
defb 1,&0,&a9,1

;;-----------------------------------------
defb 33
defb 0	
defb %01000000

defb 2
defb 2
defb &15
defb def_format_filler
defb 33,&0,&41,2
defb 33,&0,&42,3


;;-----------------------------------------
defb 34
defb 0	
defb %01000000

defb 2
defb 9
defb &15
defb def_format_filler
defb 34,&0,&41,2
defb 34,&0,&46,2
defb 34,&0,&42,2
defb 34,&0,&47,2
defb 34,&0,&43,2
defb 34,&0,&48,2
defb 34,&0,&44,2
defb 34,&0,&49,2
defb 34,&0,&45,2
defb -1

;; track, side, mfm,num ids, ids.
dd_test_disk_data:
defb 20
defb 0
defb %01000000

defb 6
defb 20,0,&2,&2
defb 20,0,&3,&2
defb 20,0,&4,&2
defb 20,0,&5,&2
defb 20,0,&6,&2
defb 20,0,&7,&2


defb 21
defb 0
defb %01000000

defb 4
defb 21,0,&2,&2
defb 21,0,&4,&2
defb 21,0,&6,&2
defb 21,0,&8,&2


;;----------------------------------
defb 22
defb 0
defb %01000000

defb 9
defb 22,0,1,&2
defb 22,0,2,&2
defb 22,0,3,&2
defb 22,0,4,&2
defb 22,0,5,&2
defb 22,0,6,&2
defb 22,0,7,&2
defb 22,0,8,&2
defb 22,0,9,&2

;;----------------------------------
defb 22
defb 1
defb %01000000

defb 9
defb 22,1,1,&2
defb 22,1,2,&2
defb 22,1,3,&2
defb 22,1,4,&2
defb 22,1,5,&2
defb 22,1,6,&2
defb 22,1,7,&2
defb 22,1,8,&2
defb 22,1,9,&2

defb 25
defb 0
defb %01000000

defb 1
defb 25,0,1,&2

;;--------------------------
defb 33
defb 0
defb %01000000

defb 1
defb 33,0,&41,&2


defb -1

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
include "../../lib/output.asm"
include "../../lib/hw/fdc.asm"
if CPC=1
include "../cpc.asm"
include "../../lib/fw/output.asm"
endif
if SPEC=1
include "../plus3.asm"
include "../../lib/spec/init.asm"
include "../../lib/spec/keyfn.asm"
include "../../lib/spec/printtext.asm"
include "../../lib/spec/readkeys.asm"
include "../../lib/spec/scr.asm"
include "../../lib/spec/writetext.asm"

sysfont:
incbin "../../lib/spec/font.bin"

endif
include "../fdchelper.asm"

result_buffer equ $

end start