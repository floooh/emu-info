;; Example screen display code for CPC Plus
;; This works with the firmware

scr_set_mode equ &bc0e
kl_new_frame_fly equ &bcd7
kl_del_frame_fly equ &bcdd
km_wait_char equ &bb06
scr_reset equ &bc02

;; defined by batch file
screen_mode equ 0

org &170

;; BASIC code:
;; 10 CALL &xxxx

start:
basic_line_10:
defw end_of_basic_line_10-basic_line_10		;; length in bytes
defw 10										;; line number
defb &83									;; "CALL"
defb " "
defb &1c									;; 16-bit hexidecimal number
defw code_start
defb 0										;; end of line marker
end_of_basic_line_10:
defw 0										;; end of program

plus_colours:
;;include "temp/plus_palette.asm"
end_plus_colours:

code_start:
call scr_reset

;; set display mode
ld a,screen_mode
call scr_set_mode

;; turn off firmwares interrupt that sets the colour every vsync 
ld hl,&b7f9
call kl_del_frame_fly

ld hl,crtc_vals
call set_crtc


di
call unlock_asic

;; page in asic ram
ld bc,&7fb8
out (c),c

;; set colours
ld hl,plus_colours
ld de,&6400
ld bc,end_plus_colours-plus_colours
ldir
ld hl,0
ld (&6420),hl

;; page it back out again
ld bc,&7fa0
out (c),c
ei

;; copy 2nd picture to screen
ld hl,end_pixels2
ld de,&c000+(end_pixels2-pixels2)
ld bc,end_pixels2-pixels2
lddr

;; copy 1st picture to screen
ld hl,end_pixels1
ld de,&4000+(end_pixels1-pixels1)
ld bc,end_pixels1-pixels1
lddr

ld hl,ff_event_block
ld b,&81
ld c,0
ld de,ff_event_routine
call kl_new_frame_fly

call km_wait_char

ld hl,ff_event_block
call kl_del_frame_fly
ret

scr_swap equ &30 xor &10

if screen_mode=0
	scrl_swap equ (4*16) xor (0*16)
endif

if screen_mode=1
	scrl_swap equ (2*16) xor (0*16)
endif

ff_event_block:
defs 10

ff_event_routine:
ret

scrl_val:
push bc
push af


;; page in asic ram
ld bc,&7fb8
out (c),c

;; update scroll
ld a,(scrl)
ld (&6804),a

;; page out ram
ld bc,&7fa0
out (c),c

ld a,(scr_base)
ld bc,&bc0c
out (c),c
inc b
out (c),a

ld a,(scr_base)
xor scr_swap
ld (scr_base),a

ld a,(scrl)
xor scrl_swap
ld (scrl),a
pop af
pop bc
ret

scrl:
defb 0

scr_base:
defb &30

pixels1:
;;incbin "temp/plus_pic1.bin"
end_pixels1:

pixels2:
;;incbin "temp/plus_pic2.bin"
end_pixels2:

set_crtc:
ld bc,&bc00
set_crtc_vals:
out (c),c
inc b
ld a,(hl)
out (c),a
dec b
inc hl
inc c
ld a,c
cp 10
jr nz,set_crtc_vals
ret

;; unlock asic
unlock_asic:
ld b,&bc
ld hl,asic_unlock_sequence
ld e,17
seq:
ld a,(hl)
out (c),a
inc hl
dec e
jr nz,seq
ret

crtc_vals:
defb 63
defb 40
defb 46
defb &8e
defb 38
defb 0
defb 25
defb 30
defb 0
defb 7

asic_unlock_sequence:
defb &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee


end start


