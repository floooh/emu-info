
start                   equ   16384
                        org   start
;; some tests rely on the 48K ROM
spec48k_rom:
                        incbin "48.rom"

						
						org 32768
                        jp    cpc_main
                        
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
; ==============================================================
; cpc version follows.
cpc_main                    call  cpc_CLS

						xor a
						ld (cpc_cur_output_type),a
						
                        ld    de,cpc_menu.txt
                        call  cpc_print_string
						
						call cpc_show_output_type
						
cpc_wait_key                call  cpc_Get_Key
                        cp    "1"
                        jr    z,cpc_Run_Z80_Flags

                        cp    "2"
                        jr    z,cpc_Run_Z80_MEMPTR

                        cp    "3"
                        jr    z,cpc_update_output
						
						cp 		"4"
						ret nz
						;; return to basic
						rst 0
						
				   
cpc_update_output				proc
						ld a,(cpc_output_type)
						inc a
						and &1
						ld (cpc_output_type),a
						
						jr cpc_main
						endp
						
cpc_show_output_type				proc
						ld a,(cpc_output_type)
						ld de,cpc_output_screen.txt
						or a
						jr z,cpc_update_output2
						ld de,cpc_output_printer.txt
cpc_update_output2
						call cpc_print_string
						ret
						endp

cpc_Run_Z80_Flags           
						ld a,(cpc_output_type)
						ld (cpc_cur_output_type),a
						ld    hl,z80_flags_table
                        ld    de,cpc_testing_flags.txt
                        jr    cpc_run_tests

cpc_Run_Z80_MEMPTR          
						ld a,(cpc_output_type)
						ld (cpc_cur_output_type),a

						ld    hl,z80_memptr_table
                        ld    de,cpc_testing_memptr.txt
                        jr    cpc_run_tests

cpc_test_finished           xor a
						ld (cpc_cur_output_type),a
						ld    de,cpc_press_key.txt
                        call  cpc_print_string
                        call  cpc_Get_Key
                        jr    cpc_main


cpc_run_tests               ld    (testptr),hl

                        push  de
                        call  cpc_CLS
                        pop   de
                        call  cpc_print_string

cpc_testloop                ld    (stackptr),sp

                 ;;       ld    a,7
                   ;;     out   (254),a

                        ld    hl,(testptr)
                        ld    e,(hl)
                        inc   hl
                        ld    d,(hl)
                        inc   hl

                        ex    de,hl

                        ld    a,h
                        or    l
                        jr    z,cpc_test_finished

                        call  cpc_print_string

                        ld a," "
                        call  cpc_out_char
						
						ld a,23
						call cpc_tab
						
                        ld    a,":"
                        call  cpc_out_char	;;rst   16
                        ld    a," "
                        call  cpc_out_char	;;rst   16

                        ld    (testptr),de

                        ld    bc, cpc_test_passed
                        push  bc
                        ld    bc, cpc_test_failed
                        push  bc
                        
                        di
                        call storefirm
                        jp    (hl)

cpc_next_test               ld    sp,(stackptr)
						
						call cpc_new_line
                        jr     cpc_testloop

cpc_new_line:
                        ld    a,13
                        call  cpc_out_char	
                        ld    a,10
                        call  cpc_out_char	
						
						ld a,1
						ld (cpc_char_pos),a
						
						ld a,(cpc_char_line)
						inc a
						ld (cpc_char_line),a
						cp 24
						ret nz
						
						;; reset char line
						ld a,1
						ld (cpc_char_line),a
						
						;; screen?
						ld a,(cpc_cur_output_type)
						or a
						ret nz
						call cpc_Get_Key
						ret
						
cpc_tab:				ld a,(cpc_char_pos)
						cp 23
						ret nc
						sub 23
						neg
						ld b,a
cpc_tab2:
						ld a," "
						call cpc_out_char
						djnz cpc_tab2
						ret
						
cpc_test_passed            
						ld    de, cpc_passed.txt
                        call   cpc_test_result
                        jr     cpc_next_test

cpc_test_failed             
						ld    de, cpc_failed.txt
                        call   cpc_test_result
                        ld    h,b
                        ld    l,c
                        call   cpc_print_hex_16
							
                                         ;;       ld    a,16
				;;		call out_char	;;rst   16
                  ;;      xor   a
                    ;;    call out_char	;;rst   16
                        jr    cpc_next_test


cpc_test_result             ;;ld    iy,23610				;; ERR NO
                        call   cpc_print_string
                        ret
						
cpc_out_char				push af
						ld a,(cpc_char_pos)
						inc a
						ld (cpc_char_pos),a

						ld a,(cpc_cur_output_type)
						or a
						jr z, cpc_out_screen
						jr cpc_out_printer
						
cpc_out_screen						
						pop af
						jp &bb5a
cpc_out_printer						
						pop af
						jp &bd2b
						
						
cpc_CLS                     proc
						ld a,1
						ld (cpc_char_line),a
						ld (cpc_char_pos),a
						ld a,1
						jp &bc0e
;;                        call  3435
  ;;                      ld    a,2
    ;;                    jp    #1601
                        endp

						
						
cpc_Get_Key                 proc
						jp &bb06
                        endp

cpc_print_string            proc
_loop_cpc                   ld    a,(de)
                        inc   de
                        cp    255
                        ret   z
						call cpc_out_char
                                                ;;rst   16
                        jr    _loop_cpc
                        endp

cpc_print_hex_16            proc
                        ld    a,h
                        call  cpc_print_hex_8
                        ld    a,l
                        call  cpc_print_hex_8
                        ret
                        endp

cpc_print_hex_8             proc
                        push  af
                        rra
                        rra
                        rra
                        rra
                        call  cpc_print_hex_char
                        pop   af
                        call  cpc_print_hex_char
                        ret
                        endp

cpc_print_hex_char          proc
                        and   15
                        cp    10
                        sbc   a,#69
                        daa
                       ;; rst   16
                       call cpc_out_char 
                       ret
                        endp


cpc_menu.txt            db    15, 1
						db 31, 9,2
                        db    "Z80 Test Suite"
                        db    31, 5,7
                        db    "1: Run Z80 Flags test"
                        db    31, 5, 9
                        db    "2: Run Z80 MEMPTR test"
                        db	  31, 5, 11
                        db    "3: Output to: "
                        db    31, 5, 13
                        db    "4: Exit to BASIC"

                        db    31, 1, 15
                        db    "All results are compared against", 13,10
                        db    "   a real NEC D780C-1 Z80 CPU"
                        db    255

cpc_press_key.txt           db    13,10
                        db    "All tests finished - press a key"
                        db    255

cpc_testing_flags.txt       db    "      Testing Z80 flags..."
                        db    13,10, 13,10
                        db    255
cpc_testing_memptr.txt      db    "      Testing Z80 MEMPTR..."
                        db    13,10, 13,10
                        db    255

						
cpc_passed.txt              db    "passed", 255
cpc_failed.txt              db    15,2	;;16, 2
                        db    "failed"
                        db    13, 10	;;, 6
                        db    " - expected "
                        db    15,1, 255

;; cpc extras; must be here, because address of some tests are important!
cpc_cur_output_type			db    0
cpc_output_type				db 	  0
cpc_char_line				db    0
cpc_char_pos				db    0

cpc_output_printer.txt	db	  31, 19, 11,"Printer", 255
cpc_output_screen.txt	db	  31, 19, 11,"Screen ", 255                        

                        
storefirm:
					;;	ld (firm_ix),ix
					;;	ld (firm_iy),iy
					;;	ld (firm_de),de
					;;	ld (firm_hl),hl
					;;	ld (firm_bc),bc
					;;	push hl
					;;	push af
					;;	pop hl
					;;	ld (firm_af),hl
					;;	pop hl						
						exx
						ld (firm_de_alt),de
						ld (firm_hl_alt),hl
						ld (firm_bc_alt),bc
						exx
						ex af,af'
					;;	push hl
					;;	push af
					;;	pop hl
						ld (firm_a_alt),a
					;;pop hl
						ex af,af'
						
						push hl
						push de
						push bc
						ld hl,specromstore
						ld de,&0000
						ld bc,&40

						ldir
						ld hl,specromstore2
						ld de,&1800
						ld bc,&1100
						ldir
						pop bc
						pop de
						pop hl
						ret
						
restore_firm:
						push hl
						push de
						push bc
						ld hl,firm_store
						ld de,&0000
						ld bc,&40
						ldir
						pop bc
						pop de
						pop hl


					;;	ld ix,(firm_ix)
					;;	ld iy,(firm_iy)
					;;	ld de,(firm_de)
					;;	ld hl,(firm_hl)
					;;	ld bc,(firm_bc)
					;;	push hl
					;;	ld hl,(firm_af)
					;;	push hl
					;;	pop af
					;;	pop hl
						exx
						ld de,(firm_de_alt)
						ld hl,(firm_hl_alt)
						ld bc,(firm_bc_alt)
						exx
						ex af,af'
						ld a,(firm_a_alt)
					;;	push hl
					;;	ld hl,(firm_af_alt)
					;;	push hl
					;;	pop af
					;;	pop hl
						ex af,af'
						ret
												
firm_af:
defw 0					
firm_de:
defw 0
firm_bc:
defw 0
firm_hl:
defw 0						
firm_ix:
defw 0
firm_iy:
defw 0					
firm_de_alt:
defw 0					
firm_hl_alt:
defw 0
firm_bc_alt:
defw 0	
firm_a_alt:
defb 0

start2:
                      
scr_set_base equ &bc08

;; cpc screen at &4000-&8000  
ld a,&40
call scr_set_base

ld hl,&0000
ld de,firm_store
ld bc,&40
ldir

ld hl,spec48k_rom+&40
ld de,&40
ld bc,&4000-&40
ldir

ld hl,spec48k_rom
ld de,specromstore
ld bc,&40
ldir

ld hl,spec48k_rom+&1800
ld de,specromstore2
ld bc,&1100
ldir

    
;; setup same as spectrum rom
ld a,63
ld i,a    
jp 32768                     

firm_store:
defs 64

specromstore:
defs 64

specromstore2:
defs &1100

end   start2

