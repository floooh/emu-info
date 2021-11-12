;; setup IM 2 interrupt handler
;; when snapshot is loaded border colour should remain
;; grey, if it changes, then IM is not restored correctly.
org &8000

start:
di
im 2
ld hl,&a0a0
ld d,l
ld e,h
inc de
ld (hl),&a2
ld bc,257
ldir
ld a,&a0
ld i,a

ld a,&c3
ld hl,int_handler
ld (&a2a2),a
ld (&a2a3),hl

ld a,&c3
ld hl,bad_int_handler
ld (&0038),a
ld (&0039),hl
ei
loop:
jp loop

int_handler:
push bc
ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c
pop bc
ei
ret

bad_int_handler:
push bc
ld bc,&7f10
out (c),c
ld bc,&7f43
out (c),c
pop bc
ei
ret



end start
