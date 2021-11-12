;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

org &8000
start:
call cls

ld hl,intro_message
call output_msg
key_again:
call km_wait_char
cp '0'
jr c,key_again
cp '7'
jr nc,key_again
sub '1' 
ld (choice),a


call read_roms

ld a,2
call &bc0e
ld ix,tests
call run_tests
call &bb06
ret

tests:
DEFINE_TEST "default rom test",rom_test
DEFINE_END_TEST

intro_message:
defb "Default expansion ROM decoding (WITHOUT expansions)",13
defb "Choice:",13
defb "1. CPC464 only",13
defb "2. CPC664 only",13
defb "3. CPC6128 only",13
defb "4. KC Compact only",13
defb "5. Aleste 520EX only",13
defb 0

choice:
defb 0

read_roms:
call kl_u_rom_enable
ld c,0
call kl_rom_select
di
ld hl,rom_data_buffer
ld b,&00
xor a
read_rom:
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
djnz read_rom
ld bc,&df00
out (c),c
call kl_u_rom_enable
ld c,0
call kl_rom_select
ei
ret

rom_data_buffer:
defs 256

rom_test:
;; copy read roms to buffer
ld ix,result_buffer
ld hl,rom_data_buffer
ld b,0
rt1:
ld a,(hl)
inc hl
ld (ix+0),a
inc ix
inc ix
djnz rt1

ld a,(choice)
or a
jr z,cpc464_roms
dec a
jr z,cpc664_roms
dec a
jr z,cpc6128_roms
dec a
jr z,kccompact_roms
dec a
jr z,aleste520ex_roms
ret 

aleste520ex_roms:
;; basic, amsdos and extra rom (3)
ld ix,result_buffer
ld b,0
xor a
car: 
push af
ld c,a

ld a,c
cp 7
ld a,(rom_data_buffer+7)
jr z,car2
ld a,c
cp 3
ld a,(rom_data_buffer+3)
jr z,car2
ld a,(rom_data_buffer+0)
car2:
ld (ix+1),a
pop af
inc a
inc ix
inc ix
djnz car
jr rom_test2

kccompact_roms:
cpc464_roms:
;; all basic
ld ix,result_buffer
ld a,(rom_data_buffer+0)
ld b,0
c4r: ld (ix+1),a
inc ix
inc ix
djnz c4r
jr rom_test2

cpc6128_roms:
cpc664_roms:
;; all basic except amsdos
ld ix,result_buffer
ld b,0
xor a
c6r: 
push af
cp 7
ld a,(rom_data_buffer+0)
jr nz,c6r2
ld a,(rom_data_buffer+7)
c6r2:
ld (ix+1),a
pop af
inc a
inc ix
inc ix
djnz c6r


rom_test2:
ld ix,result_buffer
ld bc,256
call simple_results
ret



;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"
include "../lib/int.asm"

result_buffer: equ $

end start
