org &800

start:
ld bc,$fa7e
ld a,1
out (c),a

;; At this point interrupts must be enabled.
ld b,30 ;; 30/6 = 5 frames or 5/50 of a second.
w1:
;; there are 6 CPC interrupts per frame. This waits for one of them
halt
djnz w1

;; this is the drive we want to use
;; the code uses this variable.
ld a,0
ld (drive),a

;; recalibrate means to move the selected drive to track 0.
;;
;; track 0 is a physical signal from the drive that indicates when
;; the read/write head is at track 0 position.
;;
;; The drive itself doesn't know which track the read/write head is positioned over.
;; The FDC has an internal variable for each drive which holds the current track number.
;; This value is reset when the drive indicates the read/write head is over track 0.
;; The number is increased/decreased as the FDC issues step pulses to the drive to move the head
;; to the track we want.
;;
;; once a recalibrate has been done, both drive and fdc agree on the track.
;;
call fdc_recalibrate

ld a,90
ld (track),a
call fdc_seek
loop:
jp loop

;;===============================================
;; send command to fdc
;;

fdc_write_command:


ld bc,&fb7e					;; I/O address for FDC main status register
push af						;;
fwc1: in a,(c)				;; 
add a,a						;; 
jr nc,fwc1					;; 
add a,a						;; 
jr nc,fwc2					;; 
pop af						;; 
ret							

fwc2: 
pop af				;; 

inc c						;; 
out (c),a					;; write command byte 
dec c						;; 

;; some FDC documents say there must be a delay between each
;; command byte, but in practice it seems this isn't needed on CPC.
;; Here for compatiblity.
ld a,5				;;
fwc3: dec a			;; 
jr nz,fwc3			;; 
ret							;; 

;;===============================================
;; get result phase of command
;;
;; timing is not important here

fdc_result:

ld hl,result_data 
ld bc,&fb7e
fr1:
in a,(c)
cp &c0 
jr c,fr1
 
inc c 
in a,(c) 
dec c 
ld (hl),a 
inc hl 

ld a,5 
fr2: 
dec a 
jr nz,fr2
in a,(c) 
and &10 
jr nz,fr1


ret 

;;===============================================

;; physical drive 
;; bit 1,0 are drive, bit 2 is side.
drive:
defb 0

;; physical track (updated during read)
track:
defb 0

;;===============================================

fdc_seek:
ld a,%0000001111    ;; seek command
call fdc_write_command
ld a,(drive)
call fdc_write_command
ld a,(track)
call fdc_write_command

call fdc_seek_or_recalibrate
jp nz,fdc_seek
ret

;;===============================================

fdc_recalibrate:

;; seek to track 0
ld a,%111						;; recalibrate
call fdc_write_command
ld a,(drive)					;; drive
call fdc_write_command

call fdc_seek_or_recalibrate
jp nz,fdc_recalibrate
ret

;;===============================================
;; NZ result means to retry seek/recalibrate.

fdc_seek_or_recalibrate:
ld a,%1000						;; sense interrupt status 
call fdc_write_command
call fdc_result

;; recalibrate completed?
ld ix,result_data
bit 5,(ix+0)            ;; Bit 5 of Status register 0 is "Seek complete"
jr z,fdc_seek_or_recalibrate
bit 4,(ix+0)          ;; Bit 4 of Status register 0 is "recalibrate/seek failed"
;;
;; Some FDCs will seek a maximum of 77 tracks at one time. This is a legacy/historical
;; thing when drives only had 77 tracks. 3.5" drives have 80 tracks.
;;
;; If the drive was at track 80 before the recalibrate/seek, then one recalibrate/seek 
;; would not be enough to reach track 0 and the fdc will then report an error (meaning
;; it had seeked 77 tracks and failed to reach the track we wanted).
;; We repeat the recalibrate/seek to finish the movement of the read/write head.
;;
ret

;;===============================================

result_data:
defs 8

end start