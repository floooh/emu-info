;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
if CPC=1
org &4000
endif
if SPEC=1
org &8000
endif

km_read_char equ &bb09 

start:
call cls
ld hl,menu_msg
call display_string

call exe_menu
jp start

menu_msg:
defb "0. Toggle drive motor",10,13

;; .....
;; still not working
defb "h. read id timing",10,13

defb "l. read data, read id",10,13
;; 8: 8000
;; 9: 8000-ff: 8000

;; blue jumps and becomes white
;; (512 byte standard data format)
;; (256 byte is much more stable)

;; l: 0000 40 04 00 00 00 ff 00

defb "z. read track dtl",10,13
;; m: 0400:  40 a4 20 00 00 03 00
;; z: 00a0, 40 a4 20 00 00 02 00

;; 0000
;; 41 20 20 00 00 c1 02
defb "r. read data with dma no poll",10,13
;; 0200
;; 42 01 00 02 02 01 02
;; 41 20 20 00 00 c1 02 02 02 etc
defb "t. find max tracks (fmt) "
;; shows how disc is formatted...
;;
;; e5*512, 2 byte crc, gap 3 bytes (4e), 12 bytes 0, 3 bytes a1, 1 byte fe, c,h,r,n,
;; 2 byte crc, 22 bytes 4e, 12 bytes 00, 3 bytes a1, 1 byte fb, 512 bytes data, looses sync after end of track
;; so doesn't show index mark at beginning.. 
defb "w. read data diff gaps   "
;; value:0200 41 80 00 00 00 c1 02

defb "x. write data diff gaps (fmt)",10,13
;; value:0200 0200 41 80 00 00 00 c2 02 
;; gpl has no meaning here?
defb "y. write data diff gaps 2 (fmt)",10,13


defb 0


;;-----------------------------------------------------------------

exe_menu:
call km_wait_char
;;cp "0"
;;jp z,toggle_drive_motor
cp "h"
jp z,read_id_timing
cp "H"
jp z,read_id_timing
cp "l"
jp z,read_data_read_id
cp "L"
jp z,read_data_read_id
cp "p"

;;cp "p"
;;jp z,sync_1_rd
;;cp "P"
;;jp z,sync_1_rd
cp "r"
jp z,read_data_dma_no_poll
cp "R"
jp z,read_data_dma_no_poll
cp "t"
jp z,format_84_tracks
cp "T"
jp z,format_84_tracks
cp "w"
jp z,read_data_diff_gaps
cp "W"
jp z,read_data_diff_gaps
cp "x"
jp z,write_data_diff_gaps
cp "X"
jp z,write_data_diff_gaps
cp "y"
jp z,write_data_diff_gaps2
cp "y"
jp z,write_data_diff_gaps2
ret

write_data_diff_gaps:
call cls
call pick_drive
call disc_motor_on

call fdc_recalibrate
xor a
ld (track),a
call fdc_seek

xor a
ld b,0
wddg1:
push bc
push af
push af
call print_hex
ld a,":"
call display_char

ld ix,track_buffer
ld b,9
ld c,&c1
wddg2:
ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),c
ld (ix+3),2
inc c
inc ix
inc ix
inc ix
inc ix
djnz wddg2
di
ld de,track_buffer
;; format
ld a,%01001101
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,2						;; sector size
call send_command_byte
ld a,9						;; number of sectors
call send_command_byte
ld a,16					;; gpl
call send_command_byte
ld a,&e5					;; filler
call send_command_byte
call fdc_data_write
call fdc_result_phase
ei


di
ld a,%01000101			;; write data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&c1					;; R
call send_command_byte
ld a,2						;; N
call send_command_byte
ld a,&c1					;; EOT
call send_command_byte
pop af
call send_command_byte
ld a,&ff					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_write
push de
call fdc_result_phase
pop hl
ld bc,-track_buffer
add hl,bc
ei
;; length of data written
ld a,h
call print_hex
ld a,l
call print_hex
ld a," "
call display_char

;; now try and read next sector
di
ld a,%01000110				;; read data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&c2					;; R
call send_command_byte
ld a,2						;; N
call send_command_byte
ld a,&c2					;; EOT
call send_command_byte
ld a,&2a
call send_command_byte
ld a,&ff					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_read
push de
call fdc_result_phase
pop hl
ld bc,-track_buffer
add hl,bc
ei
;; length of data written
ld a,h
call print_hex
ld a,l
call print_hex
ld a," "
call display_char
ld b,7
call dump_result
call display_newline
pop af
pop bc
inc a
dec b
jp nz,wddg1

call stop_drive_motor
call wait_key
ret

read_data_read_id:
call cls
call pick_drive
call disc_motor_on

call fdc_recalibrate
xor a
ld (track),a
call fdc_seek

ld ix,track_buffer
ld b,9
ld c,&c1
wddg2z:
ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),c
ld (ix+3),2
inc c
inc ix
inc ix
inc ix
inc ix
djnz wddg2z
di
ld de,track_buffer
;; format
ld a,%01001101
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,2						;; sector size
call send_command_byte
ld a,9						;; number of sectors
call send_command_byte
ld a,16					;; gpl
call send_command_byte
ld a,&e5					;; filler
call send_command_byte
call fdc_data_write
call fdc_result_phase
ei


;; read non exist sector
di
ld a,%01000110				;; read data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&ff					;; R
call send_command_byte
ld a,0					;; N
call send_command_byte
ld a,&ff					;; EOT
call send_command_byte
ld a,&2a
call send_command_byte
ld a,&80					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_read
call fdc_result_phase

;; now immediately read id
ld a,%01001010						;; read id
call send_command_byte
ld a,(drive)			
call send_command_byte
call fdc_result_phase			
ei
;; this should report first sector id of track
ld b,7
call dump_result
call display_newline

call wait_key
ret



write_data_diff_gaps2:
call cls
call pick_drive
call disc_motor_on

call fdc_recalibrate
xor a
ld (track),a
call fdc_seek

xor a
ld b,0
wddg12:
push bc
push af
push af
call print_hex
ld a,":"
call display_char

ld ix,track_buffer
ld c,&c1

ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),&c1
ld (ix+3),6
inc ix
inc ix
inc ix
inc ix
ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),&c2
ld (ix+3),2
inc ix
inc ix
inc ix
inc ix
ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),&c3
ld (ix+3),2
inc ix
inc ix
inc ix
inc ix
ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),&c4
ld (ix+3),2
inc ix
inc ix
inc ix
inc ix
di
ld de,track_buffer
;; format
ld a,%01001101
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,2						;; sector size
call send_command_byte
ld a,9						;; number of sectors
call send_command_byte
ld a,16					;; gpl
call send_command_byte
ld a,&e5					;; filler
call send_command_byte
call fdc_data_write
call fdc_result_phase
ei


di
ld a,%01000101			;; write data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&c1					;; R
call send_command_byte
ld a,2						;; N
call send_command_byte
ld a,&c2					;; EOT
call send_command_byte
pop af
call send_command_byte
ld a,&ff					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_write
push de
call fdc_result_phase
pop hl
ld bc,-track_buffer
add hl,bc
ei


if 0
;; now try and read next sector
di
ld a,%01000110				;; read data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&c2					;; R
call send_command_byte
ld a,2						;; N
call send_command_byte
ld a,&c2					;; EOT
call send_command_byte
ld a,&2a
call send_command_byte
ld a,&ff					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_read
push de
call fdc_result_phase
pop hl
ld bc,-track_buffer
add hl,bc
ei
;; length of data written
ld a,h
call print_hex
ld a,l
call print_hex
ld a," "
call display_char
ld b,7
call dump_result
call display_newline
endif

di
ld a,%01000110				;; read data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&c1					;; R
call send_command_byte
ld a,6						;; N
call send_command_byte
ld a,&c1					;; EOT
call send_command_byte
ld a,1					;; GPL  ?? for read
call send_command_byte
ld a,&ff					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_read
call fdc_result_phase
ei
;;ld b,7
;;call dump_result
;;call display_newline
;;ld de,track_buffer
;;ld bc,2048
;;call dump_bytes

ld de,track_buffer
ld bc,8192				
call dump_bytes

pop af
pop bc
inc a
dec b
jp nz,wddg12

call stop_drive_motor
call wait_key
ret


read_data_diff_gaps:
call cls
call pick_drive
call disc_motor_on

call fdc_recalibrate
xor a
ld (track),a
call fdc_seek

xor a
ld b,0
rddg1:
push bc
push af
push af
call print_hex
ld a,":"
call display_char
di
ld a,%01000110				;; read data, mfm
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,0						;; C
call send_command_byte
ld a,0						;; H
call send_command_byte
ld a,&c1					;; R
call send_command_byte
ld a,2						;; N
call send_command_byte
ld a,&c1					;; EOT
call send_command_byte
pop af
call send_command_byte
ld a,&ff					;; dtl
call send_command_byte
ld de,track_buffer
call fdc_data_read
push de
call fdc_result_phase
pop hl
ld bc,-track_buffer
add hl,bc
ei
;; length of data
ld a,h
call print_hex
ld a,l
call print_hex
ld a," "
call display_char

;; dump results
ld b,7
call dump_result
call display_newline

pop af
pop bc
inc a
dec b
jp nz,rddg1

call stop_drive_motor
call wait_key
ret



fdc_recalibrate:
;; seek to track 0
ld a,%111						;; recalibrate
call send_command_byte
ld a,(drive)					;; drive
call send_command_byte

fdc_recalibrate_check_end:
ld a,%1000						;; sense interrupt status
call send_command_byte
call fdc_result_phase

;; recalibrate completed?
ld ix,result_data
bit 4,(ix+0)
jr nz,fdc_recalibrate
bit 5,(ix+0)
jr z,fdc_recalibrate_check_end

ret


fdc_seek:
;; issue seek command
ld a,%0000001111    ;; seek command
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,(track)
call send_command_byte

fdc_seek_check_end:
ld a,%1000						;; sense interrupt status
call send_command_byte
call fdc_result_phase

;; recalibrate completed?
ld ix,result_data
bit 4,(ix+0)
jr nz,fdc_seek
bit 5,(ix+0)
jr z,fdc_seek_check_end

ret



format_84_tracks:
;; test... format do seek and then check that ids are not repeated to find max track
call cls
call pick_drive
call disc_motor_on


xor a
ld (track),a

fmt1:
ld a,(track)
call print_hex
ld a,":"
call display_char

call fdc_recalibrate
call fdc_seek

ld ix,track_buffer
ld b,9
ld c,&c1
fmt2:
ld a,(track)
ld (ix+0),a
ld (ix+1),0
ld (ix+2),c
ld (ix+3),2
inc c
inc ix
inc ix
inc ix
inc ix
djnz fmt2
di
ld de,track_buffer
;; format
ld a,%01001101
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,2						;; sector size
call send_command_byte
ld a,9						;; number of sectors
call send_command_byte
ld a,&52					;; gpl
call send_command_byte
ld a,&e5					;; filler
call send_command_byte
call fdc_data_write
call fdc_result_phase
ei
ld b,7
call dump_result

call fdc_recalibrate
;; go to previous track
ld a,(track)
dec a
ld (track),a
cp &ff
jp z,fmt5
call fdc_seek


;; issue read id command
ld a,%01001010						;; read id
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte
call fdc_result_phase

ld b,7
call dump_result

;; check that previous track id is correct 
ld ix,result_data
ld a,(track)
cp (ix+3)
jr nz,fmt4

fmt5:
call display_newline
ld a,(track)
inc a
inc a
ld (track),a
cp 90
jp nz,fmt1

fmt4:

call wait_key
ret



read_data_dma_no_poll:
call cls
call pick_drive
call disc_motor_on

;; specify
ld a,%00000011
call send_command_byte
ld a,&a1
call send_command_byte
ld a,&2						;; dma mode
call send_command_byte

ld a,0
ld (track),a
call fdc_seek

di
ld a,&46
call send_command_byte
ld a,(drive)
call send_command_byte
ld a,(track)
call send_command_byte
ld a,0
call send_command_byte
ld a,&c1
call send_command_byte
ld a,2
call send_command_byte
ld a,&c1
call send_command_byte
ld a,&2a
call send_command_byte
ld a,&ff
call send_command_byte


ld de,track_buffer
ld hl,512

rdnp1dma:
in a,(c)
jp p,rdnp1dma

;; and &20
;; jr nz,

;; this is required to ensure we do not miss out on some bytes sometimes
defs 5

;; this works perfectly and doesn't cause overrun
;; if the gap is wrong you either get:
;; 1. read never finishing
;; 2. overrun condition error
;; 3. some bytes missing
;; 4. result phase being data from sector
rdnp2dma:
inc c			;; [1]
in a,(c)		;; [4]
ld (de),a		;; [2]
dec c			;; [1]
inc de			;; [2] = [10]
defs 32-7-10

dec hl			;; [2]
ld a,h			;; [1]
or l			;; [1]
jp nz,rdnp2dma		;; [3] = [7]

push de
call fdc_result_phase
pop hl
ld bc,-track_buffer
add hl,bc
push hl
ei
;; length of data
ld a,h
call print_hex
ld a,l
call print_hex
call display_newline

;; dump results
ld b,7
call dump_result
call display_newline
pop bc
ld de,track_buffer

call dump_bytes

;; reset specify
ld a,%00000011
call send_command_byte
ld a,&a1
call send_command_byte
ld a,&3						;; dma mode
call send_command_byte

call stop_drive_motor
call wait_key
ret




e_read1_cnt:
inc c					;; BC = I/O address for FDC data register
in a,(c)				;; read from FDC data register
dec c					;; BC = I/O address for FDC main status register
inc de					;; increment memory pointer

fdc_data_read_count: 
in a,(c)				;; read fdc main status register
jp p,fdc_data_read_count			;; wait for fdc to signal it is ready to
						;; accept data
						;; bit 7 will be 1 when FDC is ready to accept data

and &20					;; execution phase active? (bit 5 of main status register)
jr nz,e_read1_cnt
ret


dump_bytes:
ld l,0
ld h,0
rtig3:
push bc
push hl
ld a,(de)
inc de
push de
call print_hex
ld a," "
call display_char

call wait_key

dump_bytes2:
pop de
pop hl
inc h
ld a,h
cp 16
jr nz,rtig4
ld h,0
call display_newline
inc l
ld a,l
cp 25
jr nz,rtig4
push hl
push de
call wait_key
call cls
pop de
pop hl
ld l,0
rtig4:
pop bc
dec bc
ld a,b
or c
jr nz,rtig3

ret

sync_1_rd:
call cls
call pick_drive
di

ld a,%00000011
call send_command_byte
ld a,&af			;; head unload time
call send_command_byte
ld a,&3				;; head load time
call send_command_byte

call disc_motor_on

sync11rd:
;; wait for drive to be ready
call sense_drive_status
ld ix,result_data

ld a,(ix+0)
bit 5,a
jr z,sync11rd

sync1rdl:
ld a,0
ld (track),a
ld a,&c1
ld (sector),a

;; issue read data command
ld a,%01000110						;; read data
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte
ld a,(track)
call send_command_byte
xor a
call send_command_byte
ld a,(sector)
call send_command_byte
ld a,2
call send_command_byte
ld a,(sector)
call send_command_byte
ld a,&2a
call send_command_byte
ld a,&ff
call send_command_byte

;; look for result

call fdc_result_phase

;; now turn off motor

;; how long does it take to turn off motor?
;; and how long does it take to turn on motor?
call stop_drive_motor

;; wait for start of vsync
ld b,&f5
sync11brd:
in a,(c)
rra
jr nc,sync11brd

call disc_motor_on

ret


sync_1:
call cls
call pick_drive
di

ld a,%00000011
call send_command_byte
ld a,&af			;; head unload time
call send_command_byte
ld a,&3				;; head load time
call send_command_byte


call disc_motor_on

sync11:
;; wait for drive to be ready
call sense_drive_status
ld ix,result_data

ld a,(ix+0)
bit 5,a
jr z,sync11

sync1l:
;; issue read id command
ld a,%01001010						;; read id
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte

call fdc_result_phase

ld ix,result_data
ld a,(ix+5)						;; look for &09
cp &09
jr nz,sync1l

;; 1031 bytes approx
ld bc,32992/7
call sync_delay


;;call sync_delay

;; just read id field
;; now turn off motor

;; how long does it take to turn off motor?
;; and how long does it take to turn on motor?
call stop_drive_motor

;; wait for start of vsync
ld b,&f5
sync11b:
in a,(c)
rra
jr nc,sync11b

call disc_motor_on

sync11a:
;; wait for drive to be ready
call sense_drive_status
ld ix,result_data

ld a,(ix+0)
bit 5,a
jr z,sync11a

jp synced_loop

sync_delay:
ld bc,17664/7	;; [3]

sync_delay2:
dec bc			;; [2]
ld a,b			;; [1]
or a			;; [1]
jp nz,sync_delay2	;; [3]


ret


sync_2:
call cls
call pick_drive
di
ld a,%00000011
call send_command_byte
ld a,&af			;; head unload time
call send_command_byte
ld a,&3				;; head load time
call send_command_byte

ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bd09
out (c),c
ld bc,&bd00
out (c),c

;; turn off vsyncs
ld bc,&bc07
out (c),c
ld bc,&bdff
out (c),c

call disc_motor_on

sync21:
call wait_vsync
;; wait for drive to be ready
call sense_drive_status
ld ix,result_data

ld a,(ix+0)
bit 5,a
jr z,sync21


;; issue read id command
ld a,%01001010						;; read id
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte

;; data ready?
synl22:
ld bc,&fb7e
in a,(c)
jp p,synl22

ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc09
out (c),c
ld bc,&bd00+7
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c

call fdc_result_phase			
;;ld ix,result_data
;;ld a,(ix+5)
;;cp &09
;;jp z,resync

jp synced_loop



;; ok it will take some time for motor to achieve max speed

synced_loop:
;; wait for vsync
ld b,&f5
synl1: in a,(c)
rra
jr nc,synl1
;; turn on first colour
ld bc,&7f10
out (c),c
ld bc,&7f4b						;; white
out (c),c


;; issue read id command
ld a,%01001010						;; read id
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte

;; data ready?
synl2:
ld bc,&fb7e
in a,(c)
jp p,synl2

;; result phase has started
ld bc,&7f10
out (c),c
ld bc,&7f40					;; grey
out (c),c
call fdc_result_phase			

;; ok now do other colour
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

defs 64*18

jp synced_loop



read_id_timing:
call cls
call pick_drive
call disc_motor_on

read_id_timing_loop:
;; is a char ready from keyboard?
call km_read_char
jp nc,read_id_timing4

;; is it space?
cp " "
;; wait for key and quit
jp z,wait_key

read_id_timing4:
;; issue read id command
ld a,%01001010						;; read id
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte

read_id_timing2:
ld b,&f5
in a,(c)
rra
jr nc,read_id_timing3
ld hl,vsync_txt
call display_string
read_id_timing3:
;; data ready?
ld bc,&fb7e
in a,(c)
jp p,read_id_timing2

call fdc_result_phase			;; status should show that drive is NOT READY!

ld b,7
call dump_result
call display_newline
jp read_id_timing_loop

vsync_txt:
defb "vsync",10,13,0



wait_key:
ld hl,press_a_key_msg
call display_string
call wait_key
ret

press_a_key_msg:
defb 10,13,10,13,"Press any key",0



;;-----------------------------------------------------------------

toggle_drive_motor:
ld a,(motor)
xor 1
ld (motor),a
or a
jp nz,disc_motor_on

;; stop drive motor
call stop_drive_motor
ret

motor:
defb 0
;;-----------------------------------------------------------------

pick_drive:
ld hl,drive_msg
call display_string

call wait_char
cp "A"
ld c,0
jr z,set_drive
cp "a"
ld c,0
jr z,set_drive
cp "B"
ld c,1
jr z,set_drive
cp "b"
ld c,1
jr z,set_drive

set_drive:

ld a,c
ld (drive),a
add a,'A'
call display_char
call display_newline
ret

drive_msg:
defb "Drive (A or B):",0
;;-----------------------------------------------------------------

;;----------------------------------------------------------------------------------------------
;; check for recalibrate failing... do it three times?
;; this is roughly how pc detects a drive

recal_check:
call cls
call pick_drive

ld a,(drive)
cp 0
ld c,%0001
jr z,recal_check2
ld c,%0010
recal_check2:
ld a,c
ld (recal_check_drive_mask+1),a
xor a
ld (recal_count),a
recal_again:
;; do first recalibrate
ld a,%111						;; recalibrate
call send_command_byte
ld a,(drive)					;; drive
call send_command_byte

recal_wait:
call wait_vsync

ld bc,&fb7e
in a,(c)
recal_check_drive_mask:
and %0001						;; drive 0
jr nz,recal_wait

call sense_interrupt_status
ld ix,result_data
;; no result
ld a,(ix+0)
cp &80
jp z,recal_wait

;; equipment check
bit 4,a
jp nz,recal_fail

bit 3,a
jp nz,ready_change

bit 5,a
ld hl,recal_ok_msg
jp z,recal_done
ld hl,recal_no_seek_end_msg

recal_done:
call display_string
ret

recal_fail:
ld a,(recal_count)
inc a
ld (recal_count),a
cp 2
jr nz,recal_again

ld hl,recal_fail_msg
call display_string
ret

ready_change:
ld hl,ready_change_msg
call display_string
ret

recal_no_seek_end_msg:
defb "Recalibrate no seek end",0

recal_ok_msg:
defb "Recalibrate OK",0

ready_change_msg:
defb "Ready changed",0


recal_fail_msg:
defb "Recalibrate fail",0

recal_count:
defb 0

specify_cmd:
ld a,%00000011
call send_command_byte
ld a,(step_rate_time)
rlca
rlca
rlca
rlca
and &f0
ld c,a
ld a,(head_unload_time)
and &f
or c
call send_command_byte
ld a,(head_load_time)
rlca
and &fe
or &1
call send_command_byte
ret

specify_keys:
call wait_key
cp &f0
ld hl,specify_pick
jr z,pick_dec
cp &f1
ld hl,specify_pick
jr z,pick_inc
cp &f2
ld de,specify_pick
ld hl,specify_val_tab
jr z,val_dec
cp &f3
ld de,specify_pick
ld hl,specify_val_tab
jr z,val_inc
ret

specify_pick:
defb 0				;; cur 
defb 0				;; max

specify_val_tab:
step_rate_time:
defb 1
defb 15
head_unload_time:
defb 1
defb 15
head_load_time:
defb 1
defb 15

;;-----------------------------------------

;; DE = pick val
;; HL = table of values
val_inc:
ld a,(de)
add a,a
add a,l
ld l,a
ld a,h
adc a,0
ld h,a
call pick_inc
ret

;;-----------------------------------------
;; DE = pick val
;; HL = table of values (cur and max)
val_dec:
ld a,(de)			;; value index
add a,a
add a,l
ld l,a
ld a,h
adc a,0
ld h,a
call pick_dec
ret

;;-----------------------------------------

pick_dec:
ld a,(hl)
dec a
jp p,pick_dec2
inc hl
ld a,(hl)
dec hl
pick_dec2:
ld (hl),a
ret

;;-----------------------------------------

pick_inc:
ld a,(hl)
inc a
inc hl
cp (hl)
jr nz,pick_inc2
xor a
pick_inc2:
dec hl
ld (hl),a
ret

;;-----------------------------------------


;; 1/50 = 2ms






dump_result:
ld ix,result_data
dr1:
push bc
ld a,(ix+0)
inc ix
call print_hex
ld a," "
call display_char
pop bc
djnz dr1
ret

wait_vsync_begin:
ld b,&f5
rvs1:
in a,(c)
rra
jr nc,rvs1
ret

wait_vsync:
call wait_vsync_begin
rvs2:
in a,(c)
rra
jr c,rvs2
ret


;;----------------------------------------------------------------------

drive:
defb 0
track:
defb 0
sector:
defb 0
;;----------------------------------------------------------------------

sense_drive_status:
ld a,%100						;; sense drive status
call send_command_byte
ld a,(drive)					;; drive status of connected drive
call send_command_byte
call fdc_result_phase			;; status should show that drive is NOT READY!
ret

;;----------------------------------------------------------------------

sense_interrupt_status:
ld a,%1000						;; sense interrupt status
call send_command_byte
call fdc_result_phase
ret
;;----------------------------------------------------------------------

print_hex:
push af
rrca
rrca
rrca
rrca
call print_hex_digit
pop af
print_hex_digit:
and &f
cp 10
jr c,print_hex_digit2
add a,'A'-10
jp display_char
print_hex_digit2:
add a,'0'
jp display_char
;;----------------------------------------------------------------------

if CPC=1
include "cpc.asm"
endif
if SPEC=1
include "plus3.asm"
endif
result_data:
defs 9
track_buffer: defb 1

end start