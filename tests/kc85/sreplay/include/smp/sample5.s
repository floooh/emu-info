;
; sample5.s
; SamplePlayer
;
; Created by Stefan Koch on 12.10.18.
; Copyright (c) 2018 Moods Plateau. All rights reserved.
;

; Fast 5 bit sample replay by CTC channel 2 (bytewise)
; (still experimental)

; define SMP_KC854 (0 or 1) for targeting KC 85/4 or KC 85/2-3
; define SMP_RAM8 (0 or 1) for playing from RAM8 or not

; SMP5_PLAYING indicates if the sample player is still playing (0 or 1).

; Initialize flip-flops D023A and D023B
;
SMP5_INIT:

	; set volume to zero
	IN	A,(PIOB)
	OR	VOL_MSK
	OUT	(PIOB),A

	; reset flip-flop symmetry
	IN	A,(PIOB)
	AND	~1
	OUT	(PIOB),A
	OR	1
	OUT	(PIOB),A

	; set audio channels to high level
	LD	C,CTC0
	LD	A,10
	LD	L,CTCF_CONTROL|CTCF_RESET|CTCF_TCONST
	OUT	(C),L	; Zeitgeber
	OUT	(C),A	; Period

	LD	C,CTC1
	LD	A,10
	LD	L,CTCF_CONTROL|CTCF_RESET|CTCF_TCONST
	OUT	(C),L	; Zeitgeber
	OUT	(C),A	; Period

	XOR	A
	LD	(_SMP5_SYNC),A

	LD	HL,_SMP5_ISR_SYNC
	LD	A,15
	CALL	CTC2_INIT

.SMP5_SYNC_LOOP:

	LD	A,(_SMP5_SYNC)
	AND	A
	JP	Z,.SMP5_SYNC_LOOP

	LD	A,CTCF_CONTROL|CTCF_RESET
	OUT	(CTC0),A	; CTC0 stoppen

	LD	A,CTCF_CONTROL|CTCF_RESET
	OUT	(CTC1),A	; CTC1 stoppen

	CALL	CTC2_CLEANUP	; CTC2 stoppen

	RET

; Play sample
;
; HL = sample
; BC = length (sample count)
; A = period (14 = 8 kHz)
;
; SMP5_MODE = SMP_MODE_LOOP | SMP_MODE_WAIT
;
SMP5_PLAY:

	LD	(_SMP5_START),HL
	LD	(_SMP5_LEN),BC

	; store params
	EXX

	; init ctc
	LD	HL,_SMP5_ISR
	CALL	CTC2_INIT	; play may not be called consecutively

	; state playing
	LD	A,1
	LD	(SMP5_PLAYING),A

	; check for wait mode
	LD	A,(SMP5_MODE)
	AND	SMP_MODE_WAIT
	RET	Z

	; wait for sample end
.SMP5_LOOP:
	DI
	EXX
	LD	A,C
	OR	B
	EXX
	EI
	JR	NZ,.SMP5_LOOP

; Stop playing sample
;
SMP5_STOP:

	; cleanup ctc
	CALL	CTC2_CLEANUP

	; state not playing
	XOR	A
	LD	(SMP5_PLAYING),A

	RET

	; ---------- ISR ----------

_SMP5_ISR:

	DI

	EXX
	EX	AF,AF'

	; check for end
	LD	A,C
	OR	B
	JR	Z,_SMP5_ISR_CHK_LOOP

.SMP5_ISR_PLAY:

	; disable irm for playing from RAM8
	IF SMP_RAM8 != 0

	; enable RAM8
	IN	A,(PIOA)
	PUSH	AF
	AND	~(1<<IRM)
	OUT	(PIOA),A

	ENDIF

	; set volume
	IN	A,(PIOB)

	IF SMP_KC854 == 0
	AND	~VOL_MSK	; Bereich auf Null setzen
	ELSE
	AND	~VOL_MSK4	; ohne sym. Reset
	ENDIF

	OR	(HL)		; neuen Wert setzen
	OUT	(PIOB),A	; Ltst. ausgeben

	; advance pointer
	INC	HL

	; count down
	DEC	BC

	; restore irm
	IF SMP_RAM8 != 0

	POP	AF
	OUT	(PIOA),A

	ENDIF

.SMP5_ISR_EXIT:

	EX	AF,AF'
	EXX

	EI

	RETI

_SMP5_ISR_STOP:

	CALL	SMP5_STOP	; call from ISR?

	JP	.SMP5_ISR_EXIT

_SMP5_ISR_CHK_LOOP:

	LD	A,(SMP5_MODE)
	AND	SMP_MODE_LOOP
	JP	Z,_SMP5_ISR_STOP

	; setup next cycle

	LD	HL,(_SMP5_START)
	LD	BC,(_SMP5_LEN)

	JP	.SMP5_ISR_PLAY

	; ----- sync ISR -----

_SMP5_ISR_SYNC:

	DI

	PUSH	AF

	LD	A,1
	LD	(_SMP5_SYNC),A

	POP	AF

	EI

	RETI

	; ---------- static data ----------

SMP5_MODE:
	DEFB	0

SMP5_PLAYING:
	DEFB	0

_SMP5_START:
	DEFW	0

_SMP5_LEN:
	DEFW	0

_SMP5_SYNC:
	DEFB	0
