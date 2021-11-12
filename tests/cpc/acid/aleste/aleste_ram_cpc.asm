include "lib/testdef.asm"
;; NEEDS TESTING ON A REAL ALESTE

;; AY-3-8912 tester 
org &2000
start:

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;;-----------------------------------------------------

tests:
;; test the value written to the mapper register is the one we read back
DEFINE_TEST "test mapper read 0000",mapper_read_test_0000
DEFINE_TEST "test mapper read 4000",mapper_read_test_4000
;;DEFINE_TEST "test mapper read 8000",mapper_read_test_8000 ;; where our code is
DEFINE_TEST "test mapper read c000",mapper_read_test_c000

;; test that we can page in cpc ram using mapper, read it's registers to find out what it did
DEFINE_TEST "cpc ram config through 7c", cpc_page_test_7c
DEFINE_TEST "cpc ram config through 7d", cpc_page_test_7d
DEFINE_TEST "cpc ram config through 7e", cpc_page_test_7e
DEFINE_TEST "cpc ram config through 7f", cpc_page_test_7f

;; write cpc style, then read back as msx style after switching map mod
DEFINE_TEST "cpc ram config through 7c (mapmod switch)", cpc_page_test2_7c
DEFINE_TEST "cpc ram config through 7d (mapmod switch)", cpc_page_test2_7d
DEFINE_TEST "cpc ram config through 7e (mapmod switch)", cpc_page_test2_7e
DEFINE_TEST "cpc ram config through 7f (mapmod switch)", cpc_page_test2_7f

DEFINE_END_TEST

;;-----------------------------------------------------

mapper_read_test_0000:
ld b,&7c
jp test_mapper_read

;;-----------------------------------------------------

mapper_read_test_4000:
ld b,&7d
jp test_mapper_read

;;-----------------------------------------------------

mapper_read_test_8000:
ld b,&7e
jp test_mapper_read

;;-----------------------------------------------------

mapper_read_test_c000:
ld b,&7f
jp test_mapper_read

;;-----------------------------------------------------

;; when programming cpc configs read back result from mapper and see what it has
test_mapper_read:
di

;; enable msx style mapper
ld bc,&fadf
ld a,%00000100
out (c),c

;; write all possibilities
ld ix,result_buffer

xor a
ld d,0
tmr1:
out (c),a
ld (ix+1),a		;; expected
in a,(c)
ld (ix+0),a		;; result
inc ix
inc ix
inc a
dec d
jr nz,tmr1

;; disable msx style mapper
ld bc,&fadf
ld a,%00000000
out (c),c

ld a,&7fc0
out (c),c
ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


;;-----------------------------------------------------

cpc_page_test_7c:
ld b,&7c
jp cpc_page_test

cpc_page_test_7d:
ld b,&7d
jp cpc_page_test

cpc_page_test_7e:
ld b,&7e
jp cpc_page_test

cpc_page_test_7f:
ld b,&7f
jp cpc_page_test

;;-----------------------------------------------------

num_configs equ end_ram_configs-ram_configs

;; when programming cpc configs read back result from mapper and see what it has
cpc_page_test:
di
ld ix,result_buffer

;; disable msx style mapper
ld bc,&fadf
ld a,%00000000
out (c),c

;; init expected results
push ix
ld hl,expected_ram_configs
ld d,num_configs
init_ram_configs:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
dec d
jr nz,init_ram_configs
pop ix

;; get actual results
ld d,num_configs
ld hl,ram_configs
do_ram_configs:
ld a,(hl)
inc hl
out (c),a

call read_pages

dec d
jp nz,do_ram_configs

;; disable msx style mapper
ld bc,&fadf
ld a,%00000000
out (c),c

;; restore
ld a,&7fc0
out (c),c
ei
ld ix,result_buffer
ld bc,num_configs*4
call simple_results
ret


ram_configs:
defb &c0
defb &c1
defb &c3
defb &c4
defb &c5
defb &c6
defb &c7
end_ram_configs:

expected_ram_configs:
defb 0,1,2,3
defb 0,1,2,7
defb 0,7,2,3
defb 0,4,2,3
defb 0,5,2,3
defb 0,6,2,3
defb 0,7,2,3


read_pages:
push bc
ld b,&7c
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld b,&7d
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld b,&7e
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld b,&7f
in a,(c)
ld (ix+0),a
inc ix
inc ix
pop bc
ret


;;-----------------------------------------------------

cpc_page_test2_7c:
ld b,&7c
jp cpc_page_test2

cpc_page_test2_7d:
ld b,&7d
jp cpc_page_test2

cpc_page_test2_7e:
ld b,&7e
jp cpc_page_test2

cpc_page_test2_7f:
ld b,&7f
jp cpc_page_test2


;; when programming cpc configs read back result from mapper and see what it has
cpc_page_test2:
di
ld ix,result_buffer


;; init expected results
push ix
ld hl,expected_ram_configs
ld d,num_configs
init_ram_configs2:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
dec d
jr nz,init_ram_configs2
pop ix

;; get actual results
ld d,num_configs
ld hl,ram_configs
do_ram_configs2:

;; set
push bc
push af
;; disable msx style mapper
ld bc,&fadf
ld a,%00000000
out (c),c
pop af
pop bc

ld a,(hl)
inc hl
out (c),a

;; switch to read
push bc
push af
;; enable msx style mapper
ld bc,&fadf
ld a,%00000100
out (c),c
pop af
pop bc


call read_pages

dec d
jp nz,do_ram_configs2

;; disable msx style mapper
ld bc,&fadf
ld a,%00000000
out (c),c


;; restore
ld a,&7fc0
out (c),c
ei
ld ix,result_buffer
ld bc,num_configs*4
call simple_results
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
