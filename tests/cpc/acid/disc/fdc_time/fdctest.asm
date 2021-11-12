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
defb "This test does various timings, the results you see may differ.",13,13
defb "This test is a work in progress. Use it as a guide because",13,13
defb "results appear to vary",13
defb "Press a key to continue",0
defb 0

;; TODO: time head unload using head-load, wait and time after then do new.
;; TODO: time after specify???
;; TODO: data ready command
;; TODO: data ready result
;; TODO: hammer fdc motor
;; TODO: hammer ppi cassette motor
;; TODO: hammer crtc reg same
;; TODO: hammer mode
;; TODO: hammer c0/c4
tests:
DEFINE_TEST "seek (fdc busy to not busy after seek command sent)",seek_busy

;; vary on 3.5" drive
;;DEFINE_TEST "head load timing",head_load_timing

;; unreliable
;; on 3.5" drive 9757
;;DEFINE_TEST "read data timing (cmd->data start)",rd_before_sector_timing
;; d4 on type 2, d3 on type 0
DEFINE_TEST "read data timing (cmd->execution phase start)",rd_before_sector_exec

;;DEFINE_TEST "write data before (cmd->data start)",wr_before_sector_timing

;; d on type 0, e on type 2
DEFINE_TEST "read data timing (data end->result phase)",rd_after_sector_timing
DEFINE_TEST "write data timing (data end->result phase)",wr_after_sector_timing

DEFINE_TEST "read data timing (data end->execution phase end)",rd_after_sector_exec
DEFINE_TEST "write data timing (data end->execution phase end)",wr_after_sector_exec


DEFINE_TEST "read data timing (execution phase end->result phase)",rd_exec_to_result
DEFINE_TEST "write data timing (execution phase end->result phase)",wr_exec_to_result



DEFINE_TEST "read data overrun (data end->execution phase end)",rd_overrun_exec
DEFINE_TEST "write data overrun (data end->execution phase end)",wr_overrun_exec

;; vary on 3.5" drive
DEFINE_TEST "read data timing (data end->data start)",rd_between_sector_timing

;;DEFINE_TEST "write data between sector timing",wr_between_sector_timing

DEFINE_END_TEST

res_rd_overrun_exec:
defw &1
defb 7,&40,&fe,&02,&4,&00,&0,&00,&41,&02
defb &fe,&00


rd_overrun_exec:
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

di
call send_read_data
ld de,3
call fdc_data_read_o
call time_exec_end
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
ei
call fdc_result_phase
call get_results

ld hl,res_rd_overrun_exec
ld ix,result_buffer
call copy_results

ld bc,10
jp do_results


res_wr_overrun_exec:
defw 1
defb 7,&40,&fe,&02,&4,&00,&0,&00,&41,&02
defb &fe,&00

wr_overrun_exec:
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

di
call send_write_data
ld de,3
call fdc_data_write_o
call time_exec_end
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
ei
call fdc_result_phase
call get_results

ld hl,res_wr_overrun_exec
ld ix,result_buffer
call copy_results

ld bc,10
jp do_results


res_seek_busy:
defw 2
defb &fe,&00

seek_busy:
call go_to_0

ld ix,result_buffer

di
ld a,39
call send_seek
call time_busy
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call wait_for_seek_end
ei

ld ix,result_buffer
ld hl,res_seek_busy
call copy_results

ld ix,result_buffer
ld bc,2
jp do_results


;; wait long enough for head to unload.
wait_ms:
ld hl,0
wms:
defs 8
nop
dec hl	;; [2]
ld a,h	;; [1]
or l	;; [1]
jp nz,wms ;; [3]
ret

time_result:
ld hl,0
tr:
in a,(c)		;; [4]
cp %11010000	;; [2]
inc hl			;; [2]
jp nz,tr		;; [3]
ret


time_exec_start:
ld hl,0
tes:
in a,(c)		;; [4]
and &20			;; [2]
inc hl			;; [2]
jp z,tes		;; [3]
ret

time_exec_end:
ld hl,0
tee:
in a,(c)		;; [4]
and &20			;; [2]
inc hl			;; [2]
jp nz,tee		;; [3]
ret

wait_exec_end:
in a,(c)		;; [4]
and &20			;; [2]
jp nz,wait_exec_end		;; [3]
ret

time_busy:
ld hl,0
tre:
in a,(c)		;; [4]
bit 4,a			;; fdc still busy?
inc hl			;; [2]
jp nz,tre		;; [3]
ret

time_data:
time_head:
ld hl,0
th:
in a,(c) ;; [4]
inc hl	;; [2]
jp p,th	;; [3]
ret

res_rd_after_sector_timing:
defw &000e
defb &fe,&00

rd_after_sector_timing:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
ld de,512
call fdc_data_read_n
call time_result
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_rd_after_sector_timing
call copy_results

ld bc,2
jp do_results


res_rd_after_sector_exec:
defw &000c
defb &fe,&00

rd_after_sector_exec:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
ld de,512
call fdc_data_read_n
call time_exec_end
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_rd_after_sector_exec
call copy_results

ld bc,2
jp do_results



res_rd_exec_to_result:
defw &1710
defb &fe,&00

rd_exec_to_result:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
call wait_exec_end
call time_result
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_rd_exec_to_result
call copy_results

ld bc,2
jp do_results


res_rd_before_sector_exec:
defw &00d4	;; on type 0 with switches this is d3
defb &fe,&00

rd_before_sector_exec:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
call time_exec_start
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
ld de,512
call fdc_data_read_n
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_rd_before_sector_exec
call copy_results

ld bc,2
jp do_results


res_rd_before_sector_timing:
defw &90ab
defb &fe,&00

rd_before_sector_timing:
ld a,3
call go_to_track

ld a,3
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di 
call send_read_data
ld de,sector_buffer
call fdc_data_read
call fdc_result_phase
ld a,&c2
ld (rw_r),a
ld (rw_eot),a
call send_read_data
call time_data
defs 128
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_rd_before_sector_timing
call copy_results


ld bc,2
jp do_results


rd_between:
call go_to_track
call do_motor_on
di
call send_read_data
ld de,512
call fdc_data_read_n
call time_data
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei
call do_motor_off
ret

rd_sectors:
defb 1,2
defb 2,2
defb 3,2
defb 4,2
defb 5,3
end_rd_sectors:

num_rd_sectors equ (end_rd_sectors-rd_sectors)/2

res_rd_between_sector_timing:
defw &5bd0
defw &9b3
defw &b1a
defw &466
defw &1
defb &fe,&00

rd_between_sector_timing:
ld a,0
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,&c2
ld (rw_eot),a

ld ix,result_buffer
ld hl,rd_sectors
ld b,num_rd_sectors
rdbetweentiming:
push bc
push hl
ld a,b
call outputdec
ld a,' '
call output_char
pop hl
ld a,(hl)
ld (rw_c),a
push af
inc hl
ld a,(hl)
ld (rw_n),a
inc hl
pop af
push hl
call rd_between
pop hl
pop bc
djnz rdbetweentiming


ld ix,result_buffer
ld hl,res_rd_between_sector_timing
call copy_results

ld bc,num_rd_sectors*2
jp do_results

res_wr_after_sector_timing:
defw &000d	;; e on type 0
defb &fe,&00

wr_after_sector_timing:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
ld de,512
call fdc_data_write_n
call time_result
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_wr_after_sector_timing
call copy_results


ld bc,2
jp do_results



res_wr_after_sector_exec:
defw &000c	;; b on type 0
defb &fe,&00

wr_after_sector_exec:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
ld de,512
call fdc_data_write_n
call time_exec_end
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_wr_after_sector_exec
call copy_results


ld bc,2
jp do_results


res_wr_exec_to_result:
defw &37e3		;; &31,&fe...??
defb &fe,&00

wr_exec_to_result:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_write_data
call wait_exec_end
call time_result
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_wr_exec_to_result
call copy_results


ld bc,2
jp do_results


res_wr_before_sector_exec:
defw &000d
defb &fe,&00

wr_before_sector_exec:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
call time_exec_start
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
ld de,512
call fdc_data_write_n
call fdc_result_phase
ei

ld ix,result_buffer
ld hl,res_wr_before_sector_exec
call copy_results


ld bc,2
jp do_results

wr_between_sector_timing:
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,&c2
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
di
call send_read_data
ld de,512
call fdc_data_write_n
call time_result
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase
ei

;;ld ix,result_buffer
;;ld hl,(results)
;;call copy_results

ld bc,2
jp do_results



res_head_load_timing:
defw &24f0
defw &17c3
defw &16b2
defw &1690
defw &178c
defw &1751
defw &175d
defw &187b
defw &18d1
defw &189d
defw &18f8
defw &18f4
defw &18a2
defw &7237
defw &722d
defb &fe,&00

head_load_timing:
ld a,0
call go_to_track


ld ix,result_buffer

ld b,16
ld c,0
hltiming:
push bc
push bc
ld a,b
call outputdec
ld a,' '
call output_char

call do_motor_off

ld a,0
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
call reset_specify
call do_motor_on
di
call send_read_data
call fdc_read_data_count
call fdc_result_phase

pop bc
ld a,c
call set_head_load

ld a,&c2
ld (rw_r),a
ld (rw_eot),a

call wait_ms
call wait_ms
call wait_ms
call wait_ms
call wait_ms
call wait_ms
call wait_ms

call send_read_data
call time_head
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
call fdc_result_phase

pop bc
inc c
djnz hltiming

ld ix,result_buffer
ld hl,res_head_load_timing
call copy_results

ld bc,16*2
jp do_results

;;-----------------------------------------
test_disk_format_data:
defb 0
defb 0	
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 0,&0,&c1,2
defb 0,&0,&c2,2

;;;;;;;;;;;;;;;;;
;; c1 and c2 are next to each other
defb 1
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 1,&0,&c1,2
defb 1,&0,&c2,2
defb 1,&0,&c3,2
defb 1,&0,&c4,2
defb 1,&0,&c5,2
defb 1,&0,&c6,2
defb 1,&0,&c7,2
defb 1,&0,&c8,2
defb 1,&0,&c9,2

;;;;;;;;;;;;;;;;;;;;;
;; wrap around from end to start
defb 2
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 2,&0,&c2,2
defb 2,&0,&c9,2
defb 2,&0,&c3,2
defb 2,&0,&c4,2
defb 2,&0,&c5,2
defb 2,&0,&c6,2
defb 2,&0,&c7,2
defb 2,&0,&c8,2
defb 2,&0,&c1,2

;;;;;;;;;;;;;;;;;;;;;
;; c1 and c2 are 1 sector apart
defb 3
defb 0	
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 3,&0,&c1,2
defb 3,&0,&c6,2
defb 3,&0,&c2,2
defb 3,&0,&c7,2
defb 3,&0,&c3,2
defb 3,&0,&c8,2
defb 3,&0,&c4,2
defb 3,&0,&c9,2
defb 3,&0,&c5,2


;;;;;;;;;;;;;;;;;;;;;
;; c1 and c2 different gap
defb 4
defb 0	
defb %01000000

defb 2
defb 2
defb &ff
defb def_format_filler
defb 4,&0,&c1,2
defb 4,&0,&c2,2


;;;;;;;;;;;;;;;;;;;;;
;; c1 and c2 different sizes
defb 5
defb 0	
defb %01000000

defb 3
defb 2
defb &ff
defb def_format_filler
defb 5,&0,&c1,3
defb 5,&0,&c2,3
defb -1


;;------------------------------------------------------------
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