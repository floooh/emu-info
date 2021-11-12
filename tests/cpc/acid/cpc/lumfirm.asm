;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; this test sets cpc colours and must be viewed on gt64/gt65/mm14 because 
;; it displays the luminance output from the cpc.
;;
;; works on cpc, plus and aleste.

org &8000

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
pen_swap equ &54 xor &4B

;; set colour with bit 5 set
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
defb &54		;; black
defb &4b		

defb &44		;; blue
defb &54		

defb &50		;; blue
defb &4b

defb &55		;; bright blue
defb &54		

defb &5c		;; red
defb &4b		

defb &58		;; magenta
defb &54		

defb &5d		;; mauve
defb &4b		

defb &4c		;; bright red
defb &54		

defb &45		;; purple
defb &4b		

defb &48		;; purple
defb &54		

defb &4d		;; bright magenta
defb &4b		

defb &56		;; green
defb &54		

defb &46		;; cyan
defb &4b		

defb &57		;; sky blue
defb &54		

defb &5e		;; yellow
defb &4b		

defb &40		;; white
defb &54		

defb &41	;; white
defb &4b

defb &5f	;; pastel blue
defb &54		

defb &4e		;; orange
defb &4b		

defb &47		;; pink
defb &54		

defb &4f		;; pastel magenta
defb &4b		

defb &52		;; bright green
defb &54		

defb &42		;; sea green
defb &4b		

defb &51		;; sea green
defb &54		

defb &53		;; bright cyan
defb &4b		

defb &5a		;; lime
defb &54

defb &59		;; pastel green
defb &4b		

defb &5b		;; pastel cyan
defb &54		

defb &4a		;; bright yellow
defb &4b		

defb &43		;; pastel yellow
defb &54		

defb &49		;; pastel yellow
defb &4b

defb &4b		;; bright white
defb &54		

defb &40
defb &4b

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


message:
defb "This is a visual test.",13,10,13,10
defb "This test should be run on a GT64/GT65 monochrome monitor and shows",13,10
defb "how the brightness changes when the colour is changed using the",13,10
defb "firmware palette memory register (bit 7=0, bit 6=1, port 7fxx).",13,10,13,10
defb "On a monochrome monitor the brightness will increase down the screen.",13,10,13,10
defb "This test does the same on CPC and Plus.",13,10,13,10
defb "Press a key to start",'$'

end start
