;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../lib/testdef.asm"

;; AY-3-8912 tester 
if CPC=1
org &2000
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

call cls
ld hl,message
call output_msg
call wait_key

call cls
ld ix,tests
call run_tests
call wait_key
rst 0


message:
defb "This is an automatic test.",13,13
defb "This test tests the registers of the AY-3-812 PSG and accessing it via the 8255 PPI.",13,13
defb "Press a key to start",0
;;-----------------------------------------------------

tests:
DEFINE_TEST "port A out r/w test", port_A_rw_test
DEFINE_TEST "port B out r/w test", port_B_rw_test
DEFINE_TEST "port A w through test", port_A_w_through_test
DEFINE_TEST "port B w through test", port_B_w_through_test
;; 0x0ff all the time
;; 0x0ff on kcc 
;;DEFINE_TEST "port B read", port_B_r_test
;; 0x0ff after register 16

;; kcc: correct value for first 16 registers then 
;; for it continues to count... 10 all the way to ff
;; plus, correct for all but 7 that reads c8. rest ff
;;DEFINE_TEST "reg read data report",read_reg_test

;;The YM2149 uses a 17 bit LFSR pseudo-random noise generator with taps on bits 17 and 14
;;http://listengine.tuxfamily.org/lists.tuxfamily.org/hatari-devel/2012/09/msg00045.html
DEFINE_TEST "reg write/read mask test",read_and_mask_test
DEFINE_TEST "invalid register write test",invalid_reg_write_test


;; failed, got 1, expected 0 on cpc6128 with type 0
;; on type 0 with switches, &17,&18 etc fail

;;DEFINE_TEST "register selection persistance",reg_select_persist

if CPC=1
DEFINE_TEST "psg inactive; PPI port A input, write PPI port A and read back", write_inactive_r
DEFINE_TEST "psg inactive; PPI port A output, write PPI port A and read back", write_inactive_w

DEFINE_TEST "psg select reg; PPI port A input, write PPI port A and read back", write_select_r
DEFINE_TEST "psg select reg; PPI port A output, write PPI port A and read back", write_select_w

DEFINE_TEST "psg read reg; PPI port A input, write PPI port A and read back", write_read_r
;;DEFINE_TEST "psg read reg; PPI port A output, write PPI port A and read back", write_read_w

DEFINE_TEST "psg write reg; PPI port A input, write PPI port A and read back", write_write_r

;; on type 2: 8 lots of 0, then 8, then 10, 18,20,28,30,38, etc repeat
DEFINE_TEST "psg write reg; PPI port A output, write PPI port A and read back", write_write_w

DEFINE_TEST "inactive write test, setup reg, ensure inactive doesn't change reg", write_inactive_reg
endif
;; on type 1, expected c0-ff got ff
;; on plus: got ff
;; on type 2: got ff
;;DEFINE_TEST "invalid register read/write test",read_invalid_reg_test

DEFINE_TEST "reg 8 h/w envelope update test", reg_8_upd_test
DEFINE_TEST "reg 9 h/w envelope update test", reg_9_upd_test
DEFINE_TEST "reg 10 h/w envelope update test", reg_10_upd_test

if CPC=1
;; see if Grim is correct by holding write and seeing if data is corrupted
DEFINE_TEST "psg hold write r0 (long test)",hold_w0
DEFINE_TEST "psg hold write r2 (long test)",hold_w2
DEFINE_TEST "psg hold write r4 (long test)",hold_w4
endif
DEFINE_END_TEST

hold_w0:
ld c,0
jp hold_w

hold_w2:
ld c,2
jp hold_w

hold_w4:
ld c,2
jp hold_w


;; TODO: need to turn on tone or similar to see if corruption happens?
hold_w:
di
ld ix,result_buffer

ld b,0
xor a
hw:
push bc

push bc

push bc
ld a,&ff
call write_psg_reg
pop bc

ld b,&f4
out (c),c
call set_psg_select_register
call set_psg_inactive

ld bc,&f433
out (c),c
call set_psg_write_data

ld e,4
hw2:
call vsync_sync
dec e
jr nz,hw2

pop bc
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),a
inc ix

pop bc
inc a
djnz hw

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results



reg_8_upd_test:
ld a,8
jp reg_upd_test

reg_9_upd_test:
ld a,9
jp reg_upd_test

reg_10_upd_test:
ld a,10
jp reg_upd_test


reg_upd_test:
di
ld c,a
push bc
ld ix,result_buffer

;; enable h/w envelopes for this channel
ld a,&10
call write_psg_reg

;; h/w envelope period
ld c,&0b
ld a,&30
call write_psg_reg

ld c,&0c
ld a,&00
call write_psg_reg

;; h/w envelope shape
ld c,&0d
ld a,&30
call write_psg_reg

pop bc

ld e,0
rut1:
push bc
;; keep reading to see if volume changes
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&10
inc ix
pop bc
inc e
jr nz,rut1

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results

;;-----------------------------------------------------
;; invalid register write test

invalid_reg_write_test:
di
ld ix,result_buffer
call fill_regs

ld e,16
irwt1:

;; write to register
ld c,e
ld a,&33
call write_psg_reg

;; expect no change
ld d,&16
call check_fill_regs
ld a,0
jr nc,irwt3
ld a,1
irwt3:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

inc e
jr nz,irwt1

call psg_restore
ei
ld ix,result_buffer
ld bc,256-16
jp simple_results

;;-----------------------------------------------------
;; check register values didn't change
;; returns carry flag set if they did
;; D = register to ignore
check_fill_regs:
push bc
push de
ld iy,reg_data
ld e,0
cfr1:
;; ignored register?
ld a,e
cp d
jr z,cfr3
;; not ignored
ld c,e
call read_psg_reg
cp (iy+0)
jr nz,cfr2

cfr3:
inc e
inc iy
ld a,e
cp 16
jr nz,cfr1
pop de
pop bc
or a
ret

cfr2:
pop de
pop bc
scf
ret

;;-----------------------------------------------------

fill_regs:
push de
push af
push bc
ld iy,reg_data
ld e,0
rsp1:
ld c,e
ld a,(iy+0)
inc iy
call write_psg_reg
inc e
ld a,e
cp 16
jr nz,rsp1
pop bc
pop af
pop de
ret

reg_data:
defb 1,2,3,4,5,6,7,%11001000,9,10,11,12,13,14,15,16

;;-----------------------------------------------------
;; tests register data written remains set
reg_select_persist:
di
ld ix,result_buffer

call fill_regs

;; run loop to ensure we fill register with data
;; checking what we wrote
ld e,1
loop_reg_select_persist_test:

;; select register 2
ld bc,&f402
out (c),c
call set_psg_select_register
call set_psg_inactive

;; write (no selecting reg)
ld b,&f4
out (c),e
call set_psg_write_data
call set_psg_inactive

;; read (no selecting reg)
ld bc,&f700+%10010010
out (c),c
call set_psg_read_data

ld b,&f4
in a,(c)
;; got
ld (ix+0),a
inc ix

;; expected
ld (ix+0),e
inc ix

;; inactive (no selecting reg)
call set_psg_inactive

;; back to write
ld bc,&f700+%10000010
out (c),c

ld d,2
call check_fill_regs
ld a,0
jr nc,lrsp
ld a,1
lrsp:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

inc e
jp nz,loop_reg_select_persist_test

call psg_restore
ei
ld ix,result_buffer
ld bc,256*2
jp simple_results

write_inactive_w:
call fill_num

;; port A as output
ld bc,&f700+%10000010
out (c),c

jr write_inactive

write_inactive_r:

call fill_ff

;; port A as input
ld bc,&f700+%10010010
out (c),c

jr write_inactive

fill_ff:
ld a,&ff
jr fill_all

fill_all:
ld ix,result_buffer
ld e,0
fff:
ld (ix+1),a
inc ix
inc ix
inc e
jr nz,fff
ret


fill_num:
ld ix,result_buffer
ld e,0
fnum:
ld (ix+1),e
inc ix
inc ix
inc e
jr nz,fnum
ret

;; write data to ppi port a in inactive mode and read-back. psg is in high impedance. What do we see?
write_inactive:
di
ld ix,result_buffer


ld c,7
ld a,&38
call write_psg_reg

ld bc,&f600
out (c),c

ld c,0
win:
ld b,&f4
out (c),c
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc c
jr nz,win

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results

write_select_w:
call fill_num

;; port A as output
ld bc,&f700+%10000010
out (c),c

jr write_select

write_select_r:
call fill_ff

;; port A as input
ld bc,&f700+%10010010
out (c),c

jr write_select



;; write data to ppi port a in select mode and read-back. What do we see?
write_select:
di
ld ix,result_buffer

ld c,7
ld a,&38
call write_psg_reg

ld bc,&f6c0
out (c),c

ld c,0
wse:
ld b,&f4
out (c),c
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc c
jr nz,wse

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results

write_write_w:
call fill_num
;; port A as output
ld bc,&f700+%10000010
out (c),c

jr write_write

write_write_r:
call fill_ff
;; port A as input
ld bc,&f700+%10010010
out (c),c

jr write_write



;; write data to ppi port a in inactive mode and read-back. psg is in high impedance. What do we see?
write_write:
di
ld ix,result_buffer


ld c,7
ld a,&38
call write_psg_reg

ld bc,&f680
out (c),c

ld c,0
wwe:
ld b,&f4
out (c),c
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc c
jr nz,wwe

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results


write_read_w:
;; ON GX4000
ld a,&38
call fill_all

;;call fill_num
;; port A as output
ld bc,&f700+%10000010
out (c),c

jr write_read

write_read_r:
call fill_ff

;; port A as input
ld bc,&f700+%10010010
out (c),c

jr write_read



;; write data to ppi port a in inactive mode and read-back. psg is in high impedance. What do we see?
write_read:
di
ld ix,result_buffer


ld c,7
ld a,&38
call write_psg_reg

ld bc,&f640
out (c),c

ld c,0
wre:
ld b,&f4
out (c),c
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc c
jr nz,wre

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results


;; write data to ppi port a in inactive mode and read-back. What do we see?
write_inactive_reg:
di
ld ix,result_buffer

ld b,0
ld e,0
wir1:
push de
push bc
;; select register 2
ld bc,&f402
out (c),c
call set_psg_select_register
call set_psg_inactive

ld b,&f4
out (c),e
call set_psg_write_data
call set_psg_inactive

;; write while inactive
ld bc,&f433
out (c),c

ld c,2
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
pop bc
pop de
inc e
djnz wir1

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results



;;-----------------------------------------------------

read_reg_test:
di
call fill_regs

ld ix,result_buffer
ld e,0
loop_reg_read_test:
ld c,e
call read_psg_reg
ld (ix+0),a
inc ix
inc e
jr nz,loop_reg_read_test
call psg_restore
ei
call report_positive
ld ix,result_buffer
ld bc,256
ld d,8
call simple_number_grid
ret

;;-----------------------------------------------------

read_invalid_reg_test:
di
ld ix,result_buffer
ld e,64
loop_i_reg_read_test:

ld d,256-16
lirrt1:
ld c,d ;; register
ld a,e
call write_psg_reg
ld c,d ;; register
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
inc d
jr nz,lirrt1

inc e
jr nz,loop_i_reg_read_test
call psg_restore
ei
ld ix,result_buffer
ld bc,64*(256-16)
jp simple_results

;;-----------------------------------------------------

;; read registers, check the and mask is valid and works as expected
read_and_mask_test:
di
ld iy,reg_masks
ld ix,result_buffer
ld e,0
loop_reg_and_mask_test:

;; write all possible data to this register
ld d,0
loop2_reg_and_mask_test:

;; write to register
ld c,e
ld a,d
call write_psg_reg

;; read it back
ld c,e
call read_psg_reg
ld (ix+0),a		;; got
inc ix
ld a,d
and (iy+0)
ld (ix+0),a		;; expected
inc ix

inc d
jr nz,loop2_reg_and_mask_test

inc iy
inc e
ld a,e
cp 16
jr nz,loop_reg_and_mask_test
call psg_restore
ei
ld ix,result_buffer
ld bc,256*16
jp simple_results
;;-----------------------------------------------------
;; register masks for ay-3-8912
reg_masks:
defb &ff,&0f,&ff,&0f,&ff,&0f,&1f,&ff,&1f,&1f,&1f,&ff,&ff,&0f,&ff,&ff

;;-----------------------------------------------------
;; for port B this should be 0x0ff all the time on AY-3-8912
port_B_r_test:
ld l,%00111111
ld d,15
jr psg_port_r_test

;;-----------------------------------------------------

psg_port_r_test:
di
ld ix,result_buffer
;; set i/o state
ld c,7
ld a,l
call write_psg_reg

ld a,e
ld c,d
call write_psg_reg

ld e,0
loop_psg_port_r_test:
ld c,d
call read_psg_reg
ld (ix+0),a
inc ix
inc e
jr nz,loop_psg_port_r_test
call psg_restore
ei
call report_positive

ld ix,result_buffer
ld bc,256
ld d,8
call simple_number_grid
ret
;;-----------------------------------------------------

port_A_rw_test:
ld l,%11111111
ld d,14
jr psg_port_rw_test

;;-----------------------------------------------------
port_B_rw_test:
ld l,%11111111
ld d,15
jr psg_port_rw_test
;;-----------------------------------------------------

;; port is in output mode, write data and read it back.
;; for port B on AY-3-8912 you should always get back what you read
;; for port A on AY-3-8912 and CPC you should get back what you read if no key is pressed
psg_port_rw_test:
di
ld ix,result_buffer
;; set i/o state
ld c,7
ld a,l
call write_psg_reg

ld e,0
loop_psg_port_rw_test:
ld a,e
ld c,d
call write_psg_reg
ld c,d
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,loop_psg_port_rw_test
call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results
;;-----------------------------------------------------

psg_restore:
ld c,7
ld a,%10111111
call write_psg_reg
ret

;;-----------------------------------------------------
port_A_w_through_test:
ld l,%001111111
ld h,%11111111
ld d,14
jr port_w_through_test

;;-----------------------------------------------------
port_B_w_through_test:
ld l,%001111111
ld h,%11111111
ld d,15
jr port_w_through_test
;;-----------------------------------------------------

;; set port to input, write data, set it to output and read it back.
;; should remain there and tests write through to latch.
port_w_through_test:
di
ld ix,result_buffer
ld e,0
loop_port_w_through_test:
;; set port to input
;; set i/o state
ld c,7
ld a,l
call write_psg_reg

;; write value to port
ld a,e
ld c,d
call write_psg_reg

;; set port to output
ld c,7
ld a,h
call write_psg_reg

;; read it
ld c,d
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,loop_port_w_through_test

call psg_restore
ei
ld ix,result_buffer
ld bc,256
jp simple_results
;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/outputdec.asm"
include "../lib/output.asm"
include "../lib/hw/fdc.asm"
if CPC=1
include "../lib/hw/psg.asm"
include "../lib/fw/output.asm"
include "../lib/hw/cpc.asm"
include "../lib/hw/crtc.asm"
endif
if SPEC=1
include "../lib/spec/psg.asm"
include "../lib/spec/init.asm"
include "../lib/spec/keyfn.asm"
include "../lib/spec/printtext.asm"
include "../lib/spec/readkeys.asm"
include "../lib/spec/scr.asm"
include "../lib/spec/writetext.asm"

sysfont:
incbin "../lib/spec/font.bin"

endif

result_buffer: equ $

end start

