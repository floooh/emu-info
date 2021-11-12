;; setup memory with patterns to test the compression and to set hardware to a known state
;; with this we can test if we can recover or not

;; snapshot tester
org &8000

;; no repetition
ld bc,&7fc4
out (c),c
ld hl,&4000
ld bc,&4000
ld e,0
f1:
ld (hl),e
inc e
ld a,e
cp &e5
jr nz,f1a
;; avoid e5
inc e
f1a:
dec bc
ld a,b
or c
jr nz,f1

;; e5 repetition
ld bc,&7fc5
out (c),c
ld hl,&4000
ld bc,&4000
ld e,&e5
f2:
ld (hl),e
dec bc
ld a,b
or c
jr nz,f2

;; zero repetition
ld bc,&7fc6
out (c),c
ld hl,&4000
ld bc,&4000
ld e,&00
f3:
ld (hl),e
dec bc
ld a,b
or c
jr nz,f3


;; zero repetition; including e5
ld bc,&7fc7
out (c),c
ld hl,&4000
ld bc,&4000
ld e,&00
f4:
ld (hl),e
inc e
dec bc
ld a,b
or c
jr nz,f4


;; two of each 
ld bc,&7fc0
out (c),c
ld hl,&4000
ld bc,&4000
ld d,2
ld e,&00
f5:
ld (hl),e
dec d
jr nz,f5b
ld d,2
inc e
f5b:
dec bc
ld a,b
or c
jr nz,f5


;; three of each
ld bc,&7fc0
out (c),c
ld hl,&c000
ld bc,&4000
ld d,3
ld e,&00
f6:
ld (hl),e
dec d
jr nz,f6b
ld d,3
inc e
f6b:
dec bc
ld a,b
or c
jr nz,f6

di
;; palette + pen value
ld e,16
ld b,&7f
ld c,0
c1:
out (c),c
ld a,c
or &40
out (c),a
inc c
dec e
jr nz,c1

;; select upper rom index
ld bc,&df00+&80
out (c),c

ld hl,&1111
ld de,&2222
ld bc,&3333
ex de,hl
ld hl,&4444
ld de,&5555
ld bc,&6666
ex de,hl
ld ix,&7777
ld iy,&8888
ld a,&99
ld i,a
ld a,&aa
ld r,a

loop:
jp loop