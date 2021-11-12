
include "../../lib/testdef.asm"

org &1000

start:
ld hl,information
call output_msg
call output_nl
call wait_key

call cls
ld ix,tests
call run_tests
jp do_restart


information:
defb "This tests the vortex wd20 winchester hard disk",13,13
defb "This needs testing on a real device",13,13
defb "Press any key to continue"
defb 0

tests:
DEFINE_TEST "status register",status_reg_r
DEFINE_TEST "error register",error_reg_r
DEFINE_TEST "regs read",regs_read_r
DEFINE_TEST "sector count register r/w",sec_count_rw
DEFINE_TEST "sector number register r/w",sec_num_rw
DEFINE_TEST "cylinder low register r/w",cyl_low_rw
DEFINE_TEST "cylinder high register r/w",cyl_high_rw
DEFINE_TEST "sdh register r/w",sdh_rw
DEFINE_TEST "fafa register r/w",fafa_rw
DEFINE_TEST "datareg register r/w",datareg_rw
DEFINE_TEST "recalibrate command",recal_cmd
DEFINE_TEST "seek command",seek_cmd
DEFINE_TEST "read command",read_cmd
DEFINE_END_TEST

recal_cmd:
ret


seek_cmd:
ret
read_cmd:
ret

regs_read_r:
ld ix,result_buffer
ld bc,&f800
ld de,256*4
readreg:
in a,(c)
ld (ix+0),a
inc ix
inc bc
dec de
ld a,d
or a
jr nz,readreg
ld ix,result_buffer
ld bc,256*4
ld d,16
jp simple_number_grid

status_reg_r:
ld ix,result_buffer
ld bc,&fbfb
in a,(c)
ld (ix+0),a
inc ix
ld ix,result_buffer
ld bc,1
ld d,1
jp simple_number_grid

error_reg_r:
ld ix,result_buffer
ld bc,&f9f9
in a,(c)
ld (ix+0),a
inc ix
ld ix,result_buffer
ld bc,1
ld d,1
jp simple_number_grid


sec_count_rw:
ld ix,result_buffer

ld bc,&f9fa
ld e,&ff
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results

sdh_rw:
ld ix,result_buffer

ld bc,&fbfa
ld e,&ff
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results

fafa_rw:
ld ix,result_buffer

ld bc,&fafa
ld e,&ff
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results

datareg_rw:
ld ix,result_buffer

ld bc,&f9f8
ld e,&ff
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results


sec_num_rw:
ld ix,result_buffer

ld bc,&f9fb
ld e,&ff
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results

cyl_low_rw:
ld ix,result_buffer

ld bc,&faf8
ld e,&ff
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results

cyl_high_rw:
ld ix,result_buffer

ld bc,&faf9
ld e,&3
call port_rw_test

ld ix,result_buffer
ld bc,512
jp simple_results


include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
include "../../lib/output.asm"
include "../../lib/hw/fdc.asm"
include "../../lib/fw/output.asm"
include "../../lib/hw/cpc.asm"
include "wd20common.asm"

result_buffer equ $

end start