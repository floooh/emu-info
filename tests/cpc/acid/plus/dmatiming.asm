;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

org &8000

;; NOTE: Int delayed in these tests to see on-screen
;;
;; TODO: 
;; - timing when CPU is writing to AY at the same time
;; need to see the delay
;; - confirm opcode fetch happens only for enabled 
;; channels
;; - confirm interrupt after interrupt (do not delay)
;; - confirmed cycle timing for pause
;; - confirmed cycle timing for repeat and loop instructions
;; positions:
;; ( -> chan 0 only (int+stop)
;; ( -> chan 1 only (int+stop)
;; ( -> chan 2 only (int+stop)
;; 1 -> chan 0 ay, chan 1 int+stop, chan 2 not used
;; 2 -> chan 0 not used, chan 1 ay, chan 2 int+stop
;; : -> chan 0 ay, chan 1 ay, chan 2 int+stop
;; 3 -> chan 0 stop, channel 1 ay, channel 2 int+stop
;; ) -> chan 0 int+stop, channel 1 ay, chan 2 int+stop
;; + -> chan 0 nop, chan 1 int+stop
;; ) -> chan 0 not used, chan 1 nop, chan 2 int+stop
;; + -> chan 0 nop, chan 1 nop, chan 2 int+stop
;; ) -> chan 0 int, chan 1 nop, chan 2 nop
;; + -> chan 0 int, chan 1 int, chan 2 nop
;; , -> chan 0 int, chan 1 int, chan 2 int



scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,26
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1
if 0
ld bc,&bc01
out (c),c
ld bc,&bd00+&7f
out (c),c
ld bc,&bc02
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc00
out (c),c
ld bc,&bd00+31
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+77
out (c),c
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc06
out (c),c
ld bc,&bd00+70
out (c),c
ld bc,&bc03
out (c),c
ld bc,&bd06
out (c),c
endif
di
ld a,&c3
ld hl,dma_int
ld (&0038),a
ld (&0039),hl
ei

ld bc,&bc01
out (c),c
ld bc,&bd00+64
out (c),c


call asic_enable
ld bc,&7fb8
out (c),c

loop:
ld a,1
ld (&6800),a
halt
ld a,2
ld (colour),a
;; single channel show that int position should be the
;; same for all and channels are packed together

;; channel 0 active only
ld a,%1
call single_channel
call wait_dma_done
ld a,6
ld (&6800),a
halt
ld a,2
ld (colour),a

;; channel 1 active only
ld a,%10
call single_channel
call wait_dma_done

ld a,11
ld (&6800),a
halt
ld a,2
ld (colour),a

;; channel 2 active only
ld a,%100
call single_channel
call wait_dma_done

;; writing to ay should show longer timing for ay 
;; writes and to show they are done in sequence
;; and that they are packed together

ld a,16
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_0_ay
call wait_dma_done

ld a,21
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_1_ay
call wait_dma_done

ld a,26
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_01_ay
call wait_dma_done

ld a,31
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_x1x_ay
call wait_dma_done


ld a,36
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_x1xb_ay
call wait_dma_done


;; should show nop is 1 cycle long

ld a,41
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_0_nop
call wait_dma_done

ld a,46
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_1_nop
call wait_dma_done

ld a,51
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_01_nop
call wait_dma_done

;; shows all ints together
ld a,56
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_0_int
call wait_dma_done

ld a,61
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_01_int
call wait_dma_done

ld a,66
ld (&6800),a
halt
ld a,2
ld (colour),a

call chan_012_int
call wait_dma_done

jp loop

single_channel:
push af
ld hl,&4030
ld (&1000),hl

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a
pop af
ld (&6c0f),a
ret

;; chan 0 write to ay, channel 1 int, channel 2 not active
chan_0_ay:
ld hl,&0080
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&1000
ld (&6c00),hl
ld hl,&2000
ld (&6c04),hl
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%011
ld (&6c0f),a
ret

;; chan 1 write to ay, channel 2 int, channel 0 not active
chan_1_ay:
ld hl,&0080
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&2000
ld (&6c00),hl
ld hl,&1000
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%110
ld (&6c0f),a
ret

;; chan 0 and 1 write to ay, channel 2 int
chan_01_ay:
ld hl,&0080
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret

;; chan 0 stop, channel 1 ay, channel 2 stop and int
chan_x1x_ay:
ld hl,&0080
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&4020
ld (&3000),hl

ld hl,&3000
ld (&6c00),hl
ld hl,&1000
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret

;; chan 0 stop and int, channel 1 ay, channel 2 stop and int
chan_x1xb_ay:
ld hl,&0080
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&2000
ld (&6c00),hl
ld hl,&1000
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret



;; chan 0 nop, channel 1 int, channel 2 not active
chan_0_nop:
ld hl,&4000
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&1000
ld (&6c00),hl
ld hl,&2000
ld (&6c04),hl
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%011
ld (&6c0f),a
ret

;; chan 1 nop, channel 2 int, channel 0 not active
chan_1_nop:
ld hl,&4000
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&2000
ld (&6c00),hl
ld hl,&1000
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%110
ld (&6c0f),a
ret

;; chan 0 and 1 nop, channel 2 int
chan_01_nop:
ld hl,&4000
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&1000
ld (&6c00),hl
ld (&6c04),hl
ld hl,&2000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret

;; chan 0 int, and others nop
chan_0_int:
ld hl,&4000
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&2000
ld (&6c00),hl
ld hl,&1000
ld (&6c04),hl
ld hl,&1000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret

;; chan 0 int, chan 1 int and  others nop
chan_01_int:
ld hl,&4000
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&2000
ld (&6c00),hl
ld (&6c04),hl
ld hl,&1000
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret

;; chan 0 int, chan 1 int, chan 2 int and  others nop
chan_012_int:
ld hl,&4000
ld (&1000),hl
ld hl,&4020
ld (&1002),hl

ld hl,&4030
ld (&2000),hl

ld hl,&2000
ld (&6c00),hl
ld (&6c04),hl
ld (&6c08),hl

xor a
ld (&6c02),a
ld (&6c06),a
ld (&6c0a),a

ld a,%01110000
ld (&6c0f),a

ld a,%111
ld (&6c0f),a
ret



dma_int:
push af
push bc
ld a,(&6c0f)
ld c,a
and %01110000
jr z,dma_int2
ld a,c
ld (&6c0f),a
defs 32
ld bc,&7f00
out (c),c
ld a,(colour)
inc a
ld (colour),a
and &1f
or &40
out (c),a
ld bc,&7f54
out (c),c
dma_int2:
pop bc
pop af
ei
reti

wait_dma_done:
ld a,(&6c0f)
and %111
jr nz,wait_dma_done
ret


colour:
defb 2

asic_enable:

	push af
	push hl
	push bc
	push de
 	ld hl,asic_sequence
	ld bc,&bc00
	ld d,17

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	pop de
	pop bc
	pop hl
	pop af	
	ret
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee


end start
