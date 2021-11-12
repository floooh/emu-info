;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; This test causes the fdc to hang

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
DEFINE_TEST "read id (ready change)",read_id_rc
DEFINE_END_TEST

read_id_rc:
ret

test_disk_format_data:
defb -1

dd_test_disk_data
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