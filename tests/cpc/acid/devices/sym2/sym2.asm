;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../../lib/testdef.asm"

kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f
;;scr_set_mode equ &bc0e

;; Symbiface 2 tester 
org &9001
prog_start:
ld a,2
call scr_set_mode

ld hl,test_message
call output_msg

ld hl,j2_message
call output_msg
call &bb06
cp 'Y'
ld c,1
jr z,s1
cp 'y'
ld c,1
jr z,s1
ld c,0
s1:
ld a,c
ld (j2_set),a

ld hl,rom_dis_message
call output_msg
call &bb06
cp 'Y'
ld c,1
jr z,s1b
cp 'y'
ld c,1
jr z,s1b
ld c,0
s1b:
ld a,c
ld (roms_dis),a


ld hl,rom7o_message
call output_msg
call &bb06
cp 'Y'
ld c,1
jr z,s1c
cp 'y'
ld c,1
jr z,s1c
ld c,0
s1c:
ld a,c
ld (rom7_override),a


ld hl,ram_message
call output_msg
call &bb06
cp 'Y'
ld c,1
jr z,s1d
cp 'y'
ld c,1
jr z,s1d
ld c,0
s1d:
ld a,c
ld (is_6128),a


ld a,(is_6128)
or a
jr z,not_6128
;; is a 6128
ld hl,c3_pages_6128
ld (sym2_config+(&c3-&c0)*2),hl
ld hl,cb_pages_6128
ld (sym2_config+(&cb-&c0)*2),hl
ld hl,d3_pages_6128
ld (sym2_config+(&d3-&c0)*2),hl
ld hl,db_pages_6128
ld (sym2_config+(&db-&c0)*2),hl
ld hl,e3_pages_6128
ld (sym2_config+(&e3-&c0)*2),hl
ld hl,eb_pages_6128
ld (sym2_config+(&eb-&c0)*2),hl
ld hl,f3_pages_6128
ld (sym2_config+(&f3-&c0)*2),hl
ld hl,fb_pages_6128
ld (sym2_config+(&fb-&c0)*2),hl
jr done_6128

not_6128:
;; is a 6128
ld hl,c3_pages_464
ld (sym2_config+(&c3-&c0)*2),hl
ld hl,cb_pages_464
ld (sym2_config+(&cb-&c0)*2),hl
ld hl,d3_pages_464
ld (sym2_config+(&d3-&c0)*2),hl
ld hl,db_pages_464
ld (sym2_config+(&db-&c0)*2),hl
ld hl,e3_pages_464
ld (sym2_config+(&e3-&c0)*2),hl
ld hl,eb_pages_464
ld (sym2_config+(&eb-&c0)*2),hl
ld hl,f3_pages_464
ld (sym2_config+(&f3-&c0)*2),hl
ld hl,fb_pages_464
ld (sym2_config+(&fb-&c0)*2),hl

done_6128:

call sf2_restore

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

test_message:
defb "This is an automatic test",13,10,13,10
defb "Test must be run on a CPC or Plus with symbiface 2 hardware ONLY. Other rom boards",13,10
defb "or ram expansions will cause the test to give incorrect results. I ran it on a CPC6128 with symbiface 2 only",13,10,13,10,0

rom7o_message:
defb "Your CPC can override Rom 7? (Yes for Plus and yes for 464 without DDI-1)",13,10,0

j2_message:
defb "J2 connected?",13,10,0

rom_dis_message:
defb "roms 0-7 disabled on symbiface 2?",13,10,0

ram_message:
defb "6128 or 6128 Plus?",13,10,0

is_6128:
defb 0

roms_dis:
defb 0

j2_set:
defb 0

rom7_override:
defb 0


;; fd06 -> 50
;; fd07->fe
;; fd08->b3
;; fd09->6f
;; fd0a ->1
;; fd0b ->1
;; fd0c -> 0
;; fd0d -> 0
;; fd0e -> 0
;; fd0f -> &50
;; fd10 -> 0
;; fd11- fd17 -> ff
;; fd18 -> 0
;; fd19 etc ff

;; another:
;; 50, ff,0,0,1,1,0,0,a0,50,0

;;-----------------------------------------------------
;; TODO: If rom paged 4000-&7fff write to &c000 will also go to rom data?
;; TODO: rom i/o decode
;; TODO: ram check
;; TODO: /exp
;; TODO: reset peripherals port
;; TODO: unmapped read
;; TODO: IM2 
tests:
;; disabled until my rtc is checked
;;DEFINE_TEST "rtc mem r/w",rtc_mem_rw
if 0
;; these 4 pass
DEFINE_TEST "rtc reg d r",rtc_reg_d_r
DEFINE_TEST "rtc reg d r/w",rtc_reg_d_rw
DEFINE_TEST "rtc reg c r",rtc_reg_c_r
DEFINE_TEST "rtc reg c r/w",rtc_reg_c_rw
endif
;; disabled until my rtc is checked
;;DEFINE_TEST "rtc reg a r/w",rtc_reg_a_rw

;; disabled until my rtc is checked
;;DEFINE_TEST "rtc reg 0 r/w",rtc_reg_0_rw
;;DEFINE_TEST "rtc reg 1 r/w",rtc_reg_1_rw
;;DEFINE_TEST "rtc reg 2 r/w",rtc_reg_2_rw
;;DEFINE_TEST "rtc reg 3 r/w",rtc_reg_3_rw
;;DEFINE_TEST "rtc reg 4 r/w",rtc_reg_4_rw
;;DEFINE_TEST "rtc reg 5 r/w",rtc_reg_5_rw
;;DEFINE_TEST "rtc reg 6 r/w",rtc_reg_6_rw
;;DEFINE_TEST "rtc reg 7 r/w",rtc_reg_7_rw
;;DEFINE_TEST "rtc reg 8 r/w",rtc_reg_8_rw
;;DEFINE_TEST "rtc reg 9 r/w",rtc_reg_9_rw
;;DEFINE_TEST "rtc reg 32 r/w",rtc_reg_32_rw

;; see if rom data is accessible through 4000-7fff always regardless of j2 and switches
;; shows data is accessible, and that if upper rom is not active, then we don't read the rom data there
;; it is only visible 4000-7fff
DEFINE_TEST "upper rom map to 4000-7fff (always)", upper_rom_always

;; page in, setup data with ff, then try and repeat using c000.
;; shows writing to c000 doesn't work
DEFINE_TEST "upper rom map to 4000-7fff (write c000)", upper_rom_c000

;; page in, setup data, then read through &c000 using normal rom method
;; this allows us to check j2, rom switches, rom repeat
DEFINE_TEST "upper rom map to 4000-7fff (all roms)", upper_rom_map

;; reads all roms (from c000), and use fd11 to enable and disable
DEFINE_TEST "upper rom map to 4000-7fff (disable fd11)", upper2_rom_map

;; tests 4000-7fff disable using any value
DEFINE_TEST "disable fd17 - all values", upper_rom_dis

;; showing 80 with j2 connected.
;; otherwise j2 causes issues?
DEFINE_TEST "disable fd11 - all values", upper2_rom_dis

;; see if 4000-7fff is disabled when fd11 is used
DEFINE_TEST "upper rom map to 4000-7fff (fd11)", upper2_rom_always

;; checks  c000-ffff with upper rom enable too
DEFINE_TEST "upper rom map to 4000-7fff (c000 - switch ram/rom)", upper_rom_enable_disable
DEFINE_TEST "upper rom map to 4000-7fff (4000 - switch ram/rom)", upper2_rom_enable_disable

;; failed
DEFINE_TEST "upper rom map to 4000-7fff (write through)", wt_upper_rom_map
;; failed!
;;DEFINE_TEST "upper rom map to 4000-7fff (write to 4000)", upper_rom_mir
;; succeeded!
;;DEFINE_TEST "upper rom map to 4000-7fff (write to c000)", upper_rom_mir2

DEFINE_TEST "ram page range check",ram_page_range
;; c0-ff
DEFINE_TEST "ram check (all configs)",ram_config
;; c0-ff
DEFINE_TEST "ram check (all configs - rom)",ram_config_rom

;; 01111111xxxxxxxx
DEFINE_TEST "ram i/o port decode",ram_io_decode
;; 11011111xxxxxxxx
DEFINE_TEST "rom i/o port decode",rom_io_decode
;; 
DEFINE_TEST "sym2 upper rom map i/o port decode",sym2_rom_io_decode

DEFINE_END_TEST

rtc_reg_0_rw:
ld a,0
jr rtc_reg_rw

rtc_reg_1_rw:
ld a,1
jr rtc_reg_rw

rtc_reg_2_rw:
ld a,2
jr rtc_reg_rw

rtc_reg_3_rw:
ld a,3
jr rtc_reg_rw

rtc_reg_4_rw:
ld a,4
jr rtc_reg_rw

rtc_reg_5_rw:
ld a,5
jr rtc_reg_rw

rtc_reg_6_rw:
ld a,6
jr rtc_reg_rw

rtc_reg_7_rw:
ld a,7
jr rtc_reg_rw

rtc_reg_8_rw:
ld a,8
jr rtc_reg_rw

rtc_reg_9_rw:
ld a,9
jr rtc_reg_rw

rtc_reg_32_rw:
ld a,&32
jr rtc_reg_rw

rtc_reg_rw:
di
ld ix,result_buffer
push af
ld a,&b
ld bc,&fd15
out (c),a
ld a,&80
ld bc,&fd14
out (c),a
pop af

;; select register
ld bc,&fd15
out (c),a

ld b,0
ld a,0
rtc_r_rw:
push bc
push af

;; write data
ld bc,&fd14
out (c),a
ld (ix+1),a

;; read it back
;; exclude valid ram bit 
in a,(c)
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
djnz rtc_r_rw

ld a,&b
ld bc,&fd15
out (c),a
ld a,0
ld bc,&fd14
out (c),a


ld ix,result_buffer
ld bc,256
call simple_results
ret


rtc_reg_d_rw:
di
ld ix,result_buffer


ld b,0
ld a,0
rtc_d_rw:
push bc
push af

push af
ld a,&d
ld bc,&fd15
out (c),a
pop af

;; write data
ld bc,&fd14
out (c),a

ld a,&d
ld bc,&fd15
out (c),a
;; read it back
;; exclude valid ram bit 
in a,(c)
and &7f
ld (ix+0),a
inc ix
;; on ds12887a
ld (ix+0),&7f
inc ix

pop af
inc a
pop bc
djnz rtc_d_rw
ld ix,result_buffer
ld bc,256
call simple_results
ret

rtc_reg_c_rw:
di
ld ix,result_buffer

ld a,&b
ld bc,&fd15
out (c),a
ld a,&80
ld bc,&fd14
out (c),a

;; select register
ld a,&c
ld bc,&fd15
out (c),a

ld b,0
ld a,0
rtc_c_rw:
push bc
push af

;; write data
ld bc,&fd14
out (c),a

;; read it back
;; exclude valid ram bit 
in a,(c)
ld (ix+0),a
inc ix
;; on ds12887a
ld (ix+0),&ff
inc ix

pop af
inc a
pop bc
djnz rtc_c_rw

ld a,&b
ld bc,&fd15
out (c),a
ld a,&00
ld bc,&fd14
out (c),a

ld ix,result_buffer
ld bc,256
call simple_results
ret

rtc_reg_a_rw:
di
ld ix,result_buffer

ld a,&b
ld bc,&fd15
out (c),a
ld a,&80
ld bc,&fd14
out (c),a

;; select register
ld a,&a
ld bc,&fd15
out (c),a

ld b,0
ld a,0
rtc_a_rw:
push bc
push af

;; write data
ld bc,&fd14
out (c),a
and &7f
ld (ix+1),a

;; read it back
in a,(c)
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
djnz rtc_a_rw

ld a,&b
ld bc,&fd15
out (c),a
ld a,&00
ld bc,&fd14
out (c),a

ld ix,result_buffer
ld bc,256
call simple_results
ret


rtc_reg_d_r:
di
ld ix,result_buffer
;; select register
ld a,&d
ld bc,&fd15
out (c),a
ld bc,&fd14
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

ld a,&b
ld bc,&fd15
out (c),a
ld a,&00
ld bc,&fd14
out (c),a

ld ix,result_buffer
ld bc,1
call simple_results
ret

rtc_reg_c_r:
di
ld a,&b
ld bc,&fd15
out (c),a
ld a,&80
ld bc,&fd14
out (c),a

;; clear
ld a,&c
ld bc,&fd15
out (c),a
ld bc,&fd14
in a,(c)

ld ix,result_buffer
;; select register
ld a,&c
ld bc,&fd15
out (c),a
ld bc,&fd14
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&00
inc ix
ld ix,result_buffer
ld bc,1
call simple_results
ret



;; check ram registers work like ram - they will accept any data
rtc_mem_rw:
di
ld ix,result_buffer
ld b,128-&e
ld a,&e
rtcrw:
push bc
push af
;; ignore this register
;;cp &32
;;jr z,rtcrw2
ld d,a
;; select register
ld bc,&fd15
out (c),a

;; read/write data to it
ld b,0
xor a
rtcrw3:
push bc
push af
ld bc,&fd15
out (c),d
;; write data to register
ld bc,&fd14
out (c),a
ld bc,&fd15
out (c),d
ld bc,&fd14
;; read it back
in c,(c)
cp c
jr nz,rtcrw4


pop af
inc a
pop bc
djnz rtcrw3
ld a,1
rtcrw5:
ld (ix+0),a
inc ix
ld (ix+0),1
inc ix

;;rtcrw2:
pop af
inc a
pop bc
djnz rtcrw
ld ix,result_buffer
ld bc,128-&e
call simple_results
ret

rtcrw4:
pop af
pop bc
ld a,0
jr rtcrw5

ram_io_decode:
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
ld a,&33
ld (&5000),a

pop hl
pop de
pop bc
ld a,&cc
out (c),a
ld a,&55
ld (&5000),a
push bc
ld bc,&7fc0
out (c),c
pop bc
ld a,(&5000)
cp &33
jr nz,next
push bc
ld bc,&7fcc
out (c),c
pop bc
ld a,(&5000)
cp &55
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
ld (ix+3),&ff
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&ff
ld (ix+6),h
ld (ix+7),&7f
ld bc,4
call simple_results

ret

sym2_rom_io_decode:
di
ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl
ld de,0
ld bc,0
nextloop2:
push bc
push de
push hl
call restore
call init_roms_val
ld bc,&7f00+%10001100
out (c),c
ld bc,&fd17
out (c),c
ld a,&33
ld (&5000),a

pop hl
pop de
pop bc
ld a,&1
out (c),a
push bc
ld bc,&7f00+%10001100
out (c),c

ld bc,&fd17
in a,(c)
ld a,&55
ld (&5000),a

ld bc,&df01
out (c),c
ld bc,&fd17
out (c),c
pop bc
ld a,(&5000)
cp &33
jr nz,next2
push bc
ld bc,&fd17
in a,(c)
pop bc
ld a,(&5000)
cp &55
jr nz,next2

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

next2:
inc bc
dec de
ld a,d
or e
jr nz,nextloop2

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
dl12:
push bc
push hl
push de
bit 7,d		;; important??
ld a,'x'
jr z,dl22
;; yes important, but what value?
bit 7,h
ld a,'1'
jr nz,dl22
ld a,'0'
dl22:
call &bb5a
pop de
pop hl
pop bc
add hl,hl
ex de,hl
add hl,hl
ex de,hl
djnz dl12

ld a,'-'
call &bb5a
ld ix,result_buffer
ld de,(portimportant)
ld (ix+0),e
ld (ix+1),&ff
ld (ix+2),d
ld (ix+3),&ff
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&17
ld (ix+6),h
ld (ix+7),&fd
ld bc,4
call simple_results

ret

rom_io_decode:
di

call init_roms_val
ld bc,&fd17
out (c),c

ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl
ld de,0
ld bc,0
nextloop3:
push bc
push de
push hl
call restore

pop hl
pop de
pop bc
ld a,&1
out (c),a
push bc
ld bc,&7f00+%10000100
out (c),c
pop bc
ld a,(&c000)
cp &1
jr nz,next3

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

next3:
inc bc
dec de
ld a,d
or e
jr nz,nextloop3

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
dl13:
push bc
push hl
push de
bit 7,d		;; important??
ld a,'x'
jr z,dl23
;; yes important, but what value?
bit 7,h
ld a,'1'
jr nz,dl23
ld a,'0'
dl23:
call &bb5a
pop de
pop hl
pop bc
add hl,hl
ex de,hl
add hl,hl
ex de,hl
djnz dl13

ld a,'-'
call &bb5a
ld ix,result_buffer
ld de,(portimportant)
ld (ix+0),e
ld (ix+1),&00
ld (ix+2),d
ld (ix+3),&ff
ld hl,(portsuccessOR)
ld (ix+4),l
ld (ix+5),&ff
ld (ix+6),h
ld (ix+7),&df
ld bc,4
call simple_results

ret



restore:

call sf2_restore

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

call crtc_reset
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

portimportant:
defw 0



















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

ram_config:
call ram_init

ld hl,sym2_config
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


ld hl,sym2_config
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



sym2_config:
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

c3_pages_6128:
defb 1,4,3,8 
cb_pages_6128:
defb 1,4,3,12
d3_pages_6128:
defb 1,4,3,16
db_pages_6128:
defb 1,4,3,20
e3_pages_6128:
defb 1,4,3,24
eb_pages_6128:
defb 1,4,3,28
f3_pages_6128:
defb 1,4,3,32
fb_pages_6128:
defb 1,4,3,36

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

ld ix,result_buffer
ld bc,33
call simple_results
ret

rom7_byte:
defb 1	;; amsdos for cpc6128

;; write 0-31 for each rom in symbiface 2
init_roms_val:
ld hl,&4000
xor a
ld b,32
urca:
push bc
push af
ld b,&df
out (c),a

push af
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
pop af

ld (hl),a

pop af
pop bc
inc a
djnz urca
ret

;; setup roms with ff
init_roms_ff:
ld hl,&4000
xor a
ld b,32
urcaff:
push bc
push af
ld b,&df
out (c),a

;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)

ld (hl),&ff

pop af
pop bc
inc a
djnz urcaff
ret


upper_rom_c000:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select

di

;; disable upper rom
ld bc,&7f00+%10001100
out (c),c

ld ix,result_buffer

call init_roms_ff

ld hl,&c000
ld (hl),&33

ld hl,&c000
ld b,32
xor a
urc1:
push bc
push af

ld b,&df
out (c),a
push af
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
pop af
ld (hl),a	;; write to c000

ld (ix+1),&ff ;; no change

res 7,h
ld a,(hl)	;; read from 4000
ld (ix+0),a
set 7,h

inc ix
inc ix
pop af
inc a
pop bc
djnz urc1

call init_roms_ff

ld hl,&c000
ld b,32
xor a
urcc1:
push bc
push af
ld b,&df
out (c),a
push af
ld bc,&7f00+%10000100
out (c),c
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
pop af
ld (hl),a	;; write to c000
ld (ix+1),&ff	;; ?? when all disabled!

ld bc,&7f00+%10001100
out (c),c

res 7,h
ld a,(hl)	;; read from 4000
ld (ix+0),a
set 7,h
inc ix
inc ix
pop af
inc a
pop bc
djnz urcc1

call sf2_restore

ei
ld ix,result_buffer
ld bc,64
call simple_results
ret


upper_rom_always:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select

di

;; disable upper rom
ld bc,&7f00+%10001100
out (c),c

ld ix,result_buffer

call init_roms_val

;; in ram
ld hl,&c000
ld (hl),&33

ld hl,&4000
ld b,32
xor a
ura1:
push bc
push af
ld b,&df
out (c),a
push af
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
pop af
ld (ix+1),a	;; see the programmed value

ld a,(hl)
ld (ix+0),a	;; read what we see

set 7,h
ld a,(hl)
ld (ix+2),a	;; what value at &c000
ld (ix+3),&33 ;; see ram
res 7,h

inc ix
inc ix
inc ix
inc ix
pop af
inc a
pop bc
djnz ura1

call sf2_restore

ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret

upper2_rom_always:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di

ld ix,result_buffer

ld hl,&4000
ld (hl),&33

call init_roms_val

ld hl,&4000
ld b,32
xor a
urarr1:
push bc
push af
ld b,&df
out (c),a
push af
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
;; disable roms
ld bc,&fd11
out (c),c
pop af
ld (ix+1),a	;; doesn't change 4000-7fff
ld (ix+3),a ;; doesn't change 4000-7fff

ld a,(hl)
ld (ix+0),a
inc ix
inc ix

ld bc,&fd11
in a,(c)
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
djnz urarr1

call sf2_restore

ei
ld ix,result_buffer
ld bc,32*2
call simple_results
ret


nosf2_get_rom_byte:
cp 7
ld a,(rom7_byte)
ret z
ld a,&80
ret

if 0
combine:
bit 0,c
jr nz,no_comb

ld a,(roms_dis)
or a
jr z,cmb
;; roms disabled
ld a,c
and &1f
cp 8
jr nc,cmb
;; less than 8
no_comb:
;; lower are disabled, do not combine
or a 
ret
cmb:
ld a,(j2_set)
or a
jr z,cmb2
;; j2 set
ld a,c
and &1f
cp 8
jr c,cmb2
;; upper are disabled, do not combine
or a
ret
cmb2:
;; upper and/or lower are enabled
ld a,(rom7_override)
or a
jr z,cmb3
;; rom 7 override, but choosing rom 7?
ld a,c
cp 7
jr nz,cmb3
;; no rom 7 override; choosing rom 7 do not combine
or a
ret
cmb3:
;; lower are enabled and/or upper are enabled
;; and/or rom 7 is override
scf
ret
endif






;; roms_dis is set: return 0x080 for all but rom 7. for rom 7 return rom 7 data.
;; roms_dis is clear: return symbiface 2 roms for all but 7. if rom 7 override, return symbiface 2 rom 7, otherwise return rom 7 data.
;; j2 is set: return 0x080 for 8 or above.
;; j2 is clear: return symbiface for 8 or above.

get_rom_byte:
ld c,a

ld a,(roms_dis)
or a
jr z,grb1
;; roms disabled

;; rom 7?
ld a,c
cp 7
jr nz,gr1b

;; return rom 7 byte
ld a,(rom7_byte)
ret

gr1b:
;; less than 8?
ld a,c
and &1f
cp 8
ld a,&80	;; roms disabled, return basic byte
ret c
;; 8 or above..

grb1:
;; j2 connected? return basic for all above 
ld a,(j2_set)
or a
jr z,grb2
;; j2 is set
ld a,c
and &1f
cp 8
ld a,&80
ret nc

grb2:
ld a,c
cp 7
jr nz,grb22

;; enabled... rom 7?
ld a,(rom7_override)
or a
ld a,(rom7_byte)
ret z

grb22:
;; return value anded with 1f
ld a,c
and &1f
ret



;; if roms disabled through switches and j2 is connected
;; then 80 will show for all except rom 7. (Rom 7 will either show rom 7
;; or the data from symbiface depending on if override is reliable or not)
;;
;; if j2 is not connected but all roms are disabled we see 8-31, others show
;; basic etc
;;
;; if j2 is connected but roms are enabled through switches
;; we see 0-7 only. (rom 7 value depends on if override is possible or not)
;;
;; if j2 is not connected and roms are enabled then we see all 0-31.
;; rom 7 of course depends on if override is possible or not
upper_rom_map:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di

ld ix,result_buffer

call init_roms_val

;; disable upper rom
ld bc,&fd17
out (c),c

ld hl,&c000
ld b,0
xor a
ur21:
push bc
push af
ld b,&df
out (c),a
;; enable upper rom
ld bc,&7f00+%10000100
out (c),c
call get_rom_byte
ld (ix+1),a

;; read actual value
ld a,(hl)
ld (ix+0),a
inc ix
inc ix
pop af
inc a
pop bc
djnz ur21

call sf2_restore

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

;; 
upper2_rom_map:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di

ld ix,result_buffer

ld hl,&c000
ld (hl),&34
ld hl,&4000
ld (hl),&35

call init_roms_val

ld hl,&c000
ld b,0
xor a
ur2d1:
push bc
push af
ld b,&df
out (c),a

;; enable roms
push af
push af
ld bc,&fd11
in a,(c)
pop af

;; enable upper rom
ld bc,&7f00+%10000100
out (c),c
;; 80 all the time!
;;call get_rom_byte
call nosf2_get_rom_byte
ld (ix+1),a

;; read actual value
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

;; disable
ld bc,&fd11
out (c),c

;; enable upper rom
ld bc,&7f00+%10000100
out (c),c
pop af
call nosf2_get_rom_byte
ld (ix+1),a

;; read actual value
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
djnz ur2d1

call sf2_restore

ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret


;; choose rom 1 and use various values to disable the rom paged in
upper_rom_dis:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di

;; upper rom 1
ld bc,&df01
out (c),c

ld ix,result_buffer
ld hl,&4000
xor a
ld b,0
urd1:
push bc
push af

;; disable
ld bc,&fd17
out (c),c
;; store value
ld (hl),&ff

push af
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
pop af

;; write value
ld (hl),&33

;; disable it using value
ld bc,&fd17
out (c),a

;; read it
ld a,(hl)
ld (ix+0),a
inc ix
;; expect disabled
ld (ix+0),&ff
inc ix

pop af
pop bc
inc a
djnz urd1

call sf2_restore

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


upper2_rom_dis:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di

call init_roms_val

ld bc,&7f00+%10001100
out (c),c

ld hl,&c000
ld (hl),&ff

;; upper rom 1
ld bc,&df01
out (c),c

ld bc,&7f00+%10000100
out (c),c

ld ix,result_buffer
ld hl,&c000
xor a
ld b,0
urddd1:
push bc
push af

;; disable any value
ld bc,&fd11
out (c),a

ld a,(hl)
ld (ix+0),a
inc ix
ld a,1
call nosf2_get_rom_byte
ld (ix+0),a
inc ix

ld bc,&fd11
in a,(c)

ld a,(hl)
ld (ix+0),a
inc ix
ld a,1
call get_rom_byte
ld (ix+0),a
inc ix

pop af
pop bc
inc a
djnz urddd1

call sf2_restore

ei
ld ix,result_buffer
ld bc,256*2
call simple_results
ret


upper_rom_enable_disable:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di
ld ix,result_buffer

;; write to ram
ld hl,&4000
ld (hl),&31
ld hl,&c000
ld (hl),&37
call init_roms_val

ld bc,&fd17
out (c),c

ld hl,&c000
ld b,32
ld a,0
ur2:
push bc
push af
ld b,&df
out (c),a

push af
ld (ix+1),&37
call get_rom_byte
ld (ix+3),a
ld (ix+5),&37
pop af
call nosf2_get_rom_byte
ld (ix+7),a

;; disable upper rom
ld bc,&7f00+%10001100
out (c),c

;; disable map to &4000-&7fff
ld bc,&fd17
out (c),c

;; ram
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

;; enable upper rom
ld bc,&7f00+%10000100
out (c),c

;; rom
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

ld bc,&7f00+%10001100
out (c),c

;; map to &4000-&7fff
ld bc,&fd17
in a,(c)

ld a,(hl)
ld (ix+0),a
inc ix
inc ix

;; enable upper rom
ld bc,&7f00+%10000100
out (c),c

;; upper rom not visible, only 4000
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
dec b
jp nz,ur2

call sf2_restore

ei
ld ix,result_buffer
ld bc,32*4
call simple_results
ret

upper2_rom_enable_disable:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di
ld ix,result_buffer

;; write to ram
ld hl,&4000
ld (hl),&31
ld hl,&c000
ld (hl),&37
call init_roms_val

ld bc,&fd17
out (c),c

ld hl,&4000
ld b,32
ld a,0
ur2z:
push bc
push af
ld b,&df
out (c),a

ld (ix+1),&31
ld (ix+3),&31
;;call get_rom_byte	;; shows 0,0,1,1,2,2,3,3,etc for  disabled
ld (ix+5),a
ld (ix+7),a

;; disable upper rom
ld bc,&7f00+%10001100
out (c),c

;; disable map to &4000-&7fff
ld bc,&fd17
out (c),c

;; ram
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

;; enable upper rom
ld bc,&7f00+%10000100
out (c),c

;; rom
ld a,(hl)
ld (ix+0),a
inc ix
inc ix

ld bc,&7f00+%10001100
out (c),c

;; map to &4000-&7fff
ld bc,&fd17
in a,(c)

ld a,(hl)
ld (ix+0),a
inc ix
inc ix

;; enable upper rom
ld bc,&7f00+%10000100
out (c),c

ld a,(hl)
ld (ix+0),a
inc ix
inc ix

pop af
inc a
pop bc
dec b
jp nz,ur2z

call sf2_restore

ei
ld ix,result_buffer
ld bc,32*4
call simple_results
ret


upper_rom_mir:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di
ld ix,result_buffer


;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)

;; select upper rom
ld bc,&df01
out (c),c

;; ensure upper rom is enabled
ld bc,&7f00+%10000100
out (c),c

ld hl,&4000
ld b,0
urm1a:
push hl
push bc

;; write to &4000-&40ff and see it mirror in &c000
ld b,&00
xor a
urm2:
ld (hl),a
set 7,h
cp (hl)
ld d,0		;; not same
jr nz,urm3
res 7,h
inc a
djnz urm2
ld d,1
urm3:
ld (ix+0),d
inc ix
ld (ix+0),1
inc ix

pop bc
pop hl
inc hl
djnz urm1a

call sf2_restore

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret

sf2_restore:
ld bc,&7f00+%10001100
out (c),c
ld bc,&fd17
out (c),c
ld bc,&fd11
in a,(c)
ld bc,&df00
out (c),c
ret


upper_rom_mir2:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di
ld ix,result_buffer


;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)

;; select upper rom
ld bc,&df01
out (c),c

;; ensure upper rom is enabled
ld bc,&7f00+%10000100
out (c),c

ld hl,&c000
ld b,0
urm11a:
push hl
push bc

;; write to &4000-&40ff and see it mirror in &c000
ld b,&00
xor a
urm21:
ld (hl),a
res 7,h
cp (hl)
ld d,0		;; not same
jr nz,urm31
set 7,h
inc a
djnz urm21
ld d,1
urm31:
ld (ix+0),d
inc ix
ld (ix+0),1
inc ix

pop bc
pop hl
inc hl
djnz urm11a

call sf2_restore

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


wt_upper_rom_map:
call kl_l_rom_disable
call kl_u_rom_disable
;; select rom 0 for upper rom
ld c,0
call kl_rom_select
di
ld ix,result_buffer

;; setup ram underneath
ld hl,&4000
ld b,0
xor a
wurm1:
ld (hl),a	;;4xxx
set 7,h
ld (hl),a	;;cxxx
res 7,h
inc hl
inc a
djnz wurm1

;; select upper rom
ld bc,&df01
out (c),c

ld hl,&4000
ld b,0
xor a
wurm2:
push hl
push bc
push af

push af
;; enable upper rom
ld bc,&7f00+%10000100
out (c),c
;; map upper rom to 4000-7fff
ld bc,&fd17
in a,(c)
pop af
;; setup expected results (no write through on 4000-7fff,
;; write through happens at &c000-&ffff)
ld (ix+1),a
cpl 
ld (ix+3),a	
;; peform write to &4000
ld (hl),a
set 7,h
;; perform write to &c000
ld (hl),a
res 7,h

;; disable rom at 4000
ld bc,&fd17
out (c),c

;; read 
ld a,(hl)
ld (ix+0),a
;; disable upper rom
ld bc,&7f00+%10001100
out (c),c
set 7,h
;; read
ld a,(hl)
ld (ix+2),a
res 7,h

inc ix
inc ix
inc ix
inc ix
pop af
pop bc
pop hl
inc hl
inc a
djnz wurm2

call sf2_restore
ei
ld ix,result_buffer
ld bc,256*2
call simple_results
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

result_buffer: equ $

prog_end:
end prog_start
