;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; see what hardware is initialised or not

;; sprites are at 0,0
;; random gfx
;; random colour
;; screen is mode 0 (was mode 2 at one point on power on??), random colours
;; top part is c000, split to 0000 I think. blocky tall colours

org &0
jp start

org &38
ei
ret

start:
ld sp,&bfff

ld hl,&c000
ld bc,&4000
ld e,0
ld d,0
s1:
ld (hl),d
inc e
ld a,e
cp 79
jr nz,s1b
ld e,0
inc d
s1b:
inc hl
dec bc
ld a,b
or c
jr nz,s1

ld hl,&0000
ld bc,&4000
ld d,0
s2:
ld (hl),d
ld a,d
add a,3
ld d,a
inc hl
dec bc
ld a,b
or c
jr nz,s2

ld hl,&4000
ld bc,&4000
ld d,0
s3:
ld (hl),d
ld a,d
inc a
and &f
ld d,a
inc hl
dec bc
ld a,b
or c
jr nz,s3

ld hl,&8000
ld bc,&4000
ld d,0
s4:
ld (hl),d
ld a,d
add a,&f1
ld d,a
inc hl
dec bc
ld a,b
or c
jr nz,s4

call crtc_reset

im 1
ei
call asic_enable
call asic_ram_enable

;; DO NOT SET:
;; - palette
;; - sprite pixels
;; - sprite coordinates
;; - split line


;; set screen split line
ld a,100
ld (&6801),a

ld b,16
ld hl,&6004
sprmag:
ld a,%0101
ld (hl),a
ld a,l
add a,8
ld l,a
djnz sprmag

loop:
jp loop

asic_ram_enable:
ld bc,&7fb8
out (c),c
ret

asic_ram_disable:
ld bc,&7fa0
out (c),c
ret


asic_enable:
	push af
	push hl
	push bc
	push de
 	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	pop de
	pop bc
	pop hl
	pop af	
	ret
	
asic_disable:
	push af
	push hl
	push bc
	push de
  ld hl,asic_sequence
	ld bc,&bc00
	ld d,15

ad1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ad1
ld a,&a5
out (c),a
pop de
	pop bc
	pop hl
	pop af	
	ret

crtc_reset:
di
ld hl,crtc_default_values
ld b,16
ld c,0
cr1:
push bc
ld b,&bc
out (c),c
inc b
ld a,(hl)
inc hl
out (c),a
pop bc
inc c
djnz cr1
ei
ret

crtc_default_values:
defb 63,50,50,&8e,38,0,&ff,30,0,7,0,0,&30,0,0,0,0

	
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee

end start

