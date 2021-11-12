;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This test concentrates on seek

include "../../lib/testdef.asm"

if CPC=1
org &1000
endif
if SPEC=1
org &8000
endif

start:

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
jp do_restart


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
defb "This test concentrates on seek and recalibrate.",13,13
defb "Requirements:",13
defb "- disc is writeable (NOT write protected)",13
defb 0

tests:
;; TEST!
;;DEFINE_TEST "parallel seek (same)",p_seek_same
;; TEST!
;;DEFINE_TEST "parallel seek (diff)",p_seek_diff
;;DEFINE_TEST "parallel seek (diff with wait)",p_seek_wait_diff
;; TEST!
;;DEFINE_TEST "parallel recalibrate (same)",p_recal_same
;; TEST!
;;DEFINE_TEST "parallel recalibrate (diff)",p_recal_diff

;; type 0 with switches grinds like crazy
;; type 2 - sounds like seek goes a bit weird
DEFINE_TEST "seek command repeat (while seeking)",seek_repeat
;; type 2 - hangs

;; type 0 with switches grinds like crazy
DEFINE_TEST "seek and keep changing track",seek_many
DEFINE_TEST "seek (execution phase)",seek_exec
DEFINE_TEST "recalibrate (execution phase)",recal_exec

;; Ready change cleared by seek?


DEFINE_TEST "recal then seek",recal_seek

DEFINE_TEST "seek then recalibrate",seek_recal
DEFINE_TEST "seek then invalid (&ff) command",invalid_in_seek
DEFINE_TEST "seek (twice)",seek_twice
DEFINE_TEST "seek (sense drive status for trk0)",seek_ds
DEFINE_TEST "recal (sense drive status for trk0)",recal_ds
;;DEFINE_TEST "shorter seek step (nec765 delay seek command)",seek_short

;; when drive 1 this has c8 for drive 0..
;; make drive 0 only?
DEFINE_TEST "specify during seek (may FAIL, numbers may differ a little)",seek_specify

;;DEFINE_TEST "all step the same time",seek_same_time
;; 9 hangs on type 0
;;DEFINE_TEST "seek (command during seek)",seek_invalid
DEFINE_TEST "seek drive n and drive n+2 (n->0, n+2 -> 39) (wait first seek)",seek_two_drives
DEFINE_TEST "seek drive n and drive n+2 (n->0, n+2 -> 39) (wait all seeks)",seek3_two_drives
DEFINE_TEST "seek drive n and drive n+2 (n->10, n+2 -> 10)",seek2_two_drives


;; c5,b9,ac,a0,94,88,7b,6f,62,56,4a,3e,32,26,19,0c
DEFINE_TEST "specify (time step rate) (may FAIL - numbers +1 or -1 compared to number shown here)",specify_srt
DEFINE_TEST "seek (all tracks up to 39)",seek_ncn
DEFINE_TEST "recal (side 1) (ds)",recal_side1
DEFINE_TEST "recal (ready change after recal)",recal_rc_after
DEFINE_TEST "seek (wait for end without sense int), then read id",seek_readid
DEFINE_TEST "seek (try read id during seek)",seek_test5
DEFINE_TEST "recal (ready change)",recal_rc
DEFINE_TEST "recal (ready change - trk0)",recal_rc_trk0
DEFINE_TEST "recal (other command bits)",recal_cmd
DEFINE_TEST "recal (equipment check)",recal_ec
DEFINE_TEST "recal (drive status)",recal_drive_status
DEFINE_TEST "recal (on track 0)",recal_trk0
DEFINE_TEST "recal (not ready - not trk0)",recal_nr
DEFINE_TEST "recal (not ready - trk 0)",recal_nr_trk0
DEFINE_TEST "recal (side 1) (ss)",recal_ss_side1
DEFINE_TEST "recal (ready change)",recal_rc
DEFINE_TEST "recal (fdd busy)",recal_fdd_busy
DEFINE_TEST "recal (fdc busy)",recal_fdc_busy
DEFINE_TEST "seek (ready change)",seek_rc
DEFINE_TEST "seek (seek then ready change after)",seek_rc_after
DEFINE_TEST "seek (ready change - same track)",seek_rc_same
DEFINE_TEST "seek (equipment check)",seek_ec
DEFINE_TEST "seek (drive status)",seek_drive_status
DEFINE_TEST "seek (other command bits)",seek_cmd
DEFINE_TEST "seek (not ready not same track)",seek_nr
DEFINE_TEST "seek (not ready same track)",seek_nr_st
DEFINE_TEST "seek (side 1) (ds)",seek_side1
DEFINE_TEST "seek (side 1) (ss)",seek_ss_side1
DEFINE_TEST "seek (ready change)",seek_rc
DEFINE_TEST "seek (fdd busy)",seek_fdd_busy
DEFINE_TEST "seek (fdc busy)",seek_fdc_busy
DEFINE_TEST "seek (no sense interrupt status, fdd busy)",seek_wait_busy
DEFINE_TEST "seek same track (fdd busy)",seek_same
DEFINE_TEST "seek (long seek then short seek)",seek_mult

DEFINE_TEST "recal (dma mode)",recal_dma
DEFINE_TEST "seek (dma mode)",seek_dma

;; HANG on D765A, z765a seems to do something but hangs
DEFINE_TEST "recal command repeat (while seeking)",recal_repeat

DEFINE_END_TEST

did_exec_happen:
ld d,0
deh1:
call fdc_read_main_status_register
and &20
jr z,deh2
ld d,1
deh2:
and %10000
jr nz,deh1
ld (ix+0),d
inc ix
inc ix
ret


res_seek_exec:
res_recal_exec:
defb &0			;; d765a
defb &fe,&00

seek_exec:
call go_to_0
ld a,39
call send_seek
ld hl,res_seek_exec
jp do_exec


recal_exec:
ld a,39
call go_to_track
call send_recalibrate
ld hl,res_recal_exec
jp do_exec

do_exec:
push hl
ld ix,result_buffer

call did_exec_happen

ld ix,result_buffer
pop hl
call copy_results

ld bc,1
jp do_results

res_seek_recal:
defb &7,&00,&fe,&01,&00,&00,0,&00,&41,&02
defb &fe,&00

seek_recal:
ld a,10
call go_to_track

ld ix,result_buffer

di
ld a,39
call send_seek

call short_wait

call send_recalibrate
call wait_end_read_id
ei

ld ix,result_buffer
ld hl,res_seek_recal
call copy_results

ld bc,8
jp do_results


res_recal_seek:
defb &7,&40,&fe,&01,&01,&00,3,&00,&41,&02
defb &7,&00,&fe,&01,&00,&00,&26,&00,&41,&02
defb &fe,&00

res_recal_z765a_seek:
res_recal_d765a_seek:
defb &7,&0,&fe,&01,&0,&00,&28,&00,&41,&02
defb &7,&00,&fe,&01,&00,&00,&25,&00,&41,&02
defb &fe,&00


recal_seek:
ld a,39
call go_to_track

ld ix,result_buffer

di
call send_recalibrate

call short_wait

ld a,3
call send_seek
call wait_end_read_id

ld a,39
call go_to_track

call send_recalibrate

call short_wait

ld a,0
call send_seek
call wait_end_read_id
ei

ld a,(fdc_model)
ld hl,res_recal_z765a_seek
cp fdc_model_z0765a
jr z,rrs
ld hl,res_recal_d765a_seek
cp fdc_model_d765ac2
jr z,rrs
ld hl,res_recal_seek	;; confirm
rrs:


ld ix,result_buffer
call copy_results

ld bc,16
jp do_results


res_seek_many:
defb &7,&00,&fe,&01,&00,&00,3,&00,&41,&02
defb &fe,&00


seek_many:
ld a,0
call go_to_track

ld ix,result_buffer
di
ld a,39
call send_seek

call short_wait

ld a,10
call send_seek

call short_wait

ld a,20
call send_seek

call short_wait

ld a,3
call send_seek

call short_wait
call wait_end_read_id
ei

ld ix,result_buffer
ld hl,res_seek_many
call copy_results

ld bc,8
jp do_results

wait_end_read_id:
call wait_for_seek_end

read_id_with_results:
call read_id
jp get_results


res_seek_repeat:
defb &2,&20,&fe,&01,39
defb &7,&00,&fe,&01,&00,&00,39,&00,&41,&02
defb &fe,&00


res_z765a_seek_repeat:
defb &2,&20,&fe,&01,39
defb &7,&00,&fe,&01,&00,&00,6,&00,&41,&02
defb &fe,&00

res_d765a_seek_repeat:
defb &2,&20,&fe,&01,&27
defb &7,&00,&fe,&01,&00,&00,&14,&00,&41,&02
defb &fe,&00

seek_repeat:
call go_to_0

ld ix,result_buffer

di
sr1:
ld a,39
call send_seek

call sense_interrupt_status
ld a,(fdc_result_data)
bit 4,a
jr nz,sr2
bit 5,a
jr z,sr1
sr2:
call get_results

call read_id_with_results
ei


ld a,(fdc_model)
ld hl,res_z765a_seek_repeat;; confirm
cp fdc_model_z0765a
jr z,rsr
ld hl,res_d765a_seek_repeat
cp fdc_model_d765ac2
jr z,rsr
ld hl,res_seek_repeat	;; confirm
rsr:

ld ix,result_buffer
call copy_results

ld bc,11
jp do_results


res_recal_repeat:
defb &2,&20,&fe,&01,0
defb &7,&00,&fe,&01,&00,&00,0,&00,&41,&02
defb &fe,&00

;; d765a HANGS
res_d765a_recal_repeat:
defb &2,&20,&fe,&01,0
defb &7,&40,&fe,&01,&01,&00,&4d,&00,&41,&02
defb &fe,&00


recal_repeat:
ld a,39
call go_to_track

ld ix,result_buffer

;; d765a seeks wrong way???
di
rr1:
call send_recalibrate

call sense_interrupt_status
ld a,(fdc_result_data)
bit 4,a
jr nz,rr2
bit 5,a
jr z,rr1
rr2:
call get_results

;;call read_id_with_results
ei



ld a,(fdc_model)
ld hl,res_recal_repeat;; confirm
cp fdc_model_z0765a
jr z,rrr11
ld hl,res_d765a_recal_repeat
cp fdc_model_d765ac2
jr z,rrr11
ld hl,res_recal_repeat	;; confirm
rrr11:

ld ix,result_buffer
call copy_results

ld bc,11
jp do_results

;; 8272
res_seek_twice:
defb &2,&20,&fe,&01,8
defb &7,&00,&fe,&01,&00,&00,8,&00,&41,&02
defb &fe,&00

seek_twice:
call go_to_0

ld ix,result_buffer

di
ld a,4
call send_seek
call big_wait
ld a,8
call send_seek
call big_wait

call wait_fdd_interrupt
call get_results

call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_seek_twice
call copy_results

ld bc,11
jp do_results

;; 8272
res_recal_ds:
res_seek_ds:
defb &01,&80
defb &fe,&00

seek_ds:
ld ix,result_buffer

ld a,39
call go_to_track

di
ld a,0
call send_seek

seek_ds1:
call sense_drive_status
ld a,(fdc_result_data)
bit 4,a
jr nz,seek_ds1

call sis_with_results
ei

ld ix,result_buffer
ld hl,res_seek_ds
call copy_results

ld bc,2
jp do_results

recal_ds:
ld ix,result_buffer

ld a,39
call go_to_track

di
call send_recalibrate

recal_ds1:
call sense_drive_status
ld a,(fdc_result_data)
bit 4,a
jr nz,recal_ds1

call sis_with_results
ei

ld ix,result_buffer
ld hl,res_recal_ds
call copy_results

ld bc,2
jp do_results

sis_with_results:
call sense_interrupt_status
jp get_results

sss:
di
ld a,2
call go_to_track

ld a,%0000001111    ;; seek command
call send_command_byte
ld a,(drive)
and %11
call send_command_byte
sss_delay:
jp sss_delay
defs 2048
sss_delay2:
xor a
call send_command_byte

;; now time when seek is done

ld de,0
sss4:
push de
call sense_drive_status
pop de
ld a,(fdc_result_data)
bit 4,a
jr nz,sss5
inc de
jr sss4
sss5:
ld (ix+0),e
inc ix
inc ix
ld (ix+0),d
inc ix
inc ix
call read_id_with_results
ei
ret

;; numbers differ on cpc with type 0
res_seek_short:
defw &49
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &48
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &46
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &45
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &45
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &40
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &42
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &43
defb 7,0,&fe,&01,0,0,0,0,&41,2
defw &41
defb 7,0,&fe,&01,0,0,0,0,&41,2
defb &fe,&00



seek_short:
;;nec765: "if the time to write 3 bytes of seek command exceeds 150us
;; the timing between first two step pulses may be shorter than that
;; set in the specify command by as much as 1ms"
call go_to_0

ld ix,result_buffer

ld hl,sss_delay2
ld b,8
ld de,256
sss3:
push bc
ld a,b
call outputdec
ld a,' '
call output_char
push de
ld (sss_delay+1),hl
or a
sbc hl,de
push hl
call sss
pop hl
pop de
pop bc
djnz sss3


ld ix,result_buffer
ld hl,res_seek_short
call copy_results

ld bc,10*8
jp do_results

res_seek_specify:
defb &2,&68,&fe,&01,&2
defb 7,&0,&fe,&01,0,0,2,0,&41,2
defb &2,&68,&fe,&01,&3
defb 7,&0,&fe,&01,0,0,3,0,&41,2 ;; seems to make it faster?
defb &fe,&00


res_seek_d765a_specify:
defb &2,&20,&fe,&01,&27
defb 7,&0,&fe,&01,0,0,&27,0,&41,2
defb &2,&20,&fe,&01,&27
defb 7,&0,&fe,&01,0,0,&27,0,&41,2 ;; seems to make it faster?
defb &fe,&00

seek_specify:
ld ix,result_buffer

di
;;---------------------------------------------
call reset_specify
call go_to_0

;; do slowest
ld a,0
ld (step_rate),a
call send_specify

;; seek and wait then stop motor
ld a,39
call send_seek

call short_wait

call short_wait

call stop_drive_motor

call wait_fdd_interrupt
call get_results

call do_motor_on
call read_id_with_results

;;---------------------------------------------------------------------
;; and lets tsry again but we'll speed up the seek a bit
call reset_specify
call go_to_0

ld a,39
call send_seek

call short_wait

ld a,5
ld (step_rate),a
call send_specify

call short_wait

call stop_drive_motor

call wait_fdd_interrupt
call get_results

call do_motor_on
call read_id_with_results
ei

ld a,(fdc_model)
ld hl,res_seek_specify;; confirm
cp fdc_model_z0765a
jr z,rss11
ld hl,res_seek_d765a_specify
cp fdc_model_d765ac2
jr z,rss11
ld hl,res_recal_seek	;; confirm
rss11:

ld ix,result_buffer
call copy_results

ld bc,3+8+3+8
jp do_results

cids:
push af

call go_to_0

di
ld a,39
call send_seek

call short_wait

pop af
call send_command_byte

call fdc_read_main_status_register
and %11000000
ld (ix+0),a
inc ix
inc ix
cp &c0
jr nz,cids2
;; do result phase for invalid
call fdc_result_phase
call get_results
jr cids3

cids2:
call restore_fdc
ei
ld a,&ff
ld (ix+0),a
inc ix
inc ix
ld a,&ff
ld (ix+0),a
inc ix
inc ix
cids3:
ret

seek_invalid_commands:
defb %11111 ;; invalid
defb %00110 ;; read data
defb %01100 ;; read deleted data
defb %00101 ;; write data
defb %01001 ;; write deleted data
defb %00010 ;; read a track 
defb %01010 ;; read id
defb %01101	;; format track ;; seek?
defb %10001	;; scan low ;; seek?
defb %11001	;; scan low or equal ;; seek?
defb %11101	;; scan high or equal
end_seek_invalid_commands:

res_seek_invalid:
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &00	;//80
defb &fe,&ff,&fe,&ff
defb &fe,&00

seek_invalid:
ld ix,result_buffer
ld b,end_seek_invalid_commands-seek_invalid_commands
ld hl,seek_invalid_commands
si:
push bc
push hl

push hl
ld a,b
call outputdec
ld a,' '
call output_char
pop hl

ld a,(hl)
call cids

pop hl
inc hl
pop bc
djnz si


ld ix,result_buffer
ld hl,res_seek_invalid
call copy_results

ld bc,3*(end_seek_invalid_commands-seek_invalid_commands)
jp do_results

res_invalid_in_seek:
defb &1,&80
defb &7,&00,&fe,&01,&00,&00,2,0,&41,2
defb &fe,&00

invalid_in_seek:
call go_to_0

ld ix,result_buffer
di
ld a,39
call send_seek

call short_wait

ld a,&ff
call send_command_byte
call fdc_result_phase
call get_results

call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_invalid_in_seek
call copy_results

ld bc,10
jp do_results



seek_fdd_busy:
call go_to_0

ld ix,result_buffer

di
call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld a,%1111						;; seek
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

ld a,(drive)					;; drive
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix


ld a,39							;; destination track
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call short_wait

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call wait_for_seek_end


call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix
ei

ld bc,6
jp do_results

res_p_seek_same:
defb &2,&20,&fe,&01,39
defb &2,&21,&fe,&01,39
defb 7,&00,&fe,&01,&00,&00,39,0,&41,2
defb &fe,&00

p_seek_same:
call check_multi_drives
ret z

call do_motor_on

ld ix,result_buffer
di

call go_to_0
call swap_drive
call go_to_0
call swap_drive

ld a,39
call send_seek
call swap_drive
ld a,39
call send_seek
call swap_drive

call wait_fdd_interrupt
call get_results
call sis_with_results

call read_id_with_results
;;call swap_drive
;;call read_id
;;call get_results
;;call swap_drive
ei

ld ix,result_buffer
ld hl,res_p_seek_same
call copy_results

ld bc,14
jp do_results

res_p_recal_same:
defb &2,&20,&fe,&01,&00
defb &2,&21,&fe,&01,&00
defb 7,&00,&fe,&01,&00,&00,0,0,&41,2
defb &fe,&00

p_recal_same:
call check_multi_drives
ret z

call do_motor_on

ld ix,result_buffer

di
call go_to_0
call swap_drive
call go_to_0
call swap_drive

ld a,39
call go_to_track
call swap_drive
ld a,39
call go_to_track
call swap_drive
;;call fdc_read_main_status_register
;;ld (ix+0),a
;;inc ix
;;inc ix

call send_recalibrate
call swap_drive
call send_recalibrate
call swap_drive

call wait_fdd_interrupt
call get_results
call sis_with_results

call read_id_with_results
;;call swap_drive
;;call read_id
;;call get_results
;;call swap_drive
ei

ld ix,result_buffer
ld hl,res_p_recal_same
call copy_results

ld bc,14
;;ld bc,256
jp do_results

res_p_seek_diff:
defb &2,&21,&fe,&01,15
defb &2,&20,&fe,&01,39
defb 7,&00,&fe,&01,&00,&00,39,0,&41,2
defb &fe,&00


p_seek_diff:
call check_multi_drives
ret z

call do_motor_on

ld ix,result_buffer

di
call go_to_0
call swap_drive
call go_to_0
call swap_drive

ld a,39
call send_seek
call swap_drive
ld a,15
call send_seek
call swap_drive
;;call fdc_read_main_status_register
;;ld (ix+0),a
;;inc ix
;;inc ix

call wait_fdd_interrupt
call get_results
call wait_fdd_interrupt
call get_results

call read_id_with_results
;;call swap_drive
;;call read_id
;;call get_results
;;call swap_drive
ei

ld ix,result_buffer
ld hl,res_p_seek_diff
call copy_results

ld bc,14
;;ld ix,result_buffer
;;ld hl,res_drive2_drive_status
;;call copy_results
jp do_results



res_p_recal_diff:
defb &2,&20,&fe,&01,0
defb &2,&21,&fe,&01,0
defb 7,&00,&fe,&01,&00,&00,0,0,&41,2
defb &fe,&00

p_recal_diff:
call check_multi_drives
ret z

call do_motor_on

ld ix,result_buffer

di
call go_to_0
call swap_drive
;;ld ix,result_buffer
;;ld hl,res_drive2_drive_status
;;call copy_results
call go_to_0
call swap_drive

ld ix,result_buffer
ld a,15
call go_to_track
call swap_drive
ld a,39
call go_to_track
call swap_drive

call send_recalibrate
call swap_drive
call send_recalibrate
call swap_drive
;;call fdc_read_main_status_register
;;ld (ix+0),a
;;inc ix
;;inc ix

call wait_fdd_interrupt
call get_results
call wait_fdd_interrupt
call get_results

call read_id_with_results
;;call swap_drive
;;call read_id
;;call get_results
;;call swap_drive
ei

ld ix,result_buffer
ld hl,res_p_recal_diff
call copy_results

ld bc,14
jp do_results

res_p_seek_wait_diff:
defb &2,&21,&fe,&01,15
defb &2,&20,&fe,&01,39
defb 7,&00,&fe,&01,&00,&00,39,0,&41,2
defb &fe,&00


p_seek_wait_diff:
call check_multi_drives
ret z

call do_motor_on

ld ix,result_buffer

di
call go_to_0
call swap_drive
call go_to_0
call swap_drive

ld a,39
call send_seek
call swap_drive
ld a,15
call send_seek
call swap_drive
;;call fdc_read_main_status_register
;;ld (ix+0),a
;;inc ix
;;inc ix
call big_wait
call big_wait
call big_wait
call big_wait

call sis_with_results
call sis_with_results

call read_id_with_results
;;call swap_drive
;;call read_id
;;call get_results
;;call swap_drive
ei

ld ix,result_buffer
ld hl,res_p_seek_wait_diff
call copy_results

ld bc,14
;;ld ix,result_buffer
;;ld hl,res_drive2_drive_status
;;call copy_results
jp do_results

;; RETEST!
res_seek_two_drives:
defb &2,&22,&fe,&01,&18
defb &1,&80			;; indicates drive hasn't finished seeking
defb &07,&00,&fe,&01,&00,&00,&13,&00,&41,&2
defb &07,&02,&fe,&01,&00,&00,&13,&00,&41,&2
defb &fe,&00

u8272_res_seek_two_drives:
defb &2,&22,&fe,&01,&18
defb &1,&80			;; indicates drive hasn't finished seeking
defb &07,&40,&fe,&01,&00,&00,&15,&00,&41,&2	
defb &07,&42,&fe,&01,&00,&00,&15,&00,&41,&2	
defb &fe,&00



seek_two_drives:
call check_two_drives
ret nz

di
call go_to_0			;; 0
call swap_same_drive 
call go_to_0			;; 2
call swap_same_drive

ld a,20				;; 0
call go_to_track
call swap_same_drive
ld a,20				;; 2
call go_to_track
call swap_same_drive


ld ix,result_buffer

ld a,20-5
call send_seek			;; 0
call swap_same_drive ;; 
ld a,20+4		;; 2
call send_seek
call swap_same_drive


call wait_fdd_interrupt
call get_results
call sis_with_results

call read_id			;; 0
call get_results
call swap_same_drive
call read_id			;; 2
call get_results
call swap_same_drive
ei

ld ix,result_buffer
ld a,(fdc_model)
ld hl,u8272_res_seek_two_drives
cp fdc_model_um8272
jr z,std2
ld hl,res_seek_two_drives
std2:
call copy_results

ld bc,21
jp do_results

res_seek3_two_drives:
defb &2,&22,&fe,&01,&27
defb &2,&20,&fe,&01,&00
defb &07,&00,&fe,&01,&00,&00,&13,&00,&41,&2
defb &07,&02,&fe,&01,&00,&00,&13,&00,&41,&2
defb &fe,&00

u8272_res_seek3_two_drives:
defb &2,&22,&fe,&01,&18		;; 25+5
defb &2,&20,&fe,&01,&0f
defb &07,&40,&fe,&01,&00,&00,&15,&00,&41,&2 
defb &07,&42,&fe,&01,&00,&00,&15,&00,&41,&2
defb &fe,&00

d765a_res_seek3_two_drives:
defb &2,&22,&fe,&01,&18		;; 25+5
defb &2,&20,&fe,&01,&0f
defb &07,&00,&fe,&01,&00,&00,&13,&00,&41,&2 
defb &07,&02,&fe,&01,&00,&00,&13,&00,&41,&2
defb &fe,&00


seek3_two_drives:
call check_two_drives
ret nz

di
call go_to_0			;; 0
call swap_same_drive 
call go_to_0			;; 2
call swap_same_drive

ld a,20				;; 0
call go_to_track
call swap_same_drive
ld a,20				;; 2
call go_to_track
call swap_same_drive


ld ix,result_buffer

;; 20->0 is 20 tracks
;; 20->39 is 19 tracks
ld a,20-5
call send_seek			;; 0
call swap_same_drive ;; 
ld a,20+4			;; 2
call send_seek
call swap_same_drive


call wait_fdd_interrupt
call get_results
call wait_fdd_interrupt
call get_results

call read_id			;; 0
call get_results
call swap_same_drive
call read_id			;; 2
call get_results
call swap_same_drive
ei

ld ix,result_buffer
ld a,(fdc_model)
ld hl,u8272_res_seek3_two_drives
cp fdc_model_um8272
jr z,std22
ld hl,d765a_res_seek3_two_drives
cp fdc_model_d765ac2
jr z,std22
ld hl,res_seek3_two_drives
std22:

call copy_results

ld bc,22
jp do_results

res_seek2_two_drives:
defb &2,&20,&fe,&01,&0a
defb &2,&22,&fe,&01,&0a
defb &07,00,&fe,&01,00,00,&0a,00,&41,02
defb &07,02,&fe,&01,00,00,&0a,00,&41,02
defb &fe,&00


u8272_res_seek2_two_drives:
defb &2,&20,&fe,&01,&0a
defb &2,&22,&fe,&01,&0a
defb &07,00,&fe,&01,00,00,&15,00,&41,02
defb &07,02,&fe,&01,00,00,&15,00,&41,02
defb &fe,&00

d765a_res_seek2_two_drives:
defb &2,&20,&fe,&01,&05
defb &2,&22,&fe,&01,&05
defb &07,00,&fe,&01,00,00,&5,00,&41,02
defb &07,02,&fe,&01,00,00,&5,00,&41,02
defb &fe,&00


seek2_two_drives:
call check_two_drives
ret nz

di
call go_to_0			;; 0
call swap_same_drive
call go_to_0			;; 2
call swap_same_drive

ld a,20				;; 0
call go_to_track
call swap_same_drive
ld a,20				;; 2
call go_to_track
call swap_same_drive

ld ix,result_buffer

ld a,5			;	;; 0
call send_seek
call swap_same_drive
ld a,5				;; 2
call send_seek
call swap_same_drive

call wait_fdd_interrupt
call get_results
call sis_with_results

call read_id_with_results			;; 0
call swap_same_drive
call read_id_with_results			;; 2
call swap_same_drive
ei

ld ix,result_buffer
ld a,(fdc_model)
ld hl,u8272_res_seek2_two_drives
cp fdc_model_um8272
jr z,std23
ld hl,d765a_res_seek2_two_drives
cp fdc_model_d765ac2
jr z,std23
ld hl,res_seek2_two_drives
std23:
call copy_results

ld bc,22
jp do_results


sense2_drive_status:
call check_two_drives
ret nz
call check_ready_ok
ret nz

ld ix,result_buffer
di
call clear_fdd_interrupts

call do_motor_off

call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results

call sense_drive_status		;; 0
call get_results
call swap_same_drive

call sense_drive_status		;; 2
call get_results
call swap_same_drive

call do_motor_on

call sis_with_results
call sis_with_results
call sis_with_results
call sis_with_results

call sense_drive_status		;; 0
call get_results
call swap_same_drive

call sense_drive_status		;; 2
call get_results
call swap_same_drive

ei
;;ld ix,result_buffer
;;ld hl,res_drive2_drive_status
;;call copy_results

ld bc,256
jp do_results

res_specify_srt:
defw &c5
defw &b8
defw &ac
defw &a0
defw &94
defw &87
defw &7b
defw &6e
defw &62
defw &56
defw &4a
defw &3e
defw &31
defw &25
defw &18
defw &0c
defb &fe,&00


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

ld ix,result_buffer
ld hl,res_specify_srt
call copy_results

ld bc,16*2
jp do_results

res_seek_ncn:
defb &02,&20,&fe,&02,&00
defb &00
defb &02,&20,&fe,&02,&01
defb &01
defb &02,&20,&fe,&02,&02
defb &02
defb &02,&20,&fe,&02,&03
defb &03
defb &02,&20,&fe,&02,&04
defb &04
defb &02,&20,&fe,&02,&05
defb &05
defb &02,&20,&fe,&02,&06
defb &06
defb &02,&20,&fe,&02,&07
defb &07
defb &02,&20,&fe,&02,&08
defb &08
defb &02,&20,&fe,&02,&09
defb &09
defb &02,&20,&fe,&02,&0a
defb &0a
defb &02,&20,&fe,&02,&0b
defb &0b
defb &02,&20,&fe,&02,&0c
defb &0c
defb &02,&20,&fe,&02,&0d
defb &0d
defb &02,&20,&fe,&02,&0e
defb &0e
defb &02,&20,&fe,&02,&0f
defb &0f
defb &02,&20,&fe,&02,&10
defb &10
defb &02,&20,&fe,&02,&11
defb &11
defb &02,&20,&fe,&02,&12
defb &12
defb &02,&20,&fe,&02,&13
defb &13
defb &02,&20,&fe,&02,&14
defb &14
defb &02,&20,&fe,&02,&15
defb &15
defb &02,&20,&fe,&02,&16
defb &16
defb &02,&20,&fe,&02,&17
defb &17
defb &02,&20,&fe,&02,&18
defb &18
defb &02,&20,&fe,&02,&19
defb &19
defb &02,&20,&fe,&02,&1a
defb &1a
defb &02,&20,&fe,&02,&1b
defb &1b
defb &02,&20,&fe,&02,&1c
defb &1c
defb &02,&20,&fe,&02,&1d
defb &1d
defb &02,&20,&fe,&02,&1e
defb &1e
defb &02,&20,&fe,&02,&1f
defb &1f
defb &02,&20,&fe,&02,&20
defb &20
defb &02,&20,&fe,&02,&21
defb &21
defb &02,&20,&fe,&02,&22
defb &22
defb &02,&20,&fe,&02,&23
defb &23
defb &02,&20,&fe,&02,&24
defb &24
defb &02,&20,&fe,&02,&25
defb &25
defb &02,&20,&fe,&02,&26
defb &26
defb &02,&20,&fe,&02,&27
defb &27
defb &fe,&00

seek_ncn:
ld ix,result_buffer

ld b,40
ld c,0
sn1:
push bc

push bc
push bc
call go_to_0
pop bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc
di
ld a,c
call send_seek

call get_ready_change
call get_results

call read_id
ld a,(fdc_result_data+3)
ld (ix+0),a
inc ix
inc ix
ei

pop bc
inc c
djnz sn1

ld ix,result_buffer
ld hl,res_seek_ncn
call copy_results

ld bc,40*4
jp do_results



;;-------------------------------------------------------
res_seek_ss_side1:
res_seek_side1:
res_seek_dma:
defb &02,&20,&fe,&01,&27
defb &fe,&00

seek_side1:
call check_two_sides
ret z

call go_to_0

ld ix,result_buffer

call set_side1

di
ld a,39
call send_seek
call get_ready_change
call get_results
ei

ld ix,result_buffer
ld hl,res_seek_side1
call copy_results

ld bc,3
jp do_results

seek_ss_side1:
call check_one_sides
ret z

call go_to_0

ld ix,result_buffer

di
call set_side1

ld a,39
call send_seek
call get_ready_change
call get_results
ei

ld ix,result_buffer
ld hl,res_seek_ss_side1
call copy_results

ld bc,3
jp do_results

;;-------------------------------------------------------

res_seek_cmd:
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

seek_cmd:
ld ix,result_buffer
ld b,15
ld c,1
sc1:
push bc
push bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc

push ix
push bc
di
ld a,39
call go_to_track
call go_to_0
pop bc
pop ix

ld a,c
add a,a
add a,a
add a,a
add a,a
or %1111
ld c,a
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%11000000
inc ix
bit 6,a
jr z,sc2
;; do result phase for invalid
call fdc_result_phase
call get_results
jr sc3

sc2:
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

sc3:
ei
pop bc
inc c
djnz sc1
ld a,'-'
call output_char

ld ix,result_buffer
ld hl,res_seek_cmd
call copy_results

ld bc,3*15
jp do_results



res_seek_ec:
defb &02,&20,&fe,&01,70
defb &02,&20,&fe,&01,71
defb &02,&20,&fe,&01,72
defb &02,&20,&fe,&01,73
defb &02,&20,&fe,&01,74
defb &02,&20,&fe,&01,75
defb &02,&20,&fe,&01,76
defb &02,&20,&fe,&01,77
defb &02,&20,&fe,&01,78
defb &02,&20,&fe,&01,79
defb &02,&20,&fe,&01,80
defb &fe,&00

seek_ec:
call check_80t
ret z

call do_motor_on

ld ix,result_buffer

ld b,11
ld a,70
sst1a:
push bc
push af

push bc
push af
call outputdec
ld a,' '
call output_char
pop af
pop bc

push af
call move2track0
pop af

call send_seek

call get_ready_change

call get_results
pop af
inc a
pop bc
djnz sst1a
ld a,'-'
call output_char

ld ix,result_buffer
ld hl,res_seek_ec
call copy_results

;; 2 bytes sense interrupt status over 80 tracks
ld bc,3*10
jp do_results

;;-------------------------------------------------------

res_seek_nr:
defb &02,&68,&fe,&01,&00
defb &fe,&00

seek_nr:
call check_ready_ok
ret nz

ld ix,result_buffer

call go_to_0

call do_motor_off

ld a,39
call send_seek

call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_seek_nr
call copy_results

ld bc,3
jp do_results

res_seek_nr_st:
defb &02,&68,&fe,&01,&27
defb &fe,&00


seek_nr_st:
call check_ready_ok
ret nz

ld ix,result_buffer

ld a,39
call go_to_track

call do_motor_off

ld a,39
call send_seek

call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_seek_nr_st
call copy_results

ld bc,3
jp do_results


;;-------------------------------------------------------
;; seek with dma mode on
seek_dma:
ld ix,result_buffer

call go_to_0

call set_dma_mode

ld a,39
call send_seek
call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_seek_dma
call copy_results

ld bc,3
jp do_results

;;-------------------------------------------------------

res_seek_rc_same:
defb 2,&20,&fe,&02,&27
defb &fe,&00

res_seek_rc:
defb 2,&68,&fe,&02,&02
defb &fe,&00

seek_rc:
call check_ready_ok
ret nz

ld ix,result_buffer

call go_to_0

di
ld a,39
call send_seek

call short_wait
call stop_drive_motor

call get_ready_change
call get_results

call do_motor_on
call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_seek_rc
call copy_results

ld bc,3
jp do_results

;; does ready change overwrite seek finished?

res_seek_rc_after:
defb 2,&20,&fe,&02,&03	;; on plus..
;;defb 2,&c8,&fe,&02,&03		;; differs on type 2?
defb 7,&00,&fe,&02,&00,&00,&03,&00,&41,&02
defb &fe,&00

seek_rc_after:
call check_ready_ok
ret nz

ld ix,result_buffer

call go_to_0

di
ld a,3
call send_seek

call big_wait

call stop_drive_motor
call get_ready_change
call get_results

call do_motor_on
call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_seek_rc_after
call copy_results

ld bc,11
jp do_results


seek_rc_same:
call check_ready_ok
ret nz

ld ix,result_buffer

ld a,39
call go_to_track

di
ld a,39
call send_seek

call short_wait
call stop_drive_motor


call get_ready_change
call get_results
ei

ld ix,result_buffer
ld hl,res_seek_rc_same
call copy_results

ld bc,3
jp do_results

;;------------------------------------------------------------------------------
;; 
;; test if fdc busy flag is set after first command byte, and then cleared
;; when execution phase of seek has begun

seek_fdc_busy:
call go_to_0

ld ix,result_buffer

di
ld a,%1111						;; seek
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%10000
inc ix

ld a,(drive)					;; drive
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%10000
inc ix

ld a,39							;; destination track
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

call short_wait

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

call wait_for_seek_end

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix
ei

ld bc,5
jp do_results

;;----------------------------------------------------------
seek_same:
ld ix,result_buffer

di
ld a,16
call go_to_track

call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix


ld a,16
call send_seek

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call wait_for_seek_end

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ei

ld bc,3
jp do_results

;;---------------------------------------------------------------------------
res_seek_readid:
defb &00,&fe,&03
defb &90,&fe,&03
defb &10,&fe,&03
defb 7,0,&fe,&01,&00,&00,&02,&00,&41,&02
defb &fe,&00

seek_readid:
call go_to_0

ld ix,result_buffer

di
ld a,2
call send_seek

call big_wait

call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
inc ix

ld a,%01001010			;; read id
call send_command_byte

call msr_ready
call fdc_read_main_status_register
ld (ix+0),a
inc ix
inc ix

ld a,(drive)			;; drive
call send_command_byte

call msr_ready
call fdc_read_main_status_register
ld (ix+0),a
inc ix
inc ix
call fdc_result_phase	;; read result
call get_results
ei

ld ix,result_buffer
ld hl,res_seek_readid
call copy_results

ld bc,3+8
jp do_results

;;--------------------------------------------------
;; do a long seek, then attempt a read id immediatly

res_seek_test5:
defb 0,&fe,&03
defb &90,&fe,&03
defb &10,&fe,&03
defb 7,0,&fe,1,&00,&00,&02,&00,&41,&02
defb &fe,00

seek_test5:
call go_to_0

ld ix,result_buffer

di
ld a,29
call send_seek

call short_wait

call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
inc ix

ld a,%01001010			;; read id
call send_command_byte

call msr_ready
call fdc_read_main_status_register
ld (ix+0),a
inc ix
inc ix

ld a,(drive)
call send_command_byte

call msr_ready
call fdc_read_main_status_register
ld (ix+0),a
inc ix
inc ix


call fdc_result_phase	
call get_results
ei

ld ix,result_buffer
ld hl,res_seek_test5
call copy_results

ld bc,3+8
jp do_results

;;---------------------------------------------------------------------------
;; do a short seek and wait for it to complete
;;
;; test state of fdd busy state

seek_wait_busy:
call go_to_0

ld ix,result_buffer

di
ld a,2
call send_seek

call big_wait


call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call sense_interrupt_status
ei

ld bc,1
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
res_seek_mult:
defb 0,&fe,&03
defb 2,&20,&fe,&01,&00
defb &07,00,&fe,&01,00,0,0,00,&41,02
defb &fe,00

seek_mult:
call go_to_0

ld ix,result_buffer

di
ld a,39
call send_seek

call short_wait

call get_drive_busy_mask
ld e,a

;; should be busy
call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

;; now do another seek
ld a,0
call send_seek

call get_ready_change
call get_results


call do_motor_on
call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_seek_mult
call copy_results


ld bc,12
jp do_results



;;-------------------------------------------------------
res_recal_cmd:
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



recal_cmd:
ld ix,result_buffer
ld b,30
ld c,2	;; 1 would be seek, so start with 2
rc1:
push bc
push ix
push bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc
pop ix

push ix
push bc
call go_to_0
ld a,39
call go_to_track
pop bc
pop ix

ld a,c
add a,a
add a,a
add a,a
or %111
call send_command_byte

call get_drive_busy_mask
ld e,a

;; invalid?
call msr_ready
call fdc_read_main_status_register
and &c0
ld (ix+0),a
inc ix
ld (ix+0),%11000000 ;; result phase
inc ix
cp &c0
jr nz,rc2

;; do result phase for invalid
call fdc_result_phase
call get_results
jr rc3

rc2:
ld a,&ff
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix
ld a,&ff
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

call restore_fdc

rc3:
pop bc
inc c
djnz rc1

ld a,'-'
call output_char

ld ix,result_buffer
ld hl,res_recal_cmd
call copy_results


ld bc,30*3
jp do_results

res_recal_ec:
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&20,&fe,&1,0
defb &02,&70,&fe,&1,0
defb &02,&70,&fe,&1,0
defb &02,&70,&fe,&1,0
defb &fe,&00

recal_ec:
call check_80t
ret z

call do_motor_on

ld ix,result_buffer

ld b,11
ld a,70
rt1a:
push bc
push af

push bc
push af
call outputdec
ld a,' '
call output_char
pop af
pop bc

call move2track

call send_recalibrate

call get_ready_change

call get_results
pop af
inc a
pop bc
djnz rt1a
ld a,'-'
call output_char

ld ix,result_buffer
ld hl,res_recal_ec
call copy_results

;; 2 bytes sense interrupt status over 80 tracks
ld bc,3*10
jp do_results

res_recal_ss_side1:
res_recal_side1:
res_recal_dma:
res_recal_trk0:
defb &02,&20,&fe,&01,&00
defb &fe,&00

res_recal_drive_status:
defb &01,&20,&fe,&01
defb &02,&20,&fe,&01,&00
defb &fe,&00

recal_drive_status:
ld a,39
call go_to_track

ld ix,result_buffer

di
call send_recalibrate

call short_wait

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a

call get_ready_change

call get_results
ei

ld ix,result_buffer
ld hl,res_recal_drive_status
call copy_results

ld bc,5
jp do_results

res_seek_drive_status:
defb &01,&20,&fe,&01
defb &02,&20,&fe,&01,&27
defb &fe,&00


seek_drive_status:
call go_to_0

ld ix,result_buffer

di
ld a,39
call send_seek

call short_wait

call sense_drive_status
call get_results
ld a,(ix-2)
and %11110111
ld (ix-2),a


call get_ready_change

call get_results
ei

ld ix,result_buffer
ld hl,res_seek_drive_status
call copy_results

ld bc,5
jp do_results


recal_trk0:
call go_to_0

ld ix,result_buffer

call send_recalibrate

call get_ready_change

call get_results

ld ix,result_buffer
ld hl,res_recal_trk0
call copy_results

ld bc,3
jp do_results


;;-------------------------------------------------------
;; recalibrate with dma mode on
recal_dma:
ld ix,result_buffer

ld a,39
call go_to_track

call set_dma_mode

call send_recalibrate
call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_recal_dma
call copy_results

ld bc,3
jp do_results

;;-------------------------------------------------------

recal_side1:
call check_two_sides
ret z

ld ix,result_buffer

ld a,39
call go_to_track

call set_side1

call send_recalibrate
call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_recal_side1
call copy_results

ld bc,3
jp do_results

recal_ss_side1:
call check_one_sides
ret z

ld ix,result_buffer

ld a,39
call go_to_track

call set_side1

call send_recalibrate
call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_recal_ss_side1
call copy_results

ld bc,3
jp do_results


;;-------------------------------------------------------


recal_fdd_busy:
ld a,39
call go_to_track

ld ix,result_buffer
di

call get_drive_busy_mask
ld e,a

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld a,7
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

ld a,(drive)
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call short_wait

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

call wait_for_seek_end

call msr_ready
call fdc_read_main_status_register
and e
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix
ei

ld bc,5
jp do_results


;;------------------------------------------------------------------------------

recal_fdc_busy:
ld a,39
call go_to_track

ld ix,result_buffer

di
ld a,%111						;; recal
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%10000
inc ix

ld a,(drive)					;; drive
call send_command_byte

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

call short_wait

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

call wait_for_seek_end

call msr_ready
call fdc_read_main_status_register
and %10000
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix
ei

ld bc,4
jp do_results

;;-------------------------------------------------------
res_recal_nr:
res_recal_nr_trk0:
defb 2,&68,&fe,&01,&00
defb &fe,&00

res_recal_rc_trk0:
defb 2,&20,&fe,&01,&00
defb &07,00,&fe,&01,00,0,&0,00,&41,02
defb &fe,&00

res_recal_rc:
defb 2,&78,&fe,&01,&00
defb &07,00,&fe,&01,00,&00,&25,00,&41,02
defb &fe,&00

recal_nr:
call check_ready_ok
ret nz

ld ix,result_buffer

ld a,39
call go_to_track

call do_motor_off

call send_recalibrate
call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_recal_nr
call copy_results


ld bc,3
jp do_results

recal_nr_trk0:
call check_ready_ok
ret nz

ld ix,result_buffer

call go_to_0

call do_motor_off

call send_recalibrate
call get_ready_change
call get_results

ld ix,result_buffer
ld hl,res_recal_nr_trk0
call copy_results

ld bc,3
jp do_results


;;-------------------------------------------------------

recal_rc:
call check_ready_ok
ret nz

ld ix,result_buffer

di
ld a,39
call go_to_track

call send_recalibrate
call short_wait
call stop_drive_motor

call get_ready_change
call get_results

call do_motor_on
call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_recal_rc
call copy_results

ld bc,11
jp do_results

res_recal_rc_after:
defb &2,&20,&fe,&02,&00
defb &07,00,&fe,&01,00,&0,&00,00,&41,02
defb &fe,&00

recal_rc_after:
call check_ready_ok
ret nz

ld ix,result_buffer

di
ld a,3
call go_to_track

call send_recalibrate

call big_wait

call stop_drive_motor
call get_ready_change
call get_results


call do_motor_on
call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_recal_rc_after
call copy_results

ld bc,11
jp do_results


recal_rc_trk0:
call check_ready_ok
ret nz

ld ix,result_buffer

di
ld a,0
call go_to_track

call send_recalibrate
call short_wait
call stop_drive_motor

call get_ready_change
call get_results


call do_motor_on
call read_id_with_results
ei

ld ix,result_buffer
ld hl,res_recal_rc_trk0
call copy_results

ld bc,11
jp do_results


;;-----------------------------------------
test_disk_format_data:
defb 0
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 0,&0,&41,2

defb 1
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 1,&0,&41,2

defb 2
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 2,&0,&41,2

defb 3
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 3,&0,&41,2

defb 4
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 4,&0,&41,2

defb 5
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 5,&0,&41,2

defb 6
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 6,&0,&41,2

defb 7
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 7,&0,&41,2

defb 8
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 8,&0,&41,2

defb 9
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 9,&0,&41,2

defb 10
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 10,&0,&41,2


defb 11
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 11,&0,&41,2

defb 12
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 12,&0,&41,2

defb 13
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 13,&0,&41,2

defb 14
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 14,&0,&41,2

defb 15
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 15,&0,&41,2

defb 16
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 16,&0,&41,2

defb 17
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 17,&0,&41,2

defb 18
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 18,&0,&41,2

defb 19
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 19,&0,&41,2

defb 20
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 20,&0,&41,2

defb 21
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 21,&0,&41,2

defb 22
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 22,&0,&41,2

defb 23
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 23,&0,&41,2

defb 24
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 24,&0,&41,2

defb 25
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 25,&0,&41,2

defb 26
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 26,&0,&41,2

defb 27
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 27,&0,&41,2

defb 28
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 28,&0,&41,2

defb 29
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 29,&0,&41,2

defb 30
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 30,&0,&41,2

defb 31
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 31,&0,&41,2

defb 32
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 32,&0,&41,2

defb 33
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 33,&0,&41,2

defb 34
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 34,&0,&41,2

defb 35
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 35,&0,&41,2

defb 36
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 36,&0,&41,2

defb 37
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 37,&0,&41,2

defb 38
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 38,&0,&41,2

defb 39
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 39,&0,&41,2



defb -1

;; track, side, mfm,num ids, ids.
dd_test_disk_data:
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
include "../../lib/hw/cpc.asm"
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