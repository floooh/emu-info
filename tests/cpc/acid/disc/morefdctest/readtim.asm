org &4000

txt_output equ &bb5a
km_wait_char equ &bb06
txt_set_cursor equ &bb75
scr_set_mode equ &bc0e
km_read_char equ &bb09

start:
call cls
ld hl,menu_msg
call print_msg

call exe_menu
jp start

menu_msg:
defb "0. read data timings (with history)",10,13
defb 0


;;-----------------------------------------------------------------

exe_menu:
call km_wait_char
cp "0"
jp z,read_data_timings_history
ret

;;----------------------------------------------------------------

;;----------------------------------------------------------------

read_data_timings_history:
call cls
call pick_drive

di
call disc_motor_on
call fdc_recalibrate
xor a
ld (track),a

call fdc_seek

ld ix,historical_values
ld b,0
ld a,&c1
ld (sector),a

read_time_loop:
push bc

ld a,%01000110				;; read data, mfm
call fdc_write_command
ld a,(drive)
call fdc_write_command
ld a,(track)						;; C
call fdc_write_command
ld a,0						;; H
call fdc_write_command
ld a,(sector)				;; R
call fdc_write_command
ld a,2						;; N
call fdc_write_command
ld a,(sector)				;; EOT
call fdc_write_command
ld a,1					;; GPL  
call fdc_write_command
ld a,&ff					;; dtl
call fdc_write_command

di
ld de,0
;; for first byte
read_time_data_start:
in a,(c)			
jp p,read_time_data_start
and &20
jp nz,read_time_data
jp read_time_data_loop_end

;; for all other bytes
read_time_data_loop:
in a,(c)
inc de
jp p,read_time_data_loop
and &20
jp z,read_time_data_loop_end

read_time_data:
inc c
in a,(c)
dec c
jr read_time_data_loop

read_time_data_loop_end:
ei
push de
call fdc_result
pop de

;; sector to read
ld a,(sector)
inc a
cp &ca
jr nz,rtl
ld a,&c1
rtl:
ld (sector),a

;; store historical value
ld (ix+0),e
ld (ix+1),d
inc ix
inc ix
pop bc
dec b
jp nz,read_time_loop

call disc_motor_off
call display_historical_values
ret

display_historical_values:
ld ix,historical_values
ld b,0
ld c,22
loop_display_historical_values:
push bc
push ix
ld d,(ix+1)
call print_hex
ld e,(ix+0)
call print_hex
call crlf
pop ix
inc ix
inc ix
pop bc
dec c
jr nz,ldhv_nowait
push bc
call wait_key
call crlf
pop bc
ld c,22
ldhv_nowait:
djnz loop_display_historical_values
call wait_key
ret

disc_motor_off:
xor a
ld bc,&fa7e
out (c),a
ret



historical_values:
defs 256*2


dump_result:
ld ix,result_data

dump_result_data:
dr1:
push bc
ld a,(ix+0)
inc ix
call print_hex
ld a," "
call txt_output
pop bc
djnz dr1
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
call txt_output

call km_read_char
jp nc,dump_bytes2
call km_wait_char

dump_bytes2:
pop de
pop hl
inc h
ld a,h
cp 16
jr nz,rtig4
ld h,0
call crlf
inc l
ld a,l
cp 25
jr nz,rtig4
push hl
push de
call km_wait_char
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

wait_key:
ld hl,press_a_key_msg
call print_msg
call km_wait_char
ret

press_a_key_msg:
defb 10,13,10,13,"Press any key",0


;;-----------------------------------------------------------------

pick_drive:
ld hl,drive_msg
call print_msg

call km_wait_char
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
call txt_output
call crlf
ret

drive_msg:
defb "Drive (A or B):",0
;;-----------------------------------------------------------------

crlf:
ld a,10
call txt_output
ld a,13
call txt_output
ret


print_msg:
ld a,(hl)
inc hl
or a
ret z
call txt_output
jr print_msg


;;----------------------------------------------------------------------

cls:
ld a,2
call scr_set_mode
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
call fdc_write_command
ld a,(drive)					;; drive status of connected drive
call fdc_write_command
call fdc_result			;; status should show that drive is NOT READY!
ret

;;----------------------------------------------------------------------

sense_interrupt_status:
ld a,%1000						;; sense interrupt status
call fdc_write_command
call fdc_result
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
jp txt_output
print_hex_digit2:
add a,'0'
jp txt_output
;;----------------------------------------------------------------------

include "fdc.asm"

track_buffer: defb 1

end start