
write_fdc:

push    af
push    af
write_fdc2:
in      a,(c)			; read FDC main status register
add     a,a				; transfer bit 7 ("data ready") to carry
jr      nc,write_fdc2         
add     a,a				; transfer bit 6 ("data direction") to carry
jr      nc,write_fdc3

;; conditions not met: fail
pop     af
pop     af
ret     

;;--------------------------------------------------------
;; conditions match to write command byte to fdc
write_fdc3:
pop     af
inc     c				; BC = I/O address for FDC data register
out     (c),a			; write data to FDC data register
dec     c				; BC = I/O address for FDC main status register

;; delay

ld      a,&5
fdc_write2:
dec     a
nop     
jr      nz,fdc_write2         

;; success
pop     af
ret     

restore_fdc:
ld a,(fdc_detected)
or a
ret z

call reset_fdc

;; re-send specify
ld a,3
call write_fdc
ld a,&c*16+1
call write_fdc
ld a,3
jp write_fdc

reset_fdc:
ld bc,&fb7e

resfdc1:
in a,(c)
bit 4,a			;; busy?
jr nz,resfdc2
;; write bytes until it goes busy
inc c
ld a,&80
out (c),a
dec c
jr resfdc1

resfdc2:
in a,(c)
bit 4,a
ret z
inc c
bit 6,a
jr nz,resfdc5
xor a
out (c),a
jr resfdc4
resfdc5:
in a,(c)
resfdc4:
dec c

;; delay longer than 32us
ld e,32
resfdc3:
ex      (sp),hl
dec e
jr nz,resfdc3
jr resfdc2

fdc_detected:
defb 0

detect_fdc: 
xor a
ld (fdc_detected),a

ld      bc,&fb7e			; BC = I/O address of FDC main status register
ld      e,&00			; initial retry count

fdc_detect2:
or      a
dec     e				; decrement retry count
ret     z				; quit if fdc was not ready 

in      a,(c)			; read main status register
and     &c0				; isolate data direction and data ready status flags

xor     &80				; test the conditions 1) data direction: cpu->fdc, 2) fdc ready to accept data
jr      nz,fdc_detect2			; loop if conditions were not correct...

;; to get here, data direction must be from cpu to fdc
;; and fdc must be ready to accept data

inc     c				; BC = FDC data register
out     (c),a			; write command byte (0 = "invalid")
dec     c				; BC = FDC main status register

;; delay 
ex      (sp),hl
ex      (sp),hl
ex       (sp),hl
ex      (sp),hl

;; initialise retry count with 0
ld      e,a

;; check for start of result phase
;;
;; the result phase must activate within 256 reads of the main status register

fdc_detect3:
dec     e				; decrement retry count
ret     z				; quit if fdc was not ready

in      a,(c)			; read main status register
cp      &c0				; test the conditions 1) data direction: fdc->cpu 2) fdc has data ready
jr      c,fdc_detect3          ; loop if conditions were not correct...

;; to get here, the result phase must be active

inc     c				; BC = FDC data register
in      a,(c)			; read data
xor     &80				; is data=&80? (&80 = status for invalid command)
ret     nz				; quit if wrong result was returned..

;; fdc was detected, fdc processed "invalid" command, and returned the correct results.
ld a,1
ld (fdc_detected),a
ret     
