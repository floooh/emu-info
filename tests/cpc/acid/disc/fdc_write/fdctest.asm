;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This test concentrates on write data and write deleted data.
include "../../lib/testdef.asm"


if CPC=1
org &1000
endif
if SPEC=1
org &8000
endif


start:
;;---------------------------------------------------------------------------

;; type 0 with switches reports drive ready when forcing!!!?
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

call reset_specify

;;ld a,1
;;ld (stop_each_test),a

;;ld a,1
;;ld (stop_each_test),a
call cls
ld hl,information
call output_msg
call output_nl
call wait_key

call choose_drive
call choose_drive_type

call cls
ld hl,drive_testing_msg
call output_msg

call check_ready_display

ml0:
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
defb "This test has been run on a real computer with a real drive.",13,13
defb "Requirements:",13
defb "- Real drive (not HXC or Gotek)",13
defb "- disc is writeable (NOT write protected)",13
defb "- Make sure all other expansions are disconnected",13
defb 0

tests:
;; TODO: multi-sector
;; TODO: multi sector skip
;; TODO: Multi-track
;; TODO: write data and write deleted data in dma mode check execution phase is not activated

DEFINE_TEST "write deleted data",dd_norm
DEFINE_TEST "write deleted data (data error - remove)",dd_de
DEFINE_TEST "write deleted data (data error - size)",dd_de_size
;; UM8272 - it's the last byte in the data register (0-7f, 7f repeated)
DEFINE_TEST "write deleted data (overrun - fill byte)",dd_ov_fill
;; this works, you can hammer it like crazy and it gets written
;; 0-7f, 7f x 4, 0,2,3,4,6,7,8,a,b,c,e,f etc
DEFINE_TEST "write deleted data (overrun - thrash data register)",dd_ov_hammer
DEFINE_TEST "write deleted data (ready change between sector)",dd_rc
DEFINE_TEST "write deleted data (ready change before first sector)",dd_1st_data_rc
;; 0 for most of sector then some bad bytes, not same value depends as it slows down.
;; reda data reports: 07 40 20 60 etc...
DEFINE_TEST "write deleted data (ready change during sector)",dd_data_rc
DEFINE_TEST "write deleted data (sector not found)",dd_nf
DEFINE_TEST "write deleted data (change c=ff?)",dd_ff	
DEFINE_TEST "write deleted data (wrong cylinder)",dd_wc
DEFINE_TEST "write deleted data (bad cylinder)",dd_bc
DEFINE_TEST "write deleted data (not ready)",dd_nr		
DEFINE_TEST "write deleted data (fm on fm)",dd_fm		
DEFINE_TEST "write deleted data (fm on mfm)",dd_fm_mfm
DEFINE_TEST "write deleted data (mfm on fm)",dd_mfm_fm
;; **
;;DEFINE_TEST "write deleted data (overrun)",dd_ov		
DEFINE_TEST "write deleted data (skip)",dd_sk

DEFINE_TEST "write data & write deleted data (change data mark)",write_dm

DEFINE_TEST "write data",d_norm
DEFINE_TEST "write data (data error - remove)",d_de
DEFINE_TEST "write data (data error - size)",d_de_size
;; NEED TO DO MORE CHECKS; SEEMS TO BE LAST BYTE REPEATED ON UM8272 NOT
DEFINE_TEST "write data (overrun - fill byte)",d_ov_fill
DEFINE_TEST "write data (overrun - thrash data register)",d_ov_hammer

DEFINE_TEST "write data (ready change between sector)",d_rc
DEFINE_TEST "write data (ready change before first sector)",d_1st_data_rc
DEFINE_TEST "write data (ready change during sector)",d_data_rc
DEFINE_TEST "write data (sector not found)",d_nf
DEFINE_TEST "write data (change c=ff?)",d_ff	
DEFINE_TEST "write data (wrong cylinder)",d_wc
;; **
DEFINE_TEST "write data (bad cylinder)",d_bc
DEFINE_TEST "write data (not ready)",d_nr		
DEFINE_TEST "write data (fm on fm)",d_fm		
DEFINE_TEST "write data (fm on mfm)",d_fm_mfm		
DEFINE_TEST "write data (mfm on fm)",d_mfm_fm
;; **
;;DEFINE_TEST "write data (overrun)",d_ov		
DEFINE_TEST "write data (skip)",d_sk


DEFINE_TEST "write data (dma)",d_dma
DEFINE_TEST "write deleted data (dma)",dd_dma

DEFINE_END_TEST

comp_to_sector:
ld hl,comp_buffer
ld de,sector_buffer
ld bc,512
ldir
ret

pattern_fill_comp_buffer:
ld hl,comp_buffer
ld bc,512
ld d,0
tw1:
ld (hl),d
inc hl
inc d
dec bc
ld a,b
or c
jr nz,tw1
ret

fill_comp_buffer:
ld hl,comp_buffer
ld bc,512
tws1:
ld (hl),d
inc hl
dec bc
ld a,b
or c
jr nz,tws1
ret


comp_check:
ld hl,sector_buffer
ld de,comp_buffer
ld bc,512
tw2: 
ld a,(de)
cp (hl)
jr nz,tw3
tw4:
inc hl
dec bc
ld a,b
or c
jr nz,tw2
ld a,1
or a
ret
tw3:
ld a,0
or a
ret

pattern_check:
ld hl,sector_buffer
ld bc,512
ld d,0
pc2: 
ld a,(hl)
cp d
jr nz,pc3
pc4:
inc hl
inc d
dec bc
ld a,b
or c
jr nz,pc2
ld a,1
or a
ret
pc3:
ld a,0
or a
ret


;;---------------------------------------------------------------------------------

res_d_rc:
defb 7,&48,&fe,&02,&00,&00,6,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&43,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&44,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&45,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&46,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&47,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&48,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,6,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,6,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

res_dd_rc:
defb 7,&48,&fe,&02,&00,&00,16,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&43,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&44,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&45,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&46,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&47,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&48,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,16,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,16,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

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
ld iy,send_write_data
ld a,6
ld hl,res_d_rc
jr cm_rc

dd_rc:
call check_ready_ok
ret nz
ld iy,send_write_deleted_data
ld a,16
ld hl,res_dd_rc
jr cm_rc

results:
defw 0

jpiy:
push iy
ret

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
wdrc: 
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
call fdc_data_write_n
defs 256
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives

pop hl
ld de,512
add hl,de
pop bc
dec b
jp nz,wdrc

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,9*16
jp do_results


res_d_1st_data_rc:
defb 7,&48,&fe,&02,&00,&00,6,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

res_dd_1st_data_rc:
defb 7,&48,&fe,&02,&00,&00,16,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

d_1st_data_rc:
call check_ready_ok
ret nz
ld iy,send_write_data
ld a,6
ld hl,res_d_1st_data_rc
jr cm_1st_data_rc

dd_1st_data_rc:
call check_ready_ok
ret nz
ld iy,send_write_deleted_data
ld a,16
ld hl,res_dd_1st_data_rc
jr cm_1st_data_rc


cm_1st_data_rc:
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

ld hl,sector_buffer
ld e,l
ld d,h
inc de
ld (hl),&e5
ld bc,512
ldir

call write_data

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

call do_motor_on
call read_data
call get_results

ld ix,sector_buffer
ld bc,512
ld d,16
call simple_number_grid


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16
jp do_results
;;---------------------------------------------------------------------------------

res_d_data_rc:
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&80,&00,&06,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

res_dd_data_rc:
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&40,&fe,&02,&10,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &14,&80
defb 7,&40,&fe,&02,&80,&00,16,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

d_data_rc:
call check_ready_ok
ret nz
ld a,6
ld hl,res_d_data_rc
ld iy,send_write_data
jr cm_data_rc



dd_data_rc:
call check_ready_ok
ret nz
ld a,16
ld hl,res_dd_data_rc
ld iy,send_write_deleted_data
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
wd2rc: 
push bc
push hl


ld a,b
call outputdec
ld a,' '
call output_char

push hl
call do_motor_on

ld hl,sector_buffer
ld e,l
ld d,h
inc de
ld (hl),&e5
ld bc,512
ldir
call write_data

di
call jpiy
pop de
call fdc_data_write_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives

call do_motor_on
call read_data
call get_results


ld ix,sector_buffer
ld bc,512
ld d,16
call simple_number_grid


pop hl
inc hl
pop bc
djnz wd2rc

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,16*16
jp do_results

res_d_norm:
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb &7,&40,&fe,&01,&80,&00,&00,&00,&41,2
defb 1
defb &fe,&00

res_dd_norm:
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &7,&40,&fe,&01,&80,&00,10,&00,&41,2
defb &7,&00,&fe,&01,&00,&40,10,&00,&41,2
defb 1
defb &fe,&00

d_norm:
ld iy,write_data
ld a,0
ld hl,res_d_norm
jr cm_norm


dd_norm:
ld iy,write_deleted_data
ld a,10
ld hl,res_dd_norm
jr cm_norm


cm_norm:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

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

ld ix,result_buffer

xor a
ld b,8
twa1:
push bc
push af
call fill_comp_buffer
call comp_to_sector
call jpiy
call get_results
call read_data
call get_results
call comp_check
ld (ix+0),a
inc ix
inc ix
pop af
add a,7
pop bc
djnz twa1


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,8*17
jp do_results


res_d_dma:
defw &0
defb &07,&40,&fe,&02,&80,&00,0,0,&41,&2
defb &fe,&00

d_dma:
ld iy,send_write_data
ld a,0
ld hl,res_d_dma
jr cm_dma

res_dd_dma:
defw &0
defb &07,&40,&fe,&02,&10,&00,10,0,&41,&2
defb &fe,&00

dd_dma:
ld iy,send_write_deleted_data
ld a,10
ld hl,res_dd_dma
jr cm_dma


cm_dma:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

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

ld ix,result_buffer

ld hl,sector_buffer
ld e,l
ld d,h
inc de
ld (hl),&aa
ld bc,512-1
ldir

call set_dma_mode

call jpiy
call do_write_data_count
call get_results

call set_non_dma_mode
call read_data
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results

res_d_sk:
defw &200
defb &07,&40,&fe,&02,&80,&00,8,0,&41,&2
defb &fe,&00

d_sk:
ld a,8
ld hl,res_d_sk
ld iy,send_write_data
jr cm_sk

res_dd_sk:
defw &200
defb &07,&40,&fe,&02,&80,&00,18,0,&41,&2
defb &fe,&00

dd_sk:
ld a,18
ld hl,res_dd_sk
ld iy,send_write_deleted_data
jr cm_sk

cm_sk:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

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

ld ix,result_buffer

call jpiy
call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results

res_d_de_size:
defb &00,&04
defb &07,&40,&fe,&02,&80,&00,7,0,&41,&3
defb &fe,&00

d_de_size:
ld a,7
ld hl,res_d_de_size
ld iy,send_write_data
jr cm_de_size

res_dd_de_size:
defb &00,&04
defb &07,&40,&fe,&02,&80,&00,17,0,&41,&3
defb &fe,&00

dd_de_size:
ld a,17
ld hl,res_dd_de_size
ld iy,send_write_deleted_data
jr cm_de_size

cm_de_size:
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

call jpiy

call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results


res_d_de:
defb &7,&40,&fe,&01,&20,&20,5,&00,&41,3
defb &7,&40,&fe,&01,&80,&00,5,&00,&41,3
defb &7,&40,&fe,&01,&80,&00,5,&00,&41,3
defb 1
defb &fe,&00


d_de:
ld a,5
ld hl,res_d_de
ld iy,write_data
jr cm_de

res_dd_de:
defb &7,&40,&fe,&01,&20,&20,15,&00,&41,3
defb &7,&40,&fe,&01,&80,&00,15,&00,&41,3
defb &7,&00,&fe,&01,&00,&40,15,&00,&41,3
defb 1
defb &fe,&00

dd_de:
ld a,15
ld hl,res_dd_de
ld iy,write_deleted_data
jr cm_de

cm_de:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

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

ld ix,result_buffer

call read_data
call get_results

call fill_comp_buffer
call comp_to_sector
call jpiy
call get_results
call read_data
call get_results
call comp_check
ld (ix+0),a
inc ix
inc ix

ld ix,result_buffer
ld hl,(results)
call copy_results
ld bc,8*3+1
jp do_results

res_d_nf:
defw 0
defb &7,&40,&fe,&01,&4,&00,&00,&00,&40,&02
defb &fe,&00

d_nf:
ld a,0
ld hl,res_d_nf
ld iy,send_write_data
jr cm_nf

res_dd_nf:
defw 0
defb &7,&40,&fe,&01,&4,&00,10,&00,&40,&02
defb &fe,&00

dd_nf:
ld a,10
ld hl,res_dd_nf
ld iy,send_write_deleted_data
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
call do_write_data_count
call get_results


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,10
jp do_results


res_d_ff:
defw &200
defb 7,&40,&fe,&02, &80,0,2,0,&41,2
defw &000
defb 7,&40,&fe,&02, 4,&10,&ff,0,&41,2
defb 7,&0,&fe,&02, &0,0,2,0,&41,2
defb &fe,&00

res_dd_ff:
defw &200
defb 7,&40,&fe,&02, &80,0,12,0,&41,2
defw &000
defb 7,&40,&fe,&02, 4,&10,&ff,0,&41,2
defb 7,&0,&fe,&02, &0,0,12,0,&41,2
defb &fe,&00


d_ff:
ld iy,send_write_data
ld a,2
ld hl,res_d_ff
jr cm_ff

dd_ff:
ld iy,send_write_deleted_data
ld a,12
ld hl,res_dd_ff
jr cm_ff

cm_ff:
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
call do_write_data_count
call get_results


ld a,&ff
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
call do_write_data_count
call get_results

call read_id
call get_results


ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,8+8+8+2+2+8
jp do_results

res_d_wc:
defw &0
defb 7,&40,&fe,&02,&4,&10,4,0,&41,&2
defw &200
defb 7,&40,&fe,&02,&80,&0,3,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,3,1,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,3,1,&41,&3
defw &0
defb 7,&40,&fe,&02,&4,&10,4,1,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&10,4,1,&41,&3
defb &fe,&00

d_wc:
ld iy,send_write_data
ld a,3
ld hl,res_d_wc
jr cm_wc

res_dd_wc:
defw &200
defb 7,&40,&fe,&02,&80,&00,14,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&10,13,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&10,13,1,&41,&2 
defw &0
defb 7,&40,&fe,&02,&4,&10,13,1,&41,&3 
defw &0
defb 7,&40,&fe,&02,&4,&0,14,1,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,14,1,&41,&3
defb &fe,&00


dd_wc:
ld iy,send_write_deleted_data
ld a,13
ld hl,res_dd_wc
jr cm_wc

cm_wc:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

ld ix,result_buffer

ld a,(track)
inc a
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
call do_write_data_count
call get_results

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
call do_write_data_count
call get_results


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
call do_write_data_count
call get_results



ld a,(track)
ld (rw_c),a
ld a,1
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

call jpiy
call do_write_data_count
call get_results



ld a,(track)
inc a
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
call do_write_data_count
call get_results



ld a,(track)
inc a
ld (rw_c),a
ld a,1
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

call jpiy
call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,6*10
jp do_results


res_d_bc:
defw &200
defb 7,&40,&fe,&02,&80,&0,&ff,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&2,15,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,&ff,1,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,&ff,3,&41,&3
defb &fe,&00

d_bc:
ld iy,send_write_data
ld a,4
ld hl,res_d_bc
jr cm_bc

res_dd_bc:
defw &200
defb 7,&40,&fe,&02,&80,&0,&ff,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&2,15,0,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,&ff,1,&41,&2
defw &0
defb 7,&40,&fe,&02,&4,&0,&ff,3,&41,&3
defb &fe,&00

dd_bc:
ld iy,send_write_deleted_data
ld a,14
ld hl,res_dd_bc
jr cm_bc

cm_bc:
ld (track),a
ld (results),hl
call go_to_track

ld ix,result_buffer

ld a,&ff
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
call do_write_data_count
call get_results

ld a,15
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
call do_write_data_count
call get_results

ld a,&ff
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
call do_write_data_count
call get_results

ld a,&ff
ld (rw_c),a
ld a,3
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

call jpiy
call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results


ld bc,4*10
jp do_results


d_ov:
ld a,0
;;ld hl,res_d_ov
ld iy,send_write_data
jr cm_ov

dd_ov:
ld a,10
;;ld hl,res_dd_ov
ld iy,send_write_deleted_data
jr cm_ov

cm_ov:


ld (track),a
ld (results),hl
call go_to_track

ld a,(track)
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
ld de,0
ld bc,512
wdrn:
push bc
push de

push de
push de
;; init
ld a,def_format_filler
call fill_comp_buffer
call comp_to_sector
call jpiy
call get_results
pop de

ld a,b
call outputdec
ld a,' '
call output_char

di
push de
call jpiy
pop de
call fdc_data_write_o
ei
call fdc_result_phase
call get_results 

call read_data
call get_results
pop de

ld hl,sector_buffer
add hl,de
ld a,(hl)
ld (ix+0),a
inc ix
inc ix
ld de,sector_buffer+512

wdrn2:
inc hl
cp (hl)
ld c,0
jr nz,wdrn3
ld c,1
or a
sbc hl,de
jr z,wdrn3
add hl,de
jr wdrn2

wdrn3:
ld (ix+0),c
inc ix
inc ix

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,wdrn

ld bc,18*512
jp do_results

res_d_ov_fill:
defb &7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &ff
defb &00
defb &00
defb &00
defb &fe,&00

d_ov_fill:
ld iy,send_write_data
ld a,0
ld hl,res_d_wc
jr cm_ov_fill

res_dd_ov_fill:
defb &7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &ff
defb &00
defb &00
defb &00
defb &fe,&00


dd_ov_fill:
ld iy,send_write_deleted_data
ld a,10
ld hl,res_d_wc
jr cm_ov_fill

cm_ov_fill:
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

ld d,&e5
call fill_comp_buffer
call comp_to_sector

call write_data

call pattern_fill_comp_buffer
call comp_to_sector

di
call jpiy
ld hl,sector_buffer
ld de,128
call fdc_data_write_2n
call fdc_result_phase
call get_results
ei

call read_data
call get_results


ld ix,sector_buffer
ld bc,512
ld d,16
call simple_number_grid

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,20
jp do_results

res_d_ov_hammer:
defb &7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &ff
defb &00
defb &00
defb &00
defb &fe,&00

d_ov_hammer:
ld a,0
ld iy,send_write_data
ld hl,res_d_ov_fill
jr cm_ov_hammer

res_dd_ov_hammer:
defb &7,&40,&fe,&02,&10,&00,&00,&00,&41,&02
defb &7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &ff
defb &00
defb &00
defb &00
defb &fe,&00

dd_ov_hammer:
ld a,10
ld iy,send_write_deleted_data
ld hl,res_dd_ov_fill
jr cm_ov_hammer

cm_ov_hammer:
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

ld d,&e5
call fill_comp_buffer
call comp_to_sector

call write_data

call pattern_fill_comp_buffer
call comp_to_sector

di
call jpiy
ld hl,sector_buffer
ld de,128
call fdc_data_write_2n
defs 128
;; thrash data register
thrash:
ld bc,&fb7e
in a,(c)
and &c0
cp &c0
jr z,thrash2
ld bc,&fb7f
out (c),d
inc d
jr thrash
thrash2:
call fdc_result_phase
call get_results
ei

call read_data
call get_results


ld ix,sector_buffer
ld bc,512
ld d,16
call simple_number_grid

ld ix,result_buffer
ld hl,(results)
call copy_results

ld bc,20
jp do_results



res_d_nr:
defw &0
defb &07,&48,&fe,&02,&00,&00,&00,&00,&41,&2
defb &fe,&00


d_nr:
call check_ready_ok
ret nz
ld iy,send_write_data
ld a,0
ld hl,res_d_nr
jr cm_nr

res_dd_nr:
defw &0
defb &07,&48,&fe,&02,&00,&00,10,&00,&41,&2
defb &fe,&00

dd_nr:
call check_ready_ok
ret nz
ld iy,send_write_deleted_data
ld a,10
ld hl,res_dd_nr
jr cm_nr

cm_nr:
ld (track),a
ld (results),hl

ld ix,result_buffer

ld a,(track)
call go_to_track

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

call do_motor_off

call clear_fdd_interrupts

call jpiy
call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,(results)
call copy_results


ld bc,10
jp do_results

res_d_fm:
defb &00,&00
defb &07,&40,&fe,&02,&01,&00,20,0,&41,&2
defb &fe,&00

res_dd_fm:
defb &00,&00
defb &07,&40,&fe,&02,&01,&00,21,0,&41,&2
defb &fe,&00

d_fm:
ld iy,send_write_data
ld a,20
ld hl,res_d_fm
jr cm_fm

dd_fm:
ld iy,send_write_deleted_data
ld a,21
ld hl,res_dd_fm
jr cm_fm

cm_fm:
ld (track),a
ld (results),hl

ld ix,result_buffer
ld a,(track)
call go_to_track

call set_fm

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
call do_write_data_count
call get_results

ld bc,10
jp do_results

res_d_fm_mfm:
defb &00,&00
defb &07,&40,&fe,&02,&01,&00,20,0,&41,&2
defb &fe,&00

res_dd_fm_mfm:
defb &00,&00
defb &07,&40,&fe,&02,&01,&00,21,0,&41,&2
defb &fe,&00


d_fm_mfm:
ld iy,send_write_data
ld a,22
ld hl,res_d_fm_mfm
jr cm_fm_mfm

dd_fm_mfm:
ld iy,send_write_deleted_data
ld a,23
ld hl,res_dd_fm_mfm
jr cm_fm_mfm

cm_fm_mfm:
ld (track),a
ld (results),hl

ld a,(track)
call go_to_track

call set_fm

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
call do_write_data_count
call get_results

call get_results

ld bc,10
jp do_results

res_d_mfm_fm:
defb &00,&00
defb &07,&40,&fe,&02,&01,&00,20,0,&41,&2
defb &fe,&00

res_dd_mfm_fm:
defb &00,&00
defb &07,&40,&fe,&02,&01,&00,21,0,&41,&2
defb &fe,&00


d_mfm_fm:
ld iy,send_write_data
ld a,20
ld hl,res_d_mfm_fm
jr cm_mfm_fm

dd_mfm_fm:
ld iy,send_write_deleted_data
ld a,21
ld hl,res_dd_mfm_fm
jr cm_mfm_fm

cm_mfm_fm:
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

call jpiy
call do_write_data_count
call get_results


ld bc,10
jp do_results

d_mt:
ld a,2
call go_to_track

ld ix,result_buffer

call set_mt


ld a,2
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call jpiy
call do_write_data_count
call get_results
ld bc,10
jp do_results

res_write_dm:
defw &200
defb 7,&40,&fe,&02,&80,&00,&01,&00,&41,&2
defw &200
defb 7,&40,&fe,&02,&80,&00,&01,&00,&41,&2
defw &200
defb 7,&40,&fe,&02,&80,&00,&01,&00,&41,&2
defw &200
defb 7,&0,&fe,&02,&0,&40,&01,&00,&41,&2
defb &fe,&00

write_dm:
ld a,1
call go_to_track

ld ix,result_buffer


ld a,1
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

call send_write_data
call do_write_data_count
call get_results

call send_read_data
call do_read_data_count
call get_results

call send_write_deleted_data
call do_write_data_count
call get_results

call send_read_data
call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,res_write_dm
call copy_results

ld bc,4*10
jp do_results


;;-----------------------------------------
test_disk_format_data:
;; d_norm, d_nf,d_nr,d_ov_fill
defb 0
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 0,&0,&41,2

;; write_dm
defb 1
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 1,&0,&41,2

;; d_ff
defb 2
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 2,&0,&41,2

;; d_wc
defb 3
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 3,&0,&41,2

;; d_bc
defb 4
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb &ff,&0,&41,2

;; d_de
defb 5
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 5,&0,&41,3


;; d_rc, d_1st_data_rc,d_data_rc
defb 6
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 6,&0,&41,2
defb 6,&0,&42,2
defb 6,&0,&43,2
defb 6,&0,&44,2
defb 6,&0,&45,2
defb 6,&0,&46,2
defb 6,&0,&47,2
defb 6,&0,&48,2
defb 6,&0,&49,2


;; d_de_size
defb 7
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 7,&0,&41,3

;; d_sk
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

;; ---
;; dd_norm,dd_nf, dd_nr,dd_ov_fill
defb 10
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 10,&0,&41,2


;; dd_ff
defb 12
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 12,&0,&41,2

;; dd_wc
defb 13
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 14,&0,&41,2

;; dd_bc
defb 14
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb &ff,&0,&41,2

;; dd_de
defb 15
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 15,&0,&41,3


;; dd_rc,dd_1st_data_rc,dd_data_rc
defb 16
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 16,&0,&41,2
defb 16,&0,&42,2
defb 16,&0,&43,2
defb 16,&0,&44,2
defb 16,&0,&45,2
defb 16,&0,&46,2
defb 16,&0,&47,2
defb 16,&0,&48,2
defb 16,&0,&49,2


;; dd_de_size
defb 17
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 17,&0,&41,3

;; dd_sk
defb 18
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 18,&0,&41,2

;; 19

;; d_fm
defb 20
defb 0
defb %00000000
defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 20,&0,&41,2

;; dd_fm
defb 21
defb 0
defb %00000000
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




defb -1


;;------------------------------------------------------------
;; track, side, mfm,num ids, ids.
dd_test_disk_data:
;; d_sk
defb 8
defb 0	
defb %01000000

defb 1
defb 8,&0,&41,2

;; dd_norm
defb 10
defb 0	
defb %01000000

defb 1
defb 10,&0,&41,2

;; dd_ff
defb 12
defb 0	
defb %01000000

defb 1
defb 12,&0,&41,2

;; dd_wc
defb 13
defb 0	
defb %01000000

defb 1
defb 14,&0,&41,2

;; dd_bc
defb 14
defb 0	
defb %01000000

defb 1
defb &ff,&0,&41,2


;; dd_rc
defb 16
defb 0	
defb %01000000

defb 9
defb 16,&0,&41,2
defb 16,&0,&42,2
defb 16,&0,&43,2
defb 16,&0,&44,2
defb 16,&0,&45,2
defb 16,&0,&46,2
defb 16,&0,&47,2
defb 16,&0,&48,2
defb 16,&0,&49,2





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
include "../../lib/hw/cpc.asm"
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