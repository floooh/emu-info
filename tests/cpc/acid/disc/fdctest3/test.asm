;; IX = tests
run_tests:
call run_all_tests
ld hl,done_msg
call display_string
call wait_char
rst  0

done_msg:
defb "Done. Press a key to exit",0

run_all_tests:
ld a,(ix+0)		;; end of test marker?
or a
ret z

push ix
pop hl

;;call wait_key

;; display test name..
call display_string
ld a,'-'
call display_char
;; get execution address
ld e,(hl)
inc hl
ld d,(hl)
inc hl

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
