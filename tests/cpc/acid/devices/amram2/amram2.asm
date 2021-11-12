;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../../lib/testdef.asm"

;; fbf0 *before* rom
;; full rom indices decode
;; write doesn't depend on rom enable state
;; write doesn't go through if slots are disabled.

kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f
txt_output equ &bb5a

org &4000

start:
ld a,2
call scr_set_mode
ld hl,intro_message
call display_msg
call &bb06

ld c,1
call kl_rom_select
call kl_u_rom_enable
;; enabled or not?
ld hl,&c000
ld a,(hl)
ld (initial_byte),a
ld a,(initial_byte)
cpl
ld (hl),a
ld a,(hl)
ld (new_byte),a


ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&3fff
ldir
ld a,1
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select
call kl_u_rom_disable
ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),&aa
ld bc,&3fff
ldir
xor a
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select
call kl_u_rom_disable

ld a,2
call &bc0e
ld ix,tests
jp run_tests

initial_byte:
defb 0
new_byte:
defb 0

;; TODO: Changes IM 2 vector

intro_message:
defb "Silicon Systems Amram 2 tester",13,10,13,10
defb "This test is a mix of automatic and interactive.",13,10,13,10
defb "Please test on *CPC* with Amram2 expansion ONLY connected.",13,10,13,10
defb "This was tested on a CPC6128 with Amram2 connected.",13,10,13,10
defb "Please turn off dipswitches for all the ROMs EXCEPT 1 and 2 and turn ON the",13,10
defb "WRITE ENABLE switch",13,10,13,10
defb "NOTE: This test will change the RAM in the Amram2.",13,10,13,10
defb "First test fills the Amram2 ram with &aa byte. You will see the screen filled at",13,10
defb "the same time. Press a key to continue with the test.",13,10,13,10
defb "Press any key to start",13,10,13,10
defb 0

;;-----------------------------------------------------

tests:
DEFINE_TEST "initial state",amram2_1st_state
DEFINE_TEST "amram2 first write test",amram2_initial
DEFINE_TEST "/EXP test",amram2_exp
DEFINE_TEST "unmapped port read",amram2_unmapped
DEFINE_TEST "reset peripherals i/o (f8ff)",amram2_reset_peripherals
DEFINE_TEST "amram2 write data (ENABLE ON, 1 ON, 2 ON)",amram2_write
DEFINE_TEST "amram2 rom page decode",amram2_rom_pages
DEFINE_TEST "amram2 i/o rom decode (dfxx)",amram2_rom_io_decode
DEFINE_TEST "amram2 i/o address decode (fbf0)",amram2_addr_io_decode
DEFINE_TEST "amram2 i/o  data decode (fbf0,data)",amram2_data_io_decode
DEFINE_TEST "amram2 write data (ENABLE ON, 1 OFF, 2 OFF)",amram2_2write
DEFINE_TEST "amram2 write data (ENABLE OFF, 1 ON, 2 ON)",amram2_3write
DEFINE_END_TEST

amram2_1st_state:
ld ix,result_buffer
ld a,(new_byte)
ld (ix+0),a
inc ix
ld a,(initial_byte)
ld (ix+0),a
inc ix
ld ix,result_buffer
ld bc,1
jp simple_results

amram2_reset_peripherals:
ld ix,result_buffer
ld hl,&c000

ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,1
ld bc,&fbf0
out (c),a

ld (hl),&33

ld bc,&f8ff
out (c),c

ld (hl),&44

ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,0
ld bc,&fbf0
out (c),a

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix

ld ix,result_buffer
ld bc,1
jp simple_results

amram2_exp:
ld ix,result_buffer

ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,1
ld bc,&fbf0
out (c),a

ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld hl,&c000
ld (hl),&aa

ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

xor a
ld bc,&fbf0
out (c),a

ld b,&f5
in a,(c)
and %00100000
ld (ix+0),a
inc ix
ld (ix+0),0
inc ix

ld ix,result_buffer
ld bc,4
jp simple_results

amram2_unmapped:
ld ix,result_buffer

ld bc,&fd40

in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

push bc
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,1
ld bc,&fbf0
out (c),a
pop bc

in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

push bc
ld c,1
call kl_rom_select
call kl_u_rom_enable
xor a
ld bc,&fbf0
out (c),a
pop bc

in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),&ff
inc ix

ld ix,result_buffer
ld bc,3
jp simple_results


write_msg_1:
defb "Please turn OFF slot 1 AND 2. Please leave write ENABLED. Press a key",13,10,0

write_msg_2:
defb "Please turn ON slot 1 AND 2. Please leave write ENABLED. Press a key",13,10,0

write_msg_3:
defb "Please turn ON slot 1 AND 2. Please turn OFF write ENABLED. Press a key",13,10,0


amram2_2write:
ld ix,result_buffer

;; setup ram with data
ld hl,&c000
ld a,1
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
call kl_u_rom_disable
pop hl
ld (hl),&aa
xor a
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
call kl_u_rom_disable
pop hl

ld hl,write_msg_1
call display_msg
call &bb06

ld c,1
call kl_rom_select
call kl_u_rom_enable
ld hl,&c000
ld (hl),&33
push hl
call kl_u_rom_disable
pop hl
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33	;; ram
inc ix
push hl
call kl_u_rom_enable
pop hl
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&80	;; rom 1 (mapped as basic)
inc ix
push hl
call kl_u_rom_disable
pop hl

ld hl,&c000
ld a,1
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
call kl_u_rom_disable
pop hl
ld (hl),&55
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&55	;; reading ram (mirrored into amram2)
inc ix
xor a
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
call kl_u_rom_disable
pop hl
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&55 ;; reading ram 
inc ix
push hl
call kl_u_rom_enable
pop hl
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

ld hl,write_msg_2
call display_msg
call &bb06


ld hl,&c000
push hl
ld c,1
call kl_rom_select
call kl_u_rom_enable
pop hl
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&aa		;; this is seeded value
inc ix

ld ix,result_buffer
ld bc,6
jp simple_results


amram2_3write:
ld ix,result_buffer

ld hl,write_msg_2
call display_msg
call &bb06

ld hl,&c000

;; seed ram
ld a,1
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
call kl_u_rom_disable
pop hl
ld (hl),&55
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&55
inc ix
xor a
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
pop hl

ld hl,write_msg_3
call display_msg
call &bb06


ld hl,&c000

ld a,1
ld bc,&fbf0
out (c),a
push hl
ld c,1
call kl_rom_select
call kl_u_rom_disable
pop hl
ld (hl),&33
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix
xor a
ld bc,&fbf0
out (c),a

;; now attempt to read
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&55
inc ix


ld ix,result_buffer
ld bc,3
jp simple_results


amram2_initial:
ld ix,result_buffer
ld a,&55
ld (&d000),a
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&aa
inc ix
ld a,1
ld bc,&fbf0
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&aa
inc ix
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&aa
inc ix

xor a
ld bc,&fbf0
out (c),a
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&aa
inc ix
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&aa 
inc ix
call kl_u_rom_disable
ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&55
inc ix

xor a
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select

ld ix,result_buffer
ld bc,6
jp simple_results

amram2_write:
ld ix,result_buffer

ld c,0
call kl_rom_select
call kl_u_rom_disable
ld hl,&c000
ld (hl),&44
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix
;; select rom 1
ld c,1
call kl_rom_select
call kl_u_rom_disable
ld a,1
ld bc,&fbf0
out (c),a
ld (hl),&33

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

call kl_u_rom_enable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

xor a
ld bc,&fbf0
out (c),a

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

call kl_u_rom_disable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

;;;-----
ld c,0
call kl_rom_select
call kl_u_rom_disable
ld hl,&c000
ld (hl),&44
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&44
inc ix
ld a,1
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select
call kl_u_rom_disable
ld (hl),&33

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

call kl_u_rom_enable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

xor a
ld bc,&fbf0
out (c),a

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

call kl_u_rom_disable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

;; 10

ld a,1
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select
call kl_u_rom_enable
ld (hl),&55
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&55
inc ix

xor a
ld bc,&fbf0
out (c),a
call kl_u_rom_enable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&55
inc ix

ld c,0
call kl_rom_select
call kl_u_rom_enable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

xor a
ld bc,&fbf0
out (c),a
ld c,0
call kl_rom_select
call kl_u_rom_enable

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix


xor a
ld bc,&fbf0
out (c),a
ld c,0
call kl_rom_select
call kl_u_rom_enable


ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&80
inc ix

ld a,1
ld bc,&fbf0
out (c),a
ld c,1
call amram2_write2
ld a,1
ld bc,&fbf0
out (c),a
ld c,2
call amram2_write2

;; amram2 off
ld c,1
call amram2_write3
;; amram2 off
ld c,2
call amram2_write3
xor a
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select

ld ix,result_buffer
ld bc,8*256*2+(2*256*2)+15
jp simple_results

amram2_write3:
di
ld hl,&c000

ld d,0
ld e,0
aw3:

push bc
;; enable
ld a,1
ld bc,&fbf0
out (c),a
pop bc

push bc
call kl_rom_select
pop bc
push bc
call kl_u_rom_enable
pop bc
;; write
ld (hl),e

push bc
;; disable
xor a
ld bc,&fbf0
out (c),a
pop bc
push bc
call kl_rom_select
pop bc

push bc
call kl_u_rom_enable
pop bc
;; write
ld a,e
cpl
ld (hl),a
;; re-back original value (because write protected)
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
;; read ram
push bc
call kl_u_rom_disable
pop bc
ld a,(hl)
ld (ix+0),a
inc ix
ld a,e
cpl
ld (ix+0),a
inc ix

inc e
dec d
jp nz,aw3
ret



amram2_write2:
di
ld hl,&c000

push bc
ld c,0
call kl_rom_select

call kl_u_rom_enable

ld a,(hl)
ld (rom0_data),a
pop bc

ld d,0
ld e,0

aw1:
;; disable rom
push bc
call kl_u_rom_disable
pop bc

;; main ram
ld (hl),&33

push bc
call kl_rom_select
pop bc

;; enable rom
push bc
call kl_u_rom_enable
pop bc

;; write to amram2 
ld (hl),e
;; read it back
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

;; disable rom
push bc
call kl_u_rom_disable
pop bc
;; read it back (amram2 writes through to ram)
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

;; re-write ram
ld (hl),&33

;; enable rom
push bc
call kl_u_rom_enable
pop bc
;; shows data written. if enabled writes go to amram2 regardless of whether rom
;; is enabled or not
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

push bc
ld c,0
call kl_rom_select
call kl_u_rom_enable
ld a,(hl)
ld (ix+0),a
inc ix
ld a,(rom0_data)
ld (ix+0),a
inc ix
pop bc

;; can we write to amram2 *WITHOUT* enabling ROM?
push bc
call kl_u_rom_disable
ld a,e
cpl
ld (hl),a
pop bc

;; disable rom
push bc
call kl_u_rom_disable
pop bc

;; main ram
ld (hl),&33

;; select amram2 page
push bc
call kl_rom_select
call kl_u_rom_disable
pop bc

;; write to amram2 
ld (hl),e
;; read it back
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix

;; re-write ram
ld (hl),&33

;; should show ram data
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

push bc
call kl_u_rom_enable
pop bc
ld a,(hl)
ld (ix+0),a
inc ix
ld (ix+0),&33
inc ix

inc e
dec d
jp nz,aw1
ei
ret



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
ei
ld c,0
call kl_rom_select
ret

rom_data_buffer:
defs 256

amram2_rom_pages:
call kl_u_rom_enable
ld c,7
call kl_rom_select
ld a,(&d000)
ld (rom7_data),a

ld c,0
call kl_rom_select

ld a,(&d000)
ld (rom0_data),a

ld a,1
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select
ld a,&33
ld (&d000),a
ld a,(&d000)
ld (rom1_data),a

ld c,2
call kl_rom_select
ld a,&44
ld (&d000),a
ld a,(&d000)
ld (rom2_data),a
ld a,0
ld bc,&fbf0
out (c),a
ld c,1
call kl_rom_select
call kl_u_rom_disable

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
ld a,(rom2_data)
ld (result_buffer+(2*2)+1),a
ld a,(rom7_data)
ld (result_buffer+(7*2)+1),a

ld ix,result_buffer
ld bc,256
jp simple_results

amram2_rom_io_decode:
ld c,1
call kl_rom_select
call kl_u_rom_enable


ld hl,&dfff
ld de,&2000
ld bc,amram2_rom_restore
ld ix,amram2_rom_dec_test
ld iy,amram2_rom_dec_init
jp io_decode

amram2_rom_dec_init:
ret

rom0_data:
defb 0
rom1_data:
defb 0
rom2_data:
defb 0
rom7_data:
defb 0

amram2_rom_dec_test:
push bc
ld a,1
ld bc,&fbf0
out (c),a
pop bc
ld a,1
out (c),a
ld bc,&7f00+%10001100
out (c),c
ld hl,&c000
ld (hl),&55
ld bc,&7f00+%10000100
out (c),c
ld a,(hl)
cp &55
ret nz
ld bc,&7f00+%10001100
out (c),c
ld hl,&c000
ld (hl),&aa
ld bc,&7f00+%10000100
out (c),c
ld a,(hl)
cp &aa
ret

amram2_data_io_decode:
ld c,1
call kl_rom_select
call kl_u_rom_enable

ld ix,result_buffer
ld h,&01
ld l,&ff
ld de,&fbf0
ld bc,amram2_data_restore
ld ix,amram2_data_dec_test
ld iy,amram2_data_dec_init
jp data_decode

amram2_rom_restore:
amram2_addr_restore:
amram2_data_restore:
xor a
ld bc,&fbf0
out (c),a
ld bc,&df01
out (c),c

ret


amram2_addr_io_decode:
ld c,1
call kl_rom_select
call kl_u_rom_enable

ld hl,&fbff
ld de,&0ff0
ld bc,amram2_addr_restore
ld ix,amram2_addr_dec_test
ld iy,amram2_addr_dec_init
jp io_decode

amram2_data_dec_init:
amram2_addr_dec_init:
ret


amram2_addr_dec_test:

ld a,1
out (c),a

amram2_data_dec_test:
ld bc,&df01
out (c),c
ld bc,&7f00+%10001100
out (c),c
ld hl,&c000
ld (hl),&55
ld bc,&7f00+%10000100
out (c),c
ld a,(hl)
cp &55
ret nz
ld bc,&7f00+%10001100
out (c),c
ld hl,&c000
ld (hl),&aa
ld bc,&7f00+%10000100
out (c),c
ld a,(hl)
cp &aa
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
