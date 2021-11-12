
org &4000

start:
call getCRTCType
add a,'0'
call &bb5a
call &bb06
ret

    ; Detect CRTC type

    ; Output

    ; a = CRTC type (0,1,2,3,4)

getCRTCType:
    ld    bc,&bc0c        ; select reg 12 (R/W)
    out    (c),c
    ld    bc,&bd00+%0110100    ; write a value
    out    (c),c

;    call    wVb
    ld     b,&f5            ; wait Vbl
vbLoop1:
    in    a,(c)
    rra
    jr    c,vbLoop1
vbLoop2:
    in    a,(c)
    rra
    jr    nc,vbLoop2

    ld    b,&be            ; read from status register
    in    a,(c)
    ld    d,a

    inc    b            ; read from &bf (read register)
    in    a,(c)

    cp    d            ; &be == &bf?
    jr    z,CRTC_3_4

    ; CRTC 0 1 or 2

    cp    c;%0110100        ; same value?
    jr    nz,CRTC_1_2

    ; CRTC 0

    xor    a       
    ret

CRTC_1_2:
    ld    a,d
    and    %011111
    jr    nz,CRTC_2

    ; CRTC 1

    ld    a,1
    ret

    ; CRTC 2

CRTC_2:
    ld    a,2
    ret

    ; CRTC 3 or 4

CRTC_3_4:
    ld     bc,&f782
    out     (c),c
    dec     b
    ld     a,&F
    out     (c),a
    inc     b
    out     (c),c
    dec     b
    in     c,(c)
    cp     c
    jr     nz,CRTC_4

    ; CRTC 3

CRTC_3:
    ld    a,3
    ret

    ; CRTC 4

CRTC_4:
    ld    a,4
    ret

end start	