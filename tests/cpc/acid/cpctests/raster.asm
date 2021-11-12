;; I did not use CPCPlus equ 1

;; MODE 2 results

;; GX4000: 
;; white, pastel yellow,bright white, bright yellow, bright red, blue, green, sea green
;; border is pastel yellow.
;; Text is  !"#$% etc
;; Grey extends up to but not including last pixel of "(" (i.e. there are two dots which are the final
;; pixel graphics of the bracket.). The dots are pastel yellow.and are a single mode 2 pixel in size.
;; 
;; 464 Plus: same as GX4000
;; 
;; 6128 type 2 CRTC. believed 40010. Edge connectors
;;  border shifted compared to Plus. by 1 CRTC char
;;  grey split not so obvious, bright yellow split shows two dots from first pixel of E. Remainder of E is bright red.
;;
;; 6128 type 1 CRTC. believed 40010. Has German connectors.
;; Seems same as type 2, but less obvious probably because of ghosting on my monitor.
;;
;; 6128 type 0 CRTC. believed 40010. Edge connectors
;; same as type 2.
;;
;; 464 type 0:
;; same as 6128
;;
;; 464 type 4:
;; border same as plus.  split is perfect to us. No odd pixels
;; 
;; MODE 1 results:

;; GX4000
;; split is start of $ symbol. First mode 1 pixels of the graphics are grey, rest
;; is pastel yellow
;; red to blue happens ~2 mode 1 pixels into the 8
;;
;; yellow to red happens 2 pixels into the 3

;; 6128 type 2 CRTC
;; same as type 0

;; 6128 type 1 CRTC.
;; same as type 0, 2 seems to be 3 mode 1 pixels in. (strangely with my dodgy screen
;; this is the only one where there is flicker at the grey and pale yellow transition and 
;; bright green and pastel green. No idea why).
;; 
;; 6128 type 0 CRTC.
;; grey split mid #, bright yellow split mid 2, bright white split mid -.
;; 
;; 464 type 0, 40007???
;; same as 6128.
;;
;; 464 type 4:
;; grey split mid $, just before vertical of $, split middle of 3
;;
;; kc compact:
;; border same as plus and type 4.
;; split mid #, 2nd vertical of #. yellow to red mid 2. yellow to white, last pixel of ( is grey
;;

;-----------------------------------------
;    JavaCPC RasterPaint Assembly code
; Authors: Oliver M. Lenz, Markus Hohmann
;-----------------------------------------

org &8000  ; CALL &8000
       OldCPC EQU 0 ; Set this to 0 for CPC Plus / Newer CPC Models.


start:
ld a,2 ;; MODE 2!
call &bc0e

;;ld a,1 ;; MODE 1!
;;call &bc0e

ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),&ff
;;ld (hl),%11110000
ld bc,&3fff
ldir

ld b,80
;;ld b,40
ld a,' '
s1:
push bc
push af
call &bb5a
pop af
inc a
cp 127
jr nz,s2
ld a,' '
s2:
pop bc
djnz s1

di
im    1
ei
ld bc,&7f10
out (c),c
ld bc,&7f43
out (c),c

    newframe:
ld    HL,(&0038)
ld    (rstsave),HL
ld    HL,&C9FB
ld    (&0038),HL

ld     B,&F5
waitvsync:
in    A,(C)
rra
jp    nc,waitvsync


halt
halt

di
ld    DE,&1702
waitforstart:
dec    D
jr    nz,waitforstart
dec    E
jr    nz,waitforstart

   nop
        IF        OldCPC
        nop
        ENDIF

     ld        BC,&8080
        out        (C),C  ; select pen 1
        ld        HL,colours
        ld        DE,&0203
        ld        A,&01


.nextline
rept 200
outi            ; 5
outi            ; 5
outi            ; 5
outi            ; 5
outi            ; 5
outi            ; 5
outi            ; 5
outi            ; 5
            ; 40

        out        (C),D  ; 4 ; pen 2
        ld        B,C  ; 1
        outi        ; 5
        out        (C),E  ; 4 ; pen 3
        outi        ; 5
        out        (C),A  ; 4 ; pen 1
        ld        B,C  ; 1
        ;        --
        ;        64 microseconds
endm

ld    HL,(rstsave)
ld    (&0038),HL
ei

LD A,&45 ; from &40 to &49 with bdir/bc1=01
LD D,0
LD BC,&F782 ; PPI port A out /C out
OUT (C),C
LD BC,&F40E ; Select Ay reg 14 on ppi port A
OUT (C),C
LD BC,&F6C0 ; This value is an AY index (R14)
OUT (C),C
OUT (C),D ; Validate!! out (c),0
LD BC,&F792 ; PPI port A in/C out
OUT (C),C
DEC B
OUT (C),A ; Send KbdLine on reg 14 AY through ppi port A
LD B,&F4 ; Read ppi port A
IN A,(C) ; e.g. AY R14 (AY port A)
LD BC,&F782 ; PPI port A out / C out
OUT (C),C
DEC B ; Reset PPI Write
OUT (C),D ; out (c),0
bit 7,A
jp    nz,newframe
ret

rstsave:
db      0,0

colours:
rept 200
defb &40,&43,&4b,&4a,&4c,&50,&52,&59,&5a,&48
endm

end start