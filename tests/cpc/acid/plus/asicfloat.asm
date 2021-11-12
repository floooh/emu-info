;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; Write through doesn't happen on unmapped
;; Write through doesn't happen on mapped
;; almost last byte on the bus read when unmapped
;; almost last byte on the bus read for some write only registers
include "../lib/testdef.asm"

org &8000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;;-----------------------------------------------------
tests:



DEFINE_TEST "asic ram float (5000-50ff)",asic_5000_ram_float_ff
DEFINE_TEST "asic ram float (5100-51ff)",asic_5100_ram_float_ff
DEFINE_TEST "asic ram float (5200-52ff)",asic_5200_ram_float_ff
DEFINE_TEST "asic ram float (5300-53ff)",asic_5300_ram_float_ff
DEFINE_TEST "asic ram float (5400-54ff)",asic_5400_ram_float_ff
DEFINE_TEST "asic ram float (5500-55ff)",asic_5500_ram_float_ff
DEFINE_TEST "asic ram float (5600-56ff)",asic_5600_ram_float_ff
DEFINE_TEST "asic ram float (5500-55ff)",asic_5500_ram_float_ff
DEFINE_TEST "asic ram float (5800-58ff)",asic_5800_ram_float_ff
DEFINE_TEST "asic ram float (5900-59ff)",asic_5900_ram_float_ff
DEFINE_TEST "asic ram float (5a00-5aff)",asic_5a00_ram_float_ff
DEFINE_TEST "asic ram float (5b00-5bff)",asic_5b00_ram_float_ff
DEFINE_TEST "asic ram float (5c00-5cff)",asic_5c00_ram_float_ff
DEFINE_TEST "asic ram float (5d00-5dff)",asic_5d00_ram_float_ff
DEFINE_TEST "asic ram float (5e00-5eff)",asic_5e00_ram_float_ff
DEFINE_TEST "asic ram float (5f00-5fff)",asic_5f00_ram_float_ff


DEFINE_TEST "asic ram float (6080-60ff)",asic_6080_ram_float_ff

DEFINE_TEST "asic ram float (6100-61ff)",asic_6100_ram_float_ff
DEFINE_TEST "asic ram float (6200-62ff)",asic_6200_ram_float_ff
DEFINE_TEST "asic ram float (6300-63ff)",asic_6300_ram_float_ff

DEFINE_TEST "asic ram float (6440-64ff)",asic_6440_ram_float_ff

DEFINE_TEST "asic ram float (6500-65ff)",asic_6500_ram_float_ff
DEFINE_TEST "asic ram float (6600-66ff)",asic_6600_ram_float_ff

DEFINE_TEST "asic ram float (6700-67ff)",asic_6700_ram_float_ff

DEFINE_TEST "asic ram float (6700-67ff)",asic_6810_ram_float_ff

DEFINE_TEST "asic ram float (6900-69ff)",asic_6900_ram_float_ff
DEFINE_TEST "asic ram float (6a00-6aff)",asic_6a00_ram_float_ff
DEFINE_TEST "asic ram float (6b00-6bff)",asic_6b00_ram_float_ff

DEFINE_TEST "asic ram float (6c10-6cff)", asic_6c10_ram_float_ff

DEFINE_TEST "asic ram float (6d00-6dff)",asic_6d00_ram_float_ff
DEFINE_TEST "asic ram float (6e00-6eff)",asic_6e00_ram_float_ff
DEFINE_TEST "asic ram float (6f00-6fff)",asic_6f00_ram_float_ff


DEFINE_TEST "asic ram float (7000-70ff)",asic_7000_ram_float_ff
DEFINE_TEST "asic ram float (7100-71ff)",asic_7100_ram_float_ff
DEFINE_TEST "asic ram float (7200-72ff)",asic_7200_ram_float_ff
DEFINE_TEST "asic ram float (7300-73ff)",asic_7300_ram_float_ff
DEFINE_TEST "asic ram float (7400-74ff)",asic_7400_ram_float_ff
DEFINE_TEST "asic ram float (7500-75ff)",asic_7500_ram_float_ff
DEFINE_TEST "asic ram float (7600-76ff)",asic_7600_ram_float_ff
DEFINE_TEST "asic ram float (7700-77ff)",asic_7700_ram_float_ff
DEFINE_TEST "asic ram float (7800-78ff)",asic_7800_ram_float_ff
DEFINE_TEST "asic ram float (7900-79ff)",asic_7900_ram_float_ff
DEFINE_TEST "asic ram float (7a00-7aff)",asic_7a00_ram_float_ff
DEFINE_TEST "asic ram float (7b00-7bff)",asic_7b00_ram_float_ff
DEFINE_TEST "asic ram float (7c00-7cff)",asic_7c00_ram_float_ff
DEFINE_TEST "asic ram float (7d00-7dff)",asic_7d00_ram_float_ff
DEFINE_TEST "asic ram float (7e00-7eff)",asic_7e00_ram_float_ff
DEFINE_TEST "asic ram float (7f00-7fff)",asic_7f00_ram_float_ff

DEFINE_TEST "asic write through (&5000)",asic_ram_writethrough_5000
DEFINE_TEST "asic write through (&4000)",asic_ram_writethrough_4000
DEFINE_TEST "asic write through (&7fff)",asic_ram_writethrough_7fff

DEFINE_TEST "asic ram float (&6800)", asic_ram_float_6800
DEFINE_TEST "asic ram float (&6801)", asic_ram_float_6801
DEFINE_TEST "asic ram float (&6802)", asic_ram_float_6802
DEFINE_TEST "asic ram float (&6803)", asic_ram_float_6803
DEFINE_TEST "asic ram float (&6804)", asic_ram_float_6804
DEFINE_TEST "asic ram float (&6805)", asic_ram_float_6805
DEFINE_TEST "asic ram float (&6806)", asic_ram_float_6806

;; probably reading 6808 too?
;;DEFINE_TEST "asic ram float (&6807)", asic_ram_float_6807 ;; got 7e

DEFINE_END_TEST

asic_6100_ram_float_ff:
ld hl,&6100
jp asic_ram_float_ff

asic_6200_ram_float_ff:
ld hl,&6200
jp asic_ram_float_ff

asic_6300_ram_float_ff:
ld hl,&6300
jp asic_ram_float_ff


asic_6500_ram_float_ff:
ld hl,&6500
jp asic_ram_float_ff

asic_6600_ram_float_ff:
ld hl,&6600
jp asic_ram_float_ff

asic_6700_ram_float_ff:
ld hl,&6700
jp asic_ram_float_ff


asic_6900_ram_float_ff:
ld hl,&6900
jp asic_ram_float_ff

asic_6a00_ram_float_ff:
ld hl,&6a00
jp asic_ram_float_ff

asic_6b00_ram_float_ff:
ld hl,&6b00
jp asic_ram_float_ff

asic_6c00_ram_float_ff:
ld hl,&6c00
jp asic_ram_float_ff

asic_6d00_ram_float_ff:
ld hl,&6d00
jp asic_ram_float_ff

asic_6e00_ram_float_ff:
ld hl,&6e00
jp asic_ram_float_ff

asic_6f00_ram_float_ff:
ld hl,&6f00
jp asic_ram_float_ff




asic_7000_ram_float_ff:
ld hl,&7000
jp asic_ram_float_ff

asic_7100_ram_float_ff:
ld hl,&7100
jp asic_ram_float_ff

asic_7200_ram_float_ff:
ld hl,&7200
jp asic_ram_float_ff

asic_7300_ram_float_ff:
ld hl,&7300
jp asic_ram_float_ff

asic_7400_ram_float_ff:
ld hl,&7400
jp asic_ram_float_ff

asic_7500_ram_float_ff:
ld hl,&7500
jp asic_ram_float_ff

asic_7600_ram_float_ff:
ld hl,&7600
jp asic_ram_float_ff

asic_7700_ram_float_ff:
ld hl,&7700
jp asic_ram_float_ff

asic_7800_ram_float_ff:
ld hl,&7800
jp asic_ram_float_ff

asic_7900_ram_float_ff:
ld hl,&7900
jp asic_ram_float_ff

asic_7a00_ram_float_ff:
ld hl,&7a00
jp asic_ram_float_ff

asic_7b00_ram_float_ff:
ld hl,&7b00
jp asic_ram_float_ff

asic_7c00_ram_float_ff:
ld hl,&7c00
jp asic_ram_float_ff

asic_7d00_ram_float_ff:
ld hl,&7d00
jp asic_ram_float_ff

asic_7e00_ram_float_ff:
ld hl,&7e00
jp asic_ram_float_ff

asic_7f00_ram_float_ff:
ld hl,&7f00
jp asic_ram_float_ff



asic_5000_ram_float_ff:
ld hl,&5000
jp asic_ram_float_ff

asic_5100_ram_float_ff:
ld hl,&5100
jp asic_ram_float_ff

asic_5200_ram_float_ff:
ld hl,&5200
jp asic_ram_float_ff

asic_5300_ram_float_ff:
ld hl,&5300
jp asic_ram_float_ff

asic_5400_ram_float_ff:
ld hl,&5400
jp asic_ram_float_ff

asic_5500_ram_float_ff:
ld hl,&5500
jp asic_ram_float_ff

asic_5600_ram_float_ff:
ld hl,&5600
jp asic_ram_float_ff

asic_5700_ram_float_ff:
ld hl,&5700
jp asic_ram_float_ff

asic_5800_ram_float_ff:
ld hl,&5800
jp asic_ram_float_ff

asic_5900_ram_float_ff:
ld hl,&5900
jp asic_ram_float_ff

asic_5a00_ram_float_ff:
ld hl,&5a00
jp asic_ram_float_ff

asic_5b00_ram_float_ff:
ld hl,&5b00
jp asic_ram_float_ff

asic_5c00_ram_float_ff:
ld hl,&5c00
jp asic_ram_float_ff

asic_5d00_ram_float_ff:
ld hl,&5d00
jp asic_ram_float_ff

asic_5e00_ram_float_ff:
ld hl,&5e00
jp asic_ram_float_ff

asic_5f00_ram_float_ff:
ld hl,&5f00
jp asic_ram_float_ff




asic_ram_float_6800:
ld hl,&6800
jp asic_ram_float

asic_ram_float_6801:
ld hl,&6801
jp asic_ram_float

asic_ram_float_6802:
ld hl,&6802
jp asic_ram_float

asic_ram_float_6803:
ld hl,&6803
jp asic_ram_float

asic_ram_float_6804:
ld hl,&6804
jp asic_ram_float

asic_ram_float_6805:
ld hl,&6805
jp asic_ram_float


asic_ram_float_6806:
ld hl,&6806
jp asic_ram_float

asic_ram_float_6807:
ld hl,&6807
jp asic_ram_float_special

asic_ram_float_6808:
ld hl,&6808
jp asic_ram_float_special

asic_ram_float_6809:
ld hl,&6809
jp asic_ram_float_special

asic_ram_float_680a:
ld hl,&680a
jp asic_ram_float_special

asic_ram_float_680b:
ld hl,&680b
jp asic_ram_float_special

asic_ram_float_680c:
ld hl,&680c
jp asic_ram_float_special

asic_ram_float_680d:
ld hl,&680d
jp asic_ram_float_special

asic_ram_float_680e:
ld hl,&680e
jp asic_ram_float_special

asic_ram_float_680f:
ld hl,&680f
jp asic_ram_float_special


asic_ram_writethrough_5000:
ld hl,&5000
jp asic_ram_writethrough

asic_ram_writethrough_4000:
ld hl,&4000
jp asic_ram_writethrough

asic_ram_writethrough_7fff:
ld hl,&7fff
jp asic_ram_writethrough

asic_ram_writethrough:
push hl

call asic_enable
call asic_ram_disable

ld ix,result_buffer
pop hl
di

xor a
ld b,0
arw1:
push af
push bc
push hl


ld b,a

;; in main ram
cpl
ld (hl),a	;; complemented value
ld c,a

push bc
push hl
call asic_ram_enable
pop hl
pop bc
ld (hl),b		;; actual value
push bc
push hl
call asic_ram_disable
pop hl
pop bc
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),c
inc ix

pop hl
pop bc
pop af
inc a
djnz arw1

call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

asic_ram_float_ff:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
ld b,255		;; 255 because ld bc,(nnnn) etc read from e.g. 6fff+1
arff1:
push hl
push bc
call byte_asic_ram_float
pop bc
pop hl
inc hl
djnz arff1
call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,10*255
call simple_results
ret

asic_6c10_ram_float_ff:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
ld hl,&6c10
ld b,&100-&10
arff12:
push hl
push bc
call byte_asic_ram_float
pop bc
pop hl
inc hl
djnz arff12
call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,10*(&100-&10)
call simple_results
ret

asic_6440_ram_float_ff:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
ld hl,&6440
ld b,&100-&40
arff13:
push hl
push bc
call byte_asic_ram_float
pop bc
pop hl
inc hl
djnz arff13
call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,10*(&100-&40)
call simple_results
ret

asic_6810_ram_float_ff:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
ld hl,&6810
ld b,&100-&10
arff14:
push hl
push bc
call byte_asic_ram_float
pop bc
pop hl
inc hl
djnz arff14
call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,10*(&100-&10)
call simple_results
ret


asic_6080_ram_float_ff:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
ld hl,&6080
ld b,&100-&80
arff15:
push hl
push bc
call byte_asic_ram_float
pop bc
pop hl
inc hl
djnz arff15
call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,10*(&100-&80)
call simple_results
ret

;;-----------------------------------------------------
asic_ram_float:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
di

call byte_asic_ram_float

call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,10
call simple_results
ret

byte_asic_ram_float:
;;ld ix,(xxxx)
;;ld iy,(xxxx)
;;or (hl)
;;or (ix+d)
;;or (iy+d)
;;pop af
;;pop bc
;;pop de
;;pop hl
;;pop ix
;;pop iy

ld (ad+1),hl
ld (hld+1),hl
ld (ded+2),hl
ld (bcd+2),hl

;; unmapped areas are last byte on the bus
ld e,l
ld d,h
ld c,l
ld b,h

;; tested:
;; ld a,(hl)
;; ld a,(de)
;; ld a,(bc)
;; ld a,(nnnn)
;; ld hl,(nnnn)
;; ld de,(nnnn)
;; ld bc,(nnnn)
;; ld a,(ix+n)	;; can't test, causes a read outside of addr
;; ld a,(iy+n)	;; can't test, causes a read outside of addr

l1:
ld a,(hl)		;; 7e
ld (ix+0),a
inc ix
ld a,(l1)
ld (ix+0),a
inc ix

l2:
ld a,(de)		;; 1a
ld (ix+0),a
inc ix
ld a,(l2)
ld (ix+0),a
inc ix

l3:
ld a,(bc)		;; 0a
ld (ix+0),a
inc ix
ld a,(l3)
ld (ix+0),a
inc ix

;; 3a 00 50
ad:
ld a,(&6000)	;; last byte addr
ld (ix+0),a
inc ix
ld a,(ad+2)
ld (ix+0),a
inc ix

;; 2a 00 50
hld:
ld hl,(&6000)	;; last byte addr
ld (ix+0),l
inc ix
ld a,(hld+2)
ld (ix+0),a
inc ix
ld (ix+0),h	;; last byte addr
inc ix
ld a,(hld+2)
ld (ix+0),a
inc ix

;; ed xx 00 50
ded:
ld de,(&6000)	
ld (ix+0),e
inc ix
ld a,(ded+3)
ld (ix+0),a
inc ix
ld (ix+0),d	
inc ix
ld a,(ded+3)
ld (ix+0),a
inc ix

;; ed xx 00 00 
bcd:
ld bc,(&6000)
ld (ix+0),c
inc ix
ld a,(bcd+3)		;; 00
ld (ix+0),a
inc ix
ld (ix+0),b
inc ix
ld a,(bcd+3)		;; 00
ld (ix+0),a
inc ix
ret

;;-----------------------------------------------------
asic_ram_float_special:
push hl
call asic_enable
call asic_ram_enable
pop hl
ld ix,result_buffer
di

push hl
pop iy
ld b,0
l5a:
ld a,(hl)
ld (ix+0),a
inc ix
ld a,(l5a+2)
ld (ix+0),a
inc ix
djnz l5a

call asic_ram_disable
call asic_disable

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

asic_ram_enable:
ld bc,&7fb8
out (c),c
ret

asic_ram_disable:
ld bc,&7fa0
out (c),c
ret


asic_enable:
  call asic_w_seq
	ld a,&ee
	out (c),a
	ret
asic_disable:
  call asic_w_seq
  ld a,&ae
  out (c),a
  ret
  
asic_w_seq:
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,16

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
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
include "../lib/int.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $

end start
