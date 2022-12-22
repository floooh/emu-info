;
; main.asm
; Sample Replayer (CTC1)
;
; Created by Stefan Koch on 21.12.2022.
; Copyright © 2022 Moods Plateau. All rights reserved.
;

	ORG	200H

; ---------- includes ----------

	INCLUDE "system/caos.i"
	INCLUDE "system/ctc.i"

	INCLUDE "smp/sample.i"

; ---------- switches ----------

SMP_KC854:	EQU	1
SMP_RAM8:	EQU	0

; ---------- constants ----------

SAMPLE_RATE:		EQU	4000	; 4 kHz
PERIOD:			EQU	1770000 / (16 * SAMPLE_RATE)
SAMPLE_COUNT:		EQU	28950 / 2

; ---------- code start ----------

	DEFM	7FH,7FH,"PLAY",1

	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF

	; ----- play sample -----

	LD	A,SMP_MODE_LOOP
	LD	(SMP_MODE),A

	LD	HL,SAMPLE
	LD	BC,SAMPLE_COUNT
	LD	A,PERIOD
	CALL	SMP_PLAY

	POP	AF
	POP	BC
	POP	DE
	POP	HL

	RET

	DEFM	7FH,7FH,"STOP",1

	PUSH	HL
	PUSH	AF

	CALL	SMP_STOP

	POP	AF
	POP	HL

	RET

; ---------- external code ----------

	INCLUDE "smp/ctc1.s"
	INCLUDE "smp/sample_ctc1.s"

; ---------- static data ----------

SAMPLE:
	INCBIN	"tsong2.packed"

RESTART:
	DEFB	0
