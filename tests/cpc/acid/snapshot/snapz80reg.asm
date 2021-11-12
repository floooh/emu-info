;; Use this to test storing and restoring of Z80
;; registers
;;
;; border should remain grey, if it changes colours
;; some registers are not stored correctly.
;; 
;; NOT tested PC, F, F' and R,SP
org &8000

start:
di
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

ld hl,&c9fb
ld (&0038),hl

ex af,af'
ld a,&bb
ex af,af'
ld a,&cc
push af
;; initialise all registers
ld hl,&1112
ld de,&2223
ld bc,&3334
exx
ld hl,&4445
ld de,&5556
ld bc,&6667
exx
ld ix,&7778
ld iy,&8889
;;ld sp,&999a		
ld a,&ab
ld i,a			
im 1			
ld a,&80
ld r,a
pop af
di

loop:
cp &cc
jr nz,bad_snap
push af
ld a,&11
cp h
jr nz,bad_snap
ld a,&12
cp l
jr nz,bad_snap
ld a,&22
cp d
jr nz,bad_snap
ld a,&23
cp e
jr nz,bad_snap
ld a,&33
cp b
jr nz,bad_snap
ld a,&34
cp c
jr nz,bad_snap
exx
ld a,&44
cp h
jr nz,bad_snap
ld a,&45
cp l
jr nz,bad_snap
ld a,&55
cp d
jr nz,bad_snap
ld a,&56
cp e
jr nz,bad_snap
ld a,&66
cp b
jr nz,bad_snap
ld a,&67
cp c
jr nz,bad_snap
exx
ld a,&77
defb &dd
cp h
jr nz,bad_snap
ld a,&78
defb &dd
cp l
jr nz,bad_snap
ld a,&88
defb &fd
cp h
jr nz,bad_snap
ld a,&89
defb &fd
cp l
jr nz,bad_snap
ld a,i
cp &ab
jr nz,bad_snap
ex af,af'
cp &bb
jr nz,bad_snap
ex af,af'
ld a,r
and &80
jr z,bad_snap
;;ld a,&99
;;cp h
;;jr z,bad_snap
;;ld a,&9a
;;cp l
;;jr z,bad_snap
pop af
jp loop

bad_snap:
ld bc,&7f10
out (c),c
ld c,0
bs:
ld a,c
and &1f
or &40
out (c),a
inc c
jr bs

end start