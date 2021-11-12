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
call &bb06
ret

;;-----------------------------------------------------

tests:
;; on NMOS expect 0 to be written
DEFINE_TEST "cmos/nmos out (c),0 test",cmos_nmos_test
;; an emulation test, ensure emulating instructions around ffff/0000 works ok
DEFINE_TEST "execute instructions around ffff test",execute_ffff
;; an emulation test, ensure ix+offset is correct
DEFINE_TEST "Indexing offset test",index_test
;; a nmos z80 test, check that iff1/iff2 is reported accurately for ld a,r
;; and that the int acknowledge bug is seen on NMOS Z80
DEFINE_TEST "ld a,r/ld a,i p/v int test",int_pv_test
;; check stack pointer works as expected
DEFINE_TEST "stack pointer test",stack_test
;; check that repeated ei's don't trigger int servicing until the instruction after the last
;; one
DEFINE_TEST "ei repeat and delay int test",ei_delay
;; check that repeated dd's don't trigger int servicing until the instruction after the last
;; one
DEFINE_TEST "dd repeat and delay int test",dd_delay
;; check that repeated fd's don't trigger int servicing until the instruction after the last
;; one
DEFINE_TEST "fd repeat and delay int test",fd_delay
DEFINE_END_TEST

stack:
defw 0

stack_test:
di
ld (stack),sp

ld ix,result_buffer

ld sp,&c000
ld a,0
ld (&c000),a

ld hl,&4030
push hl

ld a,(&c000)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,(&bfff)
ld (ix+0),a
inc ix
ld (ix+0),&40
inc ix
ld a,(&bffe)
ld (ix+0),a
inc ix
ld (ix+0),&30
inc ix

ld sp,&bfff
ld a,0
ld (&c000),a
ld (&bfff),a
ld (&bffd),a
ld (&bffc),a
ld hl,&5060
push hl
ld a,(&c000)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,(&bfff)
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix
ld a,(&bffe)
ld (ix+0),a
inc ix
ld (ix+0),&50
inc ix
ld a,(&bffd)
ld (ix+0),a
inc ix
ld (ix+0),&60
inc ix
ld a,(&bffc)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix



ld sp,&0000
ld a,0
ld (&0000),a
ld (&fffd),a
ld hl,&4433
push hl
ld a,(&0000)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,(&ffff)
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix
ld a,(&fffe)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix
ld a,(&fffd)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld sp,&0001
ld a,0
ld (&0001),a
ld a,0
ld (&0000),a
ld a,0
ld (&ffff),a
ld a,0
ld (&fffe),a

ld hl,&4433
push hl
ld a,(&0001)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,(&0000)
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix
ld a,(&ffff)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix
ld a,(&fffe)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld hl,&bfff
ld (hl),0
inc hl
ld (hl),&33
inc hl
ld (hl),&44
inc hl
ld (hl),&11
inc hl
ld (hl),&22

ld sp,&c000
pop hl
ld (ix+0),l
inc ix
ld (ix+0),&33
inc ix
ld (ix+0),h
inc ix
ld (ix+0),&44
inc ix
pop de
ld (ix+0),e
inc ix
ld (ix+0),&11
inc ix
ld (ix+0),d
inc ix
ld (ix+0),&22
inc ix

ld sp,&bfff
pop hl
ld (ix+0),l
inc ix
ld (ix+0),&00
inc ix
ld (ix+0),h
inc ix
ld (ix+0),&33
inc ix
pop de
ld (ix+0),e
inc ix
ld (ix+0),&44
inc ix
ld (ix+0),d
inc ix
ld (ix+0),&11
inc ix


ld sp,(stack)
ei

ld ix,result_buffer
ld bc,24
call simple_results
ret







int_pv_test:

call store_int

ld ix,result_buffer

di
ld bc,&7f00+%10011110
out (c),c

ld a,r
push af
pop hl
ld a,l
and %100
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld a,i
push af
pop hl
ld a,l
and %100
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld hl,&c9fb
ld (&0038),hl

ld bc,&7f00+%10011110
out (c),c

ei

ld a,r
push af
pop hl
ld a,l
and %100
ld (ix+0),a
inc ix
ld (ix+0),%100
inc ix

ld a,i
push af
pop hl
ld a,l
and %100
ld (ix+0),a
inc ix
ld (ix+0),%100
inc ix

call ipt_test

call restore_int

ei
ld ix,result_buffer
ld bc,4+64
call simple_results
ret

ipt_test:
push ix
ld b,64
ld c,0
iptt1:
ld a,c
cp 64-15
jr z,iptt2
cp 64-16
jr z,iptt2
ld a,%100
jr iptt3
iptt2:
xor a
iptt3:
ld (ix+1),a
inc ix
inc ix
inc c
djnz iptt1
pop ix

;; 14 and 15 from end show 0
ld b,64
ld hl,end_addr

ipt:
push bc
push hl
ld (jp_addr+1),hl

ld b,&f5
ipt2:
in a,(c)
rra
jr nc,ipt2
;; int within vsync
halt

;; next
halt
;; delay for at least 51 lines to get close to next int
ld e,51
dl1:
defs 64-1-3
dec e
jp nz,dl1

;; additional delay
jp_addr:
jp addr

addr:
defs 64
end_addr:
;; capture p/v
ld a,i
push af
pop hl
ld a,l
and %100
ld (ix+0),a
inc ix
inc ix
pop hl
dec hl
pop bc
dec b
jp nz,ipt
ret



index_test:
di
ld hl,&4000-256
ld bc,256*2
call clear_ram

ld iy,result_buffer
ld ix,&4000

ld hl,&4000-128
ld (hl),&33

ld hl,&4000-64
ld (hl),&23

ld hl,&4000-1
ld (hl),&13

ld hl,&4000+127
ld (hl),&31

ld hl,&4000+64
ld (hl),&21

ld hl,&4000+1
ld (hl),&11

ld a,(ix-128)
ld (iy+0),a
inc iy
ld (iy+0),&33
inc iy

ld a,(ix-64)
ld (iy+0),a
inc iy
ld (iy+0),&23
inc iy


ld a,(ix-1)
ld (iy+0),a
inc iy
ld (iy+0),&13
inc iy

ld a,(ix+1)
ld (iy+0),a
inc iy
ld (iy+0),&11
inc iy

ld a,(ix+64)
ld (iy+0),a
inc iy
ld (iy+0),&21
inc iy

ld a,(ix+127)
ld (iy+0),a
inc iy
ld (iy+0),&31
inc iy

ld a,(ix+255)
ld (iy+0),a
inc iy
ld (iy+0),&13
inc iy

ld a,(ix+0)
ld (iy+0),a
inc iy
ld (iy+0),0
inc iy

ld a,(ix+129)
ld (iy+0),a
inc iy
ld (iy+0),0
inc iy

ei
ld ix,result_buffer
ld bc,9
call simple_results
ret


execute_ffff:
di
ld ix,result_buffer
;; store byte
ld hl,&4000

ld (hl),&44

;; generate instruction; ends at 0000
ld de,&0000-4
ld a,&3a
ld (de),a
inc de
ld a,&00
ld (de),a
inc de
ld a,&40
ld (de),a
inc de
ld a,&c9
ld (de),a
call &0000-4
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix

;; next
ld (hl),&aa

;; generate instruction
ld de,&0000-3
ld a,&3a
ld (de),a
inc de
ld a,&00
ld (de),a
inc de
ld a,&40
ld (de),a
inc de
ld a,&c9
ld (de),a
inc de
call &0000-3
ld (ix+0),a
inc ix
ld (ix+0),&aa
inc ix

ld (hl),&55

ld de,&0000-2
ld a,&3a
ld (de),a
inc de
ld a,&00
ld (de),a
inc de
ld a,&40
ld (de),a
inc de
ld a,&c9
ld (de),a
inc de
call &0000-2
ld (ix+0),a
inc ix
ld (ix+0),&55
inc ix


ld (hl),&22

ld de,&0000-1
ld a,&3a
ld (de),a
inc de
ld a,&00
ld (de),a
inc de
ld a,&40
ld (de),a
inc de
ld a,&c9
ld (de),a
inc de
call &0000-1
ld (ix+0),a
inc ix
ld (ix+0),&22
inc ix


ei
ld ix,result_buffer
ld bc,4
call simple_results
ret

cmos_nmos_test:
di
ld ix,result_buffer

ld c,0
ld a,%10000000
call write_psg_reg

ld c,0
call select_psg_reg

;; write data to port
ld b,&f4
;; out (c),0
defb &ed
defb &71
call set_psg_write_data
call set_psg_inactive

ld c,0
call read_psg_reg
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix


ei
ld ix,result_buffer
ld bc,2
call simple_results
ret

;;--------------------------------------------------------------------

int_return_addr:
ex (sp),hl	;; hl onto stack, return into hl
push hl
push af
ld (int_addr),hl

ld a,(int_count)
inc a
ld (int_count),a
pop af
pop hl
;; return hl from stack
ex (sp),hl
inc sp
inc sp
ei
reti

int_addr:
defw 0

int_count:
defb 0

long_delay:
ld b,128
eid1:
push bc
call vsync_sync
pop bc
djnz eid1
ret



ei_delay:
di
call store_int

ld a,&c3
ld hl,int_return_addr
ld (&0038),a
ld (&0039),hl

xor a
ld (int_count),a

;; wait long enough for an int request to be pending
call long_delay

ei_delay_start:
;; repeat eis
rept 64
ei
endm
ei_delay_end:
;; now allow int
defs 64

ld hl,(int_addr)
or a
ld bc,ei_delay_start
sbc hl,bc
ld (ix+0),l
ld (ix+2),h

ld hl,(ei_delay_end)
or a
ld bc,ei_delay_start
sbc hl,bc
ld (ix+1),l
ld (ix+3),h

ld a,(int_count)
ld (ix+4),a
ld (ix+5),1
di
call restore_int
ei
ld ix,result_buffer
ld bc,3
call simple_results
ret

dd_delay:
di
call store_int

ld a,&c3
ld hl,int_return_addr
ld (&0038),a
ld (&0039),hl

xor a
ld (int_count),a

call long_delay

dd_delay_start:
rept 64
defb &dd
endm
dd_delay_end:
;; now allow int
defs 64

ld hl,(int_addr)
or a
ld bc,dd_delay_start
sbc hl,bc
ld (ix+0),l
ld (ix+2),h

ld hl,(dd_delay_end)
or a
ld bc,dd_delay_start
sbc hl,bc
ld (ix+1),l
ld (ix+3),h

ld a,(int_count)
ld (ix+4),a
ld (ix+5),1
di
call restore_int
ei
ld ix,result_buffer
ld bc,3
call simple_results
ret

fd_delay:
di
call store_int

ld a,&c3
ld hl,int_return_addr
ld (&0038),a
ld (&0039),hl

xor a
ld (int_count),a

call long_delay

fd_delay_start:
rept 64
defb &fd
endm
fd_delay_end:
;; now allow int
defs 64

ld hl,(int_addr)
or a
ld bc,fd_delay_start
sbc hl,bc
ld (ix+0),l
ld (ix+2),h

ld hl,(fd_delay_end)
or a
ld bc,fd_delay_start
sbc hl,bc
ld (ix+1),l
ld (ix+3),h

ld a,(int_count)
ld (ix+4),a
ld (ix+5),1
di
call restore_int
ei
ld ix,result_buffer
ld bc,3
call simple_results
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
