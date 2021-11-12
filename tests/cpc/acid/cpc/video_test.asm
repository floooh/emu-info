org &4000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e
pen_swap equ &54 xor &4B

;; set colour with bit 5 set
start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,1
call scr_set_mode
ld hl,main_msg
call display_msg

di
ld hl,&c9fb
ld (&0038),hl
im 1
ei
ld hl,&c800+(4*80)+71
ld (hl),%00001111

mainloop:
ld b,&f5
m1:
in a,(c)
rra
jr nc,m1

halt
halt
halt

ld bc,&7f10
out (c),c
ld bc,&7f51
out (c),c

di
;; behind the beam
ld hl,&c000
ld de,&ff00+%11110000
ld (hl),e
ld (hl),d

ld hl,&d000+(4*80)+71
ld (hl),e
ld (hl),d

;; infront of the beam
ld hl,&c000+(16*80)
ld de,&ff00+%11110000
ld (hl),e
ld (hl),d

ei

ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c

halt
call readkeys
call do_dir
jp mainloop


do_dir:
ld ix,matrix_buffer
ld a,(ix+9)
xor (ix+9+16)
ret z

ld a,(ix+9)
bit 0,a
call nz,do_down
bit 1,a
call nz,do_up
ret

do_down:
ld hl,(jp_addr+1)
dec hl
ld (jp_addr+1),hl
ret

do_up:
ld hl,(jp_addr+1)
inc hl
ld (jp_addr+1),hl
ret
jp_addr:
defs 3

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


main_msg:
defb 31,3,1,"Behind beam (red)"
defb 31,3,16,"Ahead of beam (red)"
defb 31,3,4,"First position (1 of 4) (yellow)"
defb 31,3,6,"Blue marker directly above it"
defb 0


message:
defb "This is a visual test.",13,10,13,10
defb "This test waits for a specific point during the display",13,10
defb "the writes some bytes to the RAM. It does this to detect the",13,10
defb "timing of when the pixels are fetched",13,10,13,10
defb "Tested on 40010 36AA, Type 2 CRTC",13,10
defb "Tested on 40010 36AA, HD6845SP Type 0 CRTC",13,10
defb "Tested on 40010 36AA, UM6845R type 1 CRTC",13,10
defb "Press a key to start",0

include "../lib/hw/readkeys.asm"

end start