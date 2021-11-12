;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../lib/testdef.asm"

;; crtc type 1 status tester; run after power on/off
org &2000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;; HD6845R: succeed, fail, succeed, failed

;;-----------------------------------------------------

tests:
;; check status is set (requires power on)
DEFINE_TEST "type 1 status (lpen)", type1_status_lpen
;; read register 17/16 to clear lpen status
DEFINE_TEST "type 1 status (clear lpen)", type1_status_clear_lpen
;; check value read from 17/16 is 0 (it is on my cpc)
DEFINE_TEST "type 1 lpen after power on/off", type1_lpen_reset
;; check unused bits remain at 0
DEFINE_TEST "type 1 status (unused)", type1_status_unused

;; vblank = vdisp
DEFINE_TEST "type 1 status vertical blanking", type1_status_vblank


DEFINE_END_TEST



int_store:
defs 3

;; seems to be reported for 32 lines?
type1_status_vblank:
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
defs 64*2

ld de,200
tsv3:
ld b,&be		;; [2]
in a,(c)		;; [4]
and &20		;; [2]
ld (ix+0),a	;; [5]
inc ix		;; [3]
ld (ix+0),0	;; [6]
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
and &20		;; [2]
ld (ix+0),a	;; [5]??
inc ix		;; [3]
ld (ix+0),&20	;; [6]??
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



ld b,&f5
t1sv:
in a,(c)
rra
jr nc,t1sv
ld b,&be
in a,(c)
and &20
ld (ix+0),a
inc ix
ld (ix+0),&20
inc ix
ld b,&f5
t2sv:
in a,(c)
rra
jr c,t2sv
defs 64

ld b,&be
in a,(c)
and &20
ld (ix+0),a
inc ix
ld (ix+0),&00		;; says &0x020
inc ix

ei
ld ix,result_buffer
ld bc,2
call simple_results
ret

type1_status_unused:
di
ld ix,result_buffer

ld de,512
tsu1:
ld b,&be				
in a,(c)	
and %10011111
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix
defs 64

dec de
ld a,d
or e
jr nz,tsu1

ei
ld ix,result_buffer
ld bc,512
call simple_results
ret


type1_status_lpen:
di
ld ix,result_buffer

ld e,16
ts1:
ld b,&be				
in a,(c)	
and &40
ld (ix+0),a
inc ix
ld (ix+0),&40
inc ix
dec e
jr nz,ts1

ei
ld ix,result_buffer
ld bc,16
call simple_results
ret


type1_status_clear_lpen:
di
ld ix,result_buffer

ld b,&be				
in a,(c)		
and &40
ld (ix+0),a
inc ix
ld (ix+0),&40
inc ix

ld bc,&bc00+16
out (c),c
ld b,&bf
in a,(c)

ld b,&be
in a,(c)				
and &40
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix

ld bc,&bc00+17
out (c),c
ld b,&bf
in a,(c)
ld b,&be
in a,(c)	
and &40
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix


ei
ld ix,result_buffer
ld bc,3
call simple_results
ret



type1_lpen_reset:
di
ld ix,result_buffer

ld bc,&bc00+17
out (c),c
ld b,&bf
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix

ld bc,&bc00+16
out (c),c
ld b,&bf
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix
ei
ld ix,result_buffer
ld bc,2
call simple_results
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

