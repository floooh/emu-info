org &8000
;; use all possible in/out to set colours and show timings
start:
ld hl,&c000
ld d,h
ld e,l
ld (hl),&00
inc de
ld bc,&3fff
ldir

di
ld hl,&c9fb
ld (&0038),hl
ei


loop:
ld b,&f5
l1:
in a,(c)
rra
jr nc,l1
ld bc,&bc00
out (c),c
ld bc,&bd00+63
out (c),c
ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c
halt
halt
halt
di
ld bc,&7f00
out (c),c

;; all pastel blue
ld a,&7f
rept 8
out (&44),a	;; [3]
out (&55),a	;; [3]
out (&57),a	;; [3]
out (&5b),a	;; [3]
out (&4b),a	;; [3]
out (&5b),a	;; [3]
out (&57),a	;; [3]
out (&55),a	;; [3]
out (&44),a	;; [3]
out (&44),a	;; [3]
out (&55),a	;; [3]
out (&57),a	;; [3]
out (&5b),a	;; [3]
out (&4b),a	;; [3]
out (&5b),a	;; [3]
out (&57),a	;; [3]
out (&55),a	;; [3]
out (&44),a	;; [3]
out (&44),a	;; [3]
out (&55),a	;; [3]
out (&57),a	;; [3]
nop
endm

if 0
;; all colours
ld a,%01100000
rept 27
out (&ff),a
inc a
defs 64-4
endm

;; accross
ld a,%01100000
rept 16*8
out (&ff),a
inc a
endm
endif

ld b,&7f
ld h,&44
ld l,&55
ld d,&57
ld e,&52
rept 8
out (c),h
out (c),l
out (c),d
out (c),e
out (c),h
out (c),l
out (c),d
out (c),e
out (c),h
out (c),l
out (c),d
out (c),e
out (c),h
out (c),l
out (c),d
out (c),e
endm


;; diagonal
ld hl,colours
ld a,&80

rept 16
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
ld b,a
outi
defs 4
endm

;; diagonal
ld hl,end_colours-1
ld a,&80

rept 16
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
ld b,a
outd
defs 4
endm

;; blank
ld a,&7f
rept 8
in a,(&44)	;; [3]
in a,(&55)	;; [3]
in a,(&57)	;; [3]
in a,(&5b)	;; [3]
in a,(&4b)	;; [3]
in a,(&5b)	;; [3]
in a,(&57)	;; [3]
in a,(&55)	;; [3]
in a,(&44)	;; [3]
in a,(&44)	;; [3]
in a,(&55)	;; [3]
in a,(&57)	;; [3]
in a,(&5b)	;; [3]
in a,(&4b)	;; [3]
in a,(&5b)	;; [3]
in a,(&57)	;; [3]
in a,(&55)	;; [3]
in a,(&44)	;; [3]
in a,(&44)	;; [3]
in a,(&55)	;; [3]
in a,(&57)	;; [3]
nop
endm

if 0
ld bc,&bc01
out (c),c

ld hl,crtc_vals
ld d,&2
rept 8
ld b,d
otir
defs 64-5
endm

ld bc,&bc01
out (c),c
ld hl,end_crtc_vals-1
ld d,&2
rept 8
ld b,d
otdr
defs 64-5
endm
endif


ld hl,colours2
ld a,&7f

rept 16
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
ld b,a
ini
defs 4
endm

ld hl,end_colours2
ld a,&7f

rept 16
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
ld b,a
ind
defs 4
endm

if 0
ld bc,&bc01
out (c),c

ld hl,crtc_vals
ld d,&1
rept 8
ld b,d
inir
defs 64-6
endm

ld bc,&bc01
out (c),c

ld hl,end_crtc_vals-1
ld d,&1
rept 8
ld b,d
indr
defs 64-6
endm
endif
ld bc,&bc00
out (c),c
ld bc,&bd00+63
out (c),c

ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c
ei
halt
jp loop

crtc_vals:
rept 8
defb 39
defb 38
defb 37
defb 36
defb 35
defb 34
defb 33
defb 32
endm
end_crtc_vals:

colours:
rept 16
defb &44
defb &55
defb &57
defb &5b
defb &4b
defb &5b
defb &57
defb &55
defb &44
endm
end_colours:

colours2:
rept 16
defs 8
endm
end_colours2:

end start