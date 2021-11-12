;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &4000

scr_set_mode equ &bc0e
txt_output	equ &bb5a
scr_set_border equ &bc38

start:
ld b,&14
ld c,b
call scr_set_border

;; set the screen mode
ld a,1
call scr_set_mode

ld bc,24*40
ld d,' '
l1:
inc d
ld a,d
cp &7f
jr nz,no_char_reset
ld d,' '
no_char_reset:
ld a,d
call txt_output
dec bc
ld a,b
or c
jr nz,l1

di
ld hl,&c9fb
ld (&0038),hl
ei

;; type 1
;; 3 lines repeat, no gaps, start with opqrstuv etc
;; type 2
;; 3 lines repeat, gap on right side
;; type 4:
;; 3 lines repeat, no gaps, start with opqr etc.
;;
;; HD6845R:
;; no gaps, 3 lines repeat.
loop:
ld b,&f5
l2:
in a,(c)
rra
jr nc,l2
halt
halt
halt
di
defs 64-3-4-3-2-1-1-8
ld bc,&bc01
out (c),c
;; different lengths
ld hl,table
ld e,end_table-table
inc b
loop2:
ld a,(hl)   ;; [2]
out (c),a ;; [4]
inc hl ;; [2]
dec e ;; [1]
defs 64-3-2-2-4-1
jp nz,loop2 ;; [3]
defs 2+32

;; switch 40/ff before and after HCC=40
rept 17
ld de,0+(40*256)+&ff ;; [3]
out (c),d ;; [4]
defs 8
out (c),e ;; [4]
defs 64-4-8-4-3
endm

;; switch FF then 55 just in time
rept 17
ld de,&ff00+55 ;; [3]
out (c),d ;; [4]
defs 8
out (c),e ;; [4]
defs 64-4-8-4-3
endm

ld d,65
out (c),d
defs 64-4-2
defs 64*9

ld d,64
out (c),d
defs 64-4-2
defs 64*9

ld d,63
out (c),d
defs 64-4-2
defs 64*9

ld d,62
out (c),d
defs 64-4-2
defs 64*9

ld d,61
out (c),d
defs 64-4-2
defs 64*9



ld bc,&bd00+40
out (c),c
ei

jp loop

table:
defb 39
defb 38
defb 37
defb 36
defb 35
defb 34
defb 33
defb 32
defb 31
defb 30
defb 31
defb 32
defb 33
defb 34
defb 35
defb 36
defb 37
defb 38
defb 39
defb 40
end_table:



end start
