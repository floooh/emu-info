org &8000

call test1	;; read input with motor on/off
call test2	;; write to cassette and read back with motor on
call test3	;; write to cassette and read back with motor off

;; need to do tests with play, record, pause etc on
;; also test to see how long it takes for motor switch

test4:
call motor_off

ld b,&f5
in d,(c)

call motor_on
ld hl,0
ld b,&f5
test4b
inc hl
in a,(c)
xor d
and &80
jr z,test4b
ret




test1:
;; b input, c output
ld bc,&f700+%10000010
out (c),c

call motor_off
call read_cas_in
call motor_on
call read_cas_in
call motor_off
call read_cas_in
ret

test2:
call motor_on

ld bc,&f600+%110000
out (c),c
call read_cas_in
ld bc,&f600+%100000
out (c),c
call read_cas_in
ld bc,&f600+%110000
out (c),c
call read_cas_in
ld bc,&f600+%100000
out (c),c
call read_cas_in
ret


test3:
call motor_off

ld bc,&f600+%110000
out (c),c
call read_cas_in
ld bc,&f600+%100000
out (c),c
call read_cas_in
ld bc,&f600+%110000
out (c),c
call read_cas_in
ld bc,&f600+%100000
out (c),c
call read_cas_in
ret



motor_off:
ld bc,&f600
out (c),c
ret

motor_on:
ld bc,&f610
out (c),c
ret



read_cas_in:
ld e,64
rb1:
ld b,&f5
in a,(c)
and &80
ld (hl),a
inc hl
dec e
jr nz,rb1
ret
