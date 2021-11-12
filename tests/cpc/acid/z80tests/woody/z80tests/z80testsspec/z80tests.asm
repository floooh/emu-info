
start                   equ   32768
                        org   start

                        jp    main

testhelper_LDIR         ld    a,(#ffff)   ; clears MEMPTR to zero before executing LDIR
                        ldir              ; when BC > 1, MEMPTR = #8007
                        pop   hl
                        jp    (hl)

testhelper_LDDR         ld    a,(#ffff)   ; clears MEMPTR to zero before executing LDDR
                        lddr              ; when BC > 1, MEMPTR = #800e
                        pop   hl
                        jp    (hl)

testhelper_CPIR         push  af
                        ld    a,(#ffff)   ; clears MEMPTR to zero before executing CPIR
                        cpir              ; when BC > 1, MEMPTR = #8016
                        pop   af
                        pop   hl
                        jp    (hl)

testhelper_CPDR         push  af
                        ld    a,(#ffff)   ; clears MEMPTR to zero before executing CPDR
                        pop   af
                        cpdr              ; when BC > 1, MEMPTR = #8020
                        pop   hl
                        jp    (hl)

testhelper_DJNZ_TAKEN   push  bc
                        ld    a,(#ffff)   ; clears MEMPTR to zero before executing DJNZ
                        ld    b,#ff
                        djnz  djnz_taken  ; MEMPTR = #802b
djnz_taken              pop   bc
                        pop   hl
                        jp    (hl)

testhelper_DJNZ_NOT_TAKEN
                        push  bc
                        ld    a,(#ffff)   ; clears MEMPTR to zero before executing DJNZ
                        ld    b,1
                        djnz  djnz_not_taken
djnz_not_taken          pop   bc
                        pop   hl
                        jp    (hl)


; ==============================================================

main                    call  CLS

                        ld    de,menu.txt
                        call  print_string

wait_key                call  Get_Key
                        cp    "1"
                        jr    z,Run_Z80_Flags

                        cp    "2"
                        jr    z,Run_Z80_MEMPTR

                        cp    "3"
                        jr    nz,wait_key

                        exx
                        ld    hl,#2758
                        exx
                        ret


Run_Z80_Flags           ld    hl,z80_flags_table
                        ld    de,testing_flags.txt
                        jr    run_tests

Run_Z80_MEMPTR          ld    hl,z80_memptr_table
                        ld    de,testing_memptr.txt
                        jr    run_tests

test_finished           ld    de,press_key.txt
                        call  print_string
                        call  Get_Key
                        jr    main


run_tests               ld    (testptr),hl

                        push  de
                        call  CLS
                        pop   de
                        call  print_string

testloop                ld    (stackptr),sp

                        ld    a,7
                        out   (254),a

                        ld    hl,(testptr)
                        ld    e,(hl)
                        inc   hl
                        ld    d,(hl)
                        inc   hl

                        ex    de,hl

                        ld    a,h
                        or    l
                        jr    z,test_finished

                        call  print_string

                        ld    a,23
                        rst   16
                        ld    a,19
                        rst   16
                        xor   a
                        rst   16

                        ld    a,":"
                        rst   16
                        ld    a," "
                        rst   16

                        ld    (testptr),de

                        ld    bc,test_passed
                        push  bc
                        ld    bc,test_failed
                        push  bc

                        jp    (hl)

next_test               ld    sp,(stackptr)
                        ld    a,13
                        rst   16
                        jr    testloop



test_passed             ld    de,passed.txt
                        call  test_result
                        jr    next_test

test_failed             ld    de,failed.txt
                        call  test_result
                        ld    h,b
                        ld    l,c
                        call  print_hex_16
                        ld    a,16
                        rst   16
                        xor   a
                        rst   16
                        jr    next_test


test_result             ld    iy,23610
                        call  print_string
                        ret

CLS                     proc
                        call  3435
                        ld    a,2
                        jp    #1601
                        endp

Get_Key                 proc
                        xor   a
                        ld    (23560),a
_wait_key               ld    a,(23560)
                        or    a
                        jr    z,_wait_key
                        ret
                        endp

print_string            proc
_loop                   ld    a,(de)
                        inc   de
                        cp    255
                        ret   z
                        rst   16
                        jr    _loop
                        endp

print_hex_16            proc
                        ld    a,h
                        call  print_hex_8
                        ld    a,l
                        call  print_hex_8
                        ret
                        endp

print_hex_8             proc
                        push  af
                        rra
                        rra
                        rra
                        rra
                        call  print_hex_char
                        pop   af
                        call  print_hex_char
                        ret
                        endp

print_hex_char          proc
                        and   15
                        cp    10
                        sbc   a,#69
                        daa
                        rst   16
                        ret
                        endp


menu.txt                db    22, 2, 9
                        db    "Z80 Test Suite"
                        db    22, 7, 5
                        db    "1: Run Z80 Flags test"
                        db    22, 9, 5
                        db    "2: Run Z80 MEMPTR test"
                        db    22, 11, 5
                        db    "3: Exit to BASIC"

                        db    22, 15, 0
                        db    "All results are compared against", 13
                        db    "   a real NEC D780C-1 Z80 CPU"
                        db    255

press_key.txt           db    13
                        db    "All tests finished - press a key"
                        db    255

testing_flags.txt       db    "      Testing Z80 flags..."
                        db    13, 13
                        db    255
testing_memptr.txt      db    "      Testing Z80 MEMPTR..."
                        db    13, 13
                        db    255

passed.txt              db    "passed", 255
failed.txt              db    16, 2
                        db    "failed"
                        db    13, 6
                        db    " - expected "
                        db    255

testptr                 dw    0
stackptr                dw    0

skip_output             db    0

                        include tests.asm

                        end   start

