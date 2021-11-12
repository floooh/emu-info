;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; This test is an interactive test.
include "../../lib/testdef.asm"

if CPC=1
org &1000
endif
if SPEC=1
org &8000
endif

start:
if CPC=1
ld a,2
call &bc0e
endif

ld hl,copy_result_fn
ld (cr_functions),hl

call reset_specify

ld hl,menu_msg
call output_msg

call exe_menu
jp start

;; 3": write protected and two side when out
;; write protected and two side when write protected
;; when disc in doesn't indicate two side.
;; 3" step rate? seems a bit broken on 6128plus
;;
;; ready timing for 3" on 6128plus:
;; 3f5, 74e, 4a7
;; 3" on type 1 6128:
;; on: 6c7, a04,93f
;; off: 0,0,0
;; 3.5": can't cope with smallest step rate

;; 6128 and 6128Plus?:
;; drive 0 and 2 report same.
;; side switch doesn't change reporting
;; drive switch doesn't change drive reported from sense drive status, but does change 0->1,2->3 and vice versa
;; drive 0 (3"), no power: write protected, track 0, two side
;; drive 1 (3.5) not connected: reports nothing
;; 
;; 3.5" (wp=two side)
;; disc in, motor on ready (even with ready forced)
;; don't see track 0 with drive 1
;;
;; fdc though pcn, but drive didn't report track 0!


;; TEST MOTOR ON head load/unload vary

;; teac shows forced ready but it doesn't have that
menu_msg:
defb "This test is interactive and is a work in progress.",13
defb "Drive tests",13
defb "1. Drive report (ready, write protect etc)",13
defb "2. Ready/Not-Ready time",13
defb "3. Drive step rate test",13
;;defb "4. Calculate num tracks (warning hits head against the end)",13
defb 0



;;==================================================================

exe_menu:
call wait_key
cp "1"
jp z,drive_status
cp "2"
jp z,ready_time
cp "3"
jp z,seek_test
;;cp "4"
;;jp z,calc_tracks
ret

sense_interrupt_msg:
defb "SIS:",0

sense_drive_msg:
defb "SDS:",0

drive_msg:
defb " Drive ",0

side_msg:
defb " Side ",0

normal_termination_txt:
defb "NT (00) - ",0

abnormal_termination_txt:
defb "AT (01) - ",0

invalid_command_txt:
defb "IC (10) - ",0

ready_change_txt:
defb "Ready changed - ",0

ready_txt:
defb "Ready,",0

equipment_check_txt:
defb "Equipment check,",0

seek_end_txt:
defb "Seek end,",0

not_ready_txt:
defb "Not ready,",0

fault_txt:
defb "Fault,",0

write_protected_txt:
defb "Write protected,",0

track0_txt:
defb "Track 0,",0

two_side_txt:
defb "Two side,",0

pcn_msg:
defb " PCN ",0

min:
defw 0
max:
defw 0
avg:
defs 4

first:
defb 0

READY_COUNT equ 32

minmaxavg:
ld hl,0
ld (max),hl
ld hl,0
ld (min),hl
ld hl,0
ld (avg),hl
ld (avg+2),hl
ld a,1
ld (first),a

ld b,READY_COUNT
mma:
ld a,(first)
or a
jr z,mma44
ld l,(ix+0)
ld h,(ix+1)
ld (min),hl
ld (max),hl
xor a
ld (first),a
jr mma3
mma44:
ld l,(ix+0)
ld h,(ix+1)
ld de,(min)
or a
sbc hl,de	
bit 7,h
jr z,mma2
ld l,(ix+0)
ld h,(ix+1)
ld (min),hl
mma2:
ld l,(ix+0)
ld h,(ix+1)

ld de,(max)
or a
sbc hl,de	
bit 7,h
jr nz,mma3
ld l,(ix+0)
ld h,(ix+1)
ld (max),hl

mma3:
ld a,(avg+0)
add a,(ix+0)
ld (avg+0),a
ld a,(avg+1)
adc a,(ix+1)
ld (avg+1),a
ld a,(avg+2)
adc a,0
ld (avg+2),a
ld a,(avg+3)
adc a,0
ld (avg+3),a
inc ix
inc ix
dec b
jp nz,mma
ret

ready_on_txt:
defb "Ready on: " ,0
ready_off_txt:
defb "Ready off: ",0

min_txt:
defb " Min ",0
max_txt:
defb " Max ",0
avg_txt:
defb " Avg ",0

show_minmaxavg:
ld hl,min_txt
call output_msg
ld hl,(min)
call outputhex16
ld hl,max_txt
call output_msg
ld hl,(max)
call outputhex16
ld hl,avg_txt
call output_msg
ld a,(avg+3)
ld d,a
ld a,(avg+2)
ld e,a
ld a,(avg+1)
ld h,a
ld a,(avg+0)
ld l,a

srl d
rr e
rr h
rr l

srl d
rr e
rr h
rr l

srl d
rr e
rr h
rr l

srl d
rr e
rr h
rr l

srl d
rr e
rr h
rr l

;;srl h
;;rr l
;;rr d
;;rr e

call outputhex16
call output_nl
ret

ready_values:
defs 256*2
notready_values:
defs 256*2

timeready_txt:
defb "Timing ready...",0

timeready_done_txt:
defb "Timing DONE.",13,13,0

timenotready_txt:
defb "Timing not ready...",0

ready_bad_txt:
defb "Unable to run test. Press a key",13,0

press_key_txt:
defb "Press a key",13,0

ready_time:
call choose_drive

call cls
call check_ready_display
ld a,(ready_status)
or a
jr z,rtime2
ld hl,ready_bad_txt
call output_msg
jp wait_key

rtime2:

ld a,0
ld (should_wait_key),a

ld ix,ready_values
ld iy,notready_values
ld b,READY_COUNT

time_loop:
push bc
ld a,READY_COUNT
sub b
inc a
call outputdec
ld a,"/"
call output_char
ld a,READY_COUNT
call outputdec
call output_nl

ld hl,timeready_txt
call output_msg
call output_nl

call do_motor_off

di
call disc_motor_on
ld hl,0
time_ready_on:
push hl
call sense_drive_status
pop hl
ld a,(fdc_result_data)
bit 5,a
;;call sense_drive_status_fast
;;bit 5,a
jr nz,time_ready_done
inc hl
;;call wait_vsync_start
;;call wait_vsync_end
jr time_ready_on

time_ready_done:
ei
ld (ix+0),l
ld (ix+1),h
inc ix
inc ix

call wait_drive_motor

ld hl,timenotready_txt
call output_msg
call output_nl


di
call disc_motor_off
ld hl,0
time_ready_off:
push hl
call sense_drive_status
pop hl
ld a,(fdc_result_data)
bit 5,a
;;call sense_drive_status_fast
;;bit 5,a
jr z,time_notready_done
inc hl
;;call wait_vsync_start
;;call wait_vsync_end
jr time_ready_off

time_notready_done:
ei
ld (iy+0),l
ld (iy+1),h
inc iy
inc iy

call do_motor_off

pop bc
dec b
jp nz,time_loop

ld a,1
ld (should_wait_key),a

;; find min, find max, find avg
ld hl,timeready_done_txt
call output_msg

ld hl,ready_on_txt
call output_msg
ld ix,ready_values
call minmaxavg
call show_minmaxavg

ld hl,ready_off_txt
call output_msg
ld ix,notready_values
call minmaxavg
call show_minmaxavg

ld hl,press_key_txt
call output_msg
jp wait_key


;;==================================================================
drive_status:
call cls
ld hl,drive_status_msg
call output_msg
call wait_key
call cls

call clear_fdd_interrupts


ld a,1
ld (read_drive_status),a
ld a,0
ld (should_wait_key),a

ld a,0
ld (track),a

drive_status_update:

ld h,1
ld l,6
call set_text_coords

;; see if any drive has signalled an interrupt
sense_interrupts:
call sense_interrupt_status
ld a,(fdc_result_data)
cp &80
jp z,no_interrupt
ld hl,sense_interrupt_msg
call output_msg

;; yes there is an interrupt

;; indicate the drive that interrupted
ld hl,drive_msg
call output_msg
ld a,(fdc_result_data)
and &3
call outputdec

ld hl,side_msg
call output_msg
ld a,(fdc_result_data)
rrca
rrca
and &1
call outputdec

ld hl,pcn_msg
call output_msg
ld a,(fdc_result_data+1)
call outputdec
ld a,' '
call output_char

ld a,':'
call output_char

ld a,(fdc_result_data)
and &c0
or a
ld hl,normal_termination_txt
jr z,dwpt2
cp &40
ld hl,abnormal_termination_txt
jr z,dwpt2
cp &80
ld hl,invalid_command_txt
jr z,dwpt2
ld hl,ready_change_txt
dwpt2:
call output_msg
ld a,(fdc_result_data)
bit 5,a
ld hl,seek_end_txt
call nz,output_msg
ld a,(fdc_result_data)
bit 4,a
ld hl,equipment_check_txt
call nz,output_msg

ld a,(fdc_result_data)
and &c0
cp &c0
jr z,dwpt3
ld a,(fdc_result_data)
bit 3,a
ld hl,not_ready_txt
call nz,output_msg
jr dwpt4

dwpt3:
ld a,(fdc_result_data)
bit 3,a
ld hl,not_ready_txt
jr nz,dwpt
ld hl,ready_txt
dwpt:
call output_msg

dwpt4:

call output_nl
jp sense_interrupts

drive_state:
defs 4

read_drive_status:
defb 0

no_interrupt:
ld hl,drive_state
ld b,4
xor a
sds:
push bc
push af
push hl
ld (drive),a


push hl
call sense_drive_status
pop hl

ld a,(read_drive_status) ;;force for first time
or a
ld a,(fdc_result_data)
jr nz,sds2b
cp (hl)
jp z,sds2
sds2b:
ld (hl),a

ld h,1
ld a,(drive)
add a,4
ld l,a
call set_text_coords
ld b,80
sds33:
ld a,' '
call output_char
djnz sds33

ld h,1
ld a,(drive)
add a,4
ld l,a
call set_text_coords

ld hl,sense_drive_msg
call output_msg

ld a,(drive)
call outputdec ;; physical drive
ld a,' '
call output_char

;; indicate the drive that interrupted
ld hl,drive_msg
call output_msg
ld a,(fdc_result_data)
and &3
call outputdec

ld hl,side_msg
call output_msg
ld a,(fdc_result_data)
rrca
rrca
and &1
call outputdec
ld a,' '
call output_char

ld a,(fdc_result_data)
bit 7,a
ld hl,fault_txt
call nz,output_msg

ld a,(fdc_result_data)
bit 6,a
ld hl,write_protected_txt
call nz,output_msg

ld a,(fdc_result_data)
bit 5,a
ld hl,ready_txt
call nz,output_msg

ld a,(fdc_result_data)
bit 4,a
ld hl,track0_txt
call nz,output_msg

ld a,(fdc_result_data)
bit 3,a
ld hl,two_side_txt
call nz,output_msg
call output_nl

sds2:
pop hl
pop af
inc hl
inc a
pop bc
dec b
jp nz,sds
ld a,0
ld (read_drive_status),a

call drive_status_keys

jp drive_status_update

drive_status_keys:
call get_key
cp 'M'
jp z,ds_motor_on
cp 'm'
jp z,ds_motor_on
cp 'N'
jp z,ds_motor_off
cp 'n'
jp z,ds_motor_off
cp 'Q'
jr z,track_inc
cp 'q'
jr z,track_inc
cp 'a'
jr z,track_dec
cp 'A'
jr z,track_dec
cp 'R'
jp z,ds_recalibrate
cp 'r'
jp z,ds_recalibrate
ret

motor_on_msg:
defb "Disc motor on",13,0

motor_off_msg:
defb "Disc motor off",13,0

recalibrate_msg:
defb "Recalibrate",13,0

ds_motor_on:
ld hl,motor_on_msg
call output_msg
jp disc_motor_on

ds_motor_off:
ld hl,motor_off_msg
call output_msg
jp disc_motor_off

track_inc_msg:
defb "Track +: ",0

track_dec_msg:
defb "Track -: ",0


track_inc:
ld hl,track_inc_msg
call output_msg
ld a,(track)
call outputdec
call output_nl

ld a,(track)
cp 79
ret z
inc a
ld (track),a
jr ds_seek

track_dec:
ld hl,track_dec_msg
call output_msg
ld a,(track)
call outputdec
call output_nl

ld a,(track)
cp 0
ret z
dec a
ld (track),a
jr ds_seek

ds_seek:
ld b,4
xor a

dss:
push bc
push af
ld (drive),a
ld a,(track)
call send_seek
pop af
inc a
pop bc
djnz dss
ret

ds_recalibrate:
ld hl,recalibrate_msg
call output_msg

ld b,4
xor a

dsr:
push bc
push af
ld (drive),a
call send_recalibrate
pop af
inc a
pop bc
djnz dsr
ret

drive_status_msg:
defb "The drive status test sends 'sense interrupt",13
defb "status' and 'sense drive status' and reports",13
defb "the current status.",13,13
defb "Expected:",13,13
defb "Sense interrupt status will report the same",13
defb "state for drive 0 and 2 with CPC6128 or DDI-1",13,13
defb "Sense interrupt status will report the same",13
defb "state for drive 1 and 3 with CPC6128 or DDI-1",13,13
defb "Checking 'write protect':",13
defb "1. Remove disc from drive",13
defb "2. Set the write protect tab to ON or OFF",13
defb "3. Insert disc into a drive",13
defb "4. Repeat 1-3 as you need.",13
defb "Expected:",13,13
defb "a) drive is write protected when disc is not",13
defb "inserted",13
defb "b) drive is write protected or not depending",13
defb "on write protect TAB of disc",13
defb "c) drive is write protected when drive is not",13
defb "connected",13,13
defb "Checking 'ready':",13
defb "1. Insert disc, Remove disc, Turn disc motor on",13
defb "OR turn disc motor OFF",13
defb "2. Repeat 1 as much as you want",13
defb "Expected:",13,13
defb "a) drive is not ready if it's not connected",13
defb "b) drive is not ready if disc is not inserted",13
defb "c) drive is not ready if disc inserted and motor OFF",13
defb "d) drive is ready if disc inserted and motor ON",13
defb 13,13
defb "Checking 'PCN':",13
defb "1. Press Q or A to change track. See PCN change",13
defb "2. Repeat 1 as much as you want",13
defb 13,13
defb "Checking 'track 0':"
defb "1. Use Q,A to change track (seek) OR S to recalibrate",13
defb "2. repeat 1 as much as you want",13,13
defb "Expected:",13,13
defb "a) Seek/recalibrate will work if disc is in drive",13
defb "and motor is ON.",13
defb "b) Recalibrate or moving to track 0 will show 'track 0' state",13
defb 13,13
defb "M = disc motor on, N = disc motor off",13
defb "Q = Track + 1, A = Track - 1 ",13
defb "R = recalibrate",13,13
defb "Press a key to start the test",13
defb 0

seek_test_msg:
defb "The seek test:",13,13
defb "1. Formats a test disc with 1 sector per track",13
defb "where C is the same as the physical track number.",13
defb "2. Uses each step rate value (0-15) and tries to ",13
defb "seek to track 39.",13
defb "3. When FDC reports seek is complete, a read id",13
defb "is performed.",13,13
defb "If the C read from read id matches the physical track",13
defb "seeked then the step rate is ok for the drive.",13,13
defb "This test therefore finds the minimum step rate",13
defb "accepted by the drive tested.",13,13
defb "Press a key to start the test",13
defb 0

seek_0_txt:
defb "Seek to 0 test...",13,0
seek_0_done_txt:
defb 13,"Seek to 0 test...DONE",13,0
seek_39_txt:
defb "Seek to 39 test...",13,0
seek_39_done_txt:
defb 13,"Seek to 39 test...DONE",13,0

initialising_test_msg:
defb "Initialising tests...",13,0
initialising_test_done_msg:
defb "Initialising tests... DONE",13,0

res_seek_test:
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39
defb 39
defb &02,&20,&fe,&02,39		;; 3.5" drive can't do this it gets as far as 26
defb 39
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00
defb 0
defb &02,&20,&fe,&02,&00		;; 3.5" drive can't do this.
defb 0
defb -1

drive_cant_txt:
defb "Drive can't seek correctly with the following step rate values: ",13,130
drive_cant_0_to_39_txt:
defb "0->39: ",0
drive_cant_39_to_0_txt:
defb "39->0: ",0

seek_test:
ld hl,seek_test_msg
call output_msg
call wait_key

call choose_drive

ld hl,initialising_test_msg
call output_msg

ld hl,test_disk_format_data
call do_format_test_disk

ld hl,initialising_test_done_msg
call output_msg

ld ix,result_buffer

ld hl,seek_39_txt
call output_msg

ld b,16
ld c,0
st1:
push bc
push bc
push bc
call reset_specify

call go_to_0
pop bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc
ld a,c
ld (step_rate),a

call send_specify

call clear_fdd_interrupts

ld a,39
call send_seek
call get_ready_change
call get_results

;; now perform a read id
call read_id
ld a,(fdc_result_data+3)
ld (ix+0),a
inc ix
inc ix

pop bc
inc c
djnz st1

ld hl,seek_39_done_txt
call output_msg

ld hl,seek_0_txt
call output_msg


ld b,16
ld c,0
st2:
push bc
push bc
push bc
call reset_specify
ld a,39
call go_to_track
pop bc
ld a,b
call outputdec
ld a,' '
call output_char
pop bc
ld a,c
ld (step_rate),a

call send_specify

call clear_fdd_interrupts

ld a,0
call send_seek
call get_ready_change
call get_results

;; now perform a read id
call read_id
ld a,(fdc_result_data+3)
ld (ix+0),a
inc ix
inc ix

pop bc
inc c
djnz st2

ld hl,seek_0_done_txt
call output_msg


ld ix,result_buffer
ld hl,res_seek_test
call copy_results
ld bc,32*4
call do_results

ld hl,drive_cant_txt
call output_msg
ld hl,drive_cant_0_to_39_txt
call output_msg

ld ix,result_buffer
ld b,16
ld c,0
strr1:
push bc
ld a,(ix+6)
cp 39
jr z,strr2
push bc
ld a,' '
call output_char
pop bc
ld a,c
call outputdec
strr2:
pop bc
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc c
djnz strr1

call output_nl
ld hl,drive_cant_39_to_0_txt
call output_msg

ld b,16
ld c,0
strr3:
push bc
ld a,(ix+6)
cp 0
jr z,strr4
push bc
ld a,' '
call output_char
pop bc
ld a,c
call outputdec
strr4:
pop bc
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc c
djnz strr3
call output_nl

;;ld bc,32*4
;;call do_results
call wait_key
ret


;;-----------------------------------------
test_disk_format_data:
defb 0
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 0,&0,&41,2

defb 1
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 1,&0,&41,2

defb 2
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 2,&0,&41,2

defb 3
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 3,&0,&41,2

defb 4
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 4,&0,&41,2

defb 5
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 5,&0,&41,2

defb 6
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 6,&0,&41,2

defb 7
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 7,&0,&41,2

defb 8
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 8,&0,&41,2

defb 9
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 9,&0,&41,2

defb 10
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 10,&0,&41,2


defb 11
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 11,&0,&41,2

defb 12
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 12,&0,&41,2

defb 13
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 13,&0,&41,2

defb 14
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 14,&0,&41,2

defb 15
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 15,&0,&41,2

defb 16
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 16,&0,&41,2

defb 17
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 17,&0,&41,2

defb 18
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 18,&0,&41,2

defb 19
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 19,&0,&41,2

defb 20
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 20,&0,&41,2

defb 21
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 21,&0,&41,2

defb 22
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 22,&0,&41,2

defb 23
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 23,&0,&41,2

defb 24
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 24,&0,&41,2

defb 25
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 25,&0,&41,2

defb 26
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 26,&0,&41,2

defb 27
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 27,&0,&41,2

defb 28
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 28,&0,&41,2

defb 29
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 29,&0,&41,2

defb 30
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 30,&0,&41,2

defb 31
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 31,&0,&41,2

defb 32
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 32,&0,&41,2

defb 33
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 33,&0,&41,2

defb 34
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 34,&0,&41,2

defb 35
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 35,&0,&41,2

defb 36
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 36,&0,&41,2

defb 37
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 37,&0,&41,2

defb 38
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 38,&0,&41,2

defb 39
defb 0	
defb %01000000

defb 2
defb 1
defb def_format_gap
defb def_format_filler
defb 39,&0,&41,2

defb -1

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/output.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
;;if CPC=1
include "../cpc.asm"
include "../../lib/fw/output.asm"
include "../fdchelper.asm"
include "../../lib/hw/crtc.asm"
;;endif
;;if SPEC=1
;;include "../plus3.asm"
;;include "../../lib/spec/init.asm"
;;include "../../lib/spec/keyfn.asm"
;;include "../../lib/spec/printtext.asm"
;;include "../../lib/spec/readkeys.asm"
;;include "../../lib/spec/scr.asm"
;;include "../../lib/spec/writetext.asm"
;;endif

result_buffer equ $

end start