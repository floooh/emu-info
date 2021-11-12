;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000

start:
ld c,7
ld de,&0040
ld hl,&a6ff
call &bcce

ld b,end_filename1-filename1
ld hl,filename1
ld de,&c000
call &bc77
ld hl,&c000
call &bc83
call &bc7a

ld b,end_filename2-filename2
ld hl,filename2
ld de,&c000
call &bc77
ld hl,&4000
call &bc83
call &bc7a

ld hl,&c000
ld de,&4000
ld bc,&4000

make:
ld a,(de)
rrca
rrca
or (hl)
ld (hl),a
inc hl
inc de
dec bc
ld a,b
or c
jr nz,make

ld b,end_filename3-filename3
ld hl,filename3
ld de,&c000
call &bc8c
ld hl,&c000
ld de,&4000
ld bc,&4000
ld a,2
call &bc98
call &bc8f
ret

filename1:
defb "alan"
end_filename1:

filename2:
defb "cpc6128"
end_filename2:

filename3:
defb "mode3scr"
end_filename3:

end start

