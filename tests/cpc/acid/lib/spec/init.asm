init:
ex (sp),hl
;; set stack
ld sp,&0
push hl
;; set interrupts
di
im 2
ld hl,&fdfd
ld e,l
ld d,h
ld (hl),&fe
inc de
ld bc,257
ldir
ld a,&fd
ld i,a
ld a,&c3
ld (&fefe),a
ld hl,int_handler
ld (&feff),hl
ei
;; set border to black turn off cassette etc
ld bc,&00fe
ld a,&7
out (c),a
ret

int_handler:
ei
reti

do_restart:
rst 0
