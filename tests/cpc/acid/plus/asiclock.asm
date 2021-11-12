;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

;; asic lock test 
org &8000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
call &bb06
ret

;; asic is locked after hard reset/power
;; asic lock status remains set until whole sequence has been sent
;;-----------------------------------------------------

;; gx4000 shows 1s instead of zeros for first bit
;; gx4000 shows 1 for last one too.

tests:
DEFINE_TEST "asic RMR2 lock", asic_enable_test 
DEFINE_END_TEST

asic_enable_test:
di
ld ix,result_buffer

;; ensure it's disabled
call asic_enable
call asic_ram_disable
call asic_disable


;; write unlock sequence a byte at a time and test
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

aet1:

        ld      a,(hl)
        out     (c),a
        push hl
        push bc
        call asic_ram_enable
        call asic_wr_check
        pop bc

        pop hl
        ld (ix+0),a
inc ix
ld a,d
cp 1
ld a,0
jr nz,aet2
ld a,1
aet2:
ld (ix+0),a
inc ix

        inc     hl
        dec     d
        jr      nz,aet1

;; unlocked



;; check when writing again.. should say unlocked all the time
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

aet1a:

        ld      a,(hl)
        out     (c),a
        push hl
        push bc
        call asic_ram_enable
        call asic_wr_check
        pop bc

        pop hl
        ld (ix+0),a
inc ix
ld (ix+0),1

inc ix

  inc     hl
        dec     d
        jr      nz,aet1a

;; write unlock sequence a byte at a time and test
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,15

aet3:
        ld      a,(hl)
        out     (c),a
        
         push hl
        push bc
        call asic_ram_enable
        call asic_wr_check
        pop bc
        pop hl
        ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

        inc     hl
        dec     d
        jr      nz,aet3
        ld      a,&a5
        out     (c),a
            push hl
        push bc
        call asic_ram_enable
        call asic_wr_check
        pop bc
        pop hl
        ld (ix+0),a
inc ix
ld (ix+0),1
inc ix
            push hl
        push bc
        call asic_ram_disable
        call asic_wr_check
        pop bc
        pop hl
        ld (ix+0),a
inc ix
ld (ix+0),1
inc ix
           push hl
        push bc
        call asic_ram_disable
        call asic_wr_check
        pop bc
        pop hl
        ld (ix+0),a
inc ix
ld (ix+0),1
inc ix



call asic_enable
call asic_ram_disable

call asic_wr_check
ld (ix+0),a

inc ix
ld (ix+0),0
inc ix

call asic_enable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

call asic_enable
call asic_ram_disable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

call asic_enable
call asic_ram_enable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),1 
inc ix

call asic_ram_disable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

call asic_ram_enable
call asic_disable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

call asic_enable
call asic_ram_enable
call asic_disable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix
call asic_ram_disable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix
call asic_ram_enable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

;; asic disabled so ram can't be disabled
call asic_ram_disable
;; still disabled.
call asic_disable
call asic_wr_check
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

ei
call asic_enable
call asic_ram_disable
call asic_disable

ld ix,result_buffer
ld bc,10+17+17+18
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

asic_wr_check:
ld hl,&4000
ld (hl),&aa
ld a,(hl)
cp &a
ld a,1
ret z
xor a
ret


write_asic_seq:
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,16

as1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,as1
ret


asic_enable:
	push af
	push hl
	push bc
	push de
 	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	pop de
	pop bc
	pop hl
	pop af	
	ret
	
asic_disable:
	push af
	push hl
	push bc
	push de
  ld hl,asic_sequence
	ld bc,&bc00
	ld d,15

ad1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ad1
ld a,&a5
out (c),a
pop de
	pop bc
	pop hl
	pop af	
	ret
	
  ;; any byte after &cd, &ed is ok, &ee is ok
  
asic_sequence:
defb &aa,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ed

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
