;
; main.asm
; Sample Replayer
;
; Created by Stefan Koch on 05.11.2022.
; Copyright © 2020 Moods Plateau. All rights reserved.
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

SAMPLE_RATE:		EQU	8000	; 8 kHz
PERIOD:			EQU	1770000 / (16 * SAMPLE_RATE)
SAMPLE_COUNT:		EQU	28950

; ---------- code start ----------

	DEFM	7FH,7FH,"PLAY",1

	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF

	; check for restart
	LD	A,(RESTART)
	AND	A
	JP	NZ,.SKIP_CONVERT

	; ----- convert sample -----

	; convert 8 bit signed to 5 bit unsigned
	LD	HL,SAMPLE
	LD	D,H
	LD	E,L
	LD	BC,SAMPLE_COUNT

.CONV_LOOP:
	LD	A,(HL)
	ADD	128	; signed to unsigned
	RRA
	RRA
	RRA
	AND	1FH	; 8 to 5 bit
	LD	(HL),A
	LDI
	JP	PE,.CONV_LOOP

	LD	A,1
	LD	(RESTART),A

.SKIP_CONVERT:

	; ----- play sample -----

	CALL	SMP5_INIT

	LD	A,SMP_MODE_LOOP
	LD	(SMP5_MODE),A

	LD	HL,SAMPLE
	LD	BC,SAMPLE_COUNT
	LD	A,PERIOD
	CALL	SMP5_PLAY

	POP	AF
	POP	BC
	POP	DE
	POP	HL

	RET

	DEFM	7FH,7FH,"STOP",1

	PUSH	HL
	PUSH	AF

	CALL	SMP5_STOP

	POP	AF
	POP	HL

	RET

; ---------- external code ----------

	INCLUDE "smp/ctc2.s"
	INCLUDE "smp/sample5.s"

; ---------- static data ----------

SAMPLE:
	INCBIN	"tsong2"

RESTART:
	DEFB	0
