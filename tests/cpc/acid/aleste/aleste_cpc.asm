;; aleste 520 ex cpc colours
;;
;; NEEDS TESTING ON A REAL MACHINE


org &8000

start:
di
ld hl,&c9fb
ld (&0038),hl
ei

;; disable map mod
ld a,%00000000
ld bc,&fabf
out (c),a

ld bc,&7f00
out (c),c
xor a
colours:
and &3f		;; [2]
or &40		;; [2]	
out (c),a	;; [4]	
defs 64-4-2-2-1-3
inc a		;; [1]
jp colours	;; [3]


end start