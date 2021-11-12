;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; CRTC test code
;; by Kevin Thacker 1999-2001
;;
;; This source code is released under the GNU Public License version 2 or later.
;; Please see the "Copying" file that is distributed with this source code.
;;
;; This source code is written for a Maxam compatible assembler (such as the 
;; assembler built into WinAPE emulator).
;;
;; How does it work:
;;
;; a lot of these tests work by testing the vsync signal from the crtc.
;;
;; the Amstrad CPC can only detect the vsync signal
;; directly from the CRTC because it is connected to bit 0 of PPI Port B.
;;
;; it is possible to detect the HSYNC indirectly,
;; as the HSYNC is used to generate the CPC standard raster interrupt.
;;
;; TODO:
;; - test to see how changing MA at various points will affect next split address
;; - test to see how changing RA at various points will affect split
;; - test to see how changing VT at various points will affect split
;; - test to see how changing vertical adjust at various points
;; - test adjusting R1 to see how this will effect things
;;- set r0 - need to count time until vsync?;
;;
;;- set r1 - visual test (various line lengths etc)
;;- set r6 - visual test (various heights etc;;)
;;

;; horizontal pos for type 4 and type 3 and HD6845R are the same
;;- r7?
;;- r2?
;;- r3?
;;- r10?
;;- r11?
;;- r12?
;;- r13?
;;- r14?
;;- r15;?

;;- check vsync delay with r8 somehow? done?
;;- r4=0, r7=0, change r9 and count vsync length with fixed vsync to see what happens if it goes over r9. - does it stop?
;;- r4=39, r7=0, set r9 = 2, and change vsync length and see what happens if it goes over. - does it stop?
;;- interrupt vsync
;;- interrupt hsync
;;- set hsync and use interrupt and vsync to time length
;;- try to interrupt hsync
;;- r1 - various length lines (=r0, >r0, =0)
;;- r0=short, r9=0, r4=0, see if hsync ever stops - check with int??
;;find mirror
;;check raster int relative to hsync (using vsync) for plus and for cpc.
;;- pri and dma im2 bug
;;- R7=0, R4=val. At R4=val-1 and through R4=val, set R4 to val*2 and then back to R4=val-1. See when VSYNC becomes active. This should find if:
;;Symbiface 2 apply /exp?
;;
;;Symbiface 2 respond to f888 reset port thing?
;;
;;Crtc 12/13 change various places/lines etc. including on type 1.
;;
;;Change 13/12 separately.
;;R4 is latched and the point at which it is used.
;;
;;Cursor tests type 3 and 4.
;;
;;Cursor affects pri, splt etc?
;;
;;Test r9 during r8=3 to find if r9 is normal or not.
;;
;;R8=0, r8=1, r8=2 and R8=3 and pri (do for r8=0 then r8=1 and over multiple frames) – can be an auto test rather than visual
;;
;partial

include "../lib/testdef.asm"

delay_pause equ 64*9

;;  these are the number of nop cycles/1us cycles in a 50hz frame
vsync_timeout  equ     19968

org &4000
;;nolist
;;write"crtctest.bin"

start:
call cls

ld hl,choose_crtc_message
call output_msg
;;-------------------------------------------------------
;; type we are testing...
;; 0 = UM6845/HD6845S
;; 1 = UM6845R
;; 2 = MC6845
;; 3 = ASIC CRTC
;; 4 = PreASIC
;; 5 = HD6845R (KC Compact)
call &bb06
ld a,'3'
cp '0'
jr c,start
cp '5'
jr nc,start
sub '0'
ld (crtc_type),a

;; store interrupt vector
call store_int

;; do the test routines
ld ix,test_routines
call run_tests
call wait_key
ret

choose_crtc_message:
defb "Press key of CRTC type to test",13
defb "0: UM6845/HD6845S",13
defb "1: UM6845R",13
defb "2: MC6845",13
defb "3: ASIC CRTC",13
defb "4: Cost Down CRTC",13
defb "5: HD6845R",13,0

;; retest type 4 and 2

;;-----------------------------------------------------------------------------------------------
;; tests we can automate and are not visual based

test_routines:
;; type 3:
;; fe *8
;; fe * 1, ff * 7
;; fe *8
;; fe*1,ff *7
;; fe *8 
;; 
;; later is fe*8
;; ff*8
;;
;; fe * 7, ff *1
;; ff*7, fe*1

;; fe * 4, ff * 4
;; ff * 4, fe * 4
;;
;; gradually allows it.
;; seems to be at end of line test
;;
;; type 2:
;; fe * 8
;; fe * 1,ff * 7
;; 5f *1, fe * 7
;; fe *1,fe * 7
;;
;; gradually gets to:
;; fe * 6, ff * 2
;; ff * 8
;; gradually each column to the right fills with 5f
;; fe * 5, ff * 3
;; ff * 8
;; etc
;;
;; type 1:
;; 5e * 7, 5f
;; 5f * 8
;; then 
;; 5e * 6, 5f
;; 5f * 8
;;
;; as 5f starts to go, there is at least 1 5e in there 

;;DEFINE_TEST "r4 trigger",r4_trig
;;DEFINE_TEST "r9 trigger",r9_trig

DEFINE_TEST "I/O decode test",crtc_io_decode


;; enabled vsync briefly and see if it triggers or not
;;DEFINE_TEST "vsync start at any line?", vsync_pos_set2

;; type 1 fails all of these with 0s all the time
DEFINE_TEST "vsync r8 test (r8=0)", vsync_r8_0
DEFINE_TEST "vsync r8 test (r8=1)", vsync_r8_1
DEFINE_TEST "vsync r8 test (r8=2)", vsync_r8_2
DEFINE_TEST "vsync r8 test (r8=3)", vsync_r8_3
;; type 1 has 1s for all.
DEFINE_TEST "vsync r8 htot/2 test", vsync_r8_htot
;; succeed type 4
;; succeed type 3
;; succeed type 2
;; succeed type 1
;; succeed type 0
;; HD6845R got 0 for all 
DEFINE_TEST "reg 12,13: read/write", r12_r13_read_write
;; succeed type 4
;; succeed type 3
;; succeed type 2
;; succeed type 1
;; succeed type 0 (as type 2)
;; HD6845R succeed
DEFINE_TEST "reg 14,15: read/write", r14_r15_read_write
;; succeed on type 1
;; succeed on type 2
;; succeed on type 0
;; succeed on type 5
DEFINE_TEST "other registers r/w (0,1,2,5 only)",reg_read_write
;; succeed type 2
;; succeed type 1
;; type 3 succeeded; registers repeat
;; succeed type 0
;; HD6845R succeeded
DEFINE_TEST "register write repeat (regindex & 0x031)", reg_write_repeat

;; succeed type 4
;; type 3 succeeded
;; succeed type 2
;; succeed type 1
;; succeed type 0
;; HD6845R succeeded
DEFINE_TEST "R4 - count lines",r4_count_lines
;; succeed type 4
;; type 3 succeeded
;; succeed type 2
;; succeed type 1
;; succeed type 0
;; HD6845R succeeded
DEFINE_TEST "R9 - count lines",r9_count_lines
;; succeed type 4
;; type 3 succeeded
;; succeed type 2
;; succeed type 1
;; succeed type 0
;; HD6845R succeeded
DEFINE_TEST "R5 - count lines",r5_count_lines
;; type 3 succeeded
;; type 2 hangs
;; type 1 succeeded
;; type 0 succeeded
;; interlace seems to be same as type 2. with 3, no need to double height of screen etc
DEFINE_TEST "R8 - count lines",r8_count_lines
;; type 4 gets stuck somewhere, something r9 related
;; HD6845R succeeded
DEFINE_TEST "R7 all",r7_mask
;; HD6845R succeeded
DEFINE_TEST "R2 all",r2_mask

;; type 0 succeeded, type 1 succeeded, type 2 succeeded
;; HD6845R succeeded
DEFINE_TEST "vsync pos normal test", vsync_pos
;; type 1 succeeded. type 2 succeeded
DEFINE_TEST "vsync length test", vsync_len_check


;; succeeded on type 0
;; type 1 succeeded, type 2 succeeded
;;DEFINE_TEST "vsync duration test", vsync_duration1
;; got ff expected 10
;; type 1 succeeded, type 2 succeeded 
;;DEFINE_TEST "vsync duration test 2", vsync_duration2

;;DEFINE_TEST "vsync len 16, r4=0, change r9", vsync_r9
;;DEFINE_TEST "vsync len 16, r9=7, change r4", vsync_r4

;; type 1, 
;;DEFINE_TEST "vsync r4/r9 various lengths", vsync_r4_r9

;; type 0: got 16
;; type 1: got 16
;; type 2: got 16
;; HD6845R succeed
DEFINE_TEST "vsync overlap vertical adjust", vsync_overlap_vadj
;; HD6845R 0,0,0,1,9,11,19,ff etc
DEFINE_TEST "minimum VADJ value to cause VSYNC to trigger in VADJ (VCC increment in VADJ)", vsync_line_check

;; enabled vsync briefly and see if it triggers or not
;;DEFINE_TEST "vsync start at any line?", vsync_pos_set2


;;DEFINE_TEST "vsync length re-program while vsync active test", vsync_len_cut
;;DEFINE_TEST "vsync length re-program while vsync active test", vsync_len_cut_check
;;DEFINE_TEST "vsync position re-program while vsync active test", vsync_pos_cut_check


;; type 1 succeeded
;; type 0 succeeded
;; type 2: 0,1 for a bit then all 1's 22, then two 0's at end
;; like type 2
DEFINE_TEST "hsync pos test",hsync_pos_check
;; on type 1 succeeded
;; on type 2 succeeded
;; like type 2
DEFINE_TEST "hsync length gives interrupt", crtc_check_hsync_generated
DEFINE_TEST "hsync length measure (type 2)", crtc2_get_hs_length

;; THIS NEEDS FIXING
;;DEFINE_TEST "hsync length measure (2)", hsync_len_check


DEFINE_TEST "register read repeat (3,4 only)", reg_read_repeat34

DEFINE_END_TEST

;; no latch
;; type 0:
;; 5e x 5
;; 5f * 4 lines
;; 5f 5f 5e 5e 5e 5e 5e etc
;; 5e * 3 lines
;; 
;; near middle massive block of 5e for about 31 lines or so.

;; seems to latch
;; type 1:
;; same as type 2 it seems but not so quick to go down
;; 5e 5e 5e 5e 5e 5f 5f 5f
;; full 5f*7
;; 5e 5e 5e 5e 5e 5f 5f 5f 
;; full 5f*7
;; 5e 5e 5e 5e 5e 5f 5f 5f 
;; full 5f*7
;; 5e 5e 5e 5e 
;; full 5f*7
;; jumps between 5 and 4 5e but always 5f * 7 between

;; seems to latch
;; type 2:
;; goes from 5,4,3,2,1,0 with 5f * 7 in between.

;; no latch
;; type 3:
;; fe fe fe fe fe ff ff ff
;;ff full * 4
;; ff ff fe fe fe fe fe fe
;; full fe*2
;; fe fe fe fe fe ff ff ff 
 ;; ff full *4
 ;; ff ff fe fe fe fe fe fe
 ;;

r9_trig:
di
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+2
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

ld bc,128
ld ix,r9t1
ld (r9t2+1),ix
ld hl,results_buffer
rt2:
push bc
push ix
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
call wait_vsync_start
ld a,16+6
call wait_x_lines
defs 64-17-3-3-4-1-3-4-1-4-1
ld de,&1f07
ld bc,&bc09
out (c),c
inc b
r9t2:
jp r9t1
defs 128
r9t1:
out (c),d
nop
out (c),e
ld e,64
ld b,&f5
r9t3:
in a,(c)
ld (hl),a
inc hl
inc hl
dec e
jr nz,r9t3
pop ix
dec ix
ld (r9t2+1),ix

pop bc
dec bc
ld a,b
or c
jp nz,rt2
call crtc_reset
ei
ld ix,results_buffer
ld bc,64*128
ld d,16
call simple_number_grid
ret

r4_trig:
di
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+2
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

ld bc,64*8
ld ix,r4t1
ld (r4t2+1),ix
ld hl,results_buffer
rtr24:
push bc
push ix
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
call wait_vsync_start
ld a,15
call wait_x_lines
defs 64-17-3-3-4-1-3-4-1-4-1
ld de,&0302
ld bc,&bc04
out (c),c
inc b
r4t2:
jp r4t1
defs 64*8
r4t1:
out (c),d
nop
out (c),e
ld e,16
ld b,&f5
r4t3:
in a,(c)
ld (hl),a
inc hl
inc hl
defs 64-2-2-3-4-1-3
dec e
jp nz,r4t3
pop ix
dec ix
ld (r4t2+1),ix

pop bc
dec bc
ld a,b
or c
jp nz,rtr24
call crtc_reset
ei
ld ix,results_buffer
ld bc,16*8*128
ld d,16
call simple_number_grid
ret


r7_mask:
di
ld ix,results_buffer

ld bc,&bc04
out (c),c
ld bc,&bd00+&ff
out (c),c

ld b,0
xor a
r7m:
push bc
push af

push af
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
pop af
ld bc,&bc07
out (c),c
ld b,&bd
out (c),a

call check_vsync_occured
ld a,0
adc a,0
ld (ix+0),a
inc ix
ld (ix+0),0	;; expected that it occurs
inc ix
pop af
inc a
pop bc
djnz r7m

call crtc_reset
ei

ld ix,results_buffer
ld bc,256
call simple_results
ret

r2_mask:
di
call store_int

;; setup a new int
di
ld a,&c3
ld hl,int_count
ld (&0038),a
ld (&0039),hl
ei

ld ix,results_buffer

ld bc,&bc03
out (c),c
ld bc,&bd01
out (c),c

ld bc,&bc00
out (c),c
ld bc,&bd00+&ff
out (c),c

ld b,0
xor a
r2m:
push bc
push af

ld bc,&bc02
out (c),c
ld b,&bd
out (c),a

;; reset counter
xor a
ld (counter),a
ei
call wait_frame
di
;; if counter!=0 this means a int occured. This also
;; means that a hsync was generated.
ld a,(counter)
or a
ld a,1
jr nz,r2mm
xor a
r2mm:
ld (ix+0),a
inc ix
ld (ix+0),1	;; expected that it occurs
inc ix

pop af
inc a
pop bc
djnz r2m

call restore_int
call crtc_reset
ei

ld ix,results_buffer
ld bc,256
call simple_results
ret


;; check R4 wrap etc

r4_count_lines:
;; checks r4 wrap AND checks heights are expected
di
ld ix,results_buffer

ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&08
out (c),c


ld b,0
xor a
r4cl:
push bc
push af

push af
ld bc,&bc04
out (c),c
ld bc,&bd00+16
out (c),c
call vsync_sync
call vsync_sync

call wait_vsync_start
pop af
ld b,&bd
out (c),a
push af
call count2_lines_to_vsync
pop af
ld (ix+0),e
ld (ix+2),d

and &7f
cp 2
ld hl,&ffff
jr c,r4cl2

ld l,a
ld h,0
inc hl
add hl,hl
add hl,hl
add hl,hl
r4cl2:
ld (ix+1),l
ld (ix+3),h
inc ix
inc ix
inc ix
inc ix

pop af
inc a
pop bc
djnz r4cl

call crtc_reset
ei

ld ix,results_buffer
ld bc,256*2
call simple_results
ret


r9_count_lines:
;; checks r9 wrap AND checks heights are expected

di
ld ix,results_buffer

ld bc,&bc04
out (c),c
ld bc,&bd00+15
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00+&08
out (c),c

ld b,0
xor a
r9cl:
push bc
push af

push af
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
call vsync_sync
call vsync_sync

call wait_vsync_start
pop af
ld b,&bd
out (c),a
push af
call count2_lines_to_vsync
pop af
ld (ix+0),e
ld (ix+2),d

and &1f
or a
ld hl,&ffff
jr z,r9cl2
ld l,a
ld h,0
inc hl
add hl,hl
add hl,hl
add hl,hl
add hl,hl
r9cl2:
ld (ix+1),l
ld (ix+3),h
inc ix
inc ix
inc ix
inc ix

pop af
inc a
pop bc
djnz r9cl

call crtc_reset
ei

ld ix,results_buffer
ld bc,256*2
call simple_results
ret


r5_count_lines:
;; checks r5 wrap AND checks heights are expected

di
ld ix,results_buffer

ld bc,&bc04
out (c),c
ld bc,&bd03
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&08
out (c),c

ld b,0
xor a
r5cl:
push bc
push af

push af
ld bc,&bc05
out (c),c
ld bc,&bd00+0
out (c),c
call vsync_sync
call vsync_sync

call wait_vsync_start
pop af
ld b,&bd
out (c),a
push af
call count2_lines_to_vsync
pop af
ld (ix+0),e
ld (ix+2),d

and &1f
ld l,a
ld h,0
ld bc,32
add hl,bc
ld (ix+1),l
ld (ix+3),h
inc ix
inc ix
inc ix
inc ix

pop af
inc a
pop bc
djnz r5cl

call crtc_reset
ei

ld ix,results_buffer
ld bc,256*2
call simple_results
ret


r8_count_lines:
;; checks 0,1,2,3 for r8
;; checks odd/even r9/r4 with them
;; measures for two frames in case height is different on each (e.g. type 0)

di
ld ix,results_buffer

ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c
call r8_cl

ld bc,&bc08
out (c),c
ld bc,&bd01
out (c),c
call r8_cl

ld bc,&bc08
out (c),c
ld bc,&bd02
out (c),c
call r8_cl

ld bc,&bc08
out (c),c
ld bc,&bd03
out (c),c
call r8_cl

call crtc_reset
ei

ld hl,r8_results
ld b,32
call poke_word_results
ret

r8_results
defw crtc0_r8_count ;; 0
defw crtc1_r8_count ;; 1
defw crtc3_r8_count
defw crtc3_r8_count ;; 3
defw crtc4_r8_count
defw crtc5_r8_count


crtc5_r8_count:
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &99	;; 9a not 99
defw &99 ;; 9a not 9b
defw &90	;; 91 not 90
defw &90		;; 91 not 92
defw &88	;; 91 not 92
defw &88	;; 89 not 88
defw &80	;; 89 not 8a
defw &80	;; 81 not 80
defw &99 ;; 81 not 82
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80


crtc0_r8_count:
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &55
defw &55
defw &50
defw &50
defw &4d
defw &4d
defw &48
defw &48

crtc1_r8_count:
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &9a
defw &9a
defw &91
defw &91
defw &89
defw &89
defw &81
defw &81
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &4e
defw &4d
defw &49
defw &49
defw &45
defw &45
defw &41
defw &41




crtc3_r8_count:
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &99
defw &9b	;; 9a
defw &90
defw &92
defw &88
defw &8a
defw &80
defw &82
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &55
defw &57
defw &50
defw &52
defw &4c
defw &4e
defw &48
defw &4a


crtc4_r8_count:
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &9b
defw &99
defw &92
defw &90
defw &8a
defw &88
defw &82
defw &80
defw &99
defw &99
defw &90
defw &90
defw &88
defw &88
defw &80
defw &80
defw &57
defw &55
defw &52
defw &50
defw &4e
defw &44
defw &4a
defw &48


;; R9 = even, R4 = even
;; R9 = even, R4 = odd
;; R9 = odd, R4 = even
;; R9 = odd, R4 = odd
r8_cl:
ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c


;; R9 = even, R4 = even 
ld bc,&bc09
out (c),c
ld bc,&bd00+8
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+16
out (c),c
call check_vsync_occured
jr nc,r8cl1
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl2
r8cl1:
call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl2:
inc ix
inc ix
inc ix
inc ix
call check_vsync_occured
jr nc,r8cl3
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl4
r8cl3:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl4:
inc ix
inc ix
inc ix
inc ix


;; R9 = even, R4 = odd 
ld bc,&bc09
out (c),c
ld bc,&bd00+8
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+15
out (c),c
call check_vsync_occured
jr nc,r8cl5
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl6
r8cl5:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl6:
inc ix
inc ix
inc ix
inc ix

call check_vsync_occured
jr nc,r8cl7
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl8
r8cl7:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl8:
inc ix
inc ix
inc ix
inc ix

;; R9 = odd, R4 = even 
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+16
out (c),c

call check_vsync_occured
jr nc,r8cl9
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl10
r8cl9:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl10:
inc ix
inc ix
inc ix
inc ix

call check_vsync_occured
jr nc,r8cl11
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl12
r8cl11:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl12:
inc ix
inc ix
inc ix
inc ix
;; R9 = odd, R4 = odd 
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+15
out (c),c
call check_vsync_occured
jr nc,r8cl13
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl14
r8cl13:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl14:
inc ix
inc ix
inc ix
inc ix

call check_vsync_occured
jr nc,r8cl15
ld (ix+0),&ff
ld (ix+2),&ff
jr r8cl15
r8cl15:

call vsync_sync
call vsync_sync

call wait_vsync_start
call count2_lines_to_vsync
ld (ix+0),e
ld (ix+2),d

r8cl16:
inc ix
inc ix
inc ix
inc ix
ret

count2_lines_to_vsync:
;; vsync i/o
ld b,&f5
;; line counter
ld de,0

in a,(c)
ld c,a

;; check vsync...
c2ltv1: 
in a,(c)	;; [4]
xor c		;; [1] - changed?
jp z,t1		;; [3] - no change
xor c		;; [1] - did change
ld c,a		;; [1] - store new state
rra			;; [1] - vsync set?
jp c,c2ltv2	;; [3] - yes vsync set
;; no vsync not set
t2:
defs 64-3-1-1-2-3-1-1-1-3-1-4
;; increment counter
inc de	;; [2]
ld a,d	;; [1]
or e	;; [1]
jp nz,c2ltv1 ;;[3]
ld de,&ffff
scf
ret


;; no change
t1: 
xor c		;; [1]
ld c,a		;; [1]
defs 1
jp t2

;; start of vsync found
c2ltv2:
or a
ret




;;--------------------------------
if 0
count2_lines_to_vsync:
;; vsync i/o
ld b,&f5
;; line counter
ld de,0
;; check vsync...
c2ltv1: 
in a,(c)		;; [4]
rra				;; [1]
jp c,c2ltv2		;; [3]
ld c,a
defs 64-3-1-1-2-3-1-4
;; increment counter
inc de	;; [2]
ld a,d	;; [1]
or e	;; [1]
jp nz,c2ltv1 ;;[3]
ld de,&ffff
scf
ret

;; start of vsync found
c2ltv2:
or a
ret
endif

reg_write_repeat:
di
call store_int



ld ix,results_buffer
ld b,8
xor a
rwr1:
push bc
push af
;; stop vsync using official register
ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c

push af
call wait_frame
call wait_frame
pop af

;; try to use mirror register
ld b,&bc
add a,7
out (c),a
ld bc,&bd00
out (c),c

;; did a vsync occur?
call check_vsync_occured
ld a,0
adc a,0
ld (ix+0),a
inc ix
ld (ix+0),0	;; expected that it occurs
inc ix

pop af
add a,32
pop bc
djnz rwr1

;; setup a new int
di
ld a,&c3
ld hl,int_count
ld (&0038),a
ld (&0039),hl
ei

ld b,8
xor a
rwr1b:
push bc
push af
;; stop hsync using official register
ld bc,&bc02
out (c),c
ld bc,&bdff
out (c),c

push af
call wait_frame
call wait_frame
pop af

;; try to use mirror register
ld b,&bc
add a,2
out (c),a
ld bc,&bd00
out (c),c

;; reset counter
xor a
ld (counter),a
ei
call wait_frame
di
;; if counter!=0 this means a int occured. This also
;; means that a hsync was generated.
ld a,(counter)
or a
ld a,1
jr nz,rwr1b2
xor a
rwr1b2:
ld (ix+0),a
inc ix
ld (ix+0),1	;; expected that it occurs
inc ix

pop af
add a,32
pop bc
djnz rwr1b

call restore_int
call crtc_reset
ei
ld ix,results_buffer
ld bc,16
call simple_results
ret


crtc_io_decode:
di

call store_int
ld hl,&c9fb
ld (&0038),hl

ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl


ld de,0
ld bc,0
nextloop:
push bc
push de
push hl

push bc
push de
push hl
call restore
pop hl
pop de
pop bc

push bc
;; try and disable vsync
ld bc,&bc07
out (c),c
pop bc
ld a,&ff
out (c),a
;; ensure we can read port b
ld bc,&f700+%10000010
out (c),c

call check_vsync_occured
jr c,next

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
pop hl
pop de
pop bc
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

call restore_int
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

ld ix,results_buffer
ld de,(portimportant)
ld (ix+0),e
ld (ix+1),&00
ld (ix+2),d
ld (ix+3),&43
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&ff
ld (ix+6),h
ld (ix+7),&bd
ld bc,4
call simple_results
ret



portsuccessOR:
defw 0
portsuccessAND:
defw 0

portimportant:
defw 0




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



;;-----------------------------------------------------------------------------------------------
reg_read_repeat34:
ld a,(crtc_type)
cp 3
jp z,rrr34
cp 4
jp z,rrr34
jp report_skipped

rrr34:

;; register 12/13, 14/15 can be written we can write then check all other "mirrors" are the same
di
ld ix,results_buffer

;; check r12
ld c,12
ld d,&3f
call check_mirror
;; check r13
ld c,13
ld d,&ff
call check_mirror
;; check r14
ld c,14
ld d,&3f
call check_mirror
;; check r15
ld c,15
ld d,&ff
call check_mirror

call crtc_reset
ei

ld ix,results_buffer
ld bc,256*4
call simple_results
ret

;;-----------------------------------------------------------------------------------------------

;; C = register
;; D = mask
check_mirror:
ld a,c
and &7
ld l,a

ld e,0
cm1:
;; register number
ld b,&bc
out (c),c

;; write to register
ld b,&bd
out (c),e
inc e

;; E = value to look for
;; D = mask
;; L = mirror value (0-7)
call check_mirror_reg34
ld a,1
jr c,cm2
ld a,0
cm2:
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

inc e
jr nz,cm1
ret

;;-----------------------------------------------------------------------------------------------

;; E = value to look for
;; D = mask
;; L = mirror value (0-7)

check_mirror_reg34:
push de
ld a,e
and d
ld e,a

;; check mirrors
ld h,0
cmr341:
;; select register
ld b,&bc
out (c),h

ld a,h
and &7
cp l
jr nz,cmr342	;; register is not a mirror
;; register is a mirror

;; read it
ld b,&bf
in a,(c)
;; mask it
and d
;; compare value
cp e
jr nz,cmr343
;; same

cmr342:
inc h
jr nz,cmr341
pop de
or a
ret


cmr343:
pop de
;; not same
scf
ret



;;-----------------------------------------------------------------------------------------------

reg_read_write:
ld a,(crtc_type)
cp 3
jp z,report_skipped
cp 4
jp z,report_skipped
di
ld ix,results_buffer
ld b,end_other_reg-other_reg
ld iy,other_reg
rrw1:
ld c,(iy+0)
inc iy
push bc
push ix
call crtc_reg_rw_not
pop ix
pop bc
push bc
call crtc_reg_rw
pop bc
djnz rrw1
call crtc_reset
ei
ld ix,results_buffer
ld bc,256*(end_other_reg-other_reg)
call simple_results

ret

;;-----------------------------------------------------------------------------------------------

;; 12,13, 14,15 and 31 are tested elsewhere
;; 16,17 readable on all, and is lpen registers
other_reg:
defb 0,1,2,3,4,5,6,7,8,9,10,11,18,19,20,21,22,23,24,25,26,27,28,29,30
end_other_reg:

;;-----------------------------------------------------------------------------------------------

r12_r13_read_write:
di
ld ix,results_buffer
push ix

;; type 0 says ok with ff for reg 12
ld d,&ff
;;ld d,&3f			;; mask correct for all??
;;???????
call r12_r13_set_exp
pop ix
ld c,12
call crtc_reg_rw
push ix
ld d,&ff
call r12_r13_set_exp
pop ix
ld c,13
call crtc_reg_rw
call crtc_reset
ei
ld ix,results_buffer
ld b,256*2
call simple_results
ret

r12_r13_set_exp:
ld a,(crtc_type)
or a
jp z,crtc_reg_rw_exp
cp 1
jp z,crtc_reg_rw_not
cp 2
jp z,crtc_reg_rw_not
cp 4
jp z,crtc_reg_rw_exp
cp 3
jp z,crtc_reg_rw_exp
cp 5
jp z,crtc_reg_rw_not

ret


;;-----------------------------------------------------------------------------------------------

r14_r15_read_write:
di
ld ix,results_buffer
push ix
;; type 0 says ok with ff for reg 14
ld d,&ff
;; mask correct for all (type 3 and type 4 may disagree)
;;ld d,&3f
call crtc_reg_rw_exp
pop ix
ld c,14
call crtc_reg_rw
push ix
ld d,&ff
call crtc_reg_rw_exp
pop ix
ld c,15
call crtc_reg_rw
call crtc_reset
ei
ld ix,results_buffer
ld b,256*2
call simple_results
ret

;;-----------------------------------------------------------------------------------------------
;; for crtc where registers are not readable
crtc_reg_rw_exp:
ld e,0
crrwe1:
;; expected mask
ld a,e
and d
ld (ix+1),a
inc ix
inc ix
inc e
jr nz,crrwe1
ret

;;-----------------------------------------------------------------------------------------------

;; for crtc where registers are not readable
crtc_reg_rw_not:
ld e,0
crrwn1:
;; expected mask
ld (ix+1),0
inc ix
inc ix
inc e
jr nz,crrwn1
ret

;;-----------------------------------------------------------------------------------------------

crtc_reg_rw:
ld e,0
crrw1:
;; select register
ld b,&bc
out (c),c
;; write data
ld b,&bd
out (c),e
;; select register
ld b,&bc
out (c),c
;; read it back
ld b,&bf
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc e
jr nz,crrw1
ret

;;-------------------------------------------------------------------------------------------

crtc1_r31:
ld a,(crtc_type)
cp 3
jp z,report_skipped
cp 4
jp z,report_skipped

di
ld ix,results_buffer
ld a,(crtc_type)
cp 1
jr nz,cr31b
;; type 1 (not hd6845r - no register 31 on this)
push ix
ld e,0
cr31a:
ld (ix+1),&ff
inc ix
inc ix
inc e
jr nz,cr31a
pop ix
jr cr31c
cr31b:
;; other types
push ix
call crtc_reg_rw_not
pop ix
cr31c:
ld c,31
call crtc_reg_rw
call crtc_reset
ei
ld ix,results_buffer
ld bc,256*2
call simple_results
ret

;;-------------------------------------------------------------------------------------------


;;defw crtc_reg_changes
;;defw crtc_check_be_equals_bf
;;defw crtc_check_reg_or_masks
;;defw crtc_check_reg_and_masks
;;defw crtc_check_regs2_readable
;;defw crtc_check_regs_readable
;;defw crtc_bf_all_same
;;defw crtc_be_all_same
;;defw crtc_results
;;defw detect_isv
;;defw vadj_comp_check
;;defw vtot_comp_check
;;defw mr_comp3_check
;;defw vsync_pos_change_possible
;;defw vsync_exact_pos
;;defw detect_isv
;;defw vadj_comp_check
;;defw vtot_comp_check
;;defw mr_comp_check
;;defw mr_comp2_check
;;defw vsync_pos_check
;;defw vtot_check
;;defw vtot2_check
;;defw vsync_len_cut
;;defw detect_isv
;;defw crtc_check_hsync_generated
;;defw crtc_reg_changes
;;defw crtc_check_be_equals_bf
;;defw crtc_check_reg_or_masks
;;defw crtc_check_reg_and_masks
;;defw crtc_check_regs2_readable
;;defw crtc_check_regs_readable
;;defw crtc_bf_all_same
;;defw crtc_results
;;defw 0


;;-----------------------
;; hl = start of buffer
;; bc = length of buffer
;; carry set = not all same, carry clear = all same

check_all_same:
;; get first
ld a,(hl)
inc hl
dec bc

cas1b:
;; count over?
ld a,b
or c
jr z,cas2b
;; decrement counter
dec bc
;; get next byte
xor (hl)
;; increment buffer ptr
inc hl
jp nz,cas3b

jp cas1b

cas2b:
or a
ret

cas3b:
scf
ret

;;-----------------------

;; sync with start of vsync
vsync_sync:
ld b,&f5
;; wait for vsync start
vs1: in a,(c)
rra
jr nc,vs1
;; wait for vsync end
vs2: in a,(c)
rra 
jr c,vs2
ret



;;---------------------------
;; count the number of scan-lines 
;; that the vsync is active for this will
;; be the duration of the vsync
count_vsync_lines:
push bc
push de

;; sync with start of vsync
call vsync_sync

;; wait for start of vsync
ld e,0
ld b,&f5
cvl1: 
in a,(c)
rra
jp nc,cvl1
;; got vsync. At least one line has occured.

cvl2:
in a,(c)		;; [4]
rra				;; [1]
jp nc,cvl3		;; [3]
inc e			;; [1]
jp z,cvl2b			;; [3]
defs 64-1-3-1-4-3-3
jp cvl2			;; [3]

cvl2b:
ld e,&ff

;; vsync has ended
cvl3:
ld a,e
pop de
pop bc
ret

count_vsync_lines_immediate:
ld e,0
ld b,&f5
;; check each line
cvli2:
in a,(c)			;; [4]
rra					;; [1]
jp nc,cvli3			;; [3]
inc e			;; [1]
jp z,cli2b			;; [3]
defs 64-1-3-1-4-3-3
jp cvli2			;; [3]
cli2b:
ld e,&ff
cvli3:
ld a,e
ret

;; try vsync on every line 0-r4. it's an exhaustive test
;; this is checking a vsync is triggered under normal operation
vsync_pos:
di
ld ix,results_buffer

ld bc,&bc04
out (c),c
ld bc,&bd00+39
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00+&8f
out (c),c

;; type 0 has none on last line
push ix
ld b,41
xor a
vp1:
push af
cp 40
ld a,0
jr nz,vp1b
ld a,1
vp1b:
ld (ix+1),a
inc ix
inc ix
pop af
inc a
djnz vp1
pop ix

ld b,41
xor a
vp2:
push bc
push af
ld bc,&bc07
out (c),c
inc b
out (c),a
call wait_frame
call wait_frame
;; did a vsync occur?
call check_vsync_occured
ld a,0
adc a,0
ld (ix+0),a
inc ix
inc ix
pop af
inc a
pop bc
djnz vp2


call crtc_reset
ei
ld ix,results_buffer
ld bc,41
call simple_results

ret

vsync_duration1:
di
ld ix,results_buffer

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00+&0f	;; long vsync; longer than a char line
out (c),c

call vsync_sync

;; 1 char line tall
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

call count_vsync_lines

;; store got
ld (ix+0),a
inc ix
;; type 0 reports 16; expected it will loop after a while
;; type 3 reports 0x0ff

ld a,(crtc_type)
or a
ld c,&10
jr z,vdur1
cp 1
jr z,vdur1
cp 2
jr z,vdur1
cp 3
ld c,&ff
jr z,vdur1
ld c,0		;; not tested
vdur1:
ld (ix+0),c
inc ix

call crtc_reset
ei
ld ix,results_buffer
ld bc,1
call simple_results

ret

vsync_duration2:
di
ld ix,results_buffer

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00+&0f	;; long vsync; same as a char line
out (c),c

call vsync_sync

;; 2 char line tall
ld bc,&bc04
out (c),c
ld bc,&bd01
out (c),c

call count_vsync_lines

;; store got
ld (ix+0),a
inc ix
ld (ix+0),&ff ;; type 0 gives ff, vsync lasts forever! same on type 1 and 2 and 3
inc ix

call crtc_reset
ei
ld ix,results_buffer
ld bc,1
call simple_results

ret


vsync_r9:
di
call store_int
ld hl,&c9fb
ld (&0038),hl
ld ix,results_buffer

;; change r9 height and see if vsync stops
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00
out (c),c

ld b,32
ld e,0
vr9:
push bc
push de
ei
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
call check_vsync_occured
jr nc,vr9b
ld (ix+0),&ff
inc ix
ld (ix+0),&ff
inc ix
jr vr9c
vr9b:
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
call wait_vsync_start
halt
di
ld a,5
call wait_x_lines
defs 64-3-4-1-1
ld bc,&bc09
out (c),c
inc b
out (c),e
call count_vsync_lines_immediate
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix
vr9c:
pop de
inc e
pop bc
dec b
jp nz,vr9
call restore_int
call crtc_reset
ei
ld ix,results_buffer
ld bc,64
call simple_results

ret

vsync_r4:
di
call store_int
ld hl,&c9fb
ld (&0038),hl
ld ix,results_buffer

;; change r9 height and see if vsync stops
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00
out (c),c

ld b,8
ld e,0
vr4:
push bc
push de
ei
ld bc,&bc04
out (c),c
ld bc,&bd00+7
out (c),c
call check_vsync_occured
jr nc,vr4b
ld (ix+0),&ff
inc ix
ld (ix+0),&ff
inc ix
jr vr4c
vr4b:
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
call wait_vsync_start
halt
di
ld a,5
call wait_x_lines
defs 64-3-4-1-1
ld bc,&bc04
out (c),c
inc b
out (c),e
call count_vsync_lines_immediate
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix
vr4c:
pop de
inc e
pop bc
dec b
jp nz,vr4
call restore_int
call crtc_reset
ei
ld ix,results_buffer
ld bc,64
call simple_results

ret


vsync_r8_0:
ld a,0
ld hl,r8_0_results
jr vsync_r8


vsync_r8_1:
ld a,1
ld hl,r8_1_results
jr vsync_r8

vsync_r8_2:
ld a,2
ld hl,r8_2_results
jr vsync_r8

vsync_r8_3:
ld a,3
ld hl,r8_3_results
jr vsync_r8

r8_0_results:
r8_2_results:
defb 1,1,1,1,1,1,1,1,1,1
defb 1,1,1,1,1,1,1,1,1,1
defb 1,1,1,1,1,1,1,1,1,1
defb 1,1,1,1,1,1,1,1,1,1

r8_1_results:
r8_3_results:
defb 1,1,1,1,1,1,1,1,1,1
defb 0,0,0,0,0,0,0,0,1,1
defb 1,1,1,1,1,1,1,1,1,1
defb 0,0,0,0,0,0,1,1,1,1

vsync_r8:
di
exx
push bc
push de
push hl
exx

push af
push hl
call store_int
ld hl,&c9fb
ld (&0038),hl
pop hl
ld ix,results_buffer
ld b,10*4
vr822:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
djnz vr822
ld ix,results_buffer

ld bc,&bc03
out (c),c
ld bc,&bd00+&08
out (c),c


pop af


ld d,4
vr8:
push de
push af

push af

ld bc,&bc07
out (c),c
ld bc,&bd00+36	
out (c),c

ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
pop af

ld bc,&bc08
out (c),c
inc b
out (c),a

ei
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
ld a,d
and &1
jr z,vr8b
call vsync_sync
vr8b:
;; wait for start of vsync
ld b,&f5
vr8a:
in a,(c)
rra 
jr nc,vr8a
halt
di
ld a,24
call wait_x_lines
ld bc,&bc07		;; start next frame
out (c),c
ld bc,&bd01
out (c),c
ld a,5
call wait_x_lines
defs 64-15-2-1-2-1

ld b,&f5
exx
ld b,&f5
exx

in a,(c)
in d,(c)
in e,(c)
in h,(c)
in l,(c)
in c,(c)
exx
in d,(c)
in e,(c)
in h,(c)
in l,(c)
exx
and &1
ld (ix+0),a
inc ix
inc ix
ld a,d
and &1
ld (ix+0),a
inc ix
inc ix
ld a,e
and &1
ld (ix+0),a
inc ix
inc ix
ld a,h
and &1
ld (ix+0),a
inc ix
inc ix
ld a,l
and &1
ld (ix+0),a
inc ix
inc ix
ld a,c
and &1
ld (ix+0),a
inc ix
inc ix

exx
ld a,d
and &1
ld (ix+0),a
inc ix
inc ix
ld a,e
and &1
ld (ix+0),a
inc ix
inc ix
ld a,h
and &1
ld (ix+0),a
inc ix
inc ix
ld a,l
and &1
ld (ix+0),a
inc ix
inc ix
exx

pop af
pop de
dec d
jp nz,vr8
di
exx
pop  hl
pop  de
pop  bc
exx
call restore_int
call crtc_reset


ei
ld ix,results_buffer
ld bc,10*4
call simple_results

ret

vsync_r8_htot:
di
exx
push bc
push de
push hl
exx
call store_int
ld hl,&c9fb
ld (&0038),hl

ld ix,results_buffer

ld bc,&bc03
out (c),c
ld bc,&bd00+&08
out (c),c


;; 4-> 8
;; 8->16
;; 16->32
;; 32->64

ld b,40
ld a,8
vr8q:
push bc
push af

push af
ld bc,&bc00
out (c),c
ld bc,&bd3f
out (c),c
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync


ld bc,&bc07
out (c),c
ld bc,&bd00+36	
out (c),c
ei
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
;; wait for start of vsync
ld b,&f5
vr8aq:
in a,(c)
rra 
jr nc,vr8aq
halt
di
ld a,24
call wait_x_lines

ld bc,&bc08
out (c),c
ld bc,&bd01
out (c),c

ld bc,&bc07		;; start next frame
out (c),c
ld bc,&bd01
out (c),c

ld a,5
call wait_x_lines

ld bc,&bc00
out (c),c
ld b,&bd
pop af

defs 64-15-2-1-2-1-6-3-4-3-4
out (c),a

ld b,&f5
exx
ld b,&f5
exx

in a,(c)
in d,(c)
in e,(c)
in h,(c)
in l,(c)
in c,(c)
exx
in d,(c)
in e,(c)
in h,(c)
in l,(c)
exx

and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,d
and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,e
and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,h
and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,l
and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,c
and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,b
and &1
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
exx
ld a,d
and &1
ld (ix+0),a
inc ix
inc ix
ld a,e
and &1
ld (ix+0),a
inc ix
inc ix
ld a,h
and &1
ld (ix+0),a
inc ix
inc ix
ld a,l
and &1
ld (ix+0),a
inc ix
inc ix
exx
pop af
inc a
pop bc
dec b
jp nz,vr8q
di
exx
pop  hl
pop  de
pop  bc
exx
call restore_int
call crtc_reset
ei
ld ix,results_buffer
ld bc,40*7
call simple_results

ret


;; type 0,0,0
vsync_r4_r9:
di
ld ix,results_buffer

ld b,128*32
ld e,0
ld d,0
vr49b:
push bc
push de

push de
call crtc_reset
call vsync_sync
ld a,6
call wait_x_lines
pop de

ld bc,&bc09
out (c),c
inc b
out (c),e
ld bc,&bc04
out (c),c
inc b
out (c),d

call wait_frame

;; did a vsync occur?
call check_vsync_occured
ld a,1
jr nc,vr911
ld a,0
vr911:
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

;; if yes, count the number of lines it takes...
ld a,0
call nc,count_vsync_lines
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop de
inc e
ld a,e
cp 32
jr nz,vr49c
ld e,0
inc d
vr49c:
pop bc
djnz vr49b
call crtc_reset
ei
ld ix,results_buffer
ld bc,4096*2
call simple_results

ret


vsync_overlap_vadj:
di
ld ix,results_buffer

ld bc,&bc07
out (c),c
ld bc,&bd00+38
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00+&0f	;; long vsync; same as a char line
out (c),c

call vsync_sync

call count_vsync_lines

;; store got
ld (ix+0),a
inc ix
ld (ix+0),16 ;; all allow vsync to continue through vertical adjust
inc ix

call crtc_reset
ei
ld ix,results_buffer
ld bc,1
call simple_results

ret

;;--------------------------------------
;; program different vsync lengths into
;; the vsync/hsync register (register 3)
;; 
;; if a vsync occurs then time the length
;; of the vsync.
;;

vsync_len_check:
di
ld ix,results_buffer
ld b,16
ld c,0
vlec1:
push bc
push bc
;; set a default vsync length
ld bc,&bc03
out (c),c
ld bc,&bc8e
out (c),c
;; wait for start and end of vsync
call vsync_sync
call wait_frame
pop bc
;; set new vsync width
ld b,&bc
ld a,3
out (c),a
inc b
ld a,c
add a,a
add a,a
add a,a
add a,a			;; vsync into upper 4 bits
or &e			;; default hsync width
out (c),a

call wait_frame

;; did a vsync occur?
call check_vsync_occured

;; if yes, count the number of lines it takes...
ld a,0
call nc,count_vsync_lines

;; store got
ld (ix+0),a
inc ix
inc ix
pop bc
inc c
djnz vlec1

call crtc_reset
ei
ld hl,vl_results
ld b,16
call poke_results
ret

vl_results:
defw vl_type0
defw vl_type1
defw vl_type2
defw vl_type3
defw vl_type4
defw vl_type5		;; hd6845r

;; confirmed
vl_type2:
vl_type1:
vl_type5:
defb 16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16

;; not confirmed
vl_type3:

;; confirmed
vl_type0:
vl_type4:
defb 16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

vsync_pos_set2:
di
call store_int
ld hl,&c9fb
ld (&0038),hl
ld ix,results_buffer

;; change r9 height and see if vsync stops
ld bc,&bc04
out (c),c
ld bc,&bd00+&10
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00
out (c),c

ld bc,64*8
vr9z:
push bc

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld hl,vr9x1
ld (vr9x_jump+1),hl

ei
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
call wait_vsync_start
halt
di
ld a,5
call wait_x_lines
ld bc,&bc07
out (c),c
inc b
ld de,&0100
vr9x_jump:
jp vr9x1
defs 64*8
vr9x1:
out (c),d
nop
out (c),e
call count_vsync_lines_immediate
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

ld hl,(vr9x_jump)
dec hl
ld (vr9x_jump),hl
pop bc
dec bc
ld a,b
or c
jp nz,vr9z

call restore_int
call crtc_reset
ei
ld ix,results_buffer
ld bc,64*8
call simple_results

ret
ret


vsync_pos_set:
di
ld ix,results_buffer
ld b,9
ld a,1
vps1a:
push bc
push af
ld (vps5+1),a

;; normal height
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

;; 4 char lines = 32 
ld bc,&bc04
out (c),c
ld bc,&bd04-1
out (c),c

;; 16 scanline vsync on some crtcs this is why we are using 32 line height chars

;; set vsync to known value
ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

;; give it a good change to sync nicely
call vsync_sync
call vsync_sync

;; wait for start of vsync
ld b,&f5
vps1: in a,(c)
rra
jr nc,vps1
;; turn off vsync
ld bc,&bd00+&ff
out (c),c
;; 1 line down
defs 64-4-3
;; another 30 to go
ld e,30
vps2: defs 64-1-3
dec e
jp nz,vps2
;; now we can choose which scan line we want to enable vsync on...
;; delay x lines
vps5:
ld e,1
vps3:
dec e
jp z,vps4
defs 64-1-3-3
jp vps3
vps4:
;; set vsync
ld bc,&bd00
out (c),c
;; wait a line at least
defs 64
;; did we start it?
ld b,&f5
in a,(c)
and &1
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
pop af
pop bc
inc a
dec b
jp nz,vps1a

call crtc_reset
ei

ld hl,vps_result_list
ld b,8
call poke_results
ret

vps_result_list:
defw vps_type0
defw vps_type1
defw vps_type2
defw vps_type3
defw vps_type4
defw vps_type5				;; hd6845r

vps_type1:
defb 1,1,1,1,1,1,1,1

;; not conclusive on type 0
vps_type0:
;;defb 1,1,1,1,1,1,1,1
defb 0,1,1,1,1,1,1,1

vps_type2:
defb 0,1,0,0,0,0,0,1

vps_type3:
vps_type4:
defb 0,1,0,0,0,0,0,0

vps_type5:
defb 0,0,0,0,0,0,0,0

;;------------------------
vsync_pos_cut_check:
di
ld ix,results_buffer

ld a,(crtc_type)
cp 1
ld c,&10
jr z,vpcc2
cp 2
ld c,&10
jr z,vpcc2
cp 0
ld c,&8
jr z,vpcc2
cp 4
ld c,&8
jr z,vpcc2
cp 3
ld c,&8
jr z,vpcc2

;; not checked 5
ld c,0

vpcc2:
ld a,c
ld (vpcc_exp-1),a

ld bc,&bc03
out (c),c
ld bc,&bd8e
out (c),c

;; set vsync to known value
ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

;; give it a good change to sync nicely
call vsync_sync
call vsync_sync
call vsync_sync

ld b,&f5
vcc1: in a,(c)
rra
jr nc,vcc1

;; we are now within vsync

;; set new vsync position...
ld bc,&bd00+8
out (c),c
;; count for how long vsync continues...
call count_vsync_lines_immediate

;; store got
ld (ix+0),a
inc ix
ld (ix+0),0
vpcc_exp:
inc ix

call crtc_reset
ei
ld ix,results_buffer
ld bc,1
call simple_results
ret

;;------------------------
vsync_len_cut_check:
di
ld ix,results_buffer
ld h,16
ld l,0
vlcc1:
;; set initial vsync
ld bc,&bc03
out (c),c
ld bc,&bd8e
out (c),c

;; set vsync to known value
ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

;; give it a good chance to sync nicely
call vsync_sync
call vsync_sync
call vsync_sync

ld b,&f5
vlcc2: in a,(c)
rra
jr nc,vlcc2

;; we are now within vsync

;; set new vsync width...
ld b,&bd
out (c),l

;; count for how long vsync continues...
call count_vsync_lines_immediate

;; store got
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
inc l
dec h
jr nz,vlcc1
 
call crtc_reset
ei
ld hl,vlcc_results
ld b,16
call poke_results
ret

vlcc_results:
defw vlcc_type0
defw vlcc_type1
defw vlcc_type2
defw vlcc_type3
defw vlcc_type4
defw vlcc_type5		;; hd6845r


vlcc_type3:
vlcc_type4:
vlcc_type0:
defb 8,&18,8,8,8,8,8,8,8,8,8,8,8,8,8,8

;; confirmed
vlcc_type2:
vlcc_type1:
defb &10, &10,&20, &10,&10, &10,&10, &10,&10, &10,&10, &10,&10, &10,&10, &10

;; not confirmed
vlcc_type5:
defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;;------------------------
;; waits for a vsync to occur
;; carry set = no vsync, carry clear = vsync seen

check_vsync_occured:
push af
push de
push bc
push hl

ld b,&f5
ld de,vsync_timeout
cvo:
in a,(c)
rra
jp c,cvo2
dec de
ld a,d
or e
jp nz,cvo
pop hl
pop bc
pop de
pop af
scf
ret

cvo2:
pop hl
pop bc
pop de
pop af
or a
ret



;;------------------------------------------
;; this test will find if vertical line counter is
;; incremented during vertical adjust, and as a result
;; if a vertical sync can be triggered when the vsyncpos>vertical total
;;

vsync_trigger:
di
ld ix,results_buffer

ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c

ld a,36
ld b,5
vst1:
push bc
push af
push af
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
call vsync_sync
pop af


ld bc,&bc07
out (c),c
inc b
out (c),a

call wait_frame

;; did a vsync occur?
call check_vsync_occured
ld a,1
jr nc,vst2
xor a
vst2:
ld (ix+0),a
inc ix
inc ix

pop af
pop bc
inc a
djnz vst1

call crtc_reset
ei

ld hl,vst_results
ld b,5
call poke_results
ret



vst_results:
defw vst_type0
defw vst_type1
defw vst_type2
defw vst_type3
defw vst_type4
defw vst_type5		;; hd6845r


vst_type1:
defb 1	;; 36
defb 1	;; 37
defb 1	;; 38
defb 0	;; 39
defb 0	;; 40

vst_type0:
vst_type3:
vst_type4:
vst_type2:
vst_type5:
defb 1
defb 1
defb 0
defb 0
defb 0
;;------------------------------------------
;; this test will find if vertical line counter is
;; incremented during vertical adjust, and as a result
;; if a vertical sync can be triggered when the vsyncpos>vertical total
;;

vsync_line_check:
di
ld ix,results_buffer
;; initial vsync pos
ld a,38-2
vlc1:
push af

push af
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
call vsync_sync
pop af

;; set vsync pos
ld bc,&bc07
out (c),c
inc b
out (c),a

;; try max r5 value
ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c
call wait_frame

;; did a vsync occur?
call check_vsync_occured
jr c,vlc6

;; yes
ld b,&f5
vlc1a:
in a,(c)
rra
jr c,vlc1a

;; yes one did... so we check the actual reg 5 value...

;; work out vadj that would allow the vsync to occur with
;; this vsync pos
ld b,32
xor a
vlc2:
push bc
push af

ld bc,&bc05
out (c),c
inc b
out (c),a
ld (ix+0),a
call wait_frame
;; check if vsync occured
call check_vsync_occured
jr nc,vlc3

;; no, try next value
pop af
inc a
pop bc
djnz vlc2

vlc6:
;; no vadj value will let vsync work with
;; programmed vsync position
ld (ix+0),&ff
jr vlc4

;; we found a vadj that will let vsync occur
vlc3:
pop af
pop bc
vlc4:
inc ix
inc ix
pop af
inc a
cp 50
jp nz,vlc1
call crtc_reset
ei

ld hl,vlt_results
ld b,50-36
call poke_results
ret

vlt_results:
defw vlt_type0
defw vlt_type1
defw vlt_type2
defw vlt_type3
defw vlt_type4
defw vlt_type5		;; hd6845r


;; confirmed
vlt_type1:
vlt_type5:
vlt_type2:
defb 0
defb 0
defb 0
defb 1
defb 9
defb &11
defb &19
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff

;; confirmed
vlt_type3:
vlt_type4:
defb 0
defb 0
defb 0
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff

;; confirmed
vlt_type0:
defb 0
defb 0
defb 0
defb 1
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff
defb &ff

;;-------------------------------------------

crtc_reset:
di
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
call vsync_sync
call vsync_sync
ei
ret

crtc_default_values:
defb 63,40,46,&8e,38,0,25,30,0,7,0,0,&30,0,0,0,0

;; type 0: 64 got 00 ok
hsync_pos_check:
;; setup a new int
di
ld a,&c3
ld hl,int_count
ld (&0038),a
ld (&0039),hl
ei

;; set line length
ld bc,&bc00
out (c),c
ld bc,&bd00+63
out (c),c


ld a,(crtc_type)
cp 2
jr nz,hsp111

ld ix,results_buffer
ld b,65
xor a
hsp11:
push af
cp 64
ld e,0			;; last is ok (there are a few in the middle that don't work correctly)
jr z,hsp112
;; no vsync occurs
cp 64-12		;; half hsync not full hsync???
ld e,1
jr nc,hsp112
ld e,0
hsp112:
ld (ix+1),e
inc ix
inc ix
cp 64
ld e,1
jr nz,hsp11bb
ld e,0
hsp11bb:
ld (ix+1),e
inc ix
inc ix
pop af
inc a
djnz hsp11
jp hsp1111


hsp111:
ld ix,results_buffer
ld b,65
xor a
hsp1122:
push af
ld (ix+1),0
inc ix
inc ix
cp 64
ld a,1
jr nz,hsp11b
xor a
hsp11b:
ld (ix+1),a
inc ix
inc ix
pop af
inc a
djnz hsp1122

hsp1111:
ld ix,results_buffer
ld b,65
xor a
hsp1: push af
push bc

;; set hsync pos
ld bc,&bc02
out (c),c
ld b,&bd
out (c),a

ld bc,&bc03
out (c),c
inc b
or &08		;; set hsync width to 8
out (c),a

call wait_frame

;; vsync occured?
call check_vsync_occured
ld a,0
adc a,0
ld (ix+0),a
inc ix
inc ix

;; reset counter
xor a
ld (counter),a

call wait_frame

;; if counter!=0 this means a int occured. This also
;; means that a hsync was generated.
ld a,(counter)
or a
ld a,1
jr nz,hsp7
xor a
hsp7:
ld (ix+0),a
inc ix
inc ix

pop bc
pop af
inc a
djnz hsp1

di
call restore_int
call crtc_reset
ei

ld ix,results_buffer
ld bc,65*2
call simple_results
ret

wait_frame:
ld bc,vsync_timeout
wf1:
dec bc
ld a,b
or c
jr nz,wf1
ret


;;--------------------------------------------------
;; this is used to find programmed hsync values that
;; will cause a hsync and therefore cause a interrupt to be generated

crtc_check_hsync_generated:
;; setup a new int
di
ld a,&c3
ld hl,int_count
ld (&0038),a
ld (&0039),hl
ei

ld ix,results_buffer
ld b,16
xor a
hst1: push af
push bc

;; specify horizontal sync width (vsync is fixed)
ld bc,&bc03
out (c),c
inc b
or &80
out (c),a

;; reset counter
xor a
ld (counter),a

call vsync_sync
call vsync_sync
call vsync_sync

;; if counter!=0 this means a int occured. This also
;; means that a hsync was generated.
ld a,(counter)
or a
ld a,1
jr nz,vs7
xor a
vs7:
ld (ix+0),a
inc ix
inc ix

pop bc
pop af
inc a
djnz hst1

di
call restore_int
call crtc_reset
ei

ld hl,hgi_result_list
ld b,16
call poke_results
ret

hgi_result_list:
defw hgi_type0
defw hgi_type1
defw hgi_type2
defw hgi_type3
defw hgi_type4
defw hgi_type5				;; hd6845r

;; tests for programmed hsync values that do not generate a interrupt
;; 0 -> 0 all others = 1
;; 1 for all on type 4

;; not confirmed

;; confirmed
hgi_type0:
hgi_type1:
defb 0
defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

;; confirmed
hgi_type3:
hgi_type2:
hgi_type4:
hgi_type5:
defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1


poke_results:
;; setup expected
ld ix,results_buffer
push ix
push bc
ld a,(crtc_type)
add a,a
ld e,a
ld d,0
add hl,de
ld e,(hl)
inc hl
ld d,(hl)

pr1:
inc ix
ld a,(de)
ld (ix+0),a
inc de
inc ix
djnz pr1
pop bc
ld c,b
ld b,0
pop ix
call simple_results
ret



poke_word_results:
;; setup expected
ld ix,results_buffer
push ix
push bc
ld a,(crtc_type)
add a,a
ld e,a
ld d,0
add hl,de
ld e,(hl)
inc hl
ld d,(hl)

pr1w:
ld a,(de)
ld (ix+1),a
inc de
ld a,(de)
ld (ix+3),a
inc de
inc ix
inc ix
inc ix
inc ix
djnz pr1w
pop bc
ld a,b
add a,a
ld b,a
ld c,b
ld b,0
pop ix
call simple_results
ret

int_count:
push af
ld a,(counter)
inc a
ld (counter),a
pop af
ei
ret

counter:
defb 0

;;-------------------------------

old_int:
defs 3

store_int:
di
ld hl,&0038
ld de,old_int
ld bc,3
ldir
ei
ret

restore_int:
di
ld hl,old_int
ld de,&0038
ld bc,3
ldir
ei
ret

;;----------------------------




;;*******************************************


;;-------------------------------------------

vsync_exact_pos:
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

call vsync_sync
call vsync_sync

ld b,&f5
vep1: in a,(c)
rra
jr nc,vep1

;; wait until end of vsync signal
ld a,18
call wait_x_lines

ld bc,&bc07
out (c),c
ld bc,&bd04
out (c),c
call count_lines_to_vsync
ld (vep2),a
ret

vep2:
defw 0

;;-------------------------------------------

vsync_pos_change_possible:
;; vsync at frame start
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

;; wait for first vsync
call vsync_sync

ld b,&f5
vpcp1: in a,(c)
rra
jr nc,vpcp1

;; wait for vsync to end (at least 16 lines for non-programmable
;; vsync lengths)
ld a,18
call wait_x_lines

;; set new vsync
ld bc,&bc07
out (c),c
ld bc,&bd00+6
out (c),c

;; wait until we are a few lines into the vsync signal (assuming
;; it has begun)
ld a,48-18+2
call wait_x_lines

;; check if vsync started...
ld b,&f5
in a,(c)
rra
ld a,1
jr c,vpcp2
ld a,0
vpcp2:
ld (vsync_change_possible),a
ret

vsync_change_possible:
defb 0

;;-------------------------------------------

;; if the vsync counter is active, but a new vsync width
;; is programmed, will it take effect? (only applies
;; to crtc's where the vsync is programmable?)
vsync_len_cut:
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

;; vsync is 8 lines long
ld bc,&bc03
out (c),c
ld bc,&bd00+&8e
out (c),c

;; sync so that if we wait for a vsync it will be the start
call vsync_sync
;; wait for start of vsync
ld b,&f5
vlcu1:
in a,(c)
rra
jr nc,vlcu1

ld a,6
call wait_x_lines

;; attempt to cut it by writing a value which is less
;; than current counter value...
ld bc,&bc03
out (c),c
ld bc,&bd00+&4e
out (c),c

;; count lines to vsync end
ld b,&f5
ld e,0
;; check each line
vlcu2:
in a,(c)
rra
jp nc,vlcu3
inc e
ld a,12
vlcu3:
dec a
jp nz,vlcu4
nop
nop
jp vlcu2

;; vsync has ended
vlcu4:
ld a,e
ld (vsync_cut_len),a
ret

vsync_cut_len:
defb 0


crtc_detect_reg_change:
push hl
push de

;; timeout
ld de,19968

;; get current value
in a,(c)
ld l,a

dc1:
;; read current val
in a,(c)
;; different?
xor l
jp nz,dc2

;; no
dec de
ld a,d
or e
jp nz,dc1

;; didn't change
pop de
pop hl
scf
ret


;; changed
dc2:
pop de
pop hl
or a
ret

;;------------------------------------------

crtc_reg_changeszz:
ld hl,reg_changed

;; select reg 12
ld bc,&bc0c
out (c),c

ld b,&bc
call crtc_detect_reg_change
ld a,1
jr nc,crc1
ld a,0
crc1:
ld (hl),a
inc hl

ld b,&bd
call crtc_detect_reg_change
ld a,1
jr nc,crc2
ld a,0
crc2:
ld (hl),a
inc hl

ld b,&be
call crtc_detect_reg_change
ld a,1
jr nc,crc3
ld a,0
crc3:
ld (hl),a
inc hl

ld b,&bf
call crtc_detect_reg_change
ld a,1
jr nc,crc4
ld a,0
crc4:
ld (hl),a
ret

;; 1 = reg changed, 0 = didn't change.
reg_changed:
defs 4

;;------------------------------------------------------------------------

crtc_check_be_equals_bf:
push hl
push de
push bc

ld c,&00
ld e,0
ccbef1:
;; specify reg
ld b,&bc
out (c),c

;; read &be
ld b,&be
in l,(c)
;; read &bf
ld b,&bf
in h,(c)

;; different?
ld a,h
xor l
jr nz,ccbef2

inc c
dec e
jr nz,ccbef1
pop bc
pop de
pop hl
;; not different!
ld a,1
ld (be_equal_bf),a
ret

;; different!
ccbef2:
pop bc
pop de
pop hl
xor a
ld (be_equal_bf),a
ret


be_equal_bf:
defb 0

;;--------------------------------------------------------

crtc_check_reg_readable:
ld b,&bc
out (c),c

ld c,&3f
ccrr1:
;; program new value
ld b,&bd
out (c),c
;; read back programmed value
ld b,&bf
in a,(c)
xor c
jr nz,ccrr2

dec c
jp nz,ccrr1
;; reg is readable
ld a,1
ret

;; reg not readable
ccrr2:
ld a,0
ret

crtc_check_regs_readable:
ld b,32
ld hl,crtc_reg_readable_table
ld c,0
ccrrr1: push bc
push hl
call crtc_check_reg_readable
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz ccrrr1
ret

crtc_reg_readable_table:
defs 32


;;---------------------------------------------------------

crtc_check_reg2_readable:
;; get and value
ld hl,crtc_and_table
ld a,l
add a,c
ld l,a
ld a,h
adc a,0
ld h,a

ld a,(hl)
or a
jp z,c2crr2

;; specify reg 
ld b,&bc
out (c),c

;; write 0...255
ld c,&ff
c2crr1: push bc

;; program new value
ld b,&bd
out (c),c

;; work out this value and'd
ld a,c
and (hl)
ld e,a

;; read back programmed value
ld b,&bf
in a,(c)
;; and it with reg and mask
and (hl)
;; compare to our value we wrote and'd
cp e
jr nz,c2crr3
;; same

pop bc
dec c
jp nz,c2crr1
;; reg is readable
ld a,1
ret

c2crr3:
pop bc
;; reg not readable
c2crr2:
ld a,0
ret



crtc_check_regs2_readable:
ld b,32
ld hl,crtc_reg_rable2_table
ld c,0
cc2rrr1: push bc
push hl
call crtc_check_reg2_readable
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz cc2rrr1
ret

crtc_reg_rable2_table:
defs 32

;;--------------------------------------------------------

crtc_check_reg_and_masks:
ld b,32
ld hl,crtc_and_table
ld c,0
ccram1: push bc
push hl
call crtc_reg_and_mask
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz ccram1
ret

crtc_reg_and_mask:
ld b,&bc
out (c),c

;; write &ff
ld c,&ff
ld b,&bd
out (c),c
ld b,&bf
in a,(c)
ld d,a          ;; get data and or mask

;; write 0
ld c,0
ld b,&bd
out (c),c
ld b,&bf
in a,(c)
ld e,a          ;; get or mask only 

ld a,e
cpl
and d
ret


crtc_check_reg_or_masks:
ld b,32
ld hl,crtc_or_table
ld c,0
ccrom1: push bc
push hl
call crtc_reg_or_mask
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz ccrom1
ret

crtc_reg_or_mask:
ld b,&bc
out (c),c

;; write 0
ld c,0
ld b,&bd
out (c),c
ld b,&bf
in a,(c)
ld e,a          ;; get or mask only 
ret

crtc_and_table:
defs 32

crtc_or_table:
defs 32

;;--------------------------------------------------------

crtc_bf_all_same:
ld d,&bf
call crtc_all_same
ret

;;--------------------------------------------------------

crtc_be_all_same:
ld d,&be
call crtc_all_same
ret

;;--------------------------------------------------------

crtc_all_same:
di
ld c,&00 ;; register number
call crtc_reg_changes
ret

;;--------------------------------------------------------------------

;; in:
;; C = register number
;; D = read port
;; out:
;; L = value read
crtc_reg_changes:
;; specify reg
ld b,&bc
out (c),c
;; read port
ld b,d

;; initial read
in l,(c)

;; number of times to read register
ld e,0
cas1:
in a,(c)
xor l
jr nz,cas3

inc e
jr nz,cas1

;; didn't change all the times we read it
or a
ret

;; changed
cas3:
scf
ret

;;--------------------------------------------------------

crtc_results:
;; READ FROM &BC
ld hl,crtc_read_results
ld c,&00
ld e,0
rd1:
;; specify reg
ld b,&bc
out (c),c
;; read back 
ld b,&bc
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd1

;; READ FROM &BD
ld c,&00
ld e,0
rd2:
;; specify reg
ld b,&bc
out (c),c
;; read back 
ld b,&bd
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd2


;; READ FROM &BE
ld c,&00
ld e,0
rd3:
;; specify reg
ld b,&bc
out (c),c
;; read back from &be
ld b,&be
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd3

;; READ FROM &BF

ld c,&00
ld e,0
rd4:
;; specify reg
ld b,&bc
out (c),c
;; read back
ld b,&bf
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd4
ret

crtc_read_results: equ $
mr_vals: equ $+1024




;;--------------------------------

detect_isv:
di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc08
out (c),c
ld bc,&bd03
out (c),c

;; if CRTC type 1, then we will see a VSYNC after (((38+1)*8)/2)=156 scanlines
;; ints occur on lines 2,54,106,158,210,262.

;; sync with start of vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync
ld b,&f5

di1: in a,(c)
rra
jr nc,di1
di3:
in a,(c)
rra
jr c,di3

halt
;; 54
halt
;; 106
halt
;; 158

;; if CRTC type is 1, we will be 2 scans into the VSYNC signal.
in a,(c)
rra
ld a,1
jr c,di2

;; interlace sync and video mode not like CRTC type 1.
ld a,&ff

di2:
ld (isv_like_crtc),a
ret

;; reports the CRTC type that has the same operation as the Interlace
;; Sync and Video mode reported.
isv_like_crtc:
defb 0


;;--------------------------------

vtot_comp_check:
ld a,18
ld (vtcc2+1),a

ld de,vtot_lines_table
ld b,200
vtcc1: push bc
push de
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c

call vsync_sync
call vsync_sync

ld b,&f5
vtcc: in a,(c)
rra
jr nc,vtcc
vtcc2:
ld a,18
call wait_x_lines
;; set new vtot.....
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
;; count lines until vsync starts...
call count_lines_to_vsync
pop de
;; store line count
ld (de),a
inc de

ld a,(vtcc2+1)
inc a
ld (vtcc2+1),a
pop bc
djnz vtcc1
ret

vtot_lines_table:
defs 200*2

vadj_comp_check:
;; init wait lines routine.
ld a,40  ;;-1               
ld (vacc4+1),a

ld hl,vadj_comp_table
ld b,32
vacc1:
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
;; frame is only 4 lines tall
ld bc,&bc04
out (c),c
ld bc,&bd00+5-1
out (c),c
;; vadj to max
ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
vacc7: in a,(c)
rra
jr nc,vacc7
;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
vacc4:
ld a,32
call wait_x_lines

;; set new vadj.....
ld bc,&bc05
out (c),c
ld bc,&bd00
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vacc4+1)
inc a
ld (vacc4+1),a

pop bc
dec b
jp nz,vacc1
ret

vadj_comp_table:
defs 32


;;--------------------------------

mr_comp_check:
;; init wait lines routine.
ld a,32  ;;-1               
ld (mcc4+1),a

ld hl,mr_comp_table
ld b,8
mcc1:
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
;; 8 lines per char line
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

;; sync with vsync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
mcc7: in a,(c)
rra
jr nc,mcc7

;; set new vsync pos position to char line after the one we are changing!
ld bc,&bc07
out (c),c
ld bc,&bd05
out (c),c

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
mcc4:
ld a,32
call wait_x_lines

;; set new mr.....
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(mcc4+1)
inc a
ld (mcc4+1),a

pop bc
dec b
jp nz,mcc1
ret

mr_comp_table:
defs 8


;;---------------------------------

mr_comp2_check:
;; init wait lines routine.
ld a,32  ;;-1               
ld (m2cc4+1),a

ld hl,mr_comp2_table
ld b,8
m2cc1:
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+5-1
out (c),c

;; 8 lines per char line
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
m2cc7: in a,(c)
rra
jr nc,m2cc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
m2cc4:
ld a,32
call wait_x_lines

;; set new mr.....
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(m2cc4+1)
inc a
ld (m2cc4+1),a

pop bc
dec b
jp nz,m2cc1
ret

mr_comp2_table:
defs 8



mr_comp3_check:
ld hl,0
ld (write_delay),hl

ld hl,mr_vals
ld bc,512
m3cc1:
push bc
push hl


call setup_write

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+5-1
out (c),c

;; 8 lines per char line
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
m3cc7: in a,(c)
rra
jr nc,m3cc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
ld a,32
call wait_x_lines

;; set new mr.....
ld bc,&bc09
out (c),c
ld bc,&bd00
call do_write

pop hl
ld (hl),a
inc hl

call update_write_delay

pop bc
dec bc
ld a,b
or c
jp nz,m3cc1
ret


;;--------------------------------

count_lines_to_vsync:
;; vsync i/o
ld b,&f5
;; line counter
ld e,0

;; check vsync...
cltv1: in a,(c)
rra
jp c,cltv2
;; vsync not occured yet

;; pause a bit
nop
nop
ld a,12
cltv3: dec a
jp nz,cltv3

;; increment counter
inc e
jp nz,cltv1

;; counter wrapped..! vsync did not occur within 256 lines.

ld a,&ff
ret

;; start of vsync found
cltv2:
ld a,e
ret

;;------------------------

;; wait at least 2 lines
wait_x_lines:
dec a		;; [1]
wxl1:
defs 64-1-3
dec a		;; [1]
jp nz,wxl1	;; [3]
defs 64-1-3-5-2	;; for dec, ret, call, and ld a,n`
ret			;; [3]

;;------------------------

;; syncs with a vsync on char line 0, then waits for x lines before
;; setting a new vsync pos. When the vsync pos is programmed
;; raster counter is not 0. We see if a VSYNC occurs within 8 lines.
;; if it does occur, we can assume that programming a VSYNC pos
;; within a line counter to the value of that line counter will
;; trigger a vsync to occur!

vsync_pos_check:
ld a,32-1               
ld (vpc4+1),a

ld ix,results_buffer
ld b,8
vpc1:
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
vpc7: in a,(c)
rra
jr nc,vpc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
vpc4:
ld a,32
call wait_x_lines
;; still within a line....

;; set new vsync.....
ld bc,&bc07
out (c),c
ld bc,&bd04
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (ix+0),a
inc ix
inc ix

;; wait one more line next time around...
ld a,(vpc4+1)
inc a
ld (vpc4+1),a

pop bc
djnz vpc1

ret

vtot_check:
ld a,32-1               
ld (vtc4+1),a

ld hl,vtot_table
ld b,16
vtc1:
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+39
out (c),c
;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
vtc7: in a,(c)
rra
jr nc,vtc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
vtc4:
ld a,32
call wait_x_lines
;; still within a line....

;; set new vsync.....
ld bc,&bc04
out (c),c
ld bc,&bd04
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vtc4+1)
inc a
ld (vtc4+1),a

pop bc
djnz vtc1
ret

vtot_table:
defs 16


vtot2_check:
ld a,32-1               
ld (vt2c4+1),a

ld hl,vtot2_table
ld b,16
vt2c1:
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+4
out (c),c
;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
vt2c7: in a,(c)
rra
jr nc,vt2c7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
vt2c4:
ld a,32
call wait_x_lines
;; still within a line....

;; set new vsync.....
ld bc,&bc04
out (c),c
ld bc,&bd00+5
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vt2c4+1)
inc a
ld (vt2c4+1),a

pop bc
djnz vt2c1
ret

vtot2_table:
defs 16


update_write_delay:
push hl
ld hl,(write_delay)
inc hl
ld (write_delay),hl
pop hl
ret

;; HL = delay from 0 to delay_pause.
setup_write:
ld de,(write_delay)
ld hl,end_write_nop_pause
or a
sbc hl,de
ld (do_write+1),hl
ret

write_delay: defw 0
;;-------------------------------------------------
;; the following routine is used to time the number
;; of lines following a write until the vsync occurs.
;; 
;; setup do_write to point into write_nop_pause area
;; which contains the OUT (C),C to execute, and pause before
;; and pause after.

do_write:
jp 0

start_write_nop_pause:
defs delay_pause
                          ;; space for pause before and after, 
                          ;; + some opcodes to perform.
end_write_nop_pause:

out (c),c                 ;; do write

defs 64-2-2

ld b,&f5
ld e,0

vsync_catch:

in a,(c)                  ;; get vsync state
rra                       
jp c,vsync_caught

;; no vsync
inc e
defs 64-4-1-3-1-3         ;; (delay so each vsync check is in same
                          ;; place but next line)
jp vsync_catch

;; got vsync.
vsync_caught:
ld a,e
ret

crtc_type: defb 0


wait_vsync_start:
ld b,&f5
wvs1:
in a,(c)
rra
jr nc,wvs1
ret

hsync_len_check:
call store_int

ld ix,results_buffer
ld b,16
xor a
hw1:
push bc
push af

;; set hsync width

ld bc,&bc03
out (c),c
inc b
out (c),a

di
ld a,&c3
ld hl,int_count
ld (&0038),a
ld (&0039),hl
ei

;; reset counter
xor a
ld (counter),a

call vsync_sync
call vsync_sync
call vsync_sync

;; if counter!=0 this means a int occured. This also
;; means that a hsync was generated.
ld a,(counter)
or a
jr nz,hw3

xor a
ld (ix+0),a
inc ix
inc ix
jr hw2

hw3:
;; got int
di
ld a,&c3
ld hl,vint
ld (&0038),a
ld (&0039),hl
ei

xor a
ld (hsync_len_found),a
ld hl,wne2b
ld (wne_jump+1),hl

hw4:
ld a,(hsync_len_found)
or a
jr nz,hw4

ld a,(hsync_len_found)
ld (ix+0),a
inc ix
inc ix

hw2:
pop af
inc a
pop bc
djnz hw1

di
call restore_int
call crtc_reset
ei
ld hl,hl_results
ld b,16
call poke_results
ret

hl_results:
defw hl_type0
defw hl_type1
defw hl_type2
defw hl_type3
defw hl_type4
defw hl_type5		;; hd6845r

;; confirmed
hl_type2:
hl_type3:
hl_type4:
hl_type5:
defb 16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

hl_type0:
hl_type1:
defb 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15


vint:
push af
push bc
ld b,&f5
in a,(c)
rra
jp nc,vint2
;; vsync seen

;; how many nops to get to end of vsync?

call wait_near_end

ld b,&f5
in a,(c)
rra
jr nc,vint3

;; not found
ld hl,(wne_jump+1)
dec hl
ld (wne_jump+1),hl
jr vint2

vint3:
ld hl,wne2b
ld bc,(wne_jump)
or a
sbc hl,bc
ld a,l
ld (hsync_len_found),a

vint2:
pop bc
pop af
ei
reti

hsync_len_found:
defb 0

;; 2 lines into vsync
wait_near_end:
;; wait 15 lines
ld b,240
wne:
dec b
jp nz,wne
wne_jump:
jp wne2
wne2:
defs 32
wne2b:
ret

crtc2_get_hs_length:
ld a,(crtc_type)
cp 2
jp nz,report_skipped

di
ld ix,results_buffer

ld b,16
xor a
t2hs:
push bc
push af

;; set hsync width
ld bc,&bc03
out (c),c
inc b
out (c),a

;; which r2 will cause no vsync

ld b,64
ld a,0
t2hs2:
push bc
push af
ld bc,&bc02
out (c),c
inc b
out (c),a

ld (ix+0),a ;; value tried

call wait_frame

call check_vsync_occured
jr c,t2hs4



pop af
inc a
pop bc
djnz t2hs2
;; no correct value
ld (ix+0),-1

t2hs3:
inc ix
inc ix

pop af
inc a
pop bc
djnz t2hs

ld b,16
ld ix,results_buffer
ld hl,crtc2_hs_expected
t2hs2b:
ld a,(hl)
inc hl
ld (ix+1),a
inc ix
inc ix
djnz t2hs2b

call crtc_reset

ei
ld ix,results_buffer
ld bc,16
call simple_results
ret

crtc2_hs_expected:
defb 64-16-1
defb 64-1-1
defb 64-2-1
defb 64-3-1
defb 64-4-1
defb 64-5-1
defb 64-6-1
defb 64-7-1
defb 64-8-1
defb 64-9-1
defb 64-10-1
defb 64-11-1
defb 64-12-1
defb 64-13-1
defb 64-14-1
defb 64-15-1


t2hs4:
;; previous one did it, but not this one
dec (ix+0)
pop af
pop bc
jr t2hs3



include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"
;;include "../lib/hw/scr.asm"

results_buffer: equ $

end start
