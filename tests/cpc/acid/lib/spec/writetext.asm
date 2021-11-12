;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

scr_base equ &4000
scr_height equ 196
chars_width equ 64
chars_height equ 24

write_text_init:
xor a
ld (line_count),a
;; initialise screen address table used for calculating position to draw chars
call make_scr_table
ld hl,0
jp set_char_coords

requires_press_key:
ret



nl_should_wait_key:
ld a,(line_count)
inc a
ld (line_count),a
cp chars_height
ret nz
xor a
ld (line_count),a
ret


scroll_up:
push hl
push de
push bc
ld hl,&4000
ld b,8
su2:
call scr_next_line
djnz su2

ld de,&4000

ld b,scr_height-8
su1:
push bc
push hl
push de
ld bc,32
ldir
pop de
pop hl
pop bc
call scr_next_line
ex de,hl
call scr_next_line
ex de,hl
djnz su1

ld h,0
ld l,192-8
call calc_scr_addr

ld b,8
sub2:
push bc
push hl
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,32-1
ldir
pop hl
call scr_next_line
pop bc
djnz sub2


pop bc
pop de
pop hl
ret

;;--------------------------------------------------------------------------------------------
;; H = X char coord (0-79)
;; L = Y char coord (0-24)
;; origin is top-left 0,0

set_text_coords:
set_char_coords:
push bc
push de
push hl
ld a,h
ld (x_coord),a
ld a,l
ld (y_coord),a
scc2:
ld a,h
and &1
ld (char_nibble),a
ld a,l
;; X = byte/char coordinate
;; multiply Y by 8 to get line
add a,a				;; x2
add a,a				;; x4
add a,a				;; x8
ld l,a				;;
srl h
call calc_scr_addr
ld (char_scr_addr),hl
pop hl
pop de
pop bc
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

jr refresh_coords

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

char_scr_addr:
defw 0

x_coord:
defb 0
y_coord:
defb 0

char_nibble:
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
call writenl
ret

;;--------------------------------------------------------------------------------------------

;; update char coords and recalc screen address
go_char_right:
call go_right
jr refresh_coords


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
sub ' '
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


ld a,(char_nibble)
or a
jr z,ls

ld b,8
rs1:
ld a,(hl)
and &f0
ld c,a
ld a,(de)
rrca
rrca
rrca
rrca
and &f
or c
ld (hl),a
call scr_next_line
inc de
djnz rs1
jr done_char

ls:
ld b,8
ls1:
ld a,(hl)
and &0f
ld c,a
ld a,(de)
or c
ld (hl),a
call scr_next_line
inc de
djnz ls1

done_char:

;; now update coords for next char
call go_char_right


pop bc
pop de
pop hl
ret



;;--------------------------------------------------------------------------------------------
line_count: defb 0
;;end start