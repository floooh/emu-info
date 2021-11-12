;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

org &8000
start:

result_buffer equ &2000

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;; 
;; TODO: Loop at reset/power on time?
;; TODO: bit 3 of dcsr. What does it do? it's not constant on or off.
;; TODO: pause after forcing a stop of the channel
;; TODO: execution order - I have a test for this
;; TODO: command bit 0 and 3.
tests:
DEFINE_TEST "dcsr read/write enables",dma_control_enables
;;DEFINE_TEST "dcsr read bit 3 (untested)",dma_control_bit3
DEFINE_TEST "dcsr read/write irq",dma_control_irq
DEFINE_TEST "dma enable test (dcsr bits)",dma_enable
DEFINE_TEST "dma int request test (dcsr bits)",dma_irq
DEFINE_TEST "dma int request auto clear (ivr bit 0=1)",dma_irq_clr
DEFINE_TEST "dma channel address (bit 1 set)",dma_channel
DEFINE_TEST "dma write ay register (all registers, data 0-16)",dma_ay_reg
DEFINE_TEST "dma prescale reg",dma_prescale_reg
DEFINE_TEST "dma pause (prescale 0)",dma_pause_prescale0
DEFINE_TEST "dma pause (prescale 2)",dma_pause_prescale2
DEFINE_TEST "dma pause (force stop)",dma_pause_forcestop
DEFINE_TEST "dma pause (change address)",dma_p_changeaddr
DEFINE_TEST "dma pause (change prescale lower)",dma_p_prescale
DEFINE_TEST "dma pause (change prescale higher)",dma_p_hprescale
DEFINE_TEST "dma repeat",dma_repeat
DEFINE_TEST "dma repeat (with repeat 0 in inner loop)",dma_repeat0
DEFINE_TEST "repeat reset when stopped?",dma_repeat_reset
DEFINE_TEST "4xxx int bit test",dma_4xxx
DEFINE_TEST "dma command bit 1 (2xxx,3xxx,6xxx,7xxx,axxx,bxxx,exxx,fxxx)",dma_bit1_int
DEFINE_TEST "dma command bit 2 (4xxx,5xxx,6xxx,7xxx,cxxx,dxxx,exxx,fxxx)",dma_bit2_int
DEFINE_TEST "hsync lengths and dma",dma_hsync_length
DEFINE_TEST "CRTC R0 length and dma",dma_r0_length
DEFINE_TEST "dma ay write all",dma_ay_write_all
DEFINE_TEST "dma restore ay",dma_restore_ay
DEFINE_TEST "dma under asic registers",dma_under_regs
;; 51,50,

;; in places 50, 6 x 51, 50
;;DEFINE_TEST "dma 0 channel flags (prescale) (not conclusive)",dma0_flags_prescale
;;DEFINE_TEST "dma 1 channel flags (prescale) (not conclusive)",dma1_flags_prescale
;; this just hangs!
;;DEFINE_TEST "dma 2 channel flags (prescale) (not conclusive)",dma2_flags_prescale
;;DEFINE_TEST "dma 0 channel flags (prescale)",dma0_flags_prescale
;;DEFINE_TEST "dma 1 channel flags (prescale)",dma1_flags_prescale
;;DEFINE_TEST "dma 2 channel flags (prescale)",dma2_flags_prescale
DEFINE_END_TEST

dma_under_regs:
di
ld hl,&4030
ld (&4000),hl
ld (&6000),hl
ld (&6400),hl
ld (&6800),hl
ld (&7000),hl

call asic_enable
ld bc,&7fb8
out (c),c

ld ix,result_buffer

ld hl,&4000
ld (&6c00),hl
xor a
ld (&6c02),a
ld a,1
ld (&6c0f),a

defs 128
ld a,(&6c0f)
and &7f
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix
ld a,%01110000
ld (&6c0f),a

ld hl,&6000
ld (&6c00),hl
xor a
ld (&6c02),a
ld a,1
ld (&6c0f),a

defs 128
ld a,(&6c0f)
and &7f
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix
ld a,%01110000
ld (&6c0f),a

ld hl,&6400
ld (&6c00),hl
xor a
ld (&6c02),a
ld a,1
ld (&6c0f),a

defs 128
ld a,(&6c0f)
and &7f
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix
ld a,%01110000
ld (&6c0f),a

ld hl,&6800
ld (&6c00),hl
xor a
ld (&6c02),a
ld a,1
ld (&6c0f),a

defs 128
ld a,(&6c0f)
and &7f
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix
ld a,%01110000
ld (&6c0f),a

ld hl,&7000
ld (&6c00),hl
xor a
ld (&6c02),a
ld a,1
ld (&6c0f),a

defs 128
ld a,(&6c0f)
and &7f
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix
ld a,%01110000
ld (&6c0f),a

call do_reset
ld bc,&7fa0
out (c),c
call asic_disable

ei
ld ix,result_buffer
ld bc,5
call simple_results

ret

;; all 3 channels write to ay, which shows the result last?
dma_ay_write_all:
di
call asic_enable

ld bc,&7fb8
out (c),c

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

;; write register 0 with &10
ld hl,&0010
ld (&1080),hl
ld hl,&4020
ld (&1082),hl

;; write register 0 with &20
ld hl,&0020
ld (&2000),hl
ld hl,&4020
ld (&2002),hl

ld ix,result_buffer

ld hl,&1000
ld (&6c00),hl
ld hl,&1080
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%111
ld (&6c0f),a

dwa: 
ld a,(&6c0f)
and &7
jr nz,dwa

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),&20
inc ix


call do_reset
ld bc,&7fa0
out (c),c
call asic_disable

ei

ld ix,result_buffer
ld bc,1
call simple_results
ret

;; dma restores ay register and ppi state when
;; a write to a ay register is done. confirm this.
dma_restore_ay:
di
call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer

ld c,0
ld a,&33
call write_psg_reg
ld c,2
ld a,&34
call write_psg_reg

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld bc,&f402
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c


ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a
 
dra1: 
ld a,(&6c0f)
and &7
jr nz,dra1


;; if register remains selected, we can read
;; and see register 2
ld bc,&f700+%10010010
out (c),c
ld bc,&f640
out (c),c
ld b,&f4
in a,(c)

ld bc,&f700+%10000010
out (c),c

ld (ix+0),a
inc ix
ld (ix+0),&34
inc ix

;;----
ld c,0
ld a,&22
call write_psg_reg
ld c,2
ld a,&24
call write_psg_reg

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl


;; same as above without inactive
ld bc,&f402
out (c),c
ld bc,&f6c0
out (c),c


ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

dra2: 
ld a,(&6c0f)
and &7
jr nz,dra2

;; now do inactive
ld bc,&f600
out (c),c
ld bc,&f700+%10010010
out (c),c

;; if register remains selected, we can read
;; and see register 1
ld bc,&f640
out (c),c
ld b,&f4
in a,(c)

ld bc,&f700+%10000010
out (c),c

ld (ix+0),a
inc ix
ld (ix+0),&24
inc ix


;;-------
ld c,0
ld a,&f2
call write_psg_reg
ld c,2
ld a,&f4
call write_psg_reg

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

;; select with read specified
ld bc,&f402
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010010
out (c),c

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

dra32: 
ld a,(&6c0f)
and &7
jr nz,dra32

ld bc,&f640
out (c),c
;; if register remains selected, we can read
;; and see register 1
ld b,&f4
in a,(c)

ld bc,&f700+%10000010
out (c),c

ld (ix+0),a
inc ix
ld (ix+0),&f4
inc ix


;;-------
ld c,0
ld a,&72
call write_psg_reg
ld c,2
ld a,&74
call write_psg_reg

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

;; select with read specified
ld bc,&f402
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010010
out (c),c
ld bc,&f640
out (c),c


ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

dra3: 
ld a,(&6c0f)
and &7
jr nz,dra3

;; if register remains selected, we can read
;; and see register 1
ld b,&f4
in a,(c)
ld bc,&f700+%10000010
out (c),c
ld (ix+0),a
inc ix
ld (ix+0),&74
inc ix

;;-----
ld c,0
ld a,&12
call write_psg_reg
ld c,2
ld a,&14
call write_psg_reg

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

;; same as above without inactive 
;; and without specifying select too
ld bc,&f402
out (c),c


ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

dra4: 
ld a,(&6c0f)
and &7
jr nz,dra4

;; now do select and inactive
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010010
out (c),c
ld bc,&f640
out (c),c
ld b,&f4
in a,(c)
ld bc,&f700+%10000010
out (c),c
ld (ix+0),a
inc ix
ld (ix+0),&14
inc ix

;;----
ld c,0
ld a,&b2
call write_psg_reg
ld c,2
ld a,&b4
call write_psg_reg

;; write register 0 with &30
ld hl,&0030
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

;; select with read specified
ld bc,&f402
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010010
out (c),c
ld bc,&f640
out (c),c
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&b4
inc ix


ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

dra5: 
ld a,(&6c0f)
and &7
jr nz,dra5

;; if register remains selected, we can read
;; and see register 1
ld b,&f4
in a,(c)
ld bc,&f700+%10000010
out (c),c
ld (ix+0),a
inc ix
ld (ix+0),&b4
inc ix

call do_reset

ei

ld ix,result_buffer
ld bc,7
call simple_results
ret

dma_4xxx:
di
call store_int

ld a,&c3
ld (&0038),a
ld hl,count_dma_int
ld (&0039),hl

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer

ld b,0
xor a
d41:
push bc
push af
ld (&1000),a
ld (ix+1),0
ld (ix+3),0
bit 4,a
jr z,d41a
ld (ix+1),1
ld (ix+3),0
d41a:

ld a,&40
ld (&1001),a
ld hl,&4020 ;; stop
ld (&1002),hl

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

ld hl,0
ld (int_counter),hl
ei

d42:
ld a,(&6c0f)
and 7
jr nz,d42

di
ld hl,(int_counter)
ld a,l
ld (ix+0),a
ld a,h
ld (ix+2),a
inc ix
inc ix
inc ix
inc ix

ld a,%01110000
ld (&6c0f),a

pop af
pop bc
inc a
dec b
jp nz,d41

call restore_int
call do_reset

ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret

dma_r0_length:
;; write to ay and check
di

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&0030 ;; load to register 0
ld (&1000),hl
ld hl,&0020 ;; load to register 0
ld (&1002),hl
ld hl,&0010 ;; load to register 0
ld (&1004),hl
ld hl,&4020	;; stop
ld (&1006),hl

ld a,%01110000
ld (&6c0f),a
ld bc,&bc00+2
out (c),c
ld bc,&bd00
out (c),c

ld ix,result_buffer

ld b,64
xor a
drl1:
push bc
push af
push af
ld bc,&bc00
out (c),c
ld bc,&bd00+63
out (c),c
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
pop af
;; set hsync length
ld bc,&bc00
out (c),c
inc b
out (c),a
or a
jr nz,drl1a
;; partial completion
ld a,1
ld (ix+1),a
ld (ix+3),&30
jr drl1b
drl1a:
;; full completion
xor a
ld (ix+1),a
ld (ix+3),&10
drl1b:
;; write value into reg 0 so we can see if it's changed
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f400+&00
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld a,%01110000
ld (&6c0f),a
ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync

ld a,(&6c0f)
and 7
ld (ix+0),a
inc ix
inc ix

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
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld bc,&f600
out (c),c
ld bc,&f700+%10000000
out (c),c
ld a,%01110000
ld (&6c0f),a

pop af
pop bc
inc a
dec b
jp nz,drl1

call do_reset
ld bc,&bc00
out (c),c
ld bc,&bd00+63
out (c),c
ld bc,&bc02
out (c),c
ld bc,&bd00+46
out (c),c


ei
ld ix,result_buffer
ld bc,64*2
call simple_results
ret


dma_hsync_length:
;; write to ay and check
di

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&0030 ;; load to register 0
ld (&1000),hl
ld hl,&4020	;; stop
ld (&1002),hl

ld ix,result_buffer

ld b,16
xor a
dhl1:
push bc
push af
;; set hsync length
ld bc,&bc03
out (c),c
inc b
;; set vsync length
or &80
out (c),a

;; write value into reg 0 so we can see if it's changed
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f400+&00
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
ld a,%1
ld (&6c0f),a

call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync

ld a,(&6c0f)
and 7
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

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
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&30
inc ix
ld bc,&f600
out (c),c
ld bc,&f700+%10000000
out (c),c
ld a,%01110000
ld (&6c0f),a

pop af
pop bc
inc a
dec b
jp nz,dhl1

call do_reset

ei
ld ix,result_buffer
ld bc,16*2
call simple_results
ret

dma_repeat_reset:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&2010	;; repeat
ld (&1000),hl
ld hl,&4010	;; int
ld (&1002),hl
ld hl,&4020	;; stop
ld (&1004),hl
ld hl,&4001	;; loop
ld (&1006),hl
ld hl,&4030	;; stop and int
ld (&1008),hl


ld ix,result_buffer

ld a,%01110000
ld (&6c0f),a

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld hl,0
ld (int_counter),hl

;; enable and reset int
ld a,%1
ld (&6c0f),a

drr2:
;; read
ld a,(&6c0f)
;; isolate int and enable
and %01000001
cp %01000001
jr nz,drr2b
;; seen int and active, count it
ld hl,(int_counter)
inc hl
ld (int_counter),hl
ld a,(&6c0f)
and &7
or %01110000
ld (&6c0f),a
jr drr2

drr2b:
cp %0	;; seen stop no int
jr nz,drr2c
ld a,1
ld (&6c0f),a
jr drr2

drr2c:
cp %01000000	;; seen int and stopped
jr nz,drr2

;; got to end of loop
ld a,%01110000
ld (&6c0f),a

;; 16 if repeat is not cleared at stop
;; otherwise we will see 1 and that is it
ld hl,(int_counter)
ld (ix+0),l
ld (ix+1),16
ld (ix+2),h
ld (ix+3),0

call do_reset

ei
ld ix,result_buffer
ld bc,2
call simple_results
ret


dma_repeat:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&2000
ld (&1000),hl
ld hl,&4010
ld (&1002),hl
ld hl,&4001
ld (&1004),hl
ld hl,&4020
ld (&1006),hl

call store_int

di
ld a,&c3
ld (&0038),a
ld hl,count_dma_int
ld (&0039),hl


ld ix,&2000
ld bc,513
drp1:
push bc
;; 512 should loop 512 times
dec bc
ld a,b
or c
jr nz,drp2
;; 0 = nop, which means 1 int
ld (ix+1),1
ld (ix+3),0
jr drp3
drp2:
;; set pause
ld a,c
ld (&1000),a
ld (ix+1),a
ld a,b
and &f
or &20
ld (&1001),a
and &f
ld (ix+3),a
drp3:
ld a,%01110000
ld (&6c0f),a

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld hl,0
ld (int_counter),hl
ei
ld a,1
ld (&6c0f),a

drp4:
ld a,(&6c0f)
and &7
jr nz,drp4
di
ld hl,(int_counter)
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix

pop bc
dec bc
ld a,b
or c
jr nz,drp1

call restore_int
call do_reset

ei
ld ix,&2000
ld bc,513*2
call simple_results
ret

;; got 2 and not 16

dma_repeat0:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&2000+16	;; repeat 16
ld (&1000),hl
ld hl,&4010
ld (&1002),hl
ld hl,&2000		;; repeat 0 (resets repeat..?).. No. it's ignored!
ld (&1004),hl
ld hl,&4010
ld (&1006),hl
ld hl,&4001
ld (&1008),hl
ld hl,&4020
ld (&100a),hl

call store_int

di
ld a,&c3
ld (&0038),a
ld hl,count_dma_int
ld (&0039),hl

ld ix,result_buffer
ld (ix+1),2
ld (ix+3),0

ld a,%01110000
ld (&6c0f),a

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld hl,0
ld (int_counter),hl
ei
ld a,1
ld (&6c0f),a

dr0p4:
ld a,(&6c0f)
and &7
jr nz,dr0p4
di
ld hl,(int_counter)
ld (ix+0),l
ld (ix+2),h

call restore_int
call do_reset

ei
ld ix,&2000
ld bc,2
call simple_results
ret


dma_prescale_reg:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000+16 ;; pause (remember prescale)
ld (&1002),hl
ld hl,&4020
ld (&1004),hl


ld ix,result_buffer
ld b,32
xor a
dpr1:
push bc
push af
;; set prescale
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld l,a
ld h,0
inc hl
add hl,hl
add hl,hl
add hl,hl
add hl,hl
inc hl		;; for stop
ld (ix+1),l
ld (ix+3),h

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl

ld a,1
ld (&6c0f),a

dpr2:
ld a,(&6c0f)
and %01110000
jr z,dpr2
ld a,%01110001
ld (&6c0f),a

ld hl,0

dpr3:
ld a,(&6c0f)
and 7
jp z,dpr4
defs 64-2-3-3-2-4
inc hl
jp dpr3

dpr4:
;; store count
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
pop af
pop bc
inc a
dec b
jp nz,dpr1

call do_reset

ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret

dma0_flags_prescale:
ld hl,&6c03
ld a,%1
jp dma_flags_prescale

dma1_flags_prescale:
ld hl,&6c07
ld a,%10
jp dma_flags_prescale

dma2_flags_prescale:
ld hl,&6c0b
ld a,%100
jp dma_flags_prescale

flags_addr:
defw 0

channel_enable:
defb 0

dma_flags_prescale:
di
ld (flags_addr),hl
ld (channel_enable),a

call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&1000+16 ;; pause (remember prescale)
ld (&1000),hl
ld hl,&4020
ld (&1002),hl


ld ix,result_buffer
ld b,0
xor a
dpr12:
push bc
push af
push af
ld a,4
;; set prescale
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
pop af

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl

ld a,(channel_enable)
ld (&6c0f),a

ld hl,(flags_addr)
ld (hl),a

ld hl,0
ld b,4
dpr31:
ld a,(&6c0f)
and 7
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
defs 64-2-4-2-4-2-3-2-3
dec b
jp nz,dpr31
if 0
dpr31:
ld a,(&6c0f)
and 7
jp z,dpr41
defs 64-2-3-3-2-4
inc hl
jp dpr31

dpr41:
;; store count
ld (ix+0),l
ld (ix+1),2
ld (ix+2),h
ld (ix+3),0
inc ix
inc ix
inc ix
inc ix
endif
ld a,%01110000
ld (&6c0f),a
pop af
pop bc
inc a
dec b
jp nz,dpr12

call do_reset

ei
ld ix,result_buffer
ld bc,256*4
call simple_results
ret


dma_pause_prescale2:
di

call asic_enable

ld bc,&7fb8
out (c),c

;; 1000->nop

ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000 ;; pause (remember prescale)
ld (&1002),hl
ld hl,&4020
ld (&1004),hl


ld ix,result_buffer
ld b,32
xor a
dpp1:
push bc
push af
ld (&1002),a	;; pause
or a
ld hl,2
jr z,dpp2a
ld l,a
ld h,0
ld e,l
ld d,h
add hl,hl
add hl,de
inc hl

dpp2a:
ld (ix+1),l
ld (ix+3),h

ld a,2
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl

ld a,1
ld (&6c0f),a

dpp2:
ld a,(&6c0f)
and %01110000
jr z,dpp2
ld a,%01110001
ld (&6c0f),a

ld hl,0

dpp3:
ld a,(&6c0f)
and 7
jp z,dpp4
defs 64-2-3-3-2-4
inc hl
jp dpp3

dpp4:
;; store count
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
pop af
pop bc
inc a
dec b
jp nz,dpp1

call do_reset

ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret

dma_pause_forcestop:
di

call asic_enable

ld bc,&7fb8
out (c),c


ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000+256 ;; pause 
ld (&1002),hl
ld hl,&4000
ld (&1004),hl
ld hl,&4020	;; stop
ld (&1006),hl


ld ix,result_buffer

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
ld a,4
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,1
ld (&6c0f),a

dpf02:
ld a,(&6c0f)
and %01110000
jr z,dpf02
ld a,%01110001
ld (&6c0f),a

;; force a stop
call wait_2_lines
call wait_2_lines
call wait_2_lines
ld a,%0
ld (&6c0f),a
;; and resume
ld a,%1
ld (&6c0f),a
;; now count remaining..
ld hl,0

dpf03:
ld a,(&6c0f)
and 7
jp z,dpf04
defs 64-2-3-3-2-4
inc hl
jp dpf03

dpf04:
;; store count
ld (ix+0),l
ld (ix+1),&fc
ld (ix+2),h
ld (ix+3),&4

call do_reset

ei
ld ix,result_buffer
ld bc,2
call simple_results
ret


dma_p_changeaddr:
di

call asic_enable

ld bc,&7fb8
out (c),c


ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000+256 ;; pause 
ld (&1002),hl
ld hl,&4000
ld (&1004),hl
ld hl,&4020	;; stop
ld (&1006),hl

ld hl,&4030
ld (&2000),hl


ld ix,result_buffer

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
ld a,4
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,1
ld (&6c0f),a

dpfc02:
ld a,(&6c0f)
and %01110000
jr z,dpfc02
ld a,%01110001
ld (&6c0f),a

;; force a stop
call wait_2_lines
call wait_2_lines
call wait_2_lines
;; change addr
ld hl,&2000
ld (&6c00),hl

;; and resume
ld a,%1
ld (&6c0f),a
;; now count remaining..
ld hl,0

dpfc03:
ld a,(&6c0f)
and 7
jp z,dpfc04
defs 64-2-3-3-2-4
inc hl
jp dpfc03

dpfc04:
;; store count
ld (ix+0),l
ld (ix+1),&fb
ld (ix+2),h
ld (ix+3),&4
ld a,(&6c0f)
and %01110000
ld (ix+4),a
ld (ix+5),%01000000	
ld a,%01110000
ld (&6c0f),a

call do_reset

ei
ld ix,result_buffer
ld bc,3
call simple_results
ret



dma_p_prescale:
di

call asic_enable

ld bc,&7fb8
out (c),c


ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000+256 ;; pause 
ld (&1002),hl
ld hl,&4000
ld (&1004),hl
ld hl,&4020	;; stop
ld (&1006),hl

ld ix,result_buffer

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
ld a,4
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,1
ld (&6c0f),a

dpfcp02:
ld a,(&6c0f)
and %01110000
jr z,dpfcp02
ld a,%01110001
ld (&6c0f),a

;; force a stop
call wait_2_lines
call wait_2_lines
call wait_2_lines
ld a,1
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

;; now count remaining..
ld hl,0

dpfcp03:
ld a,(&6c0f)
and 7
jp z,dpfcp04
defs 64-2-3-3-2-4
inc hl
jp dpfcp03

dpfcp04:
;; store count
ld (ix+0),l
ld (ix+1),&fe
ld (ix+2),h
ld (ix+3),&1

call do_reset

ei
ld ix,result_buffer
ld bc,2
call simple_results
ret


dma_p_hprescale:
di

call asic_enable

ld bc,&7fb8
out (c),c


ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000+256 ;; pause 
ld (&1002),hl
ld hl,&4000
ld (&1004),hl
ld hl,&4020	;; stop
ld (&1006),hl

ld ix,result_buffer

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
ld a,4
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,1
ld (&6c0f),a

dpfcph02:
ld a,(&6c0f)
and %01110000
jr z,dpfcph02
ld a,%01110001
ld (&6c0f),a

;; force a stop
call wait_2_lines
call wait_2_lines
call wait_2_lines
ld a,8
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

;; now count remaining..
ld hl,0

dpfcph03:
ld a,(&6c0f)
and 7
jp z,dpfcph04
defs 64-2-3-3-2-4
inc hl
jp dpfcph03

dpfcph04:
;; store count
ld (ix+0),l
ld (ix+1),&f0
ld (ix+2),h
ld (ix+3),&8

call do_reset

ei
ld ix,result_buffer
ld bc,2
call simple_results
ret

;; 2,2,3,4,5,6,7,
dma_pause_prescale0:
di

call asic_enable

ld bc,&7fb8
out (c),c

;; 1000->nop

ld hl,&4010	;; int (synchronisation)
ld (&1000),hl
ld hl,&1000 ;; pause (remember prescale)
ld (&1002),hl
ld hl,&4020
ld (&1004),hl


ld ix,result_buffer
ld b,32
xor a
dpp01:
push bc
push af
ld (&1002),a	;; pause
cp 2
jr nc,dpp01aa
ld a,2
jr dpp01ab

dpp01aa:
inc a

dpp01ab:
ld l,a
ld h,0
ld (ix+1),l
ld (ix+3),h

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl

ld a,1
ld (&6c0f),a

dpp02:
ld a,(&6c0f)
and %01110000
jr z,dpp02
ld a,%01110001
ld (&6c0f),a

ld hl,0

dpp03:
ld a,(&6c0f)
and 7
jp z,dpp04
defs 64-2-3-3-2-4
inc hl
jp dpp03

dpp04:
;; store count
ld (ix+0),l
ld (ix+2),h
inc ix
inc ix
inc ix
inc ix
pop af
pop bc
inc a
dec b
jp nz,dpp01

call do_reset

ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret


setup_empty:
ld hl,&1000
ld de,&4000
ld b,100
dci1:
ld (hl),e
inc hl
ld (hl),d
inc hl
djnz dci1
ld de,&4020
ld (hl),e
inc hl
ld (hl),d
ret


dma_control_enables:
di

call setup_empty

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld b,0
xor a
ld hl,&6c0f
dcs1:
push af
push hl
push af
ld a,%01110000
ld (&6c0f),a
ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
pop af
pop hl

and %111
ld (hl),a ;; write to dcsr
and %111
ld (ix+1),a ;; store expected
ld a,(hl) ;; read from dcsr
and %111
ld (ix+0),a
inc ix
inc ix

ld a,%01110000
ld (&6c0f),a


pop af
inc a
djnz dcs1

call do_reset

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

dma_control_irq:
di

call setup_empty

call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer
ld b,0
xor a
ld hl,&6c0f
dci2:
push af
push hl
push af
ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a
ld a,%01110000
ld (&6c0f),a
pop af
pop hl

and %01110000
ld (hl),a
ld a,(hl)
and %01110000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld a,%01110000
ld (&6c0f),a

pop af
inc a
djnz dci2

call do_reset

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

count_dma_int:
push hl
push af
ld a,(&6c0f)
and %01110000
jr z,cdi2
ld hl,(int_counter)
inc hl
ld (int_counter),hl
ld a,(&6c0f)
and &7
or %01110000
ld (&6c0f),a
cdi2:
pop af
pop hl
ei
reti 

int_counter:
defw 0

;; passes on gx4000
dma_bit2_int:
di
call asic_enable

ld bc,&7fb8
out (c),c

call store_int

di
ld a,&c3
ld (&0038),a
ld hl,count_dma_int
ld (&0039),hl

xor a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a

ld ix,result_buffer

ld b,16
xor a
db21:
push bc
push af

add a,a
add a,a
add a,a
add a,a
ld (&1001),a
;; if bit 2 set, then we expect to see an int
bit 6,a
ld a,1
jr nz,db22
xor a
db22:
ld (ix+1),a

ld a,&10	;; should be int if upper nibble command indicates that.
ld (&1000),a
ld hl,&4020	;; should be stop
ld (&1002),hl

;; set address
ld hl,&1000
ld (&6c00),hl
xor a
ld (&6c02),a
ld hl,0
ld (int_counter),hl
ei
ld a,1
ld (&6c0f),a

db23:
ld a,(&6c0f)
and &7
jr nz,db23

ld a,(int_counter+0)
ld (ix+0),a
inc ix
inc ix

ld a,%01110000
ld (&6c0f),a

pop af
pop bc
inc a
djnz db21

call restore_int
call do_reset
ei

ld ix,result_buffer
ld bc,16
call simple_results
ret

dma_bit1_int:
di
call asic_enable

ld bc,&7fb8
out (c),c

call store_int

di
ld a,&c3
ld (&0038),a
ld hl,count_dma_int
ld (&0039),hl

xor a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a

ld ix,result_buffer

ld b,16
xor a
db11:
push bc
push af

add a,a
add a,a
add a,a
add a,a
ld (&1001),a
;; if bit 2 set, then we expect to see an int
bit 5,a
ld a,4
jr nz,db12
ld a,1
db12:
ld (ix+1),a

ld a,&4		;; for 4xxx will be nop, for 1xxx will be pause,
			;; for 2xxx will be 4 repeats
ld (&1000),a
ld hl,&4010	;; int
ld (&1002),hl
ld hl,&4001	;; loop
ld (&1004),hl
ld hl,&4020 ;; stop
ld (&1006),hl

;; set address
ld hl,&1000
ld (&6c00),hl
xor a
ld (&6c02),a
ld hl,0
ld (int_counter),hl
ei
ld a,1
ld (&6c0f),a

db13:
ld a,(&6c0f)
and &7
jr nz,db13

ld a,(int_counter+0)
ld (ix+0),a
inc ix
inc ix

ld a,%01110000
ld (&6c0f),a

pop af
pop bc
inc a
djnz db11

call restore_int
call do_reset
ei

ld ix,result_buffer
ld bc,16
call simple_results
ret


;; wait frame
vsync_sync:
ld b,&f5
wf1:
in a,(c)
rra 
jr nc,wf1
wf2:
in a,(c)
rra
jr c,wf2
ret

dma_ay_reg:
di
call asic_enable

ld bc,&7fb8
out (c),c

ld hl,&000f
ld (&1000),hl
ld hl,&4020
ld (&1002),hl



ld ix,result_buffer

ld b,16	;; data loop
ld d,0
dayr12:
push bc
push de

;; register loop
ld b,16
xor a
dayr1:
push af
push bc

;; port a and b to output
ld bc,&f400+7
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f400+&ff
out (c),c
ld bc,&f680
out (c),c
ld bc,&f600
out (c),c



;; write register
ld (&1001),a
push af
ld a,d	;; write data
ld (&1000),a
;; set address
ld hl,&1000
ld (&6c00),hl
xor a
ld (&6c02),a
ld a,1
ld (&6c0f),a
call wait_4_lines
pop af

ld b,&f4
out (c),a
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f700+%10010000
out (c),c
ld bc,&f640
out (c),c
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
ld bc,&f600
out (c),c
ld bc,&f700+%10000000
out (c),c
pop bc
pop af
inc a
djnz dayr1
pop de
pop bc
inc d
djnz dayr12

call do_reset
ei

ld ix,result_buffer
ld bc,256
call simple_results
ret


;; 1001->1000

;; 20 00	;; write value to reg 0
;; 00 40	;; nop
;; 20 40	;; stop
;; 00 20
;; 40

dma_channel_data:
defb &20,&00
defb &00,&40
defb &20,&40
defb &00,&20
defb &40
end_dma_channel_data:

;; bit 0 is ignored and forced to zero
;; then we get:
;; write &20 to reg 0
;; nop
;; stop

;; bit 0 is not ignored:
;; then we get:
;; write 0 to reg 0
;; delay for &40 lines
;; write &40 to reg 0
;; stop
 
dma_channel:
di
ld hl,dma_channel_data
ld de,&1000
ld bc,end_dma_channel_data-dma_channel_data
ldir

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer

ld a,0
ld (&6800),a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a

ld hl,&1001
ld (&6c00),hl
ld a,1
ld (&6c0f),a
wait:
ld a,(&6c0f)
and &7
jr nz,wait

;; read reg 0
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
ld b,&f4
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&20
inc ix
ld bc,&f600
out (c),c
ld bc,&f700+%10000000
out (c),c

call do_reset
ei

ld ix,result_buffer
ld bc,1
call simple_results
ret

dma_enable:
di
ld hl,&4020	;; dma stop 
ld (&1000),hl

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer

ld a,%1
call init_dma
call wait_2_lines
ld a,(&6c0f)
and %111
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

ld a,%10
call init_dma
call wait_2_lines
ld a,(&6c0f)
and %111
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

ld a,%100
call init_dma
call wait_2_lines
ld a,(&6c0f)
and %111
ld (ix+0),a
inc ix
ld (ix+0),%0
inc ix

call do_reset
ei

ld ix,result_buffer
ld bc,3
call simple_results
ret

wait_2_lines:
defs 64*2
ret

wait_4_lines:
defs 64*4
ret

;; 40,20,00 on gx4000!
dma_irq:
di
ld hl,&4030	;; dma stop & int
ld (&1000),hl

call asic_enable

ld bc,&7fb8
out (c),c
ld a,1
ld (&6805),a

call store_int

ld a,&c3
ld hl,dma_int
ld (&0038),a
ld (&0039),hl

ld ix,result_buffer

ld a,%1
call init_dma
ei
halt
di
xor a
ld (&6c0f),a
ld a,(dma_dcsr)
and %01110000
ld (ix+0),a
inc ix
ld (ix+0),%01000000
inc ix

ld a,%10
call init_dma
ei
halt
di
xor a
ld (&6c0f),a
ld a,(dma_dcsr)
and %01110000
ld (ix+0),a
inc ix
ld (ix+0),%00100000
inc ix

ld a,%100
call init_dma
ei
halt
di
xor a
ld (&6c0f),a
ld a,(dma_dcsr)
and %01110000
ld (ix+0),a
inc ix
;; gx4000 shows 0 here!?
ld (ix+0),0	;;%00010000
inc ix

call do_reset

call restore_int

ei

ld ix,result_buffer
ld bc,3
call simple_results
ret

dma_irq_clr:
di
ld hl,&4030	;; dma stop & int
ld (&1000),hl

call asic_enable

ld bc,&7fb8
out (c),c
ld a,0
ld (&6805),a

call store_int

ld a,&c3
ld hl,dma_int
ld (&0038),a
ld (&0039),hl

ld ix,result_buffer

ld a,%1
call init_dma
ei
halt
di
xor a
ld (&6c0f),a
ld a,(dma_dcsr)
and %01110000
ld (ix+0),a
inc ix
ld (ix+0),%00000000
inc ix

ld a,%10
call init_dma
ei
halt
di
xor a
ld (&6c0f),a
ld a,(dma_dcsr)
and %01110000
ld (ix+0),a
inc ix
ld (ix+0),%00000000
inc ix

ld a,%100
call init_dma
ei
halt
di
xor a
ld (&6c0f),a
ld a,(dma_dcsr)
and %01110000
ld (ix+0),a
inc ix
ld (ix+0),%00000000
inc ix

call do_reset

call restore_int

ei

ld ix,result_buffer
ld bc,3
call simple_results
ret

do_reset:
ld a,0
ld (&6800),a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a
ld a,1
ld (&6805),a
;;ld a,&ff
;;ld (&6c03),a
;;ld (&6c07),a
;;ld (&6c0b),a

ld bc,&7fa0
out (c),c
call asic_disable

xor a
ld b,16
reset_psg:
push bc
ld b,&f4
out (c),a
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
ld bc,&f680
out (c),c
ld bc,&f400
out (c),c
ld bc,&f600
out (c),c
pop bc
inc a
djnz reset_psg
ret

init_dma:
push af
xor a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a
ld bc,&7f00+%10011100
out (c),c
ld hl,&1000
xor a
ld (&6c00),hl
ld (&6c02),a
ld (&6c04),hl
ld (&6c06),a
ld (&6c08),hl
ld (&6c0a),a


ld b,&f5
id1:
in a,(c)
rra
jr nc,id1
id2:
in a,(c)
rra
jr c,id2

;; separate raster int from our dma ints
ld a,100
ld (&6800),a

pop af
ld (&6c0f),a

ret

dma_int:
push af
ld a,(&6c0f)
ld (dma_dcsr),a
;; clear int or it stays active
ld a,%01110000
ld (&6c0f),a
pop af
ei
reti

dma_dcsr:
defb 0



asic_enable:
	push af
	push hl
	push bc
	push de
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,16

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	
	ld a,&ee
	out (c),a
	pop de
	pop bc
	pop hl
	pop af	
	ret
	
asic_disable:
	push af
	push hl
	push bc
	push de
  ld hl,asic_sequence
	ld bc,&bc00
	ld d,15

ad1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ad1
ld a,&a5
out (c),a
pop de
	pop bc
	pop hl
	pop af	
	ret

asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd


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
include "../lib/int.asm"


end start
