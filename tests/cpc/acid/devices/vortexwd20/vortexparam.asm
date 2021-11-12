org &1000

cas_out_open equ &bc8c
cas_out_direct equ &bc98
cas_out_close equ &bc8f

start:
;; dump the vortex parameters to a file
ld hl,restore_command
call wd20_write_command
call wd20_read_result_and_error

ld hl,read_sector_command
call wd20_write_command
ld hl,param_data
ld de,512
call wd20_read_data
call wd20_read_result_and_error

ld b,end_param_filename-param_filename
ld hl,param_filename
ld de,&c000
call cas_out_open
ld hl,param_data
call cas_out_direct
call cas_out_close
ret


;; 0: drive
;; 1: head
;; 2: sector count
;; 3: sector number
;; 4: cylinder low
;; 5: cylinder high
;; 6: command
restore_command:
defb 0
defb 0
defb 0
defb 0
defb 0
defb 0
defb &10

read_sector_command:
defb 0
defb 0
defb 1
defb 0
defb 0
defb 0
defb &20

param_filename:
defb "param"
end_param_filename:

param_data:
defs 512


include "wd20common.asm"

end start