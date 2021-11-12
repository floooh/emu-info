;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;

include "../../lib/testdef.asm"

if CPC=1
org &1000
endif
if SPEC=1
org &8000
endif

start:
ld hl,copy_result_fn
ld (cr_functions),hl

if SPEC=1
call init
call write_text_init
ld h,32
ld l,24
call set_dimensions
endif
if CPC=1
ld a,2
call &bc0e
endif

call detect_fdc

call reset_specify

ld a,1
ld (stop_each_test),a
call cls
ld hl,information
call output_msg
call output_nl
call wait_key

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
defb "- Real drive (not HXC or Gotek)",13
defb "- disc is writeable (NOT write protected)",13
defb "- Make sure all other expansions are disconnected",13
defb 0

;; D765AC-2 results 
tests:
;; large over small
DEFINE_TEST "9 SC, Format N=1, ID N=3",large_over_small
;; gpl
DEFINE_TEST "9 SC, Format N=2, ID N=2, Write GPL>Format GPL",write_gpl
DEFINE_END_TEST


send_cmd:
push af
ld bc,&fb7e
in a,(c)
ld (ix+0),a
inc ix
inc ix
pop af

ld bc,&fb7f
out (c),a

push af
ld bc,&fb7e
in a,(c)
ld (ix+0),a
inc ix
inc ix
pop af

ld bc,&fb7f
in a,(c)
ld (ix+0),a
inc ix
inc ix
ret

read_result:
ld bc,&fb7e
rr1:
in a,(c)
and &c0
cp &c0
jr nz,rr1
ld (ix+0),a
inc ix
inc ix

xor a
ld bc,&fb7f
out (c),a
in a,(c)
ld (ix+0),a
inc ix
inc ix
ret

DEFINE_END_TEST

sds:
ld ix,result_buffer

ld a,4
call send_cmd
ld a,(drive)
call send_cmd


ld bc,&fb7e
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&fb7f
xor a
out (c),a

ld bc,&fb7e
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&fb7f
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&fb7f
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&fb7e
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,16
jp do_results


;; 3 and 4 replaced
res_large_over_small:
defb 7,&40,&80,&00,&00,&00,&02,&03
defb 7,0,0,0,0,0,6,3
defb 7,0,0,0,0,0,7,3
defb 7,0,0,0,0,0,8,3
defb 7,0,0,0,0,0,7,3
defb 7,0,0,0,0,0,9,3
defb 7,0,0,0,0,0,1,3
defb 7,0,0,0,0,0,2,3
defb 7,0,0,0,0,0,6,3
defb 7,0,0,0,0,0,7,3
defb &fe,&00

large_over_small:
call go_to_0
ld a,0
call go_to_track

ld a,0
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&2
ld (rw_r),a
ld (rw_eot),a
ld a,3
ld (rw_n),a
ld a,def_rw_gap
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld ix,result_buffer

call write_data
call get_results

ld b,9
los:
push bc
call read_id
call get_results
pop bc
djnz los

ld bc,8*9
jp do_results

;; not found because too close?
write_gpl:
call go_to_0
ld a,1
call go_to_track

ld a,1
ld (rw_c),a
xor a
ld (rw_h),a
ld a,&2
ld (rw_r),a
ld (rw_eot),a
ld a,2
ld (rw_n),a
ld a,&ff
ld (rw_gpl),a
ld a,&ff
ld (rw_dtl),a

ld ix,result_buffer

call write_data
call get_results

ld b,9
lgs:
push bc
call read_id
call get_results
pop bc
djnz lgs

ld bc,8*9
jp do_results

;;-----------------------------------------
test_disk_format_data:
defb 0
defb 0	
defb %01000000

defb 1
defb 9
defb &5
defb def_format_filler
defb 0,&0,&1,3
defb 0,&0,&2,3
defb 0,&0,&3,3
defb 0,&0,&4,3
defb 0,&0,&5,3
defb 0,&0,&6,3
defb 0,&0,&7,3
defb 0,&0,&8,3
defb 0,&0,&9,3

defb 1
defb 0	
defb %01000000

defb 2
defb 9
defb 5
defb def_format_filler
defb 1,&0,&1,2
defb 1,&0,&2,2
defb 1,&0,&3,2
defb 1,&0,&4,2
defb 1,&0,&5,2
defb 1,&0,&6,2
defb 1,&0,&7,2
defb 1,&0,&8,2
defb 1,&0,&9,2

defb -1

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