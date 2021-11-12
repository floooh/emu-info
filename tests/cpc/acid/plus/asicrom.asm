;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

include "../lib/testdef.asm"

org &9100
start:

;; unlock asic
di
call asic_enable
ei

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;;-----------------------------------------------------

;; TODO: All cart pages
;; TODO: dfxx decoding
tests:
DEFINE_TEST "RMR2 configs (bit 3,4)", check_rmr2
DEFINE_TEST "RMR2 (bits 2..0) - low rom cart page", check_rmr_rom
DEFINE_TEST "check rmr2 writethrough (bits 4 and 3)", check_rmr_wt
DEFINE_END_TEST

;;-----------------------------------------------------
check_rmr_wt:
di
ld ix,result_buffer
push ix
;; ram writes through to &0000
ld (ix+1),&11
inc ix
inc ix
ld (ix+1),&02
inc ix
inc ix
ld (ix+1),&03
inc ix
inc ix
ld (ix+1),&04
inc ix
inc ix

;; ram writes through to &0000
ld (ix+1),&11
inc ix
inc ix
ld (ix+1),&02
inc ix
inc ix
ld (ix+1),&03
inc ix
inc ix
ld (ix+1),&04
inc ix
inc ix

if 0
;; ram writes through to &8000
ld (ix+1),&01
inc ix
inc ix
ld (ix+1),&02
inc ix
inc ix
ld (ix+1),&11
inc ix
inc ix
ld (ix+1),&04
inc ix
inc ix
endif

;; ram writes through to &4000
ld (ix+1),&01
inc ix
inc ix
ld (ix+1),&11
inc ix
inc ix
ld (ix+1),&03
inc ix
inc ix
ld (ix+1),&04
inc ix
inc ix

pop ix


call init_ram
;; enable lower rom
ld bc,&7f00+%10001000
out (c),c
;; lower rom at &0000-&3fff
ld b,&7f
ld c,%10100000
out (c),c
ld a,&11
ld (&1000),a
call read_ram_state

call init_ram
;; enable lower rom
ld bc,&7f00+%10001000
out (c),c
;; register page on, low bank rom in position &0000-&3fff
ld b,&7f
ld c,%10111000
out (c),c
ld a,&11
ld (&1000),a
call read_ram_state

if 0
call init_ram
;; enable lower rom
ld bc,&7f00+%10001000
out (c),c
;; register page on, low bank rom in position &8000-&ffff
ld b,&7f
ld c,%10110000
out (c),c
ld a,&11
ld (&9000),a
call read_ram_state
endif

call init_ram
;; enable lower rom
ld bc,&7f00+%10001000
out (c),c
;; register page off, low bank rom in position &4000-&3fff
ld b,&7f
ld c,%10101000
out (c),c
ld a,&11
ld (&5000),a
call read_ram_state

call restore_ram_rom

ei
ld ix,result_buffer
ld bc,3*4
call simple_results
ret

read_ram_state:
ld bc,&7fc0
out (c),c
ld bc,&7f00+%10001100
out (c),c
ld bc,&7f00+%10100000
out (c),c
ld a,(&1000)
ld (ix+0),a
inc ix
inc ix
ld a,(&5000)
ld (ix+0),a
inc ix
inc ix
ld a,(&9000)
ld (ix+0),a
inc ix
inc ix
ld a,(&d000)
ld (ix+0),a
inc ix
inc ix
ret

;;-----------------------------------------------------
;; HL = address
;; C = 0 (no), 1 (rom), 2 (yes).
check_register_page:
;; write value
ld b,&aa
ld (hl),b
;; read it back
ld a,(hl)
ld (ix+0),a
inc ix
;; c = 0 to mean it's not
ld a,c
cp 0
ld a,b
jr z,crp1
ld a,c
cp 1
ld a,(lowrom2)
jr z,crp1
ld a,b
and &0f
crp1:
ld (ix+0),a
inc ix
ret
;;-----------------------------------------------------

check_rmr2:
di
call init_ram

ld ix,result_buffer
;; page 0 in &c000-&ffff
ld bc,&df00+&80
out (c),c
ld bc,&7f00+%10100000
out (c),c
;; enable upper rom; disable lower
ld bc,&7f00+%10000100
out (c),c
ld a,(&d000)
ld (lowrom),a
ld a,(&e401)
ld (lowrom2),a

;; disable upper rom now; enable lower rom
ld bc,&7f00+%10001000
out (c),c

;; register page off, low bank rom in position 0-3fff
ld b,&7f
ld c,%10100000
out (c),c

;; check what we got...
ld a,(&1000)
ld (ix+0),a
inc ix
ld a,(lowrom)
ld (ix+0),a
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),&02
inc ix

ld a,(&9000)
ld (ix+0),a
inc ix
ld (ix+0),&03
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&04
inc ix

ld hl,&2401
ld c,1
call check_register_page
ld hl,&6401
ld c,0
call check_register_page
ld hl,&a401
ld c,0
call check_register_page
ld hl,&e401
ld c,0
call check_register_page

;; register page off, low bank rom in position &4000-&7fff
ld b,&7f
ld c,%10101000
out (c),c

;; check what we got...
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),&01
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
ld a,(lowrom)
ld (ix+0),a
inc ix

ld a,(&9000)
ld (ix+0),a
inc ix
ld (ix+0),&03
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&04
inc ix

ld hl,&2401
ld c,0
call check_register_page
ld hl,&6401
ld c,1
call check_register_page
ld hl,&a401
ld c,0
call check_register_page
ld hl,&e401
ld c,0
call check_register_page

if 0
;; register page off, low bank rom in position &8000-&ffff
ld b,&7f
ld c,%10110000
out (c),c

;; check what we got...
ld a,(&1000)
ld (ix+0),a
inc ix
ld (ix+0),&01
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),&02
inc ix

ld a,(&9000)
ld (ix+0),a
inc ix
ld a,(lowrom)
ld (ix+0),a
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&04
inc ix

ld hl,&2401
ld c,0
call check_register_page
ld hl,&6401
ld c,0
call check_register_page
ld hl,&a401
ld c,0
call check_register_page
ld hl,&e401
ld c,0
call check_register_page
endif

;; register page on, low bank rom in position &0000-&3fff
ld b,&7f
ld c,%10111000
out (c),c

;; check what we got...
ld a,(&1000)
ld (ix+0),a
inc ix
ld a,(lowrom)
ld (ix+0),a
inc ix

ld a,(&5000)
ld (ix+0),a
inc ix
ld (ix+0),&50	;; because of floating bus
inc ix

ld a,(&9000)
ld (ix+0),a
inc ix
ld (ix+0),&03
inc ix

ld a,(&d000)
ld (ix+0),a
inc ix
ld (ix+0),&04
inc ix
	
ld hl,&2401
ld c,1
call check_register_page
ld hl,&6401
ld c,2
call check_register_page
ld hl,&a401
ld c,0
call check_register_page
ld hl,&e401
ld c,0
call check_register_page

call restore_ram_rom
ei
ld ix,result_buffer
ld bc,8*3
call simple_results
ret

restore_ram_rom:
ld b,&7f
ld c,%10100000
out (c),c
ld b,&7f
ld c,%10000000
out (c),c
ld bc,&df00
out (c),c
ld bc,&7fc0
out (c),c
ret

;;-----------------------------------------------------

;; hl = address
;; C = select
check_rom:

cro2:
;; select it in lower area
ld b,&7f
out (c),c

;; select it in upper area
ld b,&df
ld a,c
and &7
or &80
out (c),a

;; same byte from each...
ld a,(hl)
ld (ix+0),a
inc ix
ld a,(&d000)
ld (ix+0),a
inc ix

;; increment rom count
ld a,c
inc a
and &7
ld b,a

;; keep previous bits
ld a,c
and %11111000
;; and combine
or b
ld c,a

;; did we loop around?
ld a,b
or a
jr nz,cro2
ret

init_ram:
push hl
push bc
;; reset rmr2
ld bc,&7f00+%10100000
out (c),c
;; turn off roms
ld bc,&7f00+%10001100
out (c),c
;; reset ram config
ld bc,&7fc0
out (c),c
;; initialise ram
ld hl,&1000
ld (hl),&01
ld hl,&5000
ld (hl),&02
ld hl,&9000
ld (hl),&03
ld hl,&d000
ld (hl),&04
pop bc
pop hl
ret


;;-----------------------------------------------------


check_rmr_rom:
di
call init_ram


ld ix,result_buffer
;; enable upper and lower rom
ld bc,&7f00+%10000000
out (c),c


;; register page off, low bank rom in position 0-3fff
ld b,&7f
ld c,%10100000
out (c),c

ld hl,&1000
call check_rom

;; register page off, low bank rom in position &4000-&7fff
ld b,&7f
ld c,%10101000
out (c),c

ld hl,&5000
call check_rom

if 0
;; register page off, low bank rom in position &8000-&ffff
ld b,&7f
ld c,%10110000
out (c),c
ld hl,&9000
call check_rom
endif

;; register page on, low bank rom in position &0000-&3fff
ld b,&7f
ld c,%10111000
out (c),c

ld hl,&1000
call check_rom

call restore_ram_rom

ei
ld ix,result_buffer
ld bc,8*3
call simple_results
ret

asic_ram_enable:
ld bc,&7fb8
out (c),c
ret

asic_ram_disable:
ld bc,&7fa0
out (c),c
ret

lowrom:
defb 0
lowrom2:
defb 0

asic_enable:
  call asic_w_seq
	ld a,&ee
	out (c),a
	ret
asic_disable:
  call asic_w_seq
  ld a,&ae
  out (c),a
  ret
  
asic_w_seq:
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,16

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	ret
  
	
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd

;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
include "../lib/int.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $

end start
