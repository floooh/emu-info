;; This code is used in Batman Forever demo for the Amstrad CPC
;; to detect the amount of RAM available.

;; NOTES:
;; - more than 1 ram config value can be used to select the same 
;; ram page
;; - go through selections backwards and poke value into ram.
;; - where selection has value we poked, then it is valid.
;; this means it is not used by other configuration values

memcheck:
ld hl,&4000
ld b,&7f
ld c,&ff
memchk1:
bit 2,c
jr z,memchk2
;; first check this looks like valid ram
;; we write data and see if result comes back ok
ld a,c
call mem_check_bits_change
jr nz,memchk2
;; now we check if the config can be chosen
ld a,c
call mem_check_config_valid
jr nz,memchk2

;; select config
out (c),c
;; write config byte
ld (hl),c

memchk2:
dec c
ld a,c
cp &c0
jr nz,memchk1

;; at this point we have iterated backwards over all banks
;; and poked them with a byte which corresponds to the ram config
;; byte we used to activate them
;;
;; any mirrors will all have the same byte assigned and this will be of the lowest
;; config that activates them.
;;

;; now we go through and which which are unique by looking for a byte that
;; corresponds to the bank select
ld ix,mem_unique_configs

;; go through every config
ld c,&c0
muc2:
;; skip configs using 0,1,2,3 memory configuration
;; we need those using 4,5,6,7 memory configuration
bit 2,c
jr z,muc1

;; select config
out (c),c
;; read from ram; byte should be same as config
;; if this ram is unique and not a mirror
ld a,(hl)
cp c
jr nz,muc1

;; store this config in list
ld (ix+0),c
inc ix

muc1:
;; increment for next config
inc c
jr nz,muc2

;; indicates end of configs
ld (ix+0),&c0

defb &dd
ld a,h
sub mem_unique_configs/256
defb &dd
ld a,l
sbc a,mem_unique_configs and 255

ld ix,mem_unique_configs
;; A = number of unique configs which are useable
;; IX = list of unique configs
;;

ret

;; this will return true if the first 4 banks are continuous so they can be used
;; in the demo just by using a single config byte and offset. 
;; 
;; needs to check against invalid
;;
;; returns zero false if blocks are not contiguous
;; returns zero true if they are contiguous
;;
;; A = first block to use

mem_check_contig_64_blocks:
ld ix,mem_unique_configs
;; get initial config (e.g. c4)
ld a,(ix+0)
;; increment it
inc a
;; compare against next
cp (ix+1)
ret nz
inc a
cp (ix+2)
ret nz
inc a
cp (ix+3)
ld a,(ix+0)
ret



;; HL = memory location to write to
;; A = config
;; A,C corrupted on exit
;; zero = config valid, non zero = invalid
mem_check_config_valid:
push bc
;; bank visible between &4000-&7fff
;; base ram
ld bc,&7fc0
out (c),c
;; poke byte
ld (hl),&aa
;; swap to bank
out (c),a
;; poke a different byte
ld (hl),&55
;; bank to base ram
out (c),c
;; check it didn't change
ld a,(hl)
cp &aa
pop bc
ret


;; check this is valid memory
;; HL = memory location to write to
;; A = config
;; zero = valid memory, non zero = invalid
;; A corrupt
mem_check_bits_change:
out (c),a

ld (hl),&aa
ld a,(hl)
cp &aa
ret nz
ld (hl),&55
ld a,(hl)
cp &55
ret


mem_unique_configs:
defs 32+1

;;end start