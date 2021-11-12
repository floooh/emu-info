;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;
include "../../lib/testdef.asm"

kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_l_rom_enable equ &b906
kl_l_rom_disable equ &b909
kl_rom_restore equ &b90c
kl_rom_select equ &b90f
txt_output equ &bb5a



org &8000
start:
ld a,2
call scr_set_mode
ld hl,intro_message
call display_msg
call &bb06

ld a,2
call &bc0e
ld ix,tests
call run_tests
call &bb06
ret

intro_message:
defb "Brunword MK2 tester",13,10,13,10
defb "This is an automatic test",13,10,13,10
defb "Please test on *CPC* with Brunword Mk 2 expansion ONLY connected.",13,10,13,10
defb "Tested on a 6128 with Brunword mk2 connected",13,10,13,10
defb "Press any key to continue",13,10,13,10
defb 0


display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

;;-----------------------------------------------------

;; TODO: Changes IM 2 vector
tests:
DEFINE_TEST "/EXP test",exp_test
DEFINE_TEST "unmapped port read",unmapped_test
DEFINE_TEST "reset peripherals i/o (f8ff)",reset_peripherals_test
DEFINE_TEST "rom id (all combinations of Lower and Upper ROM)",new_rom_test
DEFINE_TEST "rom write-through",wt_rom_test
DEFINE_TEST "rom (4000)",rom_4000
DEFINE_TEST "i/o rom decode (dfxx)",rom_io_decode
DEFINE_END_TEST

reset_peripherals_test:

ld ix,result_buffer
ld hl,&4000

;; read actual state
di
ld bc,&df00+%01100000
out (c),c
ld a,(hl)
ld (rom_data),a
ld bc,&df00+%01100100
out (c),c

ld bc,&df00+%01100000
out (c),c

ld a,(hl)
ld (ix+0),a
inc ix
ld a,(rom_data)
ld (ix+0),a
inc ix

ld bc,&f8ff
out (c),c

ld a,(hl)
ld (ix+0),a
inc ix
ld a,(rom_data)
ld (ix+0),a
inc ix

ld bc,&df00+%01100000
out (c),c
ei
ld c,0
call kl_rom_select
call kl_u_rom_enable

ld ix,result_buffer
ld bc,2
jp simple_results

exp_test:
ld c,0
call kl_rom_select
call kl_u_rom_enable

ld ix,result_buffer

di
ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld bc,&df00+%01100000
out (c),c

ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld bc,&df00+%01100100
out (c),c

ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ei

ld ix,result_buffer
ld bc,3
jp simple_results

unmapped_test:
ld ix,result_buffer

ld bc,&fd40
di
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

push bc
ld bc,&df00+%01100000
out (c),c
pop bc

in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

push bc
ld bc,&df00+%01100100
out (c),c
pop bc

in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

ld ix,result_buffer
ld bc,3
jp simple_results

rom_data:
defb 0

rom_4000:
ld ix,result_buffer
ld c,0
call kl_rom_select
call kl_u_rom_disable
call kl_l_rom_disable

ld hl,&7000
di
ld bc,&df00+%01100000
out (c),c
ld a,(hl)
ld (rom_data),a
ld bc,&df00+%01100100
out (c),c
ld bc,&df00
out (c),c


ld (hl),2

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),2	;; ram
inc ix

;; enable
ld bc,&df00+%01100000
out (c),c
ld a,(hl)
ld (ix+0),a
inc ix
ld a,(rom_data) ;; data from brunword
ld (ix+0),a
inc ix

;; select
ld bc,&df00
out (c),c
ld a,(hl)
ld (ix+0),a
inc ix
ld a,(rom_data)	;; still same
ld (ix+0),a
inc ix

;; disable
ld bc,&df00+%01100100
out (c),c
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),2		;; data from ram again
inc ix

ld bc,&df00+%01100100
out (c),c
ld bc,&df00
out (c),c
ei

ld ix,result_buffer
ld bc,4
call simple_results
ret

wt_rom_test:
ld ix,result_buffer

ld b,0
ld c,0
wt1:
push bc

push bc
ld c,0
call kl_rom_select
call kl_u_rom_disable
call kl_l_rom_disable
pop bc

;; setup ram
ld a,1
ld (&3000),a
ld a,2
ld (&7000),a
ld a,3
ld (&b000),a
ld a,4
ld (&f000),a

call kl_u_rom_enable
call kl_l_rom_enable

ld a,&11
ld (&3000),a
di
ld b,&df
out (c),c
ld a,&22
ld (&7000),a		;; 
ld a,&44
ld (&f000),a
ld bc,&df00+%01100100 ;; important
out (c),c
ld bc,&df00
out (c),c
ei
ld a,&33
ld (&b000),a
call kl_u_rom_disable
call kl_l_rom_disable

ld a,(&3000)
ld (ix+0),a
inc ix
ld (ix+0),&11
inc ix
ld a,(&7000)
ld (ix+0),a
inc ix
ld (ix+0),&22
inc ix
ld a,(&b000)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix
ld a,(&f000)
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix
pop bc
inc c
dec b
jp nz,wt1

ld ix,result_buffer
ld bc,256*4
call simple_results
ret

get4000:
ld a,c
and %01100100
cp %01100000
ld a,2
ret nz
ld a,c
and &3
ld d,a
ld a,c
rrca
and %1100
or d
add a,bw_roms AND 255
ld l,a
ld a,bw_roms/256
adc a,0
ld h,a
ld a,(hl)
ret

get_rom:
ld a,c
and %01100000
cp %01100000
jr nz,get_rom2
ld a,(rom0_data)
ret
get_rom2:
;; repeats at 64 too
ld a,c
cp 7
ld a,(rom7_data)
ret z
ld a,c
and &3f
cp 1
ld a,(bw_roms+1)
ret z
ld a,c
and &3f
cp 2
ld a,(bw_roms+2)
ret z
ld a,c
and &3f
cp 3
ld a,(bw_roms+3)
ret z
ld a,(rom0_data)
ret

new_rom_test:
;; setup ram
ld a,1
ld (&3000),a
ld a,2
ld (&7000),a
ld a,3
ld (&b000),a
ld a,4
ld (&f000),a

call kl_u_rom_enable

di
ld b,0
ld c,0
ld hl,bw_roms
nrt11:
push bc
ld a,c
and &3
ld d,a
ld a,c
rlca
and %11000
or d
or %01100000
ld b,&df
out (c),a
ld a,(&7000)
ld (hl),a
inc hl
pop bc
inc c
djnz nrt11
ld bc,&df00+%01100100
out (c),c
ei
;; read some roms
ld c,0
call kl_rom_select
call kl_u_rom_enable
ld a,(&f000)
ld (rom0_data),a

ld c,7
call kl_rom_select
call kl_u_rom_enable
ld a,(&f000)
ld (rom7_data),a

call kl_l_rom_enable
ld a,(&3000)
ld (lrom_data),a



;; lower and upper
ld ix,result_buffer
ld b,0
ld c,0
nrt2:
ld a,(lrom_data)
ld (ix+1),a
inc ix
inc ix
call get4000
ld (ix+1),a
inc ix
inc ix
ld a,3
ld (ix+1),a
inc ix
inc ix
call get_rom
ld (ix+1),a
inc ix
inc ix
inc c
djnz nrt2

;; upper only
ld b,0
ld c,0
nrt3:
ld a,1
ld (ix+1),a
inc ix
inc ix
call get4000
ld (ix+1),a
inc ix
inc ix
ld a,3
ld (ix+1),a
inc ix
inc ix
call get_rom
ld (ix+1),a
inc ix
inc ix
inc c
djnz nrt3

;; lower only
ld b,0
ld c,0
nrt4:
ld a,(lrom_data)
ld (ix+1),a
inc ix
inc ix
call get4000
ld (ix+1),a
inc ix
inc ix
ld a,3
ld (ix+1),a
inc ix
inc ix
ld a,4
ld (ix+1),a
inc ix
inc ix
inc c
djnz nrt4

;; none
ld b,0
ld c,0
nrt5:
ld a,1
ld (ix+1),a
inc ix
inc ix
call get4000
ld (ix+1),a
inc ix
inc ix
ld a,3
ld (ix+1),a
inc ix
inc ix
ld a,4
ld (ix+1),a
inc ix
inc ix
inc c
djnz nrt5

ld ix,result_buffer

call kl_l_rom_enable
call kl_u_rom_enable
call nrt
call kl_l_rom_disable
call kl_u_rom_enable
call nrt
call kl_l_rom_enable
call kl_u_rom_disable
call nrt
call kl_l_rom_disable
call kl_u_rom_disable
call nrt

ld ix,result_buffer
ld bc,256*4*4
call simple_results
ret

bw_roms:
defs 256

rom0_data:
defb 0
rom1_data:
defb 0
rom7_data:
defb 0
lrom_data:
defb 0

nrt:
di
ld b,0
ld c,0
nrt1:
push bc
ld b,&df
out (c),c
ld a,(&3000)
ld (ix+0),a
inc ix
inc ix
ld a,(&7000)
ld (ix+0),a
inc ix
inc ix
ld a,(&b000)
ld (ix+0),a
inc ix
inc ix
ld a,(&f000)
ld (ix+0),a
inc ix
inc ix
pop bc
inc c
djnz nrt1
ei
ret



rom_io_decode:
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (rom1_data),a

ld hl,&dfff
ld de,&2000
ld bc,rom_restore
ld ix,rom_dec_test
ld iy,rom_dec_init
jp io_decode

rom_restore:
ret

rom_dec_init:
ret

rom_dec_test:
ld a,1		;; select rom 1
out (c),a
ld bc,&7f00+%10000100 ;; enable upper rom
out (c),c
ld a,(&d000)
ld c,a
ld a,(rom1_data)
cp c
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
include "../../lib/hw/crtc.asm"
include "../../lib/portdec.asm"

result_buffer: equ $

end start
