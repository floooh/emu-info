;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;; 
;; Test ToTO's X-MEM

include "../../lib/testdef.asm"


kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

;; xmem tester 
org &9004
prog_start:

call cls
ld hl,start_message
call output_msg
call wait_key

ld a,&cc
ld (io_check_config),a

ld hl,xmem_config
ld (test_config),hl

ld hl,pages_xmem
ld (pages_config),hl

xor a
ld (rom_at_4000),a


call cls
ld hl,read_rom_message
call output_msg
rrm1:
call &bb06
cp '0'
jr c,rrm1
cp '2'
jr nc,rrm1
sub '0'
ld (read_rom),a

call cls
ld hl,lock_rom_message
call output_msg
lrm1:
call &bb06
cp '0'
jr c,lrm1
cp '2'
jr nc,lrm1
sub '0'
ld (lock_rom),a



call cls
ld hl,cpc_message
call output_msg
cpc1:
call &bb06
cp '0'
jr c,cpc1
cp '4'
jr nc,cpc1
sub '0'
ld (cpc),a


call cls
ld hl,boot_message
call output_msg
boot1:
call &bb06
cp '0'
jr c,boot1
cp '2'
jr nc,boot1
sub '0'
ld (boot),a

call cls
ld ix,tests
call run_tests
call wait_key
ret

boot:
defb 0

cpc:
defb 0

read_rom:
defb 0

lock_rom:
defb 0

read_rom_message:
defb 13,"Read rom link:",13
defb "0: No",13
defb "1: Yes",13
defb 0


lock_rom_message:
defb 13,"Lock rom link:",13
defb "0: Lock",13
defb "1: Free",13
defb 0

cpc_message:
defb 13,"CPC link:",13
defb "0: 464 (running on 464)",13
defb "1: 6128 (running on 464)",13
defb "2: 464 (running on 6128)",13
defb "3: 6128 (running on 6128)",13
defb 0

boot_message:
defb 13,"Boot link",13
defb "0: CPC",13
defb "1: X-MEM",13
defb 0

start_message:
defb "This is an automatic test.",13,13
defb "This test is for testing ToTo's XMEM ram and rom",13
defb "expansion.",13,13
defb "This was tested on my X-MEM",13
defb "Disconnect all other hardware before running this",13
defb "test.",13,13
defb "Press a key to start",13,0

io_check_config:
defb 0

pages_config:
defw 0

rom_at_4000:
defb 0

;; 47 for 7
;; 40 for rom 0

;; 0-31 (not 7) and not 0
;;ROM: 0-31, or 
;;     1-6,8-31, 64=&40 (ROM 0) and 71=&47 (lower ROM)

tests:
;; reporting - for checking other ram
;;DEFINE_TEST "ram page range check",ram_page_range
;; PASS
;;
;; lock:
;; 0: 87,cd,ff etc
;; 20->40: 87
;; 40: 87,cd,ff, etc a3
;; 60->ff: 87

;; read rom off:
;; 0 = 87, lots of ff, 7=fe
;; 40-60 is all ff.
;; 
;; read rom on, not boot, repeat at 40. except 7 is a3 and not fe
;; no repeat after
DEFINE_TEST "rom pages",rom_pages

DEFINE_TEST "ram check (all configs)",ram_config
;; PASS
DEFINE_TEST "ram check (all configs - rom)",ram_config_rom
;; TODO
;;DEFINE_TEST "ram write through rom (c1,c2,c3 configs)",ram_wt
;; PASS
DEFINE_TEST "ram i/o port decode",ram_io_decode
;; PASS
DEFINE_TEST "rom i/o port decode",rom_io_decode
;; TODO: X-MEM ROM page decode (read all and find pattern)
DEFINE_TEST "rom page decode",xmem_rom_page
DEFINE_END_TEST


read_roms:
call kl_u_rom_enable
ld c,0
call kl_rom_select
di
ld hl,rom_data_buffer
ld b,&00
xor a
read_rom1:
push bc
push af
ld bc,&df00
out (c),a

ld a,(&d000)
ld (hl),a
inc hl

pop af
inc a
pop bc
djnz read_rom1
ld bc,&df00
out (c),c
call kl_u_rom_enable
ld c,0
call kl_rom_select
ei
ret

rom_pages:
call read_roms

ld ix,rom_data_buffer
ld bc,256
ld d,8
jp simple_number_grid


rom_data_buffer:
defs 256

xmem_rom_page:
call kl_u_rom_enable
ld c,1
call kl_rom_select
ld a,(&d000)
ld (rom1_data),a

ld c,0
call kl_rom_select

ld a,(&d000)
ld (rom0_data),a

call read_roms

ld hl,rom_data_buffer
ld ix,result_buffer
ld b,0
arp:
ld a,(hl)
ld (ix+0),a
ld a,(rom0_data)
ld (ix+1),a
inc hl
inc ix
inc ix
djnz arp

ld a,(rom1_data)
ld (result_buffer+(1*2)+1),a

ld ix,result_buffer
ld bc,256
jp simple_results

ram_wt:
ld ix,result_buffer
call ram_init


ld b,32
ld c,0
ram_wt2:
push bc
ld a,c
cp 0
jr z,ram_wt3
cp 4
jr nc,ram_wt3
;; 1,2,3
ld b,&7f
or &c0
out (c),a

ld a,&aa
ld (&1000),a
ld a,&bb
ld (&d000),a

;; disable upper rom
call kl_u_rom_disable
call kl_l_rom_disable

call read_ram

ld bc,&7fc0
out (c),c

call read_ram

ram_wt3:

pop bc
inc c
djnz ram_wt2

ld ix,result_buffer
ld bc,32*4
jp simple_results

pages_forward:
defs 32
pages_backward:
defs 32

ram_page_range:

;; forwards
ld b,32
xor a
rpr1b:
push af
push bc
push af
call ram_sel
pop af
add a,5
ld (&5000),a
pop bc
pop af
inc a
djnz rpr1b

ld hl,result_buffer
;;ld hl,pages_forward
ld b,32
xor a
rpr1c:
push af
push bc
push hl
call ram_sel
pop hl
ld a,(&5000)
ld (hl),a
inc hl
pop bc
pop af
inc a
djnz rpr1c

;; backwards
ld b,32
ld a,31
rpr1d:
push af
push bc
push af
call ram_sel
pop af
add a,5
ld (&5000),a
pop bc
pop af
dec a
djnz rpr1d

ld hl,result_buffer+32
;;ld hl,pages_backward
ld b,32
xor a
rpr1e:
push af
push bc
push hl
call ram_sel
pop hl
ld a,(&5000)
ld (hl),a
inc hl
pop bc
pop af
inc a
djnz rpr1e

if 0
ld iy,0
ld ix,result_buffer+2
ld b,32
ld hl,pages_forward
ld de,pages_backward
rpr1f:
ld a,(de)
cp (hl)
ld a,0
jr nz,rpr1g
ld a,(hl)
inc iy
rpr1g:
ld (ix+0),a
inc ix
inc ix
inc de
inc hl
djnz rpr1f
defb &fd
ld a,l
ld (result_buffer),a

ld hl,(pages_config)
ld ix,result_buffer
ld b,33
rpr1h:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
inc hl
djnz rpr1h

ld ix,result_buffer
ld bc,33
call simple_results
endif
ld ix,result_buffer
ld d,16
ld bc,64
call simple_number_grid

ret

pages_xmem:
defb 33
defb 5,6,7,8
defb 9,10,11,12
defb 13,14,15,16
defb 17,18,19,20
defb 21,22,23,24
defb 25,26,27,28
defb 29,30,31,32
defb 33,34,35,36
defs 33-21




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

ram_init:
ld hl,&5000
ld b,32
ld a,31
ri1:
call ram_sel
push af
add a,5
ld (hl),a
pop af
dec a
djnz ri1

ld bc,&7fc0
out (c),c
;; now do main ram
ld hl,&1000
ld (hl),&01

ld hl,&5000
ld (hl),&02

ld hl,&9000
ld (hl),&03

ld hl,&d000
ld (hl),&04

ld c,1
call kl_rom_select
call kl_l_rom_enable
call kl_u_rom_enable
ld a,(&1000)
ld (lowrom_byte),a
ld a,(&d000)
ld (highrom_byte),a
call kl_u_rom_disable
call kl_l_rom_disable
ret

lowrom_byte:
defb 0
highrom_byte:
defb 0

rom_byte:
defb 0

test_config:
defw 0

ram_io_decode:
call ram_init
ld hl,&7fff
ld de,&8100
ld bc,xmem_restore
ld ix,xmem_check
ld iy,xmem_init
jp io_decode

xmem_restore:
xmem_init:
ret

xmem_check:
ld a,&cc
out (c),a
ld a,(&5000)
cp 9
ret

rom0_data:
defb 0
rom1_data:
defb 0

rom_io_decode:
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,(&c000)
ld (rom1_data),a
ld hl,&dfff
ld de,&2000
ld bc,xmem_rom_restore
ld ix,xmem_rom_check
ld iy,xmem_rom_init
jp io_decode

xmem_rom_restore:
xmem_rom_init:
ret

xmem_rom_check:
ld a,1
out (c),a
push bc
ld bc,&7f00+%10000101
out (c),c
ld a,(&c000)
ld c,a
ld a,(rom1_data)
cp c
pop bc
ret


ram_config:
call ram_init

ld hl,(test_config)
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

;; c4->20
;; c5->21
ram_config_rom:
call ram_init


ld hl,(test_config)
ld b,64
ld a,&c0
rcr1:
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
call ccfr

pop hl
inc hl
inc hl
pop bc
pop af
inc a
djnz rcr1
ret

ccfr:
ld a,c
and &7
cp 2
jp z,check_c2_config_roms
jp check_config_roms


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
inc ix
inc ix
inc hl
djnz cc1
pop bc
pop ix
jp check_config

check_config_roms:
push bc
push hl
call kl_l_rom_enable
call kl_u_rom_enable
pop hl
pop bc

ld ix,result_buffer
push ix
push bc
ld b,4
ccr2:
ld a,(hl)
ld (ix+1),a
inc ix
inc ix
inc hl
djnz ccr2
pop bc
pop ix

ld a,c
and &7
cp &3
jr nz,ccr3

ld a,(rom_at_4000)
or a
jr z,ccr3b
ld a,(highrom_byte)
ld (ix+3),a
ccr3b:

;; external ram (e.g. 464)
;; read from rom
ld a,(lowrom_byte)
ld (ix+1),a

ld a,(highrom_byte)
ld (ix+7),a
jp check_config

ccr3:
;; read from rom
ld a,(lowrom_byte)
ld (ix+1),a
ld a,(highrom_byte)
ld (ix+7),a
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
ld (hl),&4
pop bc
ld b,&7f
out (c),c
call read_ram
ld bc,&7fc0
out (c),c
ei
ld ix,result_buffer
ld bc,4
call simple_results
ret

read_ram:
ld hl,&1000
ld a,(hl)
ld (ix+0),a
inc ix
inc ix
ld hl,&5000
ld a,(hl)
ld (ix+0),a
inc ix
inc ix
ld hl,&9000
ld a,(hl)
ld (ix+0),a
inc ix
inc ix
ld hl,&d000
ld a,(hl)
ld (ix+0),a
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
push af
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

push bc
push hl
call kl_l_rom_disable
call kl_u_rom_disable
pop hl
pop bc
ccc2nr3:
pop af

push hl
push bc
;; ensure page 3 is setup
ld bc,&7fc0
out (c),c
ld hl,&d000
ld (hl),&4
pop bc
pop hl

push hl
ld (c2_data_page),a
push af
;; c2 (use c6)
ld b,&7f
add a,4
out (c),a
;; copy code
ld hl,prog_start
ld de,prog_start-&8000+&4000
ld bc,prog_end-prog_start
ldir
pop af
;; set c2
ld b,&7f
out (c),a
;; read 
ld a,(&1000)
ld d,a
ld a,(&5000)
ld e,a
ld a,(&9000)
ld h,a
ld a,(&d000)
ld l,a
ld a,(c2_data_page)
;; restore
ld b,&7f
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
pop hl
ld ix,result_buffer
push ix
push bc
ld b,4
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
ei
ld ix,result_buffer
ld bc,4
call simple_results
ret

c0_pages:
c8_pages:
d0_pages:
d8_pages:
e0_pages:
e8_pages:
f0_pages:
f8_pages:
defb 1,2,3,4

c1_pages:
defb 1,2,3,8 
c9_pages:
defb 1,2,3,12
d1_pages:
defb 1,2,3,16
d9_pages:
defb 1,2,3,20
e1_pages:
defb 1,2,3,24
e9_pages:
defb 1,2,3,28
f1_pages:
defb 1,2,3,32
f9_pages:
defb 1,2,3,36

c2_pages:
defb 5,6,7,8
ca_pages:
defb 9,10,11,12
d2_pages:
defb 13,14,15,16
da_pages:
defb 17,18,19,20
e2_pages:
defb 21,22,23,24
ea_pages:
defb 25,26,27,28
f2_pages:
defb 29,30,31,32
fa_pages:
defb 33,34,35,36

c3_pages:
defb 1,4,3,8 
cb_pages:
defb 1,4,3,12
d3_pages:
defb 1,4,3,16
db_pages:
defb 1,4,3,20
e3_pages:
defb 1,4,3,24
eb_pages:
defb 1,4,3,28
f3_pages:
defb 1,4,3,32
fb_pages:
defb 1,4,3,36


c4_pages:
defb 1,5,3,4
cc_pages:
defb 1,9,3,4	;; 4,5,6,7?
d4_pages:
defb 1,13,3,4 ;
dc_pages:
defb 1,17,3,4
e4_pages:
defb 1,21,3,4
ec_pages:
defb 1,25,3,4
f4_pages:
defb 1,29,3,4
fc_pages:
defb 1,33,3,4

c5_pages:
defb 1,6,3,4
cd_pages:
defb 1,10,3,4
d5_pages:
defb 1,14,3,4
dd_pages:
defb 1,18,3,4
e5_pages:
defb 1,22,3,4
ed_pages:
defb 1,26,3,4
f5_pages:
defb 1,30,3,4
fd_pages:
defb 1,34,3,4


c6_pages:
defb 1,7,3,4
ce_pages:
defb 1,11,3,4
d6_pages:
defb 1,15,3,4
de_pages:
defb 1,19,3,4
e6_pages:
defb 1,23,3,4
ee_pages:
defb 1,27,3,4
f6_pages:
defb 1,31,3,4
fe_pages:
defb 1,35,3,4

c7_pages:
defb 1,8,3,4
cf_pages:
defb 1,12,3,4
d7_pages:
defb 1,16,3,4
df_pages:
defb 1,20,3,4
e7_pages:
defb 1,24,3,4
ef_pages:
defb 1,28,3,4
f7_pages:
defb 1,32,3,4
ff_pages:
defb 1,36,3,4


xmem_config:
defw c0_pages
defw c1_pages
defw c2_pages
defw c3_pages
defw c4_pages
defw c5_pages
defw c6_pages
defw c7_pages

defw c8_pages
defw c9_pages
defw ca_pages
defw cb_pages
defw cc_pages
defw cd_pages
defw ce_pages
defw cf_pages

defw d0_pages
defw d1_pages
defw d2_pages
defw d3_pages
defw d4_pages
defw d5_pages
defw d6_pages
defw d7_pages

defw d8_pages
defw d9_pages
defw da_pages
defw db_pages
defw dc_pages
defw dd_pages
defw de_pages
defw df_pages


defw e0_pages
defw e1_pages
defw e2_pages
defw e3_pages
defw e4_pages
defw e5_pages
defw e6_pages
defw e7_pages

defw e8_pages
defw e9_pages
defw ea_pages
defw eb_pages
defw ec_pages
defw ed_pages
defw ee_pages
defw ef_pages

defw f0_pages
defw f1_pages
defw f2_pages
defw f3_pages
defw f4_pages
defw f5_pages
defw f6_pages
defw f7_pages

defw f8_pages
defw f9_pages
defw fa_pages
defw fb_pages
defw fc_pages
defw fd_pages
defw fe_pages
defw ff_pages




include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/crtc.asm"
include "../../lib/hw/psg.asm"

result_buffer: equ $

prog_end:
end prog_start
