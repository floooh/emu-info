;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; 8 scan lines top of screen
;; then 256 lines of graphics
;; then 8 scanlines of panel at bottom.

panel_top equ 8        ;; please keep this a multiple of 8 to make the code work
panel_top_pri equ ((panel_top-1)*8)

height_middle equ 28 ;; scanline height is *8
middle_pri equ ((height_middle-1)*8)+7

panel_bottom equ 8 ;; please keep this a multiple of 8 to make the code work
panel_bottom_pri equ ((panel_bottom-1)*8)

height_final equ (312-(panel_top+panel_bottom+(height_middle*8)))/8
final_pri equ 7+(height_final*8)

org &8000

start:
di
call asic_enable
ld a,&c3
ld (&0038),a
ld hl,final_int    ;; re-written
ld (&0039),hl

ld hl,&4000
ld e,l
ld d,h
inc de
ld (hl),&ff
ldir

ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),&aa
ld bc,&3fff
ldir

ld bc,&bc07
out (c),c
ld bc,&bd00+&ff
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+&ff
out (c),c
call final_int

loop:
jp loop


asic_enable:
    push af
    push hl
    push bc
    push de
    ld hl,asic_sequence
    ld bc,&bc00
    ld d,16

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
   
    ld a,&ee
    out (c),a
    pop de
    pop bc
    pop hl
    pop af   
    ret

asic_sequence:
defb &ff,&00        ;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd

;;----------------------------------------------------------------------------

middle_part_int:
push hl
push af
push bc

;; height of char lines in scanlines
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

;; height of middle area in char lines
ld bc,&bc04
out (c),c
ld bc,&bd00+height_middle-1
out (c),c

ld bc,&7fb8
out (c),c

;; last line of screen
ld a,middle_pri
ld (&6800),a

ld bc,&7fa0
out (c),c

;; screen address bottom panel
ld bc,&bc0c
out (c),c
ld bc,&bd00+&20
out (c),c

ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c


ld hl,panel_bottom_int
ld (&0039),hl

pop bc
pop af
pop hl
ei
ret


;;----------------------------------------------------------------------------


panel_bottom_int:
push hl
push af
push bc
;; setup panel
ld bc,&bc04
out (c),c
ld bc,&bd00+panel_bottom-1
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c

ld bc,&7fb8
out (c),c

ld a,panel_bottom_pri
ld (&6800),a

ld bc,&7fa0
out (c),c

ld hl,final_int
ld (&0039),hl

pop bc
pop af
pop hl
ei
ret


;; this int ensures there are 312 total scanlines on the screen
;;
final_int:
push hl
push af
push bc

;; char height in lines
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

;; all border please.
ld bc,&bc08
out (c),c
ld bc,&bd00+%110000
out (c),c

;; height in char lines
ld bc,&bc04
out (c),c
ld bc,&bd00+height_final
out (c),c

;; centralise vsync
ld bc,&bc07
out (c),c
ld bc,&bd00+(height_final/2)
out (c),c

ld bc,&7fb8
out (c),c

;; int at the end please
ld a,final_pri
ld (&6800),a

;; screen address top panel
ld bc,&bc0c
out (c),c
ld bc,&bd00+&10
out (c),c

ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c

ld bc,&7fa0
out (c),c



ld hl,panel_top_int
ld (&0039),hl

pop bc
pop af
pop hl
ei
ret

;;----------------------------------------------------------------------------

panel_top_int:
push hl
push af
push bc

;; setup panel height in lines
ld bc,&bc04
out (c),c
ld bc,&bd00+panel_top-1
out (c),c

;; single line height
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c

;; all border please.
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c

;; no vsync
ld bc,&bc07
out (c),c
ld bc,&bd00+&ff
out (c),c

ld bc,&7fb8
out (c),c

ld a,panel_top_pri
ld (&6800),a

ld bc,&7fa0
out (c),c

;; screen address middle
ld bc,&bc0c
out (c),c
ld bc,&bd00+&30
out (c),c

ld bc,&bc0d
out (c),c
ld bc,&bd00
out (c),c


ld hl,middle_part_int
ld (&0039),hl

pop bc
pop af
pop hl
ei
ret

;;----------------------------------------------------------------------------


end start