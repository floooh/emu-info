;
; ctc2.s
; Framework85
;
; Created by Stefan Koch on 17.10.21.
;

; Initializes ISR and sets and sets the period for CTC2.
;
; The ISR must save and restore all modified registers
; and return with EI and RETI instructions.
;
; HL = Int Handler (ISR)
; A = period
;
CTC2_INIT:

	LD	C,CTC2		; CTC2 -> C

	DI

	LD	E,(IX+IXO_CTC2)	; store current int service routine
	LD	D,(IX+IXO_CTC2+1)
	LD	(_CTC2_OLDINT),DE

	LD	(IX+IXO_CTC2),L	; entry new interrupt routine
	LD	(IX+IXO_CTC2+1),H

	LD	L,CTCF_CONTROL|CTCF_RESET|CTCF_TCONST|CTCF_INT
	OUT	(C),L		; Zeitgeber
	OUT	(C),A		; Period

	IM	2		; Interrupt Modus 2
	EI

	RET

CTC2_CLEANUP:

	LD	A,CTCF_CONTROL|CTCF_RESET
	OUT	(CTC2),A	; CTC2 stoppen

	DI

	LD	HL,(_CTC2_OLDINT)
	LD	(IX+IXO_CTC2),L	; restore original int routine
	LD	(IX+IXO_CTC2+1),H

	EI

	RET

; ---------- static data ----------

_CTC2_OLDINT:
	DEFW	0

