;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

;; cpc  tester 
org &8000
start:

;;raster int test needed

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

tests:
DEFINE_TEST "CPC MRER mode and rom register (bit 5=0)",cpc_mode_setl
DEFINE_TEST "CPC MRER mode and rom register (bit 5=1)",cpc_mode_setl2
;; type 4: 0 for all 
DEFINE_TEST "CPC int (HSYNC pos)", cpc_hspos_rint
;; type 1 fails with 0 for all . type 4 0 for all
DEFINE_TEST "CPC int (HSYNC width)", cpc_hswid_rint
;; fix for type 2
;;DEFINE_TEST "int in vsync test (50hz, 60hz, delayed)",vsync_int_test
;; 
DEFINE_TEST "GA I/O decode test",ga_io_decode
DEFINE_END_TEST

cpc_hspos_rint:
di
call store_int

ld hl,&c9fb
ld (&0038),hl

ld bc,&bc03
out (c),c
ld bc,&bd00+&08
out (c),c

ld hl,hspos_jp
ld b,64-8-1
ld de,dmh_jp_end-64-8-8-8-8-4
chr1:
ld (hl),e
inc hl
ld (hl),d
inc hl
inc de
djnz chr1

ld ix,result_buffer
ld hl,hspos_jp
ld b,64-8-1
xor a
chpr:
push bc
push af
push hl
ld bc,&bc02
out (c),c
inc b
out (c),a

call do_hsync_measure

ld a,d
and &1
ld (ix+0),a
ld (ix+1),1
ld a,e
and &1
ld (ix+2),a
ld (ix+3),0
inc ix
inc ix
inc ix
inc ix
pop hl
inc hl
inc hl
pop af
inc a
pop bc
dec b
jp nz,chpr

call crtc_reset
call restore_int
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret



do_hsync_measure:
ld e,(hl)
inc hl
ld d,(hl)
ld (dhm_jp+1),de
ei
;; wait for stabalisation
call vsync_sync
call vsync_sync
call vsync_sync
call vsync_sync
;; wait for start
call wait_vsync_start
;; int within vsync
halt
;; 2 hsync from start of vsync (in theory)
di
;; wait some lines
ld a,16-3
call wait_x_lines

;; vsync
ld b,&f5
dhm_jp:
jp dmh_jp_end
defs 64*6
dmh_jp_end:
in d,(c)
in e,(c)
ret

hspos_jp:
defs 64*2

cpc_hswid_rint:
di
call store_int

ld hl,&c9fb
ld (&0038),hl

ld bc,&bc02
out (c),c
ld bc,&bd00+46
out (c),c
ld hl,hsw_jp
ld ix,result_buffer
ld b,15
ld a,1
chwr:
push bc
push af
push hl

ld bc,&bc03
out (c),c
inc b
out (c),a
call do_hsync_measure

ld a,d
and &1
ld (ix+0),a
ld (ix+1),1
ld a,e
and &1
ld (ix+2),a
ld (ix+3),0
inc ix
inc ix
inc ix
inc ix
pop hl
inc hl
inc hl
pop af
inc a
pop bc
dec b
jp nz,chwr

call crtc_reset
call restore_int
ei
ld ix,result_buffer
ld bc,15*2
call simple_results
ret

;; first at 46
;; second at 64+46.
;; 64+46+0+1+2+3
;; 64+46+1+1+2+3

;; 16 is max but closest to in
hsw_jp:
defw dmh_jp_end-46-16
defw dmh_jp_end-46-15
defw dmh_jp_end-46-14
defw dmh_jp_end-46-13
defw dmh_jp_end-46-12
defw dmh_jp_end-46-11
defw dmh_jp_end-46-10
defw dmh_jp_end-46-9
defw dmh_jp_end-46-8
defw dmh_jp_end-46-7
defw dmh_jp_end-46-6
defw dmh_jp_end-46-5
defw dmh_jp_end-46-4
defw dmh_jp_end-46-3
defw dmh_jp_end-46-2
defw dmh_jp_end-46-1

;;------------------------

vsync_int_test:
ld ix,result_buffer

call store_int

di
ld a,&c3
ld hl,int_vsync_test
ld (&0038),a
ld (&0039),hl
ei

ld hl,crtc_50hz
call set_crtc

;; check there is an int in vsync

call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end

di
xor a
ld (seen_int_vsync),a
ei
call wait_vsync_start
call wait_vsync_end
di
ld a,(seen_int_vsync)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

ld hl,crtc_60hz
call set_crtc

;; check there is an int in vsync

call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end

di
xor a
ld (seen_int_vsync),a
call wait_vsync_start
call wait_vsync_end
di
ld a,(seen_int_vsync)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld hl,crtc_50hz
call set_crtc


ld e,16
wvi:
ei
;; wait for a few vsync to stabalise it
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end
call wait_vsync_start
call wait_vsync_end

;; now do the delay
call wait_vsync_start
;; halt after vsync
halt		;; +2
halt		;; +54
halt		;; +106
halt		;; +158
halt		;; +210
halt		;; +262
di
ld a,32
call wait_x_lines
xor a
ld (seen_int_vsync),a
ei
call wait_vsync_start
call wait_vsync_end
di
ld a,(seen_int_vsync)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
dec e
jp nz,wvi

call restore_int
ei
ld ix,result_buffer
ld bc,16
call simple_results
ret


int_vsync_test:
push af
push bc
ld b,&f5
in a,(c)
rra
jr nc,ivt
ld a,1
ld (seen_int_vsync),a
ivt:
pop bc
pop af
ei
ret

seen_int_vsync:
defb 0

ga_io_decode:
ld de,&c000
ld hl,&7fff
ld ix,ga_io_decode_action
ld iy,ga_io_decode_init
jp io_decode

ga_io_decode_init:
ld bc,&df00
out (c),c
ld bc,&7f00+%10000010
out (c),c
ld a,(&1000)
ld (val_1000+1),a
ld a,(&d000)
ld (val_d000+1),a
ret

ga_io_decode_action:
ld a,%10000010
out (c),a
push bc
ld bc,&df00
out (c),c
pop bc
ld a,(&1000)
val_1000:
cp 0
ret nz
ld a,(&d000)
val_d000:
cp 0
ret nz
ret

ga_io_restore_extra:
ret

cpc_mode_setl:
ld d,%00000000
ld e,0
jp cpc_mode_set

cpc_mode_setl2:
ld d,%00100000
ld e,0
jp cpc_mode_set

lower_byte:
defb 0
upper_byte:
defb 0

setup:
ld bc,&7f00+%10000000
out (c),c
ld bc,&df00
out (c),c
ld a,(&1000)
ld (lower_byte),a
ld a,(&d000)
ld (upper_byte),a
ld bc,&7f00+%10001100
out (c),c
ret

cpc_mode_set:
di
call setup

ld ix,result_buffer

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

ei

ld ix,result_buffer
ld bc,6
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
include "../lib/int.asm"
include "../lib/hw/crtc.asm"
include "../lib/portdec.asm"
include "../lib/hw/cpc.asm"

result_buffer: equ $

end start
