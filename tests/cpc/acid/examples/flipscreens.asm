org &8000
start:
di
ld a,(&0038)
ld (int_store),a
ld hl,(&0039)
ld (int_store+1),hl

ld hl,&c9fb
ld (&0038),hl
ei

loop:
call wait_vsync_start
ld a,&30
call vidstart
ld a,1
call scr_mode
call read_matrix
call wait_vsync_end

ld a,(matrix_buffer+5)
bit 7,a
jp nz,exit

call wait_vsync_start
ld a,&10
call vidstart
ld a,0
call scr_mode
call read_matrix
call wait_vsync_end

ld a,(matrix_buffer+5)
bit 7,a
jp nz,exit

jp loop

exit:
di
ld a,(int_store)
ld (&0038),a
ld hl,(int_store+1)
ld (&0039),hl
ei
ret

int_store:
defs 3

wait_vsync_start:
ld b,&f5
vsync1:
in a,(c)
rra
jr nc,vsync1
ret

wait_vsync_end:
ld b,&f5
vsync2:
in a,(c)
rra
jr c,vsync2
ret


scr_mode:
or %10001100
ld b,&7f
out (c),a
ret

vidstart:
ld bc,&bc0c
out (c),c
inc b
out (c),a
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


end start