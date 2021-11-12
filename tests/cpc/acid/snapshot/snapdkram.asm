;; setup Dk'ram block and check it's restored
org &8000

start:
di
ld hl,&c9fb
ld (&0038),hl

ld bc,&7fc4
out (c),c
ld hl,&4000
ld e,l
ld d,h
ld (hl),&5
inc de
ld bc,&3fff
ldir
ld bc,&7fc5
out (c),c
ld hl,&4000
ld e,l
ld d,h
ld (hl),&6
inc de
ld bc,&3fff
ldir
ld bc,&7fc6
out (c),c
ld hl,&4000
ld e,l
ld d,h
ld (hl),&7
inc de
ld bc,&3fff
ldir
ld bc,&7fc7
out (c),c
ld hl,&4000
ld e,l
ld d,h
ld (hl),&8
inc de
ld bc,&3fff
ldir
ld bc,&7fc0
out (c),c
ld hl,&4000
ld e,l
ld d,h
ld (hl),&02
inc de
ld bc,&3fff
ldir
ld hl,&0040
ld e,l
ld d,h
ld (hl),&01
inc de
ld bc,&4000-&0040-1
ldir
ld hl,&c000
ld e,l
ld d,h
ld (hl),&04
inc de
ld bc,&3fff
ldir
ld hl,codeend
ld e,l
ld d,h
ld (hl),&03
inc e
ld bc,&bfff-codeend-1
ldir
ld bc,&7fc5
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c
loop:
ld a,(&1000)
cp 1
jr nz,bad
ld a,(&5000)
cp 6
jr nz,bad
ld a,(&9000)
cp 3
jr nz,bad
ld a,(&d000)
cp 4
jr nz,bad

jp loop

bad:
ld bc,&7f10
out (c),c
ld bc,&7f4b
out (c),c
jr bad

codeend:
defb 0

end start
