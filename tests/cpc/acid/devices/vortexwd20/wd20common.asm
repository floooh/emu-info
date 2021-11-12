

;; read result and error
wd20_read_result_and_error:
ld bc,&fbfb
in a,(c)
ld (ix+0),a
inc ix
ld bc,&f9f9
in a,(c)
ld (ix+0),a
inc ix
ret


;;ld ix,result_buffer
;;ld hl,cmd_stat_read_sectors
;;call write_command

;; 0: drive
;; 1: head
;; 2: sector count
;; 3: sector number
;; 4: cylinder low
;; 5: cylinder high
;; 6: command

wd20_write_command:
ld a,(hl) ;; drive
inc hl
add a,a
add a,a
add a,a
ld c,a
ld a,(hl) ;; head
inc hl
and &7
or c
;; size??
ld bc,&fafa ;; drive/head select
out (c),a
ld bc,&fbfa ;; wd1010 head/select
out (c),a
ld a,(hl)
inc hl
ld bc,&f9fa ;; sector count
out (c),a
ld a,(hl)
inc hl
ld bc,&f9fb ;; sector number
out (c),a
ld a,(hl)
inc hl
ld bc,&faf8 ;; cylinder low
out (c),a
ld a,(hl)
inc hl
ld bc,&faf9 ;; cylinder high
out (c),a
ld a,(hl)
inc hl
ld bc,&fbfb
out (c),a	;; command
;; command started
ret

wd20_read_data:
ld bc,&fbfb
in a,(c)
bit 7,a
jr nz,wd20_read_data
bit 3,a
ret z

ld bc,&f9f8
in a,(c)
ld (hl),a
inc hl
ld a,d
or c
jr nz,wd20_read_data
ret


wd20_read_data_count:
ld bc,&fbfb
in a,(c)
bit 7,a
jr nz,wd20_read_data_count
bit 3,a
ret z

ld bc,&f9f8
in a,(c)
inc de
jr wd20_read_data_count

wd20_write_data:
ld bc,&fbfb
in a,(c)
bit 7,a
jr nz,wd20_write_data
bit 3,a
ret z

ld bc,&f9f8
ld a,(hl)
out (c),a
inc hl
ld a,d
or c
jr nz,wd20_write_data
ret


wd20_write_data_count:
ld bc,&fbfb
in a,(c)
bit 7,a
jr nz,wd20_write_data_count
bit 3,a
ret z

ld bc,&f9f8
xor a
out (c),a
inc de
jr wd20_read_data_count

