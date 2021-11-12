;; (c) Copyright Kevin Thacker 2015-2017
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

prog_start:

ld hl,copy_result_fn
ld (cr_functions),hl

call cls
ld hl,intro_message
call output_msg
call wait_key

call cls
ld ix,tests
jp run_tests

intro_message:
defb "This is an automatic test.",13,13
defb "This tests the Multiface 2 device.",13,13
defb "Please ensure the Multiface 2 is visible (do not press stop button",13,13
defb "and return to BASIC). Power machine on/off to make it visible.",13,13
defb "Other expansions which are connected may cause the test to",13
defb "give incorrect results. ",13,13
defb "Tested on MF2 for CPC. On CPC6128 with type 2. MF2 made ",13
defb "hidden by pressing Stop and returning to basic.",13
defb "Press any key to continue",0

;; press stop when ram/rom enabled.
;; TODO: multiface disabled
;; TODO: multiface disabled when reading address
;; TODO: /EXP
;; TODO: MF2 execute code to hide it the ram etc
;; TODO: MF2 must page in rom; what is the mechanism to make sure rom selection works?
;; 0064,0065,0066, try both opcode read AND i/o read/write to make it trigger?
;; TODO: clear ram, write to I/O and find address for it.

tests:

;; 17ff = 82
;; 1cff = f
;; 1db0 = crtc reg 0-f
;; 1f90 = pens 0-f
;; 1fcf = 10
;; 1fdf = 50
;; 1fff = c0
;;DEFINE_TEST "dump ram",mf2_ram

;; mf2 hidden, got 18 expected 0c
DEFINE_TEST "F8FF peripheral reset",f8ff_1
;; a3,c9,03,04,05,06,87,ae
;; 01,09,03,04,05,06,87,ae
;; a3,c9,03,04,05,06,87,ae
;; 01,09,03,04,05,06,07,08
;; 
;; c9->9
;; 2->9
DEFINE_TEST "MF2 enable",mf2_enable
;; got 1
;; ea->got 0
DEFINE_TEST "MF2 write to &1000 mirror in &3000?",rom_wr
;; got 18
DEFINE_TEST "CRTC reg write",crtc_reg_write
;; 0,30
DEFINE_TEST "CRTC reg sel",crtc_reg_sel
;; 1 for all
DEFINE_TEST "CRTC reg data",crtc_reg_data
;; 82
DEFINE_TEST "GA pen i/o write",ga_pen_write
;; 10,08
DEFINE_TEST "GA pen 2 i/o write",ga2_pen_write
;; 0 for all 
DEFINE_TEST "GA border i/o write",ga_border_write
;; 0 for all
DEFINE_TEST "GA ink i/o write",ga_ink_write
;; writing the rom config causes the mf2 rom to be paged out
;; we can't verify all numbers
;; 18x4,0x4 etc
DEFINE_TEST "GA mode write",ga_mode_write
;; 0 for all
DEFINE_TEST "PAL write",pal_write
;; c9 for all
DEFINE_TEST "PPI control write",ppi_control_write
DEFINE_TEST "fee8 data i/o decode (long)",mf2_data_io_decode
DEFINE_TEST "MF2 ram (&2000-&3fff) (long)",ram_check
DEFINE_TEST "MF2 rom (&0000-&3fff) (long)",rom_check
DEFINE_TEST "MF2 ram write through ram (long)",ram_wt
DEFINE_TEST "MF2 rom write through ram (long)",rom_wt
DEFINE_TEST "PPI I/O decode",ppi_io_decode
DEFINE_TEST "GA PEN I/O decode",ga_pen_io_decode
DEFINE_TEST "PAL I/O decode",pal_io_decode
DEFINE_TEST "CRTC REG I/O decode",crtc_reg_io_decode
DEFINE_TEST "fee8/feea i/o decode (long)",mf2_enable_io_decode

;; pass pass etc
DEFINE_TEST "call 0065",call_0065
DEFINE_TEST "call 0064",call_0064
DEFINE_TEST "read 0065",read_0065
DEFINE_TEST "read 0064",read_0064
DEFINE_END_TEST

res_read_0065:
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,&8
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,&8
defb &01,&2,&3,&4,&5,&6,&7,&8
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,&8
defb &01,&2,&3,&4,&5,&6,&7,&8
defb &fe,&00

call_0065:
call kl_u_rom_disable
call kl_l_rom_disable
ld c,0
call kl_rom_select

di
ld bc,&feea
out (c),c

ld a,(&b000)
ld (b000_store),a

ld a,&01
ld (&1000),a	;;0/1,2/3
ld a,&02
ld (&3000),a
ld a,&03		;;4/5,6/7
ld (&5000),a
ld a,&04
ld (&7000),a
ld a,&05
ld (&9000),a	;;8/9,a/b
ld a,&06
ld (&b000),a
ld a,&07
ld (&d000),a ;; c/d, e/f
ld a,&08
ld (&f000),a
di 

ld ix,result_buffer

ld bc,&7f00+%10000000+%10
out (c),c

ld a,(&1000)
ld (lrom_1000_store),a
ld a,(&3000)
ld (lrom_3000_store),a
ld a,(&d000)
ld (urom_d000_store),a
ld a,(&f000)
ld (urom_f000_store),a

ld bc,&fee8
out (c),c
ld a,(&1000)
ld (mf2_rom_store),a
ld a,&09
ld (&3000),a
ld bc,&feea
out (c),c
ld ix,result_buffer

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;; visible
call &0065
call read_ram ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;;  ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ei
ld ix,result_buffer
ld hl,res_read_0065
call copy_results

ld ix,result_buffer
ld bc,5*8
jp simple_results

mf2_ram:
call kl_l_rom_enable
ld c,0
call kl_rom_select
di 
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
ld hl,&2000
ld e,l
ld d,h
inc de
ld bc,&2000-1
ld (hl),0
ldir
ld b,&7f

ld c,&10
ld d,&5f-&10
ld e,16
mf2r2:
out (c),c
out (c),d
inc c
inc d
dec e
jr nz,mf2r2

ld c,0
ld d,&40
ld e,17
mf2r:
out (c),c
out (c),d
inc c
inc d
dec e
jr nz,mf2r

ld bc,&bc00
ld d,32
ld e,0
mf2r22:
out (c),c
inc b
out (c),e
dec b
inc e
dec d
jr nz,mf2r22
call crtc_reset

ld bc,&7f80+%10001000+%10
out (c),c
ld bc,&7fc0
out (c),c
ld bc,&f603
out (c),c
ld bc,&f403
out (c),c
ld bc,&f506
out (c),c
ld bc,&f782
out (c),c
ld bc,&df07
out (c),c
ld hl,&2000
ld de,&4000
ld bc,&2000
ldir

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c
ld bc,&7fc0
out (c),c

ei
ld ix,&4000
ld bc,&2000
ld d,16
jp simple_number_grid

mf2_data_io_decode:
ld h,&0
ld l,&0
ld de,&fee8
ld bc,mf2_io_restore
ld ix,mf2_data_dec_test
ld iy,mf2_dec_init
jp data_decode



mf2_data_dec_test:
ld hl,&2000 ;; potentially write to mf2 ram
ld (hl),&33
ld a,(hl)
push bc
ld bc,&7fc0
out (c),c
pop bc
cp &33 ;; mf2 ram should change
ret nz
push bc
ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
ld a,(hl)
pop bc
cp &aa ;; ram must be unchanged
ret nz
ret

copy_result_fn:
defw write_mf2_rom_store
defw write_lrom_1000_store
defw write_lrom_3000_store
defw write_urom_d000_store
defw write_urom_f000_store

b000_store:
defb 0
mf2_rom_store:
defb 0
lrom_1000_store:
defb 0
lrom_3000_store:
defb 0
urom_d000_store:
defb 0
urom_f000_store:
defb 0

write_mf2_rom_store:
ld a,(mf2_rom_store)
ld (ix-1),a
ret

write_lrom_1000_store:
ld a,(lrom_1000_store)
ld (ix-1),a
ret

write_lrom_3000_store:
ld a,(lrom_3000_store)
ld (ix-1),a
ret

write_urom_d000_store:
ld a,(urom_d000_store)
ld (ix-1),a
ret

write_urom_f000_store:
ld a,(urom_f000_store)
ld (ix-1),a
ret

pal_write:
di
ld ix,result_buffer
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld b,&7f
ld d,&c0
ld e,32
pw1:
ld a,d
and &7
cp 2
jr z,pw2
out (c),d
ld hl,&3fff
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
pw2:
inc d
dec e
jr nz,pw1

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c
ld bc,&7fc0
out (c),c

ei
ld ix,result_buffer
ld bc,32-4
jp simple_results





ppi_control_write:
di
ld ix,result_buffer
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld b,&f7
ld d,0
ld e,0
ppicw1:
out (c),d
;; 3aa8??
ld hl,&37ff
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
inc d
dec e
jr nz,ppicw1

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c
ld bc,&7fc0
out (c),c
ld bc,&f782
out (c),c
ei
ld ix,result_buffer
ld bc,256
jp simple_results

;; can't read properly because it disables mf2 ram...
ga_mode_write:
di
ld ix,result_buffer


ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld b,&7f
ld d,&80
ld e,32
gmw1:
out (c),d

ld hl,&3fef
ld a,(hl)
ld (ix+0),a
inc ix
ld a,d
bit 2,a		;; lower rom disabled?
jr z,gmw2
xor a
gmw2:
ld (ix+0),a
inc ix
inc d
dec e
jr nz,gmw1

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,32
jp simple_results

ga_colour_write:
di
ld ix,result_buffer


ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld b,&7f
ld d,&40
ld e,32
gcw1:
out (c),d

ld hl,&3fdf
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),d
inc ix
inc d
dec e
jr nz,gcw1

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,32
jp simple_results

crtc_reg_write:
di
ld ix,result_buffer

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld bc,&bc00
crw1:
out (c),c
ld hl,&3cff
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),c
inc ix
inc c
jr nz,crw1

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

call crtc_reset
ei
ld ix,result_buffer
ld bc,256
jp simple_results


f8ff_1:
di
ld ix,result_buffer

ld hl,&3cff
ld (hl),0

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
ld bc,&f8ff
out (c),c

ld bc,&bc0c
out (c),c
ld hl,&3cff
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&0c
inc ix

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

call crtc_reset
ei
ld ix,result_buffer
ld bc,1
jp simple_results


crtc_reg_data:
di
ld ix,result_buffer

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld hl,&3db0
ld bc,&bc00
ld d,16
cdw1:
push hl
push bc
push de

out (c),c ;; select reg

ld b,&bd
ld d,0
ld e,0
cdw2:
;; write data
out (c),e
ld a,(hl)
cp e
ld c,1
jr nz,cdw3
inc e
dec d
jr nz,cdw2
ld c,0
cdw3:
ld (ix+0),c
inc ix
ld (ix+0),0
inc ix
pop de
pop bc
pop hl
inc c
inc hl
dec d
jr nz,cdw1

;; now 16-32
ld bc,&bc10
ld d,16
cdw4:
push bc
push de
out (c),c

ld hl,&3db0
ld e,l
ld d,h
inc de
ld bc,15
ld (hl),0
ldir

inc b
ld a,4
out (c),a
dec b

ld hl,&3db0
ld b,16
cdw5:
ld a,(hl)
or a
ld c,1
jr nz,cdw6
inc hl
djnz cdw5
ld c,0
cdw6:
ld (ix+0),c
inc ix
ld (ix+0),0
inc ix
pop de
pop bc
dec d
jr nz,cdw4

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

call crtc_reset
ei
ld ix,result_buffer
ld bc,32
jp simple_results

rom_write:
di
ld ix,result_buffer

;; ff if upper is disabled

ld bc,&fee8
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ld hl,&3aac
ld bc,&df00
row1:
out (c),c
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),c
inc ix
inc c
jr nz,row1

ld bc,&7f00+%10001000+%10
out (c),c

ld hl,&3aac
ld bc,&df00
row2:
out (c),c
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),c
inc ix
inc c
jr nz,row2

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c
ld bc,&df00
out (c),c

ei
ld ix,result_buffer
ld bc,512
jp simple_results


ga_pen_write:
di
ld ix,result_buffer
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c


ld bc,&7f00
gpw1:
out (c),c
ld hl,&3fcf
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),c
inc ix
inc c
ld a,c
cp &3f
jr nz,gpw1

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,32
jp simple_results


ga2_pen_write:
di
ld ix,result_buffer
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld hl,&3f90
ld e,l
ld d,h
inc de
ld (hl),&00
ld bc,&10
ldir

;; specify pen
ld bc,&7f08
out (c),c
;; clear it
xor a
ld (&3fcf),a

ld bc,&7f40
out (c),c
ld hl,&3f90
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix
ld hl,&3f98
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&40
inc ix

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,2
jp simple_results


crtc_reg_sel:
di
ld ix,result_buffer
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c

ld hl,&3db0
ld e,l
ld d,h
inc de
ld (hl),&00
ld bc,&10
ldir

;; specify pen
ld bc,&bc03
out (c),c
;; clear
xor a
ld (&3cff),a

ld bc,&bd40
out (c),c
ld a,(&3db0)
ld (ix+0),a
inc ix
ld (ix+0),&0
inc ix
ld a,(&3db0+3)
ld (ix+0),a
inc ix
ld (ix+0),&40
inc ix


call crtc_reset

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,2
jp simple_results

ga_ink_write:
di
ld ix,result_buffer




push bc
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
pop bc

ld hl,&3f90
ld bc,&7f00
ld d,16
giw1a:
push bc
push hl
push de

out (c),c

ld d,0
ld e,32
giw1:
ld a,d
or &40
out (c),a
cp (hl)
ld c,0
jr nz,giw2
inc d
dec e
jr nz,giw1
ld c,1
giw2:
ld (ix+0),c
ld (ix+1),1
inc ix
inc ix
pop de
pop hl
inc hl
pop bc
inc c
dec d
jp nz,giw1a



ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,16
jp simple_results




ga_border_write:
di
ld ix,result_buffer




push bc
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
pop bc

ld hl,&3fdf
ld bc,&7f10
ld d,16
gbw1a:
push bc
push hl
push de
out (c),c

ld d,0
ld e,32
gbw1:
ld a,d
or &40
out (c),a
cp (hl)
ld c,0
jr nz,gbw2
inc d
dec e
jr nz,gbw1
ld c,1
gbw2:
ld (ix+0),c
ld (ix+1),1
inc ix
inc ix
pop de
pop hl
pop bc
inc c
dec d
jp nz,gbw1a



ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c

ei
ld ix,result_buffer
ld bc,16
jp simple_results

res_mf2_enable:
;; 00
defb &00,&fe,&01,&9,&3,&4,&5,&6,&00,&fe,&04,&00,&fe,&05
defb &01,&2,&3,&4,&5,&6,&00,&fe,&04,&00,&fe,&05
defb &00,&fe,&01,&9,&3,&4,&5,&6,&07,&8
defb &01,&2,&3,&4,&5,&6,&7,&8
;; 20
defb &00,&fe,&02,&00,&fe,&03,&3,&4,&5,&6,&00,&fe,&04,&00,&fe,&05
defb &01,&2,&3,&4,&5,&6,&00,&fe,&04,&00,&fe,&05
defb &00,&fe,&02,&00,&fe,&03,&3,&4,&5,&6,&07,&8
defb &01,&2,&3,&4,&5,&6,&7,&8 
;; 40
defb &00,&fe,&01,&9,&3,&4,&5,&6,&00,&fe,&04,&00,&fe,&05
defb &01,&2,&03,&4,&5,&6,&00,&fe,&04,&00,&fe,&05
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,&8
defb &01,&2,&3,&4,&5,&6,&7,&8
;; 60
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,8
defb &00,&fe,&02,&00,&fe,&03,&3,&4,&5,&6,&7,8
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,&8
defb &00,&fe,&01,&9,&3,&4,&5,&6,&7,&8
defb &fe,&00

mf2_enable:
call kl_u_rom_disable
call kl_l_rom_disable
ld c,0
call kl_rom_select

di
ld bc,&feea
out (c),c

ld a,(&b000)
ld (b000_store),a

ld a,&01
ld (&1000),a	;;0/1,2/3
ld a,&02
ld (&3000),a
ld a,&03		;;4/5,6/7
ld (&5000),a
ld a,&04
ld (&7000),a
ld a,&05
ld (&9000),a	;;8/9,a/b
ld a,&06
ld (&b000),a
ld a,&07
ld (&d000),a ;; c/d, e/f
ld a,&08
ld (&f000),a

ld ix,result_buffer

ld bc,&7f00+%10000000+%10
out (c),c

ld a,(&1000)
ld (lrom_1000_store),a
ld a,(&3000)
ld (lrom_3000_store),a
ld a,(&d000)
ld (urom_d000_store),a
ld a,(&f000)
ld (urom_f000_store),a

ld bc,&fee8
out (c),c
ld a,(&1000)
ld (mf2_rom_store),a
ld a,&09
ld (&3000),a
ld bc,&feea
out (c),c

;; mf2 enabled then all combos
ld bc,&fee8
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c
call read_ram

ld bc,&7f00+%10000100+%10
out (c),c
call read_ram

ld bc,&7f00+%10001000+%10
out (c),c
call read_ram

ld bc,&7f00+%10001100+%10
out (c),c
call read_ram

ld bc,&feea
out (c),c
ld bc,&7f00+%10000000+%10
out (c),c
call read_ram

ld bc,&7f00+%10000100+%10
out (c),c
call read_ram

ld bc,&7f00+%10001000+%10
out (c),c
call read_ram

ld bc,&7f00+%10001100+%10
out (c),c
call read_ram

;; mf2 enabled then all combos
ld bc,&7f00+%10000000+%10
out (c),c
ld bc,&fee8
out (c),c
call read_ram
ld bc,&feea
out (c),c

ld bc,&7f00+%10000100+%10
out (c),c
ld bc,&fee8
out (c),c
call read_ram
ld bc,&feea
out (c),c

ld bc,&7f00+%10001000+%10
out (c),c
ld bc,&fee8
out (c),c
call read_ram
ld bc,&feea
out (c),c

ld bc,&7f00+%10001100+%10
out (c),c
ld bc,&fee8
out (c),c
call read_ram
ld bc,&feea
out (c),c

ld bc,&7f00+%10001000+%10
out (c),c
ld bc,&fee8
out (c),c
call read_ram
ld bc,&feea
out (c),c
call read_ram

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram
ld bc,&7f00+%10011000+%10
out (c),c
call read_ram

;; restore
ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c

ld a,(b000_store)
ld (&b000),a

ei



ld ix,result_buffer
ld hl,res_mf2_enable
call copy_results

ld ix,result_buffer
ld bc,16*8
jp simple_results



read_ram:
ld a,(&1000)
ld (ix+0),a
inc ix
inc ix
ld a,(&3000)
ld (ix+0),a
inc ix
inc ix
ld a,(&5000)
ld (ix+0),a
inc ix
inc ix
ld a,(&7000)
ld (ix+0),a
inc ix
inc ix
ld a,(&9000)
ld (ix+0),a
inc ix
inc ix
ld a,(&b000)
ld (ix+0),a
inc ix
inc ix
ld a,(&d000)
ld (ix+0),a
inc ix
inc ix
ld a,(&f000)
ld (ix+0),a
inc ix
inc ix
ret

;; check all &2000-&3fff acts like ram
ram_check:
call kl_l_rom_enable
di
;; enable mf2
ld bc,&fee8
out (c),c

ld ix,&4000
ld bc,&2000 ;; size of ram
ld hl,&2000 ;; start of ram
rc1:
push bc

;; check all 256 possible values
ld b,0
xor a
rc2:
ld (hl),a
cp (hl)
ld c,0
jr nz,rc3
inc a
djnz rc2
ld c,1
rc3:
ld (ix+0),c
inc ix
ld (ix+0),1
inc ix
pop bc
inc hl
dec bc
ld a,b
or c
jr nz,rc1

ld bc,&feea
out (c),c
ei

ld ix,&4000
ld bc,&2000
jp simple_results


rom_check:
call kl_l_rom_enable
di
;; enable mf2
ld bc,&fee8
out (c),c

ld ix,&4000
ld bc,&2000 ;; size of rom
ld hl,&2000 ;; start of rom
roc1:
push bc

ld c,(hl)
push bc
ld bc,&7f00+%10001000+%10
out (c),c

ld b,0
xor a
rc2b:
ld (hl),a
cp c
ld d,0
jr nz,roc2c
inc a
djnz rc2b
ld d,1
roc2c:
ld (ix+0),d
inc ix
ld (ix+0),0
inc ix

ld bc,&7f00+%10001100+%10
out (c),c

pop bc
ld (hl),c

pop bc
inc hl
dec bc
ld a,b
or c
jr nz,roc1

ld bc,&7f00+%10001000+%10
out (c),c
ld bc,&feea
out (c),c
ei

ld ix,&4000
ld bc,&2000
jp simple_results

ram_wt:
di
ld ix,&4000
ld bc,&1000
ld hl,&3000
ram_wt2:
push bc
push hl
ld bc,&3fef ;; where ga-mode is written
or a
sbc hl,bc
ld c,1
jr z,ram_wt4
pop hl
push hl
ld d,0
xor a
ram_wt3:
ld (hl),a
push hl
ld hl,&c000
ld (hl),a
pop hl
cpl
;; enable mf2
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
;; write to it's ram
ld (hl),a
;; disable mf2
ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
cpl
cp (hl)
ld c,0
jr nz,ram_wt4
inc a
dec d
jr nz,ram_wt3
ld c,1
ram_wt4:
ld (ix+0),c
inc ix
ld (ix+0),1
inc ix
pop hl
inc hl
pop bc
dec bc
ld a,b
or c
jp nz,ram_wt2
ei
ld ix,&4000
ld bc,&1000
jp simple_results


rom_wt:
di
ld ix,&4000
ld bc,&1000
ld hl,&1000
rom_wt2:
push bc

ld d,0
xor a
rom_wt3:
ld (hl),a ;; orig
push hl
ld hl,&c000
ld (hl),a
pop hl

cpl
;; enable mf2
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
;; write to it's rom
ld (hl),a ;; write cpl
;; disable mf2
ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
cpl		;; cpl it back
cp (hl)	;; is it changed by writing?
ld c,0
jr nz,rom_wt4
inc a
dec d
jr nz,rom_wt3
ld c,1
rom_wt4:
ld (ix+0),c
inc ix
ld (ix+0),1	;; values unchanged
inc ix
inc hl
pop bc
dec bc
ld a,b
or c
jp nz,rom_wt2

ei
ld ix,&4000
ld bc,&1000
jp simple_results


rom_wr:
di
;; enable mf2
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
ld ix,result_buffer
ld b,0
ld hl,&1000
rom_wr2:
push hl
push bc
ld b,0
xor a
rom_wr3:
set 5,h	;; &3000
ld (hl),a
res 5,h ;; &1000
cpl
ld (hl),a
set 5,h ;; &3000
cp (hl)
ld c,1
jr nz,rom_wr4
inc a
djnz rom_wr3
ld c,0
rom_wr4:
ld (ix+0),c
inc ix
ld (ix+0),1
inc ix
pop bc
pop hl
inc hl
djnz rom_wr2
;; disable mf2
ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c


ei
ld ix,result_buffer
ld bc,256
jp simple_results

crtc_reg_io_decode:
ld hl,set_ram
ld (mf2_addr_dec_test2+1),hl

ld bc,&3cff
ld hl,&bcff
ld de,&ff00
ld a,&33
jp mf2_addr_io_decode

ga_pen_io_decode:
ld hl,set_ram
ld (mf2_addr_dec_test2+1),hl

ld bc,&3fcf
ld hl,&7fff
ld de,&ff00
ld a,&33
jp mf2_addr_io_decode

pal_io_decode:
ld hl,dummy
ld (mf2_addr_dec_test2+1),hl
ld bc,&3fff
ld hl,&7fff
ld de,&ff00
ld a,&c4
jp mf2_addr_io_decode

dummy:
ret


ppi_io_decode:
ld hl,set_ram
ld (mf2_addr_dec_test2+1),hl
ld bc,&37ff
ld hl,&f7ff
ld de,&ff00
ld a,&44
jp mf2_addr_io_decode

mf2_addr:
defw 0
mf2_data:
defb 0

mf2_addr_io_decode:
ld (mf2_data),a
ld (mf2_addr),bc
push hl
push de
ld bc,&7fc6
out (c),c
ld hl,mf2_addr_dec_test
ld de,mf2_addr_dec_test-&8000+&4000
ld bc,end_mf2_addr_dec_test-mf2_addr_dec_test
ldir
ld bc,&7fc0
out (c),c
pop de
pop hl

ld bc,mf2_addr_restore
ld ix,mf2_addr_dec_test
ld iy,mf2_addr_dec_init
jp io_decode

mf2_addr_restore:
mf2_addr_dec_init:
ld bc,&feea
out (c),c
ld hl,(mf2_addr)
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
ld (hl),0
ld bc,&7f00+%10001100+%10
out (c),c
ld bc,&feea
out (c),c
ld (hl),&ff
ret


mf2_addr_dec_test:
ld a,(mf2_data)
out (c),a
push bc
mf2_addr_dec_test2:
call set_ram
ld bc,&7f00+%10001000+%10
out (c),c
ld bc,&fee8
out (c),c
pop bc
ld hl,(mf2_addr)
ld a,(mf2_data)
cp (hl)
ret

set_ram:
ld bc,&7fc0
out (c),c
ret
end_mf2_addr_dec_test:


mf2_enable_io_decode:
ld bc,&7fc6
out (c),c
ld hl,mf2_dec_test
ld de,mf2_dec_test-&8000+&4000
ld bc,end_mf2_dec_test-mf2_dec_test
ldir
ld bc,&7fc0
out (c),c

;; seems to be full decoding.
ld hl,&fee9
ld de,&fffe
ld bc,mf2_io_restore
ld ix,mf2_dec_test
ld iy,mf2_dec_init
jp io_decode

mf2_io_restore:
mf2_dec_init:
ld hl,&2000
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
ld (hl),&55 ;; mf2 ram
ld bc,&7f00+%10001100+%10
out (c),c
ld bc,&feea
out (c),c
ld (hl),&aa ;; ram
ret


mf2_dec_test:
push bc
;; ensure lower rom is enabled
ld bc,&7f00+%10001000+%10
out (c),c
pop bc
out (c),c ;; potentially enable mf2 ram
ld hl,&2000 ;; potentially write to mf2 ram
ld (hl),&33
ld a,(hl)
push bc
ld bc,&7fc0
out (c),c
pop bc
cp &33 ;; mf2 ram should change
ret nz
push bc
ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
ld a,(hl)
pop bc
cp &aa ;; ram must be unchanged
ret nz
ret
end_mf2_dec_test:


org &9001


call_0064:
call kl_u_rom_disable
call kl_l_rom_disable
ld c,0
call kl_rom_select

di
ld bc,&feea
out (c),c

ld a,(&b000)
ld (b000_store),a

ld a,&01
ld (&1000),a	;;0/1,2/3
ld a,&02
ld (&3000),a
ld a,&03		;;4/5,6/7
ld (&5000),a
ld a,&04
ld (&7000),a
ld a,&05
ld (&9000),a	;;8/9,a/b
ld a,&06
ld (&b000),a
ld a,&07
ld (&d000),a ;; c/d, e/f
ld a,&08
ld (&f000),a
di 

ld ix,result_buffer

ld bc,&7f00+%10000000+%10
out (c),c

ld a,(&1000)
ld (lrom_1000_store),a
ld a,(&3000)
ld (lrom_3000_store),a
ld a,(&d000)
ld (urom_d000_store),a
ld a,(&f000)
ld (urom_f000_store),a

ld bc,&fee8
out (c),c
ld a,(&1000)
ld (mf2_rom_store),a
ld a,&09
ld (&3000),a
ld bc,&feea
out (c),c
ld ix,result_buffer

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;; visible
call &0064
call read_ram ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;;  ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ei
ld ix,result_buffer
ld hl,res_read_0065
call copy_results

ld ix,result_buffer
ld bc,5*8
jp simple_results



read_0065:
call kl_u_rom_disable
call kl_l_rom_disable
ld c,0
call kl_rom_select

di
ld bc,&feea
out (c),c

ld a,(&b000)
ld (b000_store),a

ld a,&01
ld (&1000),a	;;0/1,2/3
ld a,&02
ld (&3000),a
ld a,&03		;;4/5,6/7
ld (&5000),a
ld a,&04
ld (&7000),a
ld a,&05
ld (&9000),a	;;8/9,a/b
ld a,&06
ld (&b000),a
ld a,&07
ld (&d000),a ;; c/d, e/f
ld a,&08
ld (&f000),a
di 

ld ix,result_buffer

ld bc,&7f00+%10000000+%10
out (c),c

ld a,(&1000)
ld (lrom_1000_store),a
ld a,(&3000)
ld (lrom_3000_store),a
ld a,(&d000)
ld (urom_d000_store),a
ld a,(&f000)
ld (urom_f000_store),a

ld bc,&fee8
out (c),c
ld a,(&1000)
ld (mf2_rom_store),a
ld a,&09
ld (&3000),a
ld bc,&feea
out (c),c
ld ix,result_buffer

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;; visible
ld a,(&0065)
call read_ram ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;;  ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ei
ld ix,result_buffer
ld hl,res_read_0065
call copy_results

ld ix,result_buffer
ld bc,5*8
jp simple_results


read_0064:
call kl_u_rom_disable
call kl_l_rom_disable
ld c,0
call kl_rom_select

di
ld bc,&feea
out (c),c

ld a,(&b000)
ld (b000_store),a

ld a,&01
ld (&1000),a	;;0/1,2/3
ld a,&02
ld (&3000),a
ld a,&03		;;4/5,6/7
ld (&5000),a
ld a,&04
ld (&7000),a
ld a,&05
ld (&9000),a	;;8/9,a/b
ld a,&06
ld (&b000),a
ld a,&07
ld (&d000),a ;; c/d, e/f
ld a,&08
ld (&f000),a
di 

ld ix,result_buffer

ld bc,&7f00+%10000000+%10
out (c),c

ld a,(&1000)
ld (lrom_1000_store),a
ld a,(&3000)
ld (lrom_3000_store),a
ld a,(&d000)
ld (urom_d000_store),a
ld a,(&f000)
ld (urom_f000_store),a

ld bc,&fee8
out (c),c
ld a,(&1000)
ld (mf2_rom_store),a
ld a,&09
ld (&3000),a
ld bc,&feea
out (c),c
ld ix,result_buffer

ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;; visible
ld a,(&0065)
call read_ram ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ld bc,&fee8
out (c),c
ld bc,&7f00+%10001000+%10
out (c),c
call read_ram ;;  ;; visible

ld bc,&feea
out (c),c
ld bc,&7f00+%10001100+%10
out (c),c
call read_ram ;; not
ei
ld ix,result_buffer
ld hl,res_read_0065
call copy_results

ld ix,result_buffer
ld bc,5*8
jp simple_results



;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "../../include/memcheck.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/crtc.asm"
include "../../lib/hw/psg.asm"

result_buffer: equ $

end prog_start
