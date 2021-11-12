;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This example shows how to draw chars to the screen in mode 2
;; using the OS/firmware pixel data extracted from the ROM.
;; It doesn't need the OS ROM itself.
;; 
;; this example is for mode 2

scr_base equ &c000
scr_height equ 200
chars_width equ 8
chars_height equ 25

write_text_init:
;; initialise screen address table used for calculating position to draw chars
call make_scr_table
ret

;;--------------------------------------------------------------------------------------------
;; H = X char coord (0-79)
;; L = Y char coord (0-24)
;; origin is top-left 0,0

set_char_coords:
ld a,h
ld (x_coord),a
ld a,l
ld (y_coord),a
scc2:
ld a,l
;; X = byte/char coordinate
;; multiply Y by 8 to get line
add a,a				;; x2
add a,a				;; x4
add a,a				;; x8
ld l,a				;;
call calc_scr_addr
ld (char_scr_addr),hl
ret

writenl:
ret


;;--------------------------------------------------------------------------------------------

char_scr_addr:
defw 0

x_coord:
defb 0
y_coord:
defb 0

;;--------------------------------------------------------------------------------------------

;; update x and y coordinate to move to right
;; if we get to end of the line, go to start of next line
;; if we go past last char, wrap back to start
go_right:
ld a,(x_coord)
inc a
ld (x_coord),a
cp chars_width
ret nz
xor a
ld (x_coord),a
ld a,(y_coord)
inc a
ld (y_coord),a
cp chars_height
ret nz
xor a
ld (y_coord),a
ret

;;--------------------------------------------------------------------------------------------

;; update char coords and recalc screen address
go_char_right:
call go_right
ld a,(x_coord)
ld h,a
ld a,(y_coord)
ld l,a
call scc2
ret


;;--------------------------------------------------------------------------------------------
;; IN:
;; h = x byte coord
;; l = y line coord
;; OUT: 
;; HL = screen coordinate

calc_scr_addr:
push bc
push de
ld c,h
ld h,0
add hl,hl
ld de,scr_table
add hl,de
ld a,(hl)
inc hl
ld h,(hl)
ld l,a
ld b,0
add hl,bc
pop de
pop bc
ret

;;--------------------------------------------------------------------------------------------

scr_table:
defs 400

;;--------------------------------------------------------------------------------------------

make_scr_table:
ld ix,scr_table
ld hl,scr_base			;; screen base
ld b,scr_height			;; height in lines
st1: ld (ix+0),l
ld (ix+1),h
inc ix
inc ix
call scr_next_line
djnz st1
ret

;;--------------------------------------------------------------------------------------------

;; A = char to display
writechar:
push hl
push de
push bc

;; page in lower rom
;; bit 1,0: mode (mode 2)
;; bit 2: lower rom enable
;; bit 3: upper rom disable
;;


;; get addr for char pixel data
;;
;; each char is 8 bytes. One byte per line.
;; each bit is a single pixel and we can
;; plot this directly to the screen for mode 2.
;;
;; The OS converts the pixel data at runtime for mode 1 and mode 0.
;;
;; The OS stores char 0 to char 255.
;;
;; a = char
ld l,a
ld h,0
add hl,hl					;; x2
add hl,hl					;; x4
add hl,hl					;; x8
ld de,font_data				;; address of font in OS rom
							;; char 0
							
add hl,de
ex de,hl
;; DE = char pixel data

ld hl,(char_scr_addr)
;; HL = screen address

;; print entire char 
ld b,8
print_char_line:
;; do one line
ld a,(de)
ld (hl),a
;; update pixel pointer
inc de
;; update screen pointer
call scr_next_line
djnz print_char_line


;; now update coords for next char
call go_char_right


pop bc
pop de
pop hl
ret

;;--------------------------------------------------------------------------------------------

;;end start