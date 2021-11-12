;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &0000

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

ld (sp_reset),sp		;; C077
ld (hl_reset),hl		;; FD FD
ld sp,&c000
push af
pop hl
ld (af_reset),hl		;; FDFF
ld (de_reset),de		;; FFF7
ld (bc_reset),bc		;; FDFD
ld (ix_reset),ix		;; FFBF
ld (iy_reset),iy		;; FDFF
exx
ld (hl_alt_reset),hl		;; FFFF
ld (de_alt_reset),de		;; FFFF
ld (bc_alt_reset),bc		;; FFFF
exx
ex af,af'
push af
pop hl
ld (af_alt_reset),hl		;; FDFF
ex af,af'
ld a,i
ld (i_reset),a		
ld a,r
ld (r_reset),a
push af
pop hl
ld a,l
ld (iff2_reset),a

di
ld hl,test_ram
ld de,&a000
ld bc,end_test_ram-test_ram
ldir
jp &a000

test_ram:
incbin "test.bin"
end_test_ram:

org &3fff
defb 0
