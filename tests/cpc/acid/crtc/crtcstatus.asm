;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../lib/testdef.asm"

;; crtc status lister
org &2000
start:



ld a,2
call &bc0e
ld ix,tests
call run_tests
ret

;; type 4:
;; fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,fe,de,
;; de lots
;; then 9e * 8
;; then be for 16
;; 9e for quite a lot
;; then de
;; 
;; af af af af 2f 2f 2f 0f
;; etc
;; a7 27 etc after a bit

;; 2 be:
;; fe, then be all the time

;; same as type 3




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;    765
;; %11110000
;; %11011110
;; %10011110
;; %10111110

;; '0' vsync len:
;; be x 15
;; 9e x3 char lines + 1 10011110
;; de for many lines <- vblank 11011110
;; then 9e for 8		10011110
;; then be for around 16 10111110
;; then 9e for a bit 10011110

;; bit 6??

;;fe 11111110
;;de 11011110
;;9e 10011110
;;be 10111110

;;bit 5 = last line of vertical sync (if 0 it stays on forever)
;; '15' vsync len:
;; fe x 14 ;; 11111110
;; de x  1  11011110
;; fe for 16 chars (vcc counter active)
;; + a bit more
;; then be for a bit (this is vadj): 1011 1110
;;  and 9e in the middle 1001110
;; 
;; bit 6 is vblank? after a few frames??
;; bit 5 is vsync end






;; 02 shows the values in order effectively
;; be for x5 and then 9e to indicate end of vsync
;; followed by be until frame begins
;; when frame begins see fe for r4*r7 and also for r5.
;; then it starts again
;;
;; 3 shows vertical in order for each scanline
;; ef ef 6f 6f 2f 2f 2f 0f
;; during r5 shows just ef ef 6f 6f 6f 2f 2f 2f 0f
;; then a line of 0f then ef ef 6f 2f 6f 2f 2f 0f
;; then 3 furthur f0 only


;; 03:
;; e7 a7 27 07 e7 e7 a7 27
;; 17 e7 a7 27 07 e7 e7 a7 27 17 e7 a7 27 07 e7 e7 a7 27 17 e7
;; around 8 char lines i then see 37
;; turns to ef for next frame? so bit 3 is frame?
;; ef ef af 2f 1f ef af 2f -f 

;; 3 be
;; a7 27 27 27 27 27 07 a7
;; 
;; e7 e7 e7 a7 a7 27 07
;;
;; cursor * 3
;; 
;; e7 11100111
;; a7 10100111
;; 27 00100111
;; 07 00000111

;; 2 fe until 07 which is de
;; 9 char lines later be (30 of them? 3 char lines, with 9e after 12)


;; 10100111
;; 00100111
;; 00000111
;; 
;; 11100111
;; 10100111 
;; 
;; bit 6 = cursor scanline match (seen on all lines)

;; b reads f, 2 reads 7
;; 
;; 07 -> rcc = r9
;; a7 -> rcc = 0
;; 2f -> rcc = ?
;;
;; de = vcc=r4?

;; fe, be (x42) (9e is 15 in)
;;
;; 2:
;; be/9e -> 9e on last line of vertical sync
;;
;; be/fe - fe when visible?

;;
;; 3: e7,e7,67,67,37,37,37,17
;; x 16 chars
;; e7 e7 67 77 37 37 37 17 

;;
;;
;; with r8=3
;; 4 chars be
;; then 1 char 7e
;; then fe
tests:
;; at 2 see de
;; at 10 see 9e
;; 10 from there on
DEFINE_TEST "status 2 (be)", status_2_be
DEFINE_TEST "status 3 (be)", status_3_be

;; show fe first... why? be x 7 then b6 and repeat
;; 
;; b6 every 8 frames, otherwise be
;; probably actual cursor output?
DEFINE_TEST "status 2 frames (be)", status_2_fr
;; e7 x 16, ef x 16
;; bit 3 is cursor flash state 16 or 32
DEFINE_TEST "status 3 frames (be)", status_3_fr
DEFINE_TEST "status a (be)", status_a_be
;; e7 e7 67 67 27 27 27 07
;; then ef ef 6f 6f 2f etc
DEFINE_TEST "status b (be)", status_b_be
DEFINE_TEST "status 12 (be)", status_12_be
DEFINE_TEST "status 13 (be)", status_13_be		;; b7,37,17
DEFINE_TEST "status 1a (be)", status_1a_be		;; same as 2
DEFINE_TEST "status 1b (be)", status_1b_be		;; bf for 8 lines, then b7
DEFINE_TEST "status 2 (bf)", status_2_bf	;; same as
DEFINE_TEST "status 3 (bf)", status_3_bf
DEFINE_TEST "status a (bf)", status_a_bf
DEFINE_TEST "status b (bf)", status_b_bf
DEFINE_TEST "status 12 (bf)", status_12_bf
DEFINE_TEST "status 13 (bf)", status_13_bf
DEFINE_TEST "status 1a (bf)", status_1a_bf
DEFINE_TEST "status 1b (bf)", status_1b_bf
DEFINE_END_TEST

status_2_be:
ld a,2
ld b,&be
jp status

status_3_be:
ld a,3
ld b,&be
jp status

status_a_be:
ld a,&a
ld b,&be
jp status

status_b_be:
ld a,&b
ld b,&be
jp status

status_12_be:
ld a,&12
ld b,&be
jp status

status_13_be:
ld a,&13
ld b,&be
jp status

status_1a_be:
ld a,&1a
ld b,&be
jp status

status_1b_be:
ld a,&1b
ld b,&be
jp status


status_2_bf:
ld a,2
ld b,&bf
jp status

status_3_bf:
ld a,3
ld b,&bf
jp status

status_a_bf:
ld a,&a
ld b,&bf
jp status

status_b_bf:
ld a,&b
ld b,&bf
jp status

status_12_bf:
ld a,&12
ld b,&bf
jp status

status_13_bf:
ld a,&13
ld b,&bf
jp status

status_1a_bf:
ld a,&1a
ld b,&bf
jp status

status_1b_bf:
ld a,&1b
ld b,&bf
jp status

;; 2: 16 is r4
;; first 6 chars are be is this border
;; next 10 chars are fe which is visible? + 3 for r5


;; 6 char lines be then fe for 10 lines char lines + 3 scanlines.
;; (r5?)
;; then a few lines for vsync end; all is cronological
status:
di
push bc
push af
ld bc,&bc04
out (c),c
ld bc,&bd00+15
out (c),c
ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+1
out (c),c

ld bc,&bc00+10
out (c),c
ld bc,&bd00+0+%00100000 ;; non display
out (c),c
;; seem 9e on line 2, then 6, then 8, then 7
ld bc,&bc03
out (c),c
ld bc,&bd00+&0f
out (c),c

ld bc,&bc08
out (c),c
ld bc,&bd00+0
out (c),c

;; a7 a7 a7 a7 27 27 27 07
;; 2 lines at which 07 only (during vertical adjust)
ld bc,&bc00+11
out (c),c
ld bc,&bd00+3
out (c),c

ld hl,&3000
ld bc,&bc00+12
out (c),c
inc b
out (c),h
inc c
dec b
out (c),c
inc b
out (c),l


ld hl,&3000
ld bc,&bc00+14
out (c),c
inc b
out (c),h
inc c
dec b
out (c),c
inc b
out (c),l


ld bc,&bc06
out (c),c
ld bc,&bd00+10
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
pop af
ld b,&bc
out (c),a
inc b



ld b,&f5
s1:
in a,(c)
rra
jr nc,s1
pop bc
ld de,312*6
ld hl,result_buffer
s2:
in a,(c)
ld (hl),a
inc hl
defs 64-2-2-4-2-1-1-3
dec de
ld a,d
or e
jp nz,s2

call crtc_reset

ei
ld ix,result_buffer
ld d,8
ld bc,312*6
call simple_number_grid
ret

status_2_fr:
ld a,2
ld b,&be
jr status_fr

status_3_fr:
ld a,3
ld b,&be
jr status_fr


status_fr:
di
push bc
push af
ld bc,&bc04
out (c),c
ld bc,&bd00+15
out (c),c
ld bc,&bc05
out (c),c
ld bc,&bd00+3
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+0
out (c),c

ld bc,&bc00+10
out (c),c
ld bc,&bd00+1+%01100000 ;; display, blink 32 field
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd00+&3f
out (c),c

ld bc,&bc08
out (c),c
ld bc,&bd00+0
out (c),c

ld bc,&bc00+11
out (c),c
ld bc,&bd00+4
out (c),c

ld hl,&3000
ld bc,&bc00+12
out (c),c
inc b
out (c),h
inc c
dec b
out (c),c
inc b
out (c),l


ld hl,&3000
ld bc,&bc00+14
out (c),c
inc b
out (c),h
inc c
dec b
out (c),c
inc b
out (c),l


ld bc,&bc06
out (c),c
ld bc,&bd00+2
out (c),c

ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
pop af
ld b,&bc
out (c),a
inc b
pop bc

ld hl,result_buffer
ld de,512
s1a:
push bc
ld b,&f5
s1b:
in a,(c)
rra
jr nc,s1b
pop bc
in a,(c)
ld (hl),a
inc hl
push bc
ld b,&f5
s3b:
in a,(c)
rra
jr c,s3b
pop bc
dec de
ld a,d
or e
jr nz,s1a

call crtc_reset

ei
ld ix,result_buffer
ld d,16
ld bc,512
call simple_number_grid
ret

;;-------------------------------------------

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
defb 63,40,46,&8e,38,0,25,30,0,7,0,0,&30,0,0,0,0

;;-----------------------------------------------------

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
include "../lib/int.asm"
;; firmware based output
include "../lib/fw/output.asm"

result_buffer: equ $

end start
