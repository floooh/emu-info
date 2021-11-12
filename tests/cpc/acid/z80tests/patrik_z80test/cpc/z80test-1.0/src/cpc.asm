;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &100

scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
di
ld sp,&37ff
;; move test up
ld hl,end_data-1
ld de,end_data-data+&8000-1
ld bc,end_data-data
lddr

;; capture font from rom and copy it
ld hl,move_font_code
ld de,&c000
ld bc,end_move_font_code-move_font_code
ldir
call &c000

;; print init
ld a,&c3
ld hl,print_init
ld (&1601),a
ld (&1602),hl

;; int setup
ld hl,&c9fb
ld (&0038),hl

;; setup print handler
ld a,&c3
ld hl,print_handler
ld (&0010),a
ld (&0011),hl

ld hl,&c000
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,&3fff
ldir


;; execute
call &8000
infloop:
jp infloop

move_font_code:
ld bc,&7f00+%10001010
out (c),c
ld hl,&3800
ld de,&3800
ld bc,&4000-&3800
ldir
ld bc,&7f00+%10001110
out (c),c
ret
end_move_font_code:

print_init:
ld a,0
ld (xcoord),a
ld (ycoord),a
ld ix,scr_table
ld hl,&c000
ld b,200
pi:
ld (ix+0),l
ld (ix+1),h
inc ix
inc ix
call scr_next_line
djnz pi
ret

scr_next_line:
ld a,h
add a,8
ld h,a
ret nc
ld a,l
add a,&50
ld l,a
ld a,h
adc a,&c0
ld h,a
ret



xcoord:
defb 0
ycoord:
defb 0

print_handler:
push af
tab_control_flag:
ld a,0
or a
jp nz,print_handler_tab_control
pop af
cp 13
jp z,next_line
cp 23
jp z,tab_control
cp 127
jp nz,printh2
ld a,164
printh2:
push hl
push de
push bc

push af
ld a,(ycoord)
ld l,a
ld h,0
add hl,hl
add hl,hl
add hl,hl
add hl,hl
ld bc,scr_table
add hl,bc
ld a,(hl)
inc hl
ld h,(hl)
ld l,a
ld a,(xcoord)
add a,l
ld l,a
ld a,0
adc a,h
ld h,a
ex de,hl
pop af

ld l,a
ld h,0
add hl,hl
add hl,hl
add hl,hl
ld bc,&3800
add hl,bc
ex de,hl
rept 8
ld a,(de)
ld (hl),a
inc de
call scr_next_line
endm
ld a,(xcoord)
inc a
ld (xcoord),a
pop bc
pop de
pop hl
ret

next_line:
ld a,(ycoord)
inc a
ld (ycoord),a
cp 25
jr nz,next_line2
ld a,24
ld (ycoord),a

push hl
push bc
push de

ld b,24
ld hl,&c000
scroll_up:
push bc
push hl

ld e,l
ld d,h
ex de,hl
ld bc,&0050
add hl,bc

ld b,8
scroll_inner_up:
push bc
push hl
push de
ld bc,80
ldir
pop de
pop hl
ld a,h
add a,8
ld h,a
ld a,d
add a,8
ld d,a
pop bc
djnz scroll_inner_up

pop hl
ld bc,&0050
add hl,bc
pop bc
djnz scroll_up

ld b,8
clr_line:
push hl
push de
push bc
ld e,l
ld d,h
inc de
ld (hl),0
ld bc,79
ldir
pop bc
pop de
pop hl
ld a,h
add a,8
ld h,a
djnz clr_line

pop de
pop bc
pop hl

next_line2:
ld a,0
ld (xcoord),a
ret

tab_control:
ld a,1
ld (tab_control_flag+1),a
ld a,2
ld (bytes_expected),a
push hl
ld hl,control_bytes
ld (control_byte_ptr),hl
pop hl
ret

print_handler_tab_control:
pop af
push hl
ld hl,(control_byte_ptr)
ld (hl),a
inc hl
ld (control_byte_ptr),hl
pop hl
ld a,(bytes_expected)
dec a
ld (bytes_expected),a
or a
ret nz

ld a,(control_bytes+0)
ld (xcoord),a



ld a,0
ld (tab_control_flag+1),a
ret

control_byte_ptr:
defw 0

control_bytes:
defs 8

bytes_expected:
defb 0

scr_table:
defs 200*2

data:
incbin "data.bin"
end_data:

end start