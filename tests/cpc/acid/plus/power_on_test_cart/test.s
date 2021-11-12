;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; TODO: Check IM at reset time is 0.
;; TODO: Detect IVR at reset time
;; TODO: Check loop at reset time
;; TODO: Check prescale/pause at reset time. Prescale added
;; TODO: Check DMA addr at reset time. added.
include "../../lib/testdef.asm"

hl_reset equ &1000
de_reset equ hl_reset+2
bc_reset equ de_reset+2
af_reset equ bc_reset+2
ix_reset equ af_reset+2
iy_reset equ ix_reset+2
sp_reset equ iy_reset+2
hl_alt_reset equ sp_reset+2
de_alt_reset equ hl_alt_reset+2
bc_alt_reset equ de_alt_reset+2
af_alt_reset equ bc_alt_reset+2
i_reset equ af_alt_reset+2
r_reset equ i_reset+1
iff2_reset equ r_reset+1

;; byte from rom at reset time
reset_page equ &8000

;; if asic is unlocked, paging in asic ram will work
;; and value will be 0x0a else it'll be 0x0aa
ram_locked_reset equ reset_page+1

;; is asic ram is visible, asic ram will already be visible
;; and editable
ram_visible_reset equ ram_locked_reset+1
;; psg registers read before initialisation
;; default reset state
psg_registers equ ram_visible_reset+1

analogue_registers equ psg_registers+16
dma_control equ analogue_registers+8
;; in one test only byte 15 had 10 all others were zero
;; then another test all were zero!
;; copy of X/Y sprite coordinates
sprite_registers equ dma_control+1

sprite_data equ sprite_registers+(16*4)

palette_registers equ sprite_data+(16*16*16)

ppi_results equ palette_registers+(32*2)

dma_results equ ppi_results+(256*2*2)

result_buffer equ &3000


GX4000 equ 1
PLUS464 equ 0

org &a000


start:
ld sp,start-1

;; which page at reset time?
ld a,(&c000)
ld (reset_page),a

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

ld hl,&4000
ld (hl),&aa
ld a,(hl)
ld (ram_visible_reset),a

;; is asic unlocked at reset time?
call asic_ram_enable
ld hl,&4000
ld (hl),&aa
ld a,(hl)
ld (ram_locked_reset),a
call asic_ram_disable

call asic_enable
call asic_ram_enable

ld a,(&6c0f)
ld (dma_control),a

ld b,16
ld hl,&6000
ld de,sprite_registers
rsr:
ld a,(hl)
ld (de),a
inc de
inc l
ld a,(hl)
ld (de),a
inc de
inc l
ld a,(hl)
ld (de),a
inc de
inc l
ld a,(hl)
ld (de),a
inc de
inc l

ld a,l
add a,4
ld l,a
djnz rsr

ld hl,&6808
ld de,analogue_registers
ld bc,8
ldir

;; capture palette registers
ld hl,&6400
ld de,palette_registers
ld bc,32*2
ldir
ld hl,&4000
ld de,sprite_data
ld bc,16*16*16
ldir
call asic_ram_disable


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

if GX4000=1
ld hl,gx4000_msg
call output_string
endif

if PLUS464=1
ld hl,plus464_msg
call output_string
endif

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

gx4000_msg:
defb "GX4000 version of tests",13,0

plus464_msg:
defb "464Plus version of tests",13,0
;;-----------------------------------------------------

tests:
;; sp must be something like bfff or similar at power on sometimes.
;; fd fd f7 ff fd fd ff ff
;; bf ff ff fd ff ff ff ff
;; ff ff ff ff ff fd 00 20
;;
;; no long power off
;; bd bd fd bd b5 b5 f5 5d
;; bd bd bd bd 91 bd fd bd 
;; b5 bd bd bd bd 3d 7d 00 20

;; longer
;; fd fd f7 ff fd fd fd ff fd
;; bd ff ff fd ff ff ff ff
;; ff ff ff bf ff fd 00 20
;;
;; fd fd f7 ff fd fd ff fd
;; bf ff ff fd ff ff ff ff
;; ff ff ff bf ff fd 00 20
;; 
;; fd fd f7 ff fd fd ff ff
;; bf ff ff fd ff ff ff ff
;; ff ff ff ff ff fd 00 20
;;
;; rapid:
;; bd fd fd ff bd ff 3d 7d
;; bd ff bd fd 91 ff ed fd
;; a5 bd bd fd 95 7d 00 20

;; a5 bd e5 ad b5 ff f5 fd
;; b5 ad b5 ad b1 bd bd ad
;; f5 fd b5 af 35 fd 00 20

;; ff ff ff ff ff bf ff fd
;; bd ff ff fd ff ff fd fd
;; f7 fd fd fd ff fd 00 20

;; furthur down offset 0:
;; 01 0a aa 00 00 00 00 00 00 00 00 00 00 00 
;; 00 ff ff 3f 3f 3f 3f 3f 00 3f 01 80 00 00 00 00
;; 16x3
;; 00 00 00 00 00 00 00 00 00 00 00 00 0a 01 00 02

;;DEFINE_TEST "asic all ram",display_asic_ram
DEFINE_TEST "power: display z80 registers", z80_display_regs
;; check those that are initialised
DEFINE_TEST "power: test z80 registers", z80_registers
DEFINE_TEST "power: upper rom", test_reset_page
DEFINE_TEST "power: psg registers", test_psg_registers
DEFINE_TEST "power: asic locked", test_asic_enabled
DEFINE_TEST "power: asic ram disabled", test_asic_ram_enabled
;; mostly ends up zero! upper byte always seems to be zero, lower sometimes random
;; but very often zero
DEFINE_TEST "power: sprite registers", test_asic_sprite_registers
;; random!
DEFINE_TEST "power: display palette registers", test_asic_pal_registers
;; random!
;;DEFINE_TEST "power: display sprite data", test_sprite_data
;; 3f 3f 3f 3f 3f 01 3f 00
DEFINE_TEST "power: analogue registers",test_analogue_data
DEFINE_TEST "power: ppi port a i/o state", test_ppi_porta_reset
DEFINE_TEST "power: ppi port b input", test_ppi_portb
;; 0 if off for a long time otherwise 80
DEFINE_TEST "power: dma control", test_dma_control 
;; succeed
;; 81
DEFINE_TEST "power: dma addr (0)",dma_addr0
;; 80
;; 82
DEFINE_TEST "power: dma addr (1)",dma_addr1
;; 90
;; 84
DEFINE_TEST "power: dma addr (2)",dma_addr2
;; these can ALL fail. 0 and 1 seem to be 0 a lot of time, 2 fails often
DEFINE_TEST "power: dma prescale (0)", test_prescale0
DEFINE_TEST "power: dma prescale (1)", test_prescale1
DEFINE_TEST "power: dma prescale (2)", test_prescale2 
;;DEFINE_TEST "power: dma loop", test_loop
DEFINE_TEST "test cart pages", test_cart_pages
DEFINE_END_TEST

display_asic_ram:
call asic_ram_enable
ld bc,&7fb8
out (c),c
ld ix,&4000
ld d,16
ld bc,&4000
call simple_number_grid
ld bc,&7fa0
out (c),c
ret


dma_addr0:
ld a,%1
ld c,%1000000
jr dma_addr

dma_addr1:
ld a,%10
ld c,%100000
jr dma_addr

dma_addr2:
ld a,%100
ld c,%10000
jr dma_addr

num_inst equ (&a000-2)/2

dma_addr:
di
push bc
push af
ld ix,result_buffer
call asic_ram_enable

ld hl,&4030
ld (&0000),hl

pop af
ld (&6c0f),a

defs 128
ld a,(&6c0f)
ld (ix+0),a
inc ix
pop bc
ld (ix+0),c
inc ix
ld a,%0111000
ld (&6c0f),a

ld a,0
ld (&6800),a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a
ld a,1
ld (&6805),a
call asic_ram_disable
ei
ld ix,result_buffer
ld bc,1
call simple_results
ret

test_prescale0:
ld a,%1
jr test_prescale

test_prescale1:
ld a,%10
jr test_prescale

test_prescale2:
ld a,%100
jr test_prescale

test_prescale:
di
push af
ld ix,result_buffer
call asic_ram_enable

;; nops and then stop
ld hl,&2000
ld de,&4000
ld b,15
tp1:
ld (hl),e
inc hl
ld (hl),d
inc hl
djnz tp1
ld de,&4020
ld (hl),e
inc hl
ld (hl),d
inc hl

ld hl,&2000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl
pop af
ld (&6c0f),a

ld hl,0
dpr3:
ld a,(&6c0f)
and 7
jp z,dpr4
defs 64-2-3-3-2-4
inc hl
jp dpr3

dpr4:
;; store count
ld (ix+0),l
ld (ix+1),16	;; except 2 which is &025e
ld (ix+2),h
ld (ix+3),0

ld a,0
ld (&6800),a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a
ld a,1
ld (&6805),a
call asic_ram_disable
ei
ld ix,result_buffer
ld bc,2
call simple_results
ret


test_loop:
di
ld ix,result_buffer

;; if loop address is 0, we should see stop and int
ld hl,&4030
ld (&0000),hl

;; if loop address is not set, we could see it continue or see it repeat the dma address??
;; nops and then loop
ld hl,&2000
ld de,&4000
ld b,15
tppp1:
ld (hl),e
inc hl
ld (hl),d
inc hl
djnz tppp1
;; do loop
ld de,&4001
ld (hl),e
inc hl
ld (hl),d
inc hl
ld de,&4020
ld (hl),e
inc hl
ld (hl),d
inc hl

ld hl,&2000
ld (&6c00),hl
ld a,1
ld (&6c0f),a
dpr2bbbb:
ld a,(&6c0f)
and %01110000
jr z,dpr2bbbb
ld a,%01110001
ld (&6c0f),a

ld hl,0

dprl3:
ld a,(&6c0f)
and 7
jp z,dprl4
defs 64-2-3-3-2-4
inc hl
jp dprl3

dprl4:
ld a,(&6c0f)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
;; store count
ld (ix+0),l
ld (ix+1),&ff
ld (ix+2),h
ld (ix+3),&ff

ld a,0
ld (&6800),a
ld (&6c0f),a
ld a,%01110000
ld (&6c0f),a
ld a,1
ld (&6805),a
ei

ld ix,result_buffer
ld bc,3
call simple_results

ret


z80_display_regs:
ld ix,hl_reset
ld bc,iff2_reset-hl_reset
ld d,8
call simple_number_grid
ret

z80_registers:
ld ix,result_buffer
ld a,(i_reset)
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix
ld a,(r_reset)
ld (ix+0),a
inc ix
ld (ix+0),&20 ;; after storing other registers
inc ix
ld a,(iff2_reset)
and %100
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld ix,result_buffer
ld bc,3
call simple_results
ret


wait_frame:
;; wait start
ld b,&f5
wf1:
in a,(c)
rra
jr nc,wf1
;; wait end
wf2:
in a,(c)
rra
jr c,wf2
ret

test_reset_page:
ld ix,result_buffer
ld a,(reset_page)
ld (ix+0),a
ld (ix+1),1		;; page 1 at reset

ld ix,result_buffer
ld bc,1
call simple_results
ret

test_asic_enabled:
ld ix,result_buffer
ld a,(ram_locked_reset)
ld (ix+0),a
ld (ix+1),&aa

ld ix,result_buffer
ld bc,1
call simple_results
ret

test_asic_sprite_registers:
ld ix,result_buffer
ld hl,sprite_registers
ld b,16*4
tasr:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
ld (ix+0),0
inc ix
djnz tasr

ld ix,result_buffer
ld bc,16*2
call simple_results
ret

test_asic_pal_registers:
ld ix,palette_registers
ld bc,32*2
ld d,8
call simple_number_grid
ret

test_sprite_data:
ld ix,sprite_data
ld bc,16*16*16
ld d,8
call simple_number_grid
ret

test_analogue_data:
ld ix,analogue_registers
ld bc,8
ld d,8
call simple_number_grid
ret


test_asic_ram_enabled:
ld ix,result_buffer
ld a,(ram_visible_reset)
ld (ix+0),a
ld (ix+1),&aa

ld ix,result_buffer
ld bc,1
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

if GX4000=1
;; GX4000 is ff/fe for all
ld a,&fe
else
if PLUS464=1
ld a,%11111110	;; 464 /EXP is not low; cassette unknown
else
ld a,%11011110	;; 6128 /EXP should be low
endif
endif
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

test_dma_control:
di
ld ix,result_buffer
ld a,(dma_control)
and &7f
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ei
ld ix,result_buffer
ld bc,1
call simple_results
ret


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

;; 0 = ed	;; first byte of boot.s
;; 1 = 1
;; 2 = 2
;; 3 = 3
;; 4 = 4


get_page_plus:
ld a,c
bit 7,a
jr nz,gpp

;; gx4000 always returns basic, plus returns amsdos page
if GX4000=0
cp 7			;; amsdos?
ld a,3		;; physical page 3
ret z
endif

ld a,1		;; physical page 1
ret

;; cart physical page
gpp:
and &1f

or a
ret nz	;; all others = value because of the way we set them up
ld a,&ed	;; page 0
ret


test_cart_pages:
di
ld bc,&7f00+%10000110
out (c),c

ld ix,result_buffer
ld bc,&df00

tcp1:
call get_page_plus
ld (ix+1),a

out (c),c
ld a,(&c000)
ld (ix+0),a
inc ix
inc ix
inc c
ld a,c
or a
jr nz,tcp1
ld bc,&7f00+%10001110
out (c),c

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


end start

