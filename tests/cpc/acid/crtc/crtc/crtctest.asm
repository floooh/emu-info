;; CRTC test code
;; by Kevin Thacker 1999-2001
;;
;; This source code is released under the GNU Public License version 2 or later.
;; Please see the "Copying" file that is distributed with this source code.
;;
;; This source code is written for a Maxam compatible assembler (such as the 
;; assembler built into WinAPE emulator).
;;
;; How does it work:
;;
;; a lot of these tests work by testing the vsync signal from the crtc.
;;
;; the Amstrad CPC can only detect the vsync signal
;; directly from the CRTC because it is connected to bit 0 of PPI Port B.
;;
;; it is possible to detect the HSYNC indirectly,
;; as the HSYNC is used to generate the CPC standard raster interrupt.
;;
;; TODO:
;; - test to see how changing MA at various points will affect next split address
;; - test to see how changing RA at various points will affect split
;; - test to see how changing VT at various points will affect split
;; - test to see how changing vertical adjust at various points
;; - test adjusting R1 to see how this will effect things

.delay_pause equ 64*9

;;  these are the number of nop cycles/1us cycles in a 50hz frame
.vsync_timeout  equ     19968

org &4000
nolist
write"crtctest.bin"

;;-------------------------------------------------------

;; printer (y/n)?
ld hl,&bb5a
ld (display_char+1),hl
ld hl,question
call display_string
call &bb06
ld hl,&bd31
cp "Y"
jr z,nt1
cp "y"
jr z,nt1
ld hl,&bb5a
.nt1
ld (display_char+1),hl

;; store interrupt vector
call store_int

;; do the test routines
ld ix,test_routines

.next_test
call crtc_reset

ld l,(ix+0)
ld h,(ix+1)
ld a,h
or l
jp z,test_done
inc ix
inc ix
push ix
di
call call_hl
pop ix
jp next_test

.test_done
call crtc_reset

;; dump the results


;; restore interrupt vector
call restore_int
ei
ret

.call_hl
jp (hl)

;;---------------------------------------------------------

.display_char
jp &bb5a

.display_string
ld a,(hl)
inc hl
or a
ret z
call display_char
jp display_string

.display_decimal
ret

.display_hex
push af
rrca
rrca
rrca
rrca
call display_digit
pop af
.display_digit
and &f
cp 10
jr c,dd1
add a,"A"-10
jr dd2
.dd1
add a,"0"
.dd2
jp display_char

.display_crlf
ld a,10
call display_char
ld a,13
call display_char
ret

;; hl = list
;; b = count
.display_number_list
ld c,b
.dnl1
ld a,c
sub b
call display_hex
ld a," "
call display_char
ld a,":"
call display_char
ld a," "
call display_char
ld a,(hl)
inc hl
call display_hex
call display_crlf
djnz dnl1
ret



.question
defb "Output to printer (Y/N)?",13,10,0

;; vc comparison

.test_routines
;; tests for programmable vsyncs
defw vsync_len_check
;; tests for linecounter incrementing during vertical adjust
defw vsync_line_check
;; tests for programmed hsync values that do not generate a interrupt
defw crtc_check_hsync_generated


defw 0

defw mr_comp3_check
defw vsync_pos_change_possible
defw vsync_exact_pos
defw detect_isv
defw vadj_comp_check
defw vtot_comp_check
defw mr_comp_check
defw mr_comp2_check
defw vsync_pos_check
defw vtot_check
defw vtot2_check
defw vsync_len_cut
defw detect_isv
defw crtc_check_hsync_generated
defw crtc_reg_changes
defw crtc_check_be_equals_bf
defw crtc_check_reg_or_masks
defw crtc_check_reg_and_masks
defw crtc_check_regs2_readable
defw crtc_check_regs_readable
defw crtc_bf_all_same
defw crtc_results
defw 0


;;-----------------------
;; hl = start of buffer
;; bc = length of buffer
;; carry set = not all same, carry clear = all same

.check_all_same
;; get first
ld a,(hl)
inc hl
dec bc

.cas1
;; count over?
ld a,b
or c
jr z,cas2
;; decrement counter
dec bc
;; get next byte
xor (hl)
;; increment buffer ptr
inc hl
jp nz,cas3

jp cas1

.cas2
or a
ret

.cas3
scf
ret

;;-----------------------

;; sync with start of vsync
.vsync_sync
ld b,&f5
;; wait for vsync start
.vs1 in a,(c)
rra
jr nc,vs1
;; wait for vsync end
.vs2 in a,(c)
rra 
jr c,vs2
ret


;;---------------------------
;; count the number of scan-lines 
;; that the vsync is active for this will
;; be the duration of the vsync
.count_vsync_lines
push bc
push de

;; sync with start of vsync
call vsync_sync

;; wait for start of vsync
ld e,0
ld b,&f5
.cvl1 in a,(c)
rra
jp nc,cvl1
;; got vsync. At least one line has occured.
inc e

nop
ld a,15         ;; [2]
.cvl1a dec a    ;; [1]
jp nz,cvl1a     ;; [3]
                ;; [15*4 + 2 + 1] = [64] 
;;defs 64-1

;; check each line
.cvl2
in a,(c)
rra
jp nc,cvl3
inc e

nop
nop
ld a,12         ;; [2]
.cvl1b dec a    ;; [1]
jp nz,cvl1b     ;; [12*4 + 2 + 2] = 52

;;defs 64-1-3-1-4-3
jp cvl2

;; vsync has ended
.cvl3
ld a,e
pop de
pop bc
ret

;;--------------------------------------
;; program different vsync lengths into
;; the vsync/hsync register (register 3)
;; 
;; if a vsync occurs then time the length
;; of the vsync.
;;
;; this test will find:
;;
;; - if vsync length can be programmed
;; (table will hold length of vsync in scanlines)
;;
;; - if any programmed value fails to generate
;; a vsync (value will be 0 in table)

.vsync_len_check
di
ld hl,vsync_len_table
ld b,16
ld c,0
.vlec1
push bc
push bc
;; set a default vsync length
ld bc,&bc03
out (c),c
ld bc,&bc8e
out (c),c
pop bc
;; wait for start and end of vsync
call vsync_sync

;; set new vsync width
ld b,&bc
ld a,3
out (c),a
inc b
ld a,c
add a,a
add a,a
add a,a
add a,a
or &e
out (c),a

;; did a vsync occur?
call check_vsync_occured

;; if yes, count the number of lines it takes...
ld a,0
call nc,count_vsync_lines

;; store number of lines
ld (hl),a
inc hl
pop bc
inc c
djnz vlec1

ei
call crtc_reset
call vsync_len_report
ret

;; stores length of vsync in scanlines for
;; each vsync length setting
.vsync_len_table
defs 16

.vsync_len_report
ld hl,vsync_len_table
ld bc,16
call check_all_same
jr nc,vlr1
;; not all the same
ld hl,vsync_len_table
inc hl
ld b,15
.vlr2
ld a,16
sub b
cp (hl)
inc hl
jr nz,vlr3
djnz vlr2
ld hl,vsync_len_text2
call display_string
jp vlr4
.vlr3
ld hl,vsync_len_text3
call display_string
jp vlr4

;; all the same
.vlr1
ld hl,vsync_len_text1
call display_string

;; dump values
.vlr4
ld hl,vsync_len_table
ld b,16
call display_number_list
ret

.vsync_len_text1
defb "Vsync width is the same for all programmed values. Vsync width can't be defined!",13,10,0
.vsync_len_text2
defb "Vsync width is exactly the same as programmed value (not counting vsync width of 0)",13,10,0
.vsync_len_text3
defb "Vsync width does not correspond to the programmed values",13,10,0

;;------------------------
;; waits for a vsync to occur
;; carry set = no vsync, carry clear = vsync seen

.check_vsync_occured
push af
push de
push bc

ld b,&f5
ld de,vsync_timeout
.cvo
in a,(c)
rra
jp c,cvo2
dec de
ld a,d
or e
jp nz,cvo

pop bc
pop de
pop af
scf
ret

.cvo2
pop bc
pop de
pop af
or a
ret

;;------------------------------------------
;; this test will find if vertical line counter is
;; incremented during vertical adjust, and as a result
;; if a vertical sync can be triggered when the vsyncpos>vertical total
;;

.vsync_line_check
di
ld hl,vsync_line_table
;; initial vsync pos
ld a,38-2
.vlc1
push af

push af
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
call vsync_sync
pop af

;; set vsync pos
ld bc,&bc07
out (c),c
inc b
out (c),a

;; try max r5 value
ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c

;; did a vsync occur?
call check_vsync_occured
jr c,vlc6

;; yes
ld b,&f5
.vlc1a
in a,(c)
rra
jr c,vlc1a

;; yes one did... so we check the actual reg 5 value...

;; work out vadj that would allow the vsync to occur with
;; this vsync pos
ld b,32
xor a
.vlc2
push bc
push af

ld bc,&bc05
out (c),c
inc b
out (c),a
ld (hl),a

;; check if vsync occured
call check_vsync_occured
jr nc,vlc3

;; no, try next value
pop af
inc a
pop bc
djnz vlc2

.vlc6
;; no vadj value will let vsync work with
;; programmed vsync position
ld (hl),&ff
jr vlc4

;; we found a vadj that will let vsync occur
.vlc3
pop af
pop bc
.vlc4
inc hl
pop af
inc a
cp 50
jp nz,vlc1

ei
call crtc_reset
ld hl,vsync_line_table
ld b,50-36
call display_number_list
ret

;; minimum reg 5 value that will cause vsync to occr
.vsync_line_table
defs 50-36



;;-------------------------------------------

.crtc_reset
ld hl,crtc_default_values
ld b,16
ld c,0
.cr1
push bc
ld b,&bc
out (c),c
inc b
ld a,(hl)
inc hl
out (c),a
pop bc
inc c
djnz cr1
call vsync_sync
call vsync_sync
ret

.crtc_default_values
defb 63,40,46,&8e,38,0,25,30,0,7,0,0,&30,0,0,0,0

;;--------------------------------------------------
;; this is used to find programmed hsync values that
;; will cause a hsync and therefore cause a interrupt to be generated

.crtc_check_hsync_generated

;; setup a new int
di
ld a,&c3
ld hl,int_count
ld (&0038),a
ld (&0039),hl
ei

ld hl,hsync_gives_ints
ld b,16
xor a
.hst1 push af
push bc

;; specify horizontal sync width (vsync is fixed)
ld bc,&bc03
out (c),c
inc b
or &80
out (c),a

;; reset counter
xor a
ld (counter),a

call vsync_sync
call vsync_sync
call vsync_sync

;; if counter!=0 this means a int occured. This also
;; means that a hsync was generated.
ld a,(counter)
or a
ld a,1
jr nz,vs7
xor a
.vs7
ld (hl),a
inc hl

pop bc
pop af
inc a
djnz hst1

di
call int_restore
ei

ld hl,hsync_gives_ints
ld b,16
call display_number_list
ret

.hsync_gives_ints
defs 16



.int_count
push af
ld a,(counter)
inc a
ld (counter),a
pop af
ei
ret

.counter
defb 0

;;-------------------------------

.old_int
defs 3

.store_int
di
ld hl,&0038
ld de,old_int
ld bc,3
ldir
ei
ret

.restore_int
di
ld hl,old_int
ld de,&0038
ld bc,3
ldir
ei
ret

;;----------------------------




;;*******************************************


;;-------------------------------------------

.vsync_exact_pos
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

call vsync_sync
call vsync_sync

ld b,&f5
.vep1 in a,(c)
rra
jr nc,vep1

;; wait until end of vsync signal
ld a,18
call wait_x_lines

ld bc,&bc07
out (c),c
ld bc,&bd04
out (c),c
call count_lines_to_vsync
ld (vep2),a
ret

.vep2
defw 0

;;-------------------------------------------

.vsync_pos_change_possible
;; vsync at frame start
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

;; wait for first vsync
call vsync_sync

ld b,&f5
.vpcp1 in a,(c)
rra
jr nc,vpcp1

;; wait for vsync to end (at least 16 lines for non-programmable
;; vsync lengths)
ld a,18
call wait_x_lines

;; set new vsync
ld bc,&bc07
out (c),c
ld bc,&bd00+6
out (c),c

;; wait until we are a few lines into the vsync signal (assuming
;; it has begun)
ld a,48-18+2
call wait_x_lines

;; check if vsync started...
ld b,&f5
in a,(c)
rra
ld a,1
jr c,vpcp2
ld a,0
.vpcp2
ld (vsync_change_possible),a
ret

.vsync_change_possible
defb 0

;;-------------------------------------------

;; if the vsync counter is active, but a new vsync width
;; is programmed, will it take effect? (only applies
;; to crtc's where the vsync is programmable?)
.vsync_len_cut
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

;; vsync is 8 lines long
ld bc,&bc03
out (c),c
ld bc,&bd00+&8e
out (c),c

;; sync so that if we wait for a vsync it will be the start
call vsync_sync
;; wait for start of vsync
ld b,&f5
.vlcu1
in a,(c)
rra
jr nc,vlcu1

ld a,6
call wait_x_lines

;; attempt to cut it by writing a value which is less
;; than current counter value...
ld bc,&bc03
out (c),c
ld bc,&bd00+&4e
out (c),c

;; count lines to vsync end
ld b,&f5
ld e,0
;; check each line
.vlcu2
in a,(c)
rra
jp nc,vlcu3
inc e
ld a,12
.vlcu3
dec a
jp nz,vlcu4
nop
nop
jp vlcu2

;; vsync has ended
.vlcu4
ld a,e
ld (vsync_cut_len),a
ret

.vsync_cut_len
defb 0


.crtc_detect_reg_change
push hl
push de

;; timeout
ld de,19968

;; get current value
in a,(c)
ld l,a

.dc1
;; read current val
in a,(c)
;; different?
xor l
jp nz,dc2

;; no
dec de
ld a,d
or e
jp nz,dc1

;; didn't change
pop de
pop hl
scf
ret


;; changed
.dc2
pop de
pop hl
or a
ret

;;------------------------------------------

.crtc_reg_changes
ld hl,reg_changed

;; select reg 12
ld bc,&bc0c
out (c),c

ld b,&bc
call crtc_detect_reg_change
ld a,1
jr nc,crc1
ld a,0
.crc1
ld (hl),a
inc hl

ld b,&bd
call crtc_detect_reg_change
ld a,1
jr nc,crc2
ld a,0
.crc2
ld (hl),a
inc hl

ld b,&be
call crtc_detect_reg_change
ld a,1
jr nc,crc3
ld a,0
.crc3
ld (hl),a
inc hl

ld b,&bf
call crtc_detect_reg_change
ld a,1
jr nc,crc4
ld a,0
.crc4
ld (hl),a
ret

;; 1 = reg changed, 0 = didn't change.
.reg_changed
defs 4

;;------------------------------------------------------------------------

.crtc_check_be_equals_bf
push hl
push de
push bc

ld c,&00
ld e,0
.ccbef1
;; specify reg
ld b,&bc
out (c),c

;; read &be
ld b,&be
in l,(c)
;; read &bf
ld b,&bf
in h,(c)

;; different?
ld a,h
xor l
jr nz,ccbef2

inc c
dec e
jr nz,ccbef1
pop bc
pop de
pop hl
;; not different!
ld a,1
ld (be_equal_bf),a
ret

;; different!
.ccbef2
pop bc
pop de
pop hl
xor a
ld (be_equal_bf),a
ret


.be_equal_bf
defb 0

;;--------------------------------------------------------

.crtc_check_reg_readable
ld b,&bc
out (c),c

ld c,&3f
.ccrr1
;; program new value
ld b,&bd
out (c),c
;; read back programmed value
ld b,&bf
in a,(c)
xor c
jr nz,ccrr2

dec c
jp nz,ccrr1
;; reg is readable
ld a,1
ret

;; reg not readable
.ccrr2
ld a,0
ret

.crtc_check_regs_readable
ld b,32
ld hl,crtc_reg_readable_table
ld c,0
.ccrrr1 push bc
push hl
call crtc_check_reg_readable
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz ccrrr1
ret

.crtc_reg_readable_table
defs 32


;;---------------------------------------------------------

.crtc_check_reg2_readable
;; get and value
ld hl,crtc_and_table
ld a,l
add a,c
ld l,a
ld a,h
adc a,0
ld h,a

ld a,(hl)
or a
jp z,c2crr2

;; specify reg 
ld b,&bc
out (c),c

;; write 0...255
ld c,&ff
.c2crr1 push bc

;; program new value
ld b,&bd
out (c),c

;; work out this value and'd
ld a,c
and (hl)
ld e,a

;; read back programmed value
ld b,&bf
in a,(c)
;; and it with reg and mask
and (hl)
;; compare to our value we wrote and'd
cp e
jr nz,c2crr3
;; same

pop bc
dec c
jp nz,c2crr1
;; reg is readable
ld a,1
ret

.c2crr3
pop bc
;; reg not readable
.c2crr2
ld a,0
ret



.crtc_check_regs2_readable
ld b,32
ld hl,crtc_reg_rable2_table
ld c,0
.cc2rrr1 push bc
push hl
call crtc_check_reg2_readable
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz cc2rrr1
ret

.crtc_reg_rable2_table
defs 32

;;--------------------------------------------------------

.crtc_check_reg_and_masks
ld b,32
ld hl,crtc_and_table
ld c,0
.ccram1 push bc
push hl
call crtc_reg_and_mask
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz ccram1
ret

.crtc_reg_and_mask
ld b,&bc
out (c),c

;; write &ff
ld c,&ff
ld b,&bd
out (c),c
ld b,&bf
in a,(c)
ld d,a          ;; get data and or mask

;; write 0
ld c,0
ld b,&bd
out (c),c
ld b,&bf
in a,(c)
ld e,a          ;; get or mask only 

ld a,e
cpl
and d
ret


.crtc_check_reg_or_masks
ld b,32
ld hl,crtc_or_table
ld c,0
.ccrom1 push bc
push hl
call crtc_reg_or_mask
pop hl
pop bc
ld (hl),a
inc hl
inc c
djnz ccrom1
ret

.crtc_reg_or_mask
ld b,&bc
out (c),c

;; write 0
ld c,0
ld b,&bd
out (c),c
ld b,&bf
in a,(c)
ld e,a          ;; get or mask only 
ret

.crtc_and_table
defs 32

.crtc_or_table
defs 32

;;--------------------------------------------------------


.crtc_bf_all_same
push hl
push de
push bc

ld c,&00
ld e,0
.cbas1
;; specify reg
ld b,&bc
out (c),c

;; read port
ld b,&bf

ld a,e
or a
jr nz,cbas2
;; 1st read, so fetch initial value into l

in l,(c)
jr cbas3

.cbas2
;; subsequent reads. Compare value read against L (1st read value)
in a,(c)
xor l
jr nz,cbas4

.cbas3
inc c
dec e
jr nz,cbas1
pop bc
pop de
pop hl
;; not different!
ld a,1
ld (bf_all_same),a
ret

;; different!
.cbas4
pop bc
pop de
pop hl
xor a
ld (bf_all_same),a
ret


.bf_all_same
defb 0

;;--------------------------------------------------------

.crtc_results
;; READ FROM &BC
ld hl,crtc_read_results
ld c,&00
ld e,0
.rd1
;; specify reg
ld b,&bc
out (c),c
;; read back 
ld b,&bc
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd1

;; READ FROM &BD
ld c,&00
ld e,0
.rd2
;; specify reg
ld b,&bc
out (c),c
;; read back 
ld b,&bd
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd2


;; READ FROM &BE
ld c,&00
ld e,0
.rd3
;; specify reg
ld b,&bc
out (c),c
;; read back from &be
ld b,&be
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd3

;; READ FROM &BF

ld c,&00
ld e,0
.rd4
;; specify reg
ld b,&bc
out (c),c
;; read back
ld b,&bf
in a,(c)

;; store
ld (hl),a
inc hl
inc c
dec e
jr nz,rd4
ret

.crtc_read_results equ $
.mr_vals equ $+1024




;;--------------------------------

.detect_isv
di
ld hl,&c9fb
ld (&0038),hl
ei

ld bc,&bc08
out (c),c
ld bc,&bd03
out (c),c

;; if CRTC type 1, then we will see a VSYNC after (((38+1)*8)/2)=156 scanlines
;; ints occur on lines 2,54,106,158,210,262.

;; sync with start of vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync
ld b,&f5

.di1 in a,(c)
rra
jr nc,di1
.di3
in a,(c)
rra
jr c,di3

halt
;; 54
halt
;; 106
halt
;; 158

;; if CRTC type is 1, we will be 2 scans into the VSYNC signal.
in a,(c)
rra
ld a,1
jr c,di2

;; interlace sync and video mode not like CRTC type 1.
ld a,&ff

.di2
ld (isv_like_crtc),a
ret

;; reports the CRTC type that has the same operation as the Interlace
;; Sync and Video mode reported.
.isv_like_crtc
defb 0


;;--------------------------------

.vtot_comp_check
ld a,18
ld (vtcc2+1),a

ld de,vtot_lines_table
ld b,200
.vtcc1 push bc
push de
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+38
out (c),c

call vsync_sync
call vsync_sync

ld b,&f5
.vtcc in a,(c)
rra
jr nc,vtcc
.vtcc2
ld a,18
call wait_x_lines
;; set new vtot.....
ld bc,&bc04
out (c),c
ld bc,&bd00
out (c),c
;; count lines until vsync starts...
call count_lines_to_vsync
pop de
;; store line count
ld (de),a
inc de

ld a,(vtcc2+1)
inc a
ld (vtcc2+1),a
pop bc
djnz vtcc1
ret

.vtot_lines_table
defs 200*2

.vadj_comp_check
;; init wait lines routine.
ld a,40  ;;-1               
ld (vcc4+1),a

ld hl,vadj_comp_table
ld b,32
.vcc1
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
;; frame is only 4 lines tall
ld bc,&bc04
out (c),c
ld bc,&bd00+5-1
out (c),c
;; vadj to max
ld bc,&bc05
out (c),c
ld bc,&bd00+31
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.vcc7 in a,(c)
rra
jr nc,vcc7
;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
.vcc4
ld a,32
call wait_x_lines

;; set new vadj.....
ld bc,&bc05
out (c),c
ld bc,&bd00
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vcc4+1)
inc a
ld (vcc4+1),a

pop bc
dec b
jp nz,vcc1
ret

.vadj_comp_table
defs 32


;;--------------------------------

.mr_comp_check
;; init wait lines routine.
ld a,32  ;;-1               
ld (mcc4+1),a

ld hl,mr_comp_table
ld b,8
.mcc1
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
;; 8 lines per char line
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

;; sync with vsync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.mcc7 in a,(c)
rra
jr nc,mcc7

;; set new vsync pos position to char line after the one we are changing!
ld bc,&bc07
out (c),c
ld bc,&bd05
out (c),c

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
.mcc4
ld a,32
call wait_x_lines

;; set new mr.....
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(mcc4+1)
inc a
ld (mcc4+1),a

pop bc
dec b
jp nz,mcc1
ret

.mr_comp_table
defs 8


;;---------------------------------

.mr_comp2_check
;; init wait lines routine.
ld a,32  ;;-1               
ld (m2cc4+1),a

ld hl,mr_comp2_table
ld b,8
.m2cc1
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+5-1
out (c),c

;; 8 lines per char line
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.m2cc7 in a,(c)
rra
jr nc,m2cc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
.m2cc4
ld a,32
call wait_x_lines

;; set new mr.....
ld bc,&bc09
out (c),c
ld bc,&bd00
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(m2cc4+1)
inc a
ld (m2cc4+1),a

pop bc
dec b
jp nz,m2cc1
ret

.mr_comp2_table
defs 8



.mr_comp3_check
ld hl,0
ld (write_delay),hl

ld hl,mr_vals
ld bc,512
.m3cc1
push bc
push hl


call setup_write

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

ld bc,&bc04
out (c),c
ld bc,&bd00+5-1
out (c),c

;; 8 lines per char line
ld bc,&bc09
out (c),c
ld bc,&bd07
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.m3cc7 in a,(c)
rra
jr nc,m3cc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
ld a,32
call wait_x_lines

;; set new mr.....
ld bc,&bc09
out (c),c
ld bc,&bd00
call do_write

pop hl
ld (hl),a
inc hl

call update_write_delay

pop bc
dec bc
ld a,b
or c
jp nz,m3cc1
ret


;;--------------------------------

.count_lines_to_vsync
;; vsync i/o
ld b,&f5
;; line counter
ld e,0

;; check vsync...
.cltv1 in a,(c)
rra
jp c,cltv2
;; vsync not occured yet

;; pause a bit
nop
nop
ld a,12
.cltv3 dec a
jp nz,cltv3

;; increment counter
inc e
jp nz,cltv1

;; counter wrapped..! vsync did not occur within 256 lines.

ld a,&ff
ret

;; start of vsync found
.cltv2
ld a,e
ret

;;------------------------

;; wait at least 2 lines
.wait_x_lines
dec a

.wxl1
ld e,14
.wxl1b dec e
jp nz,wxl1b
nop
nop
dec a
jp nz,wxl1

ld a,13
.wxl3
dec a
jp nz,wxl3
nop
ret

;;------------------------

;; syncs with a vsync on char line 0, then waits for x lines before
;; setting a new vsync pos. When the vsync pos is programmed
;; raster counter is not 0. We see if a VSYNC occurs within 8 lines.
;; if it does occur, we can assume that programming a VSYNC pos
;; within a line counter to the value of that line counter will
;; trigger a vsync to occur!

.vsync_pos_check
ld a,32-1               
ld (vpc4+1),a

ld hl,vsync_pos_table
ld b,8
.vpc1
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c

;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.vpc7 in a,(c)
rra
jr nc,vpc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
.vpc4
ld a,32
call wait_x_lines
;; still within a line....

;; set new vsync.....
ld bc,&bc07
out (c),c
ld bc,&bd04
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vpc4+1)
inc a
ld (vpc4+1),a

pop bc
djnz vpc1
ret

.vsync_pos_table
defs 8


.vtot_check
ld a,32-1               
ld (vtc4+1),a

ld hl,vtot_table
ld b,16
.vtc1
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+39
out (c),c
;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.vtc7 in a,(c)
rra
jr nc,vtc7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
.vtc4
ld a,32
call wait_x_lines
;; still within a line....

;; set new vsync.....
ld bc,&bc04
out (c),c
ld bc,&bd04
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vtc4+1)
inc a
ld (vtc4+1),a

pop bc
djnz vtc1
ret

.vtot_table
defs 16


.vtot2_check
ld a,32-1               
ld (vt2c4+1),a

ld hl,vtot2_table
ld b,16
.vt2c1
push bc
push hl

;; vsync at char line 0
ld bc,&bc07
out (c),c
ld bc,&bd00
out (c),c
ld bc,&bc04
out (c),c
ld bc,&bd00+4
out (c),c
;; sync with vsync
call vsync_sync
call vsync_sync

;; wait for start of vsync (it will being on
;; RasterLine = 0, LineCounter = 0.)

ld b,&f5
.vt2c7 in a,(c)
rra
jr nc,vt2c7

;; wait at least 16 lines (for CRTC's without programmable
;; VSYNC lengths)
.vt2c4
ld a,32
call wait_x_lines
;; still within a line....

;; set new vsync.....
ld bc,&bc04
out (c),c
ld bc,&bd00+5
out (c),c

;; count number of lines to vsync start
call count_lines_to_vsync
pop hl
ld (hl),a
inc hl

;; wait one more line next time around...
ld a,(vt2c4+1)
inc a
ld (vt2c4+1),a

pop bc
djnz vt2c1
ret

.vtot2_table
defs 16


.update_write_delay
push hl
ld hl,(write_delay)
inc hl
ld (write_delay),hl
pop hl
ret

;; HL = delay from 0 to delay_pause.
.setup_write
ld de,(write_delay)
ld hl,end_write_nop_pause
or a
sbc hl,de
ld (do_write+1),hl
ret

.write_delay defw 0
;;-------------------------------------------------
;; the following routine is used to time the number
;; of lines following a write until the vsync occurs.
;; 
;; setup do_write to point into write_nop_pause area
;; which contains the OUT (C),C to execute, and pause before
;; and pause after.

.do_write
jp 0

.start_write_nop_pause
defs delay_pause
                          ;; space for pause before and after, 
                          ;; + some opcodes to perform.
.end_write_nop_pause

out (c),c                 ;; do write

defs 64-2-2

ld b,&f5
ld e,0

.vsync_catch

in a,(c)                  ;; get vsync state
rra                       
jp c,vsync_caught

;; no vsync
inc e
defs 64-4-1-3-1-3         ;; (delay so each vsync check is in same
                          ;; place but next line)
jp vsync_catch

;; got vsync.
.vsync_caught
ld a,e
ret
