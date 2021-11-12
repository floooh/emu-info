;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../../lib/testdef.asm"

;; IDE command tester
org &4000
start:

ld hl,copy_result_fn
ld (cr_functions),hl

call cls
ld hl,intro_message
call output_msg
call wait_key

call set_master
call set_lba
call ide_identify_device
ld hl,read_data_buffer+(60*2)
ld de,lba
ld bc,4
ldir
ld hl,read_data_buffer+(1*2)
ld e,(hl)
inc hl
ld d,(hl)
ld (chs+0),de
ld hl,read_data_buffer+(3*2)
ld e,(hl)
inc hl
ld d,(hl)
ld (chs+2),de
ld hl,read_data_buffer+(6*2)
ld e,(hl)
inc hl
ld d,(hl)
ld (chs+4),de

ld hl,(lba+0)
ld de,(lba+2)
ld a,l
add a,1
ld l,a
ld a,h
adc a,0
ld h,a
ld a,e
adc a,0
ld e,a
ld a,d
adc a,0
and &f
ld d,a
ld (lbaplusone),hl
ld (lbaplusone+2),de


ld hl,(lba)
ld de,(lba+2)
ld a,l
sub 1
ld l,a
ld a,h
sbc a,0
ld h,a
ld a,e
sbc a,0
ld e,a
ld a,d
sbc a,0
and &f
ld d,a
ld (lbaminusone),hl
ld (lbaminusone+2),de

ld hl,(lba)
ld de,(lba+2)
ld a,l
sub 2
ld l,a
ld a,h
sbc a,0
ld h,a
ld a,e
sbc a,0
ld e,a
ld a,d
sbc a,0
and &f
ld d,a
ld (lbaminustwo),hl
ld (lbaminustwo+2),de
call cls

;;ld a,(ide_device)
;;or a
;;call nz,set_defaults

;;call cls
;;ld hl,choose_drive_message
;;call output_msg
;;call wait_key
;;sub '0'
;;ld (drive_config),a
;;
;;dev2:
xor a
ld (drive_config),a
call set_master_slave


call cls
ld ix,tests
call run_tests
ret

set_master_slave:
ld a,(drive_config)
or a
jp z,set_master
jp set_slave

chs:
defs 6
lba:
defs 4
lbaplusone:
defs 4
lbaminusone:
defs 4
lbaminustwo:
defs 4

drive_config:
defb 0

intro_message:
defb "IDE command tester",13,13
defb "Tested on an X-MASS with PQI IDE DiskOnModule.",13
defb "NOTE: IDE drives vary in their support for commands.",13,13
defb "Press any key to continue",13
defb 0

choose_drive_message:
defb "Press key for drive configuration",13
defb "0: None",13
defb "1: Master",13
defb "2: Slave",13
defb "3: Master & Slave",13
defb 0

;; TODO: Detect which command-set is supported and adjust results
;; TODO: CHS, Max LBA etc
;; TODO: device reset before start it all
;; TODO: command on master and slave and see what happens with data bus?
;;-----------------------------------------------------

tests:
;; ATA-1:



;; ** ATA-1: NOP = 00
;; ATA-4: CFA REQUEST EXTENDED ERROR CODE/REQUEST SENSE = 03 (see compact flash specification pdf)
;; ATA-3: DATA SET MANAGEMENT = 06
;; ** ATA-3: DEVICE RESET = 08
;; ** ATA-1: RECALIBRATE = 1x
;; ATA-1: READ SECTORS = 20
;; ATA-1: READ SECTORS WITH VERIFY = 21
;; ATA-1: READ LONG = 22
;; ATA-1: READ LONG (w/o RETRY) = 23
;; ATA-3: READ SECTORS EXT = 24
;; ATA-3: READ DMA EXT = 25
;; READ NATIVE MAX ADDRESS EXT = 27
;; ATA-3: READ MULTIPLE EXT=29
;; ATA-3: READ STREAM DMA EXT=2A
;; ATA-3: READ STREAM EXT=2B
;; ATA-3: READ LOG EXT=2F
;; ATA-1: WRITE SECTORS = 30
;; ATA-1: WRITE SECTORS WITH VERIFY = 31
;; ATA-1: WRITE LONG = 32
;; ATA-1: WRITE LONG = 33
;; ATA-3: WRITE SECTORS EXT = 34
;; ATA-3: WRITE DMA EXT = 35
;; SET MAX ADDRESS EXT = 37
;; CF: WRITE SECTORS W/O ERASE = 38
;; ATA-3: WRITE MULTIPLE EXT = 39
;; ATA-3: WRITE STREAM DMA EXT = 3A
;; ATA-3: WRITE STREAM EXT = 3B
;; ATA-1: WRITE VERIFY = 3C
;; ATA-3: WRITE DMA FUA EXIT = 3D
;; ATA-2: READ VERIFY SECTORS = 40
;; ATA-2: READ VERIFY SECTORS w/o RETRY = 41
;; ATA-3: READ VERIFY SECTORS EXT = 42
;; ATA-3: WRITE UNCORRECTABLE EXT  = 45
;; ATA-3: READ LOG DMA EXT  = 47
;; ATA-1: FORMAT TRACK = 50
;; ATA-3: CONFIGURE STREAM = 51
;; ATA-3: WRITE LOG DMA EXT = 57
;; ATA-3: TRUSTED NON-DATA = 5B
;; ** ATA-1: SEEK = 7x
;; CF: TRANSLATE SECTOR = 87
;; ATA-1: EXECUTE DEVICE DIAGNOSTIC = 90
;; ATA-1: INITIALISE DEVICE PARAMETERS= 91
;; ATA-2: DOWNLOAD MICROCODE = 92
;; ATA-1: STANDBY IMMEDIATE = 94
;; ATA-1: IDLE IMMEDIATE = 95
;; ATA-1: STANDBY = 96
;; ATA-1: IDLE = 97
;; ATA-1: CHECK POWER MODE = 98
;; ATA-1: SLEEP = 99
;; CF: ERASE SECTORS = C0
;; ATA-1: READ MULTIPLE = C4
;; ATA-1: WRITE MULTIPLE = C5
;; ATA-1: SET MULTIPLE MODE = C6
;; ATA-1: READ DMA WITH RETRY = C8
;; ATA-1: READ DMA WITHOUT RETRY = C9
;; ATA-1: WRITE DMA WITH RETRY = CA
;; ATA-1: WRITE DMA WITHOUT RETRY = CB
;; CF: WRITE MULTIPLE WITHOUT ERASE = CD
;; GET MEDIA STATUS = DA
;; ATA-1: ACKNOWLEDGE MEDIA CHANGE - DC
;; ATA-1: BOOT - POST BOOT - DC
;; ATA-1: BOOT - PRE BOOT - DD
;; ATA-1: DOOR LOCK = DE
;; ATA-1: DOOR UNLOCK = DF
;; ATA-1: STANDBY IMMEDIATE = E0
;; ATA-1: IDLE IMMEDIATE = E1
;; ATA-1: STANDBY = E2
;; ATA-1: IDLE = E3
;; ATA-1: READ BUFFER = E4
;; ATA-1: CHECK POWER MODE = E5
;; ATA-1: SLEEP = E6
;; ATA-1: WRITE BUFFER = E8
;; ATA-1: WRITE SAME = e9
;; ATA-1: IDENTIFY DEVICE = EC
;; ATA-2: MEDIA EJECT = ED
;; ATA-1: SET FEATURES = EF
;; CF: WEAR LEVEL = F5
;; READ NATIVE MAX ADDRESS = F8
;; SET MAX ADDRESS = F9

;; NOTE: on hd. recalibrate only 10 works, same with 70, error on others
;; also read-long actually has bytes.
;; hd also doesn't support sense
;; power mode returns 22,78,44 etc.
;; read max native address works.
;;
;; need to: 1. detect if command is supported or not
;; and update results accordingly.
;; 

DEFINE_TEST "read & write (lba)",read_write_lba
DEFINE_TEST "read & write (chs)",read_write_chs

DEFINE_TEST "read around max lba",read_max_lba
;; TODO: Where H is not 16
DEFINE_TEST "read around max chs",read_max_chs

;;DEFINE_TEST "read sectors (lba)",read_sectors
;;DEFINE_TEST "write sectors (lba)",write_sectors
DEFINE_TEST "read lba switch chs",read_lba_switch_chs
DEFINE_TEST "read chs switch lba",read_chs_switch_lba

DEFINE_TEST "nop (00) (lba)",nop_lba_command
DEFINE_TEST "nop (00) (chs)",nop_command

DEFINE_TEST "request sense (03)",request_sense

DEFINE_TEST "device reset (08) (lba)",device_lba_reset
DEFINE_TEST "device reset (08) (chs)",device_reset

DEFINE_TEST "request sense ext (0b)",request_sense_ext

DEFINE_TEST "recalibrate (1x) (lba)",recalibrate_lba
DEFINE_TEST "recalibrate (1x) (chs)",recalibrate

;; commands
DEFINE_TEST "read sectors (without retry) (20)",read_20_sectors
DEFINE_TEST "read sectors (with retry) (21)",read_21_sectors

DEFINE_TEST "read sectors count (20)",read_20_sectors_count
DEFINE_TEST "read sectors count (21)",read_20_sectors_count

DEFINE_TEST "read long (without retry) (22)",read_22_sectors
DEFINE_TEST "read long (with retry) (23)",read_23_sectors

DEFINE_TEST "write sectors (without retry) (30)",write_30_sectors
DEFINE_TEST "write sectors (with retry) (31)",write_31_sectors


DEFINE_TEST "write sectors count (30)",write_30_sectors_count
DEFINE_TEST "write sectors count (31)",write_31_sectors_count

DEFINE_TEST "write long (without retry) (32)",write_32_sectors
DEFINE_TEST "write long  (with retry) (33)",write_33_sectors

DEFINE_TEST "write verify (3c)",write_3c_sectors


DEFINE_TEST "read verify sectors (without retry) (40)",read_40_sectors
DEFINE_TEST "read verify sectors (with retry) (41)",read_41_sectors

;; TODO: Where H is not 16
DEFINE_TEST "seek (7x)",seek

DEFINE_TEST "execute device diagnostic (90) (lba)",execute_lba_device_diagnostic
DEFINE_TEST "execute device diagnostic (90) (chs)",execute_device_diagnostic
;; DEFINE_TEST "initialize drive parameters (91) (lba)",init_lba_drive_parameters

DEFINE_TEST "initialize drive parameters(91) ",init_drive_parameters


DEFINE_TEST "standby immediate (94)",standby_immediate_94_command

DEFINE_TEST "idle immediate (95)",idle_immediate_95_command

DEFINE_TEST "standby (96)",standby_96_command

DEFINE_TEST "idle (97)",idle_97_command

DEFINE_TEST "check power mode (98)",check_power_mode_9

;;DEFINE_TEST "sleep (99)",sleep_99_command

DEFINE_TEST "identify packet device (a1)", identify_packet_device

;;DEFINE_TEST "set multiple(c6)",set_multiple_command


DEFINE_TEST "standby immediate (e0)",standby_immediate_e0_command

DEFINE_TEST "idle immediate (e1)",idle_immediate_e1_command

DEFINE_TEST "standby (e2)",standby_e2_command

DEFINE_TEST "idle (e3)",idle_e3_command

DEFINE_TEST "read buffer (e4) (lba)",read_lba_buffer
DEFINE_TEST "read buffer (e4) (chs)",read_buffer

DEFINE_TEST "check power mode (e5)",check_power_mode_e

DEFINE_TEST "write buffer (e8) ",write_buffer

DEFINE_TEST "identify device (ec) (lba)", identify_lba_device
DEFINE_TEST "identify device (ec) (chs)", identify_device

DEFINE_TEST "set features (ef) (lba)",set_lba_features
DEFINE_TEST "set features (ef) (chs)",set_features


;; ff,ff,ff,ff,ff,ff,ff,00,ff,ff,ff,ff,ff,ff,f,ff,-0
;;DEFINE_TEST "write buffer (e8) (lba)",write_lba_buffer
;; not working??

;; read sector 

DEFINE_TEST "read native max address (lba) (f8)",read_max_lba_address
DEFINE_TEST "read native max address (chs) (f8)",read_max_address

DEFINE_TEST "set max address (lba) (f9)",set_max_lba_address
DEFINE_TEST "set max address (chs) (f9)",set_max_address
;;DEFINE_TEST "sleep (e6)",sleep_e6_command

if 0



;; 58 = data request
;; ff * 8, 5f,00,00,01,00,00,00,58
;; fail on my drive on sym2 (both maxtor and wd)
;;DEFINE_TEST "read buffer (e4)",read_data_buffer

;;DEFINE_TEST "set max address (lba) (e4)",set_max_lba_address


DEFINE_TEST "set multiple(c6)",set_multiple_command
endif
DEFINE_END_TEST

cmd_read_sector_lba:
defb 1
defb &00
defb &03
defb 0
defb &40
defb &20


cmd_write_sector_lba:
defb 1
defb &00
defb &03
defb 0
defb &40
defb &30


cmd_read_sector_chs:
defb 1
defb &1
defb &1
defb 1
defb &01
defb &20


cmd_write_sector_chs:
defb 1
defb &1
defb &1
defb 1
defb &01
defb &30

res_read_write_lba:
defw &200
defb 0,0,0,3,0,&40,&50
defb &00,&11,&22,&33,&44,&ef,&50
defw &200
defb 0,0,0,3,0,&40,&50
defb &00,&11,&22,&33,&44,&ef,&50
defb 0
defw &200
defb 0,0,0,3,0,&40,&50
defb &00,&11,&22,&33,&44,&ef,&50
defw &200
defb 0,0,0,3,0,&40,&50
defb &00,&11,&22,&33,&44,&ef,&50
defb 0
defb &fe,&00

res_read_max_lba:
defw &0
defw &0
defb &14,&01,&00,&e8,&03,&40,&51 ;; lba
defb &21,&11,&22,&33,&44,&ef,&50
defw &0
defw &0
defb &14,&01,&01,&e8,&03,&40,&51 ;; lba+1
defb &21,&11,&22,&33,&44,&ef,&50
defw &200
defw &0
defb &0,&0,&ff,&e7,&03,&40,&50 ;; lba-1
defb &00,&11,&22,&33,&44,&ef,&50
defw &400
defw &0
defb &14,&0,&00,&e8,&03,&40,&51
defb &21,&11,&22,&33,&44,&ef,&50
defb &fe,&00

read_max_lba:
ld ix,result_buffer
call set_lba

ld hl,(lba+0)
ld de,(lba+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld a,1
ld bc,&fd0a
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(lbaplusone+0)
ld de,(lbaplusone+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld a,1
ld bc,&fd0a
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(lbaminusone+0)
ld de,(lbaminusone+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld a,1	;; lba-1, lba, lba+1
ld bc,&fd0a
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(lbaminustwo+0)
ld de,(lbaminustwo+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld a,3
ld bc,&fd0a
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld ix,result_buffer
ld hl,res_read_max_lba
call copy_results


ld ix,result_buffer
ld bc,18*4
jp simple_results


res_read_max_chs:
defw &0
defw &0
defb &14,&01,&20,&f5,&01,&00,&51
defb &21,&11,&22,&33,&44,&ef,&50
defw &200
defw &0
defb &0,&0,&20,&f3,&01,&00,&50
defb 00,&11,&22,&33,&44,&ef,&50
defw &0
defw &0 
defb &14,&01,&21,&f3,&01,&0f,&51
defb &21,&11,&22,&33,&44,&ef,&50
defw &0
defw &0
defb &14,&03,&20,&f4,&01,&0f,&51
defb &21,&11,&22,&33,&44,&ef,&50
defw &0
defw &0
defb &14,&01,&1f,&f4,&01,&0f,&51
defb &21,&11,&22,&33,&44,&ef,&50
defw &0
defw &0
defb &14,&3,&1e,&f4,&01,&0f,&51
defb &21,&11,&22,&33,&44,&ef,&50
defw &200
defw &0
defb &0,&0,&1f,&f3,&01,&0f,&50
defb &00,&11,&22,&33,&44,&ef,&50

defw &600
defw &0
defb &0,&0,&20,&f3,&01,&0f,&50
defb &00,&11,&22,&33,&44,&ef,&50


defw &0
defw &0
defb &14,&0,&0,&f3,&01,&0f,&51
defb &00,&11,&22,&33,&44,&ef,&50

defb &fe,&00

read_max_chs:
ld ix,result_buffer
call set_lba

;; c invalid
ld hl,(chs+0) ;; cylinders
inc hl
ld a,(chs+2) ;; heads
and &f
ld d,a
ld a,(chs+4) ;; spt

ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,1
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


;; h invalid
ld hl,(chs+0)
dec hl
ld a,(chs+2)
and &f
ld d,a
ld a,(chs+4)
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,1
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


;; s invalid
ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f
ld d,a
ld a,(chs+4)
inc a
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,1
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(chs+0)
ld a,(chs+2)
dec a
and &f
ld d,a
ld a,(chs+4)
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,3
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(chs+0)
ld a,(chs+2)
dec a
and &f
ld d,a
ld a,(chs+4)
dec a
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,1
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense

ld hl,(chs+0)
ld a,(chs+2)
dec a
and &f
ld d,a
ld a,(chs+4)
sub 2
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,3
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f
ld d,a
ld a,(chs+4)
sub 1
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,1
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f
ld d,a
ld a,(chs+4)
sub 2
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,4
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense


ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f
ld d,a
xor a
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,0
ld bc,&fd0a
out (c),a
ld a,&20
ld bc,&fd0f
out (c),a
call do_count_read_data
call ide_request_sense

ld ix,result_buffer
ld hl,res_read_max_chs
call copy_results


ld ix,result_buffer
ld bc,7*18
jp simple_results


read_write_lba:
ld ix,result_buffer
call set_lba

ld hl,write_data_buffer
ld d,0
call fill_buffer_num

ld hl,cmd_write_sector_lba
call ide_write_command
ld hl,write_data_buffer
ld de,512
call ide_write_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

ld hl,cmd_read_sector_lba
call ide_write_command
ld hl,read_data_buffer
ld de,512
call ide_read_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

call compare_read_write_buffers
ld (ix+0),a
inc ix
inc ix


ld hl,write_data_buffer
ld d,128
call fill_buffer_num

ld hl,cmd_write_sector_lba
call ide_write_command
ld hl,write_data_buffer
ld de,512
call ide_write_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

ld hl,cmd_read_sector_lba
call ide_write_command
ld hl,read_data_buffer
ld de,512
call ide_read_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

call compare_read_write_buffers
ld (ix+0),a
inc ix
inc ix


ld ix,result_buffer
ld hl,res_read_write_lba
call copy_results


ld ix,result_buffer
ld bc,19*2
jp simple_results


res_read_write_chs:
defw &200
defb 0,0,1,1,1,1,&50
defb &00,&11,&22,&33,&44,&af,&50
defw &200
defb 0,0,1,1,1,1,&50
defb &00,&11,&22,&33,&44,&af,&50
defb 0
defw &200
defb 0,0,1,1,1,1,&50
defb &00,&11,&22,&33,&44,&af,&50
defw &200
defb 0,0,1,1,1,1,&50
defb &00,&11,&22,&33,&44,&af,&50
defb 0
defb &fe,&00

read_write_chs:
ld ix,result_buffer
call clear_lba


ld hl,write_data_buffer
ld d,0
call fill_buffer_num

ld hl,cmd_write_sector_chs
call ide_write_command
ld hl,write_data_buffer
ld de,512
call ide_write_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

ld hl,cmd_read_sector_chs
call ide_write_command
ld hl,read_data_buffer
ld de,512
call ide_read_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

call compare_read_write_buffers
ld (ix+0),a
inc ix
inc ix


ld hl,write_data_buffer
ld d,128
call fill_buffer_num

ld hl,cmd_write_sector_chs
call ide_write_command
ld hl,write_data_buffer
ld de,512
call ide_write_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

ld hl,cmd_read_sector_chs
call ide_write_command
ld hl,read_data_buffer
ld de,512
call ide_read_data_with_count
call ide_wait_finish
call ide_read_registers
call ide_request_sense

call compare_read_write_buffers
ld (ix+0),a
inc ix
inc ix


ld ix,result_buffer
ld hl,res_read_write_chs
call copy_results


ld ix,result_buffer
ld bc,19*2
jp simple_results

res_read_lba_switch_chs:
defw &200
defw &0
defb &0,&0,0,3,0,&40,&50
defb &0,&0,0,3,0,0,&50
defb &fe,&00

read_lba_switch_chs:
ld ix,result_buffer
call set_lba

ld hl,cmd_read_sector_lba
call ide_write_command
call do_count_read_data

ld bc,&fd0e
in a,(c)
and %10111111
out (c),a
call ide_read_registers

call set_lba


ld ix,result_buffer
ld hl,res_read_lba_switch_chs
call copy_results

ld ix,result_buffer
ld bc,18
jp simple_results


res_read_chs_switch_lba:
defw &200
defw &0
defb &0,0,1,1,1,1,&50
defb &0,0,1,1,1,&41,&50
defb &fe,&00

read_chs_switch_lba:
ld ix,result_buffer
call clear_lba

ld hl,cmd_read_sector_chs
call ide_write_command
call do_count_read_data

ld bc,&fd0e
in a,(c)
or %01000000
out (c),a
call ide_read_registers

call set_lba


ld ix,result_buffer
ld hl,res_read_chs_switch_lba
call copy_results

ld ix,result_buffer
ld bc,18
jp simple_results

;; write sector and then read sector
;; write multiple sectors
;; read multiple sectors
;; read with lba, change lba and see if numbers change (expect not)
;; read with chs, see if reports chs or lba
;; write with chs, read with lba check same data read
;; set max lba, try and read beyond that.

do_results:
push bc
call set_lba
ld ix,result_buffer
pop bc
jp simple_results

res_none:
defw &ffff
defw &ffff
defb &ff,&ff,&ff,&ff,&ff,&ff,&ff
defb &fe,&00

res_nop_lba_command:
defw 0
defw 0
defb &4,&11,&22,&33,&44,&ef,&51
defb &20,&11,&22,&33,&44,&ef,&50
defb &fe,&00

res_nop_command:
defw 0
defw 0
defb &4,&11,&22,&33,&44,&af,&51
defb &20,&11,&22,&33,&44,&af,&50
defb &fe,&00

nop_command:
call clear_lba
xor a
ld hl,res_nop_command
jp command_no_params

nop_lba_command:
call set_lba
xor a
ld hl,res_nop_lba_command
jp command_no_params

res_standby_immediate_e0_command:
res_standby_immediate_94_command:
res_idle_immediate_e1_command:
res_idle_immediate_95_command:
res_standby_96_command:
res_idle_97_command:
res_sleep_99_command:
res_standby_e2_command:
res_idle_e3_command:
res_sleep_e6_command:
defw 0
defw 0
defb &0,&11,&22,&33,&44,&ef,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00

standby_immediate_94_command:
call set_lba
ld a,&94
ld hl,res_standby_immediate_94_command
jp command_no_params


idle_immediate_95_command:
call set_lba
ld a,&95
ld hl,res_idle_immediate_95_command
jp command_no_params

standby_96_command:
ld a,&96
ld hl,res_standby_96_command
jp command_no_params

idle_97_command:
ld a,&97
ld hl,res_idle_97_command
jp command_no_params

check_power_mode_98:
ld a,&98
ld hl,res_check_power_mode_9
jp command_no_params

sleep_99_command:
ld a,&99
ld hl,res_sleep_99_command
jp command_no_params

standby_immediate_e0_command:
ld a,&e0
ld hl,res_standby_immediate_e0_command
jp command_no_params

idle_immediate_e1_command:
ld a,&e1
ld hl,res_idle_immediate_e1_command
jp command_no_params

standby_e2_command:
ld a,&e2
ld hl,res_standby_e2_command
jp command_no_params

idle_e3_command:
ld a,&e3
ld hl,res_idle_e3_command
jp command_no_params

sleep_e6_command:
ld a,&e6
ld hl,res_sleep_e6_command
jp command_no_params


res_device_reset:
defw 0
defw 0
defb &4,&11,&22,&33,&44,&af,&51
defb &20,&11,&22,&33,&44,&af,&50
defb &fe,&00

device_reset:
call clear_lba
ld a,8
ld hl,res_device_reset
jp command_no_params


res_request_sense:
defw 0
defw 0
defb &0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defb &fe,&00

request_sense:
call clear_lba
ld a,&3
ld hl,res_request_sense
jp command_no_params


res_request_sense_ext:
defw 0
defw 0
defb &4,&11,&22,&33,&44,&af,&51
defb &20,&11,&22,&33,&44,&af,&50
defb &fe,&00

request_sense_ext:
call clear_lba
ld a,&b
ld hl,res_request_sense_ext
jp command_no_params


res_device_lba_reset:
defw 0
defw 0
defb &4,&11,&22,&33,&44,&ef,&51
defb &20,&11,&22,&33,&44,&ef,&50
defb &fe,&00

device_lba_reset:
call set_lba
ld a,8
ld hl,res_device_lba_reset
jp command_no_params



res_identify_device:
defw &200
defw &0
defb 0,0,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defb &fe,&00

identify_device:
call clear_lba
ld a,&ec
ld hl,res_identify_device

jp command_no_params


res_identify_packet_device:
defw &0
defw &0
defb 4,&11,&22,&33,&44,&af,&51
defb &20,&11,&22,&33,&44,&af,&50
defb &fe,&00


identify_packet_device:
call clear_lba
ld a,&a1
ld hl,res_identify_packet_device
jp command_no_params


res_identify_lba_device:
defw &200
defw &0
defb 0,0,&22,&33,&44,&ef,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00

identify_lba_device:
call set_lba
ld a,&ec
ld hl,res_identify_lba_device
jp command_no_params

main_command_no_params:
push af
call fill_regs
ld bc,&fd0f
pop af
out (c),a

call do_count_read_data
call ide_request_sense
ret

command_no_params:
push hl
ld ix,result_buffer
call main_command_no_params
pop hl
ld ix,result_buffer
call copy_results
ld bc,11+7
jp do_results

res_init_drive_parameters:
defw &0
defw &0
defb 0,&1e,&22,&33,&44,&04,&50
defw &1f4
defw &0010
defw &0020
defw &06aa
defw &0005
defw &001e
defw &e79c
defw &0003
defw &e800
defw &0003
defb &fe,&00

init_drive_parameters:
call clear_lba
ld ix,result_buffer
call fill_regs
ld a,30		;; set sectors per track
ld bc,&fd0a
out (c),a
ld a,(head_reg)
ld c,a
ld a,4		;; set heads
or c
ld bc,&fd0e
out (c),a
ld a,&91
ld bc,&fd0f
out (c),a

call do_count_read_data
call read_identity_size

ld ix,result_buffer
ld hl,res_init_drive_parameters
call copy_results

ld bc,11+20
jp do_results


res_execute_device_diagnostic:
defw &0
defw &0
defb 1,1,1,0,0,0,&50
defb &0,&11,&22,&33,&44,&af,&50
defb &fe,&00

execute_device_diagnostic:
call clear_lba
ld a,&90
ld hl,res_execute_device_diagnostic
jp command_no_params

res_execute_lba_device_diagnostic:
defw &0
defw &0
defb 1,1,1,0,0,0,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00

execute_lba_device_diagnostic:
call set_lba
ld a,&90
ld hl,res_execute_lba_device_diagnostic
jp command_no_params

res_read_buffer:
defw &200
defw &0
defb 0,0,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defb &fe,&00

read_buffer:
call clear_lba
ld a,&e4
ld hl,res_read_buffer
jp command_no_params


check_power_mode_e:
call clear_lba
jp cm_check_power_mode_e

check_lba_power_mode:
call set_lba
jp cm_check_power_mode_e


res_check_power_mode_e:
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&ff,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&ff,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&0,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&0,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defb &fe,&00

cm2_check_power_mode_e:
call main_command_no_params
ld a,&e5
call main_command_no_params
ret


cm_check_power_mode_e:
ld ix,result_buffer

ld a,&e1	;; idle immediate
call cm2_check_power_mode_e
ld a,&e3	;; idle
call cm2_check_power_mode_e
ld a,&e0	;; standby immediate
call cm2_check_power_mode_e
ld a,&e2	;; standby
call cm2_check_power_mode_e
;;ld a,&e6	;; sleep
;;call cm2_check_power_mode_e

ld ix,result_buffer
ld hl,res_check_power_mode_e
call copy_results

ld bc,10*5*2
jp do_results

;; 5f = ff
res_check_power_mode_9:
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&ff,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&ff,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&11,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&0,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&ff,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defw &0
defw &0
defb 0,&0,&22,&33,&44,&af,&50
defb &0,&11,&22,&33,&44,&af,&50
defb &fe,&00


check_power_mode_9:
call clear_lba
jp cm_check_power_mode_9

check_lba_power_mode_9:
call set_lba
jp cm_check_power_mode_9

cm2_check_power_mode_9:
call main_command_no_params
ld a,&98
call main_command_no_params
ret


cm_check_power_mode_9:
ld ix,result_buffer

ld a,&95	;; idle immediate
call cm2_check_power_mode_9
ld a,&97	;; idle
call cm2_check_power_mode_9
ld a,&94	;; standby immediate
call cm2_check_power_mode_9
ld a,&96	;; standby
call cm2_check_power_mode_9
;;ld a,&99	;; sleep
;;call cm2_check_power_mode_9


ld ix,result_buffer
ld hl,res_check_power_mode_9
call copy_results

ld bc,8*11
jp do_results


res_read_lba_buffer:
defw &200
defw &0
defb 0,0,&22,&33,&44,&ef,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00


read_lba_buffer:
call set_lba
ld a,&e4
ld hl,res_read_lba_buffer
jp command_no_params


res_write_buffer:
defw &200
defb  &00,&00,&22,&33,&44,&ef,&50
defw &200
defb  &00,&00,&22,&33,&44,&ef,&50
defb &00
defb &fe,&00


write_buffer:
ld ix,result_buffer
call fill_regs

ld hl,data_buffer
ld bc,512
ld d,0
wb1:
ld (hl),d
inc hl
dec bc
inc d
ld a,b
or c
jr nz,wb1

ld a,&e8
ld bc,&fd0f
out (c),a

ld hl,data_buffer
ld de,512
call ide_write_data_with_count
call ide_wait_finish
call ide_read_registers

call fill_regs
ld a,&e4
ld bc,&fd0f
out (c),a

ld hl,data_buffer
ld de,512
call ide_read_data_with_count
call ide_wait_finish
call ide_read_registers


ld hl,data_buffer
ld bc,512
ld d,0
wb2:
ld a,(hl)
cp d
ld a,1
jr nz,wb3
inc hl
dec bc
inc d
ld a,b
or c
jr nz,wb2
xor a
wb3:
ld (ix+0),a
inc ix
inc ix

ld hl,res_write_buffer
ld ix,result_buffer
call copy_results

ld bc,27
jp do_results

res_recalibrate:
defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &00,&11,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&af,&50

defb &fe,&00


;; send all possible recalibrate values
recalibrate:
call clear_lba
ld hl,res_recalibrate
jp recal_common

res_recalibrate_lba:
defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &fe,&00

recalibrate_lba:
call set_lba
ld hl,res_recalibrate_lba
jr recal_common

recal_common:
push hl

ld ix,result_buffer
ld b,16
xor a
rec:
push bc
push af
push af
call fill_regs
pop af

or &10
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense

pop af
inc a
pop bc
djnz rec
pop hl
ld ix,result_buffer
call copy_results

ld bc,16*14
jp do_results

res_seek:
defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&00,&00,&00,&e0,&50
defb &00,&11,&22,&33,&44,&ef,&50
;;;

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

defb &00,&11,&01,&00,&00,&00,&50
defb &00,&11,&22,&33,&44,&ef,&50

;;
defb &14,&11,&00,&e8,&03,&40,&51 ;; lba 
defb &21,&11,&22,&33,&44,&ef,&50

defb &14,&11,&01,&e8,&03,&40,&51 ;; lba plus one
defb &21,&11,&22,&33,&44,&ef,&50

defb &00,&11,&ff,&e7,&03,&40,&50 ;; lba minus one
defb &00,&11,&22,&33,&44,&ef,&50

defb &14,&11,&20,&f5,&01,&00,&51 ;; c invalid
defb &21,&11,&22,&33,&44,&ef,&50

defb &00,&11,&20,&f3,&01,&01,&50 ;; h invalid
defb &00,&11,&22,&33,&44,&ef,&50

defb &14,&11,&21,&f3,&01,&0f,&51 ;; s invalid
defb &21,&11,&22,&33,&44,&ef,&50

defb &14,&11,&00,&f3,&01,&0f,&51 ;; s invalid (0)
defb &21,&11,&22,&33,&44,&ef,&50

defb &00,&11,&20,&f3,&01,&0f,&50 ;; chs valid
defb &00,&11,&22,&33,&44,&ef,&50



defb &fe,&00

seek:
ld ix,result_buffer

;; lba valid all
ld d,16
ld e,0
s1:
push de
push de
call fill_regs
ld hl,0
ld de,0
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld bc,&fd0e
in a,(c)
and &f0
or &40
or d
out (c),a
pop de
ld a,e
or &70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense
pop de
inc e
dec d
jr nz,s1


;; chs valid all
ld d,16
ld e,0
s2:
push de
push de
call fill_regs
ld hl,0
ld d,1
ld e,0
ld bc,&fd0e
out (c),e
ld bc,&fd0b
out (c),d
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
pop de
ld a,e
or &70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense
pop de
inc e
dec d
jr nz,s2


;; lba invalid
call fill_regs

ld hl,(lba+0)
ld de,(lba+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense

;; lba invalid
call fill_regs

ld hl,(lbaplusone+0)
ld de,(lbaplusone+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense


;; lba invalid
call fill_regs

ld hl,(lbaminusone+0)
ld de,(lbaminusone+2)
ld bc,&fd0e
ld a,d
or &40
out (c),a
ld bc,&fd0b
out (c),l
ld bc,&fd0c
out (c),h
ld bc,&fd0d
out (c),e
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense

;; c invalid
call fill_regs
ld hl,(chs+0)
inc hl
ld a,(chs+2)
and &f
ld d,a
ld a,(chs+4)
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense


;; h invalid
call fill_regs
ld hl,(chs+0)
dec hl
ld a,(chs+2)
inc a
and &f

ld d,a
ld a,(chs+4)
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense


;; s invalid
call fill_regs
ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f

ld d,a
ld a,(chs+4)
inc a
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense


;; s invalid
call fill_regs
ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f

ld d,a
xor a
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense


;; s invalid
call fill_regs
ld hl,(chs+0)
dec hl
ld a,(chs+2)
dec a
and &f

ld d,a
ld a,(chs+4)
ld bc,&fd0e
out (c),d
ld bc,&fd0b
out (c),a
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld a,&70
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers
call ide_request_sense


ld hl,res_seek
ld ix,result_buffer
call copy_results

ld bc,14*(32+8)
jp do_results

;;ld ix,result_buffer
;;ld bc,28*(32+8)
;;ld d,14
;;jp simple_number_grid


read_multiple:
ld a,%00000
ld bc,&fd0e
out (c),a
;; set sectors per block
ld bc,&fd0a
out (c),a
ld a,&c6
ld bc,&fd0f
out (c),a

ld bc,&fd0f
in a,(c)

ld ix,result_buffer
ld hl,cmd_stat_read_sectors
call ide_write_command
call do_count_read_data
ret



set_multiple_command:
ld ix,result_buffer
ld b,0
xor a
smc:
push bc
push af

push af
push af
ld a,%00000
ld bc,&fd0e
out (c),a
pop af
;; set sector count
ld bc,&fd0a
out (c),a
ld a,&c6
ld bc,&fd0f
out (c),a
call ide_wait_finish
call ide_read_registers

;;call do_identify_device
ld hl,data_buffer+(59*2)
ld a,(hl)		;; sector count from ident
ld (ix+0),a
inc ix
pop af
ld (ix+1),a
inc ix
inc hl
ld a,(hl)		;; valid from ident
ld (ix+0),a
inc ix
ld (ix+0),%10000000	
inc ix

pop af
inc a
pop bc
djnz smc

ld bc,256*(16+2)
jp do_results


;; read 1 sector
cmd_stat_read_sectors:
defb 1
defb 0
defb 0
defb 0
defb &40
defb &20


res_set_features:
defw &0
defw &0
defb 0,0,&22,&33,&44,&af,&50
defb &00,&11,&22,&33,&44,&ef,&50
defb &fe,&00

set_features:
call clear_lba
ld hl,res_set_features
jr cm_set_features


res_set_lba_features:
defw &0
defw &0
defb 0,0,&22,&33,&44,&ef,&50
defb &00,&11,&22,&33,&44,&ef,&50
defb &fe,&00


set_lba_features:
call set_lba
ld hl,res_set_lba_features
jr cm_set_features

cm_set_features:
push hl
call fill_regs

ld ix,result_buffer

ld a,3
ld bc,&fd09
out (c),a

ld bc,&fd0a
xor a
out (c),a
ld a,&ef
ld bc,&fd0f
out (c),a
call do_count_read_data
pop hl
ld ix,result_buffer
call copy_results

ld bc,11
jp do_results



srs_port:
defw 0


cmd_read_sectors:
defb 1
defb 0
defb 0
defb 0
defb &40
defb &20

cmd_write_sectors:
defb 1
defb 0
defb 0
defb 0
defb &40
defb &30

res_set_max_address:
defw 0
defw 0
defb &4,&0,4,&0,&00,&af,&51
defw 0
defw 0
defb &4,&11,&22,&33,&44,&af,&51
defw &01f4
defw &0010
defw &0020
defw &06aa
defw &0005
defw &001e
defw &e79c
defw &0003
defw &e800
defw &0003
defw &0000
defb &fe,&00

set_max_address:
call clear_lba

ld ix,result_buffer
call fill_regs
ld hl,&0000	;; cylinder
ld d,&3
ld e,4

ld a,0
ld bc,&fd0a
out (c),a
ld bc,&fd0b
out (c),e
ld bc,&fd0c
out (c),l
ld bc,&fd0d
out (c),h
ld bc,&fd0e
in a,(c)
or d
out (c),a
ld a,&f9
ld bc,&fd0f
out (c),a

call do_count_read_data
call fill_regs

ld a,&f8
ld bc,&fd0f
out (c),a
call do_count_read_data

call read_identity_size

ld ix,result_buffer
ld hl,res_set_max_address
call copy_results

ld bc,42
jp do_results

res_set_max_lba_address:
defw 0
defw 0
defb &4,&0,0,&80,&00,&ef,&51
defw 0
defw 0
defb &4,&11,&22,&33,&44,&ef,&51
defw &01f4
defw &0010
defw &0020
defw &06aa
defw &0005
defw &001e
defw &e79c
defw &0003
defw &e800
defw &0003
defw &0000
defb &fe,&00

set_max_lba_address:
call set_lba

ld ix,result_buffer
call fill_regs
ld hl,&0000
ld de,&8000

ld a,0
ld bc,&fd0a
out (c),a
ld bc,&fd0b
out (c),e
ld bc,&fd0c
out (c),d
ld bc,&fd0d
out (c),l
ld bc,&fd0e
in a,(c)
or h
out (c),a
ld a,&f9
ld bc,&fd0f
out (c),a

call do_count_read_data

call fill_regs

ld a,&f8
ld bc,&fd0f
out (c),a
call do_count_read_data

call read_identity_size

ld ix,result_buffer
ld hl,res_set_max_lba_address
call copy_results

ld bc,42

jp do_results


res_read_max_lba_address:
defw &0
defw &0
defb &4,&11,&22,&33,&44,&ef,&51
defw &01f4
defw &0010
defw &0020
defw &06aa
defw &0005
defw &001e
defw &e79c
defw &0003
defw &e800
defw &0003
defb &fe,&00


read_max_lba_address:
call set_lba

ld ix,result_buffer
call fill_regs

ld a,&f8
ld bc,&fd0f
out (c),a
call do_count_read_data


call read_identity_size

ld ix,result_buffer
ld hl,res_read_max_lba_address
call copy_results

ld bc,20+11
jp do_results

read_16bit_value:
ld e,(hl)
inc hl
ld d,(hl)
inc hl
ld (ix+0),e
ld (ix+2),d
inc ix
inc ix
inc ix
inc ix
ret

;; 1,3,6,54,55,56,57,58,60,61
read_identity_size:
call ide_identify_device
ld hl,read_data_buffer+(1*2)
call read_16bit_value
ld hl,read_data_buffer+(3*2)
call read_16bit_value
ld hl,read_data_buffer+(6*2)
call read_16bit_value
ld hl,read_data_buffer+(54*2)
call read_16bit_value
ld hl,read_data_buffer+(55*2)
call read_16bit_value
ld hl,read_data_buffer+(56*2)
call read_16bit_value
ld hl,read_data_buffer+(57*2)
call read_16bit_value
ld hl,read_data_buffer+(58*2)
call read_16bit_value
ld hl,read_data_buffer+(60*2)
call read_16bit_value
ld hl,read_data_buffer+(61*2)
call read_16bit_value
ret



if 0
set_features:

ld ix,result_buffer

ld bc,&fd0e
ld a,0
out (c),a

ld a,3
ld bc,&fd09
out (c),a

ld bc,&fd0a
xor a
out (c),a
call ide_wait_execution

call ide_read_registers

ld bc,16
jp do_results

endif


res_read_max_address:
defw &0
defw &0
defb &4,&11,&22,&33,&44,&af,&51
defw &01f4
defw &0010
defw &0020
defw &06aa
defw &0005
defw &001e
defw &e79c
defw &0003
defw &e800
defw &0003
defb &fe,&00

read_max_address:
call clear_lba

ld ix,result_buffer
call fill_regs

ld a,&f8
ld bc,&fd0f
out (c),a
call do_count_read_data

call read_identity_size

ld ix,result_buffer
ld hl,res_read_max_address
call copy_results
ld bc,20+11

jp do_results


res_read_20_sectors_count:
res_read_21_sectors_count:
defw &00
defw &2
defb &0,&0,&ff,&0,&0,&40,&50
defw &200
defw &0
defb &0,&0,&0,&0,&0,&40,&50
defw &400
defw &0
defb &0,&0,&1,&0,&0,&40,&50
defw &600
defw &0
defb &0,&0,&2,&0,&0,&40,&50
defw &800
defw &0
defb &0,&0,&3,&0,&0,&40,&50
defw &a00
defw &0
defb &0,&0,4,&0,&0,&40,&50
defw &c00
defw &0
defb &0,&0,5,&0,&0,&40,&50
defw &e00
defw &0
defb &0,&0,6,&0,&0,&40,&50
defw &1000
defw &0
defb &0,&0,7,&0,&0,&40,&50
defw &1200
defw &0
defb &0,&0,8,&0,&0,&40,&50
defw &1400
defw &0
defb &0,&0,9,&0,&0,&40,&50
defw &1600
defw &0
defb &0,&0,&a,&0,&0,&40,&50
defw &1800
defw &0
defb &0,&0,&b,&0,&0,&40,&50
defw &1a00
defw &0
defb &0,&0,&c,&0,&0,&40,&50
defw &1c00
defw &0
defb &0,&0,&d,&0,&0,&40,&50
defw &1e00
defw &0
defb &0,&0,&e,&0,&0,&40,&50
defb &fe,&00



read_20_sectors_count:
ld a,&20
ld hl,res_read_20_sectors_count
jr read_sectors_count

read_21_sectors_count:
ld a,&21
ld hl,res_read_21_sectors_count
jr read_sectors_count

;; get status during command and get results 
read_sectors_count:
push hl
ld (cmd_read_sectors+5),a
ld ix,result_buffer
ld b,16
ld a,0
rsc:
push bc
push af
ld (cmd_read_sectors+0),a
ld a,b
call outputdec
ld a,' '
call output_char

ld hl,cmd_read_sectors
call ide_write_command

call do_count_read_data
pop af
pop bc
inc a
djnz rsc



ld ix,result_buffer
pop hl
call copy_results

ld bc,16*11
jp do_results



res_write_30_sectors_count:
res_write_31_sectors_count:
defw &00
defw &2
defb &0,&0,&ff,&0,&0,&40,&50
defw &200
defw &0
defb &0,&0,&0,&0,&0,&40,&50
defw &400
defw &0
defb &0,&0,&1,&0,&0,&40,&50
defw &600
defw &0
defb &0,&0,&2,&0,&0,&40,&50
defw &800
defw &0
defb &0,&0,&3,&0,&0,&40,&50
defw &a00
defw &0
defb &0,&0,4,&0,&0,&40,&50
defw &c00
defw &0
defb &0,&0,5,&0,&0,&40,&50
defw &e00
defw &0
defb &0,&0,6,&0,&0,&40,&50
defw &1000
defw &0
defb &0,&0,7,&0,&0,&40,&50
defw &1200
defw &0
defb &0,&0,8,&0,&0,&40,&50
defw &1400
defw &0
defb &0,&0,9,&0,&0,&40,&50
defw &1600
defw &0
defb &0,&0,&a,&0,&0,&40,&50
defw &1800
defw &0
defb &0,&0,&b,&0,&0,&40,&50
defw &1a00
defw &0
defb &0,&0,&c,&0,&0,&40,&50
defw &1c00
defw &0
defb &0,&0,&d,&0,&0,&40,&50
defw &1e00
defw &0
defb &0,&0,&e,&0,&0,&40,&50
defb &fe,&00

write_30_sectors_count:
ld a,&30
ld hl,res_write_30_sectors_count
jr write_sectors_count

write_31_sectors_count:
ld a,&31
ld hl,res_write_31_sectors_count
jr write_sectors_count

write_sectors_count:
push hl
ld (cmd_write_sectors+5),a
ld ix,result_buffer
ld b,16
ld a,0
wsc:
push bc
push af
ld (cmd_write_sectors+0),a
ld a,b
call outputdec
ld a,' '
call output_char

ld hl,cmd_write_sectors
call ide_write_command

call do_count_write_data
pop af
pop bc
inc a
djnz wsc



ld ix,result_buffer
pop hl
call copy_results

ld bc,16*11
jp do_results

res_read_21_sectors:
res_read_20_sectors:
defw &200
defw &00
defb &0,&0,&0,&0,&0,&40,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00

res_read_40_sectors:
res_read_41_sectors:
defw &0
defw &00
defb &0,&1,&0,&0,&0,&40,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00


res_read_22_sectors:
res_read_23_sectors:
defw &200	;;??? not 4
defw &00
defb &0,&0,&0,&0,&0,&40,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00

read_20_sectors:
ld a,&20 ;; read sectors with retry
ld hl,res_read_20_sectors
jr read_sectors

read_21_sectors:
ld a,&21 ;; read sectors without retry
ld hl,res_read_21_sectors
jr read_sectors

read_40_sectors:
ld a,&40	;; read verify sectors with retry
ld hl,res_read_40_sectors
jr read_sectors

read_41_sectors:
ld a,&41	;; read verify sectors without retry
ld hl,res_read_41_sectors
jr read_sectors


read_22_sectors:
ld a,&22 ;; read long with retry
ld hl,res_read_22_sectors
jr read_sectors

read_23_sectors:
ld a,&23 ;; read long without retry
ld hl,res_read_23_sectors
jr read_sectors

read_sectors:
push hl
ld (cmd_read_sectors+5),a
ld a,1
ld (cmd_read_sectors+0),a

ld ix,result_buffer

ld hl,cmd_read_sectors
call ide_write_command

call do_count_read_data
call ide_request_sense

ld ix,result_buffer
pop hl
call copy_results

ld bc,18
jp do_results


res_write_30_sectors:
res_write_31_sectors:
res_write_3c_sectors:
defw &200
defw &00
defb &0,&0,&0,&0,&0,&40,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00

res_write_32_sectors:
res_write_33_sectors:
defw &0
defw &00
defb &0,&1,&0,&0,&0,&40,&50
defb &0,&11,&22,&33,&44,&ef,&50
defb &fe,&00


res_write_e9_sectors:
defw &0
defw &00
defb &4,&1,&0,&0,&0,&40,&51
defb &20,&11,&22,&33,&44,&ef,&50
defw &0
defw &00
defb &4,&1,&0,&0,&0,&40,&51
defb &20,&11,&22,&33,&44,&ef,&50
defw &0
defw &00
defb &4,&1,&0,&0,&0,&40,&51
defb &20,&11,&22,&33,&44,&ef,&50
defb &fe,&00


write_30_sectors:
ld a,&30 ;; read sectors with retry
ld hl,res_write_30_sectors
jr write_sectors

write_31_sectors:
ld a,&31 ;; read sectors without retry
ld hl,res_write_31_sectors
jr write_sectors

write_3c_sectors:
ld a,&3c	;; write verify
ld hl,res_write_3c_sectors
jr write_sectors


write_32_sectors:
ld a,&32 ;; read long with retry
ld hl,res_write_32_sectors
jr write_sectors

write_33_sectors:
ld a,&33 ;; read long without retry
ld hl,res_write_33_sectors
jr write_sectors

write_sectors:
push hl
ld (cmd_write_sectors+5),a
ld a,1
ld (cmd_write_sectors+0),a

ld ix,result_buffer

ld hl,cmd_write_sectors
call ide_write_command

call do_count_write_data
call ide_request_sense

ld ix,result_buffer
pop hl
call copy_results

ld bc,18
jp do_results


;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/outputdec.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "idecommon.asm"


result_buffer: equ $

end start
