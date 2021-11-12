;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; use this to test i register


include "../lib/testdef.asm"
org &4000

rtest macro testtext, count, val
db    testtext, 0
db 		count
db 	val
endm


start:
call cls

call do_rtests
call &bb06
ret

do_rtests:

ld hl,int_test
call output_msg
ld a,'-'
call output_char


;; setup for im2
ld hl,&a000
ld e,l
ld d,h
inc de
ld (hl),&a1
ld bc,257
ldir

;; setup vector
ld a,&c3
ld (&a1a1),a
ld hl,int_rout
ld (&a1a2),hl

xor a
ld (int_success),a

ld a,&a0
ld i,a

call delay_int
im 2

ei
halt			;; 1 iteration of halt to be done
ld a,(int_success)
ld c,1
im 1
call check_i_result


ld hl,iff_1
call output_msg
ld a,'-'
call output_char
di
call get_iff2
ld c,%0
call check_i_result

ld hl,iff_2
call output_msg
ld a,'-'
call output_char

ei
call get_iff2
ld c,%100
call check_i_result


ld hl,iff_3
call output_msg
ld a,'-'
call output_char
ei
nop
call get_iff2
ld c,%100
call check_i_result

ei
;; check all values for I
ld b,0
xor a
dr1:
push af
push bc

push af
push bc

call outputhex8
ld a,'-'
call output_char
pop bc
pop af


ld c,a
call check_i

pop bc
pop af
inc a
djnz dr1

scr_cnt equ &4000/&100

main_cnt equ &a600/&100

ld hl,&00ff
ld bc,main_cnt
cim2la:
push hl
push bc
call test_im2
pop bc
pop hl
inc h
dec bc
ld a,b
or c
jr nz,cim2la


ld hl,&c0ff
ld bc,scr_cnt
cim2l:
push hl
push bc
call test_im2
pop bc
pop hl
inc h
dec bc
ld a,b
or c
jr nz,cim2l



ret

test_im2:

push hl
ld a,h
call outputhex8
ld a,'-'
call output_char
pop hl

push hl
ld (hl),&a1
inc hl
ld (hl),&a1
pop hl

di
ld a,h
ld i,a
im 2

xor a
ld (int_success),a

ei
halt
ld a,(int_success)
ld c,1
im 1
call check_i_result
ret


int_success:
defb 0

int_rout:
push af
ld a,1
ld (int_success),a
pop af
ei
reti

set_int:
ld a,(&0038)
ld (store_int),a
ld hl,(&0039)
ld (store_int+1),hl

ld hl,&c9fb
ld (&0038),hl
ret

iff_1:
defb "DI & IFF2",0
iff_2:
defb "EI & IFF2",0
iff_3:
defb "EI: NOP & IFF2",0

int_test:
defb "(IM2) Int test",0


get_iff2:
ld a,i
push af
pop hl
ld a,l
and %100
ret

restore_int:
di
push af
push hl
ld a,(store_int+0)
ld (&0038),a
ld hl,(store_int+1)
ld (&0039),hl
pop hl
pop af
ei
ret

store_int:
defs 3

check_i:
di
ld i,a
ld a,i
ei
check_i_result:
cp c
jp z,check_i2
push af
push bc
call report_negative
pop bc
pop af
ld b,a
call report_got_wanted
ret


check_i2:
call report_positive
ret


delay_int:
ei
ld b,&f5
din:
in a,(c)
rra
jr nc,din
halt
halt
halt
di
ld b,&f5
din2:
in a,(c)
rra
jr nc,din2
ret



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

end start
