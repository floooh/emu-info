;
; sample.s
; SamplePlayer
;
; Created by Stefan Koch on 21.08.18.
; Copyright (c) 2018 Moods Plateau. All rights reserved.
;

; Do not use this routine, rather use CTC channel 3 for generating
; the interrupt.

; define SMP_RAM8 (0 or 1) for playing from RAM8 or not

; SMP_PLAYING indicates if the sample player is still playing (0,1).

; Add A to 16 bit register
;
; https://wikiti.brandonw.net/index.php?title=Z80_Routines:Optimized:addAtoHL
;
ADD16:	MACRO hi lo	; 20 cycles
	ADD	lo
	LD	lo,A
	JR	NC,$+3
	INC	hi
	ENDM

; Play sample
;
; HL = sample
; BC = length (sample count)
; A = period (14 = 8 kHz, 224 cycles, phase offset 4)
;
; SMP_MODE = SMP_MODE_LOOP | SMP_MODE_WAIT
;
SMP_PLAY:

	; store params
	LD	(_SMP_START),HL
	LD	(_SMP_LEN),BC
	LD	(_SMP_PTR),HL
	LD	(_SMP_REMAINING),BC
	LD	(_SMP_PERIOD),A

	; reset phase shift
	XOR	A
	LD	(_SMP_PHASE_SHIFT),A

	; check for phase offset arg
	LD	A,(ARGN)
	CP	2
	JR	C,.SMP_NO_ARG_OFFSET

	; read offset argument
	LD	A,(ARG2)
	LD	B,A

	JR	.SMP_ARG_OFFSET_END

.SMP_NO_ARG_OFFSET:

	; check period range
	LD	A,(_SMP_PERIOD)
	SUB	12	; table start offset
	CP	_SMP_PHASE_OFFSET_END-_SMP_PHASE_OFFSET
	JR	NC,.SMP_NO_PHASE_SHIFT1

	; lookup phase offset
	LD	HL,_SMP_PHASE_OFFSET
	ADD16	H L
	LD	B,(HL)

.SMP_ARG_OFFSET_END:

	; check phase offset for zero
	LD	A,B
	AND	A
	JR	Z,.SMP_NO_PHASE_SHIFT1

	; state phase shift
	LD	A,1
	LD	(_SMP_PHASE_SHIFT),A

	; reset symmetrie flip-flops
	IN	A,(PIOB)
	OR	1
	OUT	(PIOB),A

	; start CTC0 with 180° phase shift
	LD	A,(_SMP_PERIOD)
	LD	L,CTCF_CONTROL|CTCF_RESET|CTCF_TCONST
	LD	C,CTC0
	OUT	(C),L
	OUT	(C),A

	; wait half period
.SMP_WAIT_LOOP:
	DJNZ	.SMP_WAIT_LOOP	; 13/8

.SMP_NO_PHASE_SHIFT1:

	; init ctc
	LD	HL,_SMP_ISR
	CALL	CTC1_INIT

	; state playing
	LD	A,1
	LD	(SMP_PLAYING),A

	; check for wait mode
	LD	A,(SMP_MODE)
	AND	SMP_MODE_WAIT
	RET	Z

	; wait for sample end
.SMP_LOOP:
	LD	BC,(_SMP_REMAINING)
	LD	A,C
	OR	B
	JR	NZ,.SMP_LOOP

; Stop playing sample
;
SMP_STOP:

	; cleanup CTC1
	CALL	CTC1_CLEANUP

	; check phase option
	LD	A,(_SMP_PHASE_SHIFT)
	AND	A
	JR	Z,.SMP_NO_PHASE_SHIFT2

	; stop CTC0
	LD	A,CTCF_CONTROL|CTCF_RESET
	OUT	(CTC0),A

.SMP_NO_PHASE_SHIFT2:

	; state not playing
	XOR	A
	LD	(SMP_PLAYING),A

	RET

	; ---------- ISR ----------

_SMP_ISR:

	DI

	PUSH	HL
	PUSH	BC
	PUSH	AF

	; check for end
	LD	BC,(_SMP_REMAINING)
	LD	A,C
	OR	B
	JP	Z,_SMP_ISR_CHK_LOOP

.SMP_ISR_PLAY:

	; disable irm for playing from RAM8
	IF SMP_RAM8 != 0
	; enable RAM8
	IN	A,(PIOA)
	PUSH	AF
	AND	~(1<<IRM)
	OUT	(PIOA),A
	ENDIF

	; count down
	DEC	BC
	LD	(_SMP_REMAINING),BC

	; read data
	LD	HL,(_SMP_PTR)
	LD	A,(HL)

	; even?
	BIT	0,C
	JP	NZ,.SMP_SKIP_ADVANCE

	; adapt value range
	ADD	A	; 0..31

	; advance pointer
	INC	HL
	LD	(_SMP_PTR),HL

	JP	.SMP_ISR_CONT

.SMP_SKIP_ADVANCE:

	RRA	; optimizable with RRD?
	RRA
	RRA

.SMP_ISR_CONT:

	; ensure range
	AND	1EH

	; set volume
	LD	C,A
	IN	A,(PIOB)
	AND	0E1H	; Bereich auf Null setzen
	OR	C	; neuen Wert setzen
	OUT	(PIOB),A;Ltst. ausgeben, ggf. sym. reset

	; restore irm
	IF SMP_RAM8 != 0
	POP	AF
	OUT	(PIOA),A
	ENDIF

.SMP_ISR_EXIT:

	POP	AF
	POP	BC
	POP	HL

	EI

	RETI

_SMP_ISR_STOP:

	CALL	SMP_STOP

	JP	.SMP_ISR_EXIT

_SMP_ISR_CHK_LOOP:

	LD	A,(SMP_MODE)
	AND	SMP_MODE_LOOP
	JP	Z,_SMP_ISR_STOP

	; setup next cycle

	LD	HL,(_SMP_START)
	LD	(_SMP_PTR),HL
	LD	BC,(_SMP_LEN)
	LD	(_SMP_REMAINING),BC

	JP	.SMP_ISR_PLAY

	; ---------- static data ----------

SMP_MODE:
	DEFB	0

SMP_PLAYING:
	DEFB	0

_SMP_START:
	DEFW	0

_SMP_LEN:
	DEFW	0

_SMP_PTR:
	DEFW	0

_SMP_REMAINING:
	DEFW	0

_SMP_PERIOD:
	DEFB	0

_SMP_PHASE_SHIFT:
	DEFB	0

_SMP_PHASE_OFFSET:
	DEFB	1	; 12 / 0CH
	DEFB	3	; 13 / 0DH
	DEFB	4	; 14 / 0EH
	DEFB	5	; 15 / 0FH
	DEFB	8	; 16 / 10H
	DEFB	10	; 17 / 11H
_SMP_PHASE_OFFSET_END:

; 30 / 1EH = 17 / 11H
