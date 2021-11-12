;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,2
call scr_set_mode

ld bc,24*80
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1
ld h,1
ld l,1
call &bb75
ld a,'A'
call &bb5a
ld a,'A'
call &bb5a

;; type 2: short screen. 25 chars tall visible but 1 line each
;; vsync does hit.
;; AND ma is operating correctly

;;ld bc,&bc09
;;out (c),c
;;ld bc,&bd00
;;out (c),c
;;ld bc,&bc04
;;out (c),c
;;ld bc,&bd00
;;out (c),c

;; taller screen but not big enough for an entire frame, probably need to split
;; AND ma is operating correctly
;;ld bc,&bc09
;;out (c),c
;;ld bc,&bd00
;;out (c),c
;;ld bc,&bc04
;;out (c),c
;;ld bc,&bd00
;;out (c),c
;;ld bc,&bc07
;;out (c),c
;;ld bc,&bd00+&7f
;;out (c),c
;;ld bc,&bc06
;;out (c),c
;;ld bc,&bd00+&7f
;;out (c),c

;; it seems bc04=0 is &80 height
;; is bc04 decremented?
;; also works, but still vsync and there is 1 line of border
;; AND ma is operating correctly
;;ld bc,&bc09
;;out (c),c
;;ld bc,&bd00
;;out (c),c
;;ld bc,&bc04
;;out (c),c
;;ld bc,&bd00
;;out (c),c
;;ld bc,&bc07
;;out (c),c
;;ld bc,&bd00
;;out (c),c
;;ld bc,&bc06
;;out (c),c
;;ld bc,&bd00+&7f
;;out (c),c

;; better
ld bc,&bc01
out (c),c
ld bc,&bd00+64
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+&7f
out (c),c

;; on type 0/1 bc09=0 doesn't allow hdisp to trigger because of bc04=0
;; on type 2, hdisp happens and updates. either turn it off with bc09 tweak
;; OR part way through the frame turn off vsync with bc07 to avoid match.

;; to make flood happen you need 
ld bc,&bc01
out (c),c
ld bc,&bd00+64
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00+&0
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+&7f
out (c),c


loop:
ld b,&f5
loop2:
in a,(c)
rra
jr nc,loop2

jp loop

end start
