org &4000


;; seems to type 2; cursor non-display happens for the remainder of the display!

;; end half of 2 up to first half of 9
;; every other line for 8 lines
;;
;; end half j up to start q
;; every other 8 lines
;; 
;; ; to b
;; every other
;; 
;; , to 3. starts half way through 3 to last line
;;
;; | to $
;; single line
;;
;; q to x single line

;; O to Z flash ; 8

;; @ to G no flash ;8
;;
;; 1 to 8, odd even flash!?

;; " to ,, 2 lines odd/even flash.

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

ld b,&f5
l2a:
in a,(c)
rra
jr nc,l2a
l2b:
in a,(c)
rra
jr c,l2b


 
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
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------
ld l,7
ld h,%0000000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld hl,&3000
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

LD   BC,&F881
LD   A,%01100111 
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------

ld hl,&3000+(40*3)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------

ld l,7
ld h,%0000001
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld hl,&3000+(40*5)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------

ld l,6
ld h,2
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld hl,&3000+(40*7)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------


ld hl,&3000+(40*9)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld l,1
ld h,3
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------


ld hl,&3000+(40*11)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld l,7
ld h,%0100000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------


ld hl,&3000+(40*15)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld l,7
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

LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------------------------------

ld hl,&3000+(40*17)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


ld l,7
ld h,%0000000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld bc,&bc08
out (c),c
ld bc,&bd00+%01000000
out (c),c


LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay

;;-------------------------------------------------------------------------------------------------------------------------------------------

ld hl,&3000+(40*19)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


ld l,7
ld h,%0000000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


ld bc,&bc08
out (c),c
ld bc,&bd00+%10000000
out (c),c

LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------


ld hl,&3000+(40*21)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


ld l,7
ld h,%0000000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


ld bc,&bc08
out (c),c
ld bc,&bd00+%11000000
out (c),c

LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay
;;-------------------------------------------------------------------------------------------------------------------
ld bc,&bc08
out (c),c
ld bc,&bd00
out (c),c


ld hl,&3000+(40*13)
LD   BC,&bc0e
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L

ld l,7
ld h,%1000000
LD   BC,&bc0a
OUT  (C),C
INC  B
OUT  (C),H
DEC  B
INC  C
OUT  (C),C
INC  B
OUT  (C),L


LD   BC,&F881
LD   A,%01110111
OUT  (C),A
LD   A,2                        
OUT  (C),A
call delay
call delay

ld bc,&7f00+%10011101
out (c),c
ei
jp main_loop

delay:
defs 64*8
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