;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; this test concentrates on read data and read deleted data

include "../../lib/testdef.asm"

if CPC=1
org &1000
endif
if SPEC=1
org &8000
endif

;; TODO: Fast ready gives 20,20 and shows overrun
;; Slow ready gives 
start:
;;---------------------------------------------------------------------------
;; Tested in these tests:
;; - read data/read deleted data
;;
;; See other tests for read id,read track, format, write etc
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
call choose_ready_type

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


choose_ready_type:
ld hl,which_ready_txt
call cls_msg
getchooseready:
call wait_key
cp '0'
jr c,getchooseready
cp '2'
jr nc,getchooseready
sub '1'
ld (ready_type),a
ret

ready_type:
defb 0

which_ready_txt:
defb "Choose ready->not ready speed type:",13
defb "1: Slow (e.g. 3inch drive)",13
defb "2: Fast (e.g. 3.5inch drive)",13
defb 0

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
defb "This test concentrates on read data and read deleted data.",13,13
defb "This test has been run on a real computer with a real drive. (Slow 3inch drive)",13,13
defb "Requirements:",13
defb "- disc is writeable (NOT write protected)",13
defb 0

;; TODO: it appears execution phase is not set immediately?
;; it is set when data is ready in execution phase of command??
tests:
DEFINE_TEST "read data x bytes and skip",read_and_skip
DEFINE_TEST "read data (execution phase)",d_exec
DEFINE_TEST "read deleted data (execution phase)",dd_exec

DEFINE_TEST "read data mt",d_mt

DEFINE_TEST "read data mt (ready change between sectors)",d_mt_i
;; done
DEFINE_TEST "read data (overrun - data)",d_ov_d
;; done
DEFINE_TEST "read data (overrun - deleted data)",d_ov_dd
;; done
DEFINE_TEST "read data (overrun - data error on data)",d_ov_de
;; done
DEFINE_TEST "read data (ready change between sectors)",d_rc
;; done
DEFINE_TEST "read data (ready change before first sector)",d_1st_rc

;; done
;; UNSTABLE; depends on if ready stops quickly or not
DEFINE_TEST "read data (ready change after 1st byte of sector)",d_1st_data_rc
;; done
DEFINE_TEST "read data (ready change during sector data)",d_data_rc

;; done
;; UNSTABLE; depends on if ready stops quickly or not
DEFINE_TEST "read data (ready change - data crc error on data)",d_rc_crc

;; done
DEFINE_TEST "read data (sector not found)",d_nf
;; done
DEFINE_TEST "read data (ready change - deleted data)",d_rc_dd

;; done
DEFINE_TEST "read data (side 1) (ds)",d_side1
;; done
DEFINE_TEST "read data (side 1) (ss)",d_ss_side1
;; done
DEFINE_TEST "read data (data error)",d_de


;; done
DEFINE_TEST "read data (not ready)",d_nr
;; done
;;DEFINE_TEST "read data (fm on fm)",d_fm
;; done
;;DEFINE_TEST "read data (fm on mfm)",d_fm_mfm
;; done
;;DEFINE_TEST "read data (mfm on fm)",d_mfm_fm
;; done 
;;DEFINE_TEST "read data (formatted unformatted)",d_unform

;; done
DEFINE_TEST "read data",d_norm

;; done
DEFINE_TEST "read data (bad cylinder/wrong cylinder - data)",d_bc

;; done
DEFINE_TEST "read data (bad cylinder/wrong cylinder - deleted data)",d_bc_dd

;; done
DEFINE_TEST "read data (R=EOT=ff)",d_ff

;; done
DEFINE_TEST "read data (eot)",d_eot
;; TEST
DEFINE_TEST "read data (no skip) ",d_no_sk
DEFINE_TEST "read data (skip) ",d_sk


DEFINE_TEST "read data (no polling status register)",d_no_poll

;;--
;; done
DEFINE_TEST "read deleted data (overrun - data)",dd_ov_d
;; done
DEFINE_TEST "read deleted data (overrun - deleted data)",dd_ov_dd
;; done
DEFINE_TEST "read deleted data (overrun - data error on data)",dd_ov_de
;; done
DEFINE_TEST "read deleted data (ready change between sectors)",dd_rc
;; done
DEFINE_TEST "read deleted data (ready change before first sector)",dd_1st_rc


;; done
;; UNSTABLE; depends on if ready stops quickly or not
DEFINE_TEST "read deleted data (ready change after 1st byte of sector)",dd_1st_data_rc
;; done
DEFINE_TEST "read deleted data (ready change during sector data)",dd_data_rc
;; done
;; UNSTABLE; depends on if ready stops quickly or not
DEFINE_TEST "read deleted data (ready change - data crc error)",dd_rc_crc
;; done
DEFINE_TEST "read deleted data (sector not found)",dd_nf
;; done
DEFINE_TEST "read deleted data (ready change - data)",dd_rc_d

;; done
DEFINE_TEST "read deleted data (side 1) (ds)",dd_side1
;; done
DEFINE_TEST "read deleted data (side 1) (ss)",dd_ss_side1
;; done
DEFINE_TEST "read deleted data (data error)",dd_de
;; done
DEFINE_TEST "read deleted data (not ready)",dd_nr
;; done
;;DEFINE_TEST "read deleted data (fm on fm)",dd_fm
;; done
;;DEFINE_TEST "read deleted data (fm on mfm)",dd_fm_mfm
;; done
;;DEFINE_TEST "read deleted data (mfm on fm)",dd_mfm_fm
;; done 
;;DEFINE_TEST "read deleted data (formatted unformatted)",dd_unform

;; done
DEFINE_TEST "read deleted data",dd_norm
;; done
DEFINE_TEST "read deleted data (bad cylinder/wrong cylinder - deleted data)",dd_bc
;; done
DEFINE_TEST "read deleted data (bad cylinder/wrong cylinder - data)",dd_bc_d

;; done
DEFINE_TEST "read deleted data (R=EOT=ff)",dd_ff
;; done
DEFINE_TEST "read deleted data (eot)",dd_eot
;; TEST
DEFINE_TEST "read deleted data (no skip) ",dd_no_sk
DEFINE_TEST "read deleted data (skip) ",dd_sk

DEFINE_TEST "read deleted data (no polling status register)",dd_no_poll

;;---

;; this causes problems for other commands...
DEFINE_TEST "read deleted data (msr bit 5) (dma)",dd_dma
DEFINE_TEST "read data (msr bit 5) (dma)",d_dma
DEFINE_TEST "read data (execution phase) (dma)",d_dma_exec
DEFINE_TEST "read deleted data (execution phase) (dma)",dd_dma_exec


;; HANG AND OLD
DEFINE_TEST "read data then sense int",read_data_sis


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


do_exec:
ld ix,result_buffer

call did_exec_happen
call fdc_result_phase
ei

ld ix,result_buffer
pop hl
call copy_results

ld bc,1
jp do_results

res_dd_exec:
res_d_exec:
defb &1
defb &fe,&00

res_dd_dma_exec:
res_d_dma_exec:
defb &0
defb &fe,&00


d_exec:
call go_to_0

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld hl,res_d_exec
di
push hl
call send_read_data
jr do_exec


dd_exec:
call go_to_0

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld hl,res_dd_exec
si
push hl
call send_read_deleted_data
jr do_exec

d_dma_exec:
call go_to_0

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call set_dma_mode
di
ld hl,res_d_dma_exec
push hl
call send_read_data
jp do_exec


dd_dma_exec:
call go_to_0

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call set_dma_mode

di
ld hl,res_dd_dma_exec
push hl
call send_read_deleted_data
jp do_exec


;; d765a
res_read_and_skip:
defb 6,&80,&00,&12,&0,&41,&2
defb 6,&80,&00,&12,&0,&41,&2
defb 6,&80,&00,&12,&0,&41,&2
defb 7,&40,&fe,&01,&80,&00,&12,&0,&41,&2
defb 7,&40,&fe,&01,&80,&00,&12,&0,&41,&2
defb &fe,&00

read_and_skip_count:
push de
call do_motor_on
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,18
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
pop de
ld hl,sector_buffer
call read_data_n1
ei
call fdc_result_phase
call get_results
call do_motor_off
ret

read_and_skip:
call go_to_0
ld a,18
call go_to_track
ld ix,result_buffer

ld de,1
call read_and_skip_count
ld de,100
call read_and_skip_count
ld de,256
call read_and_skip_count
ld de,512
call read_and_skip_count
ld de,1024
call read_and_skip_count


ld ix,result_buffer
ld hl,res_read_and_skip
call copy_results

ld bc,3*6+8*2
jp do_results

res_d_mt_chrn:
defw &200
defb 7,&0,&fe,&01,&0,&40,&f,&0,&41,&2
defw &400
defb 7,&40,&fe,&01,&80,&0,&10,&fe,&fe,&42,&2
defw &400
defb 7,&40,&fe,&01,&80,&0,&11,&ff,&42,&2
defw &400
defb 7,&44,&fe,&01,&80,&0,&f,&1,&2,&2
defw &400
defb 7,&44,&fe,&01,&80,&0,&10,&ff,&2,&2
defw &400
defb 7,&44,&fe,&01,&80,&0,&11,&fe,&fe,&2,&2
defb &fe,&00

res_dd_mt_chrn:
defb &fe,&00

mt_chrn:

defb 15
defb 0
defb 15,0,&41,2,&42

defb 16
defb 0
defb 16,&fe,&41,2,&42

defb 17
defb 0
defb 17,&ff,&41,2,&42

defb 15
defb 1
defb 15,1,&1,2,&2

defb 16
defb 1
defb 16,&ff,&1,2,&2

defb 17
defb 1
defb 17,&fe,&1,2,&2
end_mt_chrn:

num_mt_chrn equ (end_mt_chrn-mt_chrn)/7

d_mt:
call check_two_sides
ret z

ld hl,res_d_mt_chrn
ld iy,send_read_data
ld a,18
jr cm_mt

dd_mt:
call check_two_sides
ret z

ld hl,res_dd_mt_chrn
ld iy,send_read_deleted_data
ld a,18
jr cm_mt

cm_mt:
ld (results),hl


ld ix,result_buffer
ld hl,mt_chrn
ld b,num_mt_chrn
d_mt2:
push bc
ld a,(hl)
ld (track),a
inc hl
call set_side0
ld a,(hl)
or a
call nz,set_side1
inc hl
ld a,(hl)
ld (rw_c),a
inc hl
ld a,(hl)
ld (rw_h),a
inc hl
ld a,(hl)
ld (rw_r),a
inc hl
ld a,(hl)
ld (rw_n),a
inc hl
ld a,(hl)
ld (rw_eot),a
inc hl
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a


push hl
ld a,(track)
call go_to_track

call jpiy
call do_read_data_count
call get_results

pop hl
pop bc
djnz d_mt2


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,num_mt_chrn*10
jp do_results


res_d_mt_i:
defb 7,&40,&fe,&01,&20,&60,&f,&0,&41,&2
defb 7,&40,&fe,&01,&20,&20,&10,&fe,&fe,&41,&2
defb 7,&40,&fe,&01,&20,&20,&11,&ff,&41,&2
defb 7,&44,&fe,&01,&20,&20,&f,&1,&41,&2
defb 7,&44,&fe,&01,&20,&20,&10,&ff,&41,&2
defb 7,&44,&fe,&01,&20,&20,&11,&fe,&fe,&41,&2
defb &fe,&00


d_mt_i:
call check_two_sides
ret z
call check_ready_ok
ret nz
ld hl,res_d_mt_i
ld iy,send_read_data
ld a,18
jr cm_mt_i

dd_mt_i:
call check_two_sides
ret z
call check_ready_ok
ret nz
ld hl,res_d_mt_chrn
ld iy,send_read_deleted_data
ld a,18
jr cm_mt_i

cm_mt_i:
ld (results),hl


ld ix,result_buffer
ld hl,mt_chrn
ld b,num_mt_chrn
d_mt2_i:
push bc
ld a,(hl)
ld (track),a
inc hl
call set_side0
ld a,(hl)
or a
call nz,set_side1
inc hl
ld a,(hl)
ld (rw_c),a
inc hl
ld a,(hl)
ld (rw_h),a
inc hl
ld a,(hl)
ld (rw_r),a
inc hl
ld a,(hl)
ld (rw_n),a
inc hl
ld a,(hl)
ld (rw_eot),a
inc hl
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a


push hl
ld a,(track)
call go_to_track

di
call jpiy
ld de,3
call fdc_data_read_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results


pop hl
pop bc
djnz d_mt2_i


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,num_mt_chrn*10
jp do_results



res_d_no_poll:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

res_dd_no_poll:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00


d_no_poll:
ld hl,res_d_no_poll
ld iy,send_read_data
ld a,0
jr cm_no_poll

dd_no_poll:
ld hl,res_dd_no_poll
ld iy,send_read_deleted_data
ld a,1
jr cm_no_poll

cm_no_poll:
ld (results),hl
ld (track),a
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

di
call jpiy

ld de,sector_buffer
ld hl,512

rdnp1:
in a,(c)
jp p,rdnp1


;; this is required to ensure we do not miss out on some bytes sometimes
defs 5

;; this works perfectly and doesn't cause overrun
;; if the gap is wrong you either get:
;; 1. read never finishing
;; 2. overrun condition error
;; 3. some bytes missing
;; 4. result phase being data from sector
rdnp2:
inc c			;; [1]
in a,(c)		;; [4]
ld (de),a		;; [2]
dec c			;; [1]
inc de			;; [2] = [10]
defs 32-7-10

dec hl			;; [2]
ld a,h			;; [1]
or l			;; [1]
jp nz,rdnp2		;; [3] = [7]

call fdc_result_phase
call get_results
ei

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results

read_data_many_chrn:
defb 0,0,1,2
defb 0,0,2,2
defb 0,0,3,2

defb 1,0,1,2
defb 2,0,1,2
defb 3,0,1,2

defb 0,1,1,2
defb 0,2,1,2
defb 0,3,1,2

defb 0,0,1,1
defb 0,0,1,2
defb 0,0,1,3
end_read_data_many_chrn:

num_read_data_many_chrn equ (end_read_data_many_chrn-read_data_many_chrn)/4

read_data_many:
ld (results),hl

ld ix,result_buffer

ld (track_wanted),a
call go_to_track

ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld b,num_read_data_many_chrn
ld hl,read_data_many_chrn
rdm1:
push bc
ld a,(hl)
ld (rw_c),a
inc hl
ld a,(hl)
ld (rw_h),a
inc hl
ld a,(hl)
ld (rw_r),a
inc hl
ld a,(hl)
ld (rw_n),a
inc hl
push hl
call jpiy
call do_read_data_count
call get_results
pop hl
pop bc
djnz rdm1

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,num_read_data_many_chrn*10
jp do_results


;; 0,0,7,40,1,0,etc
;;---------------------------------------------------------------------------------

res_d_fm:
defb &fe,&00

res_dd_fm:
defb &fe,&00

d_fm:
ld iy,send_read_data

call set_fm
ld hl,res_d_fm

ld a,7
jp read_data_many

dd_fm:
ld iy,send_read_deleted_data

call set_fm
ld hl,res_dd_fm
ld a,8
jp read_data_many


res_d_fm_mfm:
defb &fe,&00


d_fm_mfm:
ld iy,send_read_data

call set_fm
ld hl,res_d_fm_mfm
ld a,0
jp read_data_many


res_dd_fm_mfm:
defb &fe,&00

dd_fm_mfm:
ld iy,send_read_deleted_data

call set_fm
ld hl,res_dd_fm_mfm
ld a,1
jp read_data_many


res_d_mfm_fm:
defb &fe,&00

d_mfm_fm:
ld iy,send_read_data
ld a,7
ld hl,res_d_mfm_fm

jp read_data_many


res_dd_mfm_fm:
defb &fe,&00

dd_mfm_fm:
ld iy,send_read_deleted_data
ld a,8
ld hl,res_dd_mfm_fm

jp read_data_many


res_d_norm:
defb %00010000
defb 0,2
defb 7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &fe,&00

res_dd_norm:
defb %00010000
defb 0,2
defb 7,&40,&fe,&02,&80,&00,&1,&00,&41,&02
defb &fe,&00

d_norm:
ld iy,send_read_data
ld a,0
ld hl,res_d_norm
jr cm_norm

dd_norm:
ld iy,send_read_deleted_data
ld a,1
ld hl,res_dd_norm
jr cm_norm

cm_norm:
ld (track),a
ld (results),hl
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy
call fdc_read_main_status_register
ld (ix+0),a
inc ix
inc ix
call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,11
jp do_results

;;---------------------------------------------------------------------------------

;; slow ready results show correct read
;; fast ready shows &20,&20 (data error)

res_d_rc:
defb 7,&48,&fe,&02,&00,&00,&03,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&43,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&44,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&45,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&46,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&47,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&48,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&03,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,&03,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


res_dd_rc:
defb 7,&48,&fe,&02,&00,&00,&04,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&43,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&44,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&45,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&46,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&47,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&48,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&04,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,&04,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

res_d_rc_dd:
defb 7,&40,&fe,&02,&10,&40,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


res_dd_rc_d:
defb 7,&40,&fe,&02,&10,&40,&0,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

d_rc_dd:
call check_ready_ok
ret nz
ld a,1
ld hl,res_d_rc_dd
ld iy,send_read_data
jr cm_rc_od

dd_rc_d:
call check_ready_ok
ret nz
ld a,0
ld hl,res_dd_rc_d
ld iy,send_read_deleted_data
jr cm_rc_od

;; motor off mid sector, data mark
cm_rc_od:
ld (track),a
ld (results),hl
ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

di
call jpiy
ld de,3
call fdc_data_read_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16
jp do_results

res_d_ov_d:
defb 7,&40,&fe,&02,&10,&00,&0,&00,&41,&02
defb &fe,&00

res_d_ov_dd:
defb 7,&40,&fe,&02,&10,&40,&1,&00,&41,&02
defb &fe,&00


res_dd_ov_d:
defb 7,&40,&fe,&02,&10,&40,&0,&00,&41,&02
defb &fe,&00

res_dd_ov_dd:
defb 7,&40,&fe,&02,&10,&40,&1,&00,&41,&02
defb &fe,&00


d_ov_d:
ld a,0
ld hl,res_d_ov_d
ld iy,send_read_data
jr cm_ov

d_ov_dd:
ld a,1
ld hl,res_d_ov_dd
ld iy,send_read_data
jr cm_ov


dd_ov_d:
ld a,0
ld hl,res_dd_ov_d
ld iy,send_read_deleted_data
jr cm_ov

dd_ov_dd:
ld a,1
ld hl,res_dd_ov_dd
ld iy,send_read_deleted_data
jr cm_ov

results:
defw 0

cm_ov:
ld (track),a
ld (results),hl
ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

di
call jpiy
ld de,3
call fdc_data_read_o
ei
call fdc_result_phase
call get_results

ld hl,(results)
ld ix,result_buffer
call copy_results

ld bc,8
jp do_results

jpiy:
push iy
ret

res_d_rc_crc:
defb 7,&40,&fe,&02,&20,&20,2,&00,&41,&03
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


res_dd_rc_crc:
defb 7,&40,&fe,&02,&20,&20,2,&00,&41,&03
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

d_rc_crc:
call check_ready_ok
ret nz
ld a,2
ld hl,res_d_rc_crc
ld iy,send_read_data
jr cm_rc_crc

dd_rc_crc:
call check_ready_ok
ret nz
ld a,2
ld hl,res_dd_rc_crc
ld iy,send_read_deleted_data
jr cm_rc_crc


cm_rc_crc:
ld (track),a
ld (results),hl
ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,3
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

di
call jpiy
ld de,3
call fdc_data_read_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16
jp do_results

res_d_ov_de:
defb 7,&40,&fe,&02,&20,&20,2,&00,&41,&03
defb &fe,&00

res_dd_ov_de:
defb 7,&40,&fe,&02,&20,&20,2,&00,&41,&03
defb &fe,&00

d_ov_de:
ld a,2
ld hl,res_d_ov_de
ld iy,send_read_data
jr cm_ov_de

dd_ov_de:
ld a,2
ld hl,res_dd_ov_de
ld iy,send_read_deleted_data
jr cm_ov_de

cm_ov_de:
ld (results),hl
ld (track),a
ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,3
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

di
call jpiy
ld de,3
call fdc_data_read_o
ei
call fdc_result_phase
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16
jp do_results



sense_all_drives:
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
call sense_interrupt_status
call get_results
ret

d_rc:
call check_ready_ok
ret nz
ld a,3
ld iy,send_read_data
ld hl,res_d_rc
jr cm_rc

dd_rc:
call check_ready_ok
ret nz
ld a,4
ld iy,send_read_deleted_data
ld hl,res_d_rc
jr cm_rc

cm_rc:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld a,&49
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld b,9
ld hl,512
rdrc: 
push bc
push hl
ld a,b
call outputdec
ld a,' '
call output_char

push hl
call do_motor_on

di
call jpiy
pop de
call fdc_data_read_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives

pop hl
ld de,512
add hl,de
pop bc
djnz rdrc


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,9*16
jp do_results

res_d_1st_rc:
defb 7,&48,&fe,&02,&00,&00,3,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


res_dd_1st_rc:
defb 7,&48,&fe,&02,&00,&00,4,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

d_1st_rc:
call check_ready_ok
ret nz
ld a,3
ld iy,send_read_data
ld hl,res_d_1st_rc
jr cm_1st_rc

dd_1st_rc:
call check_ready_ok
ret nz
ld a,4
ld iy,send_read_deleted_data
ld hl,res_dd_1st_rc
jr cm_1st_rc

cm_1st_rc:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call read_data

ld a,&42
ld (rw_r),a
ld (rw_eot),a

di
call jpiy
defs 128
call stop_drive_motor
call fdc_result_phase
ei
call get_results

call sense_all_drives

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16
jp do_results

res_d_data_rc:
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


res_dd_data_rc:
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


d_data_rc:
call check_ready_ok
ret nz

ld a,0
ld hl,res_d_data_rc
ld iy,send_read_data
jr cm_data_rc

dd_data_rc:
call check_ready_ok
ret nz

ld a,1
ld hl,res_dd_data_rc
ld iy,send_read_deleted_data
jr cm_data_rc


cm_data_rc:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld b,16
ld hl,512-16
rdr2c: 
push bc
push hl
ld a,b
call outputdec
ld a,' '
call output_char

push hl
call do_motor_on

di
call jpiy
pop de
call fdc_data_read_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives

pop hl
inc hl
pop bc
djnz rdr2c


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16*16
jp do_results



res_d_1st_data_rc:
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00


res_dd_1st_data_rc:
defb 7,&40,&fe,&02,&10,&00,&1,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

d_1st_data_rc:
ld a,0
ld hl,res_d_1st_data_rc
ld iy,send_read_data
jr cm_1st_data_rc

dd_1st_data_rc:
ld a,1
ld hl,res_dd_1st_data_rc
ld iy,send_read_deleted_data
jr cm_1st_data_rc


cm_1st_data_rc:
ld (track),a
ld (results),hl
call check_ready_ok
ret nz

ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call do_motor_on

di
call jpiy
ld de,1
call fdc_data_read_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16*16
jp do_results

res_d_nf:
defw &0
defb &7,&40,&fe,&01,&04,&00,&3,&00,&40,2
defb &fe,&00

res_dd_nf:
defw &0
defb &7,&40,&fe,&01,&04,&00,&4,&00,&40,2
defb &fe,&00

d_nf:
ld a,3
ld hl,res_d_nf
ld iy,send_read_data
jr cm_nf

dd_nf:
ld a,4
ld hl,res_dd_nf
ld iy,send_read_deleted_data
jr cm_nf


cm_nf:
ld (track),a
ld (results),hl
ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&40
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy
call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results

cm_ff_data:
defb &fd,&ff
defb &ff,&ff
defb &fd,&00
defb &ff,&00
end_cm_ff_data:

cm_ff_data_num equ (end_cm_ff_data-cm_ff_data)/2

res_d_ff:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

res_dd_ff:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

d_ff:
ld hl,res_d_ff
ld iy,send_read_data
ld a,12
jr cm_ff

dd_ff:
ld hl,res_dd_ff
ld iy,send_read_deleted_data
ld a,13
jr cm_ff

cm_ff:
ld (track),a
call go_to_track

ld ix,result_buffer

ld hl,cm_ff_data
ld b,cm_ff_data_num
cm_ff2:
push bc

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,(hl)
ld (rw_r),a
inc hl
ld a,(hl)
ld (rw_eot),a
inc hl
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
push hl

call jpiy
call do_read_data_count
call get_results
pop hl
pop bc
djnz cm_ff2

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,11
jp do_results


cm_eot_data:
defb &41,&41	;; single
defb &41,&49	;; multiple
defb &40,&49	;; missing before
defb &41,&4a	;; missing after
defb &43,&47	;; middle
defb &49,&49	;; last
defb &4a,&4a	;; after last
defb &40,&40	;; before first
defb &43,&41	;; reversed
end_cm_eot_data:

cm_eot_data_num equ (end_cm_eot_data-cm_eot_data)/2

res_d_eot:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

res_dd_eot:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

d_eot:
ld hl,res_d_eot
ld iy,send_read_data
ld a,3
jr cm_eot

dd_eot:
ld hl,res_dd_eot
ld iy,send_read_deleted_data
ld a,4
jr cm_eot

cm_eot:
ld (track),a
call go_to_track

ld ix,result_buffer

ld hl,cm_eot_data
ld b,cm_eot_data_num
cm_eot2:
push bc

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,(hl)
ld (rw_r),a
inc hl
ld a,(hl)
ld (rw_eot),a
inc hl
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
push hl

call jpiy
call do_read_data_count
call get_results
pop hl
pop bc
djnz cm_eot2

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,cm_eot_data_num*10
jp do_results


cm_sk_data:
defb &41,&41	;; data	
defb &42,&42	;; deleted data
defb &41,&43	;; data,deleted data,data
defb &41,&49	;; data,deleted data, data, deleted data etc	
defb &45,&47	;; deleted data all
end_cm_sk_data:

cm_sk_data_num equ (end_cm_sk_data-cm_sk_data)/2

res_d_sk:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

res_dd_sk:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00


res_d_no_sk:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

res_dd_no_sk:
defw &200
defb 7,&40,&fe,&02,&80,&00,23,&00,&ff,&02
defb &fe,&00

d_sk:
call set_skip
ld hl,res_d_sk
ld iy,send_read_data
ld a,14
jr cm_sk

dd_sk:
call set_skip
ld hl,res_dd_sk
ld iy,send_read_deleted_data
ld a,14
jr cm_sk


d_no_sk:
call clear_skip
ld hl,res_d_no_sk
ld iy,send_read_data
ld a,14
jr cm_sk

dd_no_sk:
call clear_skip
ld hl,res_dd_no_sk
ld iy,send_read_deleted_data
ld a,14
jr cm_sk

cm_sk:
ld (track),a
call go_to_track

ld ix,result_buffer

ld hl,cm_sk_data
ld b,cm_sk_data_num
cm_sk2:
push bc

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,(hl)
ld (rw_r),a
inc hl
ld a,(hl)
ld (rw_eot),a
inc hl
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
push hl

call jpiy
call do_read_data_count
call get_results
pop hl
pop bc
djnz cm_sk2

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,cm_sk_data_num*10
jp do_results


res_d_dma:
defb 0,0
defb 7,&40,&fe,&02,&20,&20,&00,&00,&41,&02
defb &fe,&00


dack5v_res_d_dma:
defb 0,0
defb 7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &fe,&00

d_dma:
ld iy,send_read_data
ld a,(dack_mode)
or a
ld hl,res_d_dma
jr z,rddres
ld hl,dack5v_res_d_dma
rddres:
ld a,0


jr cm_dma

dd_dma:
ld iy,send_read_deleted_data
ld a,(dack_mode)
or a
ld hl,res_d_dma
jr z,rddres2
ld hl,dack5v_res_d_dma
rddres2:
ld a,0
jr cm_dma

cm_dma:
ld (track),a
ld (results),hl
call go_to_track

call set_dma_mode

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy


call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results
ld bc,10
jp do_results

if 0
res_d_dma2:
defb 0,2
defb 7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &fe,&00

read_data_dma2:
ld a,0
call go_to_track

call set_dma_mode

ld ix,result_buffer

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

di
call send_read_data
ld de,512
call fdc_dma_read_data
ei
call fdc_result_data
call get_results

ld ix,result_buffer
ld hl,res_d_dma2
call copy_results

ld bc,10
jp do_results
endif

res_d_side1:
defb 0,2
defb 7,&40,&fe,&02,&80,&00,&5,&01,&41,&02
defb &fe,&00

d_side1:
call check_two_sides
ret z

ld iy,send_read_data
ld a,5
ld hl,res_d_side1
jr cm_side1


res_dd_side1:
defb 0,2
defb 7,&40,&fe,&02,&80,&00,&6,&01,&41,&02
defb &fe,&00

dd_side1:
call check_two_sides
ret z

ld iy,send_read_deleted_data
ld a,6
ld hl,res_dd_side1
jr cm_side1

cm_side1:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

call set_side1

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
ld a,1
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy

call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results

res_d_ss_side1:
defw &200
defb &7,&44,&fe,&02,&80,0,5,0,&41,2 ;; um8272 sets end of cylinder
defb &fe,&00


res_dd_ss_side1:
defw &200
defb &7,&44,&fe,&02,&80,0,6,0,&41,2 ;; um8272 sets end of cylinder
defb &fe,&00

d_ss_side1:
call check_one_sides
ret z

ld a,5
ld iy,send_read_data
ld hl,res_d_ss_side1
jr cm_ss_side1

dd_ss_side1:
call check_one_sides
ret z

ld a,6
ld iy,send_read_deleted_data
ld hl,res_dd_ss_side1
jr cm_ss_side1

cm_ss_side1:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

call set_side1

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
ld a,0
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy

call do_read_data_count
call get_results


ld ix,result_buffer
ld hl,(results)
call copy_results
ld bc,10
jp do_results



read_data_sis:
ld a,11
call go_to_track

ld ix,result_buffer

ld a,11
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call send_read_data

call do_read_data_count
call get_results

call sense_interrupt_status
call get_results

ld bc,9

jp do_results

read_dtl_data:
ld a,11
call go_to_track

ld ix,result_buffer

ld a,11
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&4b
ld (rw_dtl),a

call send_read_data

call do_read_data_count
call get_results

ld bc,9
jp do_results


res_d_de:
defb &00,&04
defb &07,&40,&fe,&02,&20,&20,2,0,&1,&3
defb &fe,&00

res_dd_de:
defb &00,&04
defb &07,&40,&fe,&02,&20,&20,2,0,&1,&3
defb &fe,&00

d_de:
ld a,2
ld hl,res_d_de
ld iy,send_read_data
jr cm_de

dd_de:
ld a,2
ld hl,res_dd_de
ld iy,send_read_deleted_data
jr cm_de

cm_de:
ld (track),a
ld (results),hl
call go_to_track

ld ix,result_buffer

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&1
ld (rw_r),a
ld (rw_eot),a
ld a,3
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy
call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results

res_d_nr:
defb &00,&00
defb &07,&48,&fe,&02,&00,&00,&00,&00,&41,&2
defb &fe,&00


res_dd_nr:
defb &00,&00
defb &07,&48,&fe,&02,&00,&00,&1,&00,&41,&2
defb &fe,&00

d_nr:
call check_ready_ok
ret nz
ld a,0
ld hl,res_d_nr
ld iy,send_read_data
jr cm_nr

dd_nr:
call check_ready_ok
ret nz
ld a,1
ld hl,res_dd_nr
ld iy,send_read_deleted_data
jr cm_nr

cm_nr:
ld (track),a
ld (results),hl
call check_ready_ok
ret nz

ld ix,result_buffer

ld a,(track)
call go_to_track
call do_motor_off

ld a,(track)
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy

call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results


read_dd_data:
ld h,21
ld l,0
jr readi_dd_data

read_dda_data:
ld h,20
ld l,0
jr readi_dd_data

read_dd_sk_data:
ld h,21
ld l,1
jr readi_dd_data

read_dda_sk_data:
ld h,20
ld l,1
jr readi_dd_data

readi_dd_data:
push hl

ld a,h
ld (track),a
ld (rw_c),a
call go_to_track
pop hl
ld a,l
call nz,set_skip

ld ix,result_buffer

ld b,9+8+7+6+5+4+3+2+1
ld d,1
ld e,1
rdd:
push de
push bc

push de
push bc
ld a,b
dec a
call outputdec
ld a,' '
call output_char
pop bc
pop de

xor a
ld (rw_h),a
ld a,d
ld (rw_r),a
ld a,e
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call send_read_data

call do_read_data_count
call get_results

pop bc
pop de
ld a,e
inc a
ld e,a
cp 9
jr nz,rdd2
inc d
ld e,d
rdd2:
djnz rdd

ld bc,8*45
jp do_results



;;;;


read_data_dd:
ld h,21
ld l,0
jr readi_dddd_data

read_data_dda:
ld h,20
ld l,0
jr readi_dddd_data


read_data_sk_dd:
ld h,21
ld l,1
jr readi_dddd_data

read_data_sk_dda:
ld h,20
ld l,1
jr readi_dddd_data

readi_dddd_data:
push hl

ld a,h
ld (track),a
ld (rw_c),a
call go_to_track
pop hl
ld a,l
call nz,set_skip

ld ix,result_buffer

ld b,9+8+7+6+5+4+3+2+1
ld d,1
ld e,1
rdddd:
push de
push bc

push de
push bc
ld a,b
dec a
call outputdec
ld a,' '
call output_char
pop bc
pop de

xor a
ld (rw_h),a
ld a,d
ld (rw_r),a
ld a,e
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call send_read_deleted_data

call do_read_data_count
call get_results

pop bc
pop de
ld a,e
inc a
ld e,a
cp 9
jr nz,rdddd2
inc d
ld e,d
rdddd2:
djnz rdddd

ld bc,8*45
jp do_results


res_d2_eot:
defb &00,&12
defb 7,&40,&fe,&02,&80,&00,23,0,&2,&2
defb &fe,&00

read_data2_eot:
ld a,23
call go_to_track

ld ix,result_buffer

ld a,23
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&fa
ld (rw_r),a
ld a,&02
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call send_read_data

call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,res_d2_eot
call copy_results

ld bc,8+2
jp do_results

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


res_d_bc:
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,1,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,3
defw 0
defb 7,&40,&fe,&02,&4,&2,&1d,0,1,2
defw &200
defb 7,&40,&fe,&02,&80,0,&ff,0,1,2
defb &fe,&00



res_d_bc_dd:
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,1,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,3
defw 0
defb 7,&40,&fe,&02,&4,&2,&1d,0,1,2
defw &200
defb 7,&40,&fe,&02,&80,0,&ff,0,1,2
defb &fe,&00

res_dd_bc:
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,1,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,3
defw 0
defb 7,&40,&fe,&02,&4,&2,&1d,0,1,2
defw &200
defb 7,&40,&fe,&02,&80,0,&ff,0,1,2
defb &fe,&00



res_dd_bc_d:
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,1,1,2
defw 0
defb 7,&40,&fe,&02,&4,&2,&1e,0,1,3
defw 0
defb 7,&40,&fe,&02,&4,&2,&1d,0,1,2
defw &200
defb 7,&40,&fe,&02,&80,0,&ff,0,1,2
defb &fe,&00

d_bc:
ld a,10
ld hl,res_d_bc
ld iy,send_read_data
jr cm_bc

d_bc_dd:
ld a,11
ld hl,res_d_bc_dd
ld iy,send_read_data
jr cm_bc

dd_bc:
ld a,11
ld hl,res_dd_bc
ld iy,send_read_deleted_data
jr cm_bc


dd_bc_d:
ld a,10
ld hl,res_dd_bc_d
ld iy,send_read_deleted_data
jr cm_bc

cm_bc_chrn:
defb &ff,0,1,2
defb &ff,1,1,2
defb &ff,1,1,3
defb &fe,0,1,2
			
defb 10,0,2,2
defb 10,1,2,2
defb 10,1,2,3
defb 11,1,2,3
end_cm_bc_chrn:

cm_bc_count equ ((end_cm_bc_chrn-cm_bc_chrn)/4)

cm_bc:
ld (track),a
call go_to_track

ld ix,result_buffer
ld b,cm_bc_count
ld hl,cm_bc_chrn
cm_bc2:
push bc
ld a,(hl)
ld (rw_c),a
inc hl
ld a,(hl)
ld (rw_h),a
inc hl
ld a,(hl)
ld (rw_r),a
ld (rw_eot),a
inc hl
ld a,(hl)
ld (rw_n),a
inc hl
push hl
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
call jpiy
call do_read_data_count
call get_results
pop hl
pop bc
djnz cm_bc2

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,cm_bc_count*10
jp do_results

track_wanted:
defb 0

res_d_unform:
defb &fe,&00

res_dd_unform:
defb &fe,&00

d_unform:
ld a,9
ld iy,send_read_data
ld hl,res_d_unform
jp read_data_many

dd_unform:
ld a,9
ld iy,send_read_deleted_data
ld hl,res_dd_unform
jp read_data_many


;;-----------------------------------------
test_disk_format_data:
;; data
defb 0
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 0,&0,&41,2

;; deleted data
defb 1
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 1,&0,&41,2

;; data error 
defb 2
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 2,&0,&41,3

;; data ready change between sectors
defb 3
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 3,&0,&41,2
defb 3,&0,&42,2
defb 3,&0,&43,2
defb 3,&0,&44,2
defb 3,&0,&45,2
defb 3,&0,&46,2
defb 3,&0,&47,2
defb 3,&0,&48,2
defb 3,&0,&49,2

;; deleted data ready change between sectors
defb 4
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 4,&0,&41,2
defb 4,&0,&42,2
defb 4,&0,&43,2
defb 4,&0,&44,2
defb 4,&0,&45,2
defb 4,&0,&46,2
defb 4,&0,&47,2
defb 4,&0,&48,2
defb 4,&0,&49,2

;; two sided
defb 5
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 5,&0,&41,2

;; side 2
defb 5
defb 1	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 5,&1,&41,2


defb 6
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 6,&0,&41,2

;; side 2
defb 6
defb 1	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 6,&1,&41,2


defb 7
defb 0	
defb %00000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 7,&0,&41,2

defb 8
defb 0	
defb %00000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 8,&0,&41,2


defb 9
defb 0	
defb %01000000

defb 7
defb 1
defb def_format_gap
defb def_format_filler
defb 9,&0,&41,2


;;-----------------------------------------
defb 10
defb 0
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb &ff,0,1,2			;; bad cylinder
defb 10,0,2,2

;;-----------------------------------------
defb 11
defb 0
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb &ff,0,1,2
defb 10,0,1,2


;;--------------------------------
defb 12
defb 0	
defb %01000000

defb 2
defb 4
defb def_format_gap
defb def_format_filler
defb 12,&0,&fd,2
defb 12,&0,&fe,2
defb 12,&0,&ff,2
defb 12,&0,&00,2


;;--------------------------------
defb 13
defb 0	
defb %01000000

defb 2
defb 4
defb def_format_gap
defb def_format_filler
defb 13,&0,&fd,2
defb 13,&0,&fe,2
defb 13,&0,&ff,2
defb 13,&0,&00,2


;;--------------------------------
defb 14
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 14,&0,&41,2
defb 14,&0,&42,2
defb 14,&0,&43,2
defb 14,&0,&44,2
defb 14,&0,&45,2
defb 14,&0,&46,2
defb 14,&0,&47,2
defb 14,&0,&48,2
defb 14,&0,&49,2


;;--------------------------------
defb 15
defb 0	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 15,&0,&41,2
defb 15,&0,&42,2

;;--------------------------------
defb 15
defb 1	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 15,&1,&1,2
defb 15,&1,&2,2


;;--------------------------------
defb 16
defb 0	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 16,&fe,&41,2
defb 16,&fe,&42,2

;;--------------------------------
defb 16
defb 1	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 16,&ff,&1,2
defb 16,&ff,&2,2


;;--------------------------------
defb 17
defb 0	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 17,&ff,&41,2
defb 17,&ff,&42,2

;;--------------------------------
defb 17
defb 1	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 17,&fe,&1,2
defb 17,&fe,&2,2


;;--------------------------------
;; read x
defb 18
defb 0
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 18,0,&41,2

defb -1

;; track, side, mfm,num ids, ids.
dd_test_disk_data:
defb 0
defb 0
defb %01000000

defb 1
defb 0,0,&41,&2

defb 1
defb 0
defb %01000000

defb 1
defb 1,0,&41,&2

defb 4
defb 0
defb %01000000

defb 9
defb 4,&0,&41,2
defb 4,&0,&42,2
defb 4,&0,&43,2
defb 4,&0,&44,2
defb 4,&0,&45,2
defb 4,&0,&46,2
defb 4,&0,&47,2
defb 4,&0,&48,2
defb 4,&0,&49,2


defb 6
defb 0
defb %01000000

defb 1
defb 6,&0,&41,2

defb 6
defb 1
defb %01000000

defb 1
defb 6,&1,&41,2


;;defb 8
;;defb 0
;;defb %00000000

;;defb 1
;;defb 8,&0,&41,2

;;defb 11
;;defb 0
;;defb %01000000

;;defb 2
;;defb &ff,0,1,2
;;defb 10,0,1,2



;;--------------------------------
defb 13
defb 0	
defb %01000000

defb 4
defb 13,&0,&fd,2
defb 13,&0,&fe,2
defb 13,&0,&ff,2
defb 13,&0,&00,2


;;--------------------------------
defb 14
defb 0	
defb %01000000

defb 4
defb 14,&0,&42,2
defb 14,&0,&45,2
defb 14,&0,&46,2
defb 14,&0,&47,2


;;--------------------------------
defb 15
defb 0	
defb %01000000

defb 4
defb 15,&0,&41,2
defb 15,&0,&41,2
defb 15,&0,&41,2
defb 15,&0,&41,2


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