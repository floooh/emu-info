;; draw all pens on the screen
;; THIS NEEDS TESTING ON A REAL MACHINE
org &0000

start:
jp start2
org &0038
ei
ret
start2:
;; which pen is active by default at reset time?

ld sp,&c000

im 1

call set_crtc

ld hl,&4000
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&3fff
ldir

ld hl,&4000
ld b,16
ld de,pens
pl1:
ld a,(de)
push de
push hl
push bc

ld b,8
pl2:
push bc
push af
push hl
ld e,l
ld d,h
inc de
ld (hl),a
ld bc,80-1
ldir
pop hl
ld a,h
add a,8
ld h,a
pop af
pop bc
djnz pl2
pop bc
pop hl
ld de,80
add hl,de
pop de
inc de
djnz pl1
ld hl,&4000
ld de,&c000
ld bc,&4000
ldir
ei
ld hl,6*50*4
loopit2:
halt
dec hl
ld a,h
or l
jr nz,loopit2
;; change default pen
ld b,&7f
xor a
loopit3:
or &40
out (c),a
rept 6
halt
endm
inc a
and &1f
jp loopit3

set_crtc:
;; set initial CRTC settings (screen dimensions etc)
ld hl,end_crtc_data
ld bc,&bc0f
crtc_loop:
out (c),c
dec hl
ld a,(hl)
inc b
out (c),a
dec b
dec c
jp p,crtc_loop
ret


pens:
defb 0
defb &c0
defb &0c
defb &cc
defb &30
defb &f0
defb &3c
defb &fc
defb &03
defb &c3
defb &0f
defb &cf
defb &33
defb &f3
defb &3f
defb &ff

crtc_data:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
end_crtc_data:



end start

