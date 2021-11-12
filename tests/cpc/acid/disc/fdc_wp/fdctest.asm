;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This test concentrates on write protect.
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

call reset_specify

ld a,0
ld (stop_each_test),a
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


ml3:
call cls
ld hl,set_wp_msg
call output_msg
call wait_key
call is_write_protected
jr z,ml3

ld a,&40
ld (command_bits),a



call cls
ld ix,tests
call run_tests
jp do_restart


set_wp_msg:
defb "Please WRITE PROTECT disc. Then press a key to continue",13,0

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
defb "This test checks command when WRITE PROTECT is ENABLED.",13,13
defb "Make sure all other expansions are disconnected",13,13
defb "Press any key to continue",13
defb 0

;; D765AC-2 results 
tests:
DEFINE_TEST "sense drive status (write protected)",wp_drive_status
DEFINE_TEST "write data (data) (write protected)",wp_write_data
DEFINE_TEST "write data (deleted data) (write protected)",wp_dd_write_data
DEFINE_TEST "write deleted data (data) (write protected)",wp_write_deleted_data
DEFINE_TEST "write deleted data (deleted data) (write protected)",wp_dd_write_deleted_data
DEFINE_TEST "format (write protected)",wp_write_deleted_data
DEFINE_TEST "read id (write protected)",read_id_only
DEFINE_TEST "recal (drive status)",recal_drive_status

DEFINE_TEST "read data",read_data_norm
DEFINE_TEST "read deleted data",read_deleted_data_norm

DEFINE_END_TEST

res_recal_drive_status:
defb &01,%01101000,&fe,&01
defb &2,&20,&fe,&01,&00
defb &fe,&00

recal_drive_status:
ld a,39
call go_to_track

ld ix,result_buffer

call send_recalibrate

call short_wait

call sense_drive_status
call get_results

call get_ready_change

call get_results

ld ix,result_buffer
ld hl,res_recal_drive_status
call copy_results

ld bc,5
jp do_results


res_read_data_norm:
defb 0,2
defb 7,&40,&fe,&02,&80,&00,&00,&00,&41,&02
defb &fe,&00

read_data_norm:
ld a,0
call go_to_track

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

call send_read_data

call do_read_data_count
call get_results

ld ix,result_buffer
ld hl,res_read_data_norm
call copy_results

ld bc,10
jp do_results

res_read_deleted_data_norm:
defb 0,2
defb 7,&40,&fe,&02,&80,&00,21,&00,2,&02
defb &fe,&00

read_deleted_data_norm:
ld a,21
call go_to_track

ld ix,result_buffer

ld a,21
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&2
ld (rw_r),a
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

ld ix,result_buffer
ld hl,res_read_deleted_data_norm
call copy_results

ld bc,10
jp do_results


res_read_id_only:
defb 7,0,&fe,&02,0,0,28,0,1,2
defb &fe,&00

read_id_only:
ld a,28
call go_to_track

ld ix,result_buffer

call read_id
call get_results

ld ix,result_buffer
ld hl,res_read_id_only
call copy_results

ld bc,8
jp do_results


res_wp_drive_status:
defb &01,%01001000,&fe,&02
defb &fe,&00

wp_drive_status:
ld ix,result_buffer

call sense_drive_status
call get_results
ld a,(ix-2)
and %01001111
ld (ix-2),a

ld ix,result_buffer
ld hl,res_wp_drive_status
call copy_results

ld bc,3
jp do_results

res_wp_write_data:
defb 0,0
defb 7,&40,&fe,&02,&2,&00,&00,&00,&41,&02
defb &fe,&00

wp_write_data:
ld a,0
call go_to_track

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

call send_write_data

call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,res_wp_write_data
call copy_results

ld bc,10
jp do_results

res_wp_dd_write_data:
defb 0,0
defb 7,&40,&fe,&02,&2,&00,&00,&00,&2,&02
defb &fe,&00

wp_dd_write_data:
ld a,20
call go_to_track

ld ix,result_buffer

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
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

ld ix,result_buffer
ld hl,res_wp_dd_write_data
call copy_results

ld bc,10
jp do_results

res_wp_write_deleted_data:
defb 0,0
defb 7,&40,&fe,&02,&2,&00,&00,&00,&41,&02
defb &fe,&00

wp_write_deleted_data:
ld a,0
call go_to_track

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

call send_write_deleted_data

call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,res_wp_write_deleted_data
call copy_results

ld bc,10
jp do_results

res_wp_dd_write_deleted_data:
defb 0,0
defb 7,&40,&fe,&02,&2,&00,&00,&00,&2,&02
defb &fe,&00

wp_dd_write_deleted_data:
ld a,20
call go_to_track

ld ix,result_buffer

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call send_write_deleted_data

call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,res_wp_dd_write_deleted_data
call copy_results

ld bc,10
jp do_results

res_wp_format:
defb 0,0
defb 7,&40,&fe,&02,&2,&00,&00,&00,&42,&02
defb &fe,&00

wp_format:
call go_to_0
ld a,20
call go_to_track

ld ix,result_buffer

ld a,1	;; single sector
ld (format_sc),a
ld a,2	;; size 512
ld (format_n),a
;; all defaults
ld a,def_format_gap
ld (format_gpl),a
ld a,def_format_filler
ld (format_filler),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

call send_format
call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,res_wp_format
call copy_results


ld bc,8
jp do_results

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
defb 1
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 1,&0,&41,2
defb 1,&0,&42,2
defb 1,&0,&43,2
defb 1,&0,&44,2
defb 1,&0,&45,2
defb 1,&0,&46,2
defb 1,&0,&47,2
defb 1,&0,&48,2
defb 1,&0,&49,2

;;-----------------------------------------
defb 1
defb 1	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 1,&1,&1,2
defb 1,&1,&2,2
defb 1,&1,&3,2
defb 1,&1,&4,2
defb 1,&1,&5,2
defb 1,&1,&6,2
defb 1,&1,&7,2
defb 1,&1,&8,2
defb 1,&1,&9,2

;;-----------------------------------------
defb 2
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 2,&0,&1,2
defb 2,&0,&2,2
defb 2,&0,&3,2
defb 2,&0,&4,2
defb 2,&0,&5,2
defb 2,&0,&6,2
defb 2,&0,&7,2
defb 2,&0,&8,2
defb 2,&0,&9,2

;;-----------------------------------------
defb 2
defb 1	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 2,1,&1,2
defb 2,1,&2,2
defb 2,1,&3,2
defb 2,1,&4,2
defb 2,1,&5,2
defb 2,1,&6,2
defb 2,1,&7,2
defb 2,1,&8,2
defb 2,1,&9,2

;;-----------------------------------------
defb 3
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 3,&0,&1,2
defb 3,&0,&2,2
defb 3,&0,&3,2
defb 3,&0,&4,2
defb 3,&0,&5,2
defb 3,&0,&6,2
defb 3,&0,&7,2
defb 3,&0,&8,2
defb 3,&0,&9,2

;;-----------------------------------------
defb 3
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 4,&1,&1,2
defb 4,&1,&2,2
defb 4,&1,&3,2
defb 4,&1,&4,2
defb 4,&1,&5,2
defb 4,&1,&6,2
defb 4,&1,&7,2
defb 4,&1,&8,2
defb 4,&1,&9,2

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