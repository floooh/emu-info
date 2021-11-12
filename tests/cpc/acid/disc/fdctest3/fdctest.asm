
;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.


;; CHECK:
;; - MT and SK with EOT=deleted data
;; - motor port decoding
;; - using read data port for write command
;; - using write data port for read command
;; - fdd ready timing
;; - time head load
;; - time head unload
;; - dma operation of commands
;; - seek step rate being broken if slow writing

;; 15millisecond settle time after seek?
;; index active for at least 1 millisecond

;; reset doesn't clear fdc, it still thinks something is in progress

;; SEEMS LIKE FM CAN'T BE DONE ON CPC  - THE DATA SEPERATOR CAN'T DO IT.

;; TODO: polling
;; TODO: Stop drive motor and see result
;; TODO: head load unload
;; TODO: read track size larger than sector does it find sector id?
;; TODO: read track size larger than sector does it skip data by accident?
;;TODO: Test multi-track on read track doesn't do anything
;; TODO: Format size 3, write with size 2 and see what the data looks like in terms of crc etc and gaps
;; TODO: not ready format and result
;; TODO: Read a track, specify id that will not be found but more sectors than are on the track.
;; TODO: Read a track, id found and more sectors than on the track.
;; TODO: Multi-track with different heads (bit 0 complemented).
;; TODO: Format N=0, and use read track to read actual amount written
;; TODO: Use write data and dtl/gpl to determine the actual amount written using read track
;; TODO: Format small gaps and see if sector can be found both normally and multi-sector
;; TODO: need to test all c,h,r,n values for format to see how that affects results
;; and on sc
;;- ram test check write through on rom with c1,c2 and c3.

;;- sense clears fdd ready?

;;- polling detect with status reg?

;;- check head load timing

;;- check head unload timing

;;- ppi differences (it'll be the difference between the control ports)
;;- convert a 128kb to 64kb gx4000 cart
;; - format mfm
;; - format fm
;; - format mt
;; - format skip

;;Scan: Overrun, mid way – comparison equal for data so far?
;; sector equal


;;greater data on sector, ff local. less or equal.

 

;;read data, write data etc, change ready between sectors, change ready during sectors

;; TODO: 
;; - all tests in FM
;; - Time how long from command until data comes
;; - Time how long *after* command data comes
;; - Time how long between sectors when data comes.
;; - Time how long between each ID from format
;; - Time how long 
;; - Write in MFM and FM and check data bytes are correct
;; - Delay a bit and see how close to an id you can be for it to be found.
;; - Time head load delay
;; - Time head unload delay
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

call reset_specify

ld a,1
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
 
 ;; format and write with different gap sizes to remove id field
;;-----------------------------------------------------
tests:
DEFINE_TEST "scan high or equal (cpu=pattern, sector=ff)",scan_hequal_fdd_ff
DEFINE_TEST "format (ss)",format_ss
DEFINE_TEST "format (ds)",format_ds
DEFINE_TEST "format (not ready)",format_nr
DEFINE_TEST "format (ready change)",format_rc

DEFINE_TEST "scan equal (sector not found)",scan_eq_nf

DEFINE_TEST "scan equal (match)",scan_equal_eq
DEFINE_TEST "scan equal (no match)",scan_equal_neq
DEFINE_TEST "scan equal (cpu=ff, sector=pattern)",scan_equal_cpu_ff
DEFINE_TEST "scan equal (cpu=pattern, sector=ff)",scan_equal_fdd_ff
DEFINE_TEST "scan equal (not ready)",scan_equal_nr

DEFINE_TEST "scan low or equal (sector not found)",scan_leq_nf

DEFINE_TEST "scan low or equal (equal)",scan_lequal_eq
DEFINE_TEST "scan low or equal (less & greater)",scan_lequal_low
DEFINE_TEST "scan low or equal (not ready)",scan_lequal_nr
DEFINE_TEST "scan low or equal (cpu=ff, sector=pattern)",scan_lequal_cpu_ff
DEFINE_TEST "scan low or equal (cpu=pattern, sector=ff)",scan_lequal_fdd_ff

DEFINE_TEST "scan high or equal (sector not found)",scan_heq_nf

DEFINE_TEST "scan high or equal (equal)",scan_hequal_eq
DEFINE_TEST "scan high or equal (less & greater)",scan_hequal_low
DEFINE_TEST "scan high or equal (not ready)",scan_hequal_nr
DEFINE_TEST "scan high or equal (cpu=ff, sector=pattern)",scan_hequal_cpu_ff
;; TODO
;;DEFINE_TEST "scan equal (stp=1) (41-49 - match)",scan_equal_ms
DEFINE_TEST "scan equal (no match) (all STP)",scan_equal_stp
DEFINE_TEST "scan high or equal (no match) (all STP)",scan_hequal_stp

DEFINE_TEST "scan equal (overrun) (match)",scan_equal_overrun
DEFINE_TEST "scan equal (overrun) (no match)",scan_equal_neq_overrun


;;DEFINE_TEST "scan equal (all GPL)",scan_equal_gpl

;;DEFINE_TEST "scan equal (sk)",scan_equal_sk
;;DEFINE_TEST "scan equal (mt)",scan_equal_mt

;;DEFINE_TEST "scan low or equal (all GPL)",scan_loequal_gpl
;;DEFINE_TEST "scan low or equal (all STP)",scan_loequal_stp

;;DEFINE_TEST "scan high or equal (all GPL)",scan_hiequal_gpl

DEFINE_TEST "format (ss)",format_ss
DEFINE_TEST "format (ds)",format_ds
DEFINE_TEST "format (not ready)",format_nr
;; plus: 07,40,04,00,11,00,03,02
DEFINE_TEST "write sector (using read data_register)",read_write
;; plus: 07,40,04,00,11,00,02,02
DEFINE_TEST "read sector (using write data register)",write_read
;; HANG!
;; plus: 07,40,04,00,11,00,02,02
;;DEFINE_TEST "write sector (using status register)",write_status
;; 07,48,00,00,14,40,01,06,00
DEFINE_TEST "format 512K*9 then 8KB",format_norm_8k
;; 07,48,00,00,14,04,0b,02,00
DEFINE_TEST "format (512K * 11)",format_11
;; 07,40,20,20,10,00,01,02
;; 07,40,04,00,10,00,03,03,00,00
DEFINE_TEST "format (force data error)",format_de

;; TESTED - all N can be used but the size is capped at 32768 for N=7
;; 50,00,07,40,a4,20,0a,00,01,00,00,01,07,40 etc
;; >=7 = 32768
DEFINE_TEST "format id/read track (all N)",read_track_n

;; fb,21,0c,0,0,0,0,0,0

;; does gap 4 for a bit then looses sync and gives up.
;; so you can't easily read the bytes after the id it seems
DEFINE_TEST "read track (MFM)",read_track_mfm
;; TESTED (SC=0 -> 256, all others SC -> SC)
DEFINE_TEST "format (FM) (all SC)",format_fm_sc_all

;; 0 maybe fm can't be formatted and read by cpc?
DEFINE_TEST "read data (all dtl) (FM) (N=0)",read_data_fm_n0_dtl
DEFINE_TEST "read data (all dtl) (FM) (N=1)",read_data_fm_n1_dtl
DEFINE_TEST "read data (all dtl) (FM) (N=2)",read_data_fm_n2_dtl


;;DEFINE_TEST "read track (FM)",read_track_fm

;; TESTED: skip on read track does skip
DEFINE_TEST "read track (SK=1)",read_track_sk
;; TESTED: no skip doesn't skip deleted data.
DEFINE_TEST "read track (SK=0)",read_track_nosk
;; TESTED: GPL=0 -> 256, all others GPL->GPL
DEFINE_TEST "format (all GPL)",format_GPL_all

DEFINE_TEST "read track (MT=1)",read_track_mt

;; 28/50 etc
;; 07,41,a4,20,0a,00,01,00,28,00,71,31
;; 07,41,a4,20,0a,00,01,00,50,00,71,31
;; 
DEFINE_TEST "read track (N=0 all DTL)",read_track_dtl
;; ;; 00,00,01,71,31,07,41,a4,20,0a,00,01,01
;; 00,02,71,31,... 01,02
;; 00,04,.... 03
;; 00,08,....04

;; 00,10....05
;; 00,20....06
;; 00,40....07
;; 00,80...08
;; 00,80....0b etc
DEFINE_TEST "read track (all N)",read_track_n

;; 00 00 07 41 84 00 0a 00 00 02
;; 00 02 07 41 84 00 0a 00 01 02
;; 00 04 07 41 84 00 0a 00 02 02
;; size goes above ffff!
;; goes up in 2's (18->3000

;; (93 == 2600)

DEFINE_TEST "read track (all EOT) (match)",read_track_eot_m
;; same as _m

DEFINE_TEST "read track (all EOT) (no match)",read_track_eot_nm

;; UNTESTED
;; expect last byte
;; gets stuck around 128 or so...???
DEFINE_TEST "read data overrun (single sector)",read_data_overrun
DEFINE_TEST "write data overrun (single sector)",write_data_overrun
;; UNTESTED

;; expect last byte of each sector
DEFINE_TEST "read data overrun (multi sector)",readm_data_overrun
DEFINE_TEST "write data overrun (multi sector)",writem_data_overrun

;; TESTED - format uses data mark
DEFINE_TEST "format (default data mark)",format_dm
;; TESTED: DTL bit 0 -> 50, bit 1->28, 50 all. Inconsistent!
DEFINE_TEST "read data (all dtl) (N=0)",read_data_mfm_n0_dtl
;; TESTED: DTL has no effect to data length read
DEFINE_TEST "read data (all dtl) (N=1)",read_data_mfm_n1_dtl
;; TESTED: DTL has no effect to data length read
DEFINE_TEST "read data (all dtl) (N=2)",read_data_mfm_n2_dtl
;; gpl bit = 0, 1 = 0x028
;; 28 all.read_data_mfm
;; 50 etc. then changes to 28 twice and back to 50. (maybe 0 is unstable?)
DEFINE_TEST "read data (all gpl) (N=0)",read_data_n0_gpl
;; GPL has no effect to data length read
DEFINE_TEST "read data (all gpl) (N=1)",read_data_n1_gpl
;; GPL has no effect to data length read
DEFINE_TEST "read data (all gpl) (N=2)",read_data_n2_gpl
;; got 80?
DEFINE_TEST "read data (all gpl and dtl) (N=0)",read_data_n_dtl_gpl


;; TESTED - all C values can be used
DEFINE_TEST "format id (all C)",read_data_c

;; TESTED - all H values can be used
DEFINE_TEST "format id (all H)",read_data_h

;; TESTED - all R values can be used
DEFINE_TEST "format id (all R)",read_data_r

;; TESTED - all N can be used but the size is capped at 32768 for N=7
DEFINE_TEST "format id/read data (all N)",read_data_n



;; TESTED - format uses data mark
DEFINE_TEST "format (default data mark)",format_dm

;; TESTED - all bytes can be used
DEFINE_TEST "format (all filler)",format_filler_all

;; TESTED (SC=0 -> 256, all others SC -> SC)
DEFINE_TEST "format (all SC)",format_mfm_sc_all

;; TESTED - no overrun on last byte
DEFINE_TEST "format overrun",format_overrun



;;DEFINE_TEST "read data timing",read_data_time

;; for this we need to count the timings.
;;DEFINE_TEST "format (all N)",format_N_all


;;DEFINE_TEST "specify (step rate)",specify_step_rate_all
;;DEFINE_TEST "specify (head load)",head_load_all

;; read data all GPL
;; write with all GPL and see if anything becomes broken?

;;DEFINE_TEST "read data timing",read_data_time

;;DEFINE_TEST "write data timing",write_data_time


END_TESTS

norm_11_fd:
defb 20
defb 0
defb %01000000

defb 2
defb 11
defb def_format_gap
defb def_format_filler
defb 20,0,1,2
defb 20,0,2,2
defb 20,0,3,2
defb 20,0,4,2
defb 20,0,5,2
defb 20,0,6,2
defb 20,0,7,2
defb 20,0,8,2
defb 20,0,9,2
defb 20,0,10,2
defb 20,0,11,2

defb -1

norm_9_8k_fd:
defb 20
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 20,0,1,2
defb 20,0,2,2
defb 20,0,3,2
defb 20,0,4,2
defb 20,0,5,2
defb 20,0,6,2
defb 20,0,7,2
defb 20,0,8,2
defb 20,0,9,2

defb 20
defb 0
defb %01000000

defb 6
defb 1
defb def_format_gap
defb def_format_filler
defb 20,0,1,6

defb -1


format_norm_8k:
ld hl,norm_9_8k_fd
jr format_test

format_11:
ld hl,norm_11_fd
jr format_test

format_test:
push hl
call do_motor_on
pop hl
call format_tracksi
call do_motor_off

ld ix,result_buffer
call read_id
call get_results

ld bc,9
jp do_results

write_status:
ld ix,result_buffer
ld a,&1
ld (rw_r),a
ld a,17
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,1
ld (rw_eot),a

ld a,17
call go_to_track

ld hl,sector_buffer
ld bc,512
ld d,0
ws1:
ld (hl),d
inc d
dec bc
ld a,b
or c
jr nz,ws1


call send_write_data
di
ld de,sector_buffer
call fdc_data_writes
ei
call fdc_result_phase
call get_results

call read_data
call get_results

ld hl,sector_buffer
ld bc,512
ld d,0
ws2:
ld a,(hl)
cp d
ld a,0
jr nz,ws2

inc d
dec bc
ld a,b
or c
jr nz,ws2
ld a,1
ws3:
ld (ix+0),a
ld (ix+1),1
inc ix
inc ix

ld bc,1+(8*2)
jp do_results


write_read:
ld ix,result_buffer
ld a,&2
ld (rw_r),a
ld a,17
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,1
ld (rw_eot),a

ld a,17
call go_to_track

call send_write_data
call common_read_data
call get_results

ld bc,8
jp do_results

read_write:
ld ix,result_buffer
ld a,&3
ld (rw_r),a
ld a,17
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,1
ld (rw_eot),a

ld a,17
call go_to_track


call send_read_data
call common_write_sector_data
call get_results

ld bc,8
jp do_results



format_de:
ld ix,result_buffer

ld a,&1
ld (rw_r),a
ld a,16
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,1
ld (rw_eot),a

ld a,16
call go_to_track

call read_data
call get_results

ld a,3
ld (rw_n),a
ld a,2
ld (rw_r),a

call read_data
call get_results

ld bc,9*2
jp do_results


;;----------------------------------------------------------------

format_init:
call do_motor_on
call move2track0

ld a,20	;; track for format tests
jp move2track

;;----------------------------------------------------------------

;; Check data mark written on format. It will be data.
format_dm:
call format_init

call config_read_data_format

ld hl,format_data
ld a,1
ld (hl),a
ld (rw_c),a
inc hl
ld a,2
ld (hl),a
ld (rw_h),a
inc hl
ld a,3
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
ld a,4
ld (hl),a
ld (rw_n),a
inc hl

ld ix,result_buffer
ld (ix+1),7
inc ix
inc ix
ld a,(drive)
or &40
ld (ix+1),a
inc ix
inc ix
ld (ix+1),&20
inc ix
inc ix
ld (ix+1),&60
inc ix
inc ix
ld a,(rw_c)
ld (ix+1),a
inc ix
inc ix
ld a,(rw_h)
ld (ix+1),a
inc ix
inc ix
ld a,(rw_r)
ld (ix+1),a
inc ix
inc ix
ld a,(rw_n)
ld (ix+1),a
inc ix
inc ix


call format

call read_deleted_data

ld ix,result_buffer
call get_results
ld bc,8
jp do_results

;;----------------------------------------------------------------

specify_step_rate_all:

ld ix,result_buffer
ld b,16
xor a
ssra:
push bc
push af

push af
call reset_specify
call go_to_0
pop af
ld (step_rate),a
call send_specify
call send_seek

ld de,&ffff
ssra2:
inc de				
push de
call sense_interrupt_status
pop de
ld hl,(fdc_result_data+0)
cp &80
jr z,ssra2
ld (ix+0),e
inc ix
inc ix
ld (ix+0),d
inc ix
inc ix

pop af
pop bc
inc a
djnz ssra

ld bc,2*16
jp do_results


;;----------------------------------------------------------------

head_load_all:
ld b,16
xor a
hla:
push bc
push af
ld (head_load),a

;; restore head load
;; do read.
;; then wait x ms
;; then do specify
;; then time.

;; set new head load
call send_specify

;; now do the read and time
;; but we need to be able to read from a specific point
;; head is loaded when command is executed

;; wait plenty of time for unload
ld b,8
hla2:
call wait_ms
djnz hla2


pop af
pop bc
djnz hla
ret

wait_ms:

;;----------------------------------------------------------------

read_track_eot_m:
ld a,&c1		;; this id should be found
jr read_track_eot

;;----------------------------------------------------------------

read_track_eot_nm:
ld a,1			;; this id should not be found
jr read_track_eot

;;----------------------------------------------------------------

read_track_eot:
ld (rw_r),a
ld a,10
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a

ld a,10
call go_to_track

ld ix,result_buffer
xor a
ld b,0
rte:
push bc
push af
ld (rw_eot),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_track
call do_read_data_count
call get_results

pop af
pop bc
inc a
djnz rte

ld bc,10*256
jp do_results

write_expected_length:
ld (ix+1),l
ld (ix+3),h
ld (ix+5),e
ld (ix+7),d
ld bc,8
add ix,bc
ret


read_track_sk:
ld hl,&0a00
ld de,&0000

call set_skip
jr read_track_skip

read_track_nosk:
ld hl,&1200
ld de,&0000

call clear_skip
jr read_track_skip


read_track_skip:
ld ix,result_buffer
call write_expected_length
ld a,7
ld (ix+1),a
inc ix
inc ix
ld a,(drive)
or &80
ld (ix+1),a
inc ix
inc ix
ld a,&40
ld (ix+1),a
inc ix
inc ix
ld a,&c
ld (ix+1),a
inc ix
inc ix
ld a,&0
ld (ix+1),a
inc ix
inc ix
ld a,&9
ld (ix+1),a
inc ix
inc ix
ld a,&2
ld (ix+1),a
inc ix
inc ix


ld a,12
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a

ld a,12
call go_to_track

ld a,9
ld (rw_eot),a

ld ix,result_buffer

call send_read_track
call do_read_data_count
call get_results

ld bc,4+7
jp do_results

;;--------------------------------------------------------

put_mfm_gap1:
ld b,50
jr put_mfm_gap

;;--------------------------------------------------------

put_mfm_gap2:
ld bc,22
jr put_mfm_gap

put_mfm_gap4:
ld bc,(gap4)
jr put_mfm_gap

put_mfm_gap3:
ld a,(gap3)
ld c,a
ld b,0

;;--------------------------------------------------------

put_mfm_gap:
ld (ix+1),&4e
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,put_mfm_gap
ret

;;--------------------------------------------------------

put_fm_gap1:
ld bc,26
jr put_fm_gap

;;--------------------------------------------------------

put_fm_gap2:
ld bc,11
jr put_fm_gap

;;--------------------------------------------------------

put_fm_gap:
pfg1:
ld (ix+1),&4e
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,pfg1
ret


;;--------------------------------------------------------

put_fm_iam:
call put_fm_sync
ld (ix+1),&fc
inc ix
inc ix
ret

;;--------------------------------------------------------


put_mfm_sync:
ld b,12
jr put_sync

;;--------------------------------------------------------
put_fm_sync:
ld b,6

;;--------------------------------------------------------

put_sync:
xor a
pms:
ld (ix+1),a
inc ix
inc ix
djnz pms
ret

;;--------------------------------------------------------

put_mfm_iam:
call put_mfm_sync
ld b,3
pmi2:
ld (ix+1),&c2
inc ix
inc ix
djnz pmi2
ld (ix+1),&fc
inc ix
inc ix
ret

;;--------------------------------------------------------

put_fm_marker:
push af
call put_fm_sync
pop af
ld (ix+1),a
call crc1byte
inc ix
inc ix
ret

;;--------------------------------------------------------

put_fm_id:
ld a,&fe
jp put_fm_marker

;;--------------------------------------------------------

put_fm_data:
ld a,&fb
jp put_fm_marker

;;--------------------------------------------------------

put_fm_deleted_data:
ld a,&fe
jp put_fm_marker


;;--------------------------------------------------------

put_mfm_marker:
call crc_reset
push af
call put_mfm_sync
ld b,3
ld a,&a1
pmm1:
ld (ix+1),a
call crc1byte
inc ix
inc ix
djnz pmm1
pop af
ld (ix+1),a
call crc1byte
inc ix
inc ix
ret

crc_reset:
push hl
ld hl,&ffff
ld (crc),hl
pop hl
ret


;; data block id
initial_mfm_data_crc:
call crc_reset
push af
ld b,3
imdc:
call crc_a1
djnz imdc
pop af
jp crc1byte

initial_fm_data_crc:
call crc_reset
jp crc1byte

crc_a1:
ld a,&a1
jp crc1byte

;;http://map.grauw.nl/sources/external/z80bits.html#6.1
;; Input: DE = address of input data, C = number of bytes to process
;; Output: HL = CRC
;;http://info-coach.fr/atari/software/_preservation/PROTECT_TXT.pdf
;; c,h,r,n=ff -> bad track
;;x^16 + x^12 + x^5 + 1 with initial value of FFh (as always, MSB
;;first).

	;; A = byte
crc1byte:
push bc
push hl
push af
ld hl,(crc)
	xor	h
	ld	h,a
	ld	b,8
CrcByte:	add	hl,hl
	jr	nc,Next
	ld	a,h
	xor	10h
	ld	h,a
	ld	a,l
	xor	21h
	ld	l,a
Next:	djnz	CrcByte
ld (crc),hl
pop af
pop hl
pop bc
	ret

	crc:
defw 0

;; http://retrotechnology.com/herbs_stuff/drive.html
;; x^16+x^12+x^5+1
;;--------------------------------------------------------

put_mfm_data:
ld a,&fb
jp put_mfm_marker

;;--------------------------------------------------------

put_mfm_deleted_data:
ld a,&f8
jp put_mfm_marker

;;--------------------------------------------------------

put_mfm_id:
ld a,&fe
jp put_mfm_marker

put_result_byte:
ld a,(hl)
inc hl
ld (ix+1),a
call crc1byte
inc ix
inc ix
ret


;;--------------------------------------------------------
put_result_sector:
prs:
ld a,(filler)
ld (ix+1),a
call crc1byte
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,prs
jr put_crc

put_crc:
push hl
ld hl,(crc)
ld (ix+1),h ;; high byte then low byte
ld (ix+3),l
pop hl
inc ix
inc ix
inc ix
inc ix
ret

mfm_id:
call put_mfm_id
jr put_id

fm_id:
call put_fm_id

put_id:
call put_result_byte
call put_result_byte
call put_result_byte
call put_result_byte
jr put_crc

track_build_data:
defb 0
defb 11,0,&c2,&2
defb 0
defb 11,0,&c3,&2
defb 1
defb 11,0,&c4,&2
defb 0
defb 11,0,&c5,&2
defb 0
defb 11,0,&c6,&2
defb 0
defb 11,0,&c7,&2
defb 0
defb 11,0,&c8,&2
defb 0
defb 11,0,&c9,&2
defb 0
defb 11,0,&c1,&2

read_track_mfm:
call clear_fdc_results

ld a,11
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,6
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,def_format_gap
ld (gap3),a
ld bc,100
ld (gap4),a
ld a,def_format_filler
ld (filler),a

ld a,11
call go_to_track

ld a,1
ld (rw_eot),a

ld ix,result_buffer

call send_read_track
call common_read_data
call get_results
ld ix,result_buffer+18
ld de,sector_buffer
ld bc,8192
rtm:
ld a,(de)
ld (ix+0),a
inc de
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,rtm

ld hl,track_build_data
ld ix,result_buffer+18

ld a,(hl)
inc hl
ld a,&fb
or a
jr z,rtm33
ld a,&f8
rtm33:
call initial_mfm_data_crc

ld bc,512
ld a,def_format_filler
call put_result_sector

ld b,9
rtm1:
push bc
call put_mfm_gap3
call mfm_id
call put_mfm_gap2
call put_data_marker
ld bc,512
ld a,def_format_filler
call put_result_sector
pop bc
djnz rtm1
call put_mfm_gap4

ld bc,8192
jp do_results

put_data_marker:
ld a,(hl)
inc hl
jp z,put_mfm_data
jp put_mfm_deleted_data

read_track_mt:
call set_mt
ld a,12
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a

ld a,12
call go_to_track

;; nine sectors
ld a,9
ld (rw_eot),a

ld ix,result_buffer

call send_read_track
call do_read_data_count
call get_results

ld bc,4+7
jp do_results





read_track_n:

ld a,&c1
ld (rw_r),a
ld a,10
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a

ld a,10
call go_to_track

;; single sector
ld a,1
ld (rw_eot),a

ld ix,result_buffer
xor a
ld b,0
rtn:
push bc
push af
ld (rw_n),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_track
call do_read_data_count
call get_results

pop af
pop bc
inc a
djnz rtn

ld bc,10*256
jp do_results



read_track_dtl:

ld a,&c1
ld (rw_r),a
ld a,10
ld (rw_c),a
xor a
ld (rw_h),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a

ld a,10
call go_to_track

ld a,0
ld (rw_n),a
;; single sector
ld a,1
ld (rw_eot),a

ld ix,result_buffer
xor a
ld b,0
rtd:
push bc
push af
ld (rw_dtl),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_track
call do_read_data_count
call get_results

pop af
pop bc
inc a
djnz rtd

ld bc,10*256
jp do_results

fill_buffer_ascending:
ld e,&ff
jr fill_buffer_max

fill_buffer_max:
ld hl,sector_buffer
ld bc,512
ld d,0
afillbuff:
ld (hl),d
inc d
ld a,d
cp e
jr nz,afb
ld d,0
afb:
inc hl
dec bc
ld a,b
or c
jr nz,afillbuff
ret

fill_buffer_min:
ld e,a
ld hl,sector_buffer
ld bc,512
ld d,e
fbmi:
ld (hl),d
inc d
ld a,d
cp &fe
jr nz,fbmi2
ld d,e
fbmi2:
inc hl
dec bc
ld a,b
or c
jr nz,fbmi
ret

;;----------------------------------------------------------------
fill_buffer_ff:
ld d,&ff
jr fill_buffer

fill_buffer:
ld hl,sector_buffer
ld bc,512
fillbuf:
ld (hl),d
inc hl
dec bc
ld a,b
or c
jr nz,fillbuf
ret

scan_equal_gpl:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

ld b,0
ld c,0
seg:
push bc
ld a,c
ld (rw_gpl),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_scan_equal
call do_write_data_count
call get_results

pop bc
djnz seg

ld bc,10*256
jp do_results


res_scan_lequal_eq:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_lequal_eq:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call send_scan_low_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_lequal_eq
call copy_results

ld bc,8
jp do_results


res_scan_hequal_eq:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_hequal_eq:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call send_scan_high_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_lequal_eq
call copy_results

ld bc,8
jp do_results


res_scan_lequal_low:
defb &7,&0,&fe,&01,&00,&0,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&4,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&0,&00,&00,&41,&02
defb &fe,&00

fill_byte:
ld hl,sector_buffer
ld e,l
ld d,h
inc de
ld (hl),a
ld bc,512-1
ldir
ret

scan_lequal_low:
call go_to_0

ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a


ld a,12
call fill_byte

call write_data

ld a,14
call fill_byte

call send_scan_low_or_equal
call common_write_sector_data
call get_results



ld a,14
call fill_byte

call write_data

ld a,12
call fill_byte

call send_scan_low_or_equal
call common_write_sector_data
call get_results


ld a,&7f
call fill_byte

call write_data

ld a,&80
call fill_byte

call send_scan_low_or_equal
call common_write_sector_data
call get_results




ld ix,result_buffer
ld hl,res_scan_lequal_low
call copy_results

ld bc,24
jp do_results



res_scan_hequal_low:
defb &7,&0,&fe,&01,&00,&4,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&0,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&0,&00,&00,&41,&02
defb &fe,&00

scan_hequal_low:
call go_to_0

ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a


ld a,12
call fill_byte

call write_data

ld a,14
call fill_byte

call send_scan_high_or_equal
call common_write_sector_data
call get_results



ld a,14
call fill_byte

call write_data

ld a,12
call fill_byte

call send_scan_high_or_equal
call common_write_sector_data
call get_results


ld a,&80
call fill_byte

call write_data

ld a,&7f
call fill_byte

call send_scan_high_or_equal
call common_write_sector_data
call get_results


ld ix,result_buffer
ld hl,res_scan_hequal_low
call copy_results

ld bc,24
jp do_results

res_scan_equal_eq:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_equal_eq:
call go_to_0

ld ix,result_buffer
xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call send_scan_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_equal_eq
call copy_results


ld bc,8
jp do_results

res_scan_equal_ms:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_equal_ms:
ld a,20
call go_to_track

ld ix,result_buffer
ld a,20
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
ld a,1
ld (rw_stp),a

;; init sectors each has a different number in it
ld b,9
ld c,1
seqms:
push bc
ld a,c
add a,&40
ld (rw_r),a
ld (rw_eot),a

ld a,c
call fill_byte

call write_data

pop bc
inc c
djnz seqms

ld a,&41
ld (rw_r),a
ld a,&49
ld (rw_eot),a

ld b,9
ld c,1
seqms2:
push bc
;; TODO: Multiple sector read, needs larger buffer
ld a,c
call fill_byte

call send_scan_equal
call common_write_sector_data
call get_results
pop bc
inc c
djnz seqms2

ld ix,result_buffer
ld hl,res_scan_equal_ms
call copy_results

ld bc,9*10
jp do_results


res_scan_eq_nf:
defw &0
defb &7,&0,&fe,&01,&04,&0,&00,&00,&42,&02
defb &fe,&00

scan_heq_nf:
scan_leq_nf:
scan_eq_nf:
call go_to_0

ld ix,result_buffer
xor a
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&42
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
ld a,1
ld (rw_stp),a

call send_scan_equal
call do_write_data_count
call get_results

ld ix,result_buffer
ld hl,res_scan_eq_nf
call copy_results


ld bc,10
jp do_results

res_scan_equal_nr:
defb &7,&48,&fe,&01,&00,&00,&00,&00,&41,&02
defb &fe,&00

scan_equal_nr:
call go_to_0

ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call do_motor_off

call send_scan_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_equal_nr
call copy_results

ld bc,8
jp do_results


res_scan_lequal_nr:
defb &7,&48,&fe,&01,&00,&00,&00,&00,&41,&02
defb &fe,&00

scan_lequal_nr:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call do_motor_off

call send_scan_low_or_equal
call common_write_sector_data
call get_results


ld ix,result_buffer
ld hl,res_scan_lequal_nr
call copy_results

ld bc,8
jp do_results



res_scan_hequal_nr:
defb &7,&48,&fe,&01,&00,&00,&00,&00,&41,&02
defb &fe,&00

scan_hequal_nr:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call do_motor_off

call send_scan_high_or_equal
call common_write_sector_data
call get_results


ld ix,result_buffer
ld hl,res_scan_hequal_nr
call copy_results

ld bc,8
jp do_results


res_scan_equal_fdd_ff:
defb &7,&0,&fe,&01,&00,&4,&00,&00,&41,&02
defb &fe,&00

res_scan_equal_cpu_ff:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_equal_cpu_ff:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data

call fill_buffer_ff

call send_scan_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_equal_cpu_ff
call copy_results


ld bc,8
jp do_results

scan_equal_fdd_ff:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ff

call write_data

call fill_buffer_ascending

call send_scan_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_equal_fdd_ff
call copy_results


ld bc,8
jp do_results

;;---
res_scan_lequal_fdd_ff:
defb &7,&0,&fe,&01,&00,&4,&00,&00,&41,&02
defb &fe,&00

res_scan_lequal_cpu_ff:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_lequal_cpu_ff:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

ld d,&7f
call fill_buffer_max

call write_data

call fill_buffer_ff

call send_scan_low_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_lequal_cpu_ff
call copy_results


ld bc,8
jp do_results

scan_lequal_fdd_ff:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ff

call write_data

ld d,&7f
call fill_buffer_max

call send_scan_low_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_lequal_fdd_ff
call copy_results


ld bc,8
jp do_results

;;---
res_scan_hequal_fdd_ff:
defb &7,&0,&fe,&01,&00,&0,&00,&00,&41,&02
defb &fe,&00

res_scan_hequal_cpu_ff:
defb &7,&0,&fe,&01,&00,&8,&00,&00,&41,&02
defb &fe,&00

scan_hequal_cpu_ff:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

ld a,&80
call fill_buffer_min

call write_data

call fill_buffer_ff

call send_scan_high_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_hequal_cpu_ff
call copy_results


ld bc,8
jp do_results

scan_hequal_fdd_ff:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ff

call write_data

ld a,&80
call fill_buffer_min

call send_scan_high_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_hequal_fdd_ff
call copy_results


ld bc,8
jp do_results



res_scan_equal_neq:
defb &7,&0,&fe,&01,&00,&4,&00,&00,&41,&02
defb &fe,&00

scan_equal_neq:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

call fill_buffer_ascending

call write_data


ld hl,sector_buffer
ld bc,512
sen1:
ld a,(hl)
inc a
cp &ff
jr nz,sen2
xor a
sen2:
ld (hl),a
inc hl
dec bc
ld a,b
or c
jr nz,sen1


call send_scan_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_equal_neq
call copy_results

ld bc,8
jp do_results


res_scan_lequal_neq:
defb &7,&0,&fe,&01,&00,&4,&00,&00,&41,&02
defb &fe,&00


scan_lequal_neq:
call go_to_0
ld ix,result_buffer

xor a
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
ld a,1
ld (rw_stp),a

ld a,&7f
call fill_buffer_max

call write_data

ld a,&80
call fill_buffer_min

call send_scan_low_or_equal
call common_write_sector_data
call get_results

ld ix,result_buffer
ld hl,res_scan_lequal_neq
call copy_results

ld bc,8
jp do_results


;;----------------------------------------------------------------
res_scan_equal_stp:
defw &1209
defb 7,&40,&fe,&01,&4,&0,&19,&0,&4a,&2
defw &a05
defb 7,&40,&fe,&01,&4,&0,&19,&0,&4b,&2
defw &603
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4a,&2
defw &603
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4d,&2
defw &402
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4b,&2
defw &402
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4d,&2
defw &402
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4f,&2
defw &202
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4a,&2
defw &202
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4c,&2
defw &202
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4d,&2
defw &202
defb 7,&00,&fe,&01,&0,&8,&0,&0,&4e,&2
defb &fe,&00

scan_equal_stp:
ld a,19
call go_to_track

ld ix,result_buffer

ld a,19
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld a,&ff
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
ld a,1
ld (rw_stp),a

ld b,64	;;255
ld c,1	;; 0 causes infinite loop
ses:
push bc
ld a,c
ld (rw_stp),a

ld a,b
call outputdec
ld a,' '
call output_char

;; sector formatted with def_format_filler
;; write data count uses 0
call send_scan_equal
call do_write_data_count
call get_results

pop bc
inc c
djnz ses


ld ix,result_buffer
ld hl,res_scan_equal_stp
call copy_results

ld bc,10*255
jp do_results

;;----------------------------------------------------------------
res_scan_hequal_stp:
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defw &201
defb 7,&00,&fe,&01,&0,&8,&0,&0,&41,&2
defb &fe,&00

scan_hequal_stp:
ld a,19
call go_to_track

ld ix,result_buffer

xor a
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld a,&ff
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a
ld a,1
ld (rw_stp),a

ld b,64	;;255
ld c,1	;; 0 causes infinite loop
shes:
push bc
ld a,c
ld (rw_stp),a

ld a,b
call outputdec
ld a,' '
call output_char

;; sector formatted with def_format_filler
;; write data count uses 0
call send_scan_equal
call do_write_data_count
call get_results

pop bc
inc c
djnz shes


ld ix,result_buffer
ld hl,res_scan_hequal_stp
call copy_results

ld bc,10*255
jp do_results

scan_equal_overrun:
ld a,0
call go_to_track

ld a,&ff
call fill_byte


ld a,0
ld (rw_c),a
ld a,0
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

call write_data

ld ix,result_buffer
ld de,0
ld bc,512
snrn:
push bc
push de
push de

ld a,b
call outputdec
ld a,' '
call output_char

call send_scan_equal
pop de
di
call fdc_data_write_o
ei
call fdc_result_phase
call get_results

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,snrn

ld bc,8*512
jp do_results

scan_equal_neq_overrun:
ld a,0
call go_to_track

ld a,&ee
call fill_byte


ld a,0
ld (rw_c),a
ld a,0
ld (rw_h),a
ld a,&41
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

call write_data

ld ix,result_buffer
ld de,0
ld bc,512
snrn2:
push bc
push de
push de

ld a,b
call outputdec
ld a,' '
call output_char

call send_scan_equal
pop de
di
call fdc_data_write_o
ei
call fdc_result_phase
call get_results

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,snrn2

ld bc,8*512
jp do_results


scan_equal_sk:
call go_to_0

call set_skip
ld ix,result_buffer

xor a
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

call send_scan_equal
call do_write_data_count
call get_results

ld bc,10*256
jp do_results

;;----------------------------------------------------------------
scan_loequal_gpl:
ret


;;----------------------------------------------------------------
scan_hiequal_gpl:
ret

;;----------------------------------------------------------------
format_fm_sc_all:
call set_fm
jr format_sc_all

format_mfm_sc_all
call set_mfm
jr format_sc_all

;; format all possible sc values
;; determine the number of sectors formatted by counting the number
;; of bytes in the execution phase. 
format_sc_all:
call format_init

ld a,1
ld (format_n),a
ld a,def_format_gap
ld (format_gpl),a
ld a,def_format_filler
ld (format_filler),a

ld ix,result_buffer
ld b,0
xor a
fs1a:
push bc
push af
push af
ld l,a
ld h,0
or a
jr nz,fs1b
ld hl,256
fs1b:
add hl,hl
add hl,hl
ld (ix+1),l
inc ix
inc ix
ld (ix+1),h
inc ix
inc ix

ld (ix+1),7
inc ix
inc ix
ld (ix+1),1
inc ix
inc ix
ld (ix+1),0
inc ix
inc ix
ld (ix+1),0
inc ix
inc ix
ld (ix+1),0
inc ix
inc ix
ld (ix+1),2
inc ix
inc ix
pop af
ld (ix+1),a
inc ix
inc ix
ld (ix+1),1
inc ix
inc ix
pop af
inc a
pop bc
djnz fs1a

ld ix,result_buffer
ld b,0
xor a
fs1:
push bc
push af

ld (format_sc),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_format
call do_write_data_count
call get_results

pop af
inc a
pop bc
djnz fs1

ld bc,256*(8+2)
jp do_results

;;----------------------------------------------------------------

;; verify all possible filler values when formatting a track
format_filler_all:
call format_init

;; format a single 512 byte sector
;; but vary the filler byte.
;;
;; then read back the data to confirm it is correct
call config_read_data_format

xor a
ld (rw_c),a
ld (format_data+0),a
ld (rw_h),a
ld (format_data+1),a
ld a,1
ld (rw_r),a
ld (format_data+2),a
ld a,2
ld (rw_n),a
ld (format_data+3),a


ld ix,result_buffer
ld b,0
ff1a:
ld (ix+1),7
inc ix
inc ix
;; st0
ld a,(drive)
ld (ix+1),a
inc ix
inc ix
xor a ;; st 1
ld (ix+1),a
inc ix
inc ix
xor a ;; st 2
ld (ix+1),a
inc ix
inc ix
;; on first one it can vary (f7 etc)
ld a,(format_data+0)
ld (ix+1),a
inc ix
inc ix
;;ld a,(format_data+1)
ld a,4
ld (ix+1),a
inc ix
inc ix
ld a,(format_data+2)
ld (ix+1),a
inc ix
inc ix
ld a,(format_data+3)
ld (ix+1),a
inc ix
inc ix
;; 2 shows a different value?
ld (ix+1),1
inc ix
inc ix
djnz ff1a


ld ix,result_buffer
ld b,0
xor a
ff1:
push bc
push af
ld (format_filler),a

ld a,b
call outputdec
ld a,' '
call output_char

call format
call get_results

call read_data

ld hl,sector_buffer
ld bc,512
ff2: ld a,(format_filler)
cp (hl)
ld a,0
jr nz,ff3
inc hl
dec bc
ld a,b
or c
jr nz,ff2
ld a,1
ff3:
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
djnz ff1

ld bc,256*9
jp do_results

;;----------------------------------------------------------------

format_N_all:
call format_init

ld a,1
ld (format_sc),a
ld a,def_format_gap
ld (format_gpl),a
ld a,def_format_filler
ld (format_filler),a

ld ix,result_buffer
ld b,0
xor a
fn1:
push bc
push af

ld (format_n),a

di
call send_format
call fdc_data_write_count
;;ld (ix+0),e
;;inc ix
;;;inc ix
;;ld (ix+0),d
;;inc ix
;;inc ix
call fdc_result_phase
call get_results

pop af
inc a
pop bc
djnz fn1

ld bc,2*(256+8)
jp do_results

;;----------------------------------------------------------------

;; format all possible gpl values.
;; format two sectors, use read track to then measure the gap length
format_GPL_all:
call format_init

;; format two single 512 byte sectors; enough to be able to measure the gap length
ld a,2
ld (format_n),a
ld a,2
ld (format_sc),a
ld a,def_format_filler
ld (format_filler),a

ld ix,result_buffer
ld b,0
ld c,0
fg2:
ld a,c
or a
jr z,fg3
ld (ix+1),&00
ld (ix+3),&01
jr fg4
fg3:
ld (ix+1),c
ld (ix+3),0
fg4:
inc ix
inc ix
inc ix
inc ix
inc c
djnz fg2


ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
ld (hl),2 ;; N
inc hl
ld (hl),0
inc hl
ld (hl),0
inc hl
ld (hl),2
inc hl
ld (hl),2
inc hl
ld a,&ff
ld (rw_dtl),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,3
ld (rw_n),a

ld ix,result_buffer
ld b,0
xor a
fg1:
push bc
push af
ld (format_gpl),a

ld a,b
call outputdec
ld a,' '
call output_char

call format


call send_read_track
call common_read_data
call fdc_result_phase

ld hl,sector_buffer
ld bc,512+2				;; 512 bytes of data + 2 for crc
add hl,bc
ld de,0
rgl2:
ld a,(hl)
cp &4e
jp nz,rgl3
inc de
inc hl
jp rgl2
rgl3:
ld (ix+0),e
inc ix
inc ix
ld (ix+0),d
inc ix
inc ix

pop af
inc a
pop bc
djnz fg1
ld bc,2*256
jp do_results

;;----------------------------------------------------------------

config_read_data_format:
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
ret



read_data_overrun:
ld a,10
call go_to_track

ld a,0
ld (rw_c),a
ld a,0
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
ld de,0
ld bc,512
rdrn:
push bc
push de
push de

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_data
pop de
di
call fdc_data_read_o
ei
call fdc_result_phase
call get_results

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,rdrn

ld bc,8*512
jp do_results


readm_data_overrun:

ld a,10
call go_to_track

xor a
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,&c9
ld (rw_eot),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
ld de,0
ld bc,2048
rmdrn:
push bc
push de

ld a,b
call outputdec
ld a,' '
call output_char

push de
call send_read_data
pop de
di
call fdc_data_read_o
ei
call fdc_result_phase
call get_results

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,rmdrn

ld bc,8*2048
jp do_results

write_data_overrun:
ld a,10
call go_to_track

xor a
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

ld a,b
call outputdec
ld a,' '
call output_char

push de
call send_write_data
pop de
di
call fdc_data_write_o
ei
call fdc_result_phase
call get_results 

;; need to check data for write

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,wdrn

ld bc,8*512
jp do_results


writem_data_overrun:

ld a,10
call go_to_track


xor a
ld (rw_c),a
ld (rw_h),a
ld a,&c1
ld (rw_r),a
ld a,2
ld (rw_n),a

ld ix,result_buffer
ld de,0
ld bc,2048
wmdrn:
push bc
push de

ld a,b
call outputdec
ld a,' '
call output_char

push de
call send_write_data
pop de
di
call fdc_data_write_o
ei
call fdc_result_phase
call get_results 

;; need to check data for write

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,wmdrn

ld bc,8*2048
jp do_results

format_overrun:
ld a,20
call go_to_track

ld a,2
ld (format_n),a
ld a,9
ld (format_sc),a
ld a,def_format_gap
ld (format_gpl),a
ld a,def_format_filler
ld (format_filler),a

ld hl,format_data
ld b,9
ld a,&c1
fdo1:
ld (hl),0
inc hl
ld (hl),0
inc hl
ld (hl),a
inc a
inc hl
ld (hl),2
djnz fdo1

ld ix,result_buffer
ld b,9*4
fdrn1:
ld (ix+1),7
inc ix
inc ix

ld a,b
cp 1
jr nz,fdrn1b
;; no overrun
ld a,(drive)
ld (ix+1),a
inc ix
inc ix
ld a,0
ld (ix+1),a
inc ix
inc ix
jr fdrn2
fdrn1b:
;; overrun
ld a,(drive)
or &40
ld (ix+1),a
inc ix
inc ix
ld (ix+1),&10
inc ix
inc ix
fdrn2:
ld (ix+1),&00
inc ix
inc ix
ld (ix+1),&01
inc ix
inc ix
ld (ix+1),&04
inc ix
inc ix
ld (ix+1),&09
inc ix
inc ix
ld (ix+1),&02
inc ix
inc ix
djnz fdrn1

ld ix,result_buffer
ld de,0
ld bc,9*4
fdrn:
push bc
push de
push de

ld a,b
call outputdec
ld a,' '
call output_char

call send_format
pop de
di
call fdc_data_write_o
ei
call fdc_result_phase
call get_results 

;; need to check data for write
;; need to check what was written
pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,fdrn

ld bc,8*9*4
jp do_results


;;----------------------------------------------------------------


;;----------------------------------------------------------------

setup_format_id_results:
ld ix,result_buffer
ld bc,8*2
ld d,0
sfir:
ld (ix+1),7
ld a,(drive)
ld (ix+3),a
ld (ix+5),0
ld (ix+7),0
ld (ix+9),0
ld (ix+11),0
ld (ix+13),1
ld (ix+15),2
add ix,bc
dec d
jr nz,sfir
ret


;; format a 512 byte sector with size 2
;; set the ID to the C value we want
;; and read back 
read_data_c:
call format_init

call config_read_data_format

call setup_format_id_results

ld ix,result_buffer
ld bc,8*2
xor a
ld d,0
rc1a:
ld (ix+9),a
add ix,bc
inc a
dec d
jr nz,rc1a

ld ix,result_buffer
xor a
ld b,0
rc1:
push bc
push af

;; ID field defines length
ld hl,format_data
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
ld a,2
ld (hl),a
ld (rw_n),a

ld a,b
call outputdec
ld a,' '
call output_char

call format

;; do a read id
call read_id
call get_results

pop af
pop bc
inc a
djnz rc1
ld bc,8*256
jp do_results

do_format_2sides:
ld ix,result_buffer

call format_init

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
ld hl,format_data
ld (hl),20
inc hl
ld (hl),0
inc hl
ld (hl),&41
inc hl
ld (hl),2

call format
call get_results

call read_id
call get_results

call set_side1

ld hl,format_data
ld (hl),21
inc hl
ld (hl),1
inc hl
ld (hl),&42
inc hl
ld (hl),3
ld a,3	;; size 1024
ld (format_n),a

call format
call get_results

call read_id
call get_results

call set_side0
call read_id
call get_results


ret

res_format_rc:
defb 7,&48,&fe,&02,&00,&00,&00,&00,&41,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&00,&00,&42,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb 7,&48,&fe,&02,&00,&00,&00,&00,&43,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80


defb 7,&40,&fe,&02,&80,&00,&00,&00,&49,&02
defb &1,&80
defb &1,&80
defb &1,&80
defb &1,&80
defb &fe,&00

format_rc_data:
defb 20,0,&41,2
defb 20,0,&42,2
defb 20,0,&43,2
defb 20,0,&44,2
defb 20,0,&45,2
defb 20,0,&46,2
defb 20,0,&47,2
defb 20,0,&48,2
defb 20,0,&49,2
end_format_rc_data:

format_rc:
call check_ready_ok
ret nz

call format_init

ld ix,result_buffer

ld a,9	;; single sector
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
ld hl,format_rc_data
ld de,format_data
ld bc,end_format_rc_data-format_rc_data
ldir

ld b,9
ld c,1
fmrc: 
push bc
push hl
ld a,c
ld (format_sc),a

ld a,b
call outputdec
ld a,' '
call output_char

call do_motor_on

call send_format
di
ld de,format_data
call fdc_data_write_n
call stop_drive_motor
ei
call fdc_result_phase
call get_results

call sense_all_drives

pop hl
ld de,4
add hl,de
pop bc
djnz fmrc


ld ix,result_buffer
ld hl,res_format_rc
call copy_results

ld bc,9*16
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


res_format_nr:
defb &7,&48,&fe,&01,0,0,&14,4,1,2 ;; format
defb &fe,&00

format_nr:
call check_ready_ok
ret nz

ld ix,result_buffer

ld a,0
call go_to_track

call format_init

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
ld hl,format_data
ld (hl),0
inc hl
ld (hl),0
inc hl
ld (hl),&41
inc hl
ld (hl),2

call do_motor_off

call format
call get_results

ld ix,result_buffer
ld hl,res_format_nr
call copy_results
ld bc,8
jp do_results

res_format_ss:
defb &7,0,&fe,&01,0,0,&14,4,1,2 ;; format
defb &7,0,&fe,&01,0,0,20,0,&41,2 ;; read id
defb &7,&4,&fe,&01,0,0,&14,4,1,2 ;; format
defb &7,&4,&fe,&01,0,0,21,1,&42,3 ;; read id
defb &7,&0,&fe,&01,0,0,21,1,&42,3 ;; read id
defb &fe,&00

res_format_ds:
defb &7,0,&fe,&01,0,0,&14,4,1,2 ;; format
defb &7,0,&fe,&01,0,0,20,0,&41,2 ;; read id
defb &7,&4,&fe,&01,0,0,&14,4,1,2 ;; format
defb &7,&4,&fe,&01,0,0,21,1,&42,3 ;; read id
defb &7,&0,&fe,&01,0,0,20,0,&41,2 ;; read id
defb &fe,&00

format_ss:
call check_one_sides
ret z

call do_format_2sides

ld ix,result_buffer
ld hl,res_format_ss
call copy_results

ld bc,8*5
jp do_results

format_ds:
call check_two_sides
ret z
call do_format_2sides

ld ix,result_buffer
ld hl,res_format_ds
call copy_results

ld bc,8*5
jp do_results


;;----------------------------------------------------------------

;; format a 512 byte sector with size 2
;; set the ID to the H value we want
;; and read back 
read_data_h:
call format_init

call config_read_data_format

call setup_format_id_results

ld ix,result_buffer
ld bc,8*2
xor a
ld d,0
rh1a:
ld (ix+11),a
add ix,bc
inc a
dec d
jr nz,rh1a


ld ix,result_buffer
xor a
ld b,0
rh1:
push bc
push af

push af
;; ID field defines length
ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
pop af
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
ld a,2
ld (hl),a
ld (rw_n),a

ld a,b
call outputdec
ld a,' '
call output_char


call format

;; do a read id
call read_id
call get_results

pop af
pop bc
inc a
djnz rh1
ld bc,8*256
jp do_results


;; format a 512 byte sector with size 2
;; set the ID to the R value we want
;; and read back 
read_data_r:
call format_init

call config_read_data_format


call setup_format_id_results

ld ix,result_buffer
ld bc,8*2
xor a
ld d,0
rr1a:
ld (ix+13),a
add ix,bc
inc a
dec d
jr nz,rr1a


ld ix,result_buffer
xor a
ld b,0
rr1:
push bc
push af

push af
;; ID field defines length
ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
pop af
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
ld a,2
ld (hl),a
ld (rw_n),a

ld a,b
call outputdec
ld a,' '
call output_char

call format

;; do a read id
call read_id
call get_results

pop af
pop bc
inc a
djnz rr1
ld bc,8*256
jp do_results


;;----------------------------------------------------------------

n_mfm:
defw &0028
defw &0100
defw &0200
defw &0400
defw &0800
defw &1000
defw &2000
defw &4000
defw &8000

;; format a 512 byte sector with size 2
;; set the ID to the N value we want
;; and read back and return size read.
read_data_n:
call format_init

call config_read_data_format

ld ix,result_buffer
ld b,9
ld hl,n_mfm
rn1a:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
djnz rn1a
ld b,256-9
rn1b:
ld (ix+1),&00
inc ix
inc ix
ld (ix+1),&80
inc ix
inc ix
djnz rn1b

ld ix,result_buffer
xor a
ld b,0
rn1:
push bc
push af

push af
;; ID field defines length
ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
pop af
ld (hl),a
ld (rw_n),a

ld a,b
call outputdec
ld a,' '
call output_char

call format

;; do a read id
;;call read_id

call send_read_data
call do_read_data_count


pop af
pop bc
inc a
djnz rn1
ld bc,2*256
jp do_results

read_data_mfm_n0_dtl:
ld ix,result_buffer
ld bc,8
ld d,128
rd1:
ld (ix+1),&50
ld (ix+3),&00
ld (ix+5),&28
ld (ix+7),&00
add ix,bc
dec d
jr nz,rd1

;; now it's reading 50
xor a
jp read_data_mfm_n_dtl

read_data_mfm_n1_dtl:
ld ix,result_buffer
ld bc,4
ld d,0
rd11:
ld (ix+1),&00
ld (ix+3),&01
add ix,bc
dec d
jr nz,rd11

ld a,1
jp read_data_mfm_n_dtl

read_data_mfm_n2_dtl:
ld ix,result_buffer
ld bc,4
ld d,0
rd12:
ld (ix+1),&00
ld (ix+3),&02
add ix,bc
dec d
jr nz,rd12

ld a,2
jp read_data_mfm_n_dtl


read_data_fm_n0_dtl:
ld ix,result_buffer
ld d,128
ld e,0
rfd1:
ld a,e
or a
ld bc,128
jr nz,rfd2
ld c,e
ld b,0
rfd2:
ld (ix+1),e
ld (ix+3),d
add ix,bc
dec d
jr nz,rfd1

xor a
jr read_data_fm_n_dtl

read_data_fm_n1_dtl:
ld ix,result_buffer
ld bc,4
ld d,0
rdf11:
ld (ix+1),&00
ld (ix+3),&01
add ix,bc
dec d
jr nz,rdf11

ld a,1
jr read_data_fm_n_dtl

read_data_fm_n2_dtl:
ld ix,result_buffer
ld bc,4
ld d,0
rdf12:
ld (ix+1),&00
ld (ix+3),&02
add ix,bc
dec d
jr nz,rdf12

ld a,2
jr read_data_fm_n_dtl

read_data_fm_n_dtl:
call set_fm
jr read_data_n_dtl

read_data_mfm_n_dtl:
call set_mfm

read_data_n_dtl:
push af
ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
pop af
ld (hl),a
ld (rw_n),a


call format_init

call config_read_data_format

call format

ld ix,result_buffer
xor a
ld b,0
rdtl1:
push bc
push af
ld (rw_dtl),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_data
call do_read_data_count

pop af
pop bc
inc a
djnz rdtl1
ld bc,2*256
jp do_results


read_data_n_dtl_gpl:
ld a,0
push af
ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
pop af
ld (hl),a
ld (rw_n),a


call format_init

call config_read_data_format

call format

ld ix,result_buffer
ld de,0
ld bc,512
rdtlaa1:
push bc
push de
ld a,e
ld (rw_dtl),a
ld a,d
ld (rw_gpl),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_data
call do_read_data_count

pop de
pop bc
inc de
dec bc
ld a,b
or c
jr nz,rdtlaa1
ld bc,2*256
jp do_results

read_data_n0_gpl:
ld ix,result_buffer
ld bc,4
ld d,0
ld e,0
rd10:
bit 6,e
ld hl,&0050
jr z,rd10a
ld hl,&28
rd10a:
ld (ix+1),l
ld (ix+3),h
add ix,bc
inc e
dec d
jr nz,rd10

xor a
jr read_data_n_gpl

read_data_n1_gpl:
ld ix,result_buffer
ld bc,4
ld d,0
rd11b:
ld (ix+1),&00
ld (ix+3),&01
add ix,bc
dec d
jr nz,rd11b

ld a,1
jr read_data_n_gpl

read_data_n2_gpl:
ld ix,result_buffer
ld bc,4
ld d,0
rd12b:
ld (ix+1),&00
ld (ix+3),&02
add ix,bc
dec d
jr nz,rd12b

ld a,2
jr read_data_n_gpl

read_data_n_gpl:
push af
ld hl,format_data
xor a
ld (hl),a
ld (rw_c),a
inc hl
xor a
ld (hl),a
ld (rw_h),a
inc hl
ld a,1
ld (hl),a
ld (rw_r),a
ld (rw_eot),a
inc hl
pop af
ld (hl),a
ld (rw_n),a


call format_init

call config_read_data_format

call format

ld ix,result_buffer
xor a
ld b,0
rgtl1:
push bc
push af
ld (rw_gpl),a

ld a,b
call outputdec
ld a,' '
call output_char

call send_read_data
call do_read_data_count

pop af
pop bc
inc a
djnz rgtl1
ld bc,2*256
jp do_results

;; track, side, mfm,num ids, ids.
dd_test_disk_data:
defb 12
defb 0
defb %01000000

defb 4
defb 12,0,&c2,&2
defb 12,0,&c4,&2
defb 12,0,&c6,&2
defb 12,0,&c8,&2

;;defb 14
;;defb 0
;;defb %00000000

;;defb 4
;;defb 14,0,&c2,&2
;;defb 14,0,&c4,&2
;;defb 14,0,&c6,&2
;;defb 14,0,&c8,&2

defb -1


;; track
;; side
;;  n
;; sc
;; gpl
;; filler
;; ids

test_disk_format_data:
;; scan tests (writes to sector)
defb 0
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb &0,&0,&41,&2

;;------------------------------------------------------------------
defb 1
defb 0	
defb %01000000

defb 1
defb 16
defb def_format_gap
defb def_format_filler
defb &1,&0,&1,&1
defb &1,&0,&2,&1
defb &1,&0,&3,&1
defb &1,&0,&4,&1
defb &1,&0,&5,&1
defb &1,&0,&6,&1
defb &1,&0,&7,&1
defb &1,&0,&8,&1
defb &1,&0,&9,&1
defb &1,&0,&a,&1
defb &1,&0,&b,&1
defb &1,&0,&c,&1
defb &1,&0,&d,&1
defb &1,&0,&e,&1
defb &1,&0,&f,&1
defb &1,&0,&10,&1

;;------------------------------------------------------------------
;; multi-track with H 0/1 (normal expected operation)
defb 2
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &2,&0,&1,&2
defb &2,&0,&2,&2
defb &2,&0,&3,&2
defb &2,&0,&4,&2
defb &2,&0,&5,&2
defb &2,&0,&6,&2
defb &2,&0,&7,&2
defb &2,&0,&8,&2
defb &2,&0,&9,&2

;;------------------------------------------------------------------
;; multi-track with H 0/1 (normal expected operation)
defb 2
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &2,&1,&1,&2
defb &2,&1,&2,&2
defb &2,&1,&3,&2
defb &2,&1,&4,&2
defb &2,&1,&5,&2
defb &2,&1,&6,&2
defb &2,&1,&7,&2
defb &2,&1,&8,&2
defb &2,&1,&9,&2

;;------------------------------------------------------------------
;; multi track with H different than 0/1 bit expect it to work because of toggling bit 0

defb 3
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &3,&fe,&1,&2
defb &3,&fe,&2,&2
defb &3,&fe,&3,&2
defb &3,&fe,&4,&2
defb &3,&fe,&5,&2
defb &3,&fe,&6,&2
defb &3,&fe,&7,&2
defb &3,&fe,&8,&2
defb &3,&fe,&9,&2

;;------------------------------------------------------------------
defb 3
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &3,&ff,&1,&2
defb &3,&ff,&2,&2
defb &3,&ff,&3,&2
defb &3,&ff,&4,&2
defb &3,&ff,&5,&2
defb &3,&ff,&6,&2
defb &3,&ff,&7,&2
defb &3,&ff,&8,&2
defb &3,&ff,&9,&2



;;------------------------------------------------------------------
;; multi track transitioning from side 1 to side 0

defb 4
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &4,&ff,&1,&2
defb &4,&ff,&2,&2
defb &4,&ff,&3,&2
defb &4,&ff,&4,&2
defb &4,&ff,&5,&2
defb &4,&ff,&6,&2
defb &4,&ff,&7,&2
defb &4,&ff,&8,&2
defb &4,&ff,&9,&2

;;------------------------------------------------------------------
defb 5
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &5,&fe,&1,&2
defb &5,&fe,&2,&2
defb &5,&fe,&3,&2
defb &5,&fe,&4,&2
defb &5,&fe,&5,&2
defb &5,&fe,&6,&2
defb &5,&fe,&7,&2
defb &5,&fe,&8,&2
defb &5,&fe,&9,&2


;;------------------------------------------------------------------
;; multi-track transitioning to side 1 but not found
defb 5
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &53,&fe,&1,&2
defb &53,&fe,&2,&2
defb &53,&fe,&3,&2
defb &53,&fe,&4,&2
defb &53,&fe,&5,&2
defb &53,&fe,&6,&2
defb &53,&fe,&7,&2
defb &53,&fe,&8,&2
defb &53,&fe,&9,&2


;;------------------------------------------------------------------
;; multi-track transitioning to side 0.. check C inc?
defb 6
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb &54,&fe,&1,&2
defb &54,&fe,&2,&2
defb &54,&fe,&3,&2
defb &54,&fe,&4,&2
defb &54,&fe,&5,&2
defb &54,&fe,&6,&2
defb &54,&fe,&7,&2
defb &54,&fe,&8,&2
defb &54,&fe,&9,&2

;;------------------------------------------------------------------
;; reading with R wrapping (set EOT to 0 for example, also use with 1 and 2 etc)
defb 8
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 8,0,&f8,&2
defb 8,0,&f9,&2
defb 8,0,&fa,&2
defb 8,0,&fb,&2
defb 8,0,&fc,&2
defb 8,0,&fd,&2
defb 8,0,&fe,&2
defb 8,0,&ff,&2
defb 8,0,&00,&2


;;------------------------------------------------------------------
;; reading with EOT=0x0ff 
defb 9
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 9,0,&f7,&2
defb 9,0,&f8,&2
defb 9,0,&f9,&2
defb 9,0,&fa,&2
defb 9,0,&fb,&2
defb 9,0,&fc,&2
defb 9,0,&fd,&2
defb 9,0,&fe,&2
defb 9,0,&ff,&2


;;------------------------------------------------------------------
defb 10
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 10,0,&c1,&2
defb 10,0,&c2,&2
defb 10,0,&c3,&2
defb 10,0,&c4,&2
defb 10,0,&c5,&2
defb 10,0,&c6,&2
defb 10,0,&c7,&2
defb 10,0,&c8,&2
defb 10,0,&c9,&2

;;------------------------------------------------------------------
;; multitrack with h=1 and id starting from 1
defb 10
defb 1
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 10,1,&1,&2
defb 10,1,&2,&2
defb 10,1,&3,&2
defb 10,1,&4,&2
defb 10,1,&5,&2
defb 10,1,&6,&2
defb 10,1,&7,&2
defb 10,1,&8,&2
defb 10,1,&9,&2

;;------------------------------------------------------------------
defb 11
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 11,0,&c1,&2
defb 11,0,&c2,&2
defb 11,0,&c3,&2
defb 11,0,&c4,&2
defb 11,0,&c5,&2
defb 11,0,&c6,&2
defb 11,0,&c7,&2
defb 11,0,&c8,&2
defb 11,0,&c9,&2


;;------------------------------------------------------------------
defb 12
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 12,0,&c1,&2
defb 12,0,&c2,&2
defb 12,0,&c3,&2
defb 12,0,&c4,&2
defb 12,0,&c5,&2
defb 12,0,&c6,&2
defb 12,0,&c7,&2
defb 12,0,&c8,&2
defb 12,0,&c9,&2

;;------------------------------------------------------------------
;; single density
defb 13
defb 0
defb %00000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 13,0,&c1,&2
defb 13,0,&c2,&2
defb 13,0,&c3,&2
defb 13,0,&c4,&2
defb 13,0,&c5,&2
defb 13,0,&c6,&2
defb 13,0,&c7,&2
defb 13,0,&c8,&2
defb 13,0,&c9,&2

;; single density
defb 14
defb 0
defb %00000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 14,0,&c1,&2
defb 14,0,&c2,&2
defb 14,0,&c3,&2
defb 14,0,&c4,&2
defb 14,0,&c5,&2
defb 14,0,&c6,&2
defb 14,0,&c7,&2
defb 14,0,&c8,&2
defb 14,0,&c9,&2

;;-------------------------------------------------------
;; Data Error on sector 1 and not on sector 2
defb 16
defb 0
defb %01000000

defb 3
defb 2
defb def_format_gap
defb def_format_filler
defb 16,0,1,2
defb 16,0,2,3

;;----------------------------------------------------------
;; used for writing using status register
defb 17
defb 0
defb %01000000

defb 2
defb 2
defb def_format_gap
defb def_format_filler
defb 17,0,1,2
defb 17,0,2,3

;;----------------------------------------------------------
defb 18
defb 0
defb %01000000

defb 2
defb 3
defb def_format_gap
defb def_format_filler
defb &ff,0,1,2	;; bad cylinder
defb 18,0,2,2	;; correct cylinder
defb 34,0,3,2	;; wrong cylinder

;; -- scan but doesn't write
defb 19
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 19,0,&41,2 
defb 19,0,&42,2 
defb 19,0,&43,2 
defb 19,0,&44,2 
defb 19,0,&45,2 
defb 19,0,&46,2 
defb 19,0,&47,2 
defb 19,0,&48,2 
defb 19,0,&49,2 

;; -- scan but doesn't write
defb 20
defb 0
defb %01000000

defb 2
defb 9
defb def_format_gap
defb def_format_filler
defb 20,0,&41,2 
defb 20,0,&42,2 
defb 20,0,&43,2 
defb 20,0,&44,2 
defb 20,0,&45,2 
defb 20,0,&46,2 
defb 20,0,&47,2 
defb 20,0,&48,2 
defb 20,0,&49,2 


defb -1

;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
include "../../lib/output.asm"

if CPC=1
include "../cpc.asm"
include "../../lib/hw/cpc.asm"
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