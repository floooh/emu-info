org &4000
;; time wait data for different drives
num_timings equ 32

read_data_timings_wd:
;; sectors close together
call disc_motor_on
call fdc_recalibrate
xor a
ld (track),a

ld b,num_timings
ld hl,timing_buffer
read_data_timings_wd2:
push bc
ld a,%01000110				;; read data, mfm
call fdc_write_command
ld a,(drive)
call fdc_write_command
ld a,(track)						;; C
call fdc_write_command
ld a,0						;; H
call fdc_write_command
ld a,&c1					;; R
call fdc_write_command
ld a,2						;; N
call fdc_write_command
ld a,&c2					;; EOT
call fdc_write_command
ld a,1					;; GPL  ?? for read
call fdc_write_command
ld a,&ff					;; dtl
call fdc_write_command

;; read first sector entirely.
ld de,512
read_timings2: 
in a,(c)				;; read fdc main status register
jp p,read_timings2			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register
dec de					;; increment memory pointer
ld a,d
or e
jp nz,read_timings2

;; now time until data is ready for next one
ld de,0
read_timings3: 
inc de					;; [2]
in a,(c)				;; [4]
jp p,read_timings3		;; [3]

;; result 
push de
push hl
call fdc_result
pop de
pop hl
ld (hl),e
inc hl
ld (hl),d
inc hl
pop bc
dec b
jp nz,read_data_timings_wd2

ld ix,timing_buffer
ld b,num_timings
ld hl,0

calc_avg:
ld e,(ix+0)
ld d,(ix+1)
inc ix
inc ix
add hl,de
djnz calc_avg

;; /32
srl h
rr l
srl h
rr l
srl h
rr l
srl h
rr l
srl h
rr l

ret

timing_buffer:
defs num_timings*2


end start