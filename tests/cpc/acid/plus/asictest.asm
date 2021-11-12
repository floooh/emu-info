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


tests:
DEFINE_TEST "pal mask",pal_mask
DEFINE_TEST "CPC colour set (bit 5=0)",cpc_colour_set
DEFINE_TEST "CPC colour set (bit 5=1)",cpc_colour_set2
DEFINE_TEST "CPC pen set (bit 5=0)",cpc_pen_set
DEFINE_TEST "CPC pen set (bit 5=1)",cpc_pen_set2
DEFINE_TEST "CPC border set (bit 5=0)",cpc_border_set
DEFINE_TEST "CPC border set (bit 5=1)",cpc_border_set2
DEFINE_TEST "CPC mode set (bit 5=0) (locked)",cpc_mode_setl
DEFINE_TEST "CPC mode set (bit 5=1) (locked)",cpc_mode_setl2
DEFINE_TEST "CPC mode set (bit 5=0) (unlocked)",cpc_mode_setl3
DEFINE_TEST "CPC mode set (rmr2) (bit 5=1) (unlocked)",cpc_mode_setl4
DEFINE_TEST "IN set colour",in_set_col
DEFINE_TEST "DCSR mirror",dcsr_mirror

;;DEFINE_TEST "read analogue inputs", read_analogue_inputs
;;DEFINE_TEST "analogue inputs fixed (680c-680f)",analogue_inputs_fixed
;;DEFINE_TEST "analogue inputs write no change (680c-680f)",analogue_inputs

;; these fail sometimes vector is wrong!
;;DEFINE_TEST "im2 vector (dma 0)", im2_vec_dma0
;;DEFINE_TEST "im2 vector (dma 1)", im2_vec_dma1
;;DEFINE_TEST "im2 vector (dma 2)", im2_vec_dma2
;;DEFINE_TEST "im2 vector (all dma)", im2_vec_alldma

DEFINE_TEST "sprite coord test x (l/h)",spritex_lh
DEFINE_TEST "sprite coord test y (l/h)",spritey_lh
DEFINE_TEST "sprite coord test x (ffc0-0040)",spritex_coord_test
DEFINE_TEST "sprite coord test y (ffc0-0040)",spritey_coord_test
DEFINE_TEST "sprite coord test x (200-400)",spritex2_coord_test
DEFINE_TEST "sprite coord test y (0080-0280)",spritey2_coord_test
DEFINE_TEST "ASIC GA I/O decode test",ga_io_decode
DEFINE_TEST "sprite ram mask",sprite_ram_mask
DEFINE_TEST "sprite coord mirror",sprite_coord_mirror
DEFINE_END_TEST

spritex_lh:
di
ld ix,result_buffer
call asic_enable
ld bc,&7fb8
out (c),c

ld b,0
ld c,0
sxlh:
push bc
ld de,&133
ld (&6000),de
;; set low byte
ld hl,&6000
ld (hl),c

ld a,(hl)
ld (ix+0),a
inc hl
inc ix
ld (ix+0),c
inc ix
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
ld (ix+0),&1
inc ix

pop bc
inc c
djnz sxlh
call restore_asic
ei
ld ix,result_buffer
ld bc,256*2
jp simple_results

spritey_lh:
di
ld ix,result_buffer
call asic_enable
ld bc,&7fb8
out (c),c

ld b,0
ld c,0
sylh:
push bc
ld de,&100
ld (&6002),de
;; set low byte
ld hl,&6002
ld (hl),c

ld a,(hl)
ld (ix+0),a
inc hl
inc ix
ld (ix+0),c
inc ix
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
ld (ix+0),&ff
inc ix

pop bc
inc c
djnz sylh

call restore_asic
ei
ld ix,result_buffer
ld bc,256*2
jp simple_results










;;--------------------------------------------------------

dma_int_req:
defb 0

dma_enable:
defb 0

dma_addr_base:
defb 0

dma_vec:
defb 0

;;--------------------------------------------------------

im2_vec_dma0:
ld a,%01000000
ld (dma_int_req),a
ld a,%00000001
ld (dma_enable),a
ld a,0
ld (dma_addr_base),a
ld a,4
ld (dma_vec),a
jr im2_vec_dma

;;--------------------------------------------------------

im2_vec_dma1:
ld a,%00100000
ld (dma_int_req),a
ld a,%00000010
ld (dma_enable),a
ld a,4
ld (dma_addr_base),a
ld a,2
ld (dma_vec),a
jr im2_vec_dma

;;--------------------------------------------------------

im2_vec_dma2:
ld a,%00010000
ld (dma_int_req),a
ld a,%00000100
ld (dma_enable),a
ld a,8
ld (dma_addr_base),a
ld a,0
ld (dma_vec),a
jr im2_vec_dma

;;--------------------------------------------------------

im2_vec_dma:
call store_int
call store_rst1
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

ivrd1:
di

ld bc,&bc04
out (c),c
ld bc,&bd00+31-1
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+28
out (c),c

;; stop raster int from occuring
ld a,254
ld (&6800),a

;; set this vector
ld a,(vector)
ld (&6805),a

call clear_results

call wait_frame

ld hl,dma_instruct
ld de,&2000
ld bc,end_dma_instruct-dma_instruct
ldir

;; disable all channels
xor a
ld (&6c0f),a

ld h,&6c
ld a,(dma_addr_base)
ld l,a
ld de,&2000
ld (hl),e
inc hl
ld (hl),d
inc hl
ld a,1
ld (hl),a


;; clear raster int
ld bc,&7f00+%10011110
out (c),c

;; clear dma ints
ld a,%0111000
ld (&6c0f),a

;; enable dma irq
ld a,(dma_enable)
ld (&6c0f),a


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
ld c,a
ld a,(dma_vec)
or c
ld (ix+0),a
inc ix

;; the irq
ld a,(int_req)
ld (ix+0),a
inc ix
ld a,(dma_int_req)
ld c,a
ld a,(dma_enable)
or c
ld (ix+0),a

ld a,(vector)
bit 0,a
jr nz,ivrd2

;; auto clear - interrupt request flags don't show up
;; because it has been cleared
ld a,(ix+0)
and %00000111
ld (ix+0),a

ivrd2:
inc ix

;; count
ld a,(int_count)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix


ld bc,&bc04
out (c),c
ld bc,&bd00+&26
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+&1e
out (c),c

;; restore raster int
ld a,0
ld (&6800),a


ld a,(vector)
inc a
ld (vector),a
or a
jp nz,ivrd1

call restore_rst1
call restore_raster_int
ei
ld ix,result_buffer
ld bc,256*3
jp simple_results

;;--------------------------------------------------------------------

dma_clear:
defb 0

;;--------------------------------------------------------------------

rst_code2:
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
ld (iy+0),a	;; vector
inc iy

ld a,(&6c0f)
ld (iy+0),a ;; irq
inc iy

ld a,l
cp 0			;; 2
ld l,%00010000
jr z,rst_code2b
cp 2
ld l,%00100000
jr z,rst_code2b
cp 4
ld l,%01000000
jr z,rst_code2b
ld l,%01110000
;; clear ints
rst_code2b:
ld a,(&6c0f)
and l
ld (&6c0f),a

pop bc
pop af
;; return hl from stack
ex (sp),hl
inc sp
inc sp
ei
reti

;;--------------------------------------------------------------------

im2_vec_alldma:
call store_int
call store_rst1
di
call asic_enable
xor a
ld (vector),a
ld bc,&7f00+%10001110
out (c),c

ld bc,&7fb8
out (c),c

ld hl,rst_code2
call init_im2

ld ix,result_buffer

ivrd3:
di

ld bc,&bc04
out (c),c
ld bc,&bd00+31-1
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+28
out (c),c

;; stop raster int from occuring
ld a,254
ld (&6800),a

;; set this vector
ld a,(vector)
ld (&6805),a

call wait_frame

ld hl,dma_instruct
ld de,&2000
ld bc,end_dma_instruct-dma_instruct
ldir

;; ensure all are disabled
ld a,0
ld (&6c0f),a

;; set all to the same address
ld de,&2000
ld hl,&6c00
ld (hl),e
inc hl
ld (hl),d
ld hl,&6c04
ld (hl),e
inc hl
ld (hl),d
ld hl,&6c08
ld (hl),e
inc hl
ld (hl),d


;; clear raster int
ld bc,&7f00+%10011110
out (c),c

;; clear dma ints
ld a,%0111000
ld (&6c0f),a

ld iy,dma_results

;; enable dma (all of them)
ld a,7
ld (&6c0f),a


;; turn on ints
ei
call wait_frame
di

push iy
pop hl

;; how many results did we see?
ld bc,dma_results
or a
sbc hl,bc
srl h
rr l
ld a,l
ld b,l
;; got results
ld (ix+0),a
inc ix
;; expected results
ld (ix+0),3
inc ix


ld a,(iy+0)	;; vector
ld (ix+0),a
inc ix
ld (ix+0),3	;; dma 0
inc ix

ld a,(iy+1)	;; irq
ld (ix+0),a
inc ix

ld e,%01110111		;; all channels active, all channels interrupting
ld a,(vector)
bit 0,a
jr nz,ivrd3a
res 6,e
ivrd3a:
ld (ix+0),e
inc ix

ld a,(iy+0)
ld (ix+0),a
inc ix
ld (ix+0),2	;; dma 1
inc ix

ld a,(iy+1)
ld (ix+0),a
inc ix

ld e,%00110111		;; all channels active, all channels interrupting
ld a,(vector)
bit 0,a
jr nz,ivrd3b
res 5,e
ivrd3b:
ld (ix+0),e
inc ix


ld a,(iy+0)
ld (ix+0),a
inc ix
ld (ix+0),1	;; dma 2
inc ix

ld a,(iy+1)
ld (ix+0),a
inc ix

ld e,%00010111		;; all channels active, all channels interrupting
ld a,(vector)
bit 0,a
jr nz,ivrd3c
res 4,e
ivrd3c:
ld (ix+0),e
inc ix

ld bc,&bc04
out (c),c
ld bc,&bd00+&26
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+&1e
out (c),c

;; restore raster int
ld a,0
ld (&6800),a


ld a,(vector)
inc a
ld (vector),a
or a
jp nz,ivrd3

call restore_rst1
call restore_raster_int

ld ix,result_buffer
ld bc,256*4
jp simple_results

dma_results:
defb 0


dma_instruct:
defw &4010
defw &4020
end_dma_instruct:


;;--------------------------------------------------------


ga_io_decode:
di
ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl

ld bc,&df00
out (c),c
ld bc,&7f00+%10000010
out (c),c
ld a,(&1000)
ld (val_1000+1),a
ld a,(&d000)
ld (val_d000+1),a

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
ld a,%10000010
out (c),a
push bc
ld bc,&df00
out (c),c
pop bc

ld a,(&1000)
val_1000:
cp 0
jr nz,next
ld a,(&d000)
val_d000:
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
;; plus shows 011xxxxxxxxxxxxx
ld ix,result_buffer
ld de,(portimportant)
ld (ix+0),e
ld (ix+1),&00
ld (ix+2),d
ld (ix+3),&c0
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&ff
ld (ix+6),h
ld (ix+7),&7f
ld bc,4
jp simple_results


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

jp crtc_reset


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


portsuccessOR:
defw 0
portsuccessAND:
defw 0

portimportant:
defw 0



spritex_coord_test:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld de,&ffc0
ld bc,128

sxct1:
push de
push bc
ld (&6000),de
ld (ix+1),e
ld (ix+3),d
ld de,(&6000)
ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop de
dec bc
ld a,b
or c
jr nz,sxct1

call restore_asic

ei
ld ix,result_buffer
ld bc,128*2
jp simple_results

restore_asic:
ld bc,&7fa0
out (c),c
jp asic_disable


spritex2_coord_test:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld de,&200
ld bc,512

sxct12:
push de
push bc
ld (&6000),de
ld (ix+1),e
ld a,d
cp 3
jr nz,sxct12b
ld a,&ff
sxct12b:
ld (ix+3),a
ld de,(&6000)
ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop de
dec bc
ld a,b
or c
jr nz,sxct12

call restore_asic

ei
ld ix,result_buffer
ld bc,512*2
jp simple_results


spritey_coord_test:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld de,&ffc0
ld bc,128

syct1:
push de
push bc
ld (&6002),de
ld (ix+1),e
ld a,d
or a
jr nz,syct12b
ld a,&ff
syct12b:
ld (ix+3),a
ld de,(&6002)
ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop de
dec bc
ld a,b
or c
jr nz,syct1

call restore_asic

ei

ld ix,result_buffer
ld bc,128*2
jp simple_results

spritey2_coord_test:
di

call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld de,&0080
ld bc,512

syct12:
push de
push bc
ld (&6002),de
ld (ix+1),e
ld (ix+3),d
ld de,(&6002)
ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
pop bc
pop de
dec bc
ld a,b
or c
jr nz,syct12

call restore_asic

ei

ld ix,result_buffer
ld bc,512*2
jp simple_results



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

;;--------------------------------------------------------

im2_vec_raster:
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
;; turn on raster interrupt
ld a,100
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



;;--------------------------------------------------------


vector_used:
defb 0

vector:
defb 0

int_count:
defb 0

int_req:
defb 0


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


pri_int3:
inc (hl)
ei
ret


dcsr_mirror:
di
ld hl,&4030	;; dma stop & int
ld (&1000),hl


call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer

;; iterate over all dma enables
ld b,8
xor a
dcsrm0:
push bc
push af

;; init dma
call init_dma
;; wait for it to complete (enough for dma to activate and execute)
call wait_2_lines
;; check mirror reports same value
call check_dcsr_mirror
ld a,1
jr c,dcsrm1
xor a
dcsrm1:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; now clear each in turn
ld a,%1000000
ld (&6c0f),a

;; check mirror reports same value
call check_dcsr_mirror
ld a,1
jr c,dcsrm2
xor a
dcsrm2:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; now clear each in turn
ld a,%0100000
ld (&6c0f),a

;; check mirror reports same value
call check_dcsr_mirror
ld a,1
jr c,dcsrm3
xor a
dcsrm3:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

;; now clear each in turn
ld a,%0010000
ld (&6c0f),a

;; check mirror reports same value
call check_dcsr_mirror
ld a,1
jr c,dcsrm4
xor a
dcsrm4:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop af
pop bc
inc a
djnz dcsrm0

ld a,0
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a
ld bc,&7f00+%10011000
out (c),c
ld bc,&df00
out (c),c
call restore_asic
ei

ld ix,result_buffer
ld bc,8*4
jp simple_results


;; checks all values are the same
check_dcsr_mirror:
push hl
push bc
push af
ld hl,&6c01
ld b,15
ld a,(&6c00)
cdm1:
cp (hl)
jr nz,cdm2
inc hl
djnz cdm1
pop af
pop bc
pop hl
or a
ret

cdm2:
pop af
pop bc
pop hl
scf
ret

wait_2_lines:
defs 64*2
ret

init_dma:

push af
xor a
ld (&6c0f),a
ld hl,&1000
xor a
ld (&6c00),hl
ld (&6c02),a
ld (&6c04),hl
ld (&6c06),a
ld (&6c08),hl
ld (&6c0a),a
pop af
ld (&6c0f),a
ret






cpc_mode_setl:
ld d,%00000000
ld e,0
jp cpc_mode_set

cpc_mode_setl2:
ld d,%00100000
ld e,0
jp cpc_mode_set

cpc_mode_setl3:
ld d,%00000000
ld e,1
jp cpc_mode_set

lower_byte:
defb 0
upper_byte:
defb 0
page4_byte:
defb 0

setup:
ld bc,&7f00+%10000000
out (c),c
ld bc,&df80
out (c),c
ld a,(&d000)
ld (lower_byte),a
ld bc,&df81
out (c),c
ld a,(&d000)
ld (upper_byte),a
ld bc,&df84
out (c),c
ld a,(&d000)
ld (page4_byte),a
ld bc,&7f00+%10001100
out (c),c
ret


cpc_mode_setl4:

ld d,%00100000
ld e,1
di
call setup
call asic_enable
call restore_asic

ld ix,result_buffer
call cmsl

ld bc,&7fc0
out (c),c

ld hl,&d000
ld (hl),&33
ld hl,&1000
ld (hl),&11
ld hl,&5000
ld (hl),&22


ld bc,&7f00+%10001100
out (c),c

ld bc,&df00
out (c),c

ld b,&7f
;; low rom at &0000
;; page 0
ld a,%10000000
or d
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&33	;; ram at &d000
inc ix
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),&11	;; ram at &1000
inc ix
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),&22	;; ram at &5000
inc ix


ld bc,&7f00+%10001100
out (c),c

ld bc,&df00
out (c),c

ld b,&7f
;; low rom at &4000
;; page 4
ld a,%10001100
or d
out (c),a
ld a,(&d000)	;; ram at &d000
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix
ld a,(&1000)	;; ram at &1000
ld (ix+0),a
inc ix
ld (ix+0),&11
inc ix
ld a,(&5000)	;; ram at &5000
ld (ix+0),a
inc ix
ld (ix+0),&22
inc ix


ld bc,&7f00+%10000000
out (c),c

ld bc,&df00
out (c),c

ld b,&7f
;; low rom at &0000
;; page 0
ld a,%10000000
or d
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,(upper_byte)
ld (ix+0),a	;; rom at &d000
inc ix
ld a,(&1000)
ld (ix+0),a
inc ix
ld a,(lower_byte)
ld (ix+0),a	;; rom at &1000
inc ix
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),&22	;; rom at &5000
inc ix


ld bc,&7f00+%10000000
out (c),c

ld bc,&df00
out (c),c

ld b,&7f
;; low rom at &4000
;; page 4
ld a,%10001100
or d
out (c),a
ld a,(&d000)	;; rom at &d000
ld (ix+0),a
inc ix
ld a,(upper_byte)
ld (ix+0),a
inc ix
ld a,(&1000)	;; ram at &1000
ld (ix+0),a
inc ix
ld (ix+0),&11
inc ix
ld a,(&5000)	;; rom at &5000
ld (ix+0),a
inc ix
ld a,(page4_byte)
ld (ix+0),a
inc ix


ld bc,&7f00+%10011000
out (c),c

ld bc,&df00
out (c),c
call restore_asic
ei

ld ix,result_buffer
ld bc,12
jp simple_results



cpc_mode_set:
di
call setup

call asic_enable
call restore_asic

ld ix,result_buffer
call cmsl

ld bc,&7fc0
out (c),c

ld hl,&d000
ld (hl),&33
ld hl,&1000
ld (hl),&11
ld hl,&5000
ld (hl),&22


ld bc,&7f00+%10001100
out (c),c

ld bc,&df00
out (c),c

ld b,&7f
ld a,%10000000
or d
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,(upper_byte)
ld (ix+0),a	;; rom at &d000
inc ix
ld a,(&1000)
ld (ix+0),a
inc ix
ld a,(lower_byte)
ld (ix+0),a	;; rom at &1000
inc ix
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),&22	;; ram at &5000
inc ix


ld bc,&7f00+%10001100
out (c),c

ld bc,&df00
out (c),c

ld b,&7f
ld a,%10001100
or d
out (c),a
ld a,(&d000)	;; ram at &d000
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix
ld a,(&1000)	;; ram at &1000
ld (ix+0),a
inc ix
ld (ix+0),&11
inc ix
ld a,(&5000)	;; ram at &5000
ld (ix+0),a
inc ix
ld (ix+0),&22
inc ix

call restore_asic

ei

ld ix,result_buffer
ld bc,6
jp simple_results




cmsl:
ld a,e
or a
jp z,asic_disable
jp asic_enable


read_analogue_inputs:
di

call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer
ld hl,&6808
ld b,8
rai1:
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
inc hl
djnz rai1

call restore_asic
ei
ld ix,result_buffer
ld bc,8
jp simple_results



analogue_inputs:
di

call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer

ld hl,&680c
ld b,4
ai1:
push bc
call wnc
ld a,0
jr nc,ai2
ld a,1
ai2:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
pop bc
djnz ai1

call restore_asic
ei
ld bc,4
ld ix,result_buffer
jp simple_results


analogue_inputs_fixed:
di

call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer

ld hl,&680c
ld c,&3f
call rnc_ix
ld (ix+0),0
inc ix

ld hl,&680d
ld c,&0			
call rnc_ix
;; on gx4000 this changes..
ld (ix+0),1
inc ix

ld hl,&680e
ld c,&3f
call rnc_ix
ld (ix+0),0
inc ix

ld hl,&680f
ld c,0			;; not on gx4000?
call rnc_ix
;; on gx4000 this changes..
ld (ix+0),1
inc ix

call restore_asic
ei
ld ix,result_buffer
ld bc,4
jp simple_results




wnc:
ld c,(hl)
ld b,0
xor a
wnc1:
ld (hl),a
ld a,(hl)
cp c
jr nz,wnc2
inc a
djnz wnc1
or a
ret
wnc2:
scf
ret

rnc_ix:
call rnc
ld a,0
jr nc,rnc_ix2
ld a,1
rnc_ix2:
ld (ix+0),a
inc ix
ret

rnc:
ld b,0
rnc1:
ld a,(hl)
cp c
jr nz,rnc2
djnz rnc1
or a
ret
rnc2:
scf
ret


dma_control_status:
di

call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer
ld b,0
xor a
ld hl,&6c0f
dcs1:
push hl
push af
ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
xor a
ld (&6c02),a
ld (&6c05),a
ld (&6c09),a
ld a,%11110000
ld (&6c0f),a
ld hl,&4020
ld (&1000),hl
pop af
pop hl

push af
ld (hl),a
ld a,(hl)
ld (ix+0),a
inc ix
and %10001111
ld (ix+0),a
pop af
inc ix
inc a
djnz dcs1
ld a,0
ld (&6c0f),a

call restore_asic

ei
ld ix,result_buffer
ld bc,256
jp simple_results


;; reading from +4 gives the same as reading from +0
;; reading from +6 gives the same as reading from +2
sprite_coord_mirror:
di

call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer
ld b,16
ld hl,&6000
scm1aa:
push bc
push hl
push hl
call scm1
ld a,0
jr nc,scm1a
ld a,1
scm1a:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
pop hl
inc hl
inc hl
call scm1
ld a,0
jr nc,scm1b
ld a,1
scm1b:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
pop hl
ld a,l
add a,8
ld l,a
pop bc
djnz scm1aa

call restore_asic

ei
ld ix,result_buffer
ld bc,16
jp simple_results


scm1:
ld de,&0
ld bc,0
scm2:
push bc
push hl
ld (hl),e	;; write coord
inc hl
ld (hl),d
dec hl
ld a,l
add a,4
ld l,a
ld c,(hl)
inc hl
ld b,(hl)
ex de,hl
or a
sbc hl,bc
ex de,hl
jr nz,scm22

pop hl
pop bc
inc de
dec bc
ld a,b
or c
jr nz,scm2
or a
ret

scm22:
pop hl
pop bc
scf
ret

;; check upper nibble is masked with 0x0fs
;; check lower nibble is not masked
pal_mask:
di


call asic_enable

ld bc,&7fb8
out (c),c

ld ix,result_buffer
ld hl,&6400
ld b,32
pm1:
call write_pal_byte1
ld a,0
jr nc,pm2
ld a,1
pm2:
ld (ix+0),0
inc ix
ld (ix+0),0
inc ix
inc hl
inc hl
djnz pm1

ld hl,&6401
ld b,32
pm3:
call check_mask_0f
ld a,0
jr nc,pm4
ld a,1
pm4:
ld (ix+0),0
inc ix
ld (ix+0),0
inc ix
inc hl
inc hl
djnz pm3
call restore_colours

call restore_asic

ei
ld ix,result_buffer
ld bc,32*2
jp simple_results




;; check all masked with 0x0ff
write_pal_byte1:
ld a,0
wpb1:
ld (hl),a
cp (hl)
jr nz,wpb2
inc a
jr nz,wpb1
or a
ret
wpb2:
scf
ret

;; check all bytes masked with 0x0f
check_mask_0f:
push de
push hl
push af

ld d,0
wpb21:
ld (hl),d
ld a,d
and &f
cp (hl)
jr nz,wpb22
inc d
ld a,d
or a
jr nz,wpb21
pop af
pop hl
pop de
or a
ret

wpb22:
pop af
pop hl
pop de
scf
ret



;; check written sprite values are masked with 0x0f
sprite_ram_mask:
di
call asic_enable

ld bc,&7fb8
out (c),c
ld ix,result_buffer
ld hl,&4000
ld bc,16*256
srm1:
call check_mask_0f
ld a,0
jr nc,srm2
ld a,1
srm2:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
inc hl
dec bc
ld a,b
or c
jr nz,srm1


call restore_asic

ei
ld ix,result_buffer
ld bc,16*256
jp simple_results



;; check writing cpc pen updates plus ram
cpc_pen_set:
ld c,0
jr cpsa

;; check writing cpc pen updates plus ram
cpc_pen_set2:
ld c,%00100000
jr cpsa

cpsa:
di
push bc
call asic_enable

ld bc,&7fb8
out (c),c
pop bc

ld b,16
ld ix,result_buffer
cps1aa:
ld (ix+1),&66
inc ix
inc ix
ld (ix+1),&06
inc ix
inc ix
inc ix
inc ix
djnz cps1aa

ld b,16
ld ix,result_buffer
cps1:
push bc
push bc
call reset_colours
pop bc
;; sel pen
ld b,&7f
out (c),c
ld a,&40
out (c),a

ld h,&64
ld a,c
and &f
add a,a
ld l,a
call read_col

ld a,c
and &f
ld c,a

call check_other_cols_not_set
ld a,0
jr nc,cps2
ld a,1
cps2:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop bc
inc c
djnz cps1
call restore_colours

call restore_asic

ei
ld ix,result_buffer
ld bc,16*3
jp simple_results


;; check writing cpc border updates plus ram
cpc_border_set:
ld c,16
jr cbsa

;; check writing cpc border updates plus ram
cpc_border_set2:
ld c,%00100000+16
jr cbsa

cbsa:
di
push bc
call asic_enable

ld bc,&7fb8
out (c),c
pop bc

ld b,16
ld ix,result_buffer
cbs1aa:
ld (ix+1),&66
inc ix
inc ix
ld (ix+1),&06
inc ix
inc ix
inc ix
inc ix
djnz cbs1aa

ld ix,result_buffer
ld b,16
cbs1:
push bc
push bc
call reset_colours
pop bc

;; sel pen
ld b,&7f
out (c),c
ld a,&40
out (c),a

ld hl,&6420 ;; border colour
call read_col

ld a,c
and &10
ld c,a
call check_other_cols_not_set
ld a,0
jr nc,cbs2
ld a,1
cbs2:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop bc
inc c
djnz cbs1
call restore_colours

call restore_asic

ei
ld ix,result_buffer
ld bc,16*3
jp simple_results



cpc_colour_set:
ld e,%01000000
jr ccsa

cpc_colour_set2:
ld e,%01100000
jr ccsa

ccsa:
di
push bc
call asic_enable

ld bc,&7fb8
out (c),c
pop bc

ld ix,result_buffer
push ix
ld hl,cpc_col_val
ld b,32*2
ccsa1:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
djnz ccsa1
pop ix


ld bc,&7f00
out (c),c
ld hl,&6400
ld d,32
ccs:
out (c),e
call read_col
inc e
dec d
jr nz,ccs

call restore_asic

call restore_colours
ei
ld ix,result_buffer
ld bc,32*2
jp simple_results


cpc_col_val:
defw &0666
defw &0666
defw &0f06
defw &0ff6
defw &0006
defw &00f6
defw &0606
defw &06f6
defw &00f6
defw &0ff6
defw &0ff0
defw &0fff
defw &00f0
defw &00ff
defw &006f0
defw &06ff
defw &0006
defw &0f06
defw &0f00
defw &0f0f
defw &0000
defw &000f
defw &0600
defw &060f
defw &0066
defw &0f66
defw &0f60
defw &0f6f
defw &0060
defw &006f
defw &0660
defw &066f

check_other_cols_not_set:
push hl
push bc
push af
ld hl,&6400
ld b,0
cocns1:
ld a,b
cp c
jr nz,cocns2
inc hl
inc hl
jr cocns3
cocns2:
ld a,(hl)
inc hl
or (hl)
inc hl
jr nz,cocns4

cocns3:
inc b
ld a,b
cp 32
jr nz,cocns1
pop af
pop bc
pop hl
or a
ret

cocns4:
pop af
pop bc
pop hl
scf
ret

in_set_col:
di
push bc
call asic_enable

ld bc,&7fb8
out (c),c
pop bc

ld ix,result_buffer
ld hl,in_cols
ld b,6*2
isc1:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
inc hl
djnz isc1
ld hl,cpc_col_val
ld b,32*2
isc122:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
inc hl
djnz isc122

ld ix,result_buffer
ld hl,&6400
ld a,&40
ld b,&40
ld c,&40

ld hl,&6400
ld bc,&7f00
out (c),c
in a,(c)			;; 78
call read_col
ld hl,&6400
ld bc,&7f00
out (c),c
in d,(c)			;; 50
call read_col
ld hl,&6400
ld bc,&7f00
out (c),c
in e,(c)			;; 58
call read_col
;;ld hl,&6400
;;ld bc,&7f00
;;out (c),c
;;in h,(c)			;; 60 !!
;;call read_col
;;ld hl,&6400
;;ld bc,&7f00
;;out (c),c
;;in l,(c)			;; 68 !!
;;call read_col
ld hl,&6400
ld bc,&7f00
out (c),c
in c,(c)			;; 48	
call read_col
ld hl,&6400
ld bc,&7f00
out (c),c
defb &ed,&70		;; 70
call read_col
ld hl,&6400
ld bc,&7f00
out (c),c
in b,(c)			;; 40	
call read_col

ld hl,&6400
ld bc,&7f00
out (c),c

ld a,&40
ld b,32
isc2:
push bc
push af
ld (in_inst+1),a
ld a,&7f
in_inst:
in a,(0)
call read_col
pop af
pop bc
inc a
djnz isc2

call restore_asic

call restore_colours
ei
ld ix,result_buffer
ld bc,2*(6+32)
jp simple_results


in_cols:
defw &0066
defw &0006
defw &0066
;;defw &0000		;; unstable ??
;;defw &7e7e		;; unstable???
defw &00f6	;; 00
defw &0006
defw &0666

read_col:
ld a,(hl)
ld (ix+0),a
inc ix
inc ix
inc hl
ld a,(hl)
ld (ix+0),a
dec hl
inc ix
inc ix
ret

reset_colours:
ld hl,&6400
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,32*2-1
ldir
ret

restore_colours:
ld hl,0
ld (&6400),hl
ld hl,&fff
ld (&6402),hl
ld hl,0
ld (&6420),hl
ret


;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/hw/asic.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"
include "../lib/int.asm"

result_buffer: equ $

end start
