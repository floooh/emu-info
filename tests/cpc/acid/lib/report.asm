;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

stop_on_fail:
defb 0

report_positive:
	ld hl,succeeded_txt
	jp output_msg

report_negative:
	ld hl,failed_txt
	call  output_msg
	ld a,(stop_on_fail)
	or a
	call nz,report_press_key
	ret
	
;; B = got
;; C = wanted
report_got_wanted:
	push bc
	push bc
	ld hl,got_txt
	call output_msg
	pop bc
	ld a,b
	call outputhex8
	ld hl,expected_txt
	call output_msg
	pop bc
	ld a,c
	call outputhex8
  ld hl,failed_txt
  
report_ok_fail:
	push hl
	call display_dash
	pop hl
  jp output_msg
	 
report_ok:
	push bc
	ld hl,got_txt
	call output_msg
	pop bc
	ld a,b
	call outputhex8
  ld hl,ok_msg
  jr report_ok_fail
  
report_skipped:
	ld hl,skipped_txt
	jp output_msg
	
;; A=got, C=wanted
report_cmpAC:
	push af
	push bc
	push hl
	cp c
	ld b,a
	call report_cmp
	pop hl
	pop bc
	pop af
	ret

report_cmp:
	jr z,report_positive
	jr report_negative

skipped_txt:
defb "Skipped",13,0

failed_txt:
defb "FAIL",13,0

succeeded_txt:
defb "PASS",13,0

ok_msg:
defb "OK",13,0

got_txt:
defb " got ",0

expected_txt:
defb " expected ",0


dash_msg:
defb " - ",0

display_dash:
ld hl,dash_msg
jp output_msg
