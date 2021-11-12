

ide_wait_execution:
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,ide_wait_execution 
ret

ide_wait_finish:
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,ide_wait_finish
bit 3,a
jr nz,ide_wait_finish
ret

ide_wait_data_or_error:
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,ide_wait_data_or_error 
bit 0,a
ret nz
bit 3,a
jr z,ide_wait_data_or_error
ret



do_count_read_data:
call ide_count_read_data
jr common_count_data


do_count_write_data:
call ide_count_write_data
common_count_data:
ld (ix+0),l
ld (ix+2),h
ld (ix+4),e
ld (ix+6),d
inc ix
inc ix

inc ix
inc ix

inc ix
inc ix

inc ix
inc ix
call ide_wait_finish
jp ide_read_registers

ide_wait_interrupt:
ld bc,&fd0f
wint:
in a,(c)
bit 7,a
jr nz,wint
bit 0,a
ld e,1
ret nz
bit 3,a
jr z,wint
ld e,0
ret


;; IX = command bytes
ide_write_command:
push ix

push hl
pop ix

;; send drive and head first
ld a,(ix+4)
ld bc,&fd0e
out (c),a

;; now send remaining values
ld bc,&fd0a
ld d,6
wc1:
ld a,(hl)
out (c),a
inc hl
inc c
dec d
jr nz,wc1
;; command has started
pop ix
ret

ide_write_data_with_count:
push de
call ide_write_data
pop hl
or a
sbc hl,de
ld (ix+0),l
inc ix
inc ix
ld (ix+0),h
inc ix
inc ix
ret

ide_read_data_with_count:
push de
call ide_read_data
pop hl
or a
sbc hl,de
ld (ix+0),l
inc ix
inc ix
ld (ix+0),h
inc ix
inc ix
ret


;; hl = buffer
;; de = size
ide_read_data:
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,ide_read_data
bit 3,a
ret z

ld bc,&fd08
in a,(c)
ld (hl),a
inc hl
in a,(c)
ld (hl),a
inc hl
dec de
dec de
ld a,d
or e
jr nz,ide_read_data

ret

ide_count_read_data:
ld hl,0
ld de,0

crd:
ld bc,&fd0f
in a,(c)
bit 7,a 
jr nz,crd
;; busy is clear, we can read the rest of the status register
;; drq set?
;; data to transfer?
bit 3,a
ret z

ld bc,&fd08
in a,(c)
in a,(c)
call update_count
jr crd

update_count:
ld a,l
add a,2
ld l,a
ld a,h
adc a,0
ld h,a
ld a,e
adc a,0
ld e,a
ld a,d
adc a,0
ld d,a
ret

ide_count_write_data:
ld hl,0
ld de,0

cwd:
ld bc,&fd0f
in a,(c)
bit 7,a 
jr nz,cwd
;; busy is clear, we can read the rest of the status register
;; drq set?
;; data to transfer?
bit 3,a
ret z

xor a
ld bc,&fd08
out (c),a
out (c),a
call update_count
jr cwd


;; hl = buffer
;; de = size
ide_write_data:
ld bc,&fd0f
in a,(c)
bit 7,a
jr nz,ide_write_data
bit 3,a
ret z

ld bc,&fd08
ld a,(hl)
out (c),a
inc hl
ld a,(hl)
out (c),a
inc hl
dec de
dec de
ld a,d
or e
jr nz,ide_write_data
ret

ide_read_registers:
ld bc,&fd09
ld d,7
rr1:
in a,(c)
ld (ix+0),a
inc c
inc ix
inc ix
dec d
jr nz,rr1
ret


ide_request_sense:
call fill_regs
ld a,(head_reg)
ld c,a
ld a,&ff
and %10101111
or c
ld bc,&fd0e
out (c),a
ld a,3
ld bc,&fd0f
out (c),a
call ide_wait_finish
jp ide_read_registers

set_lba:
ld a,(head_reg)
or %01000000
ld (head_reg),a
ret

clear_lba:
ld a,(head_reg)
and %10111111
ld (head_reg),a
ret

set_slave:
ld a,(head_reg)
or %10000
ld (head_reg),a
ret

set_master:
ld a,(head_reg)
and %11101111
ld (head_reg),a
ret

head_reg:
defb 0


ide_identify_device:
ld a,(head_reg)
ld c,a
ld a,&ff
and %10101111
or c
ld bc,&fd0e
out (c),a

ld a,&ec		;; identify device
ld bc,&fd0f
out (c),a

ld hl,read_data_buffer
ld de,512
call ide_read_data
call ide_wait_finish
ret

fill_regs:
ld a,(head_reg)
ld c,a
ld a,&ff
and %10101111
or c
ld bc,&fd0e
out (c),a

ld a,&11
ld bc,&fd0a
out (c),a
ld a,&22
ld bc,&fd0b
out (c),a
ld a,&33
ld bc,&fd0c
out (c),a
ld a,&44
ld bc,&fd0d
out (c),a
ret

fill_buffer_num:
ld bc,512
rb:
ld (hl),d
inc d
inc hl
dec bc
ld a,b
or c
jr nz,rb
ret


compare_read_write_buffers:
ld hl,write_data_buffer
ld de,read_data_buffer
ld bc,512
crwb:
ld a,(de)
cp (hl)
ld a,1
jr nz,crwb2
inc hl
inc de
dec bc
ld a,b
or c
jr nz,crwb
xor a
crwb2:
ret

set_defaults:
xor a
ld bc,&fd0e
out (c),a

;; disable idle->standby
xor a
ld bc,&fd0a
out (c),a
ld a,&97
ld bc,&fd0f
out (c),a
call ide_wait_finish

;; disable write cache
ld a,&82
ld bc,&fd09
out (c),a
ld a,&ef
ld bc,&fd0f
out (c),a
call ide_wait_finish


;; set pio mode, disable iordy
ld a,&3
ld bc,&fd09
out (c),a
ld a,1
ld bc,&fd0a
out (c),a
ld a,&ef
ld bc,&fd0f
out (c),a
call ide_wait_finish
ret

copy_result_fn:
ret

data_buffer:
read_data_buffer:
defs 1024
write_data_buffer:
defs 1024