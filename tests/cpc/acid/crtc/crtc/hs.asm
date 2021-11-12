.hsync_analyze
ld hl,hsync_table
ld b,16
.ha1
ld a,b
sub 16
call show_byte
ld a,":"
call show_char

ld a,(hl)
inc hl
call show_byte
djnz ha1
ret



;;-----------------------------------------------------
;; programs in different hsync widths, uses interrupts
;; to count number of ints in a frame. If any HSYNC
;; value fails to generate any interrupts then the count
;; should be 0.


.hsync_check
ld hl,hsync_table
ld b,16
.hc1
push bc
ld a,b
dec a
or &80
ld bc,&bc03
out (c),c
inc b
out (c),a

call hs_test
ld (hl),a
inc hl

pop bc
djnz hc1
ret

.hsync_table
defs 16


.hs_test
di

;; sync width start of vsync just in case
call vsync_sync

;; init new interrupt handler
ld a,&c3
ld (&0038),a
ld hl,hsync_int
ld (&0039),hl

xor a
ld (hsync_count),a
ei

;; got start of vsync
ld b,&f5		
.hc2 in a,(c)
rra
jp nc,hc2

				;; 19968/(1+1+1+3) = 3328
ld bc,3328+1			;; [3]
.hc3 
dec bc				;; [1]
ld a,b				;; [1]
or c				;; [1]
jp nz,hc3			;; [3]

				;; want 19968 NOPs time

ld a,(hsync_count)
ret

.hsync_int
	di
	push hl
	ld hl,hsync_count
	inc (hl)
	pop hl
	ei
	ret

.hsync_count
	defb 0


