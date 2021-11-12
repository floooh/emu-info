;; This code is copyright Andy Cadley. Used with permission.
org &2000

start:
di

ld sp,&c000

;Unlock the ASIC so we can use Plus functionality
ld b,&bc
ld hl,bootasicsequence
ld e,17
seq:
ld a,(hl)
out (c),a
inc hl
dec e
jr nz,seq

; Put an EI;RET combo for the interrupt handler, so the firmware doesn't
; get in the way and start altering things
ld hl,&c9fb
ld (&0038),hl
ld (&8080),hl
di

;; enable asic ram (will be visible in range &4000-&7fff)
ld bc,&7fb8
out (c),c

; Reset the display file
ld bc, &bc0d
out (c),c
inc b
xor a
out (c),a
dec b
dec c
out (c),c
inc b
ld a, &30
out (c),a

; Put the display into MODE 0, ROMs disabled
ld bc,&7f8c
out (c),c

; Clear the screen
ld hl, &c000
ld de, &c001
ld bc, &3fff
xor a
ld (hl),a
ldir

; Set the border colour
xor a
ld hl,&6421
ld (hl),a
dec l
ld a, &6c
ld (hl),a

; Setup a DMA list
ld hl,dmalist
ld de,&8100
ld bc,dmalistend - dmalist
ldir

; Configure interrupts
ld hl,0
ld (&8000),hl
ld hl,0
ld (&8002),hl
ld hl,dma0int
ld (&8004),hl
ld hl,rasterint
ld (&8006),hl

ld a,1
ld (&6805),A ; Set the IVR to use a vector of 0, autoclear disabled
ld a,&80
ld i,a
im 2

; Configure a PRI at line 1
ld a,1
ld (&6800),A
ei

donothing: halt
jp donothing

rasterint:
; First time through, our Raster Int initializes the DMA
ld hl,&8100
ld (&6c00), hl ; Set our DMA list
ld a,1
ld (&6c0f), a ; Turn on DMA channel 0

; Set the raster int so it will no longer start the DMA list
ld hl,rasterint2
ld (&8006),hl

rasterint2:
ei
ret

dma0int:
; clear DMA interrupt
ld a,(&6c0f)
set 6,a
ld (&6c0f),a

; modify the border colour
ld a,(&6420)
rrca
rrca
ld (&6420), a

; keep count of how many interrupts we've serviced
ld a,(count)
inc a
ld (count),a
cp 4
jp nz, dma0intdone

; Once we've serviced them all, restart the DMA list
xor a
ld (count),a
ld hl,&8100
ld (&6c00), hl ; Reset our DMA list

dma0intdone: ei
ret

count: defb 0

dmalist:
defw &2000 + 312-20-1 ; Repeat (This is just enough to make our DMA list "too short")
defw &4001 ; Loop
defw &4010 ; Int
defw &1002 ; Pause 2
defw &4010 ; Int
defw &1004 ; Pause 4
defw &4010 ; Int
defw &1008 ; Pause 8
defw &4010 ; Int
defw &4020 ; STOP
dmalistend:

bootasicsequence:
defb &ff,&00,&ff,&77,&b3,&51,&a8,&d4,&62,&39,&9c,&46,&2b,&15,&8a,&cd,&ee

end start