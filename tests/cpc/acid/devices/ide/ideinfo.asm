;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
include "../../lib/testdef.asm"

txt_output equ &bb5a

;; X-Mass:
;; detecting slave: timed out
;; detecting master: possible
;; device 0 passed, device 1 passed or not present
;; 50 01 (drdy, dsc (ata-4) device seek complete)
;; device seems to be ok
;; master: identify device success
;; slave: identify device fail
;;
;; Symbiface 2
;; without slave, similar to x-mass (except both are "possible")
;; device 1 passed if it's present
;; 
;; with slave, both possible, identify device success on all.

;; X-Mass with DOM:
;; 5A 04 F4 01 00 00 10 00 00 00 00 02 20 00 03 00
;; 00 E8 00 00 4F 44 35 4D 30 44 30 30 37 31 32 34
;; 00 39 20 20 20 20 20 20 01 00 01 00 04 00 30 4E
;; 30 35 31 33 44 36 51 50 20 49 44 49 20 45 69 44
;; 6B 73 6E 4F 6F 4D 75 64 65 6C 20 20 20 20 20 20
;; 20 20 20 20 20 20 20 20 20 20 20 20 20 20 01 00
;; 00 00 00 0F 00 00 00 02 00 00 03 00 F4 01 10 00
;; 20 00 00 E8 03 00 00 01 00 E8 03 00 00 00 07 04
;; 03 00 78 00 78 00 78 00 78 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 35 30 33 30 36 31 38 62 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
;; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00


org &4000
start:
ld hl,copy_result_fn
ld (cr_functions),hl

ld a,2
call scr_set_mode
ld hl,intro_message
call display_text
call &bb06


ld a,2
call scr_set_mode
ld hl,detect_msg
call display_text

call identify_devices
call &bb06

dev_info_loop:
ld hl,choose_dev
call display_text
call dev_info
jp dev_info_loop

dev_info:
call &bb06
cp '1'
jr c,dev_info
cp '3'
jr nc,dev_info
sub '1'
ld hl,ident0
jr z,di2
ld hl,ident1
di2:
jp display_inf

;; slave:
;; possible 
;; timed out
;; 50 01 device 1 passed
;; slave ok
;; master fail
;; 
;; dev1 asserted pdiag,unknown
;;
;; master with slave (with slave):
;;
;; TODO
;; master with slave (no slave):
;; master possible
;; slave possible
;; dev 0 passed, dev1 failed
;; 50 81
;; id ok
;; id fail.
;; dev 0 failed diagnostics, dev 0 detected pdasp,unknown
;;
;;
;; master/single (with slave):
;;
;; TODO

;; master/single:
;; master/save possible
;; dev 0 passed, dev1 passed or not present
;; 50 01
;; id ok
;; id bad
;; master success
;; slave failed
;; dev 0 failed diagnostics, unknown

intro_message:
defb "IDE Device Identify",13,10,13,10
defb "This program attempts to detect Master and Slave IDE devices.",13,10,13,10
defb "It uses the recommended methods described in the ATA (T13)",13,10
defb "specification. This program can also be used to confirm that",13,10
defb "your IDE emulation is handling the EC command correctly, and",13,10
defb "that it is correctly reporting drive configurations",13,10,13,10
defb "Press any key to continue",13,10,13,10
defb 0


choose_dev:
defb "Choose device: 1. Master 2. Slave",13,10,0

detect_msg:
defb "Detecting devices...",13,10,0

detect_device_msg:
defb "Detecting device ",0

identify_msg:
defb "Identify device",0

success_msg:
defb "Success",0
fail_msg:
defb "Fail",0

master_device_msg:
defb "Master",0
slave_device_msg:
defb "Slave",0

detected_msg:
defb "Detected",0

possible_msg:
defb "Possible",0

device_ok_msg:
defb "Device seems to be ok",13,10,0
device_bad_msg:
defb "Device seems to be bad",13,10,0


dev0_for_1:
defb "Master is responding for slave",0
dev1_for_0:
defb "Slave is responding for master",0

master_detect_slave:
defb "master detected slave using PDIAG",13,10,0

edd_01_master:
defb "device 0 passed, device 1 passed or not present",13,10,0
edd_00_02_to_7f_master:
defb "device 0 failed, device 1 passed or not present",13,10,0
edd_81_master:
defb "device 0 passed, device 1 failed",13,10,0
edd_80_82_to_ff_master:
defb "device 0 failed, device 1 failed",13,10,0

edd_01_slave:
defb "device 1 passed ",13,10,0
edd_00_02_to_7f_slave:
defb "device 1 failed",13,10,0
edd_unknown:
defb "device 1 unknown",13,10,0

timeout_msg:
defb "Timed out",0


;; ATA-6 Single device configurations
;; 9.16.2 Device 1 only configurations
select_dev:
push af
push af
ld hl,detect_device_msg
call display_text
pop af
rrca
rrca
rrca
rrca
and &1
ld hl,master_device_msg
jr z,selectdev2
ld hl,slave_device_msg
selectdev2:
call display_text
ld a,':'
call &bb5a
pop af
;; select dev 
ld bc,&fd0e
out (c),a

;; write to sector count register, repeat until 31 seconds is up
ld de,9395
ld bc,&fd0a

;; 1/300 -> 0.0033 -> ~9,394
dev1_test:
ld a,&aa
out (c),a
in a,(c)
cp &aa
jr nz,dev1_test2
ld a,&55
out (c),a
in a,(c)
cp &55
ld a,1
jr z,dev1_test3

dev1_test2:
halt

dec de
ld a,d
or e
jr nz,dev1_test

xor a
dev1_test3:
ld (dev_found),a
or a
ret z

ld bc,&fd0f
in a,(c)
ld (dev_status),a
ld bc,&fd09
in a,(c)
ld (dev_error),a
ret

check_status:
bit 7,a			;; BSY
jr nz,dev_not_found
bit 6,a			;; DRDY
jr z,dev_not_found
bit 5,a			;; DF
jr  nz,dev_not_found
bit 0,a			;; ERR
jr nz,dev_not_found
ld a,1
ret
dev_not_found:
xor a
ld (dev_found),a
ret

dev_found:
defb 0
dev_status:
defb 0
dev_error:
defb 0

dev0_found:
defb 0
dev1_found:
defb 0
dev0_status:
defb 0
dev0_error:
defb 0
dev1_status:
defb 0
dev1_error:
defb 0

ident0:
defs 512

ident1:
defs 512

;; ATA-6 Single device configurations
;; 9.16.2 Device 1 only configurations
identify_devices:
;; perform an execute device diagnostic
ld a,&90
ld bc,&fd0f
out (c),a

ld a,%10000
call select_dev
;; dev_found is 0 if no device found, 1 if a device was found (could be master or slave)
;; the status and error should report as appropiate.

;; is device 1 responding for device 0?
ld a,(dev_status)
ld (dev1_status),a
ld a,(dev_error)
ld (dev1_error),a

ld a,(dev_found)
ld (dev1_found),a

or a
ld hl,possible_msg
jr nz,id2
ld hl,timeout_msg
id2:
call display_text
call crlf

xor a
call select_dev

ld a,(dev_status)
ld (dev0_status),a
ld a,(dev_error)
ld (dev0_error),a

ld a,(dev_found)
ld (dev0_found),a
or a
ld hl,possible_msg
jr nz,id3
ld hl,timeout_msg
id3:
call display_text
call crlf

ld a,(dev0_found)
or a
jr z,id4
ld a,(dev0_error)
cp 1
ld hl,edd_01_master
jr z,edd_master_result
cp &81
ld hl,edd_81_master
jr z,edd_master_result
bit 7,a
ld hl,edd_00_02_to_7f_master
jr z,edd_master_result
ld hl,edd_80_82_to_ff_master
edd_master_result:
call display_text

id4:
ld a,(dev1_found)
or a
jr z,id5


ld a,(dev0_status)
call outputhex8
ld a,' '
call output_char
ld a,(dev0_error)
call outputhex8


ld a,(dev1_error)
cp 1
ld hl,edd_01_slave
jr z,edd_slave_result
bit 7,a
ld hl,edd_00_02_to_7f_slave
jr z,edd_slave_result
ld hl,edd_unknown
edd_slave_result:
call display_text
id5:


ld a,(dev0_found)
or a
jr z,id6

;;ld a,(dev0_status)
;;call outputhex8
;;ld a,' '
;;call output_char
;;ld a,(dev0_error)
;;call outputhex8
;;ld a,' '
;;call outputhex8
ld hl,master_device_msg
call display_text
ld a,':'
call output_char

ld a,(dev0_status)
call check_status
or a
ld hl,device_ok_msg
jr nz,id7
ld hl,device_bad_msg
id7:
call display_text

id6:

ld a,(dev1_found)
or a
jr z,id8

ld hl,slave_device_msg
call display_text
ld a,':'
call output_char

ld a,(dev1_status)
call check_status
or a
ld hl,device_ok_msg
jr nz,id9
ld hl,device_bad_msg
id9:
call display_text

id8:
ld hl,master_device_msg
call display_text
ld a,':'
call &bb5a
ld hl,identify_msg
call display_text
ld a," "
call &bb5a
call do_ident_0
ld hl,success_msg
jr z,id10
ld hl,fail_msg
id10:
call display_text
call crlf

ld hl,slave_device_msg
call display_text
ld a,':'
call &bb5a
ld hl,identify_msg
call display_text
ld a," "
call &bb5a
call do_ident_1
ld hl,success_msg
jr z,id11
ld hl,fail_msg
id11:
call display_text
call crlf
ret



;; Paladin:
;; ata
;; no version reported
;; max drq: 13
;; pio mode 0
;; cylinders: 1049
;; heads 16
;; sectors 63


;; DOM:
;; No version reported
;; 1
;; no features supported/reported
;; cylinders: 500
;; heads: 16
;; sectors/track: 32
;; Heads 16
;; current capacity: 59392
;; 0
;; 0
;; dma,lba

;; WD: 
;; version supported: 01,02,03,04,05,06
;; max per drq: 32784
;; supports smart, security, power, write buffer cmd, read buffer cmd, nop cmd
;; enabled: smart,power,write buffer cmd,read buffer cmd,nop cmd
;; WDC WD800BB-00JHC0
;; Cylinders: 16383
;; Heads: 16
;; Sectors/track: 63
;; Current capacity in sectors: 64528
;; current sectors: 0
;; max lba: 00
;; dma supported
;; lba supported

;; MAXTOR:
;; version supported: 01,02,03,04,05,06,07
;; max per drq: 32784
;; supports smart, security, power, write buffer cmd, read buffer cmd, nop cmd
;; enabled: smart power,write buffer cmd,read buffer cmd,nop cmd
;; Maxtor 6L200P0
;; Cylinders: 16383
;; Heads: 16
;; Sectors/track: 63
;; Current capacity in sectors: 64528
;; current sectors: 0
;; max lba: 00
;; dma supported
;; lba supported

do_ident_0:
xor a
ld hl,ident0
jr ident_drive

do_ident_1:
ld a,1
ld hl,ident1
jr ident_drive

ident_drive:
push hl
;; clear info
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,512-1
ldir
pop hl

add a,a
add a,a
add a,a
add a,a
ld bc,&fd0e
out (c),a

ld bc,&fd0f
in a,(c)
and %11101001
cp %01000000
ret nz

ld a,&ec		;; identify device
ld bc,&fd0f
out (c),a

ld de,512
call ide_read_data
call ide_wait_finish

;; check for error condition
ld bc,&fd0f
in a,(c)
bit 0,a
jr z,ident_ok
ld bc,&fd09
in a,(c)
call outputhex8
ld a,' '
call output_char
ld a,1
or a
ret

ident_ok:
;; success
ld a,0
or a
ret

display_inf:
ld de,data_buffer
ld bc,512
ldir

ld ix,data_buffer
ld d,16
ld bc,512
call simple_number_grid


ld hl,data_buffer+(0*2)
ld e,(hl)
inc hl
ld d,(hl)
bit 7,d
ld hl,ata_device_txt
call z,display_text
bit 7,d
ld hl,atapi_device_txt
call nz,display_text
call crlf

ld hl,supports_txt
call display_text

ld hl,data_buffer+(80*2)
call does_report_ver
jr c,no_version

has_ver:
srl d
rr e

ld b,15
ld a,1
sv2:
srl d
rr e
call show_ver
djnz sv2
call crlf
jr did_ver

no_version:
ld hl,no_ver_txt
call display_text

did_ver:
call crlf

;;ld hl,data_buffer+(82*2)
;;call does_report_ver
;;jr c,no_features

ld hl,logical_sectors_txt
call display_text
ld hl,data_buffer+(47*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
ld d,0
call display_decimal
call crlf


ld hl,features_supported_txt
call display_text


ld hl,data_buffer+(82*2)
call display_features

ld hl,features_enabled_txt
call display_text

ld hl,data_buffer+(85*2)
call display_features


ld hl,command_set_txt
call display_text
ld hl,data_buffer+(83*2)
call display_command_set

ld hl,model_txt
call display_text
ld hl,data_buffer+(27*2)
ld bc,40
call ide_string
call crlf

ld hl,pio_mode_txt
call display_text
ld a,(data_buffer+(51*2))
ld l,a
ld h,0
call display_decimal
call crlf

ld hl,serial_txt
call display_text
ld hl,data_buffer+(10*2)
ld bc,20
call ide_string
call crlf

ld hl,firmware_txt
call display_text
ld hl,data_buffer+(23*2)
ld bc,8
call ide_string
call crlf


ld hl,cylinder_txt
call display_text
ld hl,data_buffer+(1*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,heads_txt
call display_text
ld hl,data_buffer+(3*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,spt_txt
call display_text
ld hl,data_buffer+(6*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf


ld hl,cylinder_txt
call display_text
ld hl,data_buffer+(54*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,heads_txt
call display_text
ld hl,data_buffer+(55*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,spt_txt
call display_text
ld hl,data_buffer+(56*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,capacity_sectors_txt
call display_text
ld hl,data_buffer+(57*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,current_number_sectors_txt
call display_text
ld hl,data_buffer+(59*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
ld h,0
ld a,l
and &7f
ld l,a
call display_decimal
call crlf


ld hl,detect_txt
call display_text
ld hl,data_buffer+(93*2)
ld e,(hl)
inc hl
ld d,(hl)
bit 3,d
ld hl,dev1_assert_diag_txt
call nz,display_text

ld a,d
srl a
call display_sel
call crlf


ld de,(data_buffer+(93*2))
bit 3,e
ld hl,dev0_failed_diagnostics_txt
call nz,display_text
bit 4,e
ld hl,dev0_detected_pdiag_txt
call nz,display_text
bit 5,e
ld hl,dev0_detected_pdasp_txt
call nz,display_text
bit 6,e
ld hl,dev0_respond_dev1_txt
call nz,display_text

ld a,e
and &3
call display_sel
call crlf

;; update to 4 bytes
ld hl,max_lba_txt
call display_text
ld hl,data_buffer+(102*2)
ld e,(hl)
inc hl
ld d,(hl)
ex de,hl
call display_decimal
call crlf

ld hl,data_buffer+(49*2)
ld e,(hl)
inc hl
ld d,(hl)
bit 0,d
ld hl,dma_txt
call nz,display_text
bit 1,d
ld hl,lba_txt
call nz,display_text

ret

display_sel:
or a
ld hl,reserved_txt
jr z,dispsel
dec a
ld hl,jumper_txt
jr z,dispsel
dec a
ld hl,csel_txt
jr z,dispsel
ld hl,unknown_txt
dispsel:
jp display_text

reserved_txt:
defb "Reserved,",0
jumper_txt:
defb "Jumper,",0
csel_txt:
defb "CSEL,",0
unknown_txt:
defb "Unknown,",0

dev1_assert_diag_txt:
defb "DEV1 asserted PDIAG,",0
dev0_respond_dev1_txt:
defb "DEV0 responds when DEV1 selected,",0
dev0_detected_pdiag_txt:
defb "DEV0 detected PDIAG,",0
dev0_detected_pdasp_txt:
defb "DEV0 detected PDASP,",0
dev0_failed_diagnostics_txt:
defb "DEV0 failed diagnostics,",0

display_features:
ld e,(hl)
inc hl
ld d,(hl)

bit 0,e
ld hl,smart_txt
call nz,display_text
bit 1,e
ld hl,security_txt
call nz,display_text
bit 2,e
ld hl,removable_txt
call nz,display_text
bit 3,e
ld hl,power_txt
call nz,display_text
bit 4,e
ld hl,packet_txt
call nz,display_text
bit 1,d
ld hl,device_reset_cmd_txt
call nz,display_text
bit 4,d
ld hl,write_buffer_cmd_txt
call nz,display_text
bit 5,d
ld hl,read_buffer_cmd_txt
call nz,display_text
bit 4,d
ld hl,nop_cmd_txt
call nz,display_text

call crlf

no_features:
ret

does_report_ver:
ld e,(hl)
inc hl
ld d,(hl)
ld a,d
or e
jr z,no_rversion
ld a,d
cp &ff
jr nz,has_rver
ld a,e
cp &ff
jr z,no_rversion
has_rver:
or a
ret
no_rversion:
scf
ret

show_ver:
jr nc,sv2a
push af
ld l,a
ld h,0
call display_decimal
ld a,' '
call txt_output
pop af
sv2a:
inc a
ret

display_decimal:
push bc
push de
push hl
call ddec
pop hl
pop de
pop bc
ret

ddec:
ld bc,10000
call display_decimal_digit
ld bc,1000
call display_decimal_digit
ld bc,100
call display_decimal_digit
ld bc,10
call display_decimal_digit
ld bc,1

display_decimal_digit:
ld d,0
ddd1:
inc d
or a
sbc hl,bc
jr nc,ddd1
dec d
add hl,bc
ld a,d
add a,'0'
call txt_output
ret


crlf:
ld a,10
call txt_output
ld a,13
call txt_output
ret

ide_string:
srl b
rrc c

ides1:
inc hl
ld a,(hl)
call ide_char
dec hl
ld a,(hl)
call ide_char
inc hl
inc hl
dec bc
ld a,b
or c
jr nz,ides1
ret

ide_char
cp ' '
jr nc,id2b
ld a,' '
jr id1aa
id2b:
cp &7f
jr c,id1aa
ld a,' '
id1aa:
call txt_output
ret


display_text:
ld a,(hl)
inc hl
or a
ret z
call txt_output
jr display_text

display_command_set:
ld e,(hl)
inc hl
ld d,(hl)

bit 0,e
ld hl,download_microcode_txt
call nz,display_text
bit 1,e
ld hl,read_write_dma_queued_txt
call nz,display_text
bit 2,e
ld hl,cfa_txt
call nz,display_text
bit 3,e
ld hl,advanced_power_txt
call nz,display_text
bit 5,a
ld hl,power_up_in_standby_txt
call nz,display_text
bit 6,a
ld hl,set_features_after_spinup_txt
call nz,display_text

bit 2,e
ld hl,lba_48bit_txt
call nz,display_text

call crlf
ret

download_microcode_txt:
defb "Download microcode,",0

read_write_dma_queued_txt:
defb "Read/Write DMA Queued,",0

cfa_txt:
defb "CFA,",0

advanced_power_txt:
defb "Advanced power managerment,",0

power_up_in_standby_txt:
defb "Power up in standby,",0
set_features_after_spinup_txt:
defb "Set features after spin up,",0

lba_48bit_txt:
defb "48-bit LBA,",0

current_number_sectors_txt:
defb "Current number of sectors transferred: ",0

capacity_sectors_txt:
defb "Current capacity in sectors: ",0

logical_sectors_txt:
defb "Max logical sectors per DRQ data block: ",0

features_supported_txt:
defb "Features supported:",0

features_enabled_txt:
defb "Features enabled:",0

command_set_txt:
defb "Command set:",0

max_lba_txt:
defb "Max LBA: ",0

detect_txt:
defb "Detect: ",0

smart_txt:
defb "SMART,",0

security_txt:
defb "Security,",0

removable_txt:
defb "Removable,",0

packet_txt:
defb "packet,",0

device_reset_cmd_txt:
defb "device reset cmd,",0

write_buffer_cmd_txt:
defb "write buffer cmd,",0

read_buffer_cmd_txt:
defb "read buffer cmd,",0

nop_cmd_txt:
defb "nop cmd,",0

power_txt:
defb "Power,",0

no_ver_txt:
defb "No version reported",0

supports_txt:
defb "ATA version supported:" ,0

ata_device_txt:
defb "ATA device",0
atapi_device_txt:
defb "ATAPI device",0

dma_txt:
defb "DMA supported",13,10,0

lba_txt:
defb "LBA supported",13,10,0

pio_mode_txt:
defb "PIO mode: ",0

supports_cfa:
defb "CFA",0

model_txt:
defb "Model: ",0

serial_txt:
defb "Serial: ",0

firmware_txt:
defb "Firmware: ",0

cylinder_txt:
defb "Cylinders: ",0

heads_txt:
defb "Heads: ",0

spt_txt:
defb "Sectors/Track:",0


;;-----------------------------------------------------

include "../../lib/mem.asm"
include "../../lib/report.asm"
include "../../lib/test.asm"
include "../../lib/outputmsg.asm"
include "../../lib/outputhex.asm"
include "../../lib/output.asm"
include "../../lib/hw/psg.asm"
;; firmware based output
include "../../lib/fw/output.asm"
include "../../lib/hw/crtc.asm"
include "../../lib/portdec.asm"
include "idecommon.asm"


result_buffer  equ $

end start
