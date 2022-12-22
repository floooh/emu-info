;
; ctc1.s
; Framework85
;
; Created by Stefan Koch on 15.11.22.
;

; Initializes ISR and sets and sets the period for CTC1.
;
; The ISR must save and restore all modified registers
; and return with EI and RETI instructions.
;
; HL = Int Handler (ISR)
; A = period
;
CTC1_INIT:

	LD	C,CTC1		; CTC1 -> C

	DI

	LD	E,(IX+IXO_CTC1)	; store current int service routine
	LD	D,(IX+IXO_CTC1+1)
	LD	(_CTC1_OLDINT),DE

	LD	(IX+IXO_CTC1),L	; entry new interrupt routine
	LD	(IX+IXO_CTC1+1),H

	LD	L,CTCF_CONTROL|CTCF_RESET|CTCF_TCONST|CTCF_INT
	OUT	(C),L		; Zeitgeber
	OUT	(C),A		; Period

	IM	2		; Interrupt Modus 2
	EI

	RET

CTC1_CLEANUP:

	LD	A,CTCF_CONTROL|CTCF_RESET
	OUT	(CTC1),A	; CTC1 stoppen

	DI

	LD	HL,(_CTC1_OLDINT)
	LD	(IX+IXO_CTC1),L	; restore original int routine
	LD	(IX+IXO_CTC1+1),H

	EI

	RET

; ---------- static data ----------

_CTC1_OLDINT:
	DEFW	0
