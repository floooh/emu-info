;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

;; CPU tester 
org &8000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;;-----------------------------------------------------
;; TODO: regs
;; TODO: OUT (n),a
;; TODO: OUT (c),r
;; TODO: INI
;; TODO: IND
;; TODO: INIR
;; TODO: INDR
;; TODO: OUTI
;; TODO: OUTD
;; TODO: OTIR
;; TODO: OTDR

tests:
DEFINE_TEST "in a,(n) flags",in_a_n_test
DEFINE_TEST "in a,(c) flags",in_a_c_test
DEFINE_TEST "in b,(c) flags",in_b_c_test
DEFINE_TEST "in c,(c) flags",in_c_c_test
DEFINE_TEST "in d,(c) flags",in_d_c_test
DEFINE_TEST "in e,(c) flags",in_e_c_test
DEFINE_TEST "in h,(c) flags",in_h_c_test
DEFINE_TEST "in l,(c) flags",in_l_c_test

DEFINE_END_TEST


in_a_n_test:
di
ld ix,result_buffer
ld b,0
ld c,0
iant1:
push bc

push bc
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
pop bc
ld b,&f4
out (c),c
ld (ix+1),c

ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld bc,&f700+%10010010
out (c),c
ld bc,&f640
out (c),c
push af
pop de
ld a,&f4
in a,(&00)
push af
pop hl
ld (ix+0),a
ld (ix+2),l
ld (ix+3),e
inc ix
inc ix
inc ix
inc ix
ld bc,&f600
out (c),c
ld bc,&f700+%10000010
out (c),c

pop bc
inc c
djnz iant1
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret
 
in_a_c_test:
ld hl,in_a_c_inst
jp in_r_c_test

in_a_c_inst:
in a,(c)
ld (ix+0),a

in_b_c_test:
ld hl,in_b_c_inst
jp in_r_c_test

in_b_c_inst:
in b,(c)
ld (ix+0),b

in_c_c_test:
ld hl,in_c_c_inst
jp in_r_c_test

in_c_c_inst:
in c,(c)
ld (ix+0),c

in_d_c_test:
ld hl,in_d_c_inst
jp in_r_c_test

in_d_c_inst:
in d,(c)
ld (ix+0),d

in_e_c_test:
ld hl,in_e_c_inst
jp in_r_c_test

in_e_c_inst:
in e,(c)
ld (ix+0),e

in_h_c_test:
ld hl,in_h_c_inst
jp in_r_c_test

in_h_c_inst:
in h,(c)
ld (ix+0),h

in_l_c_test:
ld hl,in_l_c_inst
jp in_r_c_test

in_l_c_inst:
in l,(c)
ld (ix+0),l


in_r_c_test:
ld de,in_inst
ld bc,5
ldir
di
ld ix,result_buffer
ld b,0
ld c,0
irnt1:
push bc

push bc
ld bc,&f400
out (c),c
ld bc,&f6c0
out (c),c
ld bc,&f600
out (c),c
pop bc
ld b,&f4
out (c),c
ld (ix+1),c

ld bc,&f680
out (c),c
ld bc,&f600
out (c),c

ld bc,&f700+%10010010
out (c),c
ld bc,&f640
out (c),c
ld b,&f4
push af
pop de
ld a,e
ld (flags_before),a
in_inst:
in a,(c)
ld (ix+0),a
push af
pop hl
ld (ix+2),l
ld a,(ix+1)	;; expected value
xor 0
push af
pop hl
ld a,l
and &fe
ld l,a
ld a,(flags_before)
and &1
or l
ld (ix+3),a
inc ix
inc ix
inc ix
inc ix
ld bc,&f600
out (c),c
ld bc,&f700+%10000010
out (c),c

pop bc
inc c
djnz irnt1
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret

flags_before:
defb 0

;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/int.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $

end start
