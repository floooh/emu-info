;

; Détection CRTC. Madram pour
; AMSTRAD LIVE. 05/2000
;
ORG #A000
;
CALL TEST1
CALL TEST2
CALL TEST3
;
; un test de moins ne permettrait pas de
; conclure
;
CALL CONCLUT
OR   #30     ; Conversion chiffre ->
             ; code ASCII
JP   #BB5A

TEST1:
;
; Idée communiquée par Candy. Pas très
; rigoureux :) mais ça marche
;
LD    BC,#7F54          ; Je ne précise
                        ; pas le stylo,
                        ; peu importe.
OUT   (C),C
IN    A,(C)             ; En réalité on
                        ; ne lit rien
CP    C                 ; Mon instruction
                        ; préférée
LD    B,%011111         ; Type emulateur
JR    Z,SET_BITS        ; De mauvais
                        ; émulateurs autorisent la lecture du GA
INC   A                 ; Si 255 -> CPC normal
LD    B,%001000         ; Tout CPC sauf +
JR    Z,SET_BITS
LD     B,%110111        ; CPC PLUS
JR    SET_BITS
;
;
TEST2:
;
; On lit port #BExx
;
LD    BC,#BC0C        ; On s'assure de
                      ; l'offset (du poids
                      ; fort du moins)
OUT   (C),C           ; car le CPC + renverra
                      ; cette valeur.
LD    BC,#BD30
OUT   (C),C
INC   B
IN    A,(C)
CP    C
LD    B,%100111       ; CPC PLUS ou type 4
JR    Z,SET_BITS
INC   A               ; #ff?
LD    B,%111010       ; Si oui->CRTC 0 ou 2
JR    Z,SET_BITS
AND   #df             ; On écarte le bit 6 qui
                      ; peut varier,
CP    #41             ; et on doit obtenir #40
                      ; sur CRTC 1
LD    B,%111101
JR    Z,SET_BITS
LD B,%011111
JR    SET_BITS
;
;
TEST3:
;
;On lit le port #BFxx
;
LD    BC,#BC0C         ; On s'assure de l'offset
OUT   (C),C            ; Je sais, on l'a déjà fait,
                       ; mais c'est plus propre :
LD    BC,#BD30         ; les tests sont
                       ; ainsi autonomes
OUT   (C),C                    
SET   1,B              ; Spéciale décicace à Shap
IN    A,(C)
CP    C                ; Si on relit la valeur ->
                       ; CRTC 0, 3, ou 4
LD    B,%100110
JR    Z,SET_BITS
OR    A                ; Si 0 -> CRTC 1 ou 2
LD    B,%111001
JR    Z,SET_BITS
LD    B,%011111       ; C'est pas un CPC
                      ; normal !
JR    SET_BITS
;
;
;
SET_BITS:
;Mise à 1 des bits -> c'est un OR !
LD    A, (CRTC)
OR    B
LD    (CRTC),A
RET
;
;
CONCLUT:
;
; En sortie, A contient le type (5 pour un émulateur)
;
LD    A,(CRTC)
LD    BC,#500            ; B compteur, C
; numéro du type
;
CON_LP:
RRA
JR     NC,CON_LP2
INC   C
DJNZ  CON_LP
;
; Les 5 premiers bits sont à 1. Peu importe si
; le dernier est à 1 ou pas :
; dans les 2 cas on a affaire à un émulateur
;
LD    A,C
RET
CON_LP2: ; On vérifie qu'il n'y a pas d'autre
        ; bit à 0
RRA
JR     NC,CON_NOK
DJNZ  CON_LP2
LD     A,C
RET
;
CON_NOK: LD     A, 5
RET
;
;
CRTC:     DEFB 0
