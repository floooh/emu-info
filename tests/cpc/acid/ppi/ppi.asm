;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../lib/testdef.asm"

txt_output equ &bb5a

;; TODO: Test mode 1 and mode 2 with printer and cassette

;; 8255 tester 
org &4000
start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

KCC equ 0

if KCC=1
ld a,&1f		;; KC Compact
endif
if KCC=0
ld a,&2f		;; CPC
endif
ld (port_c_input),a

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


message:
defb "This is an automatic test.",13,10,13,10
defb "This test tests the operation of the 8255 PPI.",13,10,13,10
defb "This test only runs on a CPC, KC Compact or Aleste.",13,10,13,10
defb "Tests run on English CPC6128 with 'Amstrad' name, no printer and cassette",13,10
defb "connected.",13,10,13,10
defb "Press a key to start",0

port_c_input:
defb 0

;; same results in my cpc6128 type 0 and type 1

;;-----------------------------------------------------

tests:

;; a0,a0,e0,a0,a0,b0: cpc6128 type 0
;; a0,40,a0,e0,a0,a0,b0: cpc6128 type 2
;; a0,a0,e0,a0,a0,b0 cpc464
;;DEFINE_TEST "mode 2: port a write", mode2_port_a_output

;; passed on kcc
;; passed on cpc6128 type 0
;; passed on cpc6128 type 1
;; type 3 shows: got 5e repeated
DEFINE_TEST "mode 2: port A mode 2, port B mode 0, port C bits output",mode2_mode0
;; type 3 shows: got de repeated
;; except near end which shows got 0,1,2,3,4,5,6,7 expected 7
DEFINE_TEST "mode 2: port A mode 2, port B mode 0, port C bits input",mode2_mode0_b

;; type 0, shows 0-7 repeated for 40 etc
;; type 1, shows 0-7 repeated for 40 etc


;; passed on kcc

;; type 3 shows: got de repeated
;; then got 40-47 when expecting 0
;; then got 40-47 when expecting 0, then 80-87 then c0-c7
;; got c0, expected 40
;; got 00, expected 40
;; got 00 expected 80
DEFINE_TEST "mode 1: port A mode 1 (input), port B mode 0, port C bits output",mode1_mode0_i
;; type 0, shows 0-7 repeated for 40 etc
;; type 1, shows 0-7 repeated for 40 etc
;; passed on kcc

;; type 3 shows: got de repeated
;; then got 10-17 when expecting 0,1,2,3,4,5,6,7
DEFINE_TEST "mode 1: port A mode 1 (output), port B mode 0, port C bits output",mode1_mode0_o

;; 8255 in cpc6128 type 0 passes 
;; 8255 in cpc6128 type 1 passes 
;; passed on kcc
DEFINE_TEST "mode 1: port A mode 1 (input), port B mode 0, port C bits input",mode1_mode0_i2
;; 8255 in cpc6128 type 0 passes 
;; 8255 in cpc6128 type 1 passes 
;; passed on kcc
DEFINE_TEST "mode 1: port A mode 1 (output), port B mode 0, port C bits input",mode1_mode0_o2
;; a2, 40, a2, e2, a2, a2, 5e, a0: cpc6128 type 2
;; a2,a2,e2,a2,a2,5e,a0,00: cpc6128 type 0
;;a2,a2,e2,a2,a2,00,a0,00: cpc6128 type 0 (switches)
;;a2,a2,e2,a2,a2,5e,a2: cpc664
;;a2,a2,e2,a2,a2,7e,a2: cpc464
;;DEFINE_TEST "mode 1: port a write", mode1_port_a_output
DEFINE_TEST "mode 0: bit set", bit_set_test 
DEFINE_TEST "mode 0: bit clear", bit_clear_test 
DEFINE_TEST "mode 0: psg control with bit set/reset", bit_psg 
DEFINE_TEST "mode 0: port a output latch r/w", output_latch_a
;; got de, expected.. 
DEFINE_TEST "mode 0: port b output latch r/w", output_latch_b 
;; ok
DEFINE_TEST "mode 0: port c output latch r/w", output_latch_c 


;; cpc664:
;; 2->1, 3->1, 4->1, 5->1, 6->1, 6->1, 8 = 0
;; 9,a,b = 1, c,d,e,f,10 = 0, 11 = 1, 12 = 1, 13 = 0 (1/0 up to 80)
;; 83 = e, 8b = e, 89 = 1, around 90 -> 0f, 5e, 5f

;; on type 0 ppi:
;; 0->0		;; bit 0 clear
		;; bit 0 set
;; 1->2		;; bit 1 clear
;; 4->3		;; bit 1 set
;; 4->4		;; bit 2 clear
;; 7->5		;; bit 2 set
;; 7->6
;; f->7
;; f->8
;; 1f,1f 9,a, 3f,3f, b,c, 7f,7f, d,e, ff,ff 0f 10
;; 10,11,12 etc: ff,fe,ff,fd,ff,fb,ff,f7,ff,ef,ff,df,ff  all the way up to 80
;; then: 
;; 00,0f,5e,5f,02,0a,02,0a,20,2f,7e,7f,22,2a,22,2a,ff,ff,ff,ff, all up to a0
;; 80,87,de,df,82,82,82,82,82,a0 for a8, a7 for a9, fe, ff 

;; same as type 2 for type 1 cpc 6128, and type 0 switches
;; cpc464 also
;; get 0 always on 8255 in type 2
;; 83 = e, 8b = e,  90 = 0, 91 = f, 92 - 5e, 93 = 5f, 
;;  94 = 2, 95 = a, 96 = 2, 97 = a, 98 = 20, 99 = 2f, 9a = 7e, 9b = 7f
;; 9c = 22, 9d = 2a, 9e = 22, 9f = 2a, a3 = 6, ab = 6
;; b0-> 20, 27, 7e, 7f, 22, 22,22,22,20,27,7e,7f, 22, 22, 22, 22
;; c3 = 6, cb = 6, d3 = 6, db = 6, e3 = 6, eb = 6, f3 = 6, fb = 6

;; 
;; kcc:
;; shows 0 for 0-&c
;; &7f for &0d and &0e
;; &40 for &0f to &1b
;; &00 for &1c
;; &40 for &1d to &2b
;; &00 for &2c
;; &40 for &2d to &3b
;; &00 for &3c
;; &40 for &3d to &4b
;; &00 for &4c
;; &40 for &4d to &5b
;; &00 for &5c
;; &40 for &5d to &6b
;; &00 for &6c
;; &40 for &6d to &7b
;; &00 for &7c
;; &40 for &7d to &7f
;; &00 for &80,&81,&82
;; &0a for &83
;; &00 for &84 to &89
;; &8a is &10
;; &8b is &1a
;; &00 for &8c to &92
;; &0a for &93
;; &00 for &94 to &99
;; &9a is &10
;; &9b is &1a
;; &00 for &9c to &a2
;; &02 for &a3
;; &00 for &a4 to &a9
;; &aa is &10
;; &ab is &12
;; &00 for &ac to  &b1
;; &b2 is &20
;; &b3 is &22
;; &00 for &b4 to  &b9
;; &ba is &20
;; &bb is &22
;; &00 for &bc to  &c1
;; &c2 is &20
;; &c3 is &22
;; &00 for &c4 to  &c9
;; &ca is &20
;; &cb is &22
;; &00 for &cc to  &d1
;; &d2 is &20
;; &d3 is &22
;; &00 for &d4 to  &d9
;; &da is &20
;; &db is &22
;; same pattern until &ff



;; got 0, 90 shows ff and repeats ff 00 


;;DEFINE_TEST "ppi control r/w", ppi_control_test

;; got value, expected 0
DEFINE_TEST "mode 0: port a control write reset test", port_a_control_reset
;; type 3 shows got de, expected..
DEFINE_TEST "mode 0: port b control write reset test", port_b_control_reset
;; got 1,2,3,4,5,6,7 etc
DEFINE_TEST "mode 0: port c control write reset test", port_c_control_reset

;; 0x0ff all the time (type 2)
;; &00 all the time for kcc
;; ff for cpc ;; fixed on plus

;;DEFINE_TEST "mode 0: port a read", port_a_read 
;; 5e/5f all the time; type 2 cpc6128
;; fa on kcc
;; de on plus
;;DEFINE_TEST "mode 0: port b read", port_b_read
;; 2f all the time type 2 and type 1 cpc6128
;; 1f on kcc
;; 0 on plus
;;DEFINE_TEST "mode 0: port c read", port_c_read 


DEFINE_TEST "mode 0: port a read", port_a_write_when_read 
;; 5e/5f all the time; type 2 cpc6128
;; fa on kcc
;; de on plus
;; todo: fix, vsync gets in the way and sometimes cassette write
DEFINE_TEST "mode 0: port b read (vsync off)", port_b_vof_write_when_read
DEFINE_TEST "mode 0: port b read (vsync on)", port_b_von_write_when_read
;; 2f all the time type 2 and type 1 cpc6128
;; 1f on kcc
;; 0 on plus
DEFINE_TEST "mode 0: port c read", port_c_write_when_read 

;; 0-ff on plus
DEFINE_TEST "mode 0: port c mixed input/output", port_c_mixed

;; &aa on kcc
DEFINE_TEST "mode 0: ppi port a output", port_a_output
;; 0x07f in type 2 and type 1 cpc6128 and cpc664
;; 0x0ff in type 0 cpc6128.. depends on last value written though???
;; 0x01a on kcc
;; ff in plus
;;DEFINE_TEST "ppi control read", ppi_control_read 
;; pass on ppi in type 2
DEFINE_TEST "ppi port reset from control",ppi_port_reset
DEFINE_TEST "ppi i/o decode (f5xx)",ppi_io_decode


DEFINE_END_TEST


ppi_io_decode:
ld bc,ppi_restore
ld hl,&f5ff
ld de,&0b00
ld ix,ppi_dec_test
ld iy,ppi_dec_init
jp io_decode

ppi_restore:
ret

ppi_dec_init:
ld b,&f5
in a,(c)
and %00111110
ld (val_f5+1),a
ret

ppi_dec_test:
in a,(c)
and %00111110
val_f5:
cp 0
ret

ppi_port_reset:
di
ld ix,result_buffer

ld c,0
ld a,&11
call write_psg_reg


;; write->write
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f433
out (c),c
ld bc,&f680
out (c),c
;; port a changed to write from write
ld bc,&f700+%10000000
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,0
ld a,&11
call write_psg_reg

;; write->write
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f433
out (c),c
ld bc,&f680
out (c),c
;; port a changed to write from write
ld bc,&f700+%10000000
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,0
ld a,&11
call write_psg_reg

;; write->read
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f433
out (c),c
ld bc,&f680
out (c),c
;; port a changed to read from write
ld bc,&f700+%10010000
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,0
ld a,&11
call write_psg_reg

;; write->read
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f433
out (c),c
ld bc,&f680
out (c),c
;; port a changed to read from write
ld bc,&f700+%10010000
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,0
ld a,&11
call write_psg_reg

;; read->read
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f433
out (c),c
ld bc,&f640
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,0
ld a,&11
call write_psg_reg

;; read->read
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f433
out (c),c
ld bc,&f640
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix


ld c,0
ld a,&11
call write_psg_reg

;; read->write
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f640
out (c),c
ld bc,&f422
out (c),c
ld bc,&f700+%10000000
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,0
ld a,&11
call write_psg_reg

;; read->write
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f640
out (c),c
ld bc,&f422
out (c),c
ld bc,&f700+%10000000
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

call restore_ppi

ei
ld hl,result_buffer
ld bc,8
call simple_results
ret

port_c_mixed:
di
ld ix,result_buffer
;; high 4-bits are output, lower 4 bits are inputs
ld bc,&f700+%10000001
out (c),c

ld e,0

ld b,&f6
in a,(c)
and &f
ld d,a

loop_port_c_mixed:
;; output data
out (c),e
;; read back from port
in a,(c)
ld (ix+0),a
inc ix
;; upper 4 bits are programmed value
;; lower 4 bits are value read
ld a,e
and &f0
or d
ld (ix+0),a
inc ix
inc e
jr nz,loop_port_c_mixed

;; high 4-bits are output, lower 4 bits are inputs
ld bc,&f700+%10001000
out (c),c

ld e,0

ld b,&f6
in a,(c)
and &f0
ld d,a

loop2_port_c_mixed:
;; output data
out (c),e
;; read back from port
in a,(c)
ld (ix+0),a
inc ix
;; upper 4 bits are programmed value
;; lower 4 bits are value read
ld a,e
and &f
or d
ld (ix+0),a
inc ix
inc e
jr nz,loop2_port_c_mixed

call restore_ppi

ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret

;;-----------------------------------------------------
;; 1. write a value to psg register 0
;; 2. port ppi port a into input mode
;; 3. signal write to psg (data should be put into register)
;; 4. read data from psg register to see what we got
;;
;; tests what data is seen on ppi port a outputs when it is set to input mode
port_a_output:
di
ld ix,result_buffer
ld e,0

loop_port_a_output:
push de
;; restore ppi
ld bc,&f782
out (c),c

;; write data to psg
ld c,0
ld a,&aa
call write_psg_reg

;; ppi port a into input mode
ld bc,&f700+%10010010
out (c),c

;; write data to port a
ld b,&f4
out (c),e

;; write data to register
call set_psg_write_data
;; set inactive
call set_psg_inactive

ld c,0
call read_psg_reg
ld (ix+0),a				;; got
inc ix
ld (ix+0),&ff				;; expected
inc ix
pop de
inc e
jr nz,loop_port_a_output
call restore_ppi

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


;;-----------------------------------------------------
;; 1. write values to psg register 0
;; 2. use bit set to set read/write and restore inactive

bit_psg:
di
ld ix,result_buffer
ld e,0

loop_bit_psg:
push de
;; restore ppi
ld bc,&f782
out (c),c

;; select reg 0
ld bc,&f400
out (c),c

;; select register
call set_psg_select_register
call set_psg_inactive

;; write data to port a
ld b,&f4
out (c),e

;; write data
ld bc,&f700+(7*2)+1
out (c),c
;; inactive
ld bc,&f700+(7*2)+0
out (c),c

;; ppi port a into input mode
ld bc,&f700+%10010010
out (c),c

;; read data
ld bc,&f700+(6*2)+1
out (c),c

;; get data
ld b,&f4
in a,(c)

;; inactive
ld bc,&f700+(6*2)+0
out (c),c

ld (ix+0),a				;; got
inc ix
ld (ix+0),e				;; expected
inc ix
pop de
inc e
jr nz,loop_bit_psg

call restore_ppi

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


;;------------------------------------------------------------------------

mode1_mode0_i:
di
ld ix,result_buffer
;; port A mode 1,
;; port B is mode 0.
;; check bits in port C
ld bc,&f700+%10110000
out (c),c

;; check port B first acts like mode 0
ld e,0
ld b,&f5
md1md0a:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,md1md0a

;; data written to bits 7,6 and 2,1,0 are latched (mode 0) 
ld b,&f6
ld e,0
md1md0b:
;; this write only effects 2,1,0!
out (c),e
in a,(c)
and %11000111
ld (ix+0),a
inc ix
ld a,e
and %00000111
ld (ix+0),a
inc ix
inc e
jr nz,md1md0b

;; bit 6,7 are set by bit set/reset!
;; set bit 6
ld bc,&f700+(6*2)+1
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%1000000
inc ix

;; clear bit 6
ld bc,&f700+(6*2)+0
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; set bit 7
ld bc,&f700+(7*2)+1
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%10000000
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%10000000
inc ix

;; clear bit 7
ld bc,&f700+(7*2)+0
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; set bit 7
ld bc,&f700+(7*2)+1
out (c),c
;; set bit 6
ld bc,&f700+(6*2)+1
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),%11000000
inc ix

;; clear bit 7
ld bc,&f700+(7*2)+0
out (c),c
;; clear bit 6
ld bc,&f700+(6*2)+0
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

call restore_ppi
ei
ld ix,result_buffer
ld bc,256+256+8
call simple_results
ret

;;------------------------------------------------------------------------

mode1_mode0_o:
di
ld ix,result_buffer
;; port A mode 1,
;; port B is mode 0.
;; check bits in port C
ld bc,&f700+%10100000
out (c),c

;; check port B first acts like mode 0
ld e,0
ld b,&f5
md1md0a2:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,md1md0a2

;; data written to 2,1,0 are latched (mode 0) 
ld b,&f6
ld e,0
md1md0b2:
;; only effects 2,1,0
out (c),e
in a,(c)
and %110111
ld (ix+0),a
inc ix
ld a,e
and %000111
ld (ix+0),a
inc ix
inc e
jr nz,md1md0b2

;; bit 4,5 are set by bit set/reset!
;; set bit 4
ld bc,&f700+(4*2)+1
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),%10000
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),%10000
inc ix

;; clear bit 4
ld bc,&f700+(4*2)+0
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; set bit 5
ld bc,&f700+(5*2)+1
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),%100000
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),%100000
inc ix

;; clear bit 5
ld bc,&f700+(5*2)+0
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; set bit 5
ld bc,&f700+(5*2)+1
out (c),c
;; set bit 4
ld bc,&f700+(4*2)+1
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),%110000
inc ix

;; clear bit 5
ld bc,&f700+(5*2)+0
out (c),c
;; clear bit 4
ld bc,&f700+(4*2)+0
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix


call restore_ppi
ei
ld ix,result_buffer
ld bc,256+256
call simple_results
ret

;;------------------------------------------------------------------------

mode1_mode0_i2:
di
ld ix,result_buffer
;; port A mode 1,
;; port B is mode 0.
;; check bits in port C
ld bc,&f700+%10111001
out (c),c

;; check port B first acts like mode 0
ld e,0
ld b,&f5
md1md0a22:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,md1md0a22

ld b,&f6
ld e,0
md1md0b22:
out (c),e
in a,(c)
and %11000111
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000111
ld (ix+0),a
inc ix
inc e
jr nz,md1md0b22


;; bit 6,7 are set by bit set/reset!
;; set bit 6
ld bc,&f700+(6*2)+1
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; clear bit 6
ld bc,&f700+(6*2)+0
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; set bit 7
ld bc,&f700+(7*2)+1
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; clear bit 7
ld bc,&f700+(7*2)+0
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; set bit 7
ld bc,&f700+(7*2)+1
out (c),c
;; set bit 6
ld bc,&f700+(6*2)+1
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix

;; clear bit 7
ld bc,&f700+(7*2)+0
out (c),c
;; clear bit 6
ld bc,&f700+(6*2)+0
out (c),c
ld b,&f6
in a,(c)
and %11000000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %11000000
ld (ix+0),a
inc ix




call restore_ppi
ei
ld ix,result_buffer
ld bc,256+256+8
call simple_results
ret

;;------------------------------------------------------------------------

mode1_mode0_o2:
di
ld ix,result_buffer
;; port A mode 1,
;; port B is mode 0.
;; check bits in port C
ld bc,&f700+%10101001
out (c),c

;; check port B first acts like mode 0
ld e,0
ld b,&f5
md1md0a222:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,md1md0a222

;; data written to bits 5,4 and 2,1,0 are latched (mode 0) 
ld b,&f6
ld e,0
md1md0b222:
out (c),e
in a,(c)
and %110111
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110111
ld (ix+0),a
inc ix
inc e
jr nz,md1md0b222

;; bit 4,5 are set by bit set/reset!
;; set bit 4
ld bc,&f700+(4*2)+1
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; clear bit 4
ld bc,&f700+(4*2)+0
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; set bit 5
ld bc,&f700+(5*2)+1
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; try and clear the bit.. this should fail
xor a
out (c),a
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; clear bit 5
ld bc,&f700+(5*2)+0
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; set bit 5
ld bc,&f700+(5*2)+1
out (c),c
;; set bit 4
ld bc,&f700+(4*2)+1
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix

;; clear bit 5
ld bc,&f700+(5*2)+0
out (c),c
;; clear bit 4
ld bc,&f700+(4*2)+0
out (c),c
ld b,&f6
in a,(c)
and %110000
ld (ix+0),a
inc ix
ld a,(port_c_input)
and %110000
ld (ix+0),a
inc ix



call restore_ppi
ei
ld ix,result_buffer
ld bc,256+256+8
call simple_results
ret

;;------------------------------------------------------------------------

mode2_mode0:
di
;; port A mode 2,
;; port B is mode 0.
;; check bits in port C
ld bc,&f700+%11000000
out (c),c
ld ix,result_buffer
;; check port B first acts like mode 0
ld e,0
ld b,&f5
md2md0a:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,md2md0a

;; data written to bits 2,1,0 are latched (mode 0) 
ld b,&f6
ld e,0
md2md0b:
out (c),e
in a,(c)
and &7
ld (ix+0),a
inc ix
ld a,e
and &7
ld (ix+0),a
inc ix
inc e
ld a,e
cp 8
jr nz,md2md0b

call restore_ppi
ei
ld ix,result_buffer
ld bc,256+8
call simple_results
ret

;;------------------------------------------------------------------------

mode2_mode0_b:
di
ld ix,result_buffer
;; port A mode 2,
;; port B is mode 0.
;; check bits in port C
ld bc,&f700+%11000001
out (c),c

;; check port B first acts like mode 0
ld e,0
ld b,&f5
md2md0a2:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,md2md0a2

;; data written to bits 2,1,0 are inputs (mode 0) 
ld b,&f6
ld e,0
md2md0b2:
out (c),e
in a,(c)
and &7
ld (ix+0),a
inc ix
ld (ix+0),7
inc ix
inc e
ld a,e
cp 8
jr nz,md2md0b2

call restore_ppi
ei
ld ix,result_buffer
ld bc,256+8
call simple_results
ret

;;-----------------------------------------------------
;; mode 2 - bidirectional
;;  /obf goes low when write is done
;; port A is high impedance, data not yet written
;;
;; /ack; high of port Acleared, data goes out
;; back to high level, goes back to high
;; 
;; /stb; low; data from outside is latched
;; cleared with read
;;
;; obf (pc7)
;; ack pc6
;; stb pc4
;; ibf pc5

;; set inte1, inte2 using bit set
;; intra

mode2_port_a_output:
di

;; write data to psg
;;ld c,0
;;ld a,&aa
;;call write_psg_reg

ld bc,&f700+%11000000
out (c),c
ld ix,result_buffer
ld d,3

;; 00
;; obf should be high, so if we read, we get high impedance
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

;; a0
;; check /obf is high
ld b,&f6
in a,(c)
and %11111000
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

;; write data
ld b,&f4
out (c),d

in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix

;; write data to register
;;call set_psg_write_data
;; set inactive
;;call set_psg_inactive

;; a0 type 1
;; check /obf has gone low
ld b,&f6
in a,(c)
and %11111000
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

;; inte1 for output
ld bc,&f700+(6*2)+1					;; bit 6 for inte1 (output)
out (c),c
;; inte2 for input
ld bc,&f700+(4*2)+0					;; bit 4 for inte2 (input)
out (c),c

;; e0 type 1
;; look at status for interrupt
ld b,&f6
in a,(c)
and %11111000
ld (ix+0),a
inc ix
ld (ix+0),4
inc ix

;; a0 type 1
;; look at status for interrupt
;; inte1 for output
ld bc,&f700+(6*2)+0					;; bit 6 for inte1 (output)
out (c),c
ld b,&f6
in a,(c)
and %11111000
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

;; look at status for interrupt
;; a0
ld b,&f6
in a,(c)
and %11111000
ld (ix+0),a
inc ix
ld (ix+0),4
inc ix

;; b0 type 1
;; look at status for interrupt
;; inte2 for input
ld bc,&f700+(4*2)+1					;; bit 4 for inte2 (input)
out (c),c

;; b0
ld b,&f6
in a,(c)
and %11111000
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

call restore_ppi
ei
ld ix,result_buffer
ld bc,200
call simple_results
ret


;;-----------------------------------------------------
;; mode 1

;; input:
;;
;; port a:
;; intea = pc4
;; stba = pc4
;; ibfa = pc5
;; intr = pc3
;;
;; port b:
;; inteb = pc2
;; stbb = pc2
;; ibfb = pc1
;; intr = pc0
;;
;; output:
;;
;; port a:
;; obfa = pc7
;; acka = pc6
;; intra = pc3
;; intea = pc6
;;
;; port b:
;; obfb = pc1
;; ackb = pc2
;; intrb = pc0
;; inteb = pc2

mode1_port_c_tests:


mode1_port_a_output:

di
;; port A output, port B output
;; pc4,pc5 are input
ld bc,&f700+%10101101
out (c),c
ld d,3

ld ix,result_buffer
;; 00
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

;; check initial value
;; /ack is low, so /obf should be high to indicate it's read it in
;; it is 80
ld b,&f6
in a,(c)
and %11001000
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

;; write data
ld b,&f4
out (c),d
;; it is d
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix

;; 80 on type 1
;; check /obf has gone low
ld b,&f6
in a,(c)
and %11001000
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

;; it is
;; write data
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix

;; intea for output
ld bc,&f700+(6*2)+1		;; inte for group a 
out (c),c

;; look at status for interrupt
;; c0
ld b,&f6
in a,(c)
and %11001000
ld (ix+0),a
inc ix
ld (ix+0),8
inc ix

;; look at status for interrupt
;; inte1 for output
ld bc,&f700+(6*2)+0			;; inte for group a
out (c),c
;; 80
ld b,&f6
in a,(c)
and %11001000
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

;;-----------------------------
;; 00
ld b,&f5
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

;; write to port B
;; check /obf is high
;; 00
ld b,&f6
in a,(c)
and &3
ld (ix+0),a
inc ix
ld (ix+0),2
inc ix

;; write data
ld b,&f5
out (c),d

;; it is d
in a,(c)
and &3
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix

;; 00 type 1
;; check /obf has gone low
ld b,&f6
in a,(c)
and &3
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

;; inte1 for output
ld bc,&f700+(2*2)+1		;; inteb for group b
out (c),c

;; 0
;; look at status for interrupt
ld b,&f6
in a,(c)
and &3
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

;; look at status for interrupt
;; inte1 for output
ld bc,&f700+(2*2)+0		;; inteb for group b
out (c),c

;; it is 0
ld b,&f6
in a,(c)
and &3
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix


call restore_ppi
ei
ld ix,result_buffer
ld bc,200
call simple_results

ret
;; read port c status

;;-----------------------------------------------------
;; this checks if port A outputs are reset to 0 when ppi control is set
port_a_control_reset:
ld b,&f4
jr ppi_control_reset

;;-----------------------------------------------------
;; this checks if port B outputs are reset to 0 when ppi control is set
port_b_control_reset:
ld b,&f5
jr ppi_control_reset

;;-----------------------------------------------------
;; this checks if port C outputs are reset to 0 when ppi control is set
port_c_control_reset:
ld b,&f6
jr ppi_control_reset

;;-----------------------------------------------------

;; check if a port's outputs are reset to 0 when ppi control is set
;; some models of 8255 may disagree what actually happens.
;;
;; this sets port to output, writes value, sets back to output
;; then sets port to output, writes value, sets back to input.

ppi_control_reset:
di
push bc
ld bc,&f700+%10000000
out (c),c
pop bc
ld ix,result_buffer
;; all are output, set new control, are they reset?

push bc
;; test all values are reset on port A
ld l,%10000000
ld h,%10000000
call reset_tester
pop bc
ld l,%10011011
ld h,%10000000
call reset_tester
call restore_ppi
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret

;;-----------------------------------------------------

;; B = port to write to
;; L = control port value
;; E = value
reset_tester:

ld e,0			;; counter

reset_loop:
push bc
;; set all ports to output first
ld b,&f7
ld a,%10000000
out (c),a
pop bc

;; write value to port 
out (c),e

;; write control which should perform reset
push bc
ld b,&f7
out (c),l	;; change to state wanted
out (c),h	; and restore
pop bc

in a,(c)
ld (ix+0),a	;; got
inc ix
ld (ix+0),0 ;; expected
inc ix

inc e
jr nz,reset_loop
ret

;;-----------------------------------------------------

output_latch_a:
di
push bc
ld bc,&f700+%10000000
out (c),c
pop bc
ld b,&f4
jp output_latch_ppi

;;-----------------------------------------------------

output_latch_b:
di

push bc
ld bc,&f700+%10000000
out (c),c
pop bc
ld b,&f5
jp output_latch_ppi

;;-----------------------------------------------------

output_latch_c:
di
push bc
ld bc,&f700+%10000000
out (c),c
pop bc

ld b,&f6
jp output_latch_ppi

;;-----------------------------------------------------

ppi_control_test:
di

;; should report those nice values for +
push bc
ld bc,&f700+%10000000
out (c),c
pop bc

ld b,&f7
jp output_latch_ppi

;;-----------------------------------------------------

output_latch_ppi:
ld ix,result_buffer
ld e,&ff
call port_rw_test
call restore_ppi

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

;;-----------------------------------------------------

restore_ppi:
;; restore operating mode and port directions
ld bc,&f782
out (c),c
;; ppi in inactive state, tape motor off, keyboard line 0
ld bc,&f600
out (c),c
;; restore reg 7 setting
ld c,7
ld a,%00111111
call write_psg_reg
ei
;; ensure no keys are pressed
call flush_keyboard
ret

;;-----------------------------------------------------

port_a_read:
ld b,&f4
jr input_port_read

;;-----------------------------------------------------

port_b_read:
ld b,&f5
jr input_port_read

;;-----------------------------------------------------

port_c_read:
ld b,&f6
jr input_port_read

port_a_write_when_read:
ld b,&f4
jr write_when_read

port_b_vof_write_when_read:
;; vsync off
ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c

ld b,&f5
jr write_when_read


port_b_von_write_when_read:
;; vsync on, 16 line length, never shuts off
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00
out (c),c

ld b,&f5
jr write_when_read

port_c_write_when_read:
ld b,&f6
jr write_when_read


write_when_read:
di
push bc
ld bc,&f700+%10011011
out (c),c
pop bc

;; expected; if value changes this is not going to be reliable..
;; but we need to ensure it's not the value written
in a,(c)
ld d,a

ld ix,result_buffer
ld e,0
wwr1:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
inc e
jr nz,wwr1

call restore
call restore_ppi
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret
;;-----------------------------------------------------

ppi_control_read:
ld b,&f7
jr input_port_read

;;-----------------------------------------------------

input_port_read:
di
push bc
ld bc,&f700+%10011011
out (c),c
pop bc
ld ix,result_buffer
call port_r_test
call restore_ppi

ei
call report_positive
ld ix,result_buffer
ld bc,256
ld d,8
call simple_number_grid
ret

;;-----------------------------------------------------
;; test the bit set feature of the ppi in mode 0
bit_set_test:
di
ld bc,&f700+%10000000
out (c),c
ld ix,result_buffer

ld e,0
call bit_set_tester

ld e,&aa
call bit_set_tester

call restore_ppi
ei
ld ix,result_buffer
ld bc,8*2
call simple_results
ret

;;-----------------------------------------------------

;; E = value
bit_set_tester:

ld c,0			;; counter

bit_set_loop:
;; write value to port 
ld b,&f6
out (c),e

;; perform bit set
ld b,&f7

ld a,c		;; bit to set
add a,a 	;; into bits b1,b2,b3
or 1		;; set function
out (c),a 	;; set that bit

call to_or_mask
;; A = or mask for bit
or e
ld (ix+1),a	;; expected

ld b,&f6
in d,(c) ;; read data
ld (ix+0),d	;; got
inc ix
inc ix

inc c
ld a,c
cp 8
jr nz,bit_set_loop
ret

;;-----------------------------------------------------
;; test the bit clear feature of the ppi in mode 0

bit_clear_test:
di
ld ix,result_buffer
ld bc,&f700+%10000000
out (c),c

ld e,&ff
call bit_clear_tester

ld e,&aa
call bit_clear_tester

call restore_ppi
ei
ld ix,result_buffer
ld bc,8*2
call simple_results
ret

;;-----------------------------------------------------


bit_clear_tester:
ld c,0

bit_clear_loop:
;; clear port f6
ld b,&f6
out (c),e

;; perform bit set
ld b,&f7

ld a,c	;; bit to set
add a,a ;; into bits b1,b2,b3
and &fe	;; bit 0 -> 0 for clear function
out (c),a ;; clear that bit

call to_and_mask
and e
ld (ix+1),a		;; expected

ld b,&f6
in d,(c)
ld (ix+0),d		;; got
inc ix
inc ix

inc c
ld a,c
cp 8
jr nz,bit_clear_loop
ret


;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/portdec.asm"
include "../lib/hw/crtc.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $

end start
