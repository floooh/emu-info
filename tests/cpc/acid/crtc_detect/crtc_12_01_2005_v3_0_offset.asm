; Test CRTC version 3.0
; (12/01/2005) par OffseT (Futurs')


; Réalisé entièrement sur un véritable CPC
; Plus aucun registre du CRTC n'est modifé durant les tests !
 
; L'historique...
 
; Test CRTC version 1.1
;   - Test originel (23.02.1992) par Longshot (Logon System)
;   ce test CRTC est celui crée par Longhost et utilisé dans la
;   plupart des démos du Logon System.
 
; Test CRTC version 1.2
;   - Amélioration de la détection Asic (02/08/1993) par OffseT
;   le test basé sur la détection de la page I/O Asic qui
;   imposait de délocker l'Asic a été remplacé par un test
;   des vecteurs d'interruption (mode IM 2). Le délockage de
;   l'Asic n'est plus nécessaire.
;   bug connu ; ce test ne fonctionne pas nécessairement sur un
;   CPC customisé (notamment avec une interface gérant les
;   interruptions en mode vectorisé) ou sur un CPC+ dont le registre
;   Asic IVR a préalablement été modifié.
;   - Correction du bug de détection CRTC 1 (18/06/1996) par OffseT
;   sous certaines conditions de lancement le CRTC 1 était détecté
;   comme étant un CRTC 0 (on peut constater ce bug dans The Demo
;   et S&KOH). La méthode de synchronisation pour le test de détection
;   VBL a été fiabilisée et ce problème ne devrait plus survenir.
 
; - Test CRTC version 2.0
;   - Ajout d'un test émulateur (03/01/1997) par OffseT
;   ce test est basé sur la détection d'une VBL médiane lors de
;   l'activation du mode entrelacé. Les émulateurs n'émulent pas
;   cette VBL.
;   limitation systématique ; ce test ne permet pas de distinguer
;   un véritable CRTC 2 d'un CRTC 2 émulé.
 
; - Test CRTC version 3.0
;   - Retrait du test émulateur (20/12/2004) par OffseT
;   ce test ne représente aucun intéret réel et a le désavantage
;   de provoquer une VBL parasite pendant une frame.
;   - Remplacement du test Asic (29/12/2004) par OffseT
;   le nouveau test est basé sur la détection du bug de validation
;   dans le PPI émulé par l'Asic plutôt que sur les interruptions
;   en mode IM 2. C'est beaucoup plus fiable puisque ça ne dépend
;   plus du tout de l'état du registre IVR ni des extensions gérant
;   les interruptions connectées sur le CPC. Merci à Ram7 pour  l'astuce.
;   Limitation systématique ; l'état courant de configuration des ports
;   du PPI est perdue, mais ça ne pose normalement aucun problème.
;   - Remplacement du test CRTC 1 et 2 (29/12/2004) par OffseT
;   le test originel de Longshot était basé sur l'inhibition de
;   la VBL sur type 2 lorsque Reg2+Reg3>Reg0+1. Ce test modifiait
;   les réglages CRTC et l'écran sautait pendant une frame. Il a été
;   remplacé par un test basé sur la détection du balayage du border
;   spécifique au type 1 qui n'a pas ces inconvénients.
;   bug connu (rarissime) ; ce test renvoie un résultat erroné sur
;   CRTC 1 si reg6=0 ou reg6>reg4+1... ce qui est fort improbable.
;   - Modification du test CRTC 3 et 4 (29/12/2004) par OffseT
;   le test ne modifie plus la valeur du registre 12. Toutefois
;   il en teste la cohérence et vérifie également le registre 13.
;   limitation (rare) ; ce test ne fonctionne pas si reg12=reg13=0.
;   - Réorganisation générale des tests (29/12/2004) par OffseT
;   chaque test est désormais un module qui permet, par le biais
;   d'un système de masques de tests, de différencier les CRTC au
;   fur et à mesure.
;   - Retrait des dépendances d'interruption (29/12/2004) par OffseT
;   plus aucun test ne fait usage des interruptions pour se synchroniser.
;   - Ajout d'un test de lecture du port &BFxx (29/12/2004) par OffseT
;   ce test permet de différencier les CRTC 1 et 2 des autres et vient
;   en complément du test (historique) sur le timing VBL.
;   limitation (rare) ; ce test ne fonctionne pas si reg12=re13=0.
;   - Ajout d'un test de lecture des registres 4 et 5 (30/12/2004) par OffseT
;   ce test donne théoriquement les mêmes résultats que le test
;   initial de détection 3 et 4 basé sur des lectures sur le port
;   &BExx ; il consiste à lire les registres 12 et 13 via leur miroir
;   sur l'adressage des registres 4 et 5 sur type 3 et 4.
;   limitation (rare) ; ce test ne fonctionne pas si reg12=reg13=0.
;   - Ajout d'un test de lectures CRTC illégales (12/01/2005) par OffseT
;   ce test vérifie qu'on obtient bien la valeur 0 en retour
;   lors d'une tentative de lecture illégale d'un registre du
;   CRTC en écriture seule. Ceci permet de différencier les types
;   0, 1 et 2 des types 3 et 4.
;   - Ajout d'un test du port B du PPI (12/01/2005) par OffseT
;   ce test vérifie si le port B peut-etre configuré en sortie.
;   Ceci permet d'identifier le type 3.
;   Limitation systématique ; l'état courant de configuration des ports
;   du PPI est perdue, mais ça ne pose normalement aucun problème.
;   - Ajout d'un test de détection de fin de VBL (12/01/2005) par OffseT
;   ce test vérifie que le bit 5 du registre 10 du CRTC permet bien
;   de détecter la dernière ligne de VBL sur les CRTC 3 et 4. Ceci
;   permet de différencier les types 0, 1 et 2 des types 3 et 4.
;   bug systématique ; si le bit 7 du registre 3 est à zéro (double VBL)
;   le test renvoie un mauvais résultat.
;   - Ajout d'un test de lecture du registre 31 (12/01/2005) par OffseT
;   ce test vérifie sur la valeur en lecture renvoyée pour ce registre
;   est non nulle. Si c'est le cas ça veut dire qu'on a lu soit un état
;   de haute impédance (cas du type 1) soit le registre 15 qui était non
;   nul (cas des types 3 et 4). On peut alors conclure que l'on a ni un
;   type 0, ni un type 2. Si la valeur est nulle on ne peut rien conclure
;   et le test est inopérant. 
;   limitation rarissime ; ce test ne fournit pas de résultat sur type 1
;   si l'état de haute impédance est altéré
;   limitation courante ; ce test ne fournit pas de résultat sur types 3 et 4
;   si le registre 15 est nul (ce qui est la valeur par défaut)
;   - Ajout d'un test de détection des blocs 0 et 1 (12/01/2005) par OffseT
;   ce test vérifie que la détection des blocs 0 et 1 est fonctionnelle
;   sur les types 3 et 4 à l'aide des flags du registre 11 du CRTC. Ceci
;   permet de différencier les types 0,1,2 des 3,4.
;   limitation systématique ; le registre 9 doit valoir 7 sinon le
;   résultat est faux.
 
; Note ; une limitation décrit un cas dans lequel le test ne renvoie
; aucun résultat (il ne parvient pas à distinguer les CRTC) alors qu'un
; bug connu décrit un cas dans lequel le test peut renvoyer une mauvaise
; réponse (ce qui est beaucoup plus grave !).
 
; Les différents types de CRTC connus...
 
; 0 ; 6845SP                ; sur la plupart des CPC6128 sortis entre 85 et 87
; 1 ; 6845R                 ; sur la plupart des CPC6128 sortis entre 88 et 89
; 2 ; 6845S                 ; sur la plupart des CPC464 et CPC664
; 3 ; Emulé (CPC+)          ; sur les 464 plus et 6128 plus
; 4 ; Emulé (CPC old)       ; sur la plupart des CPC6128 sortis en 89 et 90.
 
 
; Le programme qui utilise le test CRTC...
 
        Org &9000
 start:
        call testcrtc   ; On lance le test CRTC !
 
        add a,48        ; On affiche le type de CRTC
        call &bb5a
		call &bb06
        ret             ; On rend la main
 
; Le test CRTC...
 
; Attention ! Le CRTC doit être dans une configuration
; rationnelle pour que les tests fonctionnent (VBL et
; HBL présentes, registres 6 et 1 non nuls, bit 7 du
; registre 3 non nul, etc.)
 
; En sortie A contient le type de CRTC (0 à 4)
; A peut valoir &F si le CRTC n'est pas reconnu
; (mauvais émulateur CPC ou mauvaise configuration
; CRTC au lancement du test)
 
testcrtc:
        ld a,&ff
        ld (typecrtc),a
        di                      ; CRTC 0,1,2,3,4
        call testlongueurvbl    ;      0,1,1,0,0
        call testbfxx           ;      0,1,1,0,0,alien
        call testbexx           ;      0,0,0,1,1,alien
        call testfinvbl         ;      0,0,0,1,1,alien
        call testr4r5           ;      0,0,0,1,1,alien
        call testregswo         ;      0,0,0,1,1
        call testbloc           ;      0,0,0,1,1,alien
        call testborder         ;      0,1,0,0,0
        call testrazppi         ;      0,0,0,1,0,alien
        call testportbppi       ;      0,0,0,1,0
        call testreg31          ;      x,1,x,1,1
        ei
        ld a,(typecrtc)
        cp crtc0
		jr z,type_0
        cp crtc1
		jr z,type_1
        cp crtc2
		jr z,type_2
        cp crtc3
		jr z,type_3
        cp crtc4
		jr z,type_4
        ld a,&f
		ret
type_0:  ld a,0
		ret
type_1:  ld a,1
		ret
type_2:  ld a,2	
		ret
type_3:  ld a,3
		ret
type_4:  ld a,4
		ret
 
 
; Test basé sur la mesure de la longueur de VBL
; Permet de différencier les types 1,2 des 0,3,4
 
; Bug systématique
;   si le bit 7 du registre 3 est à zéro (double VBL)
;   le test renvoie un mauvais résultat
 
testlongueurvbl:
        ld b,&f5        ; Boucle d'attente de la VBL
synctlv1:
        in a,(c)
        rra
        jr nc,synctlv1
nosynctlv1:
        in a,(c)        ; Pre-Synchronisation
        rra             ; Attente de la fin de la VBL
        jr c,nosynctlv1
synctlv2:
        in a,(c)        ; Deuxième boucle d'attente
        rra             ; de la VBL
        jr nc,synctlv2
 
        ld hl,140       ; Boucle d'attente de
waittlv: dec hl          ; 983 micro-secondes
        ld a,h
        or l
        jr nz,waittlv
        in a,(c)        ; Test de la VBL
        rra             ; Si elle est encore en cours
        jp c,type12     ; on a un type 1,2...
        jp type034      ; Sinon on a un type 0,3,4
 
 
; Test basé sur la lecture des registres 12 et 13
; sur le port &BFxx
; Permet de différencier les types 0,3,4 et 1,2
 
; Limitation rare
;   si reg12=reg13=0 le test est sans effet
 
testbfxx:
        ld bc,&bc0c     ; On sélectionne le reg12
        out (c),c
        ld b,&bf        ; On lit sa valeur
        in a,(c)
        ld c,a          ; si les bits 6 ou 7 sont
        and &3f         ; non nuls alors on a un
        cp c            ; problème
        jp nz,typealien
        ld a,c
        or a            ; si la valeur est non nulle
        jp nz,type034   ; alors on a un type 0,3,4
        ld bc,&bc0d
        out (c),c       ; On sélectionne le reg13
        ld b,&bf
        in a,(c)        ; On lit sa valeur
        or a            ; Si la valeur est non nulle
        jp nz,type034   ; alors on a un type 0,3,4
        ret
 
 
; Test basé sur la lecture des registres 12 et 13
; à la fois sur les ports &BExx et &BFxx
; Permet de différencier les types 0,1,2 des 3,4
 
; Limitation rare
;   si reg12=reg13=0 le test est sans effet
 
testbexx:
        ld bc,&bc0c     ; On sélectionne le registre 12
        out (c),c       ; On compare les valeurs sur
        call cpbebf     ; les ports &BExx et &BFxx
        push af         ; (on sauve les flags)
        ld b,a          ; Si le bit 6 ou 7 de la valeur
        and &3f         ; lue pour &BFxx est non nul
        cp b            ; alors on a un problème
        call nz,typealien
        pop af          ; (on récupère les flags)
        jp nz,type012   ; Si elles sont différentes
        xor a           ; on a un type 0,1,2
        cp c            ; Si elles sont égales et
        jp nz,type34    ; non nulles on a un type 3,4
        ld bc,&bc0d     ; On sélectionne le registre 13
        out (c),c       ; On compare les valeurs sur
        call cpbebf     ; les ports &BExx et &BFxx
        jp nz,type012   ; Si elles sont différentes
        xor a           ; on a un type 0,1,2
        cp c            ; Si elles sont égales et
        jp nz,type34    ; non nulles on a un type 3,4
        ret
 
cpbebf:  ld b,&be        ; On lit la valeur sur &BExx
        in a,(c)
        ld c,a          ; On la stocke dans C
        inc b
        in a,(c)        ; On lit la valeur sur &BFxx
        cp c            ; On la compare à C
        ret
 
 
; Test basé sur la RAZ du PPI
; Permet de différencier les types 0,1,2,4 du 3
 
; Limitation systématique
;   l'état courant de configuration des ports
;   du PPI est perdu
 
testrazppi:
        ld bc,&f782     ; On configure le port C
        out (c),c       ; en sortie
        dec b
        ld c,&f         ; On place une valeur sur
        out (c),c       ; le port C du PPI
        in a,(c)        ; On vérifie si la valeur est
        cp c            ; toujours là en retour
        jp nz,typealien ; sinon on a un problème
        inc b
        ld a,&82        ; On configure de nouveau
        out (c),a       ; le mode de fonctionnement
        dec b           ; des ports PPI
        in a,(c)        ; On teste si la valeur placée
        cp c            ; sur le port C est toujours là
        jp z,type3      ; Si oui on a un type 3
        or a            ; Si elle a été remise à zéro
        jp z,type0124   ; on a un type 0,1,2,4
        jp typealien    ; Sinon on a un problème
 
 
; Test basé sur la détection du balayage des lignes
; hors border
; Permet d'identifier le type 1
 
; Bug connu rarissime
;   si reg6=0 ou reg6>reg4+1 alors le test est faussé !
 
testborder:
        ld b,&f5
nosynctdb1:
        in a,(c)        ; On attend un peu pour être
        rra             ; sur d'être sortis de la VBL
        jr c,nosynctdb1 ; en cours du test précédent
synctdb1:
        in a,(c)        ; On attend le début d'une
        rra             ; nouvelle VBL
        jr nc,synctdb1
nosynctdb2:
        in a,(c)        ; On attend la fin de la VBL
        rra
        jr c,nosynctdb2
 
        ld ix,0         ; On met à zéro les compteurs
        ld hl,0         ; de changement de valeur (IX),
        ld d,l          ; de ligne hors VBL (HL) et
        ld e,d          ; de ligne hors border (DE)
        ld b,&be
        in a,(c)
        and 32
        ld c,a
 
synctdb2:
        inc de          ; On attend la VBL suivante
        ld b,&be        ; en mettant à jour les divers
        in a,(c)        ; compteurs
        and 32
        jr nz,border
        inc hl          ; Ligne de paper !
        jr noborder
border:  ds 4
noborder:
        cp c
        jr z,nochange
        inc ix          ; Transition paper/border !
        jr change
nochange:
        ds 5
change:  ld c,a
 
        ds 27
 
        ld b,&f5
        in a,(c)
        rra
        jr nc,synctdb2  ; On boucle en attendant la VBL
 
        db &dd
		ld a,l   ; Si on n'a pas eu juste deux
        cp 2            ; transitions alors ce n'est
        jp nz,type0234  ; pas un type 1
        jp type1        ; Pour plus de fiabilité au
                        ; regard de l'état de haute
                        ; impédance sur les CRTC autres
                        ; que le type 1 on pourrait
                        ; vérifier ici que HL vaut
                        ; reg6*(reg9+1) mais ça impose
                        ; de connaitre au préalable la
                        ; valeur de ces deux registres
 
 
; Test basé sur la lecture des registres 4 et 5
; Permet de différencier les types 0,1,2 des 3,4
 
; Limitation rare
;   si reg12=reg13=0 le test est sans effet
 
testr4r5:
        ld bc,&bc0c     ; On sélectionne le registre 12
        out (c),c       ; On compare les valeurs en
        call cprhrl     ; retour sur le port &BFxx
        push af         ; On sauve les flags
        ld b,a          ; Si le bit 6 ou 7 de la valeur
        and &3f         ; lue pour &BFxx est non nul
        cp b            ; alors on a un problème
        call nz,typealien
        pop af          ; On récupère les flags
        jp nz,type012   ; Si elles sont différentes
        xor a           ; on a un type 0,1,2
        cp c            ; Si elles sont égales et
        jp nz,type34    ; non nulles on a un type 3,4
        ld bc,&bc0d     ; On sélectionne le registre 13
        out (c),c       ; On compare les valeurs en
        call cprhrl     ; retour sur le port &BFxx
        jp nz,type012   ; Si elles sont différentes
        xor a           ; on a un type 0,1,2
        cp c            ; Si elles sont égales et
        jp nz,type34    ; non nulles on a un type 3,4
        ret
 
cprhrl:  ld b,&bf        ; On lit la valeur du registre
        in a,(c)        ; High sur &BFxx
        ld b,&bc        ; Sélection du registre Low
        res 3,c         ; On passe sur le registre Low
        out (c),c
        ld c,a          ; On la stocke dans C
        ld b,&bf
        in a,(c)        ; On lit la valeur sur &BFxx
        cp c            ; On la compare à C
        ret
 
 
; Test basé sur la valeur de retour sur les registres
; CRTC en écriture seule
; Permet de différencier les types 0,1,2 des types 3,4
 
; Aucune limitation/bug connus
 
testregswo:
        ld de,0         ; On lance le parcours des
        ld c,12         ; registres 0 à 11 avec
        call cumulereg  ; cumul de la valeur retour
        xor a           ; Si le résultat cumulé de
        cp d            ; la lecture est non nul
        jp nz,type34    ; alors on a un type 3,4
        jp type012      ; Sinon, c'est un type 0,1,2
cumulereg:
looptri: ld b,&bc        ; On sélectionne le
        out (c),e       ; registre "E"
        ld b,&bf        ; On lit la valeur
        in a,(c)        ; renvoyée en retour
        or d            ; On la cumule dans D avec
        ld d,a          ; les lectures précédentes
        inc e           ; On boucle jusqu'au
        ld a,e          ; registre "C"
        cp c
        jr nz,looptri
        ret
 
 
; Test basé sur la possibilité de programmer le port B
; en sortie
; Permet d'identifier le type 3
 
; Limitation systématique
;   l'état courant de configuration des ports
;   du PPI est perdu
 
testportbppi:
        ld b,&f5
synctpbp1:
        in a,(c)
        rra
        jr nc,synctpbp1
nosynctpbp1:
        in a,(c)        ; Pre-Synchronisation
        rra             ; Attente de la fin de la VBL
        jr c,nosynctpbp1
        ld bc,&f782     ; On configure le port B
        out (c),c       ; du PPI en entrée
        ld b,&f5        ; On lit la valeur présente
        in a,(c)        ; sur le port B puis on
        xor 254         ; la modifie judicieusement
        ld e,a          ; et on la stocke dans E
        ld d,&f5
        ld bc,&f780     ; On configure le port B
        out (c),c       ; du PPI en sortie
        ld b,d          ; On y envoie la valeur
        out (c),e       ; stockée dans E
        in a,(c)        ; On relit le port B
        ld bc,&f782     ; On reconfigure le port B
        out (c),c       ; du PPI en entrée
        cp e            ; Si la valeur E a été lue
        jp z,type0124   ; alors on a type 0,1,2,4
        jp type3        ; Sinon on a un type 3
 
 
; Test basé sur la détection de la dernière
; ligne de VBL
; Permet de différencier les types 0,1,2 des 3,4
 
; Bug systématique
;   si le bit 7 du registre 3 est à zéro (double VBL)
;   le test renvoie un mauvais résultat)
 
testfinvbl:
        ld bc,&bc0a     ; On sélectionne le
        out (c),c       ; registre 10 du CRTC
        ld b,&f5
nosynctfv1:
        in a,(c)        ; Pre-Synchronisation
        rra             ; Attente de la fin de la VBL
        jr c,nosynctfv1
 
        ld b,&bf        ; On lit l'état du registre 10
        in a,(c)
        and 32          ; Si le bit5 est nul alors
        jp z,type012    ; on a un type 0, 1 ou 2
 
        ld b,&f5
synctfv2:
        in a,(c)        ; Boucle d'attente de la VBL
        rra
        jr nc,synctfv2
 
        ld hl,55        ; Boucle d'attente de
waittfv: dec hl          ; 388 micro-secondes
        ld a,h
        or l
        jr nz,waittfv
 
        ld b,&bf        ; On lit l'état du registre 10
        in a,(c)
        and 32          ; Si le bit5 est nul
        jp z,typealien  ; on a un problème
 
        ld b,13         ; Boucle d'attente de
        djnz $          ; 54 micro-secondes
 
        ld b,&bf        ; On lit l'état du registre 10
        in a,(c)
        and 32          ; Si le bit5 est non nul
        jp nz,typealien ; on a un problème
 
        ld b,13         ; Boucle d'attente de
        djnz $          ; 54 micro-secondes
 
        ld b,&bf        ; On lit l'état du registre 10
        in a,(c)
        and 32          ; Si le bit5 est non nul
        jp nz,type34    ; on a un type 3 ou 4
        jp typealien    ; Sinon on a un problème
 
 
; Test basé sur le statut particulier du registre 31
; Permet d'identifier les types 1, 3 et 4
 
; Limitation rarissime
;   ce test ne fournit pas de résultat sur type 1
;   si l'état de haute impédance est altéré
; Limitation courante
;   ce test ne fournit pas de résultat sur types 3 et 4
;   si le registre 15 est nul (ce qui est la valeur par
;   défaut)
 
testreg31:
        ld bc,&bc1f     ; On sélectionne le registre 31
        out (c),c       ; et on fait une tentative de
        ld b,&bf        ; lecture sur le port &BFxx
        in a,(c)        ; Si on a une valeur non nulle
        jp nz,type134   ; alors c'est un type 1,3,4
        ret             ; sinon on ne peut rien
                        ; conclure
 
 
; Test basé sur la détection des blocs 0 et 1
; Permet de différencier les types 0,1,2 des 3,4
 
; Limitation systématique
;   le registre 9 doit valoir 7 sinon le résultat
;   est faux
 
testbloc:
        ld bc,&bc0b     ; On sélectionne le
        out (c),c       ; registre 10 du CRTC
        ld b,&f5
nosynctb1:
        in a,(c)        ; Pre-Synchronisation
        rra             ; Attente de la fin de la VBL
        jr c,nosynctb1
synctb2: in a,(c)        ; Boucle d'attente de la VBL
        rra
        jr nc,synctb2
nosynctb2:
        in a,(c)
        rra             ; Attente de la fin de la VBL
        jr c,nosynctb2
 
        ld b,&bf        ; On lit l'état du registre 11
        in a,(c)        ; (on est sur le bloc 1)
        ld d,a
 
        ld b,14         ; On attend 58 micro-secondes
        djnz $
 
        ld b,&bf
        in a,(c)        ; On lit l'état du registre 11
        ld c,a          ; (on est sur le bloc 2)
 
        ld b,96         ; On attend 386 micro-secondes
        djnz $
 
        ld b,&bf
        in a,(c)        ; On lit l'état du registre 11
        ld e,a          ; (on est sur le bloc 0)
        or d            ; Si on n'a pas lu une valeur
        or e            ; nulle à chaque fois alors
        jr nz,tbactif   ; on peut continuer
        jp type012      ; Sinon on a un type 0, 1 ou 2
tbactif: ld a,&a0        ; Si pour le bloc 0 on n'a pas
        and e           ; bit7=0 et bit5=0
        jp nz,typealien ; alors on a un problème
        ld a,&a0        ; Si pour le bloc 1 on n'a pas
        and d           ; bit7=1 et bit5=1
        cp &a0          ; alors on a un problème
        jp nz,typealien
        ld a,&a0        ; Si pour le bloc 2 on n'a pas
        and c           ; bit7=0 et bit5=1
        cp &20          ; alors on a un problème
        jp nz,typealien
        jp type34       ; Sinon on a un type 3 ou 4
 
 
; Routines de typage
 
crtc0:   Equ 1
crtc1:   Equ 2
crtc2:   Equ 4
crtc3:   Equ 8
crtc4:   Equ 16
 
type012: ld a,(typecrtc)
        and crtc0+crtc1+crtc2
        ld (typecrtc),a
        ret
type0124:
        ld a,(typecrtc)
        and crtc0+crtc1+crtc2+crtc4
        ld (typecrtc),a
        ret
type0234:
        ld a,(typecrtc)
        and crtc0+crtc2+crtc3+crtc4
        ld (typecrtc),a
        ret
type034: ld a,(typecrtc)
        and crtc0+crtc3+crtc4
        ld (typecrtc),a
        ret
type1:   ld a,(typecrtc)
        and crtc1
        ld (typecrtc),a
        ret
type12:  ld a,(typecrtc)
        and crtc1+crtc2
        ld (typecrtc),a
        ret
type134: ld a,(typecrtc)
        and crtc1+crtc3+crtc4
        ld (typecrtc),a
        ret
type3:   ld a,(typecrtc)
        and crtc3
        ld (typecrtc),a
        ret
type34:  ld a,(typecrtc)
        and crtc3+crtc4
        ld (typecrtc),a
        ret
typealien:
        xor a
        ld (typecrtc),a
        ret
 
; Variables
 
typecrtc:
        db &ff
		
		
end start