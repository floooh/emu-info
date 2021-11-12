;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; used for testing inicron ram expansion
;;
;; NEEDS TO BE VERIFIED ON A REAL DEVICE - BASED ON SCHEMATICS AND 
;; DOCUMENTATION
org &9001

include "../../lib/testdef.asm"

kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

prog_start:

;; select rom 0 for upper rom
ld c,0
call kl_rom_select

ld hl,test_message
call output_msg

call store_page

ld ix,tests
call run_tests
ret

test_message:
defb "This is an automatic test",13,10
defb "This tests the Inicron RAM. This will write to the Inicron RAM",13,10
defb "so will corrupt any data stored in it.",13,10,13,10
defb "Other expansions which are connected will cause the test to",13,10
defb "give incorrect results. ",13,10,13,10
defb "This test NEEDS to be verified on a real inicron ram device.",13,10,0

tests:


DEFINE_TEST "ram page range check",ram_page_range
;; c0-ff
DEFINE_TEST "ram check (all configs)",ram_config
;; c0-ff
DEFINE_TEST "ram check (all configs - rom)",ram_config_rom
DEFINE_TEST "ram i/o decode",ram_io_decode

DEFINE_END_TEST

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
ret

lowrom_byte:
defb 0
highrom_byte:
defb 0

rom_byte:
defb 0

ram_config:
call ram_init

ld hl,inicron_config
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
call restore_page
ret



;; c4->20
;; c5->21
ram_config_rom:
call ram_init


ld hl,inicron_config
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
call restore_page
ret

ccfr:
ld a,c
and &7
cp 2
jp z,check_c2_config_roms
jp check_config_roms

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


inicron_config:
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
defb 1,2,3,4

c1_pages:
c9_pages:
d1_pages:
d9_pages:
e1_pages:
e9_pages:
f1_pages:
f9_pages:
defb 1,2,3,8 

c2_pages:
ca_pages:
d2_pages:
da_pages:
e2_pages:
ea_pages:
f2_pages:
fa_pages:
defb 5,6,7,8

c3_pages_6128:
defb 1,4,3,8 
cb_pages_6128:
defb 1,4,3,8
d3_pages_6128:
defb 1,4,3,8
db_pages_6128:
defb 1,4,3,8
e3_pages_6128:
defb 1,4,3,8
eb_pages_6128:
defb 1,4,3,8
f3_pages_6128:
defb 1,4,3,8
fb_pages_6128:
defb 1,4,3,8

c3_pages_464:
defb 1,2,3,8 
cb_pages_464:
defb 1,2,3,12
d3_pages_464:
defb 1,2,3,16
db_pages_464:
defb 1,2,3,20
e3_pages_464:
defb 1,2,3,24
eb_pages_464:
defb 1,2,3,28
f3_pages_464:
defb 1,2,3,32
fb_pages_464:
defb 1,2,3,36


c4_pages:
defb 1,5,3,4
cc_pages:
defb 1,9,3,4	
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


ram_page_range:
call memcheck

;; expected 32 pages
ld ix,result_buffer
ld (ix+0),a
ld (ix+1),32
inc ix
inc ix

;; c4,c5,c7,c7,cc,cd,ce,cf etc
ld hl,mem_unique_configs
ld b,32
xor a
rpr:
push af
push hl

push af
ld a,(hl)
ld (ix+0),a
inc ix
pop af


push af
and %11100
add a,a
ld c,a
pop af

and &3
add a,4
or c
or &c0
ld (ix+0),a
inc ix
pop hl
pop af
inc a
inc hl
djnz rpr
call restore_page
ld ix,result_buffer
ld bc,33
call simple_results
ret


store_page:
call kl_u_rom_disable
call kl_l_rom_disable

ld b,32
xor a
ld hl,page_data
sp1:
call ram_sel
push af
ld a,(&5000)
ld (hl),a
pop af
inc a
inc hl
djnz sp1
ret


restore_page:
;; ensure data is poked into ram
call kl_u_rom_disable
call kl_l_rom_disable

ld b,32
xor a
ld hl,page_data
rp1:
call ram_sel
push af
ld a,(hl)
ld (&5000),a
pop af
inc a
inc hl
djnz rp1
ret


init_page:
;; ensure data is poked into ram
call kl_u_rom_disable
call kl_l_rom_disable

ld b,32
ld a,0
ld hl,&5000
ip1:
call ram_sel
ld (hl),a
inc a
djnz ip1
ld bc,&7fc0
out (c),c
ld a,&11
ld (&1000),a
ld a,&22
ld (&7000),a
ld a,&33
ld (&9000),a
ld a,&44
ld (&d000),a
ret



page_data:
defs 32




ram_io_decode:
call kl_l_rom_disable
call kl_u_rom_disable
call ram_init
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
ld bc,&7fc0
out (c),c
ld bc,&7f00+%10001100
out (c),c

pop hl
pop de
pop bc
ld a,&cc
out (c),a
ld a,(&5000)
cp 9
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
;; 01111111xxxxxxxx
;;ld (ix+0),e
;;ld (ix+1),&00
;;ld (ix+2),d
;;ld (ix+3),&80
ld (ix+0),e
ld (ix+1),&00
ld (ix+2),d
ld (ix+3),&80
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&ff
ld (ix+6),h
ld (ix+7),&7f
ld bc,4
call simple_results
call restore_page
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

;;call restore_fdc

call crtc_reset
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
ld bc,&fb7e
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

   

crtc_default_values:
defb 63,40,46,&8e,38,0,25,30,0,7,0,0,&30,0,0,0,0


portsuccessOR:
defw 0
portsuccessAND:
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
include "../../include/memcheck.asm"

result_buffer: equ $

prog_end:
end prog_start