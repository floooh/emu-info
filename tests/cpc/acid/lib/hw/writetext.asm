;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This example shows how to draw chars to the screen in mode 2
;; using the OS/firmware pixel data from the ROM.
;; 
;; this example is for mode 2
;;
;; This code can't be in the range &0000-&3fff because it
;; activates the lower rom in this range.


scr_base equ &c000
scr_height equ 200
chars_width equ 80
chars_height equ 25


nl_should_wait_key:
ld a,(line_count)
inc a
ld (line_count),a
cp 25
ret nz
xor a
ld (line_count),a
ret


requires_press_key:
ret

write_text_init:
xor a
ld (line_count),a
call cls
call make_scr_table
ld hl,0
jp set_char_coords

scroll_up:
push hl
push de
push bc
ld hl,&c000+chars_width
ld de,&c000

ld b,8
su1:
push bc
push hl
push de
ld bc,chars_width*(chars_height-1)-1
ldir
pop de
pop hl
pop bc
ld a,h
add a,8
ld h,a
ld a,d
add a,8
ld d,a
djnz su1

ld hl,&c000+((chars_height-1)*chars_width)
ld b,8
su2:
push bc
push hl
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,chars_width-1
ldir
pop hl
pop bc
ld a,h
add a,8
ld h,a
djnz su2
pop bc
pop de
pop hl
ret

;;--------------------------------------------------------------------------------------------
;; H = X char coord (0-79)
;; L = Y char coord (0-24)
;; origin is top-left 0,0

set_text_coords:
push bc
push de
push hl
call set_char_coords
pop hl
pop de
pop bc
ret

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
ld a,(y_coord)
inc a
cp chars_height
jr nz,writenl2

call scroll_up
;; scroll screen up
ld a,chars_height-1
writenl2:
ld (y_coord),a

xor a
ld (x_coord),a

jp refresh_coords


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
jp writenl

;;--------------------------------------------------------------------------------------------

;; update char coords and recalc screen address
go_char_right:
call go_right

refresh_coords:
push hl
push de
push bc
ld a,(x_coord)
ld h,a
ld a,(y_coord)
ld l,a
call scc2
pop bc
pop de
pop hl
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
defs scr_height*2

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
ld de,sysfont					;; address of font in OS rom
							;; char 0
							
add hl,de
ex de,hl
;; DE = char pixel data

ld hl,(char_scr_addr)
;; HL = screen address


;; lower rom readable between &0000-&3fff
;;ld bc,&7f00+%10001010
;;out (c),c


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

;; disable lower rom
;; mode 2, upper rom disabled
;;ld bc,&7f00+%10001110
;;out (c),c


;; now update coords for next char
call go_char_right


pop bc
pop de
pop hl
ret

if 0
set_dimensions:
						ld a,h
						ld (max_output_col),a
						ld a,l
						ld (max_output_line),a
						inc a
						ld (info_line),a
						ret
						
						
output_reset:
						xor a
						ld (cur_output_line),a
						ld (cur_output_col),a
						ret

						
xor a
						ld (cur_output_col),a
						
						ld a,(cur_output_line)
						inc a
						ld (cur_output_line),a
						
						push bc
						ld b,a
						ld a,(max_output_line)
						cp b
						pop bc
						jp nz,outnl

						
stored_coords:
stored_output_line:		defb 0						
stored_output_col:		defb 0

cur_output_type: 		defb 0

cur_coords:
cur_output_line:		defb 0
cur_output_col:			defb 0

max_output_col:			defb 40
max_output_line:		defb 23
info_line:				defb 24
endif
;;--------------------------------------------------------------------------------------------
line_count: defb 0
;;end start