;; (c) Copyright Kevin Thacker 2015
;; This code is part of the Arnold emulator distribution.
;; This code is free to distribute without modification
;; this copyright header must be retained.
                    
storefirmreg:
						exx
						ld (firm_de_alt),de
						ld (firm_hl_alt),hl
						ld (firm_bc_alt),bc
						exx
						ex af,af'
						ld (firm_a_alt),a
						ex af,af'
						ret
						
restorefirmreg:
						exx
						ld de,(firm_de_alt)
						ld hl,(firm_hl_alt)
						ld bc,(firm_bc_alt)
						exx
						ex af,af'
						ld a,(firm_a_alt)
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
