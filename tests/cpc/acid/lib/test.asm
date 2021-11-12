;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; IX = tests
run_tests:
call run_all_tests
xor a
call set_output_type
ld hl,done_msg
call output_msg
call wait_key
rst  0

stop_each_test:
defb 0

done_msg:
defb "Done. Press a key to exit",0

run_all_tests:
ld a,(ix+0)		;; end of test marker?
or a
ret z

push ix
pop hl

ld a,(stop_each_test)
or a
call nz,report_press_key

;; display test name..
call output_msg
ld a,'-'
call output_char
;; get execution address
ld e,(hl)
inc hl
ld d,(hl)
inc hl
;;ld a,e
;;or d
;;call z,wait_key

;; remember list pos
push hl

ex de,hl
;; execute it
call jphl
;; update list pos
pop ix
jr run_tests

jphl:
jp (hl)

;; ix = result buffer
;; bc = number
simple_list:
push bc
ld a,(ix+0)
inc ix
call outputhex8
ld a,' '
call output_char
pop bc
dec bc
ld a,b
or c
jr nz,simple_list
ret


;; ix = result buffer
;; b = count
number_list:
xor a
nl1:
push af
push bc
call outputhex8
ld a,' '
call output_char
ld a,' '
call output_char
;; read value
ld a,(ix+0)
inc ix
call outputhex8
ld a,' '
call output_char
pop af
pop bc
inc a
djnz nl1
ret

output_addr:
call outputhex16
ld a,':'
jp output_char

data_msg:
defb "DATA",0

;; ix = result buffer
;; bc = number
;; d = number in width
simple_number_grid:
ld hl,data_msg
call output_msg

ld hl,0

ld e,d
loop_simple_number_grid:
push de
push bc
push hl

ld a,e
cp d
jr nz,sng3

;; output end of line
push ix
push bc
push de
push hl

push hl
call output_nl
pop hl
call output_addr
pop hl
pop de
pop bc
pop ix


sng3:
ld a,(ix+0)
inc ix
call outputhex8
ld a,' '
call output_char
pop hl
pop bc
pop de
inc hl
;; number done in width so far
dec e
jr nz,sng2

;; reset count
ld e,d
sng2:
dec bc
ld a,b
or c
jr nz,loop_simple_number_grid
jp output_nl

;; bc = number
simple_results:
push ix
push bc




loop_simple_results:
push bc
ld a,(ix+0)
inc ix
ld c,(ix+0)
inc ix
cp c
jr nz,simple_results_fail
pop bc
dec bc
ld a,b
or c
jr nz,loop_simple_results

pop bc
pop ix
jp report_positive

simple_results_fail:
pop bc
call report_negative
pop bc
pop ix

ld hl,0
loop_fail_simple_results:
push bc
push hl

call output_addr

ld a,(ix+0)
inc ix
ld c,(ix+0)
inc ix
cp c
call loop2_fail_simple_results
pop hl
pop bc
inc hl
dec bc
ld a,b
or c
jr nz,loop_fail_simple_results
ret

loop2_fail_simple_results:
ld b,a
jp nz,report_got_wanted
;; report ok
jp report_ok

;; bc = number
simple_results_num:
ld hl,0
srn1:
push hl
push bc
call output_addr
ld a,(ix+0)
inc ix
ld c,(ix+0)
inc ix
call srn2
;;call output_nl
pop bc
pop hl
inc hl
dec bc
ld a,b
or c
jr nz,srn1
ret

srn2:
cp c
jp nz,srn3
jp report_positive

srn3:
push bc
push af
call report_negative
pop af
pop bc
ld b,a
jp report_got_wanted


copy_results:
ld a,(hl)
inc hl
cp &fe
jr nz,cr2

ld a,(hl) ;; code
inc hl
cp &fe
jr z,cr2

cp &ff
jr z,cr2

or a
ret z

call sub_copy_results
jr copy_results

cr2:
ld (ix+1),a
inc ix
inc ix
jr copy_results

sub_copy_results:
push hl
dec a
add a,a
ld hl,(cr_functions)
add a,l
ld l,a
ld a,h
adc a,0
ld h,a
ld e,(hl)
inc hl
ld d,(hl)
pop hl
push de
ret

cr_functions:
defw 0



