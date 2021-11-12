;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../lib/testdef.asm"

;; Z8536 tester (in kc compact)
org &4000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;; ec00 - port b
;; ed00 - port c (interrupts)
;; ee00	- status
;; ef00 - printer (port a)


tests:
;; got 2 expected 0 8 times
;; got 1 expected 0
DEFINE_TEST "test reset state", test_reset
;; 02 f4 00 00 00 f2 fe f0
;; 08, 08, 25, 25, 25, 7f, 88, fa
;; 01 00 00 4c 00 01 02 47
;; 01 67 00 1a fc fc fc ff
;; 00 00 80 00 00 00 00 00
;; 00 00 44 ee 00 00 00 00
;; ff ff ff ff ff ff ff ff
;; ff ff ff ff ff ff ff ff
DEFINE_TEST "read registers", read_all_reg
;; 02 00 00 00 00 f0 f0 f0
;; 08 08 00 00 00 7f 00 f9
;; 01 66 00 7f 00 05 02 47
;; 01 67 00 1a 00 00 00 ff
;; 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00
;; ff ff ff ff ff ff ff ff
;; ff ff ff ff ff ff ff ff
DEFINE_TEST "read registers (post reset)", read_all_reg_post_reset
;; f9, fb etc 
DEFINE_TEST "port c (ed00)", port_c_rw
;; 8a, a8 etc
DEFINE_TEST "port b (ec00)", port_b_rw 
;; succeeded
DEFINE_TEST "port a (ef00)", port_a_rw 
;; reads the registers in turn  (registers repeat)
;;DEFINE_TEST "control (ee00)", port_control_rw 

;; failed
DEFINE_TEST "port c via control (ed00)", port_c_via

DEFINE_TEST "port b via control (ec00)", port_b_via 
DEFINE_TEST "port a via control (ef00)", port_a_via

DEFINE_TEST "reg 1 r/w", r1_rw
DEFINE_TEST "reg 2 r/w", r2_rw
DEFINE_TEST "reg 3 r/w", r3_rw
DEFINE_TEST "reg 4 r/w", r4_rw
DEFINE_TEST "reg 5 r/w", r5_rw
DEFINE_TEST "reg 6 r/w", r6_rw
DEFINE_TEST "reg 7 r/w", r7_rw
DEFINE_TEST "reg 8 r/w", r8_rw
DEFINE_TEST "reg 9 r/w", r9_rw
DEFINE_TEST "reg 10 r/w", r10_rw
DEFINE_TEST "reg 11 r/w", r11_rw
DEFINE_TEST "reg 12 r/w", r12_rw
DEFINE_TEST "reg 13 r/w", r13_rw
DEFINE_TEST "reg 14 r/w", r14_rw
DEFINE_TEST "reg 15 r/w", r15_rw
DEFINE_TEST "reg 16 r/w", r16_rw
DEFINE_TEST "reg 17 r/w", r17_rw
DEFINE_TEST "reg 18 r/w", r18_rw
DEFINE_TEST "reg 19 r/w", r19_rw
DEFINE_TEST "reg 20 r/w", r20_rw
DEFINE_TEST "reg 21 r/w", r21_rw
DEFINE_TEST "reg 22 r/w", r22_rw
DEFINE_TEST "reg 23 r/w", r23_rw
DEFINE_TEST "reg 24 r/w", r24_rw
DEFINE_TEST "reg 25 r/w", r25_rw
DEFINE_TEST "reg 26 r/w", r26_rw
DEFINE_TEST "reg 27 r/w", r27_rw
DEFINE_TEST "reg 28 r/w", r28_rw
DEFINE_TEST "reg 29 r/w", r29_rw
DEFINE_TEST "reg 30 r/w", r30_rw
DEFINE_TEST "reg 31 r/w", r31_rw
DEFINE_TEST "reg 32 r/w", r32_rw
DEFINE_TEST "reg 33 r/w", r33_rw
DEFINE_TEST "reg 34 r/w", r34_rw
DEFINE_TEST "reg 35 r/w", r35_rw
DEFINE_TEST "reg 36 r/w", r36_rw
DEFINE_TEST "reg 37 r/w", r37_rw
DEFINE_TEST "reg 38 r/w", r38_rw
DEFINE_TEST "reg 39 r/w", r39_rw
DEFINE_TEST "reg 40 r/w", r40_rw
DEFINE_TEST "reg 41 r/w", r41_rw
DEFINE_TEST "reg 42 r/w", r42_rw
DEFINE_TEST "reg 43 r/w", r43_rw
DEFINE_TEST "reg 44 r/w", r44_rw
DEFINE_TEST "reg 45 r/w", r45_rw
DEFINE_TEST "reg 46 r/w", r46_rw
DEFINE_TEST "reg 47 r/w", r47_rw
DEFINE_TEST "reg 48 r/w", r48_rw
DEFINE_TEST "reg 49 r/w", r49_rw
DEFINE_TEST "reg 50 r/w", r50_rw
DEFINE_TEST "reg 51 r/w", r51_rw
DEFINE_TEST "reg 52 r/w", r52_rw
DEFINE_TEST "reg 53 r/w", r53_rw
DEFINE_TEST "reg 54 r/w", r54_rw
DEFINE_TEST "reg 55 r/w", r55_rw
DEFINE_TEST "reg 56 r/w", r56_rw
DEFINE_TEST "reg 57 r/w", r57_rw
DEFINE_TEST "reg 58 r/w", r58_rw
DEFINE_TEST "reg 59 r/w", r59_rw
DEFINE_TEST "reg 60 r/w", r60_rw
DEFINE_TEST "reg 61 r/w", r61_rw
DEFINE_TEST "reg 62 r/w", r62_rw
DEFINE_TEST "reg 63 r/w", r63_rw

DEFINE_END_TEST

r1_rw:
ld d,1
jp rrw

r2_rw:
ld d,2
jp rrw

r3_rw:
ld d,3
jp rrw

r4_rw:
ld d,4
jp rrw

r5_rw:
ld d,5
jp rrw

r6_rw:
ld d,6
jp rrw

r7_rw:
ld d,7
jp rrw

r8_rw:
ld d,8
jp rrw

r9_rw:
ld d,9
jp rrw

r10_rw:
ld d,10
jp rrw


r11_rw:
ld d,11
jp rrw

r12_rw:
ld d,12
jp rrw

r13_rw:
ld d,13
jp rrw

r14_rw:
ld d,14
jp rrw

r15_rw:
ld d,15
jp rrw

r16_rw:
ld d,16
jp rrw

r17_rw:
ld d,17
jp rrw

r18_rw:
ld d,18
jp rrw

r19_rw:
ld d,19
jp rrw

r20_rw:
ld d,20
jp rrw


r21_rw:
ld d,21
jp rrw

r22_rw:
ld d,22
jp rrw

r23_rw:
ld d,23
jp rrw

r24_rw:
ld d,24
jp rrw

r25_rw:
ld d,25
jp rrw

r26_rw:
ld d,26
jp rrw

r27_rw:
ld d,27
jp rrw

r28_rw:
ld d,28
jp rrw

r29_rw:
ld d,29
jp rrw

r30_rw:
ld d,30
jp rrw

r31_rw:
ld d,31
jp rrw

r32_rw:
ld d,32
jp rrw

r33_rw:
ld d,33
jp rrw

r34_rw:
ld d,34
jp rrw

r35_rw:
ld d,35
jp rrw

r36_rw:
ld d,36
jp rrw

r37_rw:
ld d,37
jp rrw

r38_rw:
ld d,38
jp rrw

r39_rw:
ld d,39
jp rrw

r40_rw:
ld d,40
jp rrw

r41_rw:
ld d,41
jp rrw

r42_rw:
ld d,42
jp rrw

r43_rw:
ld d,43
jp rrw

r44_rw:
ld d,44
jp rrw

r45_rw:
ld d,45
jp rrw

r46_rw:
ld d,46
jp rrw

r47_rw:
ld d,47
jp rrw

r48_rw:
ld d,48
jp rrw

r49_rw:
ld d,49
jp rrw

r50_rw:
ld d,50
jp rrw

r51_rw:
ld d,51
jp rrw

r52_rw:
ld d,52
jp rrw

r53_rw:
ld d,53
jp rrw

r54_rw:
ld d,54
jp rrw

r55_rw:
ld d,55
jp rrw

r56_rw:
ld d,56
jp rrw

r57_rw:
ld d,57
jp rrw

r58_rw:
ld d,58
jp rrw

r59_rw:
ld d,59
jp rrw

r60_rw:
ld d,60
jp rrw

r61_rw:
ld d,61
jp rrw

r62_rw:
ld d,62
jp rrw

r63_rw:
ld d,63
jp rrw


rrw:
call do_reset

ld ix,result_buffer
ld e,0
rrw1:
ld c,d
call select_reg
ld a,e
call write_reg
ld c,d
call select_reg
call read_reg
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

inc e
jr nz,rrw1
call z8536_reset
ei
ld ix,result_buffer
ld bc,512
call simple_results
ret



DEFINE_END_TEST

;; write counter, read counter


;;-----------------------------------------------------

port_control_rw:
ld bc,&ee00
jr port_rw

;;-----------------------------------------------------

port_c_rw:
ld bc,&ed00
ld d,%000110
ld l,%000101
jr port_rw

;;-----------------------------------------------------

port_b_rw:
ld bc,&ec00
ld d,%101011
ld l,%101010
jr port_rw

;;-----------------------------------------------------

port_a_rw:
ld bc,&ef00
ld d,%100011
ld l,%100010
jr port_rw

;;-----------------------------------------------------

port_rw:
di
push bc
push de
push hl
call do_reset
pop hl
pop de
pop bc

ld ix,result_buffer

push bc
;; non inverting
ld c,l
call select_reg
xor a
call write_reg

;; port is in output mode
ld c,d
call select_reg
xor a
call write_reg
pop bc

ld e,&ff
call port_rw_test

push bc
;; inverting
ld c,l
call select_reg
ld a,&ff
call write_reg
pop bc

ld e,&ff
call port_rw_test

call z8536_reset
ei
ld ix,result_buffer
ld bc,512
call simple_results
ret

;;-----------------------------------------------------

reg_rw:
di
ld ix,result_buffer

;; C = register number
call select_reg

ld e,0
rerw:
ld a,e
call write_reg
call read_reg
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,rerw

call z8536_reset

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

;;-----------------------------------------------------

port_c_via:
ld bc,&ed00
ld d,&f
jr port_via

;;-----------------------------------------------------

port_b_via:
ld bc,&ec00
ld d,&e
jr port_via

;;-----------------------------------------------------

port_a_via:
ld bc,&ef00
ld d,&0d
jr port_via

;;-----------------------------------------------------

;; BC = normal port to read on
;; D = register number
port_via:
di
call do_reset
ld ix,result_buffer

;; register doesn't seem to remain selected
;; C = register number
;;call select_reg

;; write through slow access, read through fast
ld e,0
pv1:
push bc

;; C = register number
call select_reg

;; write data to reg
ld a,e
call write_reg

pop bc
;; read normally
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,pv1

;; write through fast access, read through slow
ld e,0
pv2:
out (c),e
push bc

call select_reg

call read_reg
pop bc
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
inc e
jr nz,pv2

call z8536_reset
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret

do_reset:
ld bc,&ee00
;; if in reset, stay in reset, otherwise goes to
;; state 0
in a,(c)
;; select register 0, or go to state 0
xor a
out (c),a
;; ensure we are in state 0
in a,(c)
;; write register 0
ld a,0
out (c),a
;; write reset
ld a,1
out (c),a

;; end reset
ld a,0
out (c),a
ret


;;-----------------------------------------------------

test_reset:
di
ld ix,result_buffer
ld bc,&ee00
;; if in reset, stay in reset, otherwise goes to
;; state 0
in a,(c)
;; select register 0, or go to state 0
xor a
out (c),a
;; ensure we are in state 0
in a,(c)
;; write register 0
ld a,0
out (c),a
;; write reset
ld a,1
out (c),a

;; ec00 - port b
;; ed00 - port c (interrupts)
;; ee00	- status
;; ef00 - printer (port a)
ld bc,&ec00
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&ed00
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&ee00
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&ef00
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&ee00
ld e,0
tr1:
;; write value but don't leave reset state
ld a,e
or 1
out (c),a
;; read value in reset state
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc e
jr nz,tr1

;; into state 0
ld a,0
out (c),a

;; state 0
ld e,16
tr2:
in a,(c)
ld (ix+0),a
inc ix
inc ix
dec e
jr nz,tr2

xor a
out (c),a
ld a,%11111110
out (c),a
in a,(c)
ld (ix+0),a
inc ix
inc ix

call z8536_reset
ei
ld ix,result_buffer
ld bc,512
call simple_results
ret

;;------------------------------------------------------------------------------


read_all_reg_post_reset:
di
call do_reset
;; and go into read all reg function

read_all_reg:
di
ld ix,result_buffer
ld e,0
ld c,0
rar1:
call select_reg
call read_reg
ld (ix+0),a
inc ix
inc c
inc e
ld a,e
cp 64
jr nz,rar1
call z8536_reset
ei
ld ix,result_buffer
ld bc,64
ld d,8
call simple_number_grid
ret

;;-----------------------------------------------------

reg_r:
di
ld ix,result_buffer

ld e,0
rrr:
;; C = register number
call select_reg


call read_reg
ld (ix+0),a
inc ix
inc e
jr nz,rrr
call z8536_reset
ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

;;-----------------------------------------------------

;; C = reg
select_reg:
;; Z8536 control port
ld b,&ee

;; reset Z8536 access state
;; after this, the Z8536 will be waiting for a register index
;; to be written.
in a,(c)

;; write register index
out (c),c
ret

;; C = register
read_reg:
;; Z8536 control port
ld b,&ee
in a,(c)
ret

write_reg:
ld b,&ee
out (c),a
ret

z8536_reset:
di
call do_reset

ld hl,reset_values
ld      bc,&ee3d			

;; loop now does: write register index, write register data, write register index,.....
reset_loop:
ld      a,(hl)
out     (c),a			; write register index or register data
inc     hl
dec     c
jr      nz,reset_loop
ei
ret     

reset_values:
;; start of Z8536 configuration data
defb &00, &01			;; Master interrupt control: reset
;; at this point, Z8536 is in reset state, and requires a write with bit 0=0
;; a read will not change it's state.
defb &22				;; advance CIO to state 0 from RESET STATE
defb &2a, &44			;; Port B's data path polarity: 01000100 (invert bits 2 and 6)
defb &05, &02			;; Port C's data path polarity: 00000000 (do not invert any bits)
defb &23, &bd			;; Port A's data direction:  10111101 (bit 1 is INPUT, bit 6 is INPUT all other bits are OUTPUT)
defb &2b, &ee			;; Port B's data direction:  11101110 (bit 0 is INPUT, bit 4 is INPUT all other bits are OUTPUT)
defb &06, &ee			;; Port C's data direction:  11101110 (bit 0 is INPUT, bit 4 is INPUT all other bits are OUTPUT)
defb &24, &42			;; Port A's special I/O Control 
defb &0d, &ff			;; Port A's data: 11111111
defb &01, &94			;; Master Configuration Control: Port B enable, disable counters, port a enable
defb &16, &02			;; Counter/Timer 1's Time Constant MSB: &02
defb &17, &47			;; Counter/Timer 1's Time Constant LSB: &47
defb &18, &01			;; Counter/Timer 2's Time Constant MSB: &01
defb &19, &67			;; Counter/Timer 2's Time Constant LSB: &67
defb &1a, &00			;; Counter/Timer 3's Time Constant MSB: &00
defb &1b, &1a			;; Counter/Timer 3's Time Constant LSB: &1a
						;; Timer 1 time constant: &0247 (583), Timer 2 time constant: &0167 (359), Timer 3 time constant: &1a (26 = 52 * (1/2)!!!!)

defb &1c, &fc			;; Counter/Timer 1's Mode specification: Continuous,external output enable,external count enable,
						;; external trigger enable, external gate enable, retrigger enable bit, pulse output
defb &1d, &fc			;; Counter/Timer 2's Mode specification: Continuous,external output enable,external count enable,
						;; external trigger enable, external gate enable, retrigger enable bit, pulse output
defb &1e, &fc			;; Counter/Timer 3's Mode specification: Continuous,external output enable,external count enable,
						;; external trigger enable, external gate enable, retrigger enable bit, pulse output
defb &0a, &04			;; Counter/Timer 1's Command and Status: Gate Command Bit
defb &0b, &04			;; Counter/Timer 2's Command and Status: Gate Command Bit
defb &0c, &04			;; Counter/Timer 3's Command and Status: Gate Command Bit
defb &01, &f4			;; Master Configuration Control: Port B enable, Counter/Timer 1 enable, Counter/Timer 2 enable,
						;; Counter/Timer 3 enable, port A and B operate independantly, port A enable, counter/timers are
						;; idependant
defb &0a, &06			;; Counter/Timer 1's Command and Status: Gate Command Bit,Trigger Command Bit
defb &0b, &06			;; Counter/Timer 2's Command and Status: Gate Command Bit,Trigger Command Bit

;; the following are setup for the operating system only
defb &01, &f0			;; Master Configuration Control: Port B enable, Counter/Timer 1 enable, Counter/Timer 2 enable,
						;; Counter/Timer 3 enable, port A and B operate independantly, port A disable, counter/timers are
						;; idependant
defb &22, &80			;; Port A's data path polarity: invert bit 7, all other bits unchanged
defb &23, &00			;; Port A's data direction: all bits output
defb &24, &00			;; Port A's special I/O control: no actions
defb &01, &f4			;; Master Configuration Control: Port B enable, Counter/Timer 1 enable, Counter/Timer 2 enable,
						;; Counter/Timer 3 enable, port A and B operate independantly, port A enable, counter/timers are
						;; idependant
defb &0d, &7f			;; Port A's data: 01111111 (/strobe = 0)



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
