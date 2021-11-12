;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; NEEDS TESTING ON A REAL MACHINE

include "../lib/testdef.asm"

org &9001
start:
kl_l_rom_disable equ &b909
kl_l_rom_enable equ &b906
kl_u_rom_enable equ &b900
kl_u_rom_disable equ &b903
kl_rom_select equ &b90f

ld hl,result_buffer
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&a700-&9001
ldir

ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

tests:
DEFINE_TEST "Aleste RAM (MAPMOD=0) (c0-ff) (7bxx)",aleste_ram_7c
DEFINE_TEST "Aleste RAM (MAPMOD=0) (c0-ff) (7cxx)",aleste_ram_7d
DEFINE_TEST "Aleste RAM (MAPMOD=0) (c0-ff) (7exx)",aleste_ram_7e
DEFINE_TEST "Aleste RAM (MAPMOD=0) (c0-ff) (7fxx)",aleste_ram_7f
DEFINE_TEST "Aleste RAM (MAPMOD=1) (7cxx)",aleste_ram_0000
DEFINE_TEST "Aleste RAM (MAPMOD=1) (7dxx)",aleste_ram_4000
DEFINE_TEST "Aleste RAM (MAPMOD=1) (7fxx)",aleste_ram_c000
DEFINE_END_TEST

aleste_ram_7c:
ld d,&7c
jr aleste_ram

aleste_ram_7d:
ld d,&7d
jr aleste_ram

aleste_ram_7e:
ld d,&7e
jr aleste_ram

aleste_ram_7f:
ld d,&7f
jr aleste_ram

aleste_ram:
push de
call ram_init
pop de

ld ix,result_buffer
ld bc,&fabf
ld a,%1000	;; disable map mod
out (c),a

di
ld b,64
xor a
ar1:
push bc
push af
ld c,a
;; skip 2
and &7
cp 2
jr z,ar2
;; cpc style 
ld b,d
ld a,c
or %11000000
out (c),a

call read_mapper
;; read from ram
call read_ram
jr ar3

ar2:
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix
ld (ix+0),0
inc ix
inc ix

ar3:
pop af
inc a
pop bc
djnz ar1
ld ix,result_buffer
ld bc,&fabf
ld a,%1000	;; disable map mod
out (c),a

ld bc,&7fc0
out (c),c
ei

ld ix,result_buffer
ld bc,8*64
call simple_results
ret


aleste_ram_0000:
ld d,&7c
jr aleste_ram2

aleste_ram_4000:
ld d,&7d
jr aleste_ram2

aleste_ram_8000:
ld d,&7e
jr aleste_ram2

aleste_ram_c000:
ld d,&7f
jr aleste_ram2

aleste_ram2:
push de
call ram_init
pop de

ld ix,result_buffer


di
ld bc,&fabf
ld a,%1100	;; enable map mod
out (c),a

ld b,64
xor a
arm1:
push bc
push af
ld b,d
or %1100000
out (c),a

call read_mapper
;; read from ram
call read_ram

pop af
inc a
pop bc
djnz arm1

ld bc,&fabf
ld a,%1000	;; enable map mod
out (c),a


ld bc,&7fc0
out (c),c
ei

ld ix,result_buffer
ld bc,64*8
call simple_results
ret

read_mapper:
;; read from mapper
ld b,&7c
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld b,&7d
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld b,&7e
in a,(c)
ld (ix+0),a
inc ix
inc ix
ld b,&7f
in a,(c)
ld (ix+0),a
inc ix
inc ix
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

test_config:
defw 0

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
