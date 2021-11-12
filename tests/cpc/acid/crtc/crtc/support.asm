;; General support code 

.txt_output	equ	&bb5a

;;-------------------------------------------------------------
;; after this is called and you wait for vsync to become active
;; you will find the start

.vsync_sync
	ld b,&f5
.vs1
	in a,(c)
	rra
	jr nc,vs1

.vs2
	in a,(c)
	rra
	jr c,vs2

	ret


;;-------------------------------------------------------------
;; store interrupt vector

.int_store
	di
	push hl
	push de
	push bc
	ld hl,&0038
	ld de,im1_vector_store
	ld bc,&3
	ldir
	pop bc
	pop de
	pop hl
	ei
	ret

;;-------------------------------------------------------------
;; restore interrupt vector

.int_restore
	di
	push hl
	push de
	push bc
	ld hl,im1_vector_store
	ld de,&0038
	ld bc,3
	ldir
	pop bc
	pop de
	pop hl
	ei
	ret

;;-------------------------------------------------------------
;; show a null terminated string

.show_string
	ld a,(hl)
	or a
	ret z
	call txt_output
	jr show_string

;;-------------------------------------------------------------
;; show a word on the screen

.show_word
	push hl

	ld a,"#"
	call txt_output

	ld a,h
	call show_byte_digits
	ld a,l
	call show_byte_digits

	pop hl
	ret

;;------------------------------------------------------------
;; show a byte on the screen

.show_byte
	push af

	push af	
	ld a,"#"
	call txt_output
	pop af

	call show_byte_digits

	pop af
	ret

;;------------------------------------------------------------
;; show byte digits

.show_byte_digits
	push af
	push af
	srl a
	srl a
	srl a
	srl a
	call show_nibble
	pop af
	call show_nibble
	pop af
	ret

.show_nibble
	and &f
	add a,"0"
	cp "9"+1
	jr c,digit
	add a,"A"-"9"+1
.digit
	call txt_output
	ret
		

;;------------------------------------------------------------
;; print CR,LF

.crlf
	ld a,10
	call txt_output
	ld a,13
	call txt_output
	ret

;;------------------------------------------------------------

.show_char
	call txt_output
	ret


;;------------------------------------------------------------


.scankeyboard
	ld hl,keyboardbuffer
	ld de,oldkeyboardbuffer
	ld bc,16
	ldir

        ld      hl,keyboardbuffer

        ld      bc,&F782
        out     (c),c                   ;make 8255 port A=output
        ld      bc,&F40E
        out     (c),c                   ;selecting AY register 14
        ld      b,&F6                  ;8255 port C has BDIR/BC1 bits
        in      a,(c)                   ;read current state
        or      &C0                    ;set BDIR BC1 = 11 (select addr)
        out     (c),a                   ;latch 14 into AY addr select reg
        and     &3F                    ;reset top two bits (BDIR,BC1 = 00)
        out     (c),a                   ;make AY inactive again
        ld      bc,&F792
        out     (c),c                   ;make 8255 port A=input

        ld      d,9                     ;testing 10 rows (9, 8, ... 0)
ReadRow:
        ld      b,&F6
        in      a,(c)                   ;get state of 8255 port C
        and     &F0                    ;clear bottom 4 row select bits
        or      d                       ;replace them with value in D
        out     (c),a                   ;SELECT A ROW
        and     &3F
        or      &40                    ;make BDIR BC1 = 01 (read from AY)

        ld      b,&F6                  ;port C
        out     (c),a                   ;read from AY reg 14 to port A

        ld      b,&F4                  ;8255 port A now has column values
        in      a,(c)                   ;READ THE COLUMNS
        ld      (hl),a                  ;store byte in buffer
        inc     hl
        dec     d                       ;next keyboard row
        jp      p,ReadRow			;keep doing rows till we go thru 0
	
	ret

;;----------------------------------------------------------

.space_pressed
	push ix
	;; is it being held?
	ld ix,keyboardbuffer
	bit 7,(ix+5)
	jr nz,sp1

	;; not held

	;; was it held last scan?
	bit 7,(ix+5+16)
	jr z,sp1

	;; it is released on this scan,
	;; but previously it was pressed.
	pop ix
	scf
	ret


.sp1
	pop ix
	or a
	ret

;;-------------------------------------------------------

.test_complete
	ld hl,testcomp
	call show_string
	call &bb06
	ret

;;-------------------------------------------------------

.testcomp
	defb "Test complete. Press space for next test",0

.keyboardbuffer
	defs 16
.oldkeyboardbuffer
	defs	16

.im1_vector_store
	defs 3
8255 port A now has column values
      