;;=====================
;; Spectrum +3 specific
;;=====================


;;-----------------------------------------------
;; start drive motor and wait for it to be rotating
;; at full speed

start_drive_motor:
call disc_motor_on
jp wait_drive_motor

stop_drive_motor:
call disc_motor_off
jp wait_drive_motor

wait_drive_motor:
;; wait for drive motor to be rotating at full speed 
ld b,3
pause1:
ld hl,0
pause2:
dec hl
ld a,h
or l
jr nz,pause2
djnz pause1
ret

;;-----------------------------------------------


fdc_read_main_status_register:
ld bc,&2ffd
in a,(c)
ret

fdc_read_data_register:
ld bc,&3ffd
in a,(c)
ret


;;-----------------------------------------------
;; stop drive motor
disc_motor_on:
ld a,(&5b67)
or %1000					;; bit 3 is motor state
jr disc_motor_set

;;-----------------------------------------------
;; stop drive motor
disc_motor_off:
;; stop drive motor
ld a,(&5b67)
and 247					;; bit 3 is motor state

disc_motor_set:
ld bc,&1ffd				;; BC = I/O address of motor control
ld (&5b67),a
out (c),a				;; set motor state
ret

;;-----------------------------------------------
;; send a fdc command byte to the fdc

send_command_byte:
ld bc,&2ffd				;; BC = I/O address of FDC main status register

push af
sd1:
in a,(c)				;; read main status register
add a,a					;; transfer bit 7 ("Request for master") into carry
						;; when "1", fdc is ready for data transfer via it's data register
jr nc,sd1				

add a,a					;; transfer bit 6 ("Data Input/Output") into carry
						;; when "1", data transfer is from CPU to FDC
						;; when "0", data transfer is from FDC to CPU
jr nc,sd2

pop af
ret

;; to get to here:
;; - fdc is ready for data transfer
;; - data transfer is from CPU to FDC
sd2:
pop af
ld b,&3f				;; BC = I/O address of FDC data register
out (c),a				;; write command byte into fdc data register
ld b,&2f				;; BC = I/O address of FDC main status register

ld a,5
sd3:
dec a
jr nz,sd3

ret

;;----------------------------------------------------------
;; write data to fdc when in execution phase
;;
;; for commands that transfer data from CPU to FDC during execution phase
;; of command.

fdc_data_write:
jr e_write2

e_write1: 
ld b,&3f				;; BC = I/O address for FDC data register
ld a,(de)				;; read byte from memory
out (c),a				;; output to FDC data register
ld b,&2f				;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

e_write2:
in a,(c)				;; read fdc main status register
jp p,e_write2			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_write1
ret

fdc_data_read_o:
jr e_read2o

e_read1o:
ld b,&3f				;; BC = I/O address for FDC data register
in a,(c)
ld b,&2f				;; BC = I/O address for FDC main status register
dec de					;; increment memory pointer


e_read2o:
ld a,d
or e
jp nz,e_read2ob
ld de,&ffff
defs 128

e_read2ob:
in a,(c)				;; read fdc main status register
jp p,e_read2ob			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jp nz,e_read1o
ret


fdc_data_writes:
jr e_write2s

e_write1s: 
ld a,(de)				;; read byte from memory
out (c),a				;; output to FDC data register
inc de					;; increment memory pointer

e_write2s:
in a,(c)				;; read fdc main status register
jp p,e_write2s			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_write1s
ret


fdc_data_write_o:
jr e_write2o

e_write1o:
ld b,&3f				;; BC = I/O address for FDC data register
xor a
out (c),a
ld b,&2f				;; BC = I/O address for FDC main status register
dec de					;; increment memory pointer

e_write2o:
ld a,d
or e
jp nz,e_write2o2
ld de,&ffff
defs 128
e_write2o2:
in a,(c)				;; read fdc main status register
jp p,e_write2o2		;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jp nz,e_write1o
ret


fdc_data_write_n:
jr e_write2n

e_write1n:
ld b,&3f
xor a
out (c),a				;; output to FDC data register
ld b,&2f
dec de
ld a,d
or e
ret z

e_write2n:
in a,(c)				;; read fdc main status register
jp p,e_write2n			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_write1n
ret


fdc_data_read_n:
jr e_read2n

e_read1n:
ld b,&3f
in a,(c)
ld b,&2f
dec de
ld a,d
or e
ret z

e_read2n:
in a,(c)				;; read fdc main status register
jp p,e_read2n			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1n
ret


fdc_data_write_count:
ld de,0
jr e_writec2

e_writec1: 
ld b,&3f				;; BC = I/O address for FDC data register
xor a
out (c),a				;; output to FDC data register
ld b,&2f				;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

e_writec2:
in a,(c)				;; read fdc main status register
jp p,e_writec2			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_writec1
ret

;;-----------------------------------------------------------
;; read data from fdc when in execution phase
;;
;; for commands that transfer data from FDC to CPU during execution phase
;; of command.

fdc_data_read:
jr e_read2

e_read1:
ld b,&3f				;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
ld (de),a				;; write to memory
ld b,&2f				;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

e_read2:
in a,(c)				;; read fdc main status register
jp p,e_read2			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1
ret

;;rs1:
;;in a,(c)				;; [4]
;;ret m					;; [3]
;;defs 32-4-3
;;jp rs1

fdc_read_data_count:
ld de,0
jr e_read2c

e_read1c:
ld b,&3f				;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
ld b,&2f				;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

e_read2c:
in a,(c)				;; read fdc main status register
jp p,e_read2c			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1c
ret


;;-----------------------------------------------------------
;; read data from fdc when in execution phase (but DO NOT store)
;;
;; for commands that transfer data from FDC to CPU during execution phase
;; of command.

fdc_read_data2:
jr e_read2b

e_read1b:
ld b,&3f				;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
ld b,&2f				;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

e_read2b:
in a,(c)				;; read fdc main status register
jp p,e_read2b			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1b
ret

;; read 8 bytes at a time, and increment de once for each 8 byte group
fdc_read_data3:
fdr1:
in a,(c)
jp p,fdr1
and &20
jp z,fdr9
fdr1b:
ld b,&3f
in a,(c)
ld b,&2f
fdr2:
in a,(c)
jp p,fdr2
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
fdr3:
in a,(c)
jp p,fdr3
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
fdr4:
in a,(c)
jp p,fdr4
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
fdr5:
in a,(c)
jp p,fdr5
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
fdr6:
in a,(c)
jp p,fdr6
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
fdr7:
in a,(c)
jp p,fdr7
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
fdr8:
in a,(c)
jp p,fdr8
and &20
jp z,fdr9
ld b,&3f
in a,(c)
ld b,&2f
inc de
fdr10:
in a,(c)
jp p,fdr10
and &20
jp nz,fdr1b

fdr9:
ret


;;-----------------------------------------------------------------------
;; read fdc command result data 
;; B = number of bytes

fdc_result_phase:
ld b,&2f				;; BC = I/O address for FDC main status register
ld hl,fdc_result_data

r1: 
in a,(c)				;; read FDC main status register
and &c0
cp &c0					;; is fdc ready to transfer data, and is data transfer from
						;; fdc to cpu?
jr nz,r1

ld b,&3f				;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
ld b,&2f				;; BC = I/O address for FDC main status register
ld (hl),a				;; store data byte
inc hl					;; increment pointer

ld a,5
r2: dec a
jr nz,r2

in a,(c)				;; read FDC main status register
and &10					;; check FDC busy flag
jr nz,r1

ld de,fdc_result_data
or a
sbc hl,de
ld b,l
ret

;;-----------------------------------------------------------------------------


