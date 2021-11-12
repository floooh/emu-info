;; THIS NEEDS TESTING ON A REAL MACHINE
org &0000

include "../../lib/testdef.asm"

start:
;; TODO: upper ROM is active at reset?
;; TODO: CRTC at reset
;; TODO: GA at reset (pen)
ppi_results equ &1000
psg_registers equ ppi_results+(256*2*2)

;; power on lower rom (use x-mem to test)

;; will give bad results if launched from menu of cart emulator
ld ix,ppi_results

;; port A should not give values; it is set to input
ld bc,&f400

ppi1:
;; out value
out (c),c
;; read value
in a,(c)
ld (ix+0),a
ld (ix+1),&ff
inc ix
inc ix

inc c
ld a,c
or a
jr nz,ppi1

;; set to output; now it should
ld bc,&f780
out (c),c

ld bc,&f400

ppi2:
;; out value
out (c),c
;; read value
in a,(c)
ld (ix+0),a
ld (ix+1),c
inc ix
inc ix

inc c
ld a,c
or a
jr nz,ppi2

;; read psg registers
ld b,16
ld hl,psg_registers
ld c,0
rpr:
push bc
call read_psg_reg
pop bc
ld (hl),a
inc hl
inc c
djnz rpr


ld sp,&c000

ld hl,&c9fb
ld (&0038),hl

im 1

ld bc,&7f00+%10001110
out (c),c

ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c

ld bc,&7f01
out (c),c
ld bc,&7f4b
out (c),c

call set_crtc

;; at this point we have not changed port c
ei

call write_text_init

call cls

ld ix,tests
call run_tests

loop:
jp loop

set_crtc:
;; set initial CRTC settings (screen dimensions etc)
ld hl,end_crtc_data
ld bc,&bc0f
crtc_loop:
out (c),c
dec hl
ld a,(hl)
inc b
out (c),a
dec b
dec c
jp p,crtc_loop
ret

tests:
DEFINE_TEST "power: psg registers", test_psg_registers
DEFINE_TEST "power: ppi port a i/o state", test_ppi_porta_reset
DEFINE_TEST "power: ppi port b input", test_ppi_portb
DEFINE_END_TEST


test_psg_registers:
;; init values
ld hl,psg_registers
ld ix,result_buffer
ld b,14
tpr1:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
ld (ix+0),0
inc ix
djnz tpr1
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

ld ix,result_buffer
ld bc,16
call simple_results
ret


test_ppi_porta_reset:
ld ix,ppi_results
ld bc,512
call simple_results
ret

test_ppi_portb:
di
ld ix,result_buffer

ld bc,&f500

tpp1:
out (c),c
in a,(c)
and &fe
ld (ix+0),a

ld a,%11011110	;; 6128 /EXP should be low
ld (ix+1),a
inc ix
inc ix

inc c
ld a,c
or a
jr nz,tpp1

ei
ld ix,result_buffer
ld bc,256
call simple_results
ret


include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
include "../../lib/int.asm"
;; hardware based output

include "../../lib/hw/asic.asm"
include "../../lib/hw/readkeys.asm"
include "../../lib/hw/writetext.asm"
include "../../lib/hw/scr.asm"
include "../../lib/hw/printtext.asm"



crtc_data:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
end_crtc_data:

sysfont:
incbin "../../lib/hw/sysfont.bin"

result_buffer equ $

end start

