org &8000

start:
di

ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

;; c000-&ffff is all the numbers excluding
;; e5,04,nn
ld hl,&c000
ld bc,&4000
ld d,0
s1:
ld (hl),d
inc hl
inc d
ld a,d
cp &e5
jr nz,s2
inc d
s2:
dec bc
ld a,b
or c
jr nz,s1

;; e5,ff,e5
;;... e5,40,e5
;; 4000-ffff is only e5
ld hl,&4000
ld e,l
ld d,h
ld (hl),&e5
inc de
ld bc,&3fff
ldir

;; code has e5,00

;; &0000-&3fff
;; each byte repeated 4 times
ld hl,&0000
ld bc,&4000/4
ld d,0
s4:
rept 4
ld (hl),d
inc hl
endm
inc d
dec bc
ld a,b
or c
jr nz,s4

ld bc,&7f10
out (c),c
ld bc,&7f4b
out (c),c
loop:
jp loop


end start