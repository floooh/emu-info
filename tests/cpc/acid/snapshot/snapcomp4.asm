org &4000

;; fill all memory with different values
;; including e5
start:
ld hl,startcode
ld de,&ffff-(endcode-startcode)
ld bc,endcode-startcode
ldir
jp &ffff-(endcode-startcode)
startcode:
di
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

ld hl,&0001
ld bc,&ffff-(endcode-startcode)
ld d,0
s1:
ld (hl),d
inc hl
inc d
dec bc
ld a,b
or c
jr nz,s1


ld bc,&7f10
out (c),c
ld bc,&7f4b
out (c),c

loop:
jr loop
endcode:
end start