scr_set_border equ &bc38
scr_set_mode equ &bc0e
txt_output equ &bb5a
txt_set_cursor equ &bb75

;; default with no joystick: 3f 3f 3f 3f 3f 00 3f 00
;; with amstrad joystick centre is around 1b/1c for both axes rapidly changing between the two values
;; extreme up and left produce near zero. Max is about 3c/3b


org &8000
nolist

start:
;; set the screen mode
ld a,2
call scr_set_mode

call asic_enable
ld bc,&7fb8
out (c),c

loop1:
ld b,&f5
l3:
in a,(c)
rra
jr nc,l3

ld b,8
ld h,1
ld l,1
ld de,&6808
loop2:
push bc
push hl
push de
call txt_set_cursor
pop de
ld a,(de)
inc de
push de
call display_hex
pop de
pop hl
inc l
pop bc
djnz loop2

jp loop1

display_hex:
push af
rrca
rrca
rrca
rrca
call display_hex_digit
pop af
display_hex_digit
and &f
cp 10
jr nc,dhd2
add a,'0'
jp txt_output
dhd2:
add a,'A'-10
jp txt_output

asic_enable:
	push af
	push hl
	push bc
	push de
	ld hl,asic_sequence
	ld bc,&bc00
	ld d,16

ae1:
        ld      a,(hl)
        out     (c),a
        inc     hl
        dec     d
        jr      nz,ae1
	
	ld a,&ee
	out (c),a
	pop de
	pop bc
	pop hl
	pop af	
	ret
	
	
asic_sequence:
defb &ff,&00		;; synchronisation
defb &ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd

end start
