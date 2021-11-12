;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../../lib/testdef.asm"

;; TODO: device reset before start it all
;; TODO: Master/Slave combinations
;; TODO: Power on test
;; TODO: /EXP ?
;; TODO: Responds to reset port?
;; TODO: Changes IM 2 vector
;; TODO: Forces data for unmapped port?

;; IDE device tester
org &8000
start:
ld hl,copy_result_fn
ld (cr_functions),hl

call cls
ld hl,intro_message
call output_msg
call wait_key

call cls

;; choose device
ld hl,choose_ide_message
call output_msg
call wait_key
cp '0'
ld c,0
jr z,dev1
ld c,1
dev1:
ld a,c
ld (ide_device),a

;; master drive only, master drive jumper set to 'master with slave' or 'master'
ld a,1
ld (drive_config),a

ld a,(ide_device)
or a
call nz,set_defaults

;; needs testing
ld a,(ide_device)
or a
jr nz,dev2
call cls
ld hl,choose_drive_message
call output_msg
call wait_key
sub '0'
ld (drive_config),a

dev2:

call cls
ld ix,tests
call run_tests
call wait_key
ret

ide_device:
defb 0

drive_config:
defb 0


intro_message:
defb "IDE Device Tester",13,13
defb "This program supports Symbiface 2 and X-MASS interfaces.",13,13
defb "This program has been tested on these devices.",13,13
defb "Please attach one of these devices to your CPC and please attach",13
defb "zero or more IDE drives. You will be able to choose a drive",13
defb "configuration to test against.",13,13
defb "This test has NOT been tested on other IDE interfaces (e.g. uIDE16)",13,13
defb "Press any key to continue",13,13
defb 0

choose_ide_message:
defb "Please choose IDE device to test:",13,13
defb "0: Symbiface 2",13,13
defb "1: X-MASS",13,13
defb 0

choose_drive_message:
defb "Please choose drive configuration:",13,13
defb "0: None (no master or slave drive connected)",13,13
defb "1: Master drive only",13
defb "    Master drive jumper set to 'Master with slave present'",13
defb "    (or also called 'Master')",13,13
defb "2: Slave drive only",13
defb "    Slave drive jumper set to 'Slave'",13,13
defb "3: Master drive and Slave drive",13
defb "    Master drive jumper set to 'Master with slave present'",13
defb "    (or also called 'Master') OR set to 'Master/Single'",13
defb "    Slave drive jumper set to 'Slave'",13,13
defb "4: Master drive only",13
defb "    Master drive jumper set to 'Master/Single'",13
defb "    (jumper seen on WD HD drives)",13,13
defb 0


;;-----------------------------------------------------
;; x-mass seems to be broken?

tests:
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD09)",sym2_wfd09_read_sector

;;DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD08)",sym2_wfd08_read_sector

;; x-mass needs "warm up" to be able to read/write the registers???
;; or does the x-mass device cache the information??
;; slave only ff x 16
;; then 10,ff,11,ff etc
;; x-mass has 0 x 256 then ff x 256
DEFINE_TEST "Head reg (switching dev)",sw_head_all

DEFINE_TEST "Sector reg count (all values)",sec_count_all
DEFINE_TEST "Sector reg number (all values)",sec_num_all
DEFINE_TEST "Cylinder low reg  (all values)",cyl_low_all
DEFINE_TEST "Cylinder high reg (all values)",cyl_high_all
DEFINE_TEST "Head reg (all values)",head_all
DEFINE_TEST "Sector reg count (switching dev)",sw_sec_count_all
DEFINE_TEST "Sector reg number (switching dev)",sw_sec_num_all
DEFINE_TEST "Cylinder low reg  (switching dev)",sw_cyl_low_all
DEFINE_TEST "Cylinder high reg (switching dev)",sw_cyl_high_all

;; d0 x 9, then actual byte
;;DEFINE_TEST "read busy after write (fd08)",busy_fd08
;;DEFINE_TEST "read busy after write (fd09)",busy_fd09
;;DEFINE_TEST "read busy after write (fd0a)",busy_fd0a
;;DEFINE_TEST "read busy after write (fd0b)",busy_fd0b
;;DEFINE_TEST "read busy after write (fd0c)",busy_fd0c
;;DEFINE_TEST "read busy after write (fd0d)",busy_fd0d
;;DEFINE_TEST "read busy after write (fd0e)",busy_fd0e
;;DEFINE_TEST "read busy after write (fd0f)",busy_fd0f

;;DEFINE_TEST "device control reg (Symbiface 2)",device_control_reg
;;DEFINE_TEST "drive address reg (Symbiface 2)",drive_address_reg



DEFINE_TEST "X-Mass '16-bit' data",xmass_read_16bit_sector



;; ff on all
;;DEFINE_TEST "Drive address (all values) (Symbiface 2)",drive_address_all

;;DEFINE_TEST "Drive head/address (all values)",drive_head_address_all



DEFINE_TEST "alternative status register (Symbiface 2)",alt_status_reg


;; hang
;;DEFINE_TEST "Symbiface 2 data (FD06)",sym2_fd06_read_sector
;; ok
;; 0,4,0,0,0,0,0,40,50
;; got 0e,ff etc
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD07)",sym2_fd07_read_sector
;; ok
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD08)",sym2_fd08_read_sector
;; 0,4,0,0,0,0,0,40,50
;; 0,1,0,2,0,3,etc
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD09)",sym2_fd09_read_sector
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD0a)",sym2_fd0a_read_sector
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD0b)",sym2_fd0b_read_sector
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD0c)",sym2_fd0c_read_sector
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD0d)",sym2_fd0d_read_sector
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD0e)",sym2_fd0e_read_sector
DEFINE_TEST "Symbiface 2 read sector (read fd08 then FD0f)",sym2_fd0f_read_sector
;; HANG
;;DEFINE_TEST "Symbiface 2 data (FD0d only)",sym2_fd0d_read2_sector
;;DEFINE_TEST "Symbiface 2 data (FD0e only)",sym2_fd0e_read2_sector
;;DEFINE_TEST "Symbiface 2 data (FD0f only)",sym2_fd0f_read2_sector

;; hang
;;DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD07)",sym2_wfd07_read_sector
;; 0,4,0,0,0,0,0,40,50
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD08)",sym2_wfd08_read_sector
;; 0,4,0,0,0,0,0,40,50
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD09)",sym2_wfd09_read_sector
;; 0,4,0,0,0,0,0,40,50
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD0a)",sym2_wfd0a_read_sector
;; 0,4,0,0,0,0,0,40,50
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD0b)",sym2_wfd0b_read_sector
;; 0,4,0,0,0,0,0,40,50
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD0c)",sym2_wfd0c_read_sector
;; 0,4,0,0,0,0,0,40,50
DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD0d)",sym2_wfd0d_read_sector
;; changes drive, but succeeds 
;; 0,2,0,0,0,0,0,0,50
;;DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD0e)",sym2_wfd0e_read_sector
;; forces new command
;; 2,0,4,0,0,0,0,0,40,50 
;;DEFINE_TEST "Symbiface 2 read sector (read fd08 then write FD0f)",sym2_wfd0f_read_sector


;; all cause hangs

;; on x-mass:
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD07)",sym2_rfd07_write_sector
;; ok
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD08)",sym2_rfd08_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD09)",sym2_rfd09_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD0a)",sym2_rfd0a_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD0b)",sym2_rfd0b_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD0c)",sym2_rfd0c_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD0d)",sym2_rfd0d_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD0e)",sym2_rfd0e_write_sector
;; 0,4,0,0,0,0,0,40,50
;;DEFINE_TEST "Symbiface 2 write sector (write fd08 then read FD0f)",sym2_rfd0f_write_sector


;; pass
;;DEFINE_TEST "Symbiface 2 data (read data reg once before data)",sym2_read2b_sector

;; depends on device if it supports it or not.
;; wd 100 data, 01,02,03,04,05 etc
;;DEFINE_TEST "Symbiface '8-bit' data",sym_read_8bit_sector

;; hang on symbiface 2
DEFINE_TEST "IDE I/O decode",ide_io_decode
DEFINE_END_TEST


ide_io_decode:
ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped

ld hl,&fd0a
ld de,&ffff
ld a,(ide_device)
or a
jr nz,iid
ld hl,&fd0a
ld de,&ffff
iid:
ld bc,ide_io_restore
ld ix,ide_dec_test
ld iy,ide_dec_init
jp io_decode

ide_io_restore:
ld bc,&7f00+%10001100
out (c),c
ld bc,&fd17
out (c),c
ld bc,&fd11
in a,(c)
ld bc,&df00
out (c),c

ide_dec_init:
xor a
ld bc,&fd0e
out (c),a
ret


ide_dec_test:
push bc
ld bc,&7f00+%10001100
out (c),c
ld bc,&fd17
out (c),c
ld bc,&fd11
in a,(c)
ld bc,&df00
out (c),c

ld bc,&fd0e
xor a
out (c),a
ld a,&33
ld bc,&fd0a
out (c),a
pop bc
in a,(c)
cp &33
ret

;; TODO: check drive select
drive_head_address_all:
ld a,(ide_device)
or a
jp nz,report_skipped

ld ix,result_buffer
ld a,%00000
ld bc,&fd0e
out (c),a
ld bc,&fd07
ld e,&fe		;; master and slave returns ff
call byteall
ld a,%10000
ld bc,&fd0e
out (c),a
ld bc,&fd07
ld e,&fd
call byteall
ld ix,result_buffer
ld bc,512
jp simple_results

hizall:
ld e,&ff
jr byteall

byteall:
ld d,0
xor a
fdfe_all2s:
push af
out (c),a
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),e
inc ix
pop af
inc a
dec d
jr nz,fdfe_all2s
ret

fdhi_all:
ld ix,result_buffer

push bc
ld a,%00000
ld bc,&fd0e
out (c),a
pop bc

call hizall

push bc
ld a,%10000
ld bc,&fd0e
out (c),a
pop bc
call hizall

ld ix,result_buffer
ld bc,512
jp simple_results


drive_address_all:
ld a,(ide_device)
or a
jp nz,report_skipped

ld ix,result_buffer

ld d,0
ld e,0
dal:
ld bc,&fd0e
out (c),e
ld bc,&fd07
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc e
dec d
jr nz,dal

ld ix,result_buffer
ld bc,256
jp simple_results

data_all:
;; x-mass
ld ix,result_buffer
ld a,%00000
ld bc,&fd0e
out (c),a
;; seems unmapped on x-mass?
;; data seems to be all the same on x-mass
ld bc,&fd08
in h,(c)	;; read initial value
ld d,0
ld e,0
da1:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
ld (ix+0),h	;; same value all the time
inc ix
inc e
dec d
jr nz,da1
ld a,(ide_device)
or a
jr z,da2
ld ix,result_buffer
ld (ix+1),0
ld (ix+3),0
ld (ix+5),0
;; rest are FF On symbiface 2 - TODO
;; no, not with slave they are not
da2:
ld a,%10000
ld bc,&fd0e
out (c),a

ld bc,&fd08
call hizall

ld ix,result_buffer
ld bc,512
jp simple_results

head_all:
ld bc,&fd0e
ld ix,result_buffer
ld d,0
ld e,0
ha:
out (c),e
in a,(c)
ld (ix+0),a
inc ix
inc ix
inc e
dec d
jr nz,ha

ld ix,result_buffer
ld d,0
ld e,0
ha2:
ld (ix+1),e

ld a,(drive_config)
or a
jr z,ha55
cp 1
jr nz,ha4
bit 4,e		;; accessing master/slave?
jr z,ha56	;; accessing master
jr ha55
ha4:
cp 2		;; slave only
jr nz,ha5
bit 4,e		;; accessing master/slave?
jr nz,ha56 ;; accessing slave
;; accessing master
jr ha55	
ha5:
cp 3		;; master and slave
jr nz,ha6
;; accessing master or slave
jr ha56
ha6:
;; master/single
jr ha56
ha55:
ld (ix+1),&ff
ha56:
inc ix
inc ix
inc e
dec d
jr nz,ha2

ld ix,result_buffer
ld bc,256
jp simple_results


alt_status:
ld bc,&fd0e
out (c),a

asr2:
ld h,0
asr1:
ld (ix+1),1

ld bc,&fd0f
in e,(c)
ld bc,&fd06
in d,(c)

ld a,e
cp &ff
jr nz,asr3b
ld a,d
cp &ff
jr nz,asr3b
ld (ix+0),&ff
ld (ix+1),&ff
jr asr3a

asr3b:
ld a,e
cp d
ld a,1
jr z,asr3
xor a
asr3:
ld (ix+0),a
asr3a:
inc ix
inc ix
dec h
jr nz,asr1
ret

ff_result:
push bc
ld b,0
ff_r1:
ld (ix+1),&ff
inc ix
inc ix
djnz ff_r1
pop bc
ret

keep_result:
push bc
ld b,0
ff_r2:
inc ix
inc ix
djnz ff_r2
pop bc
ret

drive_config_set_result:
ld e,a
ld a,(drive_config)
or a
jr z,ff_result	;; neither connected
cp 1		;; master only
jr nz,nf2
bit 4,e		;; accessing slave?
jr nz,ff_result
jr keep_result
nf2:
cp 2		;; slave only
jr nz,nf3
bit 4,e		;; accessing master
jr z,ff_result
jr keep_result
nf3:
cp 3		;; master and slave
jr nz,nf4
jr keep_result
nf4:
;; master/single
jr keep_result


drive_head_config_set_result:
ld d,0
ld e,0
dhcsr:
ld a,(drive_config)
or a
jr z,dhcsr2	;; neither connected
cp 1
jr nz,nf2dhc
bit 4,e		;; accessing slave?
jr nz,dhcsr2
jr dhcsr3
nf2dhc:
cp 2		;; slave only
jr nz,nf3dhc
bit 4,e		;; accessing master
jr z,dhcsr2
jr dhcsr3
nf3dhc:
cp 3		;; master and slave
jr nz,nf4dhc
jr dhcsr3
nf4dhc:
;; master/single
jr dhcsr3

dhcsr2:
ld (ix+1),&ff
dhcsr3:
inc ix
inc ix
inc ix
inc ix
inc e
dec d
jr nz,dhcsr
ret


drive2_head_config_set_result:
ld d,0
ld e,0
d2hcsr:

ld a,(drive_config)
or a
jr z,d22hcsr2	;; neither connected
cp 1
jr nz,n22f2dhc
bit 4,e		;; accessing slave?
jr nz,d22hcsr2
jr d22hcsr3
n22f2dhc:
cp 2		;; slave only
jr nz,n22f3dhc
bit 4,e		;; accessing master
jr z,d22hcsr2
jr d22hcsr3
n22f3dhc:
cp 3		;; master and slave
jr nz,n22f4dhc
jr d22hcsr3
n22f4dhc:
;; master/single
jr d22hcsr3

d22hcsr2:
ld (ix+1),&ff
ld (ix+3),&ff
d22hcsr3:

ld a,(drive_config)
or a
jr z,d2hcsr2	;; neither connected
cp 1
jr nz,n2f2dhc
bit 4,e		;; accessing slave?
jr z,d2hcsr2
jr d2hcsr3
n2f2dhc:
cp 2		;; slave only
jr nz,n2f3dhc
bit 4,e		;; accessing master
jr nz,d2hcsr2
jr d2hcsr3
n2f3dhc:
cp 3		;; master and slave
jr nz,n2f4dhc
jr d2hcsr3
n2f4dhc:
;; master/single
jr d2hcsr3

d2hcsr2:
ld (ix+3),&ff


d2hcsr3:
inc ix
inc ix
inc ix
inc ix
inc e
dec d
jr nz,d2hcsr
ret

alt_status_reg:
ld a,(ide_device)
or a
jp nz,report_skipped

ld ix,result_buffer

ld a,%00000
call alt_status

ld a,%10000
call alt_status

ld ix,result_buffer
ld bc,512
jp simple_results

reg_all: 
ld ix,result_buffer
push ix
ld a,%00000
push af
push bc
ld bc,&fd0e
out (c),a
pop bc
ld e,&ff
call port_rw_test
pop af
pop ix
call drive_config_set_result

push ix
ld a,%10000
push af
push bc
ld bc,&fd0e
out (c),a
pop bc
ld e,&ff
call port_rw_test
pop af
pop ix
call drive_config_set_result

ld ix,result_buffer
ld bc,512
jp simple_results

sw_data:
ld d,0
ld e,0
swd2:

push bc
ld bc,&fd0e
ld a,h	;; select other device
xor %10000
out (c),a
pop bc
xor a
out (c),a

;; master
push bc
ld bc,&fd0e
out (c),h
pop bc
out (c),e ;; write
in a,(c) ;; read back
ld (ix+0),a
inc ix
inc ix

;; slave
push bc
ld bc,&fd0e
ld a,h	;; select other device
xor %10000
out (c),a
pop bc
ld a,e		;; write
cpl
out (c),a

push bc
ld bc,&fd0e
out (c),h
pop bc
in a,(c)
ld (ix+0),a ;; read
inc ix
inc ix

inc e
dec d
jr nz,swd2
ret

sw_config_data:
ld d,0
ld e,0
swcd:
ld (ix+1),e
inc ix
inc ix
ld a,e
cpl
ld (ix+1),a
inc ix
inc ix
inc e
dec d
jr nz,swcd
ret


sw_head_config_data:
ld d,0
ld e,0
swhcd:
ld (ix+1),e
inc ix
inc ix
ld (ix+1),0
inc ix
inc ix
inc e
dec d
jr nz,swhcd
ret


sw2_head_config_data:
ld d,0
ld e,0
sw2hcd:
ld (ix+1),e
inc ix
inc ix
ld (ix+1),&10
inc ix
inc ix
inc e
dec d
jr nz,sw2hcd
ret

sw_reg:
ld ix,result_buffer

push ix
push ix
ld h,0
call sw_data
pop ix
call sw_config_data
pop ix
ld a,0
push af
call drive_config_set_result
pop af
call drive_config_set_result

push ix
push ix
ld h,%10000
call sw_data
pop ix
call sw_config_data
pop ix
ld a,%10000
push af
call drive_config_set_result
pop af
call drive_config_set_result

ld ix,result_buffer
ld bc,1024
jp simple_results




sec_count_all:
ld bc,&fd0a
jp reg_all

sw_sec_count_all:
ld bc,&fd0a
jp sw_reg

sec_num_all:
ld bc,&fd0b
jp reg_all

sw_sec_num_all:
ld bc,&fd0b
jp sw_reg

cyl_low_all:
ld bc,&fd0c
jp reg_all

sw_cyl_low_all:
ld bc,&fd0c
jp sw_reg

cyl_high_all:
ld bc,&fd0d
jp reg_all

sw_cyl_high_all:
ld bc,&fd0d
jp sw_reg


sw_head_all:
ld bc,&fd0e
ld ix,result_buffer

ld h,0
push ix
push ix
call sw_data
pop ix
call sw_head_config_data
pop ix
call drive_head_config_set_result

ld h,%10000
push ix
push ix
call sw_data
pop ix
call sw2_head_config_data
pop ix
call drive2_head_config_set_result

ld ix,result_buffer
ld bc,1024
jp simple_results

read_data_status:
rds:

ld bc,&fd0f
in a,(c)
ld (ix+0),a
inc ix
inc ix

ld bc,&fd0f
rds1:
;; if busy is set then loop
in a,(c)
bit 7,a 
jr nz,rds1
;; busy is clear, we can read the rest of the status register
;; drq set?
;; data to transfer?
bit 3,a
jr z,rds2

ld bc,&fd08
in a,(c)
ld bc,&fd08
in a,(c)
jr rds
rds2:
ld bc,&fd0f
in a,(c)
ld (ix+0),a
inc ix
inc ix
ret


;; read 1 sector
cmd_stat_read_sectors:
defb 1
defb 0
defb 0
defb 0
defb &40
defb &20

read_sector_status:
ld a,1
jr read_sec_status

read_sectors_status:
ld a,2
jr read_sec_status

;; get status during command and get results 
read_sec_status:
ld (cmd_stat_read_sectors+0),a

ld hl,result_buffer
ld e,l
ld d,h
ld (hl),0
inc de
ld bc,4096
ldir

ld ix,result_buffer
ld b,6
rssa:
ld a,&50
ld (ix+1),a
inc ix
inc ix
djnz rssa
ld (ix+1),&d0
inc ix
inc ix

ld a,(cmd_stat_read_sectors+0)
l2:
push af

ld bc,255
rssa1:
ld a,&58
ld (ix+1),a
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,rssa1
;; on x-mass these are missing in middle of sector; they appear
;; at end (4 for 2 sectors??)
ld (ix+1),&50
inc ix
inc ix
ld (ix+1),&50
inc ix
inc ix
pop af
dec a
jp nz,l2

ld b,6
rssa2:
ld a,&ff
ld (ix+1),a
inc ix 
inc ix
djnz rssa2
ld (ix+1),&50
inc ix
inc ix
ld (ix+1),&fe
inc ix
inc ix
;; zero on x-mass
ld (ix+1),&ff
inc ix
inc ix
ld (ix+1),&ff
inc ix
inc ix
ld (ix+1),&00
inc ix
inc ix
ld (ix+1),&00
inc ix
inc ix
ld (ix+1),&00
inc ix
inc ix
ld (ix+1),&00
inc ix
inc ix
ld (ix+1),&40
inc ix
inc ix
ld (ix+1),&50
inc ix
inc ix

ld ix,result_buffer
xor a
ld bc,&fd0e
out (c),a

ld hl,cmd_stat_read_sectors

ld bc,&fd0a
ld d,6
rss:
push bc
;; read status prior to sending command
ld bc,&fd0f
in a,(c)
ld (ix+0),a
inc ix
inc ix
pop bc

ld a,(hl)
out (c),a
inc hl
inc c
dec d
jr nz,rss


ld a,(cmd_stat_read_sectors+0)
rssaa2:
push af
ld de,512
call read_data_status
pop af
dec a
jp nz,rssaa2
call ide_wait_finish
call ide_read_registers
push ix
pop hl
ld bc,result_buffer
or a
sbc hl,bc
ld c,l
ld b,h

ld hl,0
ld bc,256+1
ld a,(cmd_stat_read_sectors+0)
rssaa3:
add hl,bc
dec a
jr nz,rssaa3
ld bc,16+6
add hl,bc
ld c,l
ld b,h
ld ix,result_buffer
jp simple_results

cmd_stat_write_sectors:
defb 1
defb 0
defb 0
defb 0
defb &40
defb &30

busy_fd08:
ld bc,&fd08
jr busy_common

busy_fd09:
ld bc,&fd09
jr busy_common

busy_fd0a:
ld bc,&fd0a
jr busy_common

busy_fd0b:
ld bc,&fd0b
jr busy_common

busy_fd0c:
ld bc,&fd0c
jr busy_common
busy_fd0d:
ld bc,&fd0d
jr busy_common

busy_fd0e:
ld bc,&fd0e
jr busy_common

busy_fd0f:
ld bc,&fd0f
jr busy_common


busy_common:
ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped

push bc
di
exx  ;; into alt
push bc
push de
push hl
exx  ;; out of alt

push bc
push bc

ld ix,result_buffer
ld hl,cmd_stat_write_sectors
call ide_write_command
ld bc,&fd0f
wsr:
in a,(c)
bit 7,a
jr nz,wsr
ld de,256
ld bc,&fd08
ld a,0
wsr2:
out (c),a
out (c),a
dec de
ld a,d
or e
jr nz,wsr2
pop bc
in d,(c)
in e,(c)
in h,(c)
in l,(c)
in a,(c)
exx  ;; into alt
pop bc
in d,(c)
in e,(c)
in h,(c)
in l,(c)
exx;; out of alt
in c,(c)
ld (ix+0),d
ld (ix+1),e
ld (ix+2),h
ld (ix+3),l
ld (ix+4),a
exx ;; into alt
ld (ix+5),d
ld (ix+6),e
ld (ix+7),h
ld (ix+8),l

pop hl
pop de
pop bc
exx ;; out of alt
ei
ld bc,&fd0f
wsr3:
in a,(c)
bit 7,a
jr nz,wsr3
pop bc
in a,(c)
ld (ix+9),a
ld ix,result_buffer
ld bc,10
ld d,8
call simple_number_grid
ret

sym2_fd06_read_sector:
ld bc,&fd06
jp sym2_read_sector

sym2_fd07_read_sector:
ld bc,&fd07
jp sym2_read_sector

sym2_fd08_read_sector:
ld bc,&fd08
jp sym2_read_sector

sym2_fd09_read_sector:
ld bc,&fd09
jp sym2_read_sector

sym2_fd0a_read_sector:
ld bc,&fd0a
jp sym2_read_sector

sym2_fd0b_read_sector:
ld bc,&fd0b
jp sym2_read_sector

sym2_fd0c_read_sector:
ld bc,&fd0c
jp sym2_read_sector

sym2_fd0d_read_sector:
ld bc,&fd0d
jp sym2_read_sector

sym2_fd0e_read_sector:
ld bc,&fd0e
jp sym2_read_sector

sym2_fd0f_read_sector:
ld bc,&fd0f
jp sym2_read_sector

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
call ide_wait_finish
call ide_read_registers
ld ix,result_buffer
ld bc,16
jp simple_results

fill_sector:
ld hl,data_buffer
ld bc,512
ld d,0
sr8s:
ld (hl),d
inc d
inc hl
dec bc
ld a,b
or c
jr nz,sr8s

;; write sector in compatible way
ld hl,cmd_stat_write_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_write_data
call ide_wait_finish
ret


xmass_read_16bit_sector:
ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped


;; ignore if symbiface 2
ld a,(ide_device)
or a
jp z,report_skipped

call fill_sector

;; read sector in the compatible way
;; using 8-bit transfer
ld ix,result_buffer
ld hl,cmd_stat_read_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_read_data
call ide_wait_finish


;; disable 8-bit transfer
ld bc,&fd0e
ld a,0
out (c),a

ld a,&81
ld bc,&fd09
out (c),a

ld a,&ef
ld bc,&fd0f
out (c),a
call ide_wait_finish

ld hl,cmd_stat_read_sectors
call ide_write_command

ld de,0
ld hl,data_buffer+512
xcrd:
ld bc,&fd0f
in a,(c)
bit 7,a 
jr nz,xcrd
bit 3,a
jr z,xrcd2

ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
inc de
jr xcrd
xrcd2:
ld (ix+0),e
ld (ix+1),0
ld (ix+2),d
ld (ix+3),&1
inc ix
inc ix
inc ix
inc ix
call ide_wait_finish
xor a
ld (ix+1),a
ld (ix+3),a
ld (ix+5),a
ld (ix+7),a
ld (ix+9),a
ld (ix+11),&40
ld (ix+13),&50
call ide_read_registers

push ix
ld hl,data_buffer
ld bc,256
xsrs3:
ld a,(hl)
ld (ix+1),a
inc hl
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,xsrs3
pop ix
push ix
ld hl,data_buffer+512
ld bc,256
xsrs4:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,xsrs4
pop ix
;; enable 8-bit transfer
ld bc,&fd0e
ld a,0
out (c),a

ld a,&1
ld bc,&fd09
out (c),a

ld a,&ef
ld bc,&fd0f
out (c),a
call ide_wait_finish

ld ix,result_buffer
ld bc,256+16+2
jp simple_results



sym_read_8bit_sector:
;; ignore if not symbiface 2
ld a,(ide_device)
or a
jp nz,report_skipped

call fill_sector

;; read sector in the compatible way
ld ix,result_buffer
ld hl,cmd_stat_read_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_read_data
call ide_wait_finish

;; enable 8-bit transfer - if device doesn't support it
;; then it will read different data
ld bc,&fd0e
ld a,0
out (c),a

ld a,&1
ld bc,&fd09
out (c),a

ld a,&ef
ld bc,&fd0f
out (c),a

call ide_wait_finish

ld hl,cmd_stat_read_sectors
call ide_write_command

ld de,0
ld hl,data_buffer+512
scrd:
ld bc,&fd0f
in a,(c)
bit 7,a 
jr nz,scrd
bit 3,a
jr z,srcd2

ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
inc de
jr scrd
srcd2:
ld (ix+0),e
ld (ix+1),0
ld (ix+2),d
ld (ix+3),&2
inc ix
inc ix
inc ix
inc ix
call ide_wait_finish
xor a
ld (ix+1),a
ld (ix+3),a
ld (ix+5),a
ld (ix+7),a
ld (ix+9),a
ld (ix+11),&40
ld (ix+13),&50
call ide_read_registers

;; expected
push ix
ld hl,data_buffer
ld bc,512
ssrs3:
ld a,(hl)
ld (ix+1),a
inc hl
;;inc hl
inc ix
inc ix
ld (ix+1),0
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,ssrs3
;; actual
pop ix
ld hl,data_buffer+512
ld bc,512
ssrs4:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,ssrs4


;; disable 8-bit transfer
ld bc,&fd0e
ld a,0
out (c),a

ld a,&81
ld bc,&fd09
out (c),a

ld a,&ef
ld bc,&fd0f
out (c),a

call ide_wait_finish

ld ix,result_buffer
ld bc,256+7+2
jp simple_results


srs_port:
defw 0

sym2_read_sector:
ld (srs_port),bc

ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped

;; ignore if not symbiface 2
;;ld a,(ide_device)
;;or a
;;jp nz,report_skipped

call fill_sector

;; read sector in the compatible way
ld ix,result_buffer
ld hl,cmd_stat_read_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_read_data
call ide_wait_finish

ld hl,cmd_stat_read_sectors
call ide_write_command

;; read sector using each port
ld de,0
ld hl,data_buffer+512
srs:
;; data ready?
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,srs
bit 3,a
jr z,srs2
;; read first byte using data register
ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
;; read next byte using provided port
ld bc,(srs_port)
in a,(c)
ld (hl),a
inc hl
inc de
inc de
jr srs

srs2:
ld (ix+0),e
ld (ix+1),0
ld (ix+2),d
ld (ix+3),&2
inc ix
inc ix
inc ix
inc ix
call ide_wait_finish
xor a
ld (ix+1),a
ld (ix+3),a
ld (ix+5),a
ld (ix+7),a
ld (ix+9),a
ld (ix+11),&40
ld (ix+13),&50
call ide_read_registers

;; expected
push ix
ld hl,data_buffer
ld bc,512
srs3:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,srs3
;; actual
pop ix
ld hl,data_buffer+512
ld bc,512
srs4:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,srs4

ld ix,result_buffer
ld bc,512+7
jp simple_results

sym2_fd0e_read2_sector:
ld bc,&fd0e
jr sym2_read_sector2

sym2_fd0d_read2_sector:
ld bc,&fd0d
jr sym2_read_sector2

sym2_fd0f_read2_sector:
ld bc,&fd0f
jr sym2_read_sector2

sym2_read_sector2:
ld (srs_port),bc

ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped


;; ignore if not symbiface 2
ld a,(ide_device)
or a
jp nz,report_skipped

call fill_sector

;; read sector in the compatible way
ld ix,result_buffer
ld hl,cmd_stat_read_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_read_data
call ide_wait_finish


ld hl,cmd_stat_read_sectors
call ide_write_command

;; read sector using each port
ld de,0
ld hl,data_buffer+512
srs22:
;; data ready?
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,srs22
bit 3,a
jr z,srs22a
;; read first byte using data register
ld bc,(srs_port)
in a,(c)
ld (hl),a
inc hl
;; read next byte using provided port
ld bc,(srs_port)
in a,(c)
ld (hl),a
inc hl
inc de
inc de
jr srs22

srs22a:
call ide_wait_finish
;; expected
ld ix,result_buffer
push ix
ld hl,data_buffer
ld bc,512
srs32:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,srs32
;; actual
pop ix
ld hl,data_buffer+512
ld bc,512
srs42:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,srs42

ld ix,result_buffer
ld bc,512
jp simple_results


sym2_read2b_sector:
ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped


;; ignore if not symbiface 2
ld a,(ide_device)
or a
jp nz,report_skipped

call fill_sector

;; read sector in the compatible way
ld ix,result_buffer
ld hl,cmd_stat_read_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_read_data
call ide_wait_finish

ld hl,cmd_stat_read_sectors
call ide_write_command

ld bc,&fd08
in a,(c)
ld (hl),a
inc hl

;; read sector using each port
ld de,0
ld hl,data_buffer+512
srs22b:
;; data ready?
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,srs22b
bit 3,a
jr z,srs22ab
;; read first byte using data register
ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
inc de

ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
inc de
jr srs22b

srs22ab:
call ide_wait_finish
;; expected
ld ix,result_buffer
push ix
ld hl,data_buffer
ld bc,512
srs32b:
ld a,(hl)
ld (ix+1),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,srs32b
;; actual
pop ix
ld hl,data_buffer+512
ld bc,512
srs42b:
ld a,(hl)
ld (ix+0),a
inc hl
inc ix
inc ix
dec bc
ld a,b
or c
jr nz,srs42b

ld ix,result_buffer
ld bc,512
jp simple_results

sym2_wfd06_read_sector:
ld bc,&fd06
jp sym2_read2w_sector

sym2_wfd07_read_sector:
ld bc,&fd07
jp sym2_read2w_sector

sym2_wfd08_read_sector:
ld bc,&fd08
jp sym2_read2w_sector

sym2_wfd09_read_sector:
ld bc,&fd09
jp sym2_read2w_sector

sym2_wfd0a_read_sector:
ld bc,&fd0a
jp sym2_read2w_sector

sym2_wfd0b_read_sector:
ld bc,&fd0b
jp sym2_read2w_sector

sym2_wfd0c_read_sector:
ld bc,&fd0c
jp sym2_read2w_sector

sym2_wfd0d_read_sector:
ld bc,&fd0d
jp sym2_read2w_sector

sym2_wfd0e_read_sector:
ld bc,&fd0e
jp sym2_read2w_sector

sym2_wfd0f_read_sector:
ld bc,&fd0f
jp sym2_read2w_sector


sym2_read2w_sector:
ld (srs_port),bc

ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped

;; ignore if not symbiface 2
;;ld a,(ide_device)
;;or a
;;jp nz,report_skipped

call fill_sector

;; read sector in the compatible way
ld ix,result_buffer
;;ld hl,cmd_stat_read_sectors
;;call ide_write_command
;;ld hl,data_buffer
;;ld de,512
;;call ide_read_data
;;call ide_wait_finish


ld hl,cmd_stat_read_sectors
call ide_write_command

ld de,0
wsrs22b:
;; data ready?
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,wsrs22b
bit 3,a
jr z,wsrs22ab

ld bc,&fd08
in a,(c)
inc de
xor a
ld bc,(srs_port)
out (c),a
inc de
jr wsrs22b

wsrs22ab:
ld (ix+0),e
ld (ix+1),0
ld (ix+2),d
ld (ix+3),&2
inc ix
inc ix
inc ix
inc ix
call ide_wait_finish
xor a
ld (ix+1),a
ld (ix+3),a
ld (ix+5),a
ld (ix+7),a
ld (ix+9),a
ld (ix+11),&40
ld (ix+13),&50
call ide_read_registers

ld ix,result_buffer
ld bc,2+7
jp simple_results




sym2_rfd06_write_sector
ld bc,&fd06
jp sym2_write2r_sector

sym2_rfd07_write_sector
ld bc,&fd07
jp sym2_write2r_sector

sym2_rfd08_write_sector
ld bc,&fd08
jp sym2_write2r_sector

sym2_rfd09_write_sector
ld bc,&fd09
jp sym2_write2r_sector

sym2_rfd0a_write_sector
ld bc,&fd0a
jp sym2_write2r_sector

sym2_rfd0b_write_sector
ld bc,&fd0b
jp sym2_write2r_sector

sym2_rfd0c_write_sector
ld bc,&fd0c
jp sym2_write2r_sector

sym2_rfd0d_write_sector
ld bc,&fd0d
jp sym2_write2r_sector

sym2_rfd0e_write_sector
ld bc,&fd0e
jp sym2_write2r_sector

sym2_rfd0f_write_sector
ld bc,&fd0f
jp sym2_write2r_sector


sym2_write2r_sector:
ld (srs_port),bc

ld a,(drive_config)
cp 0
jp z,report_skipped
cp 2
jp z,report_skipped

;; ignore if not symbiface 2
;;ld a,(ide_device)
;;or a
;;jp nz,report_skipped

call fill_sector

;; write sector in the compatible way
ld ix,result_buffer
ld hl,cmd_stat_write_sectors
call ide_write_command
ld hl,data_buffer
ld de,512
call ide_write_data
call ide_wait_finish


ld hl,cmd_stat_write_sectors
call ide_write_command

ld de,0
ld hl,data_buffer+512
wsrs22bw:
;; data ready?
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,wsrs22bw
bit 3,a
jr z,wsrs22abw

xor a
ld bc,&fd08
out (c),a
inc de
ld bc,(srs_port)
in a,(c)
inc de
jr wsrs22bw

wsrs22abw:
ld (ix+0),e
ld (ix+1),0
ld (ix+2),d
ld (ix+3),&2
inc ix
inc ix
inc ix
inc ix
call ide_wait_finish
xor a
ld (ix+1),a
ld (ix+3),a
ld (ix+5),a
ld (ix+7),a
ld (ix+9),a
ld (ix+11),&40
ld (ix+13),&50
call ide_read_registers

ld hl,cmd_stat_read_sectors
call ide_write_command
ld hl,data_buffer+521
ld de,512
call ide_read_data
call ide_wait_finish


ld ix,result_buffer
ld bc,2+7
jp simple_results


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


status_io:
defw 0

;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "../../lib/portdec.asm"
include "../../lib/hw/crtc.asm"
include "../../lib/hw/psg.asm"
include "idecommon.asm"


result_buffer: equ $

end start
