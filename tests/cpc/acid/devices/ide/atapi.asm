;; THIS IS WORK IN PROGRESS CODE TO ACCESS A CD-ROM DRIVE USING THE SYMBIFACE 2 AND A CPC

org &8000
nolist

;; http://www.seagate.com/staticfiles/support/disc/manuals/scsi/100293068a.pdf

start:
;; set pio
xor a
ld bc,&fd09
out (c),a

ld hl,cmd_identify_packet_device
call ide_write_command

call send_atapi_command


send_atapi_command:
push hl
ld hl,cmd_packet
call ide_write_command
pop hl

call ide_wait_data_or_error
;; error?
ld a,e
or a
ret nz
ld bc,&fd0a
in a,(c)
bit 0,a	;; C/D
ret z
bit 1,a	;; I/O
ret nz

ld bc,&fd0f
in a,(c)
bit 0,a
ret nz

wp:
;; write packet bytes
ld bc,&fd08
ld a,(hl)
out (c),a
inc hl
ld bc,&fd08
ld a,(hl)
out (c),a
inc hl

ld bc,&fd0f
in a,(c)
bit 7,a
jr z,wp

call ide_wait_data_or_error
;; error?
ld a,e
or a
ret nz
ld bc,&fd0a
in a,(c)
bit 0,a	;; C/D
ret nz
;;bit 1,a	;; I/O
;;ret nz

;; read size to transfer
ld bc,&fd0c
in a,(c)
ld e,a
ld bc,&fd0d
in a,(c)
ld d,a

ld hl,read_data_buffer
call ide_read_data


call ide_wait_data_or_error
;; error?
ld a,e
or a
ret nz
ld bc,&fd0a
in a,(c)
bit 0,a	;; C/D
ret z
bit 1,a	;; I/O
ret z

ld bc,&fd0f
in a,(c)
bit 0,a
ret z
ld bc,&fd09
in a,(c)

ret

atapi_read_sectors_command:
defb &a8
defs 11


cmd_packet:
defb 0
defb 0
defb &00
defb &40		;; max size of 16384 bytes
defb &40
defb &a0

cmd_identify_packet_device:
defb 0
defb 0
defb 0
defb 0
defb &40
defb &a1


include "idecommon.asm"

end start