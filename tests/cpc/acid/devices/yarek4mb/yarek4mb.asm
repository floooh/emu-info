;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; 
;; Test Yarek's 4MB internal ram expansion for CPC6128.
;; Thankyou to TFM for testing.

include "../../lib/testdef.asm"


kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

;; yarek 4mb tester 
org &9004
prog_start:


ld a,2
call scr_set_mode
ld hl,start_message
call output_msg
call wait_key


ld a,2
call scr_set_mode
ld ix,tests
call run_tests

ld hl,done_txt
call output_msg
ret

start_message:
defb "This is an automatic test.",13,10,13,10
defb "This test was run on real hardware by TFM",13,10,13,10
defb "This test is for testing Yarek's 4MB internal ram",13,10
defb "expansion for the CPC6128.",13,10,13,10
defb "Disconnect all other hardware before running this",13,10
defb "test.",13,10,13,10
defb "Press a key to start",0


done_txt:
defb "Done!",0

tests:
DEFINE_TEST "ram check (pages)",ram_pages

DEFINE_TEST "ram check (all configs) (78xx)",ram_78xx_config
DEFINE_TEST "ram check (all configs) (79xx)",ram_79xx_config
DEFINE_TEST "ram check (all configs) (7axx)",ram_7axx_config
DEFINE_TEST "ram check (all configs) (7bxx)",ram_7bxx_config
DEFINE_TEST "ram check (all configs) (7cxx)",ram_7cxx_config
DEFINE_TEST "ram check (all configs) (7dxx)",ram_7dxx_config
DEFINE_TEST "ram check (all configs) (7exx)",ram_7exx_config
DEFINE_TEST "ram check (all configs) (7fxx)",ram_7fxx_config

DEFINE_TEST "ram i/o decode (78xx)",ram_78xx_io_decode
DEFINE_TEST "ram i/o decode (79xx)",ram_79xx_io_decode
DEFINE_TEST "ram i/o decode (7axx)",ram_7axx_io_decode
DEFINE_TEST "ram i/o decode (7bxx)",ram_7bxx_io_decode
DEFINE_TEST "ram i/o decode (7cxx)",ram_7cxx_io_decode
DEFINE_TEST "ram i/o decode (7dxx)",ram_7dxx_io_decode
DEFINE_TEST "ram i/o decode (7exx)",ram_7exx_io_decode
DEFINE_TEST "ram i/o decode (7fxx)",ram_7fxx_io_decode

DEFINE_END_TEST

ram_78xx_config:
ld bc,&7800
ld hl,5
jp ram_config

ram_79xx_config:
ld bc,&7900
ld hl,37
jp ram_config

ram_7axx_config:
ld bc,&7a00
ld hl,69
jp ram_config

ram_7bxx_config:
ld bc,&7b00
ld hl,101
jp ram_config

ram_7cxx_config:
ld bc,&7c00
ld hl,133
jp ram_config

ram_7dxx_config:
ld bc,&7d00
ld hl,165
jp ram_config

ram_7exx_config:
ld bc,&7e00
ld hl,197
jp ram_config

ram_7fxx_config:
ld bc,&7f00
ld hl,229
jp ram_config

ram_port:
defb 0

ram_config:
ld a,b
ld (ram_port),a

;; init configs
ex de,hl
ld b,64
ld c,0
ld ix,config
rc1bb:
push ix
push bc
ld l,(ix+0)
ld h,(ix+1)
push hl
pop ix

bit 2,c
jr z,rc2
;; 4,5,6,7
ld a,c
and &3
ld l,a
ld h,0
add hl,de
ld (ix+2),l
ld (ix+3),h
jr rc3

rc2:
ld a,c
and &7
cp 1
jr nz,rc2b
;; 1
ld hl,3
add hl,de
ld (ix+6),l
ld (ix+7),h
jr rc3
rc2b:
cp 3
jr nz,rc4
;; 3
;; 1
ld hl,3
add hl,de
ld (ix+6),l
ld (ix+7),h
jr rc3
rc4:
cp 2
jr nz,rc3
ld hl,0
add hl,de
ld (ix+0),l
ld (ix+1),h
ld hl,1
add hl,de
ld (ix+2),l
ld (ix+3),h
ld hl,2
add hl,de
ld (ix+4),l
ld (ix+5),h
ld hl,3
add hl,de
ld (ix+6),l
ld (ix+7),h
jr rc3
rc3:
pop bc
pop ix
inc ix
inc ix
ld a,c
and &7
cp 7
jr nz,rc1bb2
inc de
inc de
inc de
inc de

rc1bb2:
inc c
dec b
jp nz,rc1bb



call init_pages
ld hl,config
ld b,64
ld a,&c0
rc1:
ld c,a
push af
ld a,c
call outputhex8
ld a,'-'
call output_char

push bc
push hl
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call ccfnr

pop hl
inc hl
inc hl
pop bc
pop af
inc a
djnz rc1
ret

ccfnr:
ld a,c
and &7
cp 2
jp z,check_c2_config
jp check_config_no_roms


check_config_no_roms:
ccnr1:
push bc
push hl
call kl_l_rom_disable
call kl_u_rom_disable
pop hl
pop bc
ld ix,result_buffer
push ix
push bc
ld b,4
cc1:
ld a,(hl)
ld (ix+1),a
inc hl
ld a,(hl)
ld (ix+3),a
inc hl
inc ix
inc ix
inc ix
inc ix
djnz cc1
pop bc
pop ix
jp check_config

check_config:
;; set config
ld ix,result_buffer
di
push bc
;; ensure page 3 is setup
ld bc,&7fc0
out (c),c
ld hl,&d000
ld (hl),4
inc hl
ld (hl),0
pop bc
ld a,(ram_port)
ld b,a
out (c),c
call read_ram
ld bc,&7fc0
out (c),c
ei
ld ix,result_buffer
ld bc,4*2
jp simple_results

read_ram:
ld hl,&1000
ld a,(hl)
ld (ix+0),a
inc hl
ld a,(hl)
ld (ix+2),a
inc ix
inc ix
inc ix
inc ix
ld hl,&5000
ld a,(hl)
ld (ix+0),a
inc hl
ld a,(hl)
ld (ix+2),a
inc ix
inc ix
inc ix
inc ix
ld hl,&9000
ld a,(hl)
ld (ix+0),a
inc hl
ld a,(hl)
ld (ix+2),a
inc ix
inc ix
inc ix
inc ix
ld hl,&d000
ld a,(hl)
ld (ix+0),a
inc hl
ld a,(hl)
ld (ix+2),a
inc ix
inc ix
inc ix
inc ix
ret


c2_data_page:
defb 0

check_c2_config:
ld a,c
ld e,0
jp c2_config_general

check_c2_config_roms:
ld a,c
ld e,1
jp c2_config_general

c2_pages_roms:
defs 4

c2_config_general:
di
exx
push de
push hl
exx
ei
push af
if 0
inc e
dec e
jr z,ccc2nr2
ld a,(lowrom_byte)
ld (c2_pages_roms+0),a
ld a,(highrom_byte)
ld (c2_pages_roms+3),a
inc hl
ld a,(hl)
ld (c2_pages_roms+1),a
inc hl
ld a,(hl)
ld (c2_pages_roms+2),a
ld hl,c2_pages_roms

push bc
push hl
call kl_l_rom_enable
call kl_u_rom_enable
pop hl
pop bc
jr ccc2nr3

ccc2nr2:
endif
push bc
push hl
call kl_l_rom_disable
call kl_u_rom_disable
pop hl
pop bc
ccc2nr3:
pop af

push hl
ld (c2_data_page),a
;; c2 (use c6)
ld a,(ram_port)
ld b,a
push af
ld a,(c2_data_page)
add a,4
out (c),a
;; copy code
ld hl,prog_start
ld de,prog_start-&8000+&4000
ld bc,prog_end-prog_start
ldir
;; c2 (use c6)
ld a,(ram_port)
ld b,a
pop af
ld a,(c2_data_page)
out (c),a
di
;; read 
ld a,(&1000)
ld d,a
ld a,(&1001)
ld e,a
ld a,(&5000)
ld h,a
ld a,(&5001)
ld l,a
exx 
ld a,(&9000)
ld d,a
ld a,(&9001)
ld e,a
ld a,(&d000)
ld h,a
ld a,(&d001)
ld l,a
exx
;; restore
ld a,(ram_port)
ld b,a
ld a,(c2_data_page)
add a,4
out (c),a
ld ix,result_buffer
ld a,d
ld (ix+0),a
ld a,e
ld (ix+2),a
ld a,h
ld (ix+4),a
ld a,l
ld (ix+6),a
exx
ld a,d
ld (ix+8),a
ld a,e
ld (ix+10),a
ld a,h
ld (ix+12),a
ld a,l
ld (ix+14),a
exx
pop hl
ld ix,result_buffer
push ix
push bc
ld b,8
ccr22:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
inc hl
djnz ccr22
pop bc
pop ix
ld bc,&7fc0
out (c),c
exx
pop hl
pop de
exx
ei
ld ix,result_buffer
ld bc,8
jp simple_results


config:
defw c0_pages
defw c1_pages	;; 35
defw c2_pages
defw c3_pages_6128
defw c4_pages ;; 20
defw c5_pages ;; 21 
defw c6_pages ;; 22
defw c7_pages ;; 23
defw c8_pages
defw c9_pages
defw ca_pages
defw cb_pages_6128
defw cc_pages
defw cd_pages
defw ce_pages
defw cf_pages
defw d0_pages
defw d1_pages
defw d2_pages
defw d3_pages_6128
defw d4_pages
defw d5_pages
defw d6_pages
defw d7_pages
defw d8_pages
defw d9_pages
defw da_pages
defw db_pages_6128
defw dc_pages
defw dd_pages
defw de_pages
defw df_pages
defw e0_pages
defw e1_pages
defw e2_pages
defw e3_pages_6128
defw e4_pages
defw e5_pages
defw e6_pages
defw e7_pages
defw e8_pages
defw e9_pages
defw ea_pages
defw eb_pages_6128
defw ec_pages
defw ed_pages
defw ee_pages
defw ef_pages
defw f0_pages
defw f1_pages
defw f2_pages
defw f3_pages_6128
defw f4_pages
defw f5_pages
defw f6_pages
defw f7_pages
defw f8_pages
defw f9_pages
defw fa_pages
defw fb_pages_6128
defw fc_pages
defw fd_pages
defw fe_pages
defw ff_pages


c0_pages:
c8_pages:
d0_pages:
d8_pages:
e0_pages:
e8_pages:
f0_pages:
f8_pages:
defw 1,2,3,4

c1_pages:
defw 1,2,3,8 
c9_pages:
defw 1,2,3,12
d1_pages:
defw 1,2,3,16
d9_pages:
defw 1,2,3,20
e1_pages:
defw 1,2,3,24
e9_pages:
defw 1,2,3,28
f1_pages:
defw 1,2,3,32
f9_pages:
defw 1,2,3,36

c2_pages:
defw 5,6,7,8
ca_pages:
defw 9,10,11,12
d2_pages:
defw 13,14,15,16
da_pages:
defw 17,18,19,20
e2_pages:
defw 21,22,23,24
ea_pages:
defw 25,26,27,28
f2_pages:
defw 29,30,31,32
fa_pages:
defw 33,34,35,36

c3_pages_6128:
defw 1,4,3,8 
cb_pages_6128:
defw 1,4,3,12
d3_pages_6128:
defw 1,4,3,16
db_pages_6128:
defw 1,4,3,20
e3_pages_6128:
defw 1,4,3,24
eb_pages_6128:
defw 1,4,3,28
f3_pages_6128:
defw 1,4,3,32
fb_pages_6128:
defw 1,4,3,36


c4_pages:
defw 1,5,3,4
cc_pages:
defw 1,9,3,4	;; 4,5,6,7?
d4_pages:
defw 1,13,3,4 ;
dc_pages:
defw 1,17,3,4
e4_pages:
defw 1,21,3,4
ec_pages:
defw 1,25,3,4
f4_pages:
defw 1,29,3,4
fc_pages:
defw 1,33,3,4

c5_pages:
defw 1,6,3,4
cd_pages:
defw 1,10,3,4
d5_pages:
defw 1,14,3,4
dd_pages:
defw 1,18,3,4
e5_pages:
defw 1,22,3,4
ed_pages:
defw 1,26,3,4
f5_pages:
defw 1,30,3,4
fd_pages:
defw 1,34,3,4


c6_pages:
defw 1,7,3,4
ce_pages:
defw 1,11,3,4
d6_pages:
defw 1,15,3,4
de_pages:
defw 1,19,3,4
e6_pages:
defw 1,23,3,4
ee_pages:
defw 1,27,3,4
f6_pages:
defw 1,31,3,4
fe_pages:
defw 1,35,3,4

c7_pages:
defw 1,8,3,4
cf_pages:
defw 1,12,3,4
d7_pages:
defw 1,16,3,4
df_pages:
defw 1,20,3,4
e7_pages:
defw 1,24,3,4
ef_pages:
defw 1,28,3,4
f7_pages:
defw 1,32,3,4
ff_pages:
defw 1,36,3,4




ram_pages:
;; init results
ld ix,result_buffer
ld b,0
ld de,5
rp2:
ld (ix+1),e
ld (ix+3),d
inc de
inc ix
inc ix
inc ix
inc ix
djnz rp2

call init_pages

ld ix,result_buffer
ld b,0
ld e,0
rp1:
call select_page
ld a,(&5000)
ld (ix+0),a
ld a,(&5001)
ld (ix+2),a
inc ix
inc ix
inc ix
inc ix
inc e
djnz rp1

ld ix,result_buffer
ld bc,256*2
jp simple_results

;; 10000111
;; 01111000
;; 0xxx0xxx
ram_78xx_io_decode:
ld hl,&78ff
ld de,&8700
ld a,9
jp ram_io_decode

ram_79xx_io_decode:
ld hl,&79ff
ld de,&8700
ld a,41
jp ram_io_decode

ram_7axx_io_decode:
ld hl,&7aff
ld de,&8700
ld a,73
jp ram_io_decode

ram_7bxx_io_decode:
ld hl,&7bff
ld de,&8700
ld a,105
jp ram_io_decode

ram_7cxx_io_decode:
ld hl,&7cff
ld de,&8700
ld a,137
jp ram_io_decode

ram_7dxx_io_decode:
ld hl,&7dff
ld de,&8700
ld a,169
jp ram_io_decode

ram_7exx_io_decode:
ld hl,&7eff
ld de,&8700
ld a,201
jp ram_io_decode

ram_7fxx_io_decode:
ld hl,&7fff
ld de,&8700
ld a,233
jp ram_io_decode


value_check:
defw 0

ram_io_decode:
ld (value_check),a
xor a
ld (value_check+1),a
push de
push hl
call init_pages
pop hl
pop de
ld bc,yarek_restore
ld ix,yarek_check
ld iy,yarek_init
jp io_decode

yarek_restore:
ret

yarek_init:
call restore
ld bc,&7fc0
out (c),c
ld bc,&7f00+%10001100
out (c),c
ret

yarek_check:
ld a,&cc
out (c),a
push hl
push de
ld de,(&5000)
ld hl,(value_check)
or a
sbc hl,de
pop de
pop hl
ret


init_pages:
ld hl,5
ld b,0
ld e,0
init_pages2:
push de
call select_page
ld a,l
ld (&5000),a
ld a,h
ld (&5001),a
pop de
inc hl
inc e
djnz init_pages2
ld bc,&7fc0
out (c),c
ld de,1
ld hl,&1000
ld (hl),e
inc hl
ld (hl),d
inc de
ld hl,&5000
ld (hl),e
inc hl
ld (hl),d
inc de
ld hl,&9000
ld (hl),e
inc hl
ld (hl),d
inc de
ld hl,&d000
ld (hl),e
inc hl
ld (hl),d
inc de

ret

;; 8 bits



;; E = page
select_page:
push de
push bc
push af
;; tttbbbxx
ld a,e
srl a
srl a
srl a
srl a
srl a
and %111
or %01111000
ld b,a

ld a,e
and %11100
add a,a
ld c,a
ld a,e
and %11
add a,4
add a,c
or %11000000
out (c),a
pop af
pop bc
pop de
ret


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
include "../../include/memcheck.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/crtc.asm"

result_buffer: equ $
prog_end:
end prog_start
