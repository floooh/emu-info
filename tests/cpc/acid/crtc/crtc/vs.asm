;;-----------------------------------------------------------------
;; programs in different vsync widths, times vsync width, then
;; stores the result in a table.
;;
;; carry true if the values are not all the same, carry false
;; if they are the same. First byte in table indicates what
;; the value is

.vsync_fixed_test
ld hl,vsync_width
ld b,15

;; get first value
ld a,(hl)
inc hl

;; check all other values in buffer are same.
.vf1
cp (hl)
jr nz,vf2
inc hl
djnz vf1
or a
ret

.vf2
scf
ret


.vsync_analyze
call vsync_fixed_test
jr c,va1

ld hl,vsync_variable
call show_string

ld b,16
ld hl,vsync_width
.va3
ld a,b
sub 16
call show_byte
ld a,":"
call show_char
ld a,(hl)
inc hl
call show_byte
call crlf
djnz va3
ret

.va1
ld hl,vsync_fixed
call show_string

ld a,(hl)
call show_byte
call crlf
ret

.vsync_check
;; ensure HTOT is 64 chars, otherwise this code will not
;; work.
ld bc,&bc00
out (c),c
ld bc,&bd3f
out (c),c

;; program all possible vsync widths
;; then do check.

ld hl,vsync_width
ld b,16    ;; width 15-0
.vchk
push bc
ld a,b
dec a
add a,a
add a,a
add a,a
add a,a    ;; into upper nibble
or &e    ;; horizontal sync width
ld bc,&bc03   ;; set vertical sync width
out (c),c
inc b
out (c),a

call vs_time  ;; time vsync
ld (hl),a   ;; store scan-line length timed
inc hl

pop bc
djnz vchk

ld bc,&bc03
out (c),c
ld bc,&bd8e
out (c),c
ret

.vsync_width
defs 16


.vs_time
;; sync with start of vsync

call vsync_sync

;; check vsync each line.
;; if active, increment counter,
;; otherwise quit.

ld e,0          ;; line counter
.v2
ld b,&f5        ;; [2]
in a,(c)        ;; [4]
rra             ;; [1]
jp nc,v3        ;; [3]
inc e           ;; [1]
defs 64-2-4-1-3-1-3
jp v2          ;; [3]


.v3
ld a,e
ret

.vsync_variable
defb "Vsync width can be programmed.",13,10,0

.vsync_fixed
defb "Vsync width is fixed regardless of value programmed.",13,10,0
