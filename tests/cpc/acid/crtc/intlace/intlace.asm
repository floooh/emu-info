;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
;;
;; This uses interlace sync and video mode to show two screens (32KB)
;; works on type 0,1,2,3 and 4.
org &01a0

km_wait_char equ &bb06
txt_output equ &bb5a

incbin "lotus.bin"

display_text:
ld a,(hl)
inc hl
or a
ret z
call txt_output
jr display_text

message:
defb "CRTC type? 0,1,2,3,4,5",0

crtc_type:
defb 0

;; on type 2: we only need to set bc00,8:out &bd00,3
;; only if we set R9 to 3 do we see what we see on type 1 with R9=7.
;; if we set r9 to even, the counter loops and shows at least 2 lines repeated (2 and a half??)
;;
;; on type 1 it is as we expect. We can use odd and even values and it works ok.
;; to see same as type 3, we need to make bc09 = 8
;; 
;; on type 3: we need to set bc09=6, otherwise we see repeated lines!?
;; same need for 4 and 7 and 6.

start:
ld hl,message
call display_text
start1:
call km_wait_char
cp '0'
jr c,start1
cp '5'
jr nc,start1
sub '0'
ld (crtc_type),a
di

ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c

ld bc,&7f01
out (c),c
ld bc,&7f40
out (c),c

ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

;; mode 2; roms off
ld bc,&7f00+%10001110
out (c),c

;; interlace sync and video mode
ld bc,&bc08
out (c),c
ld bc,&bd03
out (c),c

;; R9 must be odd
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c

ld a,(crtc_type)
cp 2
jr z,set_base

;; on type 1 we need this code
;; on type 2 we don't need *ANY* of this
;; just set BC08 to 3 and set base. That is it.
ld bc,&bc04
out (c),c
ld bc,&bd00+(39*2)-1
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+(30*2)-1
out (c),c

ld bc,&bc06
out (c),c
ld bc,&bd00+50
out (c),c

set_base:
;; 32kb screen
ld h,&00+%001100
ld l,&d0
ld bc,&bc0c
out (c),c
inc b
out (c),h
dec b
inc c
out (c),c
inc b
out (c),l

loop:
jp loop

scr_next_line:
ld a,h
add a,8
ld h,a
ret nc
ld a,l
add a,&50
ld l,a
ld a,h
adc a,&c0
ld h,a
ret


end start