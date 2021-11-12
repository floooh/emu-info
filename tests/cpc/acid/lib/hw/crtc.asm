wait_vsync_start:
ld b,&f5
wvs:
in a,(c)
rra
jr nc,wvs
ret

wait_vsync_end:
ld b,&f5
wve:
in a,(c)
rra
jr c,wve
ret

;;-----------------------

;; sync with start of vsync
vsync_sync:
ld b,&f5
;; wait for vsync start
vs1: in a,(c)
rra
jr nc,vs1
;; wait for vsync end
vs2: in a,(c)
rra 
jr c,vs2
ret


set_crtc:
ld bc,&bc00
ld e,16
sc:
out (c),c
inc b
ld a,(hl)
out (c),a
dec b
inc hl
inc c
dec e
jr nz,sc
ret

;;-------------------------------------------

crtc_reset:
ld hl,crtc_50hz
jr set_crtc

crtc_50hz:
defb &3f, &28, &2e, &8e, &26, &00, &19, &1e, &00, &07, &00,&00,&30,&00,&c0,&00
crtc_60hz:
defb &3f, &28, &2e, &8e, &1f, &06, &19, &1b, &00, &07, &00,&00,&30,&00,&c0,&00
