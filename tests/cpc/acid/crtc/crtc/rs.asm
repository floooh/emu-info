;; CRTC
;;
;; bits 0,1 of upper byte BIT 1 is /WR, bit 0 is RS
;;
;; /WR	RS
;; 0		0		Write register index (All)
;; 0		1		Write register data (All)
;; 1		0		Read status register (UM6845)
;; 1		1		Read register data (All)

;; bit 6 = lpen register full
;; bit 5 = vertical blanking

;; no carry = status register is present, carry = no status register

.check_status
call vsync_sync

;; check it 10 times
ld b,10
.cs1
push bc
call check_status_present
jr c,cs2				;; failed.

pop bc
djnz cs1

ld hl,status_found
call show_string

;; status register check passed
or a
ret

;; status register check failed
.cs2

ld hl,status_not_found
call show_string
scf
ret

;; this checks to see if status byte has a bit which matches
;; vsync signal. If it does, then we assume that the status
;; register exists.

.check_status_present
;; wait for start of vsync
ld b,&f5
.rs2 in a,(c)
rra
jr nc,rs2

;; in vsync now

ld b,&be
in a,(c)
and &20		;;%00100000
jr z,rs4

;; both vsync and status register bit are active

ld b,&f5
.rs3
in a,(c)
rra
jr  c,rs3

;; end of vsync

ld b,&be
in a,(c)
and &20	;;%00100000
jr nz,rs6

;; both vsync and status register bit are active

;; now, lets wait for status register bit to change
ld b,&be
.rs4
in a,(c)
and &20	;;%00100000
jr z,rs6

;; status says we are in vertical blanking

ld b,&f5
.rs5 
in a,(c)
rra
jr nc,rs6

;; vsync says we are in vertical blanking and so does status.
;; looks like status register exists

or a
ret


;; status register doesn't seem to exist...
.rs6
scf
ret


.status_found
defb "CRTC has status register.",13,10,0

.status_not_found
defb "CRTC doesn't have status register",13,10,0
