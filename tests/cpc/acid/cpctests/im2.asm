;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &4000
nolist
;; type 0 and type 1 the same:
;; got fe for all
;; then 02 on the end??

start:
ld ix,result_buffer
ld b,0
xor a
tester:
push bc
push af
push af

call fill_screen

di
ld hl,&7f00
ld e,l
ld d,h
inc de
ld (hl),&80
ld bc,&101
ldir

ld a,&c3
ld (&8080),a
ld (&8091),a
ld hl,int_fn_bad
ld (&8081),hl
ld (&8092),hl

pop af
ld l,a
ld h,&7f
ld (hl),&00
inc hl
ld (hl),&91
ld a,&c3
ld (&9100),a
ld hl,int_fn_good
ld (&9101),hl

xor a
ld (int_bad_count),a
ld (int_good_count),a

ld a,&7f
ld i,a
im 2
ei
nop
halt
di
ld a,(int_bad_count)
neg
ld b,a
ld a,(int_good_count)
add a,b
;; -1 for bad
;; 1 for good
;; 0 for both
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
pop af
inc a
pop bc
djnz tester
im 1
ei
ld ix,result_buffer
ld bc,256
call simple_results
call &bb06
ret

int_fn_bad:
push af
ld a,(int_bad_count)
inc a
ld (int_bad_count),a
pop af
ei
reti


int_fn_good:
push af
ld a,(int_good_count)
inc a
ld (int_good_count),a
pop af
ei
reti

int_bad_count:
defb 0

int_good_count:
defb 0

fill_screen:
ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),a
ld bc,&4000
ldir
ret

;;-----------------------------------------------------

include "lib/mem.asm"
include "lib/report.asm"
include "lib/test.asm"
include "lib/outputmsg.asm"
include "lib/outputhex.asm"
include "lib/output.asm"
include "lib/hw/psg.asm"
;; firmware based output
include "lib/fw/output.asm"

result_buffer: equ $

end start