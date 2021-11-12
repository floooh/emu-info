;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; This code can be used to copy an entire program into RAM
;; from cart. It works in a similar way to the ROM filesystem
;; but without the directory and individual files. A single block
;; is copied entirely into RAM and executed from there.
;;
;; NOTE: You must setup the hardware as you need.

;;----------------------------------------------------------------------------------------
;; cart page 0 is started at &0000
;;
;; In this example:
;; stack is set to &c000 and will grow down. We use about 12 bytes.
;;
;; We install a function at &be00 which turns off the roms and executes
;; the program.
;;
;; The program then takes control and sets up the hardware.
org &0000

game_start equ &1000
game_exe equ &1000

start:
ld bc,&fb7e
in a,(c)
ld (&bdfe),a
ld bc,&fb7f
in a,(c)
ld (&bdff),a

di					;; disable interrupts

ld sp,&c000			;; set the stack

;; copy game code into RAM
ld hl,game_code			;; start of code within cartridge
ld de,game_start			;; address in RAM to copy to
ld bc,end_game_code-game_code	;; length to copy

;; do the copy...

defb &dd
ld h,&80				;; initial cartridge page (page 0)

;; HL = read address
;; DE = write address
;; BC = length
;; HIX = rom

;; start address but in upper rom area
ld a,h
or &c0

load_file3:
push bc		;; store length
ld b,&df	;; ROM select
defb &dd	;; select it
ld a,h
out (c),a	
pop bc		;; restore length

load_file2:
;; read from rom and write to ram, decrement bc too
ldi
jp po,load_file4	;; BC=0?

;; more bytes to do..

;; did we reach the end of the page (address = 0, overflowed from ffff)
ld a,h
or l
jr nz,load_file2	;; loop for more bytes

;; reached end of page

;; reset read address
ld hl,&c000

;; increment rom select
defb &dd
inc h

;; select rom
jr load_file3

;; now execute it.
load_file4:
;; we need to install a function to execute so we can disable the ROMs
;; and execute the program in RAM
ld hl,boot_game
ld de,&be00
push de
ld bc,end_boot_game-boot_game
ldir
ret

boot_game:
;; disable upper and lower rom
ld bc,&7f00+%10001100
out (c),c
jp game_exe			;; and execute game
end_boot_game:

;;----------------------------------------------------------------------------------------

;; your data follows...
game_code:
incbin "game.bin"
end_game_code:

