;
;  ctc.i
;  Framework85
;
;  Created by Stefan Koch on 21.02.16.
;
;

; Taken from
;
; Z80 CPU Peripherals
; User Manual
;
; Source: http://z80.info/zip/um0081.pdf

; Bits

CTCB_CONTROL:	EQU	0	; Control or Vector (1: control 0: vector)
CTCB_RESET:	EQU	1	; Reset (1: software reset 0: continue operation)
CTCB_TCONST:	EQU	2	; Time Constant (1: time constant follows 0: no tc follows)
CTCB_TTRIGGER:	EQU	3	; Time Trigger (1: CLK/TRG pulse starts timer 0: automatic trigger when time constant is loaded) TIMER mode only
CTCB_EDGE:	EQU	4	; CLK/TRG Edge Section (1: rising edge 0: falling edge)
CTCB_PRESCALE:	EQU	5	; Prescaler Value (1: 256 0: 16) TIMER mode only
CTCB_COUNTER:	EQU	6	; Mode (1: counter 0: timer)
CTCB_INT:	EQU	7	; Interrupt (1: enable 0: disable)

CTCF_CONTROL:	EQU	1 << CTCB_CONTROL
CTCF_RESET:	EQU	1 << CTCB_RESET
CTCF_TCONST:	EQU	1 << CTCB_TCONST
CTCF_TTRIGGER:	EQU	1 << CTCB_TTRIGGER
CTCF_EDGE:	EQU	1 << CTCB_EDGE
CTCF_PRESCALE:	EQU	1 << CTCB_PRESCALE
CTCF_COUNTER:	EQU	1 << CTCB_COUNTER
CTCF_INT:	EQU	1 << CTCB_INT
