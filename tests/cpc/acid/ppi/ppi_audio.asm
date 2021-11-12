;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
org &8000


km_wait_char equ &bb06
txt_output equ &bb5a
scr_set_mode equ &bc0e

;; set colour with bit 5 set
start:
ld a,2
call scr_set_mode
ld hl,message
call display_msg
call km_wait_char

;; set to mode 1, clear screen and reset CRTC base
ld a,2
call scr_set_mode

ld hl,message_tw_moff
call display_msg

di
ld bc,&f700+%10000010
out (c),c

;; produces sound on my cpc with type 1 and type 4
ld h,&20		;; tape write
ld l,&0
ld de,5000
ld b,&f6
ppi_aud1:
out (c),h
call delay
out (c),l
call delay
dec de
ld a,d
or e
jr nz,ppi_aud1
ei

ld hl,message_tw_mon
call display_msg

di
ld bc,&f700+%10000010
out (c),c

;; produces sound on my cpc with type 1
;; on type 4 with cassette in this is louder than normal tape write

ld h,&30		;; tape motor and tape write
ld l,&0
ld de,5000
ld b,&f6
ppi_aud2:
out (c),h
call delay
out (c),l
call delay

dec de
ld a,d
or e
jr nz,ppi_aud2
ei

ld hl,message_tr_moff
call display_msg

di
ld bc,&f700+%1000000
out (c),c
ld bc,&f600
out (c),c
ld h,&80
ld l,&0
ld de,5000
ld b,&f5
ppi_aud3:
out (c),h
call delay
out (c),l
call delay

dec de
ld a,d
or e
jr nz,ppi_aud3
ei

ld hl,message_tr_mon
call display_msg


di
;; tape read and motor
ld bc,&f700+%1000000
out (c),c
ld bc,&f610
out (c),c
ld h,&80
ld l,&0
ld de,5000
ld b,&f5
ppi_aud4:
out (c),h
call delay
out (c),l
call delay

dec de
ld a,d
or e
jr nz,ppi_aud4
ei

ld hl,tests_done
call display_msg
call &bb06
rst 0

delay:
defs 128
ret

message_tw_moff:
defb "Tape write - motor off - Sound",13,10,0

message_tw_mon:
defb "Tape write - motor on - Sound (louder on Cost down)",13,10,0

message_tr_moff:
defb "Tape read - motor off - No sound",13,10,0

message_tr_mon:
defb "Tape read - motor on - No sound",13,10,0

tests_done:
defb "Tests complete",0

display_msg:
ld a,(hl)
or a
ret z
inc hl
call txt_output
jr display_msg


message:
defb "This is an audible test.",13,10,13,10
defb "This test produces sound using the PPI.",13,10,13,10
defb "This test only runs on CPC and can only be heard through",13,10
defb "the speaker.",13,10,13,10
defb "The speaker volume needs to be turned up to hear it.",13,10,13,10
defb "Press a key to start",0


end start