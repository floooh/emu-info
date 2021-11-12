
test                    macro testproc, testtext
                        dw    testproc
                        db    testtext, 255
                        endm

z80_flags_table
                        test  proc_SCF,               "SCF"
                        test  proc_CCF,               "CCF"
                        test  proc_DAA,               "DAA"
                        test  proc_CPL,               "CPL"
                        test  proc_NEG,               "NEG"
                        test  proc_AND,               "AND"
                        test  proc_OR,                "OR"
                        test  proc_XOR,               "XOR"
                        test  proc_CP,                "CP"
                        test  proc_INC8,              "INC8"
                        test  proc_ADD8,              "ADD8"
                        test  proc_ADC8,              "ADC8"
                        test  proc_DEC8,              "DEC8"
                        test  proc_SUB8,              "SUB8"
                        test  proc_SBC8,              "SBC8"

                        test  proc_ADD16,             "ADD16"
                        test  proc_ADC16,             "ADC16"
                        test  proc_SBC16,             "SBC16"

                        test  proc_RLA_RRA,           "RLA/RRA"
                        test  proc_RLCA_RRCA,         "RLCA/RRCA"

                        test  proc_RLC_RRC,           "RLC/RRC"
                        test  proc_RL_RR,             "RL/RR"
                        test  proc_SLA_SRA,           "SLA/SRA"
                        test  proc_SLL_SRL,           "SLL/SRL"

                        test  proc_RLD_RRD,           "RLD/RRD"

                        test  proc_LDAI_LDAR,         "LD A,I/R"

                        test  proc_BIT_HL,            "BIT n,(HL)"
                        test  proc_BIT_IX,            "BIT n,(IX+d)"
                        test  proc_BIT_IY,            "BIT n,(IY+d)"

                        test  proc_LDI,               "LDI"
                        test  proc_LDD,               "LDD"
                        test  proc_LDIR,              "LDIR"
                        test  proc_LDDR,              "LDDR"
                        test  proc_CPI,               "CPI"
                        test  proc_CPD,               "CPD"
                        test  proc_INI,               "INI"
                        test  proc_IND,               "IND"
                        test  proc_OUTI,              "OUTI"
                        test  proc_OUTD,              "OUTD"

                        test  proc_DDCB_IX_ROM,       "DD CB (00-FF)  ROM"
                        test  proc_DDCB_IX_RAM,       "DD CB (00-FF)  RAM"

                        test  proc_FDCB_IY_ROM,       "FD CB (00-FF)  ROM"
                        test  proc_FDCB_IY_RAM,       "FD CB (00-FF)  RAM"

                        test  proc_CB_ROM_without53,  "CB (00-FF)     ROM"
                        test  proc_CB_RAM_without53,  "CB (00-FF)     RAM"
                        test  proc_CB_ROM_with53,     "CB (00-FF) 5+3 ROM"
                        test  proc_CB_RAM_with53,     "CB (00-FF) 5+3 RAM"

                        dw    0

                      ; ----- MEMPTR tests -----
z80_memptr_table
                        test  test_MEMPTR_LD_A_addr,  "LD A,(addr)"
                        test  test_MEMPTR_LD_addr_A,  "LD (addr),A"

                        test  test_MEMPTR_LD_A_BC,    "LD A,(BC)"
                        test  test_MEMPTR_LD_A_DE,    "LD A,(DE)"
                        test  test_MEMPTR_LD_A_HL,    "LD A,(HL)"

                        test  test_MEMPTR_LD_BC_A,    "LD (BC),A"
                        test  test_MEMPTR_LD_DE_A,    "LD (DE),A"
                        test  test_MEMPTR_LD_HL_A,    "LD (HL),A"

                        test  test_MEMPTR_LD_HL_addr, "LD HL,(addr)"
                        test  test_MEMPTR_LD_SHL_addr,"LD HL,(addr) [ED]"   ; ED version
                        test  test_MEMPTR_LD_DE_addr, "LD DE,(addr)"
                        test  test_MEMPTR_LD_BC_addr, "LD BC,(addr)"
                        test  test_MEMPTR_LD_IX_addr, "LD IX,(addr)"
                        test  test_MEMPTR_LD_IY_addr, "LD IY,(addr)"
                        test  test_MEMPTR_LD_SP_addr, "LD SP,(addr)"

                        test  test_MEMPTR_LD_addr_HL, "LD (addr),HL"
                        test  test_MEMPTR_LD_addr_SHL,"LD (addr),HL [ED]"   ; ED version
                        test  test_MEMPTR_LD_addr_DE, "LD (addr),DE"
                        test  test_MEMPTR_LD_addr_BC, "LD (addr),BC"
                        test  test_MEMPTR_LD_addr_IX, "LD (addr),IX"
                        test  test_MEMPTR_LD_addr_IY, "LD (addr),IY"
                        test  test_MEMPTR_LD_addr_SP, "LD (addr),SP"

                        test  test_MEMPTR_EX_SP_HL,   "EX (SP),HL"
                        test  test_MEMPTR_EX_SP_IX,   "EX (SP),IX"
                        test  test_MEMPTR_EX_SP_IY,   "EX (SP),IY"

                        test  test_MEMPTR_ADD_HL_BC,  "ADD HL,BC"
                        test  test_MEMPTR_ADD_IX_BC,  "ADD IX,BC"
                        test  test_MEMPTR_ADD_IY_BC,  "ADD IY,BC"
                        test  test_MEMPTR_ADC_HL_BC,  "ADC HL,BC"
                        test  test_MEMPTR_SBC_HL_BC,  "SBC HL,BC"

                        test  test_MEMPTR_DJNZ_TAKEN, "DJNZ (taken)"
                        test  test_MEMPTR_DJNZ_NOT_TAKEN, "DJNZ (not taken)"

                        test  test_MEMPTR_RLD,        "RLD"
                        test  test_MEMPTR_RRD,        "RRD"

                        test  test_MEMPTR_IN_A_PORT,  "IN A,(port)"
                        test  test_MEMPTR_IN_A_BC,    "IN A,(C)"
                        test  test_MEMPTR_OUT_PORT_A, "OUT (port),A"
                        test  test_MEMPTR_OUT_BC_A,   "OUT (C),A"

                        test  test_MEMPTR_LDI,        "LDI"
                        test  test_MEMPTR_LDD,        "LDD"
                        test  test_MEMPTR_LDIR_BC_EQ, "LDIR (BC=1)"
                        test  test_MEMPTR_LDIR_BC_GT, "LDIR (BC>1)"
                        test  test_MEMPTR_LDDR_BC_EQ, "LDDR (BC=1)"
                        test  test_MEMPTR_LDDR_BC_GT, "LDDR (BC>1)"

                        test  test_MEMPTR_CPI,        "CPI"
                        test  test_MEMPTR_CPD,        "CPD"
                        test  test_MEMPTR_CPIR_BC_EQ, "CPIR (BC=1)"
                        test  test_MEMPTR_CPIR_BC_GT, "CPIR (BC>1)"
                        test  test_MEMPTR_CPDR_BC_EQ, "CPDR (BC=1)"
                        test  test_MEMPTR_CPDR_BC_GT, "CPDR (BC>1)"

                        test  test_MEMPTR_INI,        "INI"
                        test  test_MEMPTR_IND,        "IND"
                        test  test_MEMPTR_INIR,       "INIR"
                        test  test_MEMPTR_INDR,       "INDR"

                        test  test_MEMPTR_OUTI,       "OUTI"
                        test  test_MEMPTR_OUTD,       "OUTD"
                        test  test_MEMPTR_OTIR,       "OTIR"
                        test  test_MEMPTR_OTDR,       "OTDR"

                        dw    0

proc_SCF                proc
                        ld    bc,#0ebf
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ccf
                        scf
                        jp    Calc_CRC
                        endp

proc_CCF                proc
                        ld    bc,#3ced
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        scf
                        ccf
                        jp    Calc_CRC
                        endp

proc_DAA                proc
                        ld    bc,#20fd
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        daa
                        jp    Calc_CRC
                        endp

proc_CPL                proc
                        ld    bc,#b0d6
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        cpl
                        jp    Calc_CRC
                        endp

proc_NEG                proc
                        ld    bc,#ee36
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        neg
                        jp    Calc_CRC
                        endp

proc_AND                proc
                        ld    bc,#cb8e
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        and   c
                        jp    Calc_CRC
                        endp

proc_OR                 proc
                        ld    bc,#c57c
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        or    c
                        jp    Calc_CRC
                        endp

proc_XOR                proc
                        ld    bc,#26f4
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        xor   c
                        jp    Calc_CRC
                        endp

proc_CP                 proc
                        ld    bc,#1676
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        cp    c
                        jp    Calc_CRC
                        endp

proc_ADD8               proc
                        ld    bc,#9c3c
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        add   a,c
                        jp    Calc_CRC
                        endp

proc_ADC8               proc
                        ld    bc,#6e2a
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        adc   a,c
                        jp    Calc_CRC
                        endp

proc_SUB8               proc
                        ld    bc,#1ef5
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        sub   c
                        jp    Calc_CRC
                        endp

proc_SBC8               proc
                        ld    bc,#f6dd
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,b
                        sbc   a,c
                        jp    Calc_CRC
                        endp

proc_INC8               proc
                        ld    bc,#48cf
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        dec   c
                        inc   c
                        jp    Calc_CRC
                        endp

proc_DEC8               proc
                        ld    bc,#e0d5
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        inc   c
                        dec   c
                        jp    Calc_CRC
                        endp

proc_ADD16              proc
                        ld    bc,#e268
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        add   hl,bc
                        jp    Calc_CRC
                        endp

proc_ADC16              proc
                        ld    bc,#715f
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        add   a,a
                        adc   hl,bc
                        jp    Calc_CRC
                        endp

proc_SBC16              proc
                        ld    bc,#0e1c
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        add   a,a
                        sbc   hl,bc
                        jp    Calc_CRC
                        endp

proc_RLA_RRA            proc
                        ld    bc,#13c1
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        rla
                        call  Calc_CRC
                        ld    a,c
                        rra
                        jp    Calc_CRC
                        endp

proc_RLCA_RRCA          proc
                        ld    bc,#13c1
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        rlca
                        call  Calc_CRC
                        ld    a,c
                        rrca
                        jp    Calc_CRC
                        endp

proc_RLC_RRC            proc
                        ld    bc,#10ab
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        rlc   a
                        call  Calc_CRC
                        ld    a,c
                        rrc   a
                        jp    Calc_CRC
                        endp

proc_RL_RR              proc
                        ld    bc,#e221
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        rl    a
                        call  Calc_CRC
                        ld    a,c
                        rr    a
                        jp    Calc_CRC
                        endp

proc_SLA_SRA            proc
                        ld    bc,#defa
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        sla   a
                        call  Calc_CRC
                        ld    a,c
                        sra   a
                        jp    Calc_CRC
                        endp

proc_SLL_SRL            proc
                        ld    bc,#5fdd
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,c
                        sll   a
                        call  Calc_CRC
                        ld    a,c
                        srl   a
                        jp    Calc_CRC
                        endp

proc_RLD_RRD            proc
                        ld    bc,#7997
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    h,5
                        ld    a,l
                        inc   l
                        rld
                        call  Calc_CRC

                        ld    a,l
                        inc   l
                        rrd
                        jp    Calc_CRC
                        endp

proc_LDAI_LDAR          proc
                        ld    bc,#220c
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,i
                        call  Calc_CRC
                        ld    a,r
                        jp    Calc_CRC
                        endp

proc_BIT_HL             proc
                        ld    bc,#6208
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,r
                        ld    l,a

                        bit   0,(hl)
                        call  Calc_CRC
                        bit   1,(hl)
                        call  Calc_CRC
                        bit   2,(hl)
                        call  Calc_CRC
                        bit   3,(hl)
                        call  Calc_CRC
                        bit   4,(hl)
                        call  Calc_CRC
                        bit   5,(hl)
                        call  Calc_CRC
                        bit   6,(hl)
                        call  Calc_CRC
                        bit   7,(hl)
                        jp    Calc_CRC
                        endp

proc_BIT_IX             proc
                        ld    bc,#4ad9
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,r
                        ld    ixl,a

                        bit   0,(ix+0)
                        call  Calc_CRC
                        bit   1,(ix+127)
                        call  Calc_CRC
                        bit   2,(ix-128)
                        call  Calc_CRC
                        bit   3,(ix+64)
                        call  Calc_CRC
                        bit   4,(ix-64)
                        call  Calc_CRC
                        bit   5,(ix+32)
                        call  Calc_CRC
                        bit   6,(ix-32)
                        call  Calc_CRC
                        bit   7,(ix-1)
                        jp    Calc_CRC
                        endp

proc_BIT_IY             proc
                        ld    bc,#3a82
                        ld    hl,_code
                        jp    proc_Opcode
_code
                        ld    a,r
                        ld    iyl,a

                        bit   0,(iy+0)
                        call  Calc_CRC
                        bit   1,(iy+127)
                        call  Calc_CRC
                        bit   2,(iy-128)
                        call  Calc_CRC
                        bit   3,(iy+69)
                        call  Calc_CRC
                        bit   4,(iy-69)
                        call  Calc_CRC
                        bit   5,(iy+12)
                        call  Calc_CRC
                        bit   6,(iy-12)
                        call  Calc_CRC
                        bit   7,(iy+1)
                        jp    Calc_CRC
                        endp



proc_Opcode             proc

                        di

                        push  bc
                        ld    (_call+1),hl

                        call  Init_CRC

                        ld    ix,8192
                        ld    iy,8192
                        ld    hl,0
                        ld    de,0
                        ld    bc,0

                        xor   a
                        ld    r,a   ; R always set immediately before loop entry to remain at fixed values in loop

_loop                   push  bc
                        pop   af

_call                   call  0

                        inc   c
                        jr    nz,_loop
                        inc   b
                        jr    nz,_loop

                        ld    iy,23610
                        ei

                        ld    hl,(CRC_16)
                        call  print_hex_16
                        ld    a," "
                        rst   16

                        pop   bc
                        or    a
                        sbc   hl,bc
                        ret   nz

                        pop   hl
                        ret
                        endp

proc_LDI                proc
                        ld    hl,#a0ed    ; LDI
                        ld    bc,#4487    ; expected result
                        jr    proc_ED_Opcode
                        endp
proc_LDD                proc
                        ld    hl,#a8ed    ; LDD
                        ld    bc,#7f0e    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_LDIR               proc
                        ld    hl,#b0ed    ; LDIR
                        ld    bc,#9acc    ; expected result
                        jr    proc_ED_Opcode
                        endp
proc_LDDR               proc
                        ld    hl,#b8ed    ; LDDR
                        ld    bc,#ce51    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_CPI                proc
                        ld    hl,#a1ed    ; CPI
                        ld    bc,#55db    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_CPD                proc
                        ld    hl,#a9ed    ; CPD
                        ld    bc,#ac82    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_INI                proc
                        ld    hl,#a2ed    ; INI
                        ld    bc,#f25d    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_IND                proc
                        ld    hl,#aaed    ; IND
                        ld    bc,#4a02    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_OUTI               proc
                        ld    hl,#a3ed    ; OUTI
                        ld    bc,#8b66    ; expected result
                        jr    proc_ED_Opcode
                        endp

proc_OUTD               proc
                        ld    hl,#abed    ; OUTD
                        ld    bc,#1156    ; expected result
                        jr    proc_ED_Opcode
                        endp




proc_ED_Opcode          proc

                        push  bc
                        ld    (_opcode),hl

                        call  Init_CRC

                        ld    bc,0

_flagsloop              exx

                        ld    hl,#1800
                        ld    de,#1801
                        ld    bc,#10fe

_loop                   exx
                        push  bc
                        pop   af
                        exx
_opcode                 ldi

                        call  Calc_CRC

                        ld    a,b
                        or    a
                        jr    nz,_loop

                        exx
                        inc   c
                        jr    nz,_flagsloop

                        ld    hl,(CRC_16)
                        call  print_hex_16
                        ld    a," "
                        rst   16

                        pop   bc
                        or    a
                        sbc   hl,bc
                        ret   nz

                        pop   hl
                        ret

                        endp

proc_DDCB_IX_ROM        proc
                        ld    ix,#01a0
                        ld    bc,#d9eb
                        jr    proc_DDCB_IX
                        endp

proc_DDCB_IX_RAM        proc
                        ld    hl,#02ab
                        ld    de,49152
                        ld    bc,256
                        ldir

                        ld    ix,49152
                        ld    bc,#90c0
                        jr    proc_DDCB_IX
                        endp

proc_DDCB_IX            proc

                        di
                        push  bc

                        ld    iy,0
                        ld    hl,0
                        ld    de,0
                        ld    bc,0

                        push  hl
                        pop   af

_loop                   ld    (_opcode+3),a

_opcode                 db    #dd, #cb, #00, #00

                        push  af
                        add   iy,de
                        add   iy,bc
                        ex    de,hl
                        add   iy,de
                        pop   de
                        add   iy,de
                        ld    d,0
                        ld    e,(ix+0)
                        add   iy,de

                        inc   ix
                        ld    a,(_opcode+3)
                        inc   a
                        jr    nz,_loop

                        push  iy
                        pop   hl

                        ld    iy,23610
                        ei

                        call  print_hex_16
                        ld    a," "
                        rst   16

                        pop   bc
                        or    a
                        sbc   hl,bc
                        ret   nz

                        pop   hl
                        ret

                        endp

proc_FDCB_IY_ROM        proc
                        ld    hl,#01a0
                        ld    bc,#d9eb
                        jr    proc_FDCB_IY
                        endp

proc_FDCB_IY_RAM        proc
                        ld    hl,#02ab
                        ld    de,49152
                        ld    bc,256
                        ldir

                        ld    hl,49152
                        ld    bc,#90c0
                        jr    proc_FDCB_IY
                        endp

proc_FDCB_IY            proc

                        di
                        push  bc

                        push  hl
                        pop   iy

                        ld    ix,0
                        ld    hl,0
                        ld    de,0
                        ld    bc,0

                        push  hl
                        pop   af

_loop                   ld    (_opcode+3),a

_opcode                 db    #fd, #cb, #00, #00

                        push  af
                        add   ix,de
                        add   ix,bc
                        ex    de,hl
                        add   ix,de
                        pop   de
                        add   ix,de
                        ld    d,0
                        ld    e,(iy+0)
                        add   ix,de

                        inc   iy
                        ld    a,(_opcode+3)
                        inc   a
                        jr    nz,_loop

                        push  ix
                        pop   hl

                        ld    iy,23610
                        ei

                        call  print_hex_16
                        ld    a," "
                        rst   16

                        pop   bc
                        or    a
                        sbc   hl,bc
                        ret   nz

                        pop   hl
                        ret

                        endp

proc_CB_ROM_with53      proc
                        ld    a,1
                        ld    (with_53),a
                        ld    ix,#01a0
                        ld    bc,#4d19
                        jr    proc_CB
                        endp

proc_CB_RAM_with53      proc
                        ld    a,1
                        ld    (with_53),a
                        ld    hl,#02ab
                        ld    de,49152
                        ld    bc,256
                        ldir

                        ld    ix,49152
                        ld    bc,#1b66
                        jr    proc_CB
                        endp

proc_CB_ROM_without53   proc
                        xor   a
                        ld    (with_53),a
                        ld    ix,#01a0
                        ld    bc,#4731
                        jr    proc_CB
                        endp

proc_CB_RAM_without53   proc
                        xor   a
                        ld    (with_53),a
                        ld    hl,#02ab
                        ld    de,49152
                        ld    bc,256
                        ldir

                        ld    ix,49152
                        ld    bc,#15ae
                        jr    proc_CB
                        endp

proc_CB                 proc

                        di
                        push  bc

                        ld    iy,0
                        ld    hl,0
                        ld    de,0
                        ld    bc,0

                        push  hl
                        pop   af

_loop                   ld    (_opcode1+1),a
                        ld    (_opcode2+1),a

                        and   7
                        cp    6
                        jr    nz,_opcode1 ; not (HL) opcode

                        push  hl
                        push  ix
                        pop   hl
_opcode2                db    #cb, #00
                        ld    a,(hl)
                        pop   hl
                        jr    _result

_opcode1                db    #cb, #00

_result                 push  af
                        add   iy,de
                        pop   de
                        ld    a,(with_53)
                        or    a
                        jr    nz,_keep_53

                        res   5,e
                        res   3,e

_keep_53                add   iy,de
                        add   iy,bc
                        ex    de,hl
                        add   iy,de

                        inc   ix
                        ld    a,(_opcode1+1)
                        inc   a
                        jr    nz,_loop

                        push  iy
                        pop   hl

                        ld    iy,23610
                        ei

                        call  print_hex_16
                        ld    a," "
                        rst   16

                        pop   bc
                        or    a
                        sbc   hl,bc
                        ret   nz

                        pop   hl
                        ret

                        endp

with_53                 db    0


test_MEMPTR_DJNZ_TAKEN  proc
                        ld    hl,_opcodes
                        ld    bc,#002b    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                call  testhelper_DJNZ_TAKEN
                        ds    20
                        endp

test_MEMPTR_DJNZ_NOT_TAKEN  proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                call  testhelper_DJNZ_NOT_TAKEN
                        ds    20
                        endp

test_MEMPTR_LD_A_addr   proc
                        ld    hl,_opcodes
                        ld    bc,#2ff8    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        ld    a,(#2ff7)
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LD_addr_A   proc
                        ld    hl,_opcodes
                        ld    bc,#35fc    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        ld    a,#35
                        ld    (#20fb),a
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LD_A_BC     proc
                        ld    hl,_opcodes
                        ld    bc,#1f8d    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  bc
                        push  af
                        ld    bc,#1f8c
                        ld    a,(bc)
                        pop   af
                        pop   bc
                        ds    20
                        endp

test_MEMPTR_LD_A_DE     proc
                        ld    hl,_opcodes
                        ld    bc,#311f    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  de
                        push  af
                        ld    de,#311e
                        ld    a,(de)
                        pop   af
                        pop   de
                        ds    20
                        endp

test_MEMPTR_LD_A_HL     proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  af
                        ld    hl,#2113
                        ld    a,(hl)
                        pop   af
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_LD_BC_A     proc
                        ld    hl,_opcodes
                        ld    bc,#179c    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  bc
                        push  af
                        ld    bc,#0e9b
                        ld    a,#17
                        ld    (bc),a
                        pop   af
                        pop   bc
                        ds    20
                        endp

test_MEMPTR_LD_DE_A     proc
                        ld    hl,_opcodes
                        ld    bc,#3a08    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  de
                        push  af
                        ld    de,#3307
                        ld    a,#fa
                        ld    (de),a
                        pop   af
                        pop   de
                        ds    20
                        endp

test_MEMPTR_LD_HL_A     proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  af
                        ld    hl,#1efe
                        ld    a,#ff
                        ld    (hl),a
                        pop   af
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_LD_HL_addr  proc
                        ld    hl,_opcodes
                        ld    bc,#0f0a    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        ld    hl,(#0f09)
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_LD_SHL_addr proc
                        ld    hl,_opcodes
                        ld    bc,#21db    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        db    #ed, #6b, #da, #21      ; ED version: LD HL,(#21da)
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_LD_DE_addr  proc
                        ld    hl,_opcodes
                        ld    bc,#347b    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  de
                        ld    de,(#347a)
                        pop   de
                        ds    20
                        endp

test_MEMPTR_LD_BC_addr  proc
                        ld    hl,_opcodes
                        ld    bc,#0140    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  bc
                        ld    bc,(#013f)
                        pop   bc
                        ds    20
                        endp

test_MEMPTR_LD_IX_addr  proc
                        ld    hl,_opcodes
                        ld    bc,#2f40    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  ix
                        ld    ix,(#2f3f)
                        pop   ix
                        ds    20
                        endp

test_MEMPTR_LD_IY_addr  proc
                        ld    hl,_opcodes
                        ld    bc,#0001    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  iy
                        ld    iy,(#0000)
                        pop   iy
                        ds    20
                        endp

test_MEMPTR_LD_SP_addr  proc
                        ld    hl,_opcodes
                        ld    bc,#1978    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        ld    hl,0
                        add   hl,sp
                        ld    sp,(#1977)
                        ld    sp,hl
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_LD_addr_HL  proc
                        ld    hl,_opcodes
                        ld    bc,#3042    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                ld    (#3041),hl
                        ds    20
                        endp

test_MEMPTR_LD_addr_SHL proc
                        ld    hl,_opcodes
                        ld    bc,#1a45    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                db    #ed, #63, #44, #1a      ; ED version: LD (#1a44),HL
                        ds    20
                        endp

test_MEMPTR_LD_addr_DE  proc
                        ld    hl,_opcodes
                        ld    bc,#000a    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                ld    (#0009),de
                        ds    20
                        endp

test_MEMPTR_LD_addr_BC  proc
                        ld    hl,_opcodes
                        ld    bc,#2e98    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                ld    (#2e97),bc
                        ds    20
                        endp

test_MEMPTR_LD_addr_IX  proc
                        ld    hl,_opcodes
                        ld    bc,#0d56    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                ld    (#0d55),ix
                        ds    20
                        endp

test_MEMPTR_LD_addr_IY  proc
                        ld    hl,_opcodes
                        ld    bc,#1912    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                ld    (#1911),iy
                        ds    20
                        endp

test_MEMPTR_LD_addr_SP  proc
                        ld    hl,_opcodes
                        ld    bc,#0115    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                ld    (#0114),sp
                        ds    20
                        endp

test_MEMPTR_EX_SP_HL    proc
                        ld    hl,_opcodes
                        ld    bc,#3809    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        ld    hl,#3809
                        ex    (sp),hl
                        ex    (sp),hl
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_EX_SP_IX    proc
                        ld    hl,_opcodes
                        ld    bc,#2114    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  ix
                        ld    ix,#2114
                        ex    (sp),ix
                        ex    (sp),ix
                        pop   ix
                        ds    20
                        endp

test_MEMPTR_EX_SP_IY    proc
                        ld    hl,_opcodes
                        ld    bc,#0737    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  iy
                        ld    iy,#0737
                        ex    (sp),iy
                        ex    (sp),iy
                        pop   iy
                        ds    20
                        endp

test_MEMPTR_ADD_HL_BC   proc
                        ld    hl,_opcodes
                        ld    bc,#099b    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  bc
                        ld    hl,#099a
                        ld    bc,#1000
                        add   hl,bc
                        pop   bc
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_ADD_IX_BC   proc
                        ld    hl,_opcodes
                        ld    bc,#2a44    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  ix
                        push  bc
                        ld    ix,#2a43
                        ld    bc,#1000
                        add   ix,bc
                        pop   bc
                        pop   ix
                        ds    20
                        endp

test_MEMPTR_ADD_IY_BC   proc
                        ld    hl,_opcodes
                        ld    bc,#019d    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  iy
                        push  bc
                        ld    iy,#019c
                        ld    bc,#1000
                        add   iy,bc
                        pop   bc
                        pop   iy
                        ds    20
                        endp

test_MEMPTR_ADC_HL_BC   proc
                        ld    hl,_opcodes
                        ld    bc,#1773    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  bc
                        ld    hl,#1772
                        ld    bc,#1000
                        or    a
                        adc   hl,bc
                        pop   bc
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_SBC_HL_BC   proc
                        ld    hl,_opcodes
                        ld    bc,#2446    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  bc
                        ld    hl,#2445
                        ld    bc,#1000
                        or    a
                        sbc   hl,bc
                        pop   bc
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_RLD         proc
                        ld    hl,_opcodes
                        ld    bc,#117f    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  af
                        ld    hl,#117e
                        ld    a,#fd
                        rld
                        pop   af
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_RRD         proc
                        ld    hl,_opcodes
                        ld    bc,#34ae    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  hl
                        push  af
                        ld    hl,#34ad
                        ld    a,#fd
                        rrd
                        pop   af
                        pop   hl
                        ds    20
                        endp

test_MEMPTR_IN_A_PORT   proc
                        ld    hl,_opcodes
                        ld    bc,#3100    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        ld    a,#30
                        in    a,(#ff)
                        pop   af
                        ds    20
                        endp

test_MEMPTR_IN_A_BC     proc
                        ld    hl,_opcodes
                        ld    bc,#0aff    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  bc
                        push  af
                        ld    bc,#0afe
                        in    a,(c)
                        pop   af
                        pop   bc
                        ds    20
                        endp

test_MEMPTR_OUT_PORT_A  proc
                        ld    hl,_opcodes
                        ld    bc,#2100    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        ld    a,#21
                        out   (#ff),a
                        pop   af
                        ds    20
                        endp

test_MEMPTR_OUT_BC_A    proc
                        ld    hl,_opcodes
                        ld    bc,#3dff    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  bc
                        push  af
                        ld    bc,#3dfe
                        ld    a,7
                        out   (c),a
                        pop   af
                        pop   bc
                        ds    20
                        endp

test_MEMPTR_LDI         proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    de,#2000
                        ld    bc,#3000
                        ldi
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LDD         proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#2000
                        ld    de,#3000
                        ld    bc,#1000
                        ldd
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LDIR_BC_EQ  proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    de,#2000
                        ld    bc,1
                        call  testhelper_LDIR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LDIR_BC_GT  proc
                        ld    hl,_opcodes
                        ld    bc,#0007    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    de,#2000
                        ld    bc,10
                        call  testhelper_LDIR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LDDR_BC_EQ  proc
                        ld    hl,_opcodes
                        ld    bc,#0000    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    de,#2000
                        ld    bc,1
                        call  testhelper_LDDR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_LDDR_BC_GT  proc
                        ld    hl,_opcodes
                        ld    bc,#000e    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    de,#2000
                        ld    bc,10
                        call  testhelper_LDDR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_CPI         proc
                        ld    hl,_opcodes
                        ld    bc,#0001    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        cpi
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_CPD         proc
                        ld    hl,_opcodes
                        ld    bc,#3fff    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        cpd
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_CPIR_BC_EQ  proc
                        ld    hl,_opcodes
                        ld    bc,#0001    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    bc,1
                        xor   a
                        call  testhelper_CPIR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_CPIR_BC_GT  proc
                        ld    hl,_opcodes
                        ld    bc,#0017    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    bc,2
                        xor   a
                        call  testhelper_CPIR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_CPDR_BC_EQ  proc
                        ld    hl,_opcodes
                        ld    bc,#3fff    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    bc,1
                        xor   a
                        call  testhelper_CPDR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_CPDR_BC_GT  proc
                        ld    hl,_opcodes
                        ld    bc,#001f    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#1000
                        ld    bc,2
                        xor   a
                        call  testhelper_CPDR
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_INI         proc
                        ld    hl,_opcodes
                        ld    bc,#3fff    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#3ffe
                        ini
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_IND         proc
                        ld    hl,_opcodes
                        ld    bc,#3ffd    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#3ffe
                        ind
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_INIR        proc
                        ld    hl,_opcodes
                        ld    bc,#01ff    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#04fe
                        inir
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_INDR        proc
                        ld    hl,_opcodes
                        ld    bc,#01fd    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#08fe
                        indr
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_OUTI        proc
                        ld    hl,_opcodes
                        ld    bc,#3f00    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#3fff
                        outi
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_OUTD        proc
                        ld    hl,_opcodes
                        ld    bc,#01fe    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#02ff
                        outd
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_OTIR        proc
                        ld    hl,_opcodes
                        ld    bc,#0100    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#04ff
                        otir
                        exx
                        pop   af
                        ds    20
                        endp

test_MEMPTR_OTDR        proc
                        ld    hl,_opcodes
                        ld    bc,#00fe    ; expected result
                        jp    test_MEMPTR_Opcode
_opcodes                push  af
                        exx
                        ld    hl,#0000
                        ld    bc,#08ff
                        otdr
                        exx
                        pop   af
                        ds    20
                        endp






test_MEMPTR_Opcode      proc

                        push  bc
                        call  Read_MEMPTR
                        pop   bc

                        or    a
                        sbc   hl,bc
                        ret   nz

                        pop   hl
                        ret

                        endp

FLAG_3                  macro
                        bit   0,(hl)
                        push  af
                        dec   sp
                        pop   af
                        inc   sp
                        rla
                        rla
                        rla
                        rr    e

                        cpd               ; decrement MEMPTR
                        inc   hl
                        endm

Read_MEMPTR             proc

                        di

                        ld    de,_opcode
                        ld    bc,20
                        ldir

                        ld    ix,_loop
                        ld    bc,8192

                        ld    hl,_exitloop
                        push  hl

                        ld    a,(#ffff)   ; clears MEMPTR to zero before executing test opcode

_opcode                 ds     20

                        ld    hl,#ffff

_loop                   rept  8
                              FLAG_3
                        endm

                        ld    (hl),e
                        dec   hl

                        ret   po
                        jp    (ix)

_exitloop               call  MEMPTR_B013

                        ei

                        ld    a,(skip_output)
                        or    a
                        jr    nz,_skip

                        call  print_hex_16
                        ld    a," "
                        rst   16

_skip                   ret

                        endp


MEMPTR_B013             proc

                        ld    hl,#ffff
                        ld    de,0

                        ld    a,(hl)
                        push  af
                        bit   0,a
                        jr    nz,_descendloop

_ascendloop             ld    a,8
_ascendloop2            rrc   (hl)
                        jr    c,_ascendexit
                        inc   de
_skip                   dec   a
                        jr    nz,_ascendloop2
                        dec   hl
                        jr    _ascendloop
_ascendexit             dec   de
                        jr    _exitloop

_descendloop            ld    a,8
_descendloop2           rrc   (hl)
                        jr    nc,_descendexit
                        inc   de
                        dec   a
                        jr    nz,_descendloop2
                        dec   hl
                        jr    _descendloop
_descendexit            dec   de

_exitloop
                        pop   af          ; restore original (#FFFF) value
                        bit   0,a
                        res   5,d
                        jr    z,_result
                        set   5,d

_result                 ex    de,hl
                        ret

                        endp

; 1. exclusive-or the input byte with the low-order byte of the CRC register to get an INDEX
; 2. shift the CRC register eight bits to the right
; 3. exclusive-or the CRC register with the contents of Table[INDEX]
      
; value in AF

Init_CRC                proc
                        push  hl
                        ld    hl,#ffff
                        ld    (CRC_16),hl
                        pop   hl
                        ret
                        endp

Calc_CRC                proc
                        push  hl
                        push  de
                        push  bc
                        push  af

                        push  af
                        pop   bc
                        ld    a,c   ; A = input byte from Flags
                        ld    hl,(CRC_16)

; CRC-16/CITT for 8080/Z80
; On entry HL = old CRC, A = byte
; On exit HL = new CRC, A,B,C undefined

                        xor   h
                        ld    b,a
                        ld    c,l
                        rrca
                        rrca
                        rrca
                        rrca
                        ld    l,a
                        and   #0f
                        ld    h,a
                        xor   b
                        ld    b,a
                        xor   l
                        and   #f0
                        ld    l,a
                        xor   c
                        add   hl,hl
                        xor   h
                        ld    h,a
                        ld    a,l
                        xor   b
                        ld    l,a


                        ld    (CRC_16),hl

                        pop   af
                        pop   bc
                        pop   de
                        pop   hl
                        ret
                        endp

CRC_16                  dw    0




