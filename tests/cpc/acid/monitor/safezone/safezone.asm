org &8000
nolist

scr_base equ &1a0
scr_pixels_per_byte equ 4
chars_width equ 48
scr_width equ (chars_width*2*scr_pixels_per_byte)
scr_height equ (35*8)
scr_width_bytes equ (scr_width/scr_pixels_per_byte)
half_scr_width equ (scr_width/2)
half_scr_height equ (scr_height/2)

size_reduce_x equ 8
size_reduce_y equ 8

;; mode 1 pens
pen0  equ %00000000
pen1 equ %11110000
pen2 equ %00001111
pen3 equ %11111111

box_x equ 0
box_y equ box_x+2
box_width equ box_y+2
box_height equ box_width+2
box_pen equ box_height+2
box_data_size equ box_pen+1

;; horizontal left side mask
box_draw_left_mask equ 0
;; horizontal right side mask
box_draw_right_mask equ box_draw_left_mask+1
;; vertical mask left side
box_draw_left_vert_mask equ box_draw_right_mask+1
;; vertical mask right side
box_draw_right_vert_mask equ box_draw_left_vert_mask+1
;; screen address of top-left
box_draw_scraddr1 equ box_draw_right_vert_mask+1
;; screen address of top-right
box_draw_scraddr2 equ box_draw_scraddr1+2
;; screen address of bottom-left
box_draw_scraddr3 equ box_draw_scraddr2+2
;; width in bytes
box_draw_width_bytes equ box_draw_scraddr3+2
;; height in lines
box_draw_height_lines equ box_draw_width_bytes+1
;; box encoded pen
box_draw_encoded_pen equ box_draw_height_lines+2

;; size of all data
box_draw_data_size equ box_draw_encoded_pen+2



safezone:
di
ld bc,&7f10
out (c),c
ld bc,&7f43
out (c),c

ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c

ld bc,&7f01
out (c),c
ld bc,&7f40
out (c),c

ld bc,&7f02
out (c),c
ld bc,&7f45
out (c),c

ld bc,&7f03
out (c),c
ld bc,&7f52
out (c),c

;; mode 1
ld bc,&7f00+%10001100+1
out (c),c

call make_scr_table

;; setup crtc
ld hl,crtc_vals
call set_crtc

call cls

ld ix,box_data
;; init
ld hl,0
ld (ix+box_x+0),l
ld (ix+box_x+1),h
ld hl,0
ld (ix+box_y+0),l
ld (ix+box_y+1),h
ld hl,scr_width
ld (ix+box_width+0),l
ld (ix+box_width+1),h
ld hl,scr_height
ld (ix+box_height+0),l
ld (ix+box_height+1),h
ld a,1
ld (ix+box_pen),a


ld bc,scr_width/8
ld de,0
vloop:
push bc
push de
ld hl,0
ld bc,scr_height
ld a,1
call draw_vert_line
pop de
ex de,hl
ld bc,8
add hl,bc
ex de,hl
pop bc
dec bc
ld a,b
or c
jr nz,vloop

;; middle
ld de,half_scr_width
ld hl,0
ld a,3
ld bc,scr_height
call draw_vert_line


ld bc,scr_height/8
ld hl,0
hloop:
push bc
push hl
ld de,0
ld bc,scr_width
ld a,1
call draw_horz_line
pop hl
ld bc,8
add hl,bc
pop bc
dec bc
ld a,b
or c
jr nz,hloop

ld de,0
ld hl,half_scr_height
ld a,3
ld bc,scr_width
call draw_horz_line

if 0
ld b,16
bl:
push bc
call draw_box

;; reduce size
ld bc,size_reduce_x
ld de,size_reduce_y

ld l,(ix+box_x+0)
ld h,(ix+box_x+1)
add hl,bc
ld (ix+box_x+0),l
ld (ix+box_x+1),h

ld l,(ix+box_width+0)
ld h,(ix+box_width+1)
or a
sbc hl,bc
or a
sbc hl,bc
ld (ix+box_width+0),l
ld (ix+box_width+1),h

ld l,(ix+box_y+0)
ld h,(ix+box_y+1)
add hl,de
ld (ix+box_y+0),l
ld (ix+box_y+1),h

ld l,(ix+box_height+0)
ld h,(ix+box_height+1)
or a
sbc hl,de
or a
sbc hl,de
ld (ix+box_height+0),l
ld (ix+box_height+1),h

pop bc
dec b
jp nz,bl


;; draw vertical line in middle
ld de,half_scr_width
ld hl,0
ld bc,scr_height
ld a,3
call draw_vert_line

ld de,0
ld hl,half_scr_height
ld bc,scr_width
ld a,3
call draw_horz_line
endif

ll:
jp ll

draw_box_data:
defs box_draw_data_size

;; HL = table
get_pixel_mask:
push hl
and &3
add a,l
ld l,a
ld a,h
adc a,0
ld h,a
ld a,(hl)
pop hl
ret

;; mode 1 pixel mask
pixel_mask_l:
defb %11111111
defb %01110111
defb %00110011
defb %00010001

pixel_mask_r:
defb %11111111     
defb %10001000      
defb %11001100      
defb %11101110      

pixel_mask:
defb %10001000
defb %01000100
defb %00100010
defb %00010001

get_pen:
push hl
and &3
add a,pen_table AND 255
ld l,a
ld a,pen_table/256
adc a,0
ld h,a
ld a,(hl)
pop hl
ret


pen_table:
defb pen0
defb pen1
defb pen2
defb pen3


cls:
ld hl,scr_base
ld bc,scr_height
cl1:
push bc
push hl

ld bc,scr_width_bytes
ld e,l
ld d,h
inc hl
ld (hl),0
ldir

pop hl
call scr_next_line
pop bc
dec bc
ld a,b
or c
jr nz,cl1
ret


box_data:
defw 0
defw 0
defw (48*2*2)
defw (35*8)


draw_box:
ld iy,draw_box_data

;; calc screen addresses
ld e,(ix+box_x+0)
ld d,(ix+box_x+1)
ld l,(ix+box_y+0)
ld h,(ix+box_y+1)
call get_scr_addr
ld (iy+box_draw_scraddr1+0),l
ld (iy+box_draw_scraddr1+1),h

;; could avoid this one if we draw left-right on top-line then drew down
ld e,(ix+box_x+0)
ld d,(ix+box_x+1)
ld l,(ix+box_width+0)
ld h,(ix+box_width+1)
add hl,de
ld e,l
ld d,h
ld l,(ix+box_y+0)
ld h,(ix+box_y+1)
call get_scr_addr
ld (iy+box_draw_scraddr2+0),l
ld (iy+box_draw_scraddr2+1),h

ld e,(ix+box_y+0)
ld d,(ix+box_y+1)
ld l,(ix+box_height+0)
ld h,(ix+box_height+1)
add hl,de
ld e,(ix+box_x+0)
ld d,(ix+box_x+1)
call get_scr_addr
ld (iy+box_draw_scraddr3+0),l
ld (iy+box_draw_scraddr3+1),h

;; width
ld l,(ix+box_width+0)
ld h,(ix+box_width+1)
ld bc,scr_pixels_per_byte-1
add hl,bc
;; /4 to get width in bytes
srl h 
rr l
srl h
rr l
ld a,l
ld (iy+box_draw_width_bytes),a

ld a,(ix+box_x+0)
ld hl,pixel_mask
push af
call get_pixel_mask
ld (iy+box_draw_left_vert_mask),a
pop af
ld hl,pixel_mask_l
call get_pixel_mask
ld (iy+box_draw_left_mask),a

;; x 
ld l,(ix+box_x+0)
ld h,(ix+box_x+1)
;; width
ld c,(ix+box_width+0)
ld b,(ix+box_width+1)
;; x + width to get right side
add hl,bc
;; x pixel of right side
ld a,l
push af
ld hl,pixel_mask
call get_pixel_mask
ld (iy+box_draw_right_vert_mask),a
pop af
ld hl,pixel_mask_r
call get_pixel_mask
ld (iy+box_draw_right_mask),a

;; pen
ld a,(ix+box_pen)
call get_pen
ld (iy+box_draw_encoded_pen),a

ld l,(ix+box_height+0)
ld h,(ix+box_height+1)
ld (iy+box_draw_height_lines+0),l
ld (iy+box_draw_height_lines+1),h

;; draw left side
ld l,(iy+box_draw_scraddr1+0)
ld h,(iy+box_draw_scraddr1+1)
ld d,(iy+box_draw_left_vert_mask)
ld c,(iy+box_draw_height_lines+0)
ld b,(iy+box_draw_height_lines+1)
ld e,(iy+box_draw_encoded_pen)
call idraw_vert_line

;; draw right side
ld l,(iy+box_draw_scraddr2+0)
ld h,(iy+box_draw_scraddr2+1)
ld d,(iy+box_draw_right_vert_mask)
ld c,(iy+box_draw_height_lines+0)
ld b,(iy+box_draw_height_lines+1)
ld e,(iy+box_draw_encoded_pen)
call idraw_vert_line

;; draw top
ld l,(iy+box_draw_scraddr1+0)
ld h,(iy+box_draw_scraddr1+1)
ld d,(iy+box_draw_left_mask)
ld e,(iy+box_draw_right_mask)
ld c,(iy+box_draw_width_bytes)
ld b,(iy+box_draw_encoded_pen)
call idraw_horz_line

;; draw bottom
ld l,(iy+box_draw_scraddr3+0)
ld h,(iy+box_draw_scraddr3+1)
ld d,(iy+box_draw_left_mask)
ld e,(iy+box_draw_right_mask)
ld c,(iy+box_draw_width_bytes)
ld b,(iy+box_draw_encoded_pen)
call idraw_horz_line
ret

;; DE = x 
;; HL = y
;; A = colour
;; BC = length
draw_vert_line:
push af
call get_scr_addr

push hl
ld a,e
ld hl,pixel_mask
call get_pixel_mask
ld d,a
pop hl

pop af
call get_pen
ld e,a

call idraw_vert_line
ret


;; DE = x 
;; HL = y
;; A = colour
;; BC = length
draw_horz_line:
push af
call get_scr_addr

push hl
ld a,e
ld hl,pixel_mask_l
call get_pixel_mask
ld d,a
pop hl

ld e,&ff

srl b
rr c
srl b
rr c

pop af
call get_pen
ld b,a

;; HL = screen address
;; B = encoded pen
;; D = left mask
;; E = right mask
;; C = number of bytes
;; A is used

call idraw_horz_line
ret




;;
;; HL=screen address
;; BC = height
;; E = encoded pen
;; D = mask
idraw_vert_line:
;; sort out pen
ld a,d
;; and with pixel data
and e
;; B = masked pixel ready to draw.
ld e,a

ld a,d
cpl
ld d,a

dvl1:
;; get pixel from screen
ld a,(hl)
;; mask it
and d
;; combine with new pixel
or e
ld (hl),a

call scr_next_line
dec bc
ld a,b
or c
jr nz,dvl1
ret



;; HL = screen address
;; B = encoded pen
;; D = left mask
;; E = right mask
;; C = number of bytes
;; A is used
idraw_horz_line:
push bc

;; get left mask
ld a,d
;; and get pixels of pen ready
and b
ld c,a

ld a,d
; A = pixel data ready to put to screen
cpl

;; A = mask for pixels to remove from screen
and (hl)
;; now pixel data from screen ready to put back
;; C = new pixel data to store
or c
;; store back to screen
ld (hl),a
inc hl
pop bc

dec c
dec c

dhm:
ld (hl),b
inc hl
dec c
jr nz,dhm

ld a,e
and b
ld c,a

ld a,e
cpl
;; A = mask for pixels to remove from screen
and (hl)
;; now pixel data from screen ready to put back
;; C = new pixel data to store
or c
;; store back to screen
ld (hl),a
ret




set_crtc:
ld bc,&bc00
set_crtc_vals:
out (c),c
inc b
ld a,(hl)
out (c),a
dec b
inc hl
inc c
ld a,c
cp 14
jr nz,set_crtc_vals
ret

crtc_vals:
defb &3f
defb 48
defb 49
defb &89
defb 38
defb 0
defb 35
defb 35
defb 0
defb 7
defb 0
defb 0
defb &0c
defb 208

;;--------------------------------------------------------------------------------------------
;; IN:
;; de = x pixel coord
;; hl = y line coord
;; OUT: 
;; HL = screen coordinate
get_scr_addr:
push bc
push de
push af
add hl,hl
ld bc,scr_table
add hl,bc
ld a,(hl)
inc hl
ld h,(hl)
ld l,a

;; /4 to get byte (mode 1)
srl d
rr e

srl d
rr e

;; add onto address on line
add hl,de
pop af
pop de
pop bc
ret

;;-----------------------------------------------------------------------------------------------------
;; input conditions:
;; HL = screen address
;; output conditions:
;; HL = screen address (next scanline down)
;;

scr_next_line:
;; go down next scan line
ld a,h
add a,8
ld h,a
;; check if we should go to next char line
and &38
ret nz

;; remove effect of last add
ld a,h
sub &8
ld h,a

;; add on amount to go to next char line
ld a,l
add a,chars_width*2
ld l,a
ld a,h
adc a,&00
ld h,a

;; if we overflowed to next 16k the result will be 0
and &38
ret z

;; we didn't overflow adjust to go back into 1st 16k
ld a,h
sub &38
ld h,a
ret


;;--------------------------------------------------------------------------------------------

make_scr_table:
ld hl,scr_table
ld de,scr_base			;; screen base
ld bc,scr_height			;; height in lines
st1: ld (hl),e
inc hl
ld (hl),d
inc hl
ex de,hl
call scr_next_line
ex de,hl
dec bc
ld a,b
or c
jr nz,st1
ret

scr_table:
defs scr_height*2

end safezone
