;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

include "../../lib/testdef.asm"

kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

start:

ld a,2
call scr_set_mode
ld hl,start_message
call output_msg
call wait_key


call cls

;; select rom 0 for upper rom
ld c,0
call kl_rom_select

call kl_l_rom_enable
call kl_u_rom_enable
ld a,(&1000)
ld (lowrom_byte),a
ld a,(&d000)
ld (highrom_byte),a
call kl_u_rom_disable
call kl_l_rom_disable


;; ensure data is poked into ram
call kl_u_rom_disable
call kl_l_rom_disable

ld ix,tests
call run_tests


ld hl,done_txt
call output_msg
ret

start_message:
defb "This is an automatic test.",13,10,13,10
defb "This test is for testing Vortex's 512KB internal ram",13,10
defb "expansion for the CPC464.",13,10,13,10
defb "Disconnect all other hardware before running this",13,10
defb "test.",13,10,13,10
defb "Press a key to start",0

done_txt:
defb "Done!",0

ram_sel:
push bc
push af

push af
and %11100
add a,a
ld c,a
pop af
and &3
add a,4
or c
or &c0
ld b,&7f
out (c),a
pop af
pop bc
ret


filename:
defb "VRTX"
end_filename:

lowrom_byte:
defb 0
highrom_byte:
defb 0

;; todo: bus test to see if it's forcing a value onto the bus
;; todo: read 7fxx?
;; todo: /exp
;; TODO: reset peripherals
;; todo: how test ram disable?
;; todo: test bits of 7fxx, blocked or not? (can test 10.. others need visual can't test others...?)
tests:
DEFINE_TEST "7fxx, fbbd, rom and ram test",l7fxx_test
;; doesn't report any i/o port!!!?
DEFINE_TEST "7fxx i/o decode", l7fxx_io_decode ;; not conclusive.

;; 7e 00 7e
;;DEFINE_TEST "exp",read_exp	;; read exp
;; 0
;;DEFINE_TEST "fbbd read",read_fbbd ;; read fbbd
;; 0
;;DEFINE_TEST "dfxx read",read_dfxx ;; read dfxx

;; rom exactly decoded at slot 6
;; rom has 0, rest are cf
;;DEFINE_TEST "vortex BOS rom index decode",bos_index_decode
DEFINE_TEST "vortex BOS rom index decode",bos_index_decode
;; 33 00 33 00 33 00 33 00 

DEFINE_TEST "vortex BOS rom enable/disable (using fbbd)",bos_enable_disable
;; succeed
DEFINE_TEST "bank active (0000-7fff)", bank_active
;; succeed
DEFINE_TEST "fbbd bits 7&6",fbbd_bits_76
DEFINE_TEST "ram write through (0000-7fff)", bank_write_through
DEFINE_TEST "bank test (0-7) (0000-ffff)", bank_test
;; 
;;DEFINE_TEST "7fxx &00 test - other bits accessed when bit 5 set to 1",l7fxx_00_test
;;DEFINE_TEST "7fxx &40 test - other bits accessed when bit 5 set to 1",l7fxx_01_test
;;DEFINE_TEST "7fxx &80 test - other bits accessed when bit 5 set to 1",l7fxx_10_test
;; &c0 on 464?
;; xx0xxxxxxxxxxxxxxxx 
DEFINE_TEST "dfxx i/o decode", df00_io_decode
;;xxxxx0xxx0xxxx0x
DEFINE_TEST "fbbd i/o decode", fbbd_io_decode
DEFINE_END_TEST

read_exp:
di
ld ix,result_buffer

ld b,&f5
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld bc,&7f00+%00000000
out (c),c

ld a,%101000
ld bc,&fbbd
out (c),a
ld b,&f5
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld a,%101000
ld bc,&fbbd
out (c),a
ld bc,&7f00+%00100000
out (c),c
ld b,&f5
in a,(c)
ld (ix+0),a
inc ix
inc ix

di
call restore
ei
ld ix,result_buffer
ld bc,6
ld d,8
call simple_number_grid
ret


read_fbbd:
di
ld ix,result_buffer

ld bc,&fbbd
ld de,256
call port_r_test

di
call restore
ei
call report_positive
ld ix,result_buffer
ld bc,256
ld d,8
call simple_number_grid
ret


read_dfxx:
di
ld ix,result_buffer

ld bc,&df00
ld de,256

call port_r_test

ei
call report_positive
ld ix,result_buffer
ld bc,256
ld d,8
call simple_number_grid
ret



;; xUExxxxxx

;; 00xxxxxxx - lower - pen select
;; 01xxxxxxx - upper - colour set
;; 10xxxxxxx - lower - mode/rom
;; 11xxxxxxx - upper - PAL 

l7fxx_00_test:
call kl_l_rom_disable
call kl_u_rom_disable
di
call init_ram
ld ix,result_buffer
ld a,%101000
ld bc,&fbbd
out (c),a

ld bc,&7f00+16
out (c),c

;; ram enabled in lower
ld bc,&7f00+%00100000
out (c),c

ld bc,&7f40
out (c),c

ld de,10000
l7f0:
dec de
ld a,d
or e
jr nz,l7f0

di 
call restore
ei
call report_positive
ret

l7fxx_01_test:
call kl_l_rom_disable
call kl_u_rom_disable
di
call init_ram
ld ix,result_buffer
ld a,%101000
ld bc,&fbbd
out (c),a

ld bc,&7f00
out (c),c

ld bc,&7f54
out (c),c

ld hl,l7fxx_01_test_inner
ld de,&4000
ld bc,end_l7fxx_01_test_inner-l7fxx_01_test_inner
ldir

jp &4000
l7f12:
di
call restore
ei
call report_positive

ret

l7fxx_01_test_inner:
;; ram enabled in upper
ld bc,&7f00+%01100000
out (c),c

;; wait
ld de,10000
l7f122:
dec de
ld a,d
or e
jr nz,l7f122

;; switch back
ld bc,&7f00+%01000000
out (c),c
jp l7f12
end_l7fxx_01_test_inner:

l7fxx_results:
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &01,&02,&03,&cf
defb &05,&06,&03,&cf
defb &05,&06,&03,&cf
defb &05,&06,&03,&cf
defb &05,&06,&03,&cf
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &01,&02,&03,&00
defb &05,&06,&03,&00
defb &05,&06,&03,&00
defb &05,&06,&03,&00
defb &05,&06,&03,&00
defb &b2,&02,&03,&cf
defb &01,&02,&03,&cf
defb &b2,&02,&03,&04
defb &01,&02,&03,&04
defb &b2,&02,&03,&cf
defb &01,&02,&03,&cf
defb &b2,&02,&03,&04
defb &01,&02,&03,&04
defb &00,&02,&03,&00
defb &01,&02,&03,&00
defb &00,&02,&03,&04
defb &01,&02,&03,&04
defb &00,&02,&03,&00
defb &01,&02,&03,&00
defb &00,&02,&03,&04
defb &01,&02,&03,&04
defb &b2,&02,&03,&cf
defb &01,&02,&03,&cf
defb &b2,&02,&03,&04
defb &01,&02,&03,&04
defb &b2,&06,&03,&cf
defb &05,&06,&03,&cf
defb &b2,&06,&03,&04
defb &05,&06,&03,&04
defb &00,&02,&03,&00
defb &01,&02,&03,&00
defb &00,&02,&03,&04
defb &01,&02,&03,&04
defb &00,&06,&03,&00
defb &05,&06,&03,&00
defb &00,&06,&03,&04
defb &05,&06,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &05,&06,&03,&04
defb &05,&06,&03,&04
defb &05,&06,&03,&04
defb &05,&06,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &01,&02,&03,&04
defb &05,&06,&03,&04
defb &05,&06,&03,&04
defb &05,&06,&03,&04
defb &05,&06,&03,&04
defb &b2,&02,&03,&00
defb &01,&02,&03,&00
defb &b2,&02,&03,&04
defb &01,&02,&03,&04
defb &b2,&02,&03,&00
defb &01,&02,&03,&00
defb &b2,&02,&03,&04
defb &01,&02,&03,&04
defb &00,&02,&03,&00
defb &01,&02,&03,&00
defb &00,&02,&03,&04
defb &01,&02,&03,&04
defb &00,&02,&03,&00
defb &01,&02,&03,&00
defb &00,&02,&03,&04
defb &01,&02,&03,&04
defb &b2,&02,&03,&00
defb &01,&02,&03,&00
defb &b2,&02,&03,&04
defb &01,&02,&03,&04
defb &b2,&06,&03,&00
defb &05,&06,&03,&00
defb &b2,&06,&03,&04
defb &05,&06,&03,&04
defb &00,&02,&03,&00
defb &01,&02,&03,&00
defb &00,&02,&03,&04
defb &01,&02,&03,&04
defb &00,&06,&03,&00
defb &05,&06,&03,&00
defb &00,&06,&03,&04
defb &05,&06,&03,&04

defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&07,&cf
defb &b2,&02,&07,&cf
defb &b2,&02,&07,&cf
defb &b2,&02,&07,&cf
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&03,&cf
defb &b2,&02,&07,&cf
defb &b2,&02,&07,&cf
defb &b2,&02,&07,&cf
defb &b2,&02,&07,&cf
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&07,&00
defb &b2,&02,&07,&00
defb &b2,&02,&07,&00
defb &b2,&02,&07,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&03,&00
defb &b2,&02,&07,&00
defb &b2,&02,&07,&00
defb &b2,&02,&07,&00
defb &b2,&02,&07,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&03,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
defb &00,&02,&07,&00
end_7fxx_results:

code_lower equ &4000
code_lower2 equ &5001
data_lower equ &6000

l7fxx_test:
ld hl,l7fxx_results
ld ix,result_buffer
ld bc,end_7fxx_results-l7fxx_results
lll1:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
inc hl
dec bc
ld a,b
or c
jr nz,lll1

call get_lower_rom_data

call kl_l_rom_disable
call kl_u_rom_disable

ld c,0
call kl_rom_select
di
call init_ram
ld ix,result_buffer

;; 0
ld bc,&df00
out (c),c
call get_values_combination
;; 16
ld bc,&df06
out (c),c
call get_values_combination

ld bc,&fbbd
ld a,%0
out (c),a
ld bc,&7f00+%10000000
out (c),c

ld hl,get_values
ld de,code_lower2
ld bc,end_get_values-get_values
ldir
ld hl,l7fxx_4000_code
ld de,code_lower
ld bc,end_l7fxx_4000_code-l7fxx_4000_code
ldir
ld (spstore),sp
ld (ixstore),ix
ld ix,data_lower
ld sp,&7fff
jp code_lower
l7fxx_tl:
ld sp,(spstore)
ld de,(ixstore)
ld hl,data_lower
ld bc,16*16*2
lll3:
ld a,(hl)
ld (de),a
inc hl
inc hl
inc de
inc de
dec bc
ld a,b
or c
jr nz,lll3
di
call restore
ei

;; 16 combinations
;; 16 read for each
ld ix,result_buffer
ld bc,16*16*2*2
ld d,8
;;call simple_number_grid
call simple_results
ret
spstore:
defs 2
ixstore:
defs 2


;; 16
get_values_combination:
; R1 RO R2
;; 0 0 0
;; 0 0 1
;; 0 1 0
;; 0 1 1
;; 1 0 0
;; 1 0 1
;; 1 1 0
;; 1 1 1 

;; H: R1-RO---
;; L: R2-----

;; 0
ld h,%00000000
ld l,%00000000
call get_value

;; 4
ld h,%00000000
ld l,%00100000
call get_value

;; 8
ld h,%00001000
ld l,%00000000
call get_value

;; 12
ld h,%00001000
ld l,%00100000
call get_value

;; 16
ld h,%00100000
ld l,%00000000
call get_value

;; 20
ld h,%00100000
ld l,%00100000
call get_value

;; 24
ld h,%00101000
ld l,%00000000
call get_value

;; 28
ld h,%00101000
ld l,%00100000
call get_value

;; 32
ld h,%10000000
ld l,%10000000
call get_value

;; 36
ld h,%10000000
ld l,%10100000
call get_value

;; 40
ld h,%10001000
ld l,%10000000
call get_value

;; 44
ld h,%10001000
ld l,%10100000
call get_value

;; 48
ld h,%10100000
ld l,%10000000
call get_value

;; 52
ld h,%10100000
ld l,%10100000
call get_value

;; 56
ld h,%10101000
ld l,%10000000
call get_value

;; 60
ld h,%10101000
ld l,%10100000
call get_value


ret


get_value:
ld bc,&fbbd
out (c),h
ld b,&7f
ld c,l
call get_values
ret



;; 16 read
get_values:
ld b,&7f
out (c),c
ld a,(&1000)
ld (ix+0),a
inc ix
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
inc ix

ld a,(&a600)
ld (ix+0),a
inc ix
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
inc ix

ld a,c
add a,4
ld c,a
ld b,&7f
out (c),c
ld a,(&1000)
ld (ix+0),a
inc ix
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
inc ix

ld a,(&a600)
ld (ix+0),a
inc ix
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
inc ix


ld a,c
add a,4
ld c,a
ld b,&7f
out (c),c
ld a,(&1000)
ld (ix+0),a
inc ix
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
inc ix

ld a,(&a600)
ld (ix+0),a
inc ix
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
inc ix

ld a,c
add a,4
ld c,a
ld b,&7f
out (c),c
ld a,(&1000)
ld (ix+0),a
inc ix
inc ix


ld a,(&5000)
ld (ix+0),a
inc ix
inc ix

ld a,(&a600)
ld (ix+0),a
inc ix
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
inc ix


ret
end_get_values:

l7fxx_4000_code:
get2_all_values_combination:

ld bc,&df00
out (c),c
call get2_values_combination-l7fxx_4000_code+code_lower
ld bc,&df06
out (c),c
call get2_values_combination-l7fxx_4000_code+code_lower
jp l7fxx_tl

get2_values_combination:
; R1 RO R2
;; 0 0 0
;; 0 0 1
;; 0 1 0
;; 0 1 1
;; 1 0 0
;; 1 0 1
;; 1 1 0
;; 1 1 1 

;; H: R1-RO---
;; L: R2-----

;; 24
ld h,%01000000
ld l,%01000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01000000
ld l,%01100000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01001000
ld l,%01000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01001000
ld l,%01100000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01100000
ld l,%01000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01100000
ld l,%01100000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01101000
ld l,%01000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%01101000
ld l,%01100000
call get_value2-l7fxx_4000_code+code_lower


ld h,%11000000
ld l,%11000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11000000
ld l,%11100000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11001000
ld l,%11000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11001000
ld l,%11100000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11100000
ld l,%11000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11100000
ld l,%11100000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11101000
ld l,%11000000
call get_value2-l7fxx_4000_code+code_lower

ld h,%11101000
ld l,%11100000
call get_value2-l7fxx_4000_code+code_lower


ld bc,&fbbd
ld a,%0
out (c),a
ld bc,&7f00+%10000000
out (c),c


ret


get_value2:
ld bc,&fbbd
out (c),h
ld b,&7f
ld c,l
call code_lower2
ret
end_l7fxx_4000_code:




get_lower_rom_data:
call kl_l_rom_enable
ld a,(&1000)
ld (low_rom_data),a
call kl_l_rom_disable
ret

get_bos_rom_data:
ld bc,&fbbd
ld a,%0
out (c),a
ld c,6
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (bos_rom_data),a
call kl_u_rom_disable
ret

low_rom_data:
defb 0

bos_rom_data:
defb 0

rom0_rom_data:
defb 0

bos_enable_disable:
call get_bos_rom_data
ld c,0
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (rom0_rom_data),a
call kl_u_rom_disable
ld a,&33
ld (&d000),a
ld ix,result_buffer
;; without ram enabled/disabled
ld c,6
call kl_rom_select
;; disable bos rom
ld a,%001000
ld bc,&fbbd
out (c),a
;; disable upper rom
call kl_u_rom_disable
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,&33	;
ld (ix+0),a
inc ix
;; upper rom enabled, bos disabled
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,(bos_rom_data)
;;ld a,(rom0_rom_data)		;; 20
ld (ix+0),a
inc ix
;; upper rom disabled, bos enabled
call kl_u_rom_disable
ld a,%000000
ld bc,&fbbd
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,&33			;; ff
ld (ix+0),a
inc ix
;; upper rom enabled, bos enabled
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,(bos_rom_data)
;;ld a,(bos_rom_data)
ld (ix+0),a
inc ix


ld c,6
call kl_rom_select
;; disable bos rom
ld a,%101000
ld bc,&fbbd
out (c),a
;; disable upper rom
call kl_u_rom_disable
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,&33
ld (ix+0),a
inc ix
;; upper rom enabled, bos disabled
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,(bos_rom_data)
;;ld a,(rom0_rom_data)
ld (ix+0),a
inc ix
;; upper rom disabled, bos enabled
call kl_u_rom_disable
ld a,%100000
ld bc,&fbbd
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,&33
ld (ix+0),a
inc ix
;; upper rom enabled, bos enabled
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld a,(bos_rom_data)
ld (ix+0),a
inc ix

di
call restore
ei

ld ix,result_buffer
ld bc,8
call simple_results
ret


bos_index_decode:
call get_bos_rom_data
ld c,0
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (rom0_rom_data),a
call kl_u_rom_disable
ld a,&33
ld (&d000),a
call kl_u_rom_enable
ld c,0
call kl_rom_select
di
;; enable rom on board
ld a,%00000000
ld bc,&fbbd
out (c),a

ld ix,result_buffer
ld b,0
ld c,0
bid2:
ld a,c
cp 6
ld a,(bos_rom_data)
jr z,bid3
ld a,(rom0_rom_data)
bid3:
ld (ix+1),a
inc ix
inc ix
inc c
djnz bid2

ld ix,result_buffer
ld b,0
xor a
bid:
push bc
push af
ld b,&df
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
inc ix
pop af
inc a
pop bc
djnz bid
ld bc,&df00
out (c),c
call restore
ei
ld ix,result_buffer
ld bc,256
call simple_results
;;ld d,16
;;call simple_number_grid
ret

bank_write_through:
call kl_u_rom_disable
call kl_l_rom_disable
di
call init_ram
ld ix,result_buffer

ld a,%00101000
ld bc,&fbbd
out (c),a

exx
push bc
res 6,c ;; lower
set 5,c	;; enable ram
out (c),c

ld a,&33
ld (&1000),a
ld (&5000),a
pop bc
out (c),c
exx
ld a,%1000
ld bc,&fbbd
out (c),a

ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),2
inc ix

call restore
ei
ld ix,result_buffer
ld bc,2
call simple_results
ret

bank_active:
call kl_l_rom_disable
call kl_u_rom_disable

di
call init_ram

ld ix,result_buffer

ld a,%00101000
ld bc,&fbbd
out (c),a

exx
push bc
res 6,c ;; lower
set 5,c	;; enable ram
out (c),c

;; both enabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),5
inc ix


;; both enabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

res 6,c ;; lower
res 5,c	;; disable ram
out (c),c

;; 7fxx disabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix


;; 7fxx disabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),2
inc ix
exx
ld a,%00001000
ld bc,&fbbd
out (c),a
exx
;; both disabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

;; both disabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),2
inc ix

exx
ld a,%00101000
ld bc,&fbbd
out (c),a
exx
;; main enabled only
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

;; main enabled only
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),2
inc ix

exx
ld a,%00001000
ld bc,&fbbd
out (c),a
exx

;; 7fxx enabled only
res 6,c ;; lower
set 5,c	;; enable ram
out (c),c

ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix


ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),2
inc ix
pop bc
out (c),c
exx

call restore
ei
ld ix,result_buffer
ld bc,4
call simple_results
ret

fbbd_bits_76:
call kl_l_rom_disable
call kl_u_rom_disable

di
call init_ram

ld ix,result_buffer

ld a,%00101000
ld bc,&fbbd
out (c),a

ld bc,&7f00+%00100000
out (c),c

;; both enabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),5
inc ix

;; both enabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix


ld a,%01101000
ld bc,&fbbd
out (c),a

ld bc,&7f00+%00100000
out (c),c

;; both enabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),5
inc ix

;; both enabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix


ld a,%10101000
ld bc,&fbbd
out (c),a

ld bc,&7f00+%00100000
out (c),c

;; both enabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),5
inc ix

;; both enabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

ld a,%11101000
ld bc,&fbbd
out (c),a

ld bc,&7f00+%00100000
out (c),c

;; both enabled
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),5
inc ix

;; both enabled
ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),6
inc ix

di
call restore
ei
ld ix,result_buffer
ld bc,4
call simple_results
ret



bank_test:
call kl_u_rom_disable
call kl_l_rom_disable
di
call init_ram

ld hl,bank_test_upper
ld de,&4000
ld bc,end_bank_test_upper-bank_test_upper
ldir

ld ix,result_buffer

ld b,8
xor a
fb1:
push bc
push af

push af
or %101000 ;; enable ram
ld bc,&fbbd
out (c),a
pop af
add a,a
add a,a
add a,5
ld (ix+1),a
inc a
ld (ix+3),a
inc a
ld (ix+5),a
inc a
ld (ix+7),a

exx
push bc
res 6,c	;; lower
set 5,c
out (c),c

ld a,(&1000)
ld (ix+0),a
ld a,(&5000)
ld (ix+2),a

res 5,c
out (c),c
jp &4000		;; do upper

bank_test2:
ld a,e
ld (ix+4),a
ld a,d
ld (ix+6),a
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix
inc ix

pop bc
out (c),c
exx
ld a,%100
ld bc,&fbbd
out (c),a

pop af
inc a
pop bc
djnz fb1

call restore
ei
ld ix,result_buffer
ld bc,8*4
call simple_results
ret

bank_test_upper:
res 7,c
set 6,c
set 5,c
out (c),c

ld a,(&a600)
ld e,a
ld a,(&d000)
ld d,a
set 7,c
res 5,c
out (c),c
jp bank_test2
end_bank_test_upper:

init_ram:
ld hl,init_ram_code
ld de,&4000
ld bc,end_init_ram_code-init_ram_code
ldir

ld b,8
xor a
ir1:
push bc
push af
push af
or %101000
ld bc,&fbbd
out (c),a
exx
pop af
push bc
res 6,c	;; lower
set 5,c
out (c),c
add a,a
add a,a
add a,5
ld hl,&1000
ld (hl),a
inc a
ld hl,&5000
ld (hl),a
inc a

;; turn off ram in lower
res 5,c
out (c),c
;; jump to init upper
jp &4000

init_ram2:
pop bc
out (c),c
exx
pop af
inc a
pop bc
djnz ir1
ld hl,&1000
ld (hl),1
ld hl,&5000
ld (hl),2
ld hl,&a600
ld (hl),3
ld hl,&d000
ld (hl),4
ret

init_ram_code:
res 7,c
set 6,c		;; enable upper
set 5,c		;; enable ram
out (c),c

ld hl,&a600
ld (hl),a
inc a
ld hl,&d000
ld (hl),a
set 7,c
res 5,c		;; disable upper
res 6,c		;; disable ram
out (c),c
jp init_ram2 ;; and back to code...
end_init_ram_code:

fbbd_io_decode:
call kl_u_rom_disable
call kl_l_rom_disable
di
call init_ram

ld hl,&0442
ld (wantedportimportant),hl
ld hl,&fbbd
ld (wantedportsuccessOR),hl
ld hl,fbbd_io_check
ld (io_decode_check+1),hl
call io_decode
ret

fbbd_io_check:
ld a,%101000	;; enable ram; disable rom
out (c),a
push bc
ld bc,&7fc0
out (c),c
ld bc,&7f00+%10001100
out (c),c
ld bc,&7f00+%00100000
out (c),c
ld a,(&1000)
cp &5
ld a,1
jr nz,fbbd_io_check_bad
ld a,(&5000)
cp &6
ld a,1
jr nz,fbbd_io_check_bad
xor a ;; good
fbbd_io_check_bad:
pop bc
or a
ret


df00_io_decode:
call get_bos_rom_data
ld a,&33
ld (&d000),a
ld hl,&2000
ld (wantedportimportant),hl
ld hl,&dfff
ld (wantedportsuccessOR),hl
ld hl,df00_io_check
ld (io_decode_check+1),hl
call io_decode
ret


df00_io_check:
ld a,6		;; select bos
out (c),a
push bc
ld bc,&fbbd
ld a,%000000	;; enable rom
out (c),a
ld bc,&7f00+%10000100
out (c),c
ld a,(bos_rom_data)
ld c,a
ld a,(&d000)
cp c
pop bc
ret

;; ??? 0
l7fxx_io_decode:
call kl_u_rom_disable
call kl_l_rom_disable
di
call init_ram

ld hl,&0	
ld (wantedportimportant),hl
ld hl,&0
ld (wantedportsuccessOR),hl
ld hl,l7fxx_io_check
ld (io_decode_check+1),hl
call io_decode
ret

l7fxx_io_check:
ld a,%10101100 	;; lower and enable ram
out (c),a
push bc
ld bc,&fbbd
ld a,%00100000
out (c),a
pop bc
;;ld a,(&1000)
;;cp &5
;;ld a,1
;;jr nz,l7fxx_io_check_bad
ld a,(&5000)
cp &6
ld a,1
jr nz,l7fxx_io_check_bad
xor a ;; good
l7fxx_io_check_bad:
or a
ret


io_decode:
di
ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl

ld de,0
ld bc,0
nextloop:
push bc
push de
push hl
call restore

pop hl
pop de
pop bc

io_decode_check:
call 0
jr nz,next

;; success
push hl
push bc
ld hl,(portsuccessOR)
ld a,h
or b
ld h,a
ld a,l
or c
ld l,a
ld (portsuccessOR),hl
ld hl,(portsuccessAND)
ld a,h
and b
ld h,a
ld a,l
and c
ld l,a
ld (portsuccessAND),hl
pop bc
pop hl

next:
inc bc
dec de
ld a,d
or e
jr nz,nextloop

ld hl,(portsuccessOR)
ld de,(portsuccessAND)
ld a,h
xor d
cpl
ld h,a
ld a,l
xor e
cpl
ld l,a
ld (portimportant),hl

call restore
ei
ld de,(portimportant)
ld hl,(portsuccessOR)
ld b,16
dl1:
push bc
push hl
push de
bit 7,d		;; important??
ld a,'x'
jr z,dl2
;; yes important, but what value?
bit 7,h
ld a,'1'
jr nz,dl2
ld a,'0'
dl2:
call &bb5a
pop de
pop hl
pop bc
add hl,hl
ex de,hl
add hl,hl
ex de,hl
djnz dl1

ld a,'-'
call &bb5a
ld ix,result_buffer

ld de,(portimportant)
ld (ix+0),e
ld (ix+2),d
ld de,(wantedportimportant)
ld (ix+1),e
ld (ix+3),d
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+6),h
ld de,(wantedportsuccessOR)
ld (ix+5),e
ld (ix+7),d
ld bc,4
call simple_results

ret


restore:
;; rom
ld bc,&df00
out (c),c
;; mode/rom
ld bc,&7f00+%10001110
out (c),c
;; pal
ld bc,&7fc0
out (c),c
;; palette
ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c
ld bc,&7f01
out (c),c
ld bc,&7f4b
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c
ld bc,&f700+%10000010
out (c),c
ld bc,&f600
out (c),c
ld bc,&fbbd
ld a,%0000
out (c),a
exx
ld bc,&7f00+%10001110
out (c),c
exx
call crtc_reset

call restore_fdc

ret

fdc_detected:
defb 0

detect_fdc: 
ld      bc,&fb7e			; BC = I/O address of FDC main status register
ld      e,&00			; initial retry count

fdc_detect2:
or      a
dec     e				; decrement retry count
ret     z				; quit if fdc was not ready 

in      a,(c)			; read main status register
and     &c0				; isolate data direction and data ready status flags

xor     &80				; test the conditions 1) data direction: cpu->fdc, 2) fdc ready to accept data
jr      nz,fdc_detect2			; loop if conditions were not correct...

;; to get here, data direction must be from cpu to fdc
;; and fdc must be ready to accept data

inc     c				; BC = FDC data register
out     (c),a			; write command byte (0 = "invalid")
dec     c				; BC = FDC main status register

;; delay 
ex      (sp),hl
ex      (sp),hl
ex       (sp),hl
ex      (sp),hl

;; initialise retry count with 0
ld      e,a

;; check for start of result phase
;;
;; the result phase must activate within 256 reads of the main status register

fdc_detect3:
dec     e				; decrement retry count
ret     z				; quit if fdc was not ready

in      a,(c)			; read main status register
cp      &c0				; test the conditions 1) data direction: fdc->cpu 2) fdc has data ready
jr      c,fdc_detect3          ; loop if conditions were not correct...

;; to get here, the result phase must be active

inc     c				; BC = FDC data register
in      a,(c)			; read data
xor     &80				; is data=&80? (&80 = status for invalid command)
ret     nz				; quit if wrong result was returned..

;; fdc was detected, fdc processed "invalid" command, and returned the correct results.

scf     
ret     


write_fdc:

push    af
push    af
write_fdc2:
in      a,(c)			; read FDC main status register
add     a,a				; transfer bit 7 ("data ready") to carry
jr      nc,write_fdc2         
add     a,a				; transfer bit 6 ("data direction") to carry
jr      nc,write_fdc3

;; conditions not met: fail
pop     af
pop     af
ret     

;;--------------------------------------------------------
;; conditions match to write command byte to fdc
write_fdc3:
pop     af
inc     c				; BC = I/O address for FDC data register
out     (c),a			; write data to FDC data register
dec     c				; BC = I/O address for FDC main status register

;; delay

ld      a,&5
fdc_write2:
dec     a
nop     
jr      nz,fdc_write2         

;; success
pop     af
ret     

restore_fdc:
ld a,(fdc_detected)
or a
ret z

call reset_fdc
;; re-send specify
ld a,3
call write_fdc
ld a,&c*16+1
call write_fdc
ld a,3
call write_fdc
ld a,1
ld bc,&fa7e
out (c),a
ld a,&ff
ld (&BE5F),a
ret

reset_fdc:
xor a
ld (&be5f),a

;; motor off
ld bc,&fa7e
xor a
out (c),a

;; command in progress
ld bc,&fb7e
in a,(c)
bit 4,a
ret z
upd_cmd:
in a,(c)
and &d0
cp &90
jr nz,upd_exec
inc c
xor a
out (c),a
dec c
;; delay 
ex      (sp),hl
ex      (sp),hl
ex       (sp),hl
ex      (sp),hl
jr upd_cmd

upd_exec:
in a,(c)
jp p,upd_exec
and &20
jr z,upd_result
inc c
in a,(c) ;; read data to skip to end
dec c
jr upd_exec

upd_result:
in a,(c)
and &10
ret z
upd_result2:
in a,(c)
cp &c0
jr c,upd_result2
inc c
in a,(c) ;; read result bytes
;; delay 
ex      (sp),hl
ex      (sp),hl
ex       (sp),hl
ex      (sp),hl
dec c
jr upd_result
ret


;;-------------------------------------------

crtc_reset:
ld hl,crtc_default_values
ld b,16
ld c,0
cr1:
push bc
ld b,&bc
out (c),c
inc b
ld a,(hl)
inc hl
out (c),a
pop bc
inc c
djnz cr1
ret

crtc_default_values:
defb 63,40,46,&8e,38,0,25,30,0,7,0,0,&30,0,0,0,0


portsuccessOR:
defw 0
portsuccessAND:
defw 0
wantedportimportant:
defw 0
wantedportsuccessOR:
defw 0

portimportant:
defw 0


;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
;; firmware based output
include "../../lib/fw/output.asm"

result_buffer: equ $


end start
