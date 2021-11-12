;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; tested by ngroom on his rombo board that he is selling
;; on ebay
include "../../lib/testdef.asm"

kl_u_rom_enable equ &b900
kl_rom_select equ &b90f
txt_output equ &bb5a

org &4000

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
defb "Rombo ROM board tester",13,10,13,10
defb "Please test on *CPC* with Rombo ROM Board ONLY connected.",13,10,13,10
defb "Please set link to select ROMS 8-15. Please enable a ROM ",13,10
defb "in SLOT 8 only. Please disable all other slots",13,10,13,10
defb "Thankyou to user nrgroom on cpcwiki for running the test on",13,10
defb "his ROMBO rom board.",13,10,13,10
defb "Press any key to continue",13,10,13,10

defb 0

;;-----------------------------------------------------

;; UNKNOWN: What does reset do (not easy to test)

tests:
DEFINE_TEST "Rombo rom page decode",Rombo_rom_pages
DEFINE_TEST "Rombo i/o rom decode (dfxx)",Rombo_rom_io_decode
DEFINE_END_TEST

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

Rombo_rom_pages:
call kl_u_rom_enable
ld c,7
call kl_rom_select
ld a,(&d000)
ld (rom7_data),a

ld c,0
call kl_rom_select

ld a,(&d000)
ld (rom0_data),a

ld c,8
call kl_rom_select
ld a,(&d000)
ld (rom8_data),a

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

ld a,(rom8_data)
ld (result_buffer+(8*2)+1),a
ld a,(rom7_data)
ld (result_buffer+(7*2)+1),a

ld ix,result_buffer
ld bc,256
jp simple_results

Rombo_rom_io_decode:
ld hl,&dfff
ld de,&2000
ld bc,Rombo_rom_restore
ld ix,Rombo_rom_dec_test
ld iy,Rombo_rom_dec_init
jp io_decode

Rombo_rom_restore:
ret

Rombo_rom_dec_init:
ld c,8
call kl_rom_select
ld a,(&d000)
ld (rom8_data),a
ret

rom0_data:
defb 0
rom8_data:
defb 0
rom2_data:
defb 0
rom7_data:
defb 0

Rombo_rom_dec_test:
ld a,8
out (c),a
ld bc,&7f00+%10000100
out (c),c
ld a,(&d000)
ld c,a
ld a,(rom8_data)
cp c
ret

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/crtc.asm"
include "../../lib/hw/psg.asm"
include "../../lib/question.asm"
;; firmware based output
include "../../lib/fw/output.asm"

result_buffer: equ $

end start
