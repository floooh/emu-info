;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

readkeys:
;; store previous values
ld hl,matrix_buffer
ld de,old_matrix_buffer
ld bc,16
ldir

;; scans 16 rows!
;; for extra testing ;)
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
or a
jr nz,scan_key            ;no loop and get next row

;; scanned all rows
pop bc

ld a,&82                  ;write PPI Control: Port A: Output, Port B: Input, Port C upper: output, Port C lower: output.
out (c),a

dec b
out (c),c                 ;set PSG operation: bit7=0, bit 6=0 (PSG operation: inactive)
ret

wait_key:
push bc
push hl
push de
wait_key2:
ld b,&f5
wk1:
in a,(c)
rra
jr nc,wk1
wk2:
in a,(c)
rra
jr c,wk2
call readkeys
;; key matrix
ld hl,matrix_buffer
;; number of lines
ld b,10
;; initial state
xor a
wk3:
;; 0 for no key pressed
or (hl)
inc hl
djnz wk3
or a
jr z,wait_key2
pop de
pop hl
pop bc
ret 

matrix_buffer:
defs 16
old_matrix_buffer:
defs 16
