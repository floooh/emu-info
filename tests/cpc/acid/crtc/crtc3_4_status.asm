;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; 
;; type 3 and 4 status tester
include "../lib/testdef.asm"

org &4000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret


;;-----------------------------------------------------

tests:
DEFINE_TEST "RC==0 and RC==MR",rc_eq_mr
;; on type 4 failed with 40 all
DEFINE_TEST "VBlank",status_vblank
;; failed 4 times, remainder ok, type 4 does same
DEFINE_TEST "Vsync end",vsync_end
;; succeed type 4.
DEFINE_TEST "Cursor flash rate",cursor_flash

;; ok, then failed.type 4 the same
DEFINE_TEST "Cursor active on scanline",cursor_scanline
DEFINE_END_TEST

vsync_end:
di
ld ix,result_buffer
ld b,16
xor a
vse1:
push bc
push af

push af
;; set vsync length
ld bc,&bc03
out (c),c
add a,a
add a,a
add a,a
add a,a
or &8
inc b
out (c),a

call vsync_sync
call vsync_sync

ld a,2
ld de,312*4
call read_status_lines

pop af
cp 0
jr nz,vse1a
ld a,16
vse1a:
dec a
ld d,a

;; check repeat every 312 lines (number of lines in frame)
ld b,4
ld hl,status_buffer
vse6:
push bc
push hl

ld e,0
ld b,32
vse2:
;; expected value
ld a,e
cp d
ld c,%00100000
jr nz,vse3
ld c,%00000000
vse3:
;; get actual
ld a,(hl)
and %00100000
cp c
ld a,1	;; error
jr nz,vse5
inc e
inc hl
djnz vse2
xor a	;; ok
vse5:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop hl
ld bc,312
add hl,bc
pop bc
dec b
jp nz,vse6



pop af
inc a
pop bc
dec b
jp nz,vse1

call crtc_reset
ei
ld ix,result_buffer
ld bc,16*4
call simple_results
ret

cursor_flash:
di
ld ix,result_buffer

ld bc,&bc00+10
out (c),c
ld bc,&bd00+%00000000
out (c),c

call get_results


ld bc,&bc00+10
out (c),c
ld bc,&bd00+%00100000
out (c),c

call get_results

ld bc,&bc00+10
out (c),c
ld bc,&bd00+%01000000
out (c),c

call get_results

ld bc,&bc00+10
out (c),c
ld bc,&bd00+%01100000
out (c),c
call get_results

call crtc_reset

ei

ld ix,result_buffer
ld bc,4*3
call simple_results


ret

get_results:
ld a,3
ld de,256
call read_status_frames

ld bc,256
ld d,%1000
call test_changes
ld a,0
adc a,0
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld (ix+0),0
ld (ix+2),0
ld (ix+1),16
ld (ix+3),16

or a
jr nz,cf1
ld bc,256
ld d,%1000
call check_toggle_rate
ld a,(min)
ld (ix+0),a
ld a,(max)
ld (ix+2),a
cf1:
inc ix
inc ix
inc ix
inc ix
ret

check_toggle_rate:
ld hl,status_buffer

ld a,0
ld (setminmax),a

ld a,(hl)
defb &fd
ld h,a
dec bc
ctr1:
inc hl
dec bc
ld a,b
or c
jr z,ctr23
defb &fd
ld a,h
xor (hl)	;; next
and d		;; mask
jr z,ctr1
ld a,(hl)
defb &fd
ld h,a

;; found first changed byte
ld e,0
ctr2:
inc e
inc hl
dec bc
ld a,b
or c
jr z,ctr23
defb &fd
ld a,h
xor (hl)
and d
jr z,ctr2
ld a,(hl)
defb &fd
ld h,a

ld a,1
ld (setminmax),a
ld a,e
ld (min),a
ld (max),a

ctr22:
ld e,0
ld a,(hl)
defb &fd
ld h,a
ctr2b:
inc e
inc hl
dec bc
ld a,b
or c
jr z,ctr23
defb &fd
ld a,h
xor (hl)
and d
jr z,ctr2b

ld a,(min)
cp e
jr c,ctr2c
ld a,e
ld (min),a
ctr2c:
ld a,(max)
cp e
jr nc,ctr2d
ld a,e
ld (max),a
ctr2d:
jr ctr22

ctr23:
ret

min:
defb 0
max:
defb 0
setminmax:
defb 0


test_changes:
ld hl,status_buffer

ld a,(hl)	;; initial
inc hl
dec bc
tc1:
xor (hl)	;; next
and d		;; mask
jr nz,changes
inc hl
dec bc
ld a,b
or c
jr nz,tc1
scf
ret
changes:
or a
ret




;;-----------------------------------------------------

read_status_frames:
ld b,&bc
out (c),a
ld b,&bf
ld hl,status_buffer
s1a:
push bc
ld b,&f5
s1b:
in a,(c)
rra
jr nc,s1b
pop bc
in a,(c)
ld (hl),a
inc hl
push bc
ld b,&f5
s3b:
in a,(c)
rra
jr c,s3b
pop bc
dec de
ld a,d
or e
jr nz,s1a
ret

;;-----------------------------------------------------

read_status_lines:
ld b,&bc
out (c),a

ld b,&f5
s1:
in a,(c)
rra
jr nc,s1
ld b,&bf
ld hl,status_buffer
s2:
in a,(c)
ld (hl),a
inc hl
defs 64-2-2-4-2-1-1-3
dec de
ld a,d
or e
jp nz,s2
ret

;;-----------------------------------------------------
rc_eq_mr:
di
ld ix,result_buffer

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld a,0
ld b,32
rc_eq_mr2:
push af
push bc

push af
ld bc,&bc09
out (c),c
inc b
out (c),a

call vsync_sync
call vsync_sync

ld a,3
ld de,256
call read_status_lines
pop af
ld c,a
ld hl,status_buffer
ld b,256
ld d,0

rc_eq_mr3:
;;RC = 0
ld a,d
cp 0
ld e,%10000000
jr z,rc_eq_mr4
ld e,%00000000
rc_eq_mr4:
ld a,(hl)
and %10000000
cp e
ld a,1
jr nz,rc_eq_mr7

;; RC==MR
ld a,d
cp c
ld e,%00000000
jr z,rc_eq_mr5
ld e,%00100000
rc_eq_mr5:
ld a,(hl)
and %00100000
cp e
ld a,1
jr nz,rc_eq_mr7

ld a,d		;; get line counter
cp c		;; compare mr programmed
jr nz,rc_eq_mr6
ld d,&ff		;; reset line counter
rc_eq_mr6:
inc d
inc hl
dec b
jp nz,rc_eq_mr3
ld a,0
rc_eq_mr7:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop bc
pop af
inc a
djnz rc_eq_mr2
call crtc_reset

ld ix,result_buffer
ld bc,32
call simple_results
ret


;;-----------------------------------------------------
cursor_scanline:
di
ld ix,result_buffer

ld a,7
ld (height),a

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,32*32
ld hl,0
cs:
push bc
push hl
ld bc,&bc00+10
out (c),c
inc b
out (c),h

ld bc,&bc00+11
out (c),c
inc b
out (c),l
push hl
call vsync_sync
call vsync_sync

ld a,3
ld de,256
call read_status_lines
pop de
ld hl,status_buffer

ld b,0
ld c,0

cs1:
;; within range?
ld a,c
cp e
ld a,%00000000
jr nc,cs2
ld a,c
cp d
ld a,%00000000
jr c,cs2
ld a,%01000000
cs2:
xor (hl)
and %01000000
ld a,1
jr nz,cs4
ld a,(height)
cp c
jr nz,cs3
ld c,&ff
cs3: 
inc hl
inc c
djnz cs1
xor a
cs4:
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

pop hl
inc l
ld a,l
cp 32
jr nz,cs5
ld l,0
inc h
cs5:
pop bc
dec bc
ld a,b
or c
jp nz,cs
call crtc_reset
ei
ld ix,result_buffer
ld bc,32*32
call simple_results
ret

height:
defb 0


int_store:
defs 3

status_vblank:
defb &ed,&ff
di
ld a,(&0038)
ld (int_store),a
ld hl,(&0039)
ld (int_store+1),hl
ld hl,&c9fb
ld (&0038),hl
ei

ld ix,result_buffer

ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c

ld bc,&bc01
out (c),c
ld bc,&bd00+40
out (c),c

ld bc,&bc02
out (c),c
ld bc,&bd00+46
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+32
out (c),c

halt
halt
halt
halt
halt
halt
halt
halt
halt
halt
halt
halt


ld b,&f5
tsv1:
in a,(c)
rra
jr c,tsv1

ld b,&f5
tsv2:
in a,(c)
rra
jr nc,tsv2

halt

halt
defs 64
defs 64-3-4-1
ld bc,&bc02
out (c),c
inc b

ld de,200
tsv3:
ld b,&be		;; [2]
in a,(c)		;; [4]
and &40		;; [2]
ld (ix+0),a	;; [5]
inc ix		;; [3]
ld (ix+0),&00	;; [6]
inc ix		;; [3]
defs 64-2-4-2-2-3-3-1-1-3-5-6
dec de		;; [2]
ld a,d		;; [1]
or e			;; [1]
jp nz,tsv3	;; [3]

ld de,100
tsv4:
ld b,&be		;; [2]
in a,(c)		;; [4]
and &40		;; [2]
ld (ix+0),a	;; [5]??
inc ix		;; [3]
ld (ix+0),&40	;; [6]??
inc ix		;; [3]
defs 64-2-4-2-2-3-3-1-1-3-5-6
dec de		;; [2]
ld a,d		;; [1]
or e			;; [1]
jp nz,tsv4	;; [3]

di
ld a,(int_store)
ld (&0038),a
ld hl,(int_store+1)
ld (&0039),hl

ei
ld ix,result_buffer
ld bc,300
call simple_results
ret


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

vsync_sync:
ld b,&f5
vs1:
in a,(c)
rra
jr nc,vs1
vs2:
in a,(c)
rra 
jr c,vs2
ret

;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
include "../lib/int.asm"
;; firmware based output
include "../lib/fw/output.asm"

status_buffer: defs 312*8
result_buffer: equ $

end start
