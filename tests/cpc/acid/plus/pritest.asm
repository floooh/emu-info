;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

;; asic tester 
org &8000
start:


ld a,2
call &bc0e
ld ix,tests
call run_tests
jp &bb06

;;TODO: PRI, R8=3, odd and even frames and odd/even R9
tests:
DEFINE_TEST "6c0f PRI status", test_pri_status
DEFINE_TEST "PRI start (R2)", test_pri_start
DEFINE_TEST "PRI start (R3)", r3_test_pri_start
;; mostly 1 followed by 13 2's
DEFINE_TEST "PRI re-trigger (hsync pos)", test_pri3
DEFINE_TEST "pri all values", test_pri_all
DEFINE_TEST "pri wrap", test_pri_wrap
DEFINE_TEST "PRI triggering tests", test_pri_trigger
;; 1,1,1,0,0,0, and some 2sfd
;; DEFINE_TEST "PRI trigger R8 (R8=0,R8=1,R8=2)", pri_trigger_r8
DEFINE_TEST "pri repeat (r9>8)",test_pri_repeat
DEFINE_TEST "pri delay (DI)",test_pri_delay
DEFINE_TEST "pri clear",test_pri_clear
DEFINE_TEST "PRI trigger bug (hsync pos)", test_pri_bug
DEFINE_TEST "PRI trigger bug (hsync width)", test_pri_bug2
DEFINE_TEST "PRI all values - count lines as expected - R7>PRI",test_pri_count_all
DEFINE_TEST "PRI can delay normal raster interrupt", test_pri_delay_norm
DEFINE_TEST "pri all values (through vsync)", test_pri_vsync
DEFINE_TEST "PRI 2 lines into vsync (R4 fixed, R7 varies)", test_pri_vsync_all
DEFINE_TEST "PRI 2 lines into vsync (R4 varies, R7 fixed)", test_pri_vsync_2all
DEFINE_TEST "PRI (enable norm during pri int handler)", test_pri_norm
;; 4,80,01,4,80,01,06,80,01,06,80,01,04, and repeat...
DEFINE_TEST "im2 vector (pri)", im2_pri_raster
;; 6,80,06,4,80,06,04,80,06,04,80,06,

;; 4 error, 4 ok
;; 6,36,80,6,36,80,6,36,80,6,3e,80,06,3c,80,06,3c,80
DEFINE_TEST "im2 vector (norm)", im2_norm_raster
DEFINE_END_TEST

wait_2_lines:
defs 64*2
ret


test_raster_vec:
di

;; from reset, standard raster int
ld ix,result_buffer

ld hl,rst_code3
call init_im2
ei

halt

;; seen fe (254)
;; should be vector after reset
ld a,(vector_used)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

;; enable asic to get access to page
call asic_enable

halt

;; get vector
ld a,(vector_used)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

;; enable asic ram
ld bc,&7fb8
out (c),c

halt

;; get flag 
ld a,(&6c0f)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

;; store
ld a,(vector_used)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

;; disable asic ram
ld bc,&7fa0
out (c),c

halt

;; store
ld a,(vector_used)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

ld bc,&7fb8
out (c),c

ld a,100
ld (&6800),a

halt

;; store
ld a,(vector_used)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

ld a,0
ld (&6800),a

halt

;; store
ld a,(vector_used)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix


call restore_raster_int

ld ix,result_buffer
ld bc,7
jp simple_results

im2_pri_raster:
;; turn on raster interrupt
ld a,100
jp im2_vec_raster

im2_norm_raster
xor a
jp im2_vec_raster

im2_vec_line:
defb 0

;;--------------------------------------------------------

im2_vec_raster:
ld (im2_vec_line),a

call store_rst1
call store_int
di
call asic_enable
xor a
ld (vector),a

ld bc,&7f00+%10001110
out (c),c

ld bc,&7fb8
out (c),c

ld hl,rst_code1
call init_im2

ld ix,result_buffer

ivr1:
di
ld a,(im2_vec_line)
ld (&6800),a

;; turn off dma etc
ld a,%01110000
ld (&6c0f),a

;; set this vector
ld a,(vector)
ld (&6805),a

call clear_results

call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(vector_used)
ld (ix+0),a
inc ix
ld a,(vector)
and &f8
or 6
ld (ix+0),a
inc ix

;; the irq
ld a,(int_req)
ld (ix+0),a
inc ix
ld (ix+0),&80 ;; expect raster interrupt only
inc ix

;; the count
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

ld a,(vector)
inc a
ld (vector),a
or a
jp nz,ivr1

call restore_raster_int
call restore_rst1
ld ix,result_buffer
ld bc,256*3
jp simple_results


store_rst1:
ld hl,8
ld de,rst1_stored
ld bc,3
ldir
ret
restore_rst1:
ld hl,rst1_stored
ld de,8
ld bc,3
ldir
ret
rst1_stored:
defs 3

;;--------------------------------------------------------------------

rst_code1:
ex (sp),hl	;; hl onto stack, return into hl
push hl
push af
dec hl	;; go back one because it's the start we want and not the return address

push bc
;; base of the rst instructions
ld bc,&1000
or a
sbc hl,bc
add hl,hl
ld a,l
ld (vector_used),a		;; vector used	

ld a,(&6c0f)
ld (int_req),a			;; int req at time

;; clear ints
ld a,%01110000
ld (&6c0f),a

ld a,(int_count)
inc a
ld (int_count),a

pop bc
pop af
pop hl
;; return hl from stack
ex (sp),hl
inc sp
inc sp
ei
reti


vector_used:
defb 0

vector:
defb 0

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


restore_asic:
ld bc,&7fa0
out (c),c
jp asic_disable




test_pri_delay_norm:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c

ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1

ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a


ld hl,norm_results
ld ix,result_buffer
ld bc,0+(end_norm_results-norm_results)/2
tpm1b:
ld e,(hl)
inc hl
ld d,(hl)
inc hl
ld (ix+1),e
ld (ix+3),d
inc ix
inc ix
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,tpm1b

ld ix,result_buffer
ld a,1
ld b,255
tpm:
push af
push bc
di
;; set pri
ld (&6800),a

call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c
ei
halt
;; wait until another int happens (which will be normal and count 
;; the number of lines until it does)
xor a
ld (int_count),a
ld (&6800),a ;; disable pri
ld hl,int_count
ld de,0

tpm1:
ld a,(hl) ;; int count change?
or a
jp nz,tpm2

inc de	;; inc count
defs 64-3-2-3-1-2
jp tpm1

tpm2:
di
ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop af
inc a
djnz tpm

call restore_raster_int

ld ix,result_buffer
ld bc,255*2
jp simple_results

norm_results:
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20
defw &1f
defw &1e
defw &1d
defw &1c
defw &1b
defw &1a
defw &19
defw &18
defw &17
defw &16
defw &15
defw &14
defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20
defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20
defw &1f
defw &1e
defw &1d
defw &1c
defw &1b
defw &1a
defw &19
defw &18
defw &17
defw &16
defw &15
defw &14

defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20

defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20
defw &1f
defw &1e
defw &1d
defw &1c
defw &1b
defw &1a
defw &19
defw &18
defw &17
defw &16
defw &15
defw &14

defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20

defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20
defw &1f
defw &1e
defw &1d
defw &1c
defw &1b
defw &1a
defw &19
defw &18
defw &17
defw &16
defw &15
defw &14

defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20


defw &2d
defw &2c
defw &2b
defw &2a
defw &29
defw &28
defw &27
defw &26
defw &25
defw &24
defw &23
defw &22
defw &21
defw &20
defw &1f
defw &1e
defw &1d
defw &1c
defw &1b
defw &1a
defw &19
defw &18
defw &17
defw &16
defw &15
defw &14
defw &13
defw &12
defw &11
defw &10
defw &0f
defw &0e

defw &41
defw &40
defw &3f
defw &3e
defw &3d
defw &3c
defw &3b
defw &3a
defw &39
defw &38
defw &37
defw &36
defw &35
defw &34
defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e

defw &33
defw &32
defw &31
defw &30
defw &2f
defw &2e
defw &2d
defw &2c
end_norm_results:




;;--------------------------------------------------------

pri_int:
push af
ld a,(int_count)
inc a
ld (int_count),a
pop af
ei
reti

;;--------------------------------------------------------
;; restore raster int
restore_raster_int:

call asic_enable
ld bc,&7fb8
out (c),c

;; disable PRI, turn on normal
ld a,0
ld (&6800),a
ld a,1
ld (&6805),a

;; set int mode
im 1

;; clear dma int and disable channel
ld a,%01110000
ld (&6c0f),a

call set_crtc

call restore_asic

call restore_int

ei
ret

;; PRI during VADJ
;; PRI out of reach (>R4)
;; PRI out of reach (>RCC)
test_pri_trigger:
call store_int
di
call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c





;; disable dma
ld a,0
ld (&6c0f),a

ld ix,result_buffer

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+7
out (c),c

;; test trigger in vertical adjust
ld b,32		;; all VADJ values
ld d,0
ld a,8*8
tpt1:
push af
push bc
push de

push af
;; set vertical adjust
ld bc,&bc05
out (c),c
inc b
out (c),d
call wait_frame
call wait_frame
call wait_frame
call wait_frame
pop af
;; set raster int
ld (&6800),a
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop de
inc d
pop bc
pop af
inc a
djnz tpt1

;; should not trigger
ld bc,&bc04
out (c),c
ld bc,&bd00+31-1
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+28
out (c),c

ld bc,&bc05
out (c),c
ld bc,&bd00
out (c),c

;; stop raster int from occuring
ld a,254
ld (&6800),a

call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; disable dma
ld a,0
ld (&6c0f),a

;; should not trigger
ld bc,&bc09
out (c),c
ld bc,&bd00+3
out (c),c

call wait_frame

;; stop raster int from occuring
ld a,4
ld (&6800),a

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; disable dma
ld a,0
ld (&6c0f),a


call restore_raster_int

ld ix,result_buffer
ld bc,2+32
jp simple_results

pri_trigger_r8:
call store_int
di
call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c





;; disable dma
ld a,0
ld (&6c0f),a

ld ix,result_buffer

ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c

ld b,255
ld a,1
ptr81:
push af
push bc

push af

ld a,0
ld (&6800),a

call wait_frame
call wait_frame
call wait_frame
call wait_frame
pop af
;; set raster int
ld (&6800),a
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

pop de
inc d
pop bc
pop af
inc a
djnz ptr81


ld bc,&bc08
out (c),c
ld bc,&bd01
out (c),c

ld b,255
ld a,1
ptr82:
push af
push bc

push af

ld a,0
ld (&6800),a

call wait_frame
call wait_frame
call wait_frame
call wait_frame
pop af
;; set raster int
ld (&6800),a
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

pop de
inc d
pop bc
pop af
inc a
djnz ptr82


ld bc,&bc08
out (c),c
ld bc,&bd02
out (c),c

ld b,255
ld a,1
ptr83:
push af
push bc

push af

ld a,0
ld (&6800),a

call wait_frame
call wait_frame
call wait_frame
call wait_frame
pop af
;; set raster int
ld (&6800),a
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

pop de
inc d
pop bc
pop af
inc a
djnz ptr83

ld a,0
ld (&6800),a

call restore_raster_int
ei

ld ix,result_buffer
ld bc,255*3
jp simple_results


test_pri_repeat:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a


ld ix,result_buffer

ld bc,&bc09
out (c),c
ld bc,&bd00+31
out (c),c

;; set
ld a,10
ld (&6800),a

call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),4
inc ix

call restore_raster_int

ld ix,result_buffer
ld bc,1
jp simple_results

test_pri_delay:
call store_int
di
call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a


ld ix,result_buffer

;; set
ld a,10
ld (&6800),a
ei
halt
di
;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a

;; wait a frame to delay it
call wait_frame
call wait_frame
ei
;; wait a couple of lines to see if int triggers
call wait_2_lines

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

call restore_raster_int

ld ix,result_buffer
ld bc,1
jp simple_results


test_pri_clear:
call store_int
di
call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a


ld ix,result_buffer

;; set
ld a,10
ld (&6800),a

;; wait frame to ensure it's setup
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a

;; wait a frame to delay it and ensure it's asserted
call wait_frame

;; clear
ld bc,&7f00+%10011110
out (c),c
ei
;; it will either trigger or not
defs 4

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

call restore_raster_int

ld ix,result_buffer
ld bc,1
jp simple_results


set_crtc:
;; set initial CRTC settings (screen dimensions etc)
ld hl,end_crtc_data
ld bc,&bc0f
crtc_loop:
out (c),c
dec hl
ld a,(hl)
inc b
out (c),a
dec b
dec c
jp p,crtc_loop
ret

wait_frame:
;; wait start
ld b,&f5
wf1:
in a,(c)
rra
jr nc,wf1
;; wait end
wf2:
in a,(c)
rra
jr c,wf2
ret

crtc_data:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
end_crtc_data:

;;--------------------------------------------------------

clear_results:
;; clear
ld a,0
ld (vector_used),a
ld (int_req),a
ld (int_count),a
ret

;;--------------------------------------------------------
;; HL = function
init_im2:
;; set function to call from rst
ld a,&c3
ld (&0008),a
ld (&0009),hl

;; setup 128 rsts (128 because asic will force bit 0 to 0)
ld hl,&1000
ld b,128
ii2: ld (hl),&cf ;; rst 1
inc hl
djnz ii2

;; init table to point to the rsts
ld hl,&1100
ld b,128
ld de,&1000
sv:
ld (hl),e
inc hl
ld (hl),d
inc hl
inc de
djnz sv

ld a,&11
ld i,a

im 2
ret


capture_control:
ld e,16
tps1:
;; status remains set for a while
ld a,(&6c0f)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix
defs 64
dec e
jr nz,tps1
ret

int_count:
defb 0

int_req:
defb 0

test_pri_all:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a

ld ix,result_buffer
xor a
ld b,0
tpa:
push af
push bc
;; stop raster int from occuring
ld (&6800),a
push af
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
pop af
or a
ld a,6
jr z,tpa2
ld a,1
tpa2:
ld (ix+0),a
inc ix
pop bc
pop af
inc a
djnz tpa

call restore_raster_int

ld ix,result_buffer
ld bc,256
jp simple_results

test_pri_count_all:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1
ei

ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a

ld ix,result_buffer
ld b,255
ld de,1
tpca1:
ld (ix+1),e
ld (ix+3),d
inc ix
inc ix
inc ix
inc ix
inc de
djnz tpca1

ld ix,result_buffer
ld a,1
ld b,255
tpca:
push af
push bc

push af
ld bc,&bc07
out (c),c
ld bc,&bd00+&7f
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+3
out (c),c
ld a,0
ld (&6800),a
rept 32
halt
endm
ld a,7+(3*8)
ld (&6800),a
halt
pop af
ld (&6800),a
defs 32
ld bc,&bc04
out (c),c
ld bc,&bd00+&7f
out (c),c
call count_lines

ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop af
inc a
dec b
jp nz,tpca
di
call crtc_reset
call restore_raster_int
ei

ld ix,result_buffer
ld bc,255*2
jp simple_results


count_lines:
xor a
ld (int_count),a
ld hl,int_count
ld de,0

cl1:
ld a,(hl) ;; int count change?
or a
jp nz,cl2

inc de	;; inc count
defs 64-3-2-3-1-2
jp cl1

cl2:
ret

test_pri_vsync_all:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1
ei

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld b,32
tpava1:
ld a,b
cp 1
ld de,&5
jr nz,tpava1b
ld de,&15
tpava1b:
ld (ix+1),e
ld (ix+3),d
inc ix
inc ix
inc ix
inc ix
djnz tpava1

;; disable dma
ld a,%01110000
ld (&6c0f),a

ld bc,&bc04
out (c),c
ld bc,&bd00+33
out (c),c

ld ix,result_buffer
ld a,1
ld b,32
tpava:
push af
push bc

push af
ld a,0
ld (&6800),a
pop af

push af
push af
push af
ld bc,&bc07
out (c),c
inc b
out (c),a
pop af

call wait_frame
call wait_frame
pop af
dec a		;; few lines before
add a,a
add a,a
add a,a
add a,4
ld (&6800),a
halt
pop af
add a,a
add a,a
add a,a
add a,1		;; 2 lines into vsync
ld (&6800),a	
call count_lines

ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop af
inc a
djnz tpava
di
call crtc_reset
call restore_raster_int
ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret

;; delay normal int, set pri, see how long before int is triggered
;; setting pri clear 

pri_norm_handler:
push af
xor a
ld (&6800),a
ld a,(int_count)
inc a
ld (int_count),a
pop af
ei
ret

test_pri_norm:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c

ld bc,&bc03
out (c),c
ld bc,&bd00
out (c),c

;; set pri int
ld a,&c3
ld hl,pri_norm_handler
ld (&0038),a
ld (&0039),hl
im 1
ei

ld bc,&7fb8
out (c),c

;; needs to be line where normal int would happen
ld a,100
ld (&6800),a


;; disable dma
ld a,%01110000
ld (&6c0f),a

;; wait x lines

ld ix,result_buffer
ld a,(int_count)
ld (ix+0),a
inc ix
inc ix

di
call crtc_reset
call restore_raster_int
ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret

test_pri_vsync_2all:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1
ei

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld b,32
;; 2 for first
tpava3:
ld a,b
cp 1
ld de,&4
jr nz,tpava3b
ld de,&0104
tpava3b:
ld (ix+1),e
ld (ix+3),d
inc ix
inc ix
inc ix
inc ix
djnz tpava3

;; disable dma
ld a,%01110000
ld (&6c0f),a

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld ix,result_buffer
ld a,1
ld b,32
tpava2:
push af
push bc

push af
ld a,0
ld (&6800),a
pop af

push af
push af

ld bc,&bc04
out (c),c
inc b
out (c),a
pop af

call wait_frame
call wait_frame
pop af
add a,a
add a,a
add a,a
add a,5
ld (&6800),a
halt
ld a,1
ld (&6800),a
call count_lines

ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop af
inc a
djnz tpava2
di
call crtc_reset
call restore_raster_int
ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret

test_pri_vsync:
call store_int
di

call asic_enable
ld bc,&7f00+%10001110
out (c),c


;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1
ei

ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a

;; R4=15 &0184 (128 scans) (388) 3 frames???
;;...
;; R4=8 &01bc (444)
;; R4=7 &01c4
;; R4=6 &01cc
;; R4=5 &01d4
;; R4=4 &01dc
;; R4=3 &01e4
;; R4=2 &01ec
;; R4=1 test hangs

ld ix,result_buffer
ld de,4
ld b,23
xor a
tpav1:
or a
jr nz,tpav2

ld (ix+1),&e4	;; pri is also reset/acknowledged/cleared
ld (ix+3),&01
jr tpav3
tpav2:
ld (ix+1),e
ld (ix+3),d
tpav3:
inc a
inc ix
inc ix
inc ix
inc ix
inc de
djnz tpav1

ld ix,result_buffer
ld a,1
ld b,23
tpav:
push af
push bc

push af
call wait_frame
call wait_frame

;; 4*8 = 32 
;; 
ld bc,&bc04
out (c),c
ld bc,&bd00+3
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld a,5+(3*8)
ld (&6800),a
halt
pop af
ld (&6800),a
call count_lines

ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop af
inc a
djnz tpav
di
call crtc_reset
call restore_raster_int
ei
ld ix,result_buffer
ld bc,23*2
call simple_results
ret


test_pri_wrap:
call store_int
di
call asic_enable
ld bc,&7f00+%10001110
out (c),c

;; set taller screen
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd7f
out (c),c

;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1


ld bc,&7fb8
out (c),c


;; disable dma
ld a,%01110000
ld (&6c0f),a

ld ix,result_buffer
xor a
ld b,0
tpw:
push af
push bc
ld (&6800),a
push af
call wait_frame
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di

;; the vector
ld a,(int_count)
ld (ix+0),a
inc ix
pop af
or a
ld a,&13
jr z,tpw2
ld a,2
tpw2:
ld (ix+0),a
inc ix
pop bc
pop af
inc a
djnz tpw

call restore_raster_int

ld ix,result_buffer
ld bc,256
jp  simple_results


rst_code3:
ex (sp),hl	;; hl onto stack, return into hl
push af
dec hl	;; go back one because it's the start we want and not the return address

push bc
;; base of the rst instructions
ld bc,&1000
or a
sbc hl,bc
add hl,hl
ld a,l
ld (vector_used),a		;; vector used	

pop bc
pop af
;; return hl from stack
ex (sp),hl
inc sp
inc sp
ei
reti

test_pri_status:
call store_int
di
call asic_enable
ld bc,&7f00+%10001110
out (c),c
ld bc,&7fb8
out (c),c

;; disable dma
ld a,%01110000
ld (&6c0f),a

;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl
im 1

ei

ld ix,result_buffer

;; set pri interrupt
ld a,100
ld (&6800),a
halt

;; check the status remains set for a while; and it does
call capture_control

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

;; check it remains set, which it does.

call capture_control

call restore_raster_int

ld ix,result_buffer
ld bc,32
jp simple_results



;; 2,1,1,1,2,2,2,2,2,2,

test_pri_bug2:
call store_int
di
call asic_enable

ld bc,&7f00+%10001110
out (c),c

ld bc,&bc02
out (c),c
ld bc,&bd00+60
out (c),c

ld bc,&7fb8
out (c),c

;; clear dma ints
ld a,%01110000
ld (&6c0f),a

;; disable dma channels
ld a,0
ld (&6c0f),a

;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl

;; use im1
im 1

;; set the line
ld a,100
ld (&6800),a

ld b,16
ld c,0
ld ix,result_buffer
tpb2:
push bc
ld a,c

;; set hsync position
ld bc,&bc03
out (c),c
inc b
or &80
out (c),a

call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di
ld a,(int_count)
ld (ix+0),a
inc ix
pop bc
;; 0 = 16
ld a,c
add a,hsync_width_results AND 255
ld l,a
ld a,hsync_width_results/256
adc a,0
ld h,a
ld a,(hl)
ld (ix+0),a
inc ix
inc c
djnz tpb2

call restore_raster_int

ld ix,result_buffer
ld bc,16
jp simple_results


;; it's delayed inside the asic
hsync_width_results:
defb 2		;; 60+16
defb 1 		;; 60+1 -> 62
defb 1		;; 60+2 -> 63
defb 1		;; 60+3 -> 64?
defb 2		;; 60+4
defb 2		;; 60+5
defb 2
defb 2
defb 2
defb 2
defb 2
defb 2
defb 2
defb 2
defb 2
defb 2

pri_int3:
inc (hl)
ei
ret

test_pri3:
call store_int
di
call asic_enable

ld bc,&7f00+%10001110
out (c),c

ld bc,&7fb8
out (c),c

;; clear dma ints
ld a,%01110000
ld (&6c0f),a

;; disable dma channels
ld a,0
ld (&6c0f),a

;; set pri int
ld a,&c3
ld hl,pri_int3
ld (&0038),a
ld (&0039),hl

;; use im1
im 1


ld b,63
ld c,0
ld ix,result_buffer
tp3b2:
push bc
ld a,c

;; set hsync position
ld bc,&bc02
out (c),c
inc b
out (c),a

;; clear raster int
ld bc,&7f00+%10011110
out (c),c
ei
ld de,&6800
ld a,100
ld (&6800),a
ld hl,int_count
ld (hl),0
halt
rept 64
;; keep setting pri line
ld (de),a
endm
di
ld a,(int_count)
ld (ix+0),a
inc ix
pop bc
ld a,c
cp 64-14
ld a,2
jr nc,tb3p1a
ld a,1
tb3p1a:
ld (ix+0),a
inc ix
inc c
djnz tp3b2

call restore_raster_int

ld ix,result_buffer
ld bc,63
jp simple_results

test_pri_start:
call store_int
di
call asic_enable

ld bc,&7f00+%10001110
out (c),c

ld bc,&7fb8
out (c),c

;; clear dma ints
ld a,%01110000
ld (&6c0f),a

;; disable dma channels
ld a,0
ld (&6c0f),a

;; set pri int
ld hl,&c9fb
ld (&0038),hl

;; use im1
im 1


ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+3
out (c),c

ld a,3*8+7
ld (&6800),a

ld ix,result_buffer
ld hl,pri_start_data
ld bc,63*6
tpd3b2a:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,tpd3b2a


ld b,63
ld c,0
ld ix,result_buffer
tpd3b2:
push bc
ld a,c

;; set hsync position
ld bc,&bc02
out (c),c
inc b
out (c),a

di
call wait_frame
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c
ei
ld b,&f5
halt
in a,(c)
in d,(c)
in e,(c)
in h,(c)
in l,(c)
in c,(c)

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

pop bc
inc c
djnz tpd3b2

di
call restore_raster_int
call crtc_reset
ei

ld ix,result_buffer
ld bc,63*2
call simple_results
ret
;;ld ix,result_buffer
;;ld bc,63*6*2
;;ld d,12
;;jp  simple_number_grid

r3_test_pri_start:
call store_int
di
call asic_enable

ld bc,&7f00+%10001110
out (c),c

ld bc,&7fb8
out (c),c

;; clear dma ints
ld a,%01110000
ld (&6c0f),a

;; disable dma channels
ld a,0
ld (&6c0f),a

;; set pri int
ld hl,&c9fb
ld (&0038),hl

;; use im1
im 1


ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+3
out (c),c

ld a,3*8+7
ld (&6800),a

ld ix,result_buffer
ld hl,r3_pri_start_data
ld bc,16*6
rtpd3b2a:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,rtpd3b2a

ld bc,&bc02
out (c),c
ld bc,&bd00+64-8
out (c),a

ld b,16
ld c,0
ld ix,result_buffer
r3tpd3b2:
push bc
ld a,c

;; set hsync width
ld bc,&bc03
out (c),c
inc b
or &80
out (c),a

di
call wait_frame
call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c
ei
ld b,&f5
halt
in a,(c)
in d,(c)
in e,(c)
in h,(c)
in l,(c)
in c,(c)

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

pop bc
inc c
djnz r3tpd3b2

di
call restore_raster_int
call crtc_reset
ei

ld ix,result_buffer
ld bc,16*2
call simple_results
ret

r3_pri_start_data:
rept 16
defb 0,0,0,0,0,1,0
endm

pri_start_data:
rept 63-13-6
defb 0,0,0,0,0,0,0
endm

defb 0,0,0,0,0,0,1
defb 0,0,0,0,0,0,1
defb 0,0,0,0,0,0,1
defb 0,0,0,0,0,0,1

defb 0,0,0,0,0,1,1
defb 0,0,0,0,0,1,1
defb 0,0,0,0,0,1,1
defb 0,0,0,0,0,1,1


defb 0,0,0,0,1,1,1
defb 0,0,0,0,1,1,1
defb 0,0,0,0,1,1,1
defb 0,0,0,0,1,1,1

defb 0,0,0,1,1,1,1
defb 0,0,0,1,1,1,1
defb 0,0,0,1,1,1,1
defb 0,0,0,1,1,1,1

defb 0,0,1,1,1,1,1
defb 0,0,1,1,1,1,1
defb 0,0,1,1,1,1,1
defb 0,0,1,1,1,1,1

defb 0,1,1,1,1,1,1
defb 0,1,1,1,1,1,1
defb 0,1,1,1,1,1,1
defb 0,1,1,1,1,1,1
rept 13*6
defs 0
endm


test_pri_bug:
call store_int
di
call asic_enable

ld bc,&7f00+%10001110
out (c),c

;; set hsync width and vsync width (only hsync width important here)
ld bc,&bc03
out (c),c
ld bc,&bd00+&8e
out (c),c

ld bc,&7fb8
out (c),c

;; clear dma ints
ld a,%01110000
ld (&6c0f),a

;; set pri int
ld a,&c3
ld hl,pri_int
ld (&0038),a
ld (&0039),hl

;; use im1
im 1

;; set the line
ld a,100
ld (&6800),a

ld b,64
ld c,0
ld ix,result_buffer
tpb1:
push bc
ld a,c

;; set hsync position
ld bc,&bc02
out (c),c
inc b
out (c),a

call wait_frame

;; clear raster int
ld bc,&7f00+%10011110
out (c),c

xor a
ld (int_count),a
;; turn on ints
ei
call wait_frame
di
ld a,(int_count)
ld (ix+0),a
inc ix
pop bc

ld a,c
cp 64-14
ld a,2
jr nc,tbp1a
ld a,1
tbp1a:
ld (ix+0),a
inc ix

inc c
djnz tpb1

call restore_raster_int

ld ix,result_buffer
ld bc,64
jp simple_results



;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/hw/asic.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"
include "../lib/int.asm"

result_buffer: equ $

end start
