;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;;
;; test writing to asic registers goes
;; through to external ram.
;;
;; found by Ast and gerald.

org &a000

include "../lib/testdef.asm"

kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

start:
call cls

ld hl,intro_message
call output_msg

ld hl,has_extra_ram_message
call output_msg
call &bb06
cp 'Y'
jr z,set_has_ram
cp 'y'
jr z,set_has_ram
ld a,0
jr set_has_ram2
set_has_ram:
ld a,1
set_has_ram2:
ld (hasInternalExtraRam),a

ld hl,external_ram_message
call output_msg
call &bb06
cp 'Y'
jr z,set_ex_has_ram
cp 'y'
jr z,set_ex_has_ram
ld a,0
jr set_ex_has_ram2
set_ex_has_ram:
ld a,1
set_ex_has_ram2:
ld (hasExternalExtraRam),a

ld a,(hasInternalExtraRam)
ld c,a
ld a,(hasExternalExtraRam)
or c
ld (hasExtraRam),a


ld ix,tests
call run_tests
ret

intro_message:
defb "464Plus with 64KB only - N then N",13,10
defb "6128Plus with 128KB only - Y then N",13,10
defb "464Plus with external ram expansion - N then Y",13,10
defb "6128Plus with external ram expansion - Y then Y",13,10
defb 0

has_extra_ram_message:
defb 13,10,"Has internal extra 64KB? Y/N",13,10,0
external_ram_message:
defb 13,10,"Has external extra 64KB? Y/N",13,10,0


;;--------------------------------------------------------------------

tests:
DEFINE_TEST "write through c4 reg", c4_reg_writethrough
;;DEFINE_TEST "write through cc reg", cc_reg_writethrough
DEFINE_TEST "write through c4 unmapped", c4_um_writethrough
;;DEFINE_TEST "write through cc unmapped", cc_um_writethrough
DEFINE_END_TEST

c4_reg_writethrough:
ld a,&c4
ld hl,&6804
jr ram_writethrough

cc_reg_writethrough:
ld a,&cc
ld hl,&6804
jr ram_writethrough


c4_um_writethrough:
ld a,&c4
ld hl,&7800
jr ram_writethrough

cc_um_writethrough:
ld a,&cc
ld hl,&7800
jr ram_writethrough

ram_writethrough:
di
ld ix,result_buffer

ld (hl),&33

ld b,&7f
out (c),a

;; set initial value in ram
ld (hl),&11

push hl
call asic_enable
call asic_ram_enable
pop hl

ld (hl),&22
push hl
call asic_ram_disable
call asic_disable
pop hl
;; read value written
ld a,(hl)
ld (ix+0),a
inc ix
;; if no extra ram we see result in main ram
;; overwritten by &11
ld a,(hasExtraRam)
or a
ld a,&11 
jr z,set_result
;; if we have external ram then we
;; see value written.
;; write through occurs
ld a,(hasExternalExtraRam)
or a
ld a,&22
jr nz,set_result
;; if we have internal ram it's value shows
;; write through doesn't occur
ld a,(hasInternalExtraRam)
or a
ld a,&11			
jr nz,set_result
ld a,&ff
set_result:
ld (ix+0),a
inc ix

ld bc,&7fc0
out (c),c

;; restore
call asic_enable
call asic_ram_enable
ld hl,&6804
ld (hl),0
call asic_ram_disable
call asic_disable
ei

ld ix,result_buffer
ld bc,1
call simple_results
ret

hasExtraRam:
defb 0

hasInternalExtraRam:
defb 0

hasExternalExtraRam:
defb 0

;;-----------------------------------------------------

include "../lib/hw/asic.asm"
include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $


end start