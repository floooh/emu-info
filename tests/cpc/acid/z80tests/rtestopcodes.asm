;; (c) Copyright Kevin Thacker 2015-2016
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.

;; use this to test r register increment

;; halt need special
;; jr taken not taken need special
;; int need special
;; ret need special

include "../lib/testdef.asm"
org &4000

rtest macro testtext, count, val
db    testtext, 0
db 		count
db 	val
endm


;; AY-3-8912 tester 
org &2000
start:
call cls
ld hl,message
call display_msg
call wait_key

call cls
call do_rtests
call wait_key
ret



display_msg:
ld a,(hl)
or a
ret z
inc hl
call output_char
jr display_msg

message:
defb "This is an automatic test.",13,10,13,10
defb "This test checks the amount the R value is increment for various Z80 instructions and the interrupt modes. ",13,10,13,10
defb "Passes on CPC6128 with SGSZ8400AB1",13,10,13,10
defb "Press a key to start",0

of_1:
defb "R increment &7e",0


of_2:
defb "R increment &fe",0

do_rtests:
ld hl,of_1
call output_msg
ld a,'-'
call output_char

;; check overflow
ld a,&7e
ld c,0
call check_r

;; check overflow bit 7 set
ld hl,of_2
call output_msg
ld a,'-'
call output_char

ld a,&fe
ld c,&80
call check_r


ld hl,int_1
call output_msg
ld a,'-'
call output_char

call delay_int
call set_int
xor a
ld r,a
ei			;; interrupt is taken after ld a,r
			;; so will not be taken..
ld a,r
ld c,3
call restore_int
call check_r_result


ld hl,int_2
call output_msg
ld a,'-'
call output_char

call delay_int
call set_int
xor a
ld r,a
ei			;; interrupt is taken after nop
nop
ld a,r
ld c,7
call restore_int
call check_r_result


ld hl,int_3
call output_msg
ld a,'-'
call output_char

call delay_int
call set_int
xor a
ld r,a
ei
halt			;; 1 iteration of halt to be done
ld a,r
ld c,7
call restore_int
call check_r_result


ld hl,int_4
call output_msg
ld a,'-'
call output_char


;; setup for im2
ld hl,&a000
ld e,l
ld d,h
inc de
ld (hl),&a1
ld bc,257
ldir

;; setup vector
ld a,&c3
ld (&a1a1),a
ld hl,int_rout
ld (&a1a2),hl

ld a,&a0
ld i,a

call delay_int
im 2

xor a
ld r,a
ei
halt			;; 1 iteration of halt to be done
ld a,r
im 1
ld c,9
call check_r_result


;; result will be different depend on plus or cpc 
;; with plus we can have more control to see what happens
ld hl,int_5
call output_msg
ld a,'-'
call output_char

call delay_int
call set_int
im 0

xor a
ld r,a
ei
halt			;; 1 iteration of halt to be done
ld a,r
im 1
;; got 7 on cpc with type 1 crtc
ld c,7
call restore_int
call check_r_result


ld hl,int_6
call output_msg
ld a,'-'
call output_char

call delay_int
call set_int
im 1

xor a
ld r,a
ei
halt			;; 1 iteration of halt to be done
ld a,r
im 1
;; got 7 on cpc with type 1 crtc
ld c,7
call restore_int
call check_r_result

ld hl,iff_1
call output_msg
ld a,'-'
call output_char
di
call get_iff2
ld c,%0
call check_r_result

ld hl,iff_2
call output_msg
ld a,'-'
call output_char

ei
call get_iff2
ld c,%100
call check_r_result


ld hl,iff_3
call output_msg
ld a,'-'
call output_char
ei
nop
call get_iff2
ld c,%100
call check_r_result


;; check all values for r
ld b,0
xor a
dr1:
push af
push bc

push af
push bc

call outputhex8
ld a,'-'
call output_char
pop bc
pop af


push af
push af
and &80
ld c,a
pop af

inc a
inc a
and &7f
or c
ld c,a
pop af
call check_r

pop bc
pop af
inc a
djnz dr1


ld hl,rtests
rloop:
ld a,(hl)
or a
ret z

call output_msg
ld a,'-'
call output_char

;; read opcode count
ld b,(hl)
inc hl
;; read r reg value
ld c,(hl)
inc hl
call do_test
jp rloop

int_rout:
ei
reti

set_int:
ld a,(&0038)
ld (store_int),a
ld hl,(&0039)
ld (store_int+1),hl

ld hl,&c9fb
ld (&0038),hl
ret

iff_1:
defb "DI & IFF2",0
iff_2:
defb "EI & IFF2",0
iff_3:
defb "EI: NOP & IFF2",0

int_1:
defb "(IM1) EI: LD A,R",0

int_2:
defb "(IM1) EI: NOP: LD A,R",0

int_3:
defb "(IM1) HALT",0

int_4:
defb "Interrupt mode 2",0

int_5:
defb "Interrupt mode 0",0

int_6:
defb "Interrupt mode 1",0


get_iff2:
ld a,r
push af
pop hl
ld a,l
and %100
ret

restore_int:
di
push af
push hl
ld a,(store_int+0)
ld (&0038),a
ld hl,(store_int+1)
ld (&0039),hl
pop hl
pop af
ei
ret

store_int:
defs 3

check_r:
di
ld r,a
ld a,r
ei
check_r_result:
cp c
jp z,check_r2
push af
push bc
call report_negative
pop bc
pop af
ld b,a
call report_got_wanted
ret

delay_int:
ei
ld b,&f5
din:
in a,(c)
rra
jr nc,din
halt
halt
halt
di
ld b,&f5
din2:
in a,(c)
rra
jr nc,din2
ret



check_r2:
call report_positive
ret

;; hl = points to opcode
;; b = number of bytes for opcode
;; c = R count
do_test:
di

;; clear area
push bc

push hl
push bc
;; clear test area with nops
ld hl,test_area
ld bc,end_test_area-test_area-1
ld e,l
ld d,h
inc de
ld (hl),0
ldir
pop bc
pop hl
;; copy instruction into test area
ld de,test_area
ld c,b
ld b,0
ldir
;; write ld a,r opcode next
ld a,&ed
ld (de),a
inc de
ld a,&5f
ld (de),a
inc de
pop bc

push hl
push bc
di

push ix
push iy
ex af,af'
push af
ex af,af'
exx
push bc
push de
push hl
exx
ld ix,buffer
ld iy,buffer
ld de,buffer
ld hl,buffer
ld bc,buffer
ld (sp_store+1),sp
ld sp,buffer
ld bc,&bc0f
out (c),c
;; initialse r value
xor a
ld r,a

;; copied to here
test_area:
defs 8
end_test_area:

sp_store:
ld sp,0
sub 2
exx
pop hl
pop de
pop bc
exx
ex af,af'
pop af
ex af,af'
pop iy
pop ix
im 1
ei

pop bc
cp c
jp z,pos
push af
push bc
call report_negative
pop bc
pop af
ld b,a
call report_got_wanted
pop hl
ret

pos:
call report_positive
pop hl
ret


defs 256
buffer:
defs 256



rtests:
rtest "nop", 1, 1
nop

rtest "ld bc,nnnn", 3, 1
ld bc,&0101

rtest "ld (bc),a", 1, 1
ld (bc),a

rtest "inc bc", 1, 1
inc bc

rtest "inc b", 1, 1
inc b

rtest "dec b", 1, 1
dec b

rtest "ld b,n", 2, 1
ld b,&1

rtest "rlca", 1, 1
rlca

rtest "ex af,af'", 2, 2
ex af,af'
ex af,af'

rtest "add hl,bc", 1, 1
add hl,bc

rtest "ld a,(bc)", 1, 1
ld a,(bc)

rtest "dec bc", 1, 1
dec bc

rtest "inc c", 1, 1
inc c

rtest "dec c", 1, 1
dec c

rtest "ld c,n", 2, 1
ld c,&1

rtest "rrca", 1,1
rrca

rtest "djnz", 2,1
defb &10,&00

rtest "ld de,n",3,1
ld de,&0101

rtest "ld (de),a",1,1
ld (de),a

rtest "inc de",1,1
inc de

rtest "inc d",1,1
inc d

rtest "dec d",1,1
dec d

rtest "ld d,n",2,1
ld d,&1

rtest "rla",1,1
rla

rtest "jr e",2,1
defb &18,&00

rtest "add hl,de",1,1
add hl,de

rtest "ld a,(de)",1,1
ld a,(de)

rtest "dec de",1,1
dec de

rtest "inc e",1,1
inc e

rtest "dec e",1,1
dec e

rtest "ld e,n",2,1
ld e,&1

rtest "rra",1,1
rra

rtest "jr nz,e",2,1
defb &20,&00


rtest "ld hl,n",3,1
ld hl,&0101

rtest "ld (nnnn),hl",3,1
ld (buffer),hl

rtest "inc hl",1,1
inc hl

rtest "inc h",1,1
inc h

rtest "dec h",1,1
dec h

rtest "ld h,n",2,1
ld h,&1

rtest "daa",1,1
daa

rtest "jr z,e",2,1
defb &28,&00

rtest "add hl,hl",1,1
add hl,hl

rtest "ld hl,(nnnn)",3,1
ld hl,(buffer)

rtest "dec hl",1,1
dec hl

rtest "inc l",1,1
inc l

rtest "dec l",1,1
dec l

rtest "ld l,n",2,1
ld l,&1

rtest "cpl",1,1
cpl

rtest "jr nc,e",2,1
defb &30,&00


rtest "ld sp,n",3,1
ld sp,&0101

rtest "ld (nnnn),a",3,1
ld (buffer),a

rtest "inc sp",1,1
inc sp

rtest "inc (hl)",1,1
inc (hl)

rtest "dec (hl)",1,1
dec (hl)

rtest "ld (hl),n",2,1
ld (hl),&1

rtest "scf",1,1
scf

rtest "jr c,e",2,1
defb &38,&00

rtest "add hl,sp",1,1
add hl,sp

rtest "ld a,(nnnn)",3,1
ld a,(buffer)

rtest "dec sp",1,1
dec sp

rtest "inc a",1,1
inc a

rtest "dec a",1,1
dec a

rtest "ld a,n",2,1
ld a,&1

rtest "ccf",1,1
ccf

rtest "ld b,b",1,1
ld b,b
rtest "ld b,c",1,1
ld b,c
rtest "ld b,d",1,1
ld b,d
rtest "ld b,e",1,1
ld b,e
rtest "ld b,h",1,1
ld b,h
rtest "ld b,l",1,1
ld b,l
rtest "ld b,(hl)",1,1
ld b,(hl)
rtest "ld b,a",1,1
ld b,a

rtest "ld c,b",1,1
ld c,b
rtest "ld c,c",1,1
ld c,c
rtest "ld c,d",1,1
ld c,d
rtest "ld c,e",1,1
ld c,e
rtest "ld c,h",1,1
ld c,h
rtest "ld c,l",1,1
ld c,l
rtest "ld c,(hl)",1,1
ld c,(hl)
rtest "ld c,a",1,1
ld c,a

rtest "ld d,b",1,1
ld d,b
rtest "ld d,c",1,1
ld d,c
rtest "ld d,d",1,1
ld d,d
rtest "ld d,e",1,1
ld d,e
rtest "ld d,h",1,1
ld d,h
rtest "ld d,l",1,1
ld d,l
rtest "ld d,(hl)",1,1
ld d,(hl)
rtest "ld d,a",1,1
ld d,a

rtest "ld e,b",1,1
ld e,b
rtest "ld e,c",1,1
ld e,c
rtest "ld e,d",1,1
ld e,d
rtest "ld e,e",1,1
ld e,e
rtest "ld e,h",1,1
ld e,h
rtest "ld e,l",1,1
ld e,l
rtest "ld e,(hl)",1,1
ld e,(hl)
rtest "ld e,a",1,1
ld e,a


rtest "ld h,b",1,1
ld h,b
rtest "ld h,c",1,1
ld h,c
rtest "ld h,d",1,1
ld h,d
rtest "ld h,e",1,1
ld h,e
rtest "ld h,h",1,1
ld h,h
rtest "ld h,l",1,1
ld h,l
rtest "ld h,(hl)",1,1
ld h,(hl)
rtest "ld h,a",1,1
ld h,a

rtest "ld l,b",1,1
ld l,b
rtest "ld l,c",1,1
ld l,c
rtest "ld l,d",1,1
ld l,d
rtest "ld l,e",1,1
ld l,e
rtest "ld l,h",1,1
ld l,h
rtest "ld l,l",1,1
ld l,l
rtest "ld l,(hl)",1,1
ld l,(hl)
rtest "ld l,a",1,1
ld l,a

rtest "ld (hl),b",1,1
ld (hl),b
rtest "ld (hl),c",1,1
ld (hl),c
rtest "ld (hl),d",1,1
ld (hl),d
rtest "ld (hl),e",1,1
ld (hl),e
rtest "ld (hl),h",1,1
ld (hl),h
rtest "ld (hl),l",1,1
ld (hl),l
rtest "ld (hl),a",1,1
ld (hl),a

rtest "ld a,b",1,1
ld a,b
rtest "ld a,c",1,1
ld a,c
rtest "ld a,d",1,1
ld a,d
rtest "ld a,e",1,1
ld a,e
rtest "ld a,h",1,1
ld a,h
rtest "ld a,l",1,1
ld a,l
rtest "ld a,(hl)",1,1
ld a,(hl)
rtest "ld a,a",1,1
ld a,a

rtest "add a,b",1,1
add a,b
rtest "add a,c",1,1
add a,c
rtest "add a,d",1,1
add a,d
rtest "add a,e",1,1
add a,e
rtest "add a,h",1,1
add a,h
rtest "add a,l",1,1
add a,l
rtest "add a,(hl)",1,1
add a,(hl)
rtest "add a,a",1,1
add a,a


rtest "adc a,b",1,1
adc a,b
rtest "adc a,c",1,1
adc a,c
rtest "adc a,d",1,1
adc a,d
rtest "adc a,e",1,1
adc a,e
rtest "adc a,h",1,1
adc a,h
rtest "adc a,l",1,1
adc a,l
rtest "adc a,(hl)",1,1
adc a,(hl)
rtest "adc a,a",1,1
adc a,a


rtest "sub a,b",1,1
sub b
rtest "sub a,c",1,1
sub c
rtest "sub a,d",1,1
sub d
rtest "sub a,e",1,1
sub e
rtest "sub a,h",1,1
sub h
rtest "sub a,l",1,1
sub l
rtest "sub a,(hl)",1,1
sub (hl)
rtest "sub a,a",1,1
sub a


rtest "sbc a,b",1,1
sbc a,b
rtest "sbc a,c",1,1
sbc a,c
rtest "sbc a,d",1,1
sbc a,d
rtest "sbc a,e",1,1
sbc a,e
rtest "sbc a,h",1,1
sbc a,h
rtest "sbc a,l",1,1
sbc a,l
rtest "sbc a,(hl)",1,1
sbc a,(hl)
rtest "sbc a,a",1,1
sbc a,a



rtest "and a,b",1,1
and b
rtest "and a,c",1,1
and c
rtest "and a,d",1,1
and d
rtest "and a,e",1,1
and e
rtest "and a,h",1,1
and h
rtest "and a,l",1,1
and l
rtest "and a,(hl)",1,1
and (hl)
rtest "and a,a",1,1
and a


rtest "xor a,b",1,1
xor b
rtest "xor a,c",1,1
xor c
rtest "xor a,d",1,1
xor d
rtest "xor a,e",1,1
xor e
rtest "xor a,h",1,1
xor h
rtest "xor a,l",1,1
xor l
rtest "xor a,(hl)",1,1
xor (hl)
rtest "xor a,a",1,1
xor a


rtest "or a,b",1,1
or b
rtest "or a,c",1,1
or c
rtest "or a,d",1,1
or d
rtest "or a,e",1,1
or e
rtest "or a,h",1,1
or h
rtest "or a,l",1,1
or l
rtest "or a,(hl)",1,1
or (hl)
rtest "or a,a",1,1
or a


rtest "cp a,b",1,1
cp b
rtest "cp a,c",1,1
cp c
rtest "cp a,d",1,1
cp d
rtest "cp a,e",1,1
cp e
rtest "cp a,h",1,1
cp h
rtest "cp a,l",1,1
cp l
rtest "cp a,(hl)",1,1
cp (hl)
rtest "cp a,a",1,1
cp a

rtest "pop bc",1,1
pop bc

rtest "push bc",1,1
push bc

rtest "add a,n",2,1
add a,&1


rtest "rlc b",2,2
rlc b
rtest "rlc c",2,2
rlc c
rtest "rlc d",2,2
rlc d
rtest "rlc e",2,2
rlc e
rtest "rlc h",2,2
rlc h
rtest "rlc l",2,2
rlc l
rtest "rlc (hl)",2,2
rlc (hl)
rtest "rlc a",2,2
rlc a



rtest "rrc b",2,2
rrc b
rtest "rrc c",2,2
rrc c
rtest "rrc d",2,2
rrc d
rtest "rrc e",2,2
rrc e
rtest "rrc h",2,2
rrc h
rtest "rrc l",2,2
rrc l
rtest "rrc (hl)",2,2
rrc (hl)
rtest "rrc a",2,2
rrc a



rtest "rl b",2,2
rl b
rtest "rl c",2,2
rl c
rtest "rl d",2,2
rl d
rtest "rl e",2,2
rl e
rtest "rl h",2,2
rl h
rtest "rl l",2,2
rl l
rtest "rl (hl)",2,2
rl (hl)
rtest "rl a",2,2
rl a


rtest "rr b",2,2
rr b
rtest "rr c",2,2
rr c
rtest "rr d",2,2
rr d
rtest "rr e",2,2
rr e
rtest "rr h",2,2
rr h
rtest "rr l",2,2
rr l
rtest "rr (hl)",2,2
rr (hl)
rtest "rr a",2,2
rr a


rtest "sla b",2,2
sla b
rtest "sla c",2,2
sla c
rtest "sla d",2,2
sla d
rtest "sla e",2,2
sla e
rtest "sla h",2,2
sla h
rtest "sla l",2,2
sla l
rtest "sla (hl)",2,2
sla (hl)
rtest "sla a",2,2
sla a

rtest "sra b",2,2
sra b
rtest "sra c",2,2
sra c
rtest "sra d",2,2
sra d
rtest "sra e",2,2
sra e
rtest "sra h",2,2
sra h
rtest "sra l",2,2
sra l
rtest "sra (hl)",2,2
sra (hl)
rtest "sra a",2,2
sra a


rtest "sll b",2,2
defb &cb,&30
rtest "sll c",2,2
defb &cb,&31
rtest "sll d",2,2
defb &cb,&32
rtest "sll e",2,2
defb &cb,&33
rtest "sll h",2,2
defb &cb,&34
rtest "sll l",2,2
defb &cb,&35
rtest "sll (hl)",2,2
defb &cb,&36
rtest "sll a",2,2
defb &cb,&37

rtest "srl b",2,2
srl b
rtest "srl c",2,2
srl c
rtest "srl d",2,2
srl d
rtest "srl e",2,2
srl e
rtest "srl h",2,2
srl h
rtest "srl l",2,2
srl l
rtest "srl (hl)",2,2
srl (hl)
rtest "srl a",2,2
srl a


rtest "bit 0,b",2,2
bit 0,b
rtest "bit 0,c",2,2
bit 0,c
rtest "bit 0,d",2,2
bit 0,d
rtest "bit 0,e",2,2
bit 0,e
rtest "bit 0,h",2,2
bit 0,h
rtest "bit 0,l",2,2
bit 0,l
rtest "bit 0,(hl)",2,2
bit 0,(hl)
rtest "bit 0,a",2,2
bit 0,a


rtest "bit 1,b",2,2
bit 1,b
rtest "bit 1,c",2,2
bit 1,c
rtest "bit 1,d",2,2
bit 1,d
rtest "bit 1,e",2,2
bit 1,e
rtest "bit 1,h",2,2
bit 1,h
rtest "bit 1,l",2,2
bit 1,l
rtest "bit 1,(hl)",2,2
bit 1,(hl)
rtest "bit 1,a",2,2
bit 1,a

rtest "bit 2,b",2,2
bit 2,b
rtest "bit 2,c",2,2
bit 2,c
rtest "bit 2,d",2,2
bit 2,d
rtest "bit 2,e",2,2
bit 2,e
rtest "bit 2,h",2,2
bit 2,h
rtest "bit 2,l",2,2
bit 2,l
rtest "bit 2,(hl)",2,2
bit 2,(hl)
rtest "bit 2,a",2,2
bit 2,a

rtest "bit 3,b",2,2
bit 3,b
rtest "bit 3,c",2,2
bit 3,c
rtest "bit 3,d",2,2
bit 3,d
rtest "bit 3,e",2,2
bit 3,e
rtest "bit 3,h",2,2
bit 3,h
rtest "bit 3,l",2,2
bit 3,l
rtest "bit 3,(hl)",2,2
bit 3,(hl)
rtest "bit 3,a",2,2
bit 3,a

rtest "bit 4,b",2,2
bit 4,b
rtest "bit 4,c",2,2
bit 4,c
rtest "bit 4,d",2,2
bit 4,d
rtest "bit 4,e",2,2
bit 4,e
rtest "bit 4,h",2,2
bit 4,h
rtest "bit 4,l",2,2
bit 4,l
rtest "bit 4,(hl)",2,2
bit 4,(hl)
rtest "bit 4,a",2,2
bit 4,a

rtest "bit 5,b",2,2
bit 5,b
rtest "bit 5,c",2,2
bit 5,c
rtest "bit 5,d",2,2
bit 5,d
rtest "bit 5,e",2,2
bit 5,e
rtest "bit 5,h",2,2
bit 5,h
rtest "bit 5,l",2,2
bit 5,l
rtest "bit 5,(hl)",2,2
bit 5,(hl)
rtest "bit 5,a",2,2
bit 5,a


rtest "bit 6,b",2,2
bit 6,b
rtest "bit 6,c",2,2
bit 6,c
rtest "bit 6,d",2,2
bit 6,d
rtest "bit 6,e",2,2
bit 6,e
rtest "bit 6,h",2,2
bit 6,h
rtest "bit 6,l",2,2
bit 6,l
rtest "bit 6,(hl)",2,2
bit 6,(hl)
rtest "bit 6,a",2,2
bit 6,a

rtest "bit 7,b",2,2
bit 7,b
rtest "bit 7,c",2,2
bit 7,c
rtest "bit 7,d",2,2
bit 7,d
rtest "bit 7,e",2,2
bit 7,e
rtest "bit 7,h",2,2
bit 7,h
rtest "bit 7,l",2,2
bit 7,l
rtest "bit 7,(hl)",2,2
bit 7,(hl)
rtest "bit 7,a",2,2
bit 7,a


rtest "res 0,b",2,2
res 0,b
rtest "res 0,c",2,2
res 0,c
rtest "res 0,d",2,2
res 0,d
rtest "res 0,e",2,2
res 0,e
rtest "res 0,h",2,2
res 0,h
rtest "res 0,l",2,2
res 0,l
rtest "res 0,(hl)",2,2
res 0,(hl)
rtest "res 0,a",2,2
res 0,a


rtest "res 1,b",2,2
res 1,b
rtest "res 1,c",2,2
res 1,c
rtest "res 1,d",2,2
res 1,d
rtest "res 1,e",2,2
res 1,e
rtest "res 1,h",2,2
res 1,h
rtest "res 1,l",2,2
res 1,l
rtest "res 1,(hl)",2,2
res 1,(hl)
rtest "res 1,a",2,2
res 1,a

rtest "res 2,b",2,2
res 2,b
rtest "res 2,c",2,2
res 2,c
rtest "res 2,d",2,2
res 2,d
rtest "res 2,e",2,2
res 2,e
rtest "res 2,h",2,2
res 2,h
rtest "res 2,l",2,2
res 2,l
rtest "res 2,(hl)",2,2
res 2,(hl)
rtest "res 2,a",2,2
res 2,a

rtest "res 3,b",2,2
res 3,b
rtest "res 3,c",2,2
res 3,c
rtest "res 3,d",2,2
res 3,d
rtest "res 3,e",2,2
res 3,e
rtest "res 3,h",2,2
res 3,h
rtest "res 3,l",2,2
res 3,l
rtest "res 3,(hl)",2,2
res 3,(hl)
rtest "res 3,a",2,2
res 3,a

rtest "res 4,b",2,2
res 4,b
rtest "res 4,c",2,2
res 4,c
rtest "res 4,d",2,2
res 4,d
rtest "res 4,e",2,2
res 4,e
rtest "res 4,h",2,2
res 4,h
rtest "res 4,l",2,2
res 4,l
rtest "res 4,(hl)",2,2
res 4,(hl)
rtest "res 4,a",2,2
res 4,a

rtest "res 5,b",2,2
res 5,b
rtest "res 5,c",2,2
res 5,c
rtest "res 5,d",2,2
res 5,d
rtest "res 5,e",2,2
res 5,e
rtest "res 5,h",2,2
res 5,h
rtest "res 5,l",2,2
res 5,l
rtest "res 5,(hl)",2,2
res 5,(hl)
rtest "res 5,a",2,2
res 5,a


rtest "res 6,b",2,2
res 6,b
rtest "res 6,c",2,2
res 6,c
rtest "res 6,d",2,2
res 6,d
rtest "res 6,e",2,2
res 6,e
rtest "res 6,h",2,2
res 6,h
rtest "res 6,l",2,2
res 6,l
rtest "res 6,(hl)",2,2
res 6,(hl)
rtest "res 6,a",2,2
res 6,a

rtest "res 7,b",2,2
res 7,b
rtest "res 7,c",2,2
res 7,c
rtest "res 7,d",2,2
res 7,d
rtest "res 7,e",2,2
res 7,e
rtest "res 7,h",2,2
res 7,h
rtest "res 7,l",2,2
res 7,l
rtest "res 7,(hl)",2,2
res 7,(hl)
rtest "res 7,a",2,2
res 7,a


rtest "set 0,b",2,2
set 0,b
rtest "set 0,c",2,2
set 0,c
rtest "set 0,d",2,2
set 0,d
rtest "set 0,e",2,2
set 0,e
rtest "set 0,h",2,2
set 0,h
rtest "set 0,l",2,2
set 0,l
rtest "set 0,(hl)",2,2
set 0,(hl)
rtest "set 0,a",2,2
set 0,a


rtest "set 1,b",2,2
set 1,b
rtest "set 1,c",2,2
set 1,c
rtest "set 1,d",2,2
set 1,d
rtest "set 1,e",2,2
set 1,e
rtest "set 1,h",2,2
set 1,h
rtest "set 1,l",2,2
set 1,l
rtest "set 1,(hl)",2,2
set 1,(hl)
rtest "set 1,a",2,2
set 1,a

rtest "set 2,b",2,2
set 2,b
rtest "set 2,c",2,2
set 2,c
rtest "set 2,d",2,2
set 2,d
rtest "set 2,e",2,2
set 2,e
rtest "set 2,h",2,2
set 2,h
rtest "set 2,l",2,2
set 2,l
rtest "set 2,(hl)",2,2
set 2,(hl)
rtest "set 2,a",2,2
set 2,a

rtest "set 3,b",2,2
set 3,b
rtest "set 3,c",2,2
set 3,c
rtest "set 3,d",2,2
set 3,d
rtest "set 3,e",2,2
set 3,e
rtest "set 3,h",2,2
set 3,h
rtest "set 3,l",2,2
set 3,l
rtest "set 3,(hl)",2,2
set 3,(hl)
rtest "set 3,a",2,2
set 3,a

rtest "set 4,b",2,2
set 4,b
rtest "set 4,c",2,2
set 4,c
rtest "set 4,d",2,2
set 4,d
rtest "set 4,e",2,2
set 4,e
rtest "set 4,h",2,2
set 4,h
rtest "set 4,l",2,2
set 4,l
rtest "set 4,(hl)",2,2
set 4,(hl)
rtest "set 4,a",2,2
set 4,a

rtest "set 5,b",2,2
set 5,b
rtest "set 5,c",2,2
set 5,c
rtest "set 5,d",2,2
set 5,d
rtest "set 5,e",2,2
set 5,e
rtest "set 5,h",2,2
set 5,h
rtest "set 5,l",2,2
set 5,l
rtest "set 5,(hl)",2,2
set 5,(hl)
rtest "set 5,a",2,2
set 5,a


rtest "set 6,b",2,2
set 6,b
rtest "set 6,c",2,2
set 6,c
rtest "set 6,d",2,2
set 6,d
rtest "set 6,e",2,2
set 6,e
rtest "set 6,h",2,2
set 6,h
rtest "set 6,l",2,2
set 6,l
rtest "set 6,(hl)",2,2
set 6,(hl)
rtest "set 6,a",2,2
set 6,a

rtest "set 7,b",2,2
set 7,b
rtest "set 7,c",2,2
set 7,c
rtest "set 7,d",2,2
set 7,d
rtest "set 7,e",2,2
set 7,e
rtest "set 7,h",2,2
set 7,h
rtest "set 7,l",2,2
set 7,l
rtest "set 7,(hl)",2,2
set 7,(hl)
rtest "set 7,a",2,2
set 7,a


rtest "adc a,n",2,1
adc a,&1

rtest "pop de",1,1
pop de

rtest "out (n),a",4,2
ld a,&7f
out (&4b),a


rtest "push de",1,1
push de

rtest "sub a,n",2,1
sub &1

rtest "exx",2,2
exx
exx

rtest "in a,(n)",2,1
in a,(&00)

rtest "sbc a,n",2,1
sbc a,&1

rtest "pop hl",1,1
pop hl

rtest "ex (sp),hl",1,1
ex (sp),hl

rtest "push hl",1,1
push hl

rtest "and n",2,1
and &1

rtest "ex de,hl",1,1
ex de,hl

rtest "xor n",2,1
xor &1

rtest "pop af",1,1
pop af

rtest "di",1,1
di

rtest "push af",1,1
push af

rtest "or n",2,1
or &1

rtest "ld sp,hl",1,1
ld sp,hl

rtest "ei",2,2
ei
di

rtest "cp n",2,1
cp &1




rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&40
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&41
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&42
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&43
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&44
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&45
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&46
rtest "bit 0,(ix+0)",4,2
defb &dd,&cb,&00,&47

rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&48
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&49
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&4a
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&4b
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&4c
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&4d
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&4e
rtest "bit 1,(ix+0)",4,2
defb &dd,&cb,&00,&4f


rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&50
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&51
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&52
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&53
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&54
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&55
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&56
rtest "bit 2,(ix+0)",4,2
defb &dd,&cb,&00,&57

rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&58
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&59
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&5a
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&5b
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&5c
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&5d
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&5e
rtest "bit 3,(ix+0)",4,2
defb &dd,&cb,&00,&5f

rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&60
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&61
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&62
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&63
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&64
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&65
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&66
rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&67

rtest "bit 4,(ix+0)",4,2
defb &dd,&cb,&00,&68
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&69
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&6a
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&6b
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&6c
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&6d
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&6e
rtest "bit 5,(ix+0)",4,2
defb &dd,&cb,&00,&6f

rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&70
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&71
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&72
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&73
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&74
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&75
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&76
rtest "bit 6,(ix+0)",4,2
defb &dd,&cb,&00,&77

rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&78
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&79
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&7a
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&7b
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&7c
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&7d
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&7e
rtest "bit 7,(ix+0)",4,2
defb &dd,&cb,&00,&7f


rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&80
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&81
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&82
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&83
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&84
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&85
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&86
rtest "res 0,(ix+0)",4,2
defb &dd,&cb,&00,&87

rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&88
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&89
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&8a
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&8b
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&8c
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&8d
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&8e
rtest "res 1,(ix+0)",4,2
defb &dd,&cb,&00,&8f


rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&90
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&91
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&92
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&93
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&94
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&95
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&96
rtest "res 2,(ix+0)",4,2
defb &dd,&cb,&00,&97

rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&98
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&99
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&9a
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&9b
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&9c
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&9d
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&9e
rtest "res 3,(ix+0)",4,2
defb &dd,&cb,&00,&9f

rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a0
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a1
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a2
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a3
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a4
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a5
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a6
rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a7

rtest "res 4,(ix+0)",4,2
defb &dd,&cb,&00,&a8
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&a9
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&aa
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&ab
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&ac
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&ad
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&ae
rtest "res 5,(ix+0)",4,2
defb &dd,&cb,&00,&af

rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b0
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b1
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b2
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b3
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b4
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b5
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b6
rtest "res 6,(ix+0)",4,2
defb &dd,&cb,&00,&b7

rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&b8
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&b9
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&ba
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&bb
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&bc
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&bd
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&be
rtest "res 7,(ix+0)",4,2
defb &dd,&cb,&00,&bf


rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c0
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c1
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c2
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c3
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c4
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c5
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c6
rtest "set 0,(ix+0)",4,2
defb &dd,&cb,&00,&c7

rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&c8
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&c9
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&ca
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&cb
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&cc
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&cd
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&ce
rtest "set 1,(ix+0)",4,2
defb &dd,&cb,&00,&cf


rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d0
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d1
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d2
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d3
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d4
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d5
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d6
rtest "set 2,(ix+0)",4,2
defb &dd,&cb,&00,&d7

rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&d8
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&d9
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&da
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&db
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&dc
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&dd
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&de
rtest "set 3,(ix+0)",4,2
defb &dd,&cb,&00,&df

rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e0
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e1
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e2
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e3
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e4
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e5
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e6
rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e7

rtest "set 4,(ix+0)",4,2
defb &dd,&cb,&00,&e8
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&e9
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&ea
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&eb
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&ec
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&ed
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&ee
rtest "set 5,(ix+0)",4,2
defb &dd,&cb,&00,&ef

rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f0
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f1
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f2
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f3
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f4
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f5
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f6
rtest "set 6,(ix+0)",4,2
defb &dd,&cb,&00,&f7

rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&f8
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&f9
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&fa
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&fb
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&fc
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&fd
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&fe
rtest "set 7,(ix+0)",4,2
defb &dd,&cb,&00,&ff

rtest "ed,00",2,2
defb &ED,&00
rtest "ed,01",2,2
defb &ED,&01
rtest "ed,02",2,2
defb &ED,&02
rtest "ed,03",2,2
defb &ED,&03
rtest "ed,04",2,2
defb &ED,&04
rtest "ed,05",2,2
defb &ED,&05
rtest "ed,06",2,2
defb &ED,&06
rtest "ed,07",2,2
defb &ED,&07
rtest "ed,08",2,2
defb &ED,&08
rtest "ed,09",2,2
defb &ED,&09
rtest "ed,0a",2,2
defb &ED,&0A
rtest "ed,0b",2,2
defb &ED,&0B
rtest "ed,0c",2,2
defb &ED,&0C
rtest "ed,0d",2,2
defb &ED,&0D
rtest "ed,0e",2,2
defb &ED,&0E
rtest "ed,0f",2,2
defb &ED,&0F
rtest "ed,10",2,2
defb &ED,&10
rtest "ed,11",2,2
defb &ED,&11
rtest "ed,12",2,2
defb &ED,&12
rtest "ed,13",2,2
defb &ED,&13
rtest "ed,14",2,2
defb &ED,&14
rtest "ed,15",2,2
defb &ED,&15
rtest "ed,16",2,2
defb &ED,&16
rtest "ed,17",2,2
defb &ED,&17
rtest "ed,18",2,2
defb &ED,&18
rtest "ed,19",2,2
defb &ED,&19
rtest "ed,1a",2,2
defb &ED,&1A
rtest "ed,1b",2,2
defb &ED,&1B
rtest "ed,1c",2,2
defb &ED,&1C
rtest "ed,1d",2,2
defb &ED,&1D
rtest "ed,1e",2,2
defb &ED,&1E
rtest "ed,1f",2,2
defb &ED,&1F
rtest "ed,20",2,2
defb &ED,&20
rtest "ed,21",2,2
defb &ED,&21
rtest "ed,22",2,2
defb &ED,&22
rtest "ed,23",2,2
defb &ED,&23
rtest "ed,24",2,2
defb &ED,&24
rtest "ed,25",2,2
defb &ED,&25
rtest "ed,26",2,2
defb &ED,&26
rtest "ed,27",2,2
defb &ED,&27
rtest "ed,28",2,2
defb &ED,&28
rtest "ed,29",2,2
defb &ED,&29
rtest "ed,2a",2,2
defb &ED,&2A
rtest "ed,2b",2,2
defb &ED,&2B
rtest "ed,2c",2,2
defb &ED,&2C
rtest "ed,2d",2,2
defb &ED,&2D
rtest "ed,2e",2,2
defb &ED,&2E
rtest "ed,2f",2,2
defb &ED,&2F
rtest "ed,30",2,2
defb &ED,&30
rtest "ed,31",2,2
defb &ED,&31
rtest "ed,32",2,2
defb &ED,&32
rtest "ed,33",2,2
defb &ED,&33
rtest "ed,34",2,2
defb &ED,&34
rtest "ed,35",2,2
defb &ED,&35
rtest "ed,36",2,2
defb &ED,&36
rtest "ed,37",2,2
defb &ED,&37
rtest "ed,38",2,2
defb &ED,&38
rtest "ed,39",2,2
defb &ED,&39
rtest "ed,3a",2,2
defb &ED,&3A
rtest "ed,3b",2,2
defb &ED,&3B
rtest "ed,3c",2,2
defb &ED,&3C
rtest "ed,3d",2,2
defb &ED,&3D
rtest "ed,3e",2,2
defb &ED,&3E
rtest "ed,3f",2,2
defb &ED,&3F

rtest "ed,7f",2,2
defb &ED,&7f

rtest "ed,80",2,2
defb &ED,&80
rtest "ed,81",2,2
defb &ED,&81
rtest "ed,82",2,2
defb &ED,&82
rtest "ed,83",2,2
defb &ED,&83
rtest "ed,84",2,2
defb &ED,&84
rtest "ed,85",2,2
defb &ED,&85
rtest "ed,86",2,2
defb &ED,&86
rtest "ed,87",2,2
defb &ED,&87
rtest "ed,88",2,2
defb &ED,&88
rtest "ed,89",2,2
defb &ED,&89
rtest "ed,8a",2,2
defb &ED,&8A
rtest "ed,8b",2,2
defb &ED,&8B
rtest "ed,8c",2,2
defb &ED,&8C
rtest "ed,8d",2,2
defb &ED,&8D
rtest "ed,8e",2,2
defb &ED,&8E
rtest "ed,8f",2,2
defb &ED,&8F
rtest "ed,90",2,2
defb &ED,&90
rtest "ed,91",2,2
defb &ED,&91
rtest "ed,92",2,2
defb &ED,&92
rtest "ed,93",2,2
defb &ED,&93
rtest "ed,94",2,2
defb &ED,&94
rtest "ed,95",2,2
defb &ED,&95
rtest "ed,96",2,2
defb &ED,&96
rtest "ed,97",2,2
defb &ED,&97
rtest "ed,98",2,2
defb &ED,&98
rtest "ed,99",2,2
defb &ED,&99
rtest "ed,9a",2,2
defb &ED,&9A
rtest "ed,9b",2,2
defb &ED,&9b
rtest "ed,9c",2,2
defb &ED,&9C
rtest "ed,9d",2,2
defb &ED,&9D
rtest "ed,9e",2,2
defb &ED,&9E
rtest "ed,9f",2,2
defb &ED,&9F
rtest "ed,a4",2,2
defb &ED,&a4
rtest "ed,ac",2,2
defb &ED,&ac
rtest "ed,ad",2,2
defb &ED,&ad
rtest "ed,ae",2,2
defb &ED,&ae
rtest "ed,af",2,2
defb &ED,&af
rtest "ed,b4",2,2
defb &ED,&b4
rtest "ed,bc",2,2
defb &ED,&bc
rtest "ed,bd",2,2
defb &ED,&bd
rtest "ed,be",2,2
defb &ED,&be
rtest "ed,bf",2,2
defb &ED,&bf


rtest "ed,c0",2,2
defb &ED,&c0
rtest "ed,c1",2,2
defb &ED,&c1
rtest "ed,c2",2,2
defb &ED,&c2
rtest "ed,c3",2,2
defb &ED,&c3
rtest "ed,c4",2,2
defb &ED,&c4
rtest "ed,c5",2,2
defb &ED,&c5
rtest "ed,c6",2,2
defb &ED,&c6
rtest "ed,c7",2,2
defb &ED,&c7
rtest "ed,c8",2,2
defb &ED,&c8
rtest "ed,c9",2,2
defb &ED,&c9
rtest "ed,ca",2,2
defb &ED,&ca
rtest "ed,cb",2,2
defb &ED,&cB
rtest "ed,cc",2,2
defb &ED,&cC
rtest "ed,cd",2,2
defb &ED,&cD
rtest "ed,ce",2,2
defb &ED,&cE
rtest "ed,cf",2,2
defb &ED,&cF
rtest "ed,d0",2,2
defb &ED,&d0
rtest "ed,d1",2,2
defb &ED,&d1
rtest "ed,d2",2,2
defb &ED,&d2
rtest "ed,d3",2,2
defb &ED,&d3
rtest "ed,d4",2,2
defb &ED,&d4
rtest "ed,d5",2,2
defb &ED,&d5
rtest "ed,d6",2,2
defb &ED,&d6
rtest "ed,d7",2,2
defb &ED,&d7
rtest "ed,d8",2,2
defb &ED,&d8
rtest "ed,d9",2,2
defb &ED,&d9
rtest "ed,da",2,2
defb &ED,&dA
rtest "ed,db",2,2
defb &ED,&db
rtest "ed,dc",2,2
defb &ED,&dC
rtest "ed,dd",2,2
defb &ED,&dD
rtest "ed,de",2,2
defb &ED,&dE
rtest "ed,df",2,2
defb &ED,&dF

rtest "ed,e0",2,2
defb &ED,&e0
rtest "ed,e1",2,2
defb &ED,&e1
rtest "ed,e2",2,2
defb &ED,&e2
rtest "ed,e3",2,2
defb &ED,&e3
rtest "ed,e4",2,2
defb &ED,&e4
rtest "ed,e5",2,2
defb &ED,&e5
rtest "ed,e6",2,2
defb &ED,&e6
rtest "ed,e7",2,2
defb &ED,&e7
rtest "ed,e8",2,2
defb &ED,&e8
rtest "ed,e9",2,2
defb &ED,&e9
rtest "ed,ea",2,2
defb &ED,&ea
rtest "ed,eb",2,2
defb &ED,&eB
rtest "ed,ec",2,2
defb &ED,&eC
rtest "ed,ed",2,2
defb &ED,&eD
rtest "ed,ee",2,2
defb &ED,&eE
rtest "ed,ef",2,2
defb &ED,&eF
rtest "ed,f0",2,2
defb &ED,&f0
rtest "ed,f1",2,2
defb &ED,&f1
rtest "ed,f2",2,2
defb &ED,&f2
rtest "ed,f3",2,2
defb &ED,&f3
rtest "ed,f4",2,2
defb &ED,&f4
rtest "ed,f5",2,2
defb &ED,&f5
rtest "ed,f6",2,2
defb &ED,&f6
rtest "ed,f7",2,2
defb &ED,&f7
rtest "ed,f8",2,2
defb &ED,&f8
rtest "ed,f9",2,2
defb &ED,&f9
rtest "ed,fa",2,2
defb &ED,&fA
rtest "ed,fb",2,2
defb &ED,&fb
rtest "ed,fc",2,2
defb &ED,&fc
rtest "ed,fd",2,2
defb &ED,&fD
rtest "ed,fe",2,2
defb &ED,&fE
rtest "ed,ff",2,2
defb &ED,&fF


rtest "in b,(c)",2,2
in b,(c)
;;rtest "out (c),b",2,2
;;out (c),b
rtest "sbc hl,bc",2,2
sbc hl,bc
rtest "ld (nnnn),bc",4,2
ld (buffer),bc
rtest "neg",2,2
neg
;;rtest "retn",2,2
;; retn
rtest "im 0",2,2
im 0
rtest "ld i,a",2,2
ld i,a
rtest "in c,(c)",2,2
in c,(c)
rtest "out (c),c",2,2
out (c),c
rtest "adc hl,bc",2,2
adc hl,bc
rtest "ld bc,(nnnn)",4,2
ld bc,(buffer)
rtest "neg",2,2
defb &ed,&4c
;;rtest "reti",2,2
;; reti
rtest "im 0",2,2
defb &ed,&4e
rtest "ld r,a",2,2
ld r,a
rtest "in d,(c)",2,2
in d,(c)
rtest "out (c),d",2,2
out (c),d
rtest "sbc hl,de",2,2
sbc hl,de
rtest "ld (nnnn),de",4,2
ld (buffer),de
rtest "neg",2,2
defb &ed,&54
;;rtest "retn",2,2
;; defb &ed,&55
defb "im 1",2,2
im 1
defb "ld i,a",2,2
ld i,a
rtest "in e,(c)",2,2
in e,(c)
rtest "out (c),e",2,2
out (c),e
rtest "adc hl,de",2,2
adc hl,de
rtest "ld de,(nnnn)",4,2
ld de,(buffer)
rtest "neg",2,2
defb &ed,&5c
;;rtest "retn",2,2
;; defb &ed,&55
defb "im 2",2,2
im 2
defb "ld a,r",2,2
ld a,r
rtest "in h,(c)",2,2
in h,(c)
rtest "out (c),h",2,2
out (c),h
rtest "sbc hl,hl",2,2
sbc hl,hl
rtest "ld (nnnn),hl",4,2
defb &ed,&63
defw buffer
rtest "neg",2,2
defb &ed,&64
;;rtest "retn",2,2
;; defb &ed,&6d
defb "im 0",2,2
defb &ed,&66
defb "rrd",2,2
rrd
rtest "in l,(c)",2,2
in l,(c)
rtest "out (c),l",2,2
out (c),l
rtest "adc hl,hl",2,2
adc hl,hl
rtest "ld hl,(nnnn)",4,2
defb &ed,&6b
defw buffer
rtest "neg",2,2
defb &ed,&6c
;;rtest "retn",2,2
;; defb &ed,&6d
defb "im 0",2,2
defb &ed,&6e
defb "rld",2,2
rld
rtest "in f,(c)",2,2
defb &ed,&70
rtest "out (c),0",2,2
defb &ed,&71
rtest "sbc hl,sp",2,2
sbc hl,sp
rtest "ld (nnnn),sp",4,2
ld (buffer),sp
rtest "neg",2,2
defb &ed,&74
;;rtest "retn",2,2
;; defb &ed,&6d
defb "im 1",2,2
defb &ed,&76
defb "ed,77",2,2
defb &ed,&77
rtest "in a,(c)",2,2
in a,(c)
rtest "out (c),a",2,2
out (c),a
rtest "adc hl,sp",2,2
adc hl,sp
rtest "ld sp,(nnnn)",4,2
ld sp,(buffer)
rtest "neg",2,2
defb &ed,&7c
;;rtest "retn",2,2
;; defb &ed,&6d
defb "im 2",2,2
defb &ed,&7e




rtest "dd.dd.nop", 3,3
defb &dd
defb &dd
nop

rtest "fd.fd.nop", 3,3
defb &fd
defb &fd
nop

rtest "dd.fd.nop", 3,3
defb &dd
defb &fd
nop

rtest "fd.dd.nop", 3,3
defb &fd
defb &dd
nop

rtest "dd,dd,dd,dd,nop", 5,5
defb &dd
defb &dd
defb &dd
defb &dd
nop


rtest "ld a,(ix+0)", 3, 2
ld a,(ix+0)

rtest "ld a,ixh", 2, 2
defb &dd, &7c

defb 0

;;-------------------------------------------------

if 0
rtestbegin
defb &7
rtestend 1
defb &8
rtestend 1
defb &9
rtestend 1
defb &0A
rtestend 1
defb &0B
rtestend 1
defb &0C
rtestend 1
defb &0D
rtestend 1
defb &0E,&01
rtestend 1
defb &0F
rtestend 1
defb &10,&01
rtestend 1
defb &11,&01,&01
rtestend 1
defb &12
rtestend 1
defb &13
rtestend 1
defb &14
rtestend 1
defb &15
rtestend 1
defb &16,&01
rtestend 1
defb &17
rtestend 1
defb &18,&01
rtestend 1
defb &19
rtestend 1
defb &1A
rtestend 1
defb &1B
rtestend 1
defb &1C
rtestend 1
defb &1D
rtestend 1
defb &1E,&01
rtestend 1
defb &1F
rtestend 1
defb &20,&01
rtestend 1
defb &21,&01,&01
rtestend 1
defb &22,&01,&01
rtestend 1
defb &23
rtestend 1
defb &24
rtestend 1
defb &25
rtestend 1
defb &26,&01
rtestend 1
defb &27
rtestend 1
defb &28,&01
rtestend 1
defb &29
rtestend 1
defb &2A,&01,&01
defb &2B
defb &2C
defb &2D
defb &2E,&01
defb &2F
defb &30,&01
defb &31,&01,&01
defb &32,&01,&01
defb &33
defb &34
defb &35
defb &36,&01
defb &37
defb &38,&01
defb &39
defb &3A,&01,&01
defb &3B
defb &3C
defb &3D
defb &3E,&01
defb &3F
defb &40
defb &41
defb &42
defb &43
defb &44
defb &45
defb &46
defb &47
defb &48
defb &49
defb &4A
defb &4B
defb &4C
defb &4D
defb &4E
defb &4F
defb &50
defb &51
defb &52
defb &53
defb &54
defb &55
defb &56
defb &57
defb &58
defb &59
defb &5A
defb &5B
defb &5C
defb &5D
defb &5E
defb &5F
defb &60
defb &61
defb &62
defb &63
defb &64
defb &65
defb &66
defb &67
defb &68
defb &69
defb &6A
defb &6B
defb &6C
defb &6D
defb &6E
defb &6F
defb &70
defb &71
defb &72
defb &73
defb &74
defb &75
defb &76
defb &77
defb &78
defb &79
defb &7A
defb &7B
defb &7C
defb &7D
defb &7E
defb &7F
defb &80
defb &81
defb &82
defb &83
defb &84
defb &85
defb &86
defb &87
defb &88
defb &89
defb &8A
defb &8B
defb &8C
defb &8D
defb &8E
defb &8F
defb &90
defb &91
defb &92
defb &93
defb &94
defb &95
defb &96
defb &97
defb &98
defb &99
defb &9A
defb &9B
defb &9C
defb &9D
defb &9E
defb &9F
defb &A0
defb &A1
defb &A2
defb &A3
defb &A4
defb &A5
defb &A6
defb &A7
defb &A8
defb &A9
defb &AA
defb &AB
defb &AC
defb &AD
defb &AE
defb &AF
defb &B0
defb &B1
defb &B2
defb &B3
defb &B4
defb &B5
defb &B6
defb &B7
defb &B8
defb &B9
defb &BA
defb &BB
defb &BC
defb &BD
defb &BE
defb &BF
defb &C0
defb &C1
defb &C2,&01,&01
defb &C3,&01,&01
defb &C4,&01,&01
defb &C5
defb &C6,&01
defb &C7
defb &C8
defb &C9
defb &CA,&01,&01
defb &CC,&01,&01
defb &CD,&01,&01
defb &CE,&01
defb &CF
defb &D0
defb &D1
defb &D2,&01,&01
defb &D3,&01
defb &D4,&01,&01
defb &D5
defb &D6,&01
defb &D7
defb &D8
defb &D9
defb &DA,&01,&01
defb &DB,&01
defb &DC,&01,&01
defb &DD,&09
defb &DD,&19
defb &DD,&21,&01,&01
defb &DD,&22,&01,&01
defb &DD,&23
defb &DD,&24
defb &DD,&25
defb &DD,&26,&01
defb &DD,&29
defb &DD,&2A,&01,&01
defb &DD,&2B
defb &DD,&2C
defb &DD,&2D
defb &DD,&2E,&01
defb &DD,&34,&01
defb &DD,&35,&01
defb &DD,&36,&01,&01
defb &DD,&39
defb &DD,&44
defb &DD,&45
defb &DD,&46,&01
defb &DD,&4C
defb &DD,&4D
defb &DD,&4E,&01
defb &DD,&54
defb &DD,&55
defb &DD,&56,&01
defb &DD,&5C
defb &DD,&5D
defb &DD,&5E,&01
defb &DD,&60
defb &DD,&61
defb &DD,&62
defb &DD,&63
defb &DD,&64
defb &DD,&65
defb &DD,&66,&01
defb &DD,&67
defb &DD,&68
defb &DD,&69
defb &DD,&6A
defb &DD,&6B
defb &DD,&6C
defb &DD,&6D
defb &DD,&6E,&01
defb &DD,&6F
defb &DD,&70,&01
defb &DD,&71,&01
defb &DD,&72,&01
defb &DD,&73,&01
defb &DD,&74,&01
defb &DD,&75,&01
defb &DD,&77,&01
defb &DD,&7C
defb &DD,&7D
defb &DD,&7E,&01
defb &DD,&84
defb &DD,&85
defb &DD,&86,&01
defb &DD,&8C
defb &DD,&8D
defb &DD,&8E,&01
defb &DD,&94
defb &DD,&95
defb &DD,&96,&01
defb &DD,&9C
defb &DD,&9D
defb &DD,&9E,&01
defb &DD,&A4
defb &DD,&A5
defb &DD,&A6,&01
defb &DD,&AC
defb &DD,&AD
defb &DD,&AE,&01
defb &DD,&B4
defb &DD,&B5
defb &DD,&B6,&01
defb &DD,&BC
defb &DD,&BD
defb &DD,&BE,&01
defb &DD,&E1
defb &DD,&E3
defb &DD,&E5
defb &DD,&E9
defb &DD,&F9
defb &DE,&01
defb &DF
defb &E0
defb &E1
defb &E2,&01,&01
defb &E3
defb &E4,&01,&01
defb &E5
defb &E6,&01
defb &E7
defb &E8
defb &E9
defb &EA,&01,&01
defb &EB
defb &EC,&01,&01
defb &ED,&00
defb &ED,&01
defb &ED,&02
defb &ED,&03
defb &ED,&04
defb &ED,&05
defb &ED,&06
defb &ED,&07
defb &ED,&08
defb &ED,&09
defb &ED,&0A
defb &ED,&0B
defb &ED,&0C
defb &ED,&0D
defb &ED,&0E
defb &ED,&0F
defb &ED,&10
defb &ED,&11
defb &ED,&12
defb &ED,&13
defb &ED,&14
defb &ED,&15
defb &ED,&16
defb &ED,&17
defb &ED,&18
defb &ED,&19
defb &ED,&1A
defb &ED,&1B
defb &ED,&1C
defb &ED,&1D
defb &ED,&1E
defb &ED,&1F
defb &ED,&20
defb &ED,&21
defb &ED,&22
defb &ED,&23
defb &ED,&24
defb &ED,&25
defb &ED,&26
defb &ED,&27
defb &ED,&28
defb &ED,&29
defb &ED,&2A
defb &ED,&2B
defb &ED,&2C
defb &ED,&2D
defb &ED,&2E
defb &ED,&2F
defb &ED,&30
defb &ED,&31
defb &ED,&32
defb &ED,&33
defb &ED,&34
defb &ED,&35
defb &ED,&36
defb &ED,&37
defb &ED,&38
defb &ED,&39
defb &ED,&3A
defb &ED,&3B
defb &ED,&3C
defb &ED,&3D
defb &ED,&3E
defb &ED,&3F
defb &ED,&40
defb &ED,&41
defb &ED,&42
defb &ED,&43,&01,&01
defb &ED,&44
defb &ED,&45
defb &ED,&46
defb &ED,&47
defb &ED,&48
defb &ED,&49
defb &ED,&4A
defb &ED,&4B,&01,&01
defb &ED,&4C
defb &ED,&4D
defb &ED,&4E
defb &ED,&4F
defb &ED,&50
defb &ED,&51
defb &ED,&52
defb &ED,&53,&01,&01
defb &ED,&54
defb &ED,&55
defb &ED,&56
defb &ED,&57
defb &ED,&58
defb &ED,&59
defb &ED,&5A
defb &ED,&5B,&01,&01
defb &ED,&5C
defb &ED,&5D
defb &ED,&5E
defb &ED,&5F
defb &ED,&60
defb &ED,&61
defb &ED,&62
defb &ED,&63,&01,&01
defb &ED,&64
defb &ED,&65
defb &ED,&66
defb &ED,&67
defb &ED,&68
defb &ED,&69
defb &ED,&6A
defb &ED,&6B,&01,&01
defb &ED,&6C
defb &ED,&6D
defb &ED,&6E
defb &ED,&6F
defb &ED,&70
defb &ED,&71
defb &ED,&72
defb &ED,&73,&01,&01
defb &ED,&74
defb &ED,&75
defb &ED,&76
defb &ED,&77
defb &ED,&78
defb &ED,&79
defb &ED,&7A
defb &ED,&7B,&01,&01
defb &ED,&7C
defb &ED,&7D
defb &ED,&7E
defb &ED,&7F
defb &ED,&80
defb &ED,&81
defb &ED,&82
defb &ED,&83
defb &ED,&84
defb &ED,&85
defb &ED,&86
defb &ED,&87
defb &ED,&88
defb &ED,&89
defb &ED,&8A
defb &ED,&8B
defb &ED,&8C
defb &ED,&8D
defb &ED,&8E
defb &ED,&8F
defb &ED,&90
defb &ED,&91
defb &ED,&92
defb &ED,&93
defb &ED,&94
defb &ED,&95
defb &ED,&96
defb &ED,&97
defb &ED,&98
defb &ED,&99
defb &ED,&9A
defb &ED,&9B
defb &ED,&9C
defb &ED,&9D
defb &ED,&9E
defb &ED,&9F
defb &ED,&A0
defb &ED,&A1
defb &ED,&A2
defb &ED,&A3
defb &ED,&A4
defb &ED,&A5
defb &ED,&A6
defb &ED,&A7
defb &ED,&A8
defb &ED,&A9
defb &ED,&AA
defb &ED,&AB
defb &ED,&AC
defb &ED,&AD
defb &ED,&AE
defb &ED,&AF
defb &ED,&B0
defb &ED,&B1
defb &ED,&B2
defb &ED,&B3
defb &ED,&B4
defb &ED,&B5
defb &ED,&B6
defb &ED,&B7
defb &ED,&B8
defb &ED,&B9
defb &ED,&BA
defb &ED,&BB
defb &ED,&BC
defb &ED,&BD
defb &ED,&BE
defb &ED,&BF
defb &ED,&C0
defb &ED,&C1
defb &ED,&C2
defb &ED,&C3
defb &ED,&C4
defb &ED,&C5
defb &ED,&C6
defb &ED,&C7
defb &ED,&C8
defb &ED,&C9
defb &ED,&CA
defb &ED,&CB
defb &ED,&CC
defb &ED,&CD
defb &ED,&CE
defb &ED,&CF
defb &ED,&D0
defb &ED,&D1
defb &ED,&D2
defb &ED,&D3
defb &ED,&D4
defb &ED,&D5
defb &ED,&D6
defb &ED,&D7
defb &ED,&D8
defb &ED,&D9
defb &ED,&DA
defb &ED,&DB
defb &ED,&DC
defb &ED,&DD
defb &ED,&DE
defb &ED,&DF
defb &ED,&E0
defb &ED,&E1
defb &ED,&E2
defb &ED,&E3
defb &ED,&E4
defb &ED,&E5
defb &ED,&E6
defb &ED,&E7
defb &ED,&E8
defb &ED,&E9
defb &ED,&EA
defb &ED,&EB
defb &ED,&EC
defb &ED,&ED
defb &ED,&EE
defb &ED,&EF
defb &ED,&F0
defb &ED,&F1
defb &ED,&F2
defb &ED,&F3
defb &ED,&F4
defb &ED,&F5
defb &ED,&F6
defb &ED,&F7
defb &ED,&F8
defb &ED,&F9
defb &ED,&FA
defb &ED,&FB
defb &ED,&FC
defb &ED,&FD
defb &ED,&FE
defb &ED,&FF
defb &EE,&01
defb &EF
defb &F0
defb &F1
defb &F2,&01,&01
defb &F3
defb &F4,&01,&01
defb &F5
defb &F6,&01
defb &F7
defb &F8
defb &F9
defb &FA,&01,&01
defb &FB
defb &FC,&01,&01
defb &FD,&09
defb &FD,&19
defb &FD,&21,&01,&01
defb &FD,&22,&01,&01
defb &FD,&23
defb &FD,&24
defb &FD,&25
defb &FD,&26,&01
defb &FD,&29
defb &FD,&2A,&01,&01
defb &FD,&2B
defb &FD,&2C
defb &FD,&2D
defb &FD,&2E,&01
defb &FD,&34,&01
defb &FD,&35,&01
defb &FD,&36,&01,&01
defb &FD,&39
defb &FD,&44
defb &FD,&45
defb &FD,&46,&01
defb &FD,&4C
defb &FD,&4D
defb &FD,&4E,&01
defb &FD,&54
defb &FD,&55
defb &FD,&56,&01
defb &FD,&5C
defb &FD,&5D
defb &FD,&5E,&01
defb &FD,&60
defb &FD,&61
defb &FD,&62
defb &FD,&63
defb &FD,&64
defb &FD,&65
defb &FD,&66,&01
defb &FD,&67
defb &FD,&68
defb &FD,&69
defb &FD,&6A
defb &FD,&6B
defb &FD,&6C
defb &FD,&6D
defb &FD,&6E,&01
defb &FD,&6F
defb &FD,&70,&01
defb &FD,&71,&01
defb &FD,&72,&01
defb &FD,&73,&01
defb &FD,&74,&01
defb &FD,&75,&01
defb &FD,&77,&01
defb &FD,&7C
defb &FD,&7D
defb &FD,&7E,&01
defb &FD,&84
defb &FD,&85
defb &FD,&86,&01
defb &FD,&8C
defb &FD,&8D
defb &FD,&8E,&01
defb &FD,&94
defb &FD,&95
defb &FD,&96,&01
defb &FD,&9C
defb &FD,&9D
defb &FD,&9E,&01
defb &FD,&A4
defb &FD,&A5
defb &FD,&A6,&01
defb &FD,&AC
defb &FD,&AD
defb &FD,&AE,&01
defb &FD,&B4
defb &FD,&B5
defb &FD,&B6,&01
defb &FD,&BC
defb &FD,&BD
defb &FD,&BE,&01
defb &FD,&CB,&01,&00
defb &FD,&CB,&01,&01
defb &FD,&CB,&01,&02
defb &FD,&CB,&01,&03
defb &FD,&CB,&01,&04
defb &FD,&CB,&01,&05
defb &FD,&CB,&01,&06
defb &FD,&CB,&01,&07
defb &FD,&CB,&01,&08
defb &FD,&CB,&01,&09
defb &FD,&CB,&01,&0A
defb &FD,&CB,&01,&0B
defb &FD,&CB,&01,&0C
defb &FD,&CB,&01,&0D
defb &FD,&CB,&01,&0E
defb &FD,&CB,&01,&0F
defb &FD,&CB,&01,&10
defb &FD,&CB,&01,&11
defb &FD,&CB,&01,&12
defb &FD,&CB,&01,&13
defb &FD,&CB,&01,&14
defb &FD,&CB,&01,&15
defb &FD,&CB,&01,&16
defb &FD,&CB,&01,&17
defb &FD,&CB,&01,&18
defb &FD,&CB,&01,&19
defb &FD,&CB,&01,&1A
defb &FD,&CB,&01,&1B
defb &FD,&CB,&01,&1C
defb &FD,&CB,&01,&1D
defb &FD,&CB,&01,&1E
defb &FD,&CB,&01,&1F
defb &FD,&CB,&01,&20
defb &FD,&CB,&01,&21
defb &FD,&CB,&01,&22
defb &FD,&CB,&01,&23
defb &FD,&CB,&01,&24
defb &FD,&CB,&01,&25
defb &FD,&CB,&01,&26
defb &FD,&CB,&01,&27
defb &FD,&CB,&01,&28
defb &FD,&CB,&01,&29
defb &FD,&CB,&01,&2A
defb &FD,&CB,&01,&2B
defb &FD,&CB,&01,&2C
defb &FD,&CB,&01,&2D
defb &FD,&CB,&01,&2E
defb &FD,&CB,&01,&2F
defb &FD,&CB,&01,&30
defb &FD,&CB,&01,&31
defb &FD,&CB,&01,&32
defb &FD,&CB,&01,&33
defb &FD,&CB,&01,&34
defb &FD,&CB,&01,&35
defb &FD,&CB,&01,&36
defb &FD,&CB,&01,&37
defb &FD,&CB,&01,&38
defb &FD,&CB,&01,&39
defb &FD,&CB,&01,&3A
defb &FD,&CB,&01,&3B
defb &FD,&CB,&01,&3C
defb &FD,&CB,&01,&3D
defb &FD,&CB,&01,&3E
defb &FD,&CB,&01,&3F
defb &FD,&CB,&01,&40
defb &FD,&CB,&01,&41
defb &FD,&CB,&01,&42
defb &FD,&CB,&01,&43
defb &FD,&CB,&01,&44
defb &FD,&CB,&01,&45
defb &FD,&CB,&01,&46
defb &FD,&CB,&01,&47
defb &FD,&CB,&01,&48
defb &FD,&CB,&01,&49
defb &FD,&CB,&01,&4A
defb &FD,&CB,&01,&4B
defb &FD,&CB,&01,&4C
defb &FD,&CB,&01,&4D
defb &FD,&CB,&01,&4E
defb &FD,&CB,&01,&4F
defb &FD,&CB,&01,&50
defb &FD,&CB,&01,&51
defb &FD,&CB,&01,&52
defb &FD,&CB,&01,&53
defb &FD,&CB,&01,&54
defb &FD,&CB,&01,&55
defb &FD,&CB,&01,&56
defb &FD,&CB,&01,&57
defb &FD,&CB,&01,&58
defb &FD,&CB,&01,&59
defb &FD,&CB,&01,&5A
defb &FD,&CB,&01,&5B
defb &FD,&CB,&01,&5C
defb &FD,&CB,&01,&5D
defb &FD,&CB,&01,&5E
defb &FD,&CB,&01,&5F
defb &FD,&CB,&01,&60
defb &FD,&CB,&01,&61
defb &FD,&CB,&01,&62
defb &FD,&CB,&01,&63
defb &FD,&CB,&01,&64
defb &FD,&CB,&01,&65
defb &FD,&CB,&01,&66
defb &FD,&CB,&01,&67
defb &FD,&CB,&01,&68
defb &FD,&CB,&01,&69
defb &FD,&CB,&01,&6A
defb &FD,&CB,&01,&6B
defb &FD,&CB,&01,&6C
defb &FD,&CB,&01,&6D
defb &FD,&CB,&01,&6E
defb &FD,&CB,&01,&6F
defb &FD,&CB,&01,&70
defb &FD,&CB,&01,&71
defb &FD,&CB,&01,&72
defb &FD,&CB,&01,&73
defb &FD,&CB,&01,&74
defb &FD,&CB,&01,&75
defb &FD,&CB,&01,&76
defb &FD,&CB,&01,&77
defb &FD,&CB,&01,&78
defb &FD,&CB,&01,&79
defb &FD,&CB,&01,&7A
defb &FD,&CB,&01,&7B
defb &FD,&CB,&01,&7C
defb &FD,&CB,&01,&7D
defb &FD,&CB,&01,&7E
defb &FD,&CB,&01,&7F
defb &FD,&CB,&01,&80
defb &FD,&CB,&01,&81
defb &FD,&CB,&01,&82
defb &FD,&CB,&01,&83
defb &FD,&CB,&01,&84
defb &FD,&CB,&01,&85
defb &FD,&CB,&01,&86
defb &FD,&CB,&01,&87
defb &FD,&CB,&01,&88
defb &FD,&CB,&01,&89
defb &FD,&CB,&01,&8A
defb &FD,&CB,&01,&8B
defb &FD,&CB,&01,&8C
defb &FD,&CB,&01,&8D
defb &FD,&CB,&01,&8E
defb &FD,&CB,&01,&8F
defb &FD,&CB,&01,&90
defb &FD,&CB,&01,&91
defb &FD,&CB,&01,&92
defb &FD,&CB,&01,&93
defb &FD,&CB,&01,&94
defb &FD,&CB,&01,&95
defb &FD,&CB,&01,&96
defb &FD,&CB,&01,&97
defb &FD,&CB,&01,&98
defb &FD,&CB,&01,&99
defb &FD,&CB,&01,&9A
defb &FD,&CB,&01,&9B
defb &FD,&CB,&01,&9C
defb &FD,&CB,&01,&9D
defb &FD,&CB,&01,&9E
defb &FD,&CB,&01,&9F
defb &FD,&CB,&01,&A0
defb &FD,&CB,&01,&A1
defb &FD,&CB,&01,&A2
defb &FD,&CB,&01,&A3
defb &FD,&CB,&01,&A4
defb &FD,&CB,&01,&A5
defb &FD,&CB,&01,&A6
defb &FD,&CB,&01,&A7
defb &FD,&CB,&01,&A8
defb &FD,&CB,&01,&A9
defb &FD,&CB,&01,&AA
defb &FD,&CB,&01,&AB
defb &FD,&CB,&01,&AC
defb &FD,&CB,&01,&AD
defb &FD,&CB,&01,&AE
defb &FD,&CB,&01,&AF
defb &FD,&CB,&01,&B0
defb &FD,&CB,&01,&B1
defb &FD,&CB,&01,&B2
defb &FD,&CB,&01,&B3
defb &FD,&CB,&01,&B4
defb &FD,&CB,&01,&B5
defb &FD,&CB,&01,&B6
defb &FD,&CB,&01,&B7
defb &FD,&CB,&01,&B8
defb &FD,&CB,&01,&B9
defb &FD,&CB,&01,&BA
defb &FD,&CB,&01,&BB
defb &FD,&CB,&01,&BC
defb &FD,&CB,&01,&BD
defb &FD,&CB,&01,&BE
defb &FD,&CB,&01,&BF
defb &FD,&CB,&01,&C0
defb &FD,&CB,&01,&C1
defb &FD,&CB,&01,&C2
defb &FD,&CB,&01,&C3
defb &FD,&CB,&01,&C4
defb &FD,&CB,&01,&C5
defb &FD,&CB,&01,&C6
defb &FD,&CB,&01,&C7
defb &FD,&CB,&01,&C8
defb &FD,&CB,&01,&C9
defb &FD,&CB,&01,&CA
defb &FD,&CB,&01,&CB
defb &FD,&CB,&01,&CC
defb &FD,&CB,&01,&CD
defb &FD,&CB,&01,&CE
defb &FD,&CB,&01,&CF
defb &FD,&CB,&01,&D0
defb &FD,&CB,&01,&D1
defb &FD,&CB,&01,&D2
defb &FD,&CB,&01,&D3
defb &FD,&CB,&01,&D4
defb &FD,&CB,&01,&D5
defb &FD,&CB,&01,&D6
defb &FD,&CB,&01,&D7
defb &FD,&CB,&01,&D8
defb &FD,&CB,&01,&D9
defb &FD,&CB,&01,&DA
defb &FD,&CB,&01,&DB
defb &FD,&CB,&01,&DC
defb &FD,&CB,&01,&DD
defb &FD,&CB,&01,&DE
defb &FD,&CB,&01,&DF
defb &FD,&CB,&01,&E0
defb &FD,&CB,&01,&E1
defb &FD,&CB,&01,&E2
defb &FD,&CB,&01,&E3
defb &FD,&CB,&01,&E4
defb &FD,&CB,&01,&E5
defb &FD,&CB,&01,&E6
defb &FD,&CB,&01,&E7
defb &FD,&CB,&01,&E8
defb &FD,&CB,&01,&E9
defb &FD,&CB,&01,&EA
defb &FD,&CB,&01,&EB
defb &FD,&CB,&01,&EC
defb &FD,&CB,&01,&ED
defb &FD,&CB,&01,&EE
defb &FD,&CB,&01,&EF
defb &FD,&CB,&01,&F0
defb &FD,&CB,&01,&F1
defb &FD,&CB,&01,&F2
defb &FD,&CB,&01,&F3
defb &FD,&CB,&01,&F4
defb &FD,&CB,&01,&F5
defb &FD,&CB,&01,&F6
defb &FD,&CB,&01,&F7
defb &FD,&CB,&01,&F8
defb &FD,&CB,&01,&F9
defb &FD,&CB,&01,&FA
defb &FD,&CB,&01,&FB
defb &FD,&CB,&01,&FC
defb &FD,&CB,&01,&FD
defb &FD,&CB,&01,&FE
defb &FD,&CB,&01,&FF
defb &FD,&E1
defb &FD,&E3
defb &FD,&E5
defb &FD,&E9
defb &FD,&F9
defb &FE,&01
defb &FF

;; these are to test how IX/IY offsets are displayed
defb &DD,&70,&7F
defb &DD,&70,&80
defb &DD,&70,&FF
defb &DD,&70,&00
defb &DD,&70,&40
defb &DD,&70,&c0
endif

include "../lib/mem.asm"
include "../lib/report.asm"
include "../lib/test.asm"
include "../lib/outputmsg.asm"
include "../lib/outputhex.asm"
include "../lib/output.asm"
include "../lib/hw/psg.asm"
;; firmware based output
include "../lib/fw/output.asm"
;;include "../lib/hw/scr.asm"

end start
