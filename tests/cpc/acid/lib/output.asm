;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

output_type_screen equ 0
output_type_printer equ 1

output_string:
ld a,(hl)
or a
ret z
inc hl
push hl
call output_char
pop hl
jr output_string

push_wait_key:
push af
ld a,(should_wait_key)
ld (stored_should_wait_key),a
pop af
ld (should_wait_key),a
ret

pop_wait_key:
ld a,(stored_should_wait_key)
ld (should_wait_key),a
ret


report_press_key:
call wait_key
ret

if 0
push hl
push bc
push de
push ix

ld hl,(cur_coords)
ld (stored_coords),hl

ld h,0
ld a,(info_line)
ld l,a
call set_text_coords
ld hl,press_key_msg
call output_string

call wait_key

ld h,0
ld a,(info_line)
ld l,a
call set_text_coords
ld a,(max_output_col)
ld b,a
clinfo:
ld a,' '
call output_char
djnz clinfo

ld hl,(stored_coords)
call set_text_coords

pop ix
pop de
pop bc
pop hl
ret

press_key_msg:
defb "** Press a key to continue **",0
endif
				
set_output_type:
						ld (cur_output_type),a
						ret
												
output_nl:				
outnl:		
						call nl_should_wait_key
						jr nz,outnl2
						
						ld a,(should_wait_key)
						or a
						call nz,report_press_key						
outnl2:					
						ld a,(cur_output_type)
						or a
						jr z,outnl_screen
						jr outnl_printer

						
outnl_screen:			jp writenl
outnl_printer			jp printnl
				
output_char:			cp 13
						jr z,output_nl
						
						push af	
						ld a,(cur_output_type)
						or a
						jr z,output_screen
						jr output_printer

output_screen:			pop af
						jp writechar
output_printer:
						pop af
						jp printchar

cur_output_type:		defb 0
should_wait_key:		defb 1
stored_should_wait_key:	defb 0