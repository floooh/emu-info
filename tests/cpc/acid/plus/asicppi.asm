;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

;; ASIC PPI tester 
org &4000
start:


ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;; on gx4000 it's all zeros
port_c_input:
defb 0

;;-----------------------------------------------------

tests:

DEFINE_TEST "mode 0: bit set", bit_set_test 
DEFINE_TEST "mode 0: bit clear", bit_clear_test 
DEFINE_TEST "mode 0: psg control with bit set/reset", bit_psg 
DEFINE_TEST "mode 0: port a output latch r/w", output_latch_a
DEFINE_TEST "mode 0: port b output latch r/w", output_latch_b 
DEFINE_TEST "mode 0: port c output latch r/w", output_latch_c 
;; got 0 expect ff, then other times it does pattern
DEFINE_TEST "ppi control r/w", ppi_control_test
DEFINE_TEST "mode 0: port a control write reset test", port_a_control_reset
DEFINE_TEST "mode 0: port b control write reset test", port_b_control_reset
DEFINE_TEST "mode 0: port c control write reset test", port_c_control_reset
;; ff for plus
DEFINE_TEST "mode 0: port a read", port_a_read 
;; de/fe on plus
DEFINE_TEST "mode 0: port b read", port_b_read
;; 0 on plus
DEFINE_TEST "mode 0: port c read", port_c_read 


DEFINE_TEST "mode 0: port a write when read", port_a_write_when_read 
;; de on plus or fe on gx4000 so could fail
;; could be ff too
DEFINE_TEST "mode 0: port b write when read", port_b_write_when_read

DEFINE_TEST "mode 0: port c write when read", port_c_write_when_read 

DEFINE_TEST "mode 0: port c mixed input/output", port_c_mixed

DEFINE_TEST "mode 0: ppi port a output", port_a_output

DEFINE_TEST "ppi control read", ppi_control_read 

DEFINE_TEST "ppi write order",ppi_write_order

;; need to do more testing on more plus machines
;;DEFINE_TEST "ppi control (psg)", ppi_control_psg

DEFINE_TEST "ppi i/o decode (f5xx)",ppi_io_decode

DEFINE_END_TEST



ppi_io_decode:
di
ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl

ld b,&f5
in a,(c)
and %00111110
ld (val_f5+1),a

ld de,0
ld bc,0
nextloop:
push bc
push de
push hl
call restore

pop hl
pop de
pop bc
in a,(c)
and %00111110
val_f5:
cp 0
jr nz,next

;; success
push hl
push bc
ld hl,(portsuccessOR)
ld a,h
or b
ld h,a
ld a,l
or c
ld l,a
ld (portsuccessOR),hl
ld hl,(portsuccessAND)
ld a,h
and b
ld h,a
ld a,l
and c
ld l,a
ld (portsuccessAND),hl
pop bc
pop hl

next:
inc bc
dec de
ld a,d
or e
jr nz,nextloop

ld hl,(portsuccessOR)
ld de,(portsuccessAND)
ld a,h
xor d
cpl
ld h,a
ld a,l
xor e
cpl
ld l,a
ld (portimportant),hl

call restore
ei
ld de,(portimportant)
ld hl,(portsuccessOR)
ld b,16
dl1:
push bc
push hl
push de
bit 7,d		;; important??
ld a,'x'
jr z,dl2
;; yes important, but what value?
bit 7,h
ld a,'1'
jr nz,dl2
ld a,'0'
dl2:
call &bb5a
pop de
pop hl
pop bc
add hl,hl
ex de,hl
add hl,hl
ex de,hl
djnz dl1

ld a,'-'
call &bb5a
ld ix,result_buffer
ld de,(portimportant)
ld (ix+0),e
ld (ix+1),&00
ld (ix+2),d
ld (ix+3),&0b
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&ff
ld (ix+6),h
ld (ix+7),&f5
ld bc,4
call simple_results

ret

restore:
;; rom
ld bc,&df00
out (c),c
;; mode/rom
ld bc,&7f00+%10001110
out (c),c
;; pal
ld bc,&7fc0
out (c),c
;; palette
ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c
ld bc,&7f01
out (c),c
ld bc,&7f4b
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c
ld bc,&f700+%10000010
out (c),c
ld bc,&f600
out (c),c

call crtc_reset
ret

portsuccessOR:
defw 0
portsuccessAND:
defw 0

portimportant:
defw 0


;;-------------------------------------------

crtc_reset:
ld hl,crtc_default_values
ld b,16
ld c,0
cr1:
push bc
ld b,&bc
out (c),c
inc b
ld a,(hl)
inc hl
out (c),a
pop bc
inc c
djnz cr1
ret

crtc_default_values:
defb 63,40,46,&8e,38,0,25,30,0,7,0,0,&30,0,0,0,0


ppi_write_order:
di
ld ix,result_buffer

;; write data to psg
ld c,0
ld a,&aa
call write_psg_reg

;; traditional way
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
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

;; write data to psg
ld c,0
ld a,&aa
call write_psg_reg

;; reverse it
ld bc,&f6c0
out (c),c
ld bc,&f400
out (c),c
ld bc,&f600
out (c),c
ld bc,&f680
out (c),c
ld bc,&f433
out (c),c
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

;; write data to psg
ld c,0
ld a,&aa
call write_psg_reg

;; traditional way no inactive
;; on register select
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f433
out (c),c
ld bc,&f680
out (c),c

ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&aa
inc ix

;; a bit messed up and no inactive
ld bc,&f6c0
out (c),c
ld bc,&f400
out (c),c
ld bc,&f680
out (c),c
ld bc,&f433
out (c),c

;; do this to ensure the data doesn't get messed up
ld bc,&f600
out (c),c

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix


call restore_ppi

ei
ld ix,result_buffer
ld bc,4
call simple_results
ret

setup_reg0:
ld bc,&f700+%10000000
out (c),c

;; select register 0 and write &33 into it
ld bc,&f6c0
out (c),c
ld bc,&f400
out (c),c
ld bc,&f600
out (c),c

ld bc,&f433
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c
ret

select_reg0:
;; select register 0
ld bc,&f6c0
out (c),c
ld bc,&f400
out (c),c
ld bc,&f600
out (c),c
ret

ppi_control_psg:
di
ld ix,result_buffer

call setup_reg0
call select_reg0

ld bc,&f680		;; write register
out (c),c
;; ppi port a input; what are the outputs??
ld bc,&f700+%10011011
out (c),c
;; inactive
ld bc,&f600
out (c),c

ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

call setup_reg0
call select_reg0

ld bc,&f640		;; read register (port set as output)
out (c),c
;; ppi port a input; what are the outputs??
ld bc,&f700+%10011011
out (c),c
;; inactive
ld bc,&f600
out (c),c

ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

call restore_ppi

ei
ld ix,result_buffer
ld bc,2
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
ld (ix+0),e
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
ld (ix+0),e
inc ix
inc e
jr nz,loop2_port_c_mixed

call restore_ppi

ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret


port_a_write_when_read:
ld b,&f4
jr write_when_read

port_b_write_when_read:
ld b,&f5

di
push bc
ld bc,&f700+%10011011
out (c),c
pop bc
call vsync_sync
in a,(c)
ld d,a

ld ix,result_buffer
ld e,0
wwr1b:
out (c),e
call vsync_sync
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
inc e
jr nz,wwr1b

call restore_ppi
ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

port_c_write_when_read:
di
push bc
ld bc,&f700+%10011011
out (c),c
pop bc

ld b,&f6
ld ix,result_buffer
ld e,0
wwrb1:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,wwrb1

call restore_ppi
ei
ld ix,result_buffer
ld bc,256
call simple_results
ret



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

call restore_ppi
ei
ld ix,result_buffer
ld bc,256
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
in d,(c)
md2md0a:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
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
ld (ix+0),a ;; expected
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

vsync_sync:
push bc
ld b,&f5
vs1:
in a,(c)
rra
jr nc,vs1
vs2:
in a,(c)
rra
jr nc,vs2
pop bc
ret


;;-----------------------------------------------------

output_latch_b:
di


ld ix,result_buffer
ld e,0
olb1:
call vsync_sync

ld bc,&f700+%10000010
out (c),c
ld b,&f5
in d,(c)

out (c),e

ld bc,&f700+%10000000
out (c),c
ld b,&f5
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
inc e
jr nz,olb1
call restore_ppi

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret



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

ld bc,&f400+7
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f438
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld ix,result_buffer
ld e,0
ld b,&f7
ppict2:
;; output val
out (c),e
;; read val
in a,(c)
ld (ix+0),a
inc ix


;;1xx1 0000 -> 10000000
;;1000 0000 -> 10001111
;;1010 0000 -> 10101111
;;1100 0000 -> 11001111
;;1110 0000 -> 11101111

;; setup expected
bit 7,e
ld a,&0
jr z,ppict1
ld a,e
bit 4,a
ld a,&ff
jr nz,ppict1
ld a,&0
ppict1:
ld (ix+0),a
inc ix
;; increment
inc e
jr nz,ppict2
call restore_ppi

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

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

di
push bc
ld bc,&f700+%10011011
out (c),c
pop bc

ld ix,result_buffer

ld e,0
ld b,&f4
par:
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
inc e
jr nz,par

call restore_ppi
ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

;;-----------------------------------------------------
;; de or fe on gx4000; seems some inputs float
port_b_read:
ld b,&f5
jr input_port_read

;;-----------------------------------------------------

port_c_read:

di
push bc
ld bc,&f700+%10011011
out (c),c
pop bc

ld ix,result_buffer

ld e,0
ld b,&f6
pcr:
in a,(c)
ld (ix+0),a
inc ix
ld a,(port_c_input)
ld (ix+0),a
inc ix
inc e
jr nz,pcr

call restore_ppi
ei
ld ix,result_buffer
ld bc,256
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
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $

end start
