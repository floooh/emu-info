;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &2000
nolist

km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

ld a,0
call scr_set_mode

di
ld hl,scr_data+128
ld de,&c000
ld bc,&4000
ldir

ld a,(&0038)
ld (int_store),a
ld hl,(&0039)
ld (int_store+1),hl

ld hl,&c9fb
ld (&0038),hl
ei

;; into mode 3
ld bc,&7f00+%10001111
out (c),c

l1:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2

call read_matrix

ld ix,matrix_buffer
;; check esc
ld a,(ix+8)
and %100
jr nz,exit

line5_prev equ 16+5

ld ix,matrix_buffer
xor (ix+line5_prev)
jr z,l1
;; check space
ld a,(ix+5)
and %10000000
jr z,l1

ld a,(scr_toggle)
xor &ff
ld (scr_toggle),a

call scr_on_off

jp l1

exit:
di
ld a,(int_store)
ld (&0038),a
ld hl,(int_store+1)
ld (&0039),hl
ei
ret


scr_toggle:
defb 0

scr_on_off:
ld a,(scr_toggle)
or a
jp z,scr_on
jp scr_off

scr_on:
ld hl,&c000
ld bc,&4000

scr_on2:
rrc (hl)
rrc (hl)
inc hl
dec bc
ld a,b
or c
jr nz,scr_on2
ret

scr_off:
ld hl,&c000
ld bc,&4000

scr_off2:
rlc (hl)
rlc (hl)
inc hl
dec bc
ld a,b
or c
jr nz,scr_off2
ret




;; This example shows the correct method to read the keyboard and
;; joysticks on the CPC, CPC+ and KC Compact.
;;
;; This source is compatible with the CPC+.
;;
;; The following is assumed before executing of this algorithm:
;; - I/O port A of the PSG is set to input,
;; - PPI Port A is set to output

read_matrix:
ld hl,matrix_buffer
ld de,prev_matrix_buffer
ld bc,16
ldir
ld hl,matrix_buffer        ; buffer to store matrix data

ld bc,&f40e                ; write PSG register index (14) to PPI port A (databus to PSG)
out (c),c

ld b,&f6
in a,(c)
and &30
ld c,a

or &C0                     ; bit 7=bit 6=1 (PSG operation: write register index)
out (c),a                  ; set PSG operation -> select PSG register 14

;; at this point PSG will have register 14 selected.
;; any read/write operation to the PSG will act on this register.

out (c),c                  ; bit 7=bit 6=0 (PSG operation: inactive)

inc b
ld a,&92
out (c),a                  ; write PPI control: port A: input, port B: input, port C upper: output
                           ; port C lower: output
push bc
set 6,c                    ; bit 7=0, bit 6=1 (PSG operation: read register data)

scan_key:
ld b,&f6 
out (c),c                 ;set matrix line & set PSG operation

ld b,&f4                  ;PPI port A (databus to/from PSG)
in a,(c)                  ;get matrix line data from PSG register 14

cpl                       ;invert data: 1->0, 0->1
                          ;if a key/joystick button is pressed bit will be "1"
                          ;keys that are not pressed will be "0"

ld (hl),a                 ;write line data to buffer
inc hl                    ;update position in buffer
inc c                     ;update line

ld a,c
and &0f
cp &0a                    ;scanned all rows?
jr nz,scan_key            ;no loop and get next row

;; scanned all rows
pop bc

ld a,&82                  ;write PPI Control: Port A: Output, Port B: Input, Port C upper: output, Port C lower: output.
out (c),a

dec b
out (c),c                 ;set PSG operation: bit7=0, bit 6=0 (PSG operation: inactive)
ret

matrix_buffer:
defs 16
prev_matrix_buffer:
defs 16

scr_data:
incbin "mode3scr.bin"

int_store:
defs 3



display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg

message:
defb "This is a visual test.",13,10,13,10
defb "This tests MODE 3 of the GA. Mode 3 is a 4 colour mode which",13,10
defb "is an artifact of how the Gate-Array mode decoding is",13,10
defb "implemented. (bit 7=1,bit 6=0, bit 1=1, bit 0=1,port 7fxx",13,10,13,10
defb "Some bits in the byte are used. This test stores two pictures",13,10
defb "one in the used bits and another in the unused bits.",13,10,13,10
defb "You should only see ONE picture at a time.",13,10,13,10
defb "Press space to switch screens",13,10,13,10
defb "Press a key to start",0


end start