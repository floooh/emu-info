org &4000

;; playcity, nmi int happens at 2nd byte of @
;; now it seems to be 2nd byte of bracket (if flash is enabled)
km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
scr_set_border equ &bc38

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
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
di

call write_text_init

DI
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&7f00
out (c),c

ld a,&c3
ld hl,nmi_interrupt
ld (&0066),a
ld (&0067),hl

; Intialize Cursor Height
LD   l,7
ld h,%1100000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld hl,&3004
; Program new cursor in the CRTC
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

; Reenable CTC
;; Playcity will hold NMI!?
LD   BC,&F881
;;LD   A,%00110111 ;; does all lines
LD   A,%01100111 ;; much better. only does the lines for the cursor and no others
				;; and does flash
				;; around 6/7 for the int
LD   A,%01110111 ;; TEST!
;;LD   A,%01010111 ;; TEST!
;;LD   A,%01000111 ;; TEST!

				OUT  (C),A
LD   A,2                        ;; 1 doesn't seem to work, 2 works but it's every other line
OUT  (C),A
 
 main_loop:
loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
di


 call readkeys
call do_dir

jp main_loop

do_dir:
ld ix,matrix_buffer
ld a,(ix+9)
xor (ix+9+16)
ret z

ld a,(ix+9)
bit 0,a
call nz,do_down
bit 1,a
call nz,do_up
ret

do_down:
ret

do_up:
ret

update:
ld h,1
ld l,10
call set_char_coords
ld hl,0
or a
ld bc,0
sbc hl,bc
call outputhex16
ret

nmi_interrupt:
push bc
ld bc,&7f4a
out (c),c
ld bc,&7f54
out (c),c
pop bc
retn


include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
include "../../lib/int.asm"
;; hardware based output

include "../../lib/hw/asic.asm"
include "../../lib/hw/readkeys.asm"
include "../../lib/hw/writetext.asm"
include "../../lib/hw/scr.asm"
include "../../lib/hw/printtext.asm"

crtc_data:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
end_crtc_data:

sysfont:
incbin "../../lib/hw/sysfont.bin"



display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test requires the Playcity hardware",13,10
defb "This test uses:",13,10
defb "* Playcity",13,10
defb "* NMI",13,10
defb "* CURSOR",13,10
defb "* Z80 CTC (on Playcity)",13,10,13,10
defb "The test shows the timing of NMI and the CURSOR output",13,10
defb "from the CRTC.",13,10,13,10
defb "Press a key to start",0


end start