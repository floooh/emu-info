

;;-----------------------------------------------
;; start drive motor and wait for it to be rotating
;; at full speed

disc_motor_off:
xor a					
jr disc_motor_set

disc_motor_on:
ld a,1					

disc_motor_set:
ld bc,&fa7e				;; BC = I/O address of motor control
out (c),a				;; set motor state
ret

start_drive_motor:
call disc_motor_on
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
ld bc,&fb7e
in a,(c)
ret

fdc_read_data_register:
ld bc,&fb7f
in a,(c)
ret

;;-----------------------------------------------
;; stop drive motor


stop_drive_motor:
call disc_motor_off
jp wait_drive_motor

;;-----------------------------------------------
;; send a fdc command byte to the fdc

send_command_byte:
ld bc,&fb7e				;; BC = I/O address of FDC main status register

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
inc c					;; BC = I/O address of FDC data register
out (c),a				;; write command byte into fdc data register
dec c					;; BC = I/O address of FDC data register

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

e_write1:
inc c					;; BC = I/O address for FDC data register
ld a,(de)				;; read byte from memory
out (c),a				;; output to FDC data register
dec c					;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

fdc_data_write:
e_write2:
in a,(c)				;; read fdc main status register
jp p,e_write2			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_write1
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


fdc_data_write_n:
jr e_write2n

e_write1n:
inc c					;; BC = I/O address for FDC data register
xor a
out (c),a				;; output to FDC data register
dec c					;; BC = I/O address for FDC main status register
dec de

e_write2n:
ld a,d
or e
ret z
e_write2n2:
in a,(c)				;; read fdc main status register
jp p,e_write2n2		;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_write1n
ret

fdc_data_write_2n:
jr e_write2n22

e_write21n:
inc c			
inc b
outi
dec c					;; BC = I/O address for FDC main status register
dec de
ld a,d
or e
ret z

e_write2n22:
in a,(c)				;; read fdc main status register
jp p,e_write2n22		;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_write21n
ret


fdc_data_write_o:
jr e_write2o

e_write1o:
inc c					;; BC = I/O address for FDC data register
ld a,&ff
out (c),a				;; output to FDC data register
dec c					;; BC = I/O address for FDC main status register
dec de

e_write2o:
ld a,d
or e
jp nz,e_write2o2
defs 128
e_write2ob2:
in a,(c)					;; read fdc main status register
jp p,e_write2ob2			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jp nz,e_write2ob2
ret

e_write2o2:
in a,(c)				;; read fdc main status register
jp p,e_write2o2		;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jp nz,e_write1o
ret


fdc_data_read_n:
jr e_read2n

e_read1n:
inc c					;; BC = I/O address for FDC data register
in a,(c)
dec c					;; BC = I/O address for FDC main status register
dec de


e_read2n:
ld a,d
or e
ret z
e_read2nb:
in a,(c)				;; read fdc main status register
jp p,e_read2nb			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1n
ret

fdc_data_read_o:
jr e_read2o

e_read1o:
inc c					;; BC = I/O address for FDC data register
in a,(c)
dec c					;; BC = I/O address for FDC main status register
dec de


e_read2o:
ld a,d
or e
jp nz,e_read2ob
defs 128
e_read2ob2:
in a,(c)					;; read fdc main status register
jp p,e_read2ob2			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jp nz,e_read2ob2
ret

e_read2ob:
in a,(c)				;; read fdc main status register
jp p,e_read2ob			;; wait for fdc to signal it is ready to
						;; accept data 
						;; bit 7 will be 1 when FDC is ready to accept data


and &20					;; execution phase active? (bit 5 of main status register)
jp nz,e_read1o
ret


fdc_data_write_count:
ld de,0
jr e_writec2

e_writec1:
inc c					;; BC = I/O address for FDC data register
xor a
out (c),a				;; output to FDC data register
dec c					;; BC = I/O address for FDC main status register
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

e_read1:
inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
ld (de),a				;; write to memory
dec c					;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

fdc_data_read:
e_read2:
in a,(c)				;; read fdc main status register
jp p,e_read2			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1
ret


fdc_read_data_count:
ld de,0
jr e_readc2

e_readc1:
inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

e_readc2:
in a,(c)				;; read fdc main status register
jp p,e_readc2			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_readc1
ret

fdc_dma_read_data:
in a,(c)				;; read fdc main status register
jp p,fdc_dma_read_data

inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register
dec de
ld a,d
or e
jr nz,fdc_dma_read_data
ret


fdc_timing:
ld de,0

;; waiting for data from sector
ft1:
in a,(c)		;; [4]
jp m,ft2		;; [3]
defs 32-3-2-3-4
inc de			;; [2]
jp ft1			;; [3]

ft2:
and &20					
jr z,ft3

;; execution phase read
ft2b:
inc c			
in a,(c)
dec c				
ft4:
in a,(c)
jp p,ft4
and &20					
jr nz,ft2b


;; execution
ft3:
in a,(c)		;; [4]
jp m,ft5		;; [3]
defs 32-3-2-3-4
inc de			;; [2]
jp ft3			;; [3]

ft5: 
ret


fdc_read_data_timing:
ld de,0

frdt1:
in a,(c)
jp m,frdt2
and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_readc1
inc de
jr frdt1

frdt2:
inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register

ld (hl),e
inc hl
inc hl
ld (hl),d
inc hl
jr fdc_read_data_timing

;;-----------------------------------------------------------
;; read data from fdc when in execution phase (but DO NOT store)
;;
;; for commands that transfer data from FDC to CPU during execution phase
;; of command.

fdc_read_data2:
jr e_read2b

e_read1b:
inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register
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
inc c
in a,(c)
dec c
fdr2:
in a,(c)
jp p,fdr2
and &20
jp z,fdr9
inc c
in a,(c)
dec c
fdr3:
in a,(c)
jp p,fdr3
and &20
jp z,fdr9
inc c
in a,(c)
dec c
fdr4:
in a,(c)
jp p,fdr4
and &20
jp z,fdr9
inc c
in a,(c)
dec c
fdr5:
in a,(c)
jp p,fdr5
and &20
jp z,fdr9
inc c
in a,(c)
dec c
fdr6:
in a,(c)
jp p,fdr6
and &20
jp z,fdr9
inc c
in a,(c)
dec c
fdr7:
in a,(c)
jp p,fdr7
and &20
jp z,fdr9
inc c
in a,(c)
dec c
fdr8:
in a,(c)
jp p,fdr8
and &20
jp z,fdr9
inc c
in a,(c)
dec c
inc de
fdr10:
in a,(c)
jp p,fdr10
and &20
jp nz,fdr1b

fdr9:
ret

fdc_read_result_byte:
ld bc,&fb7e
in c,(c)
ld a,5
rrbb2:
dec a
jr nz,rrbb2
ret

rdn1:
INC C
IN A,(C)
LD (HL),A
DEC C
INC HL
DEC DE
read_data_n1:
IN A,(C)
JP P,rdn1
AND &20
RET Z
LD A,D
OR E
JP NZ,rdn1
rdn2:
INC C
IN A,(C)
DEC C
rdn3:
IN A,(C)
JP P,rdn3
AND &20
JP NZ,rdn2
RET

;;-----------------------------------------------------------------------
;; read fdc command result data 
;; B = number of bytes

fdc_result_phase:
ld bc,&fb7e				;; BC = I/O address of FDC main status register
ld hl,fdc_result_data

r1:
in a,(c)				;; read FDC main status register
and &c0
cp &c0					;; is fdc ready to transfer data, and is data transfer from
						;; fdc to cpu?
jr nz,r1

inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register
ld (hl),a				;; store data byte
inc hl					;; increment pointer

ld a,5
r2:
dec a
jr nz,r2

in a,(c)				;; read FDC main status register
and &10					;; check FDC busy flag
jr nz,r1

r3:
ld de,fdc_result_data
or a
sbc hl,de
ld b,l
ret

;;-----------------------------------------------------------------------------
sense_drive_status_fast:

ld bc,&fb7f

ld a,8

out (c),a

ex (sp),hl

ex (sp),hl

ex (sp),hl

ex (sp),hl

ld a,(drive)

out (c),a

ex (sp),hl

ex (sp),hl

ex (sp),hl

ex (sp),hl

ld bc,&fb7f

in a,(c)

ret