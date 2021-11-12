;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This program will show all 27 CPC colours on the screen
;; in bars of 8 pixels tall. The colours are in the main window.
;; The colours in the border show where the colour changes occur.

org &4000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

;; set to mode 1, clear screen and reset CRTC base
ld a,1
call scr_set_mode

ld bc,&bc06
out (c),c
ld bc,&bd00+34
out (c),c

ld bc,&bc07
out (c),c
ld bc,&bd00+33
out (c),c

di
ld hl,&c9fb
ld (&0038),hl
ei

ff:
ld b,&f5
ff2:
in a,(c)
rra
jr nc,ff2
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c

halt
di				;; [1]
ld hl,colours	;; [3]   colour table
ld d,&0			;; [2]	 pen 0
ld e,&10		;; [2]	 border
				
rept 32
ld b,&7f		;; [2]
out (c),d		;; [4] select pen
outi			;; [5] pen colour
inc b			;; [1]
out (c),e		;; [4] select border
outi			;; [5] border colour
				;; = [21]

				;; 64-21 = 43 NOPs to end of line

;; Want to delay for 8 lines.
;; 8*64 = 512
;; 512-43 = 469 NOPs
				
;; calculation for delay:
;; 469/4 = 117.25
;; 117*4 = 468 which doesn't allow for ld b,170 and final repetition of loop
;; 116*4 = 464 leaving 5 which is enough for ld b,170 and final iteration of loop
ld b,116	;; [2]
_loop DEFL $
djnz _loop		;; [4]*116 + [3]*1
endm
ld bc,&7f00
out (c),c
ld bc,&7f40
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f40
out (c),c
ei

jp ff

colours:
defb &40		
defb &4b		

defb &41		
defb &54		

defb &42		
defb &4b		

defb &43
defb &54		

defb &44
defb &4b		

defb &45
defb &54		

defb &46
defb &4b		

defb &47
defb &54		

defb &48
defb &4b		

defb &49
defb &54		

defb &4a
defb &4b		

defb &4b
defb &54		

defb &4c
defb &4b		

defb &4d
defb &54		

defb &4e
defb &4b		

defb &4f
defb &54		

defb &50
defb &4b		

defb &51
defb &54		

defb &52
defb &4b		

defb &53
defb &54		

defb &54
defb &4b		

defb &55
defb &54

defb &56
defb &4b		

defb &57
defb &54		

defb &58
defb &4b		

defb &59
defb &54		

defb &5a
defb &4b		

defb &5b
defb &54		

defb &5c
defb &4b		

defb &5d
defb &54		

defb &5e
defb &4b		

defb &5f
defb &54		
 

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This test shows all of the CPC hardware colours from 0-&1f by",13,10
defb "re-programming pen 0.",13,10,13,10
defb "Uses 'palette memory' (bit 7=0, bit 6=1 port 7fxx)",13,10,13,10
defb "This test must be checked on a colour monitor to ensure the colours.",13,10
defb "are correct",13,10,13,10
defb "The border changes between black and white to show where the colour",13,10
defb "change have been made.",13,10,13,10
defb "The first colour (hw colour 0) starts at the first white bar in the border",13,10
defb "and you should see all 32 hardware colours.",13,10,13,10
defb "Press a key to start",0

end start