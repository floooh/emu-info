;
;
;        LOGON SYSTEM 1991
;
;        WARNING !!! CE TEST ENCLENCHE LA ROM BASSE !!!
;        DONC EN SORTANT,IL FAUT LA DECLENCHER ET IL
;        FAUT ABSOLUMENT QUE CE TEST CE TROUVE EN MÉMOIRE
;        HAUTE > &8000 !!!! IMPERATIVEMENT (CPC+)
;        Poser EI RET en &0038 !!!
;
;        TEST CRTC V1.1 (13.04.1991) by LONGSHOT.
;        valeur en &BF00
;
;        0 - HD6845SP
;        1 - MOTOROLA 6845
;        2 - MOTOROLA 6845 S (REG2 49Max)
;        3 - ASIC (PLUS)
;        4 - GATE ARRAY (ERSATZ PLUS)
;
         ORG  &A000
SCREEN   EQU  &C000+12

         DI
         LD   BC,&7F10
         OUT  (C),C
         LD   A,84
         OUT  (C),A
         LD   C,0
         OUT  (C),C
         OUT  (C),A
         LD   A,75
         INC  C
         OUT  (C),C
         OUT  (C),A
         LD   HL,(&0038)
         LD   HL,&C9FB
         LD   (&0038),HL
;
         CALL TESTCRT
         LD   (&BF00),A                 ; SAUVE RESULTAT
;
         LD   BC,&7F8E                  ; DECONNECTE ROMS
         OUT  (C),C
         LD   BC,&BC0C
         OUT  (C),C
         LD   BC,&BD30
         OUT  (C),C
         LD   BC,&BC0D
         OUT  (C),C
         LD   BC,&BD00
         OUT  (C),C
         JP   CONTROL
;
TESTCRT:
         DI
         LD   E,17
         LD   HL,TABASIC
         LD   BC,&BC00
SASIC:
         LD   A,(HL)
         OUT  (C),A
         INC  HL
         DEC  E
         JR   NZ,SASIC
         LD   BC,&7FC0
         OUT  (C),C
         LD   HL,&4000
         LD   DE,&B8A0
         LD   A,123
         LD   (HL),A
         OUT  (C),D
         XOR  A
         LD   (HL),A
         OUT  (C),E
         LD   A,(HL)
         OR   A
         LD   A,3                       ; RETURN ASIC CRTC type 3
         RET  NZ
;
         LD   B,&F5                     ; Wait Sync
VS:
         IN   A,(C)
         RRA
         JP   NC,VS
VS1:
         IN   A,(C)                     ; Pre-Synchronisation 23.02.92
         RRA
         JP   C,VS1
VS2:
         IN   A,(C)
         RRA
         JP   NC,VS2
         EI                             ; Wait 1/300eme sec
         HALT
         LD   HL,75                     ; + 449 usec
WAIT:
         DEC  HL
         LD   A,H
         OR   L
         JP   NZ,WAIT
         IN   A,(C)                     ; Sync Valide ?
         RRA
         JP   C,TYPES12                 ; Non
;
;        Type 0 ou 4 ?
;
         LD   BC,&BC00+12
         OUT  (C),C
         LD   DE,&2829
         INC  B
         OUT  (C),E
         INC  B
         IN   A,(C)
         CP   E
         PUSH AF
         DEC  B
         OUT  (C),D
         POP  AF
         JR   NZ,TYPE0
         LD   A,4                       ; CRTC type 4
         RET
TYPE0:
         XOR  A                         ; CRTC type 0
         RET
TYPES12:
         HALT
         HALT
         HALT
         DI
VS3:
         IN   A,(C)
         RRA
         JP   NC,VS3
         LD   BC,&BC00+2                ; Overflow Reg 2
         OUT  (C),C
         LD   BC,&BD00+50
         OUT  (C),C
         EI
         HALT                           ; Wait Next Sync 6x1/300eme
         HALT
         HALT
         HALT
         HALT
         HALT
         HALT
         LD   B,&F5
         IN   A,(C)                     ; Sync Ok ?
         RRA
         LD   BC,&BD00+46
         OUT  (C),C
         JP   NC,TYPE2
         LD   A,1                       ; CRTC type 1
         RET
TYPE2:
         LD   A,2                       ; CRTC type 2
         RET
;
CONTROL:
         DI
         LD   HL,&C000
         LD   DE,&C001
         LD   BC,(&3FFF)
         LD   (HL),L
         LDIR
;
;
         LD   A,(&BF00)
         LD   L,A
         LD   H,0
         ADD  HL,HL
         ADD  HL,HL
         ADD  HL,HL
;
         LD   DE,TB0
         ADD  HL,DE
         PUSH HL
         POP  IX
;
         LD   HL,SCREEN
         LD   B,8
;
SPRIT0:   PUSH BC
         PUSH HL
         LD   A,(IX+0)
;
         LD   B,8
SPRIT1:
         RLA
         CALL C,AFFICH
         LD   DE,&0008
         ADD  HL,DE
         DJNZ SPRIT1
;
SPRIT2:   INC  IX
         POP  HL
         LD   DE,&00F0
         ADD  HL,DE
         POP  BC
         DJNZ SPRIT0
FIN:      JR   FIN
;
AFFICH:
         PUSH BC
         PUSH HL
         PUSH AF
         LD   A,&FF
         LD   B,24
AFFICH0:
         LD   (HL),A
         INC  HL
         LD   (HL),A
         INC  HL
         LD   (HL),A
         INC  HL
         LD   (HL),A
         INC  HL
         LD   (HL),A
         INC  HL
         LD   (HL),A
         INC  hl
         LD   (HL),A
         INC  HL
         LD   (HL),A
         INC  HL
;
         LD   DE,&07F8
         ADD  HL,DE
         JP   NC,AFFICH1
         LD   DE,&C050
         ADD  HL,DE
AFFICH1:
         DJNZ AFFICH0
         POP  AF
         POP  HL
         POP  BC
         RET
;
TB0:
         DEFB &7C,&C6,&CE,&D6
         DEFB &E6,&C6,&7C,&00
TB1:
         DEFB &18,&38,&18,&18
         DEFB &18,&18,&7E,&00
TB2:
         DEFB &3C,&66,&06,&3C
         DEFB &60,&66,&7E,&00
TB3:
         DEFB &3C,&66,&06,&1C
         DEFB &06,&66,&3C,&00
TB4:
         DEFB &1C,&3C,&6C,&CC
         DEFB &FE,&0C,&1E,&00
TB5:
         DEFB &7E,&62,&60,&7C
         DEFB &06,&66,&3C,&00
;
TABASIC:
         DEFB 255,0,255,119,179
         DEFB 81,168,212,98,57,156
         DEFB 70,43,21,138,205
         DEFB 238