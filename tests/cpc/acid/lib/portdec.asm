data_decode:
ld (data_restore_extra+1),bc
ld a,h
ld (wantedDataImportant),a
ld a,l
ld (wantedDataSuccessOR),a
ld (dataport),de
ld (dataport_dec_test+1),ix
ld (dataport_dec_init+1),iy

ld a,0
ld (datasuccessOR),a
ld a,&ff
ld (datasuccessAND),a

di
dataport_dec_init:
call justret


ld d,0 ;; loop
ld c,0 ;; data
datdec:
push de
push bc

push bc
push de
push hl
call data_restore

pop hl
pop de
pop bc

;; write data to port
push bc
ld a,c
ld bc,(dataport)
out (c),a
pop bc
;; run test
push bc
dataport_dec_test:
call justret
pop bc
jr nz,datanext

;; success
ld a,(datasuccessOR)
or c
ld (datasuccessOR),a
ld a,(datasuccessAND)
and c
ld (datasuccessAND),a

datanext:
pop bc
pop de
inc c
dec d
jr nz,datdec

ld a,(datasuccessAND)
ld d,a
ld a,(datasuccessOR)
xor d
cpl
ld (dataimportant),a

call data_restore
ei

ld a,(dataimportant)
ld d,a
ld a,(datasuccessOR)
ld e,a

ld b,8
ddl1:
push bc
push de
bit 7,d		;; important??
ld a,'x'
jr z,ddl2
;; yes important, but what value?
bit 7,e
ld a,'1'
jr nz,ddl2
ld a,'0'
ddl2:
call &bb5a
pop de
pop bc
rlc d
rlc e
djnz ddl1

ld a,'-'
call &bb5a

ld ix,result_buffer
ld a,(wantedDataImportant)
ld (ix+1),a
ld a,(dataimportant)
ld (ix+0),a
ld a,(wantedDataSuccessOR)
ld (ix+3),a
ld a,(portsuccessOR)
ld (ix+2),a

ld bc,2
jp simple_results

wantedDataImportant:
defb 0
wantedDataSuccessOR:
defb 0
datasuccessOR:
defb 0
datasuccessAND:
defb 0
dataimportant:
defb 0
dataport:
defw 0

io_decode:
ld (port_restore_extra+1),bc
ld (wantedPortImportant),de
ld (wantedPortSuccessOR),hl
ld (port_dec_test+1),ix
ld (port_dec_init+1),iy
di

ld hl,0
ld (portsuccessOR),hl
ld hl,&ffff
ld (portsuccessAND),hl

port_dec_init:
call justret

ld de,0
ld bc,0
nextloop:
push bc
push de
push hl
call port_restore

pop hl
pop de
pop bc

push bc
push hl
push de
port_dec_test:
call justret
pop de
pop hl
pop bc
jr nz,next

;; success
push hl
push bc
ld hl,(portsuccessOR)
ld a,h
or b
ld h,a
ld a,l
or c
ld l,a
ld (portsuccessOR),hl
ld hl,(portsuccessAND)
ld a,h
and b
ld h,a
ld a,l
and c
ld l,a
ld (portsuccessAND),hl
pop bc
pop hl

next:
inc bc
dec de
ld a,d
or e
jr nz,nextloop

ld hl,(portsuccessOR)
ld de,(portsuccessAND)
ld a,h
xor d
cpl
ld h,a
ld a,l
xor e
cpl
ld l,a
ld (portimportant),hl

call port_restore
ei
ld de,(portimportant)
ld hl,(portsuccessOR)
ld b,16
dl1:
push bc
push hl
push de
bit 7,d		;; important??
ld a,'x'
jr z,dl2
;; yes important, but what value?
bit 7,h
ld a,'1'
jr nz,dl2
ld a,'0'
dl2:
call &bb5a
pop de
pop hl
pop bc
add hl,hl
ex de,hl
add hl,hl
ex de,hl
djnz dl1

ld a,'-'
call &bb5a
ld ix,result_buffer
ld de,(wantedPortImportant)
ld (ix+1),e
ld (ix+3),d
ld de,(portimportant)
ld (ix+0),e
ld (ix+2),d
ld de,(wantedPortSuccessOR)
ld (ix+5),e
ld (ix+7),d
ld de,(portsuccessOR)
ld (ix+4),e
ld (ix+6),d
ld bc,4
jp simple_results

port_restore:
port_restore_extra:
call justret
jr restore

data_restore:
data_restore_extra:
call justret
jr restore

restore:
;; rom
ld bc,&df00
out (c),c
;; mode/rom
ld bc,&7f00+%10001110
out (c),c
;; pal
ld bc,&7fc0
out (c),c
;; palette
ld bc,&7f00
out (c),c
ld bc,&7f54
out (c),c
ld bc,&7f01
out (c),c
ld bc,&7f4b
out (c),c
ld bc,&7f10
out (c),c
ld bc,&7f54
out (c),c
ld bc,&f700+%10000010
out (c),c
ld bc,&f600
out (c),c
xor a
ld bc,&fa7e
out (c),a

call crtc_reset
justret:
ret

wantedPortImportant:
defw 0
wantedPortSuccessOR:
defw 0

portsuccessOR:
defw 0
portsuccessAND:
defw 0

portimportant:
defw 0

