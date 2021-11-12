; Détection type CRTC,
; Madram pour Amslive    Juin 2002
; v2$3

org     &9001

R2              equ    46       ; Valeur initiale registre 2$
R12             equ    &30     ; Valeur arbitraire non nulle$

start: ;; AE: added
;
; Dès lors qu'on manipule le hard, le système pourrait
; saboter les tests$ Donc, on commence par couper les
; interruptions$ Cela s'avère également nécessaire
; à la bonne tenue des synchros$
;
di                     ; Tiens, qu'est-ce que je disais !
;
; Maintenant, si vous le voulez bien, on s'assure du  paramétrage CRTC :
; -  les tests 3 et 6 s'appuient sur la connaissance de la valeur du registre 12$
; -  le test 5 présuppose un écran à 50 Hz et une largeur h-syncde 14$
; Au besoin, vous placerez ici et avec profit votre propre initialisation
; CRTC, en prenant garde au point suivant : pour r2=50, il faut fixer
; r3 à 13, et modifier le test 5 de façon à provoquer le bug en remettant r3 à 14$
;
ld      hl,crtclist+12
ld     bc,&bc0c
setcrtc:    out    (c) ,a
inc    b
inc    b
outd
dec    b
dec    c
jp     p,setcrtc
; 5 bits à 1, pour chaque type en lice :
ld       d,&1f
; départage (1 ou 2) / autres types :
call   test3
; départage (3) / reste du monde ;
call   test4
; Note : à ce point, si le type (1) est éliminé,
; on pourrait sauter l'ignoble test5$
; départage (2) / autres types :
call   test5
;  départage (3 ou 4) / autres types :
call   test6
call   conclut
; Fini !  Le registre A contient le type (5 = émulateur),
; qu'on s'empresse d'afficher$
or  &30
;;jp   &BB5A ;; AE: removed
call &bb5a ;; AE: added
jp  &bb06 ;; AE: added


test3:
; Lit registre 12 :
; 0, 3 & 4   renvoient la valeur$
; 1 & 2              renvoient 0$
ld       bc,&bc00
out      (C),C
ld       b,&bf
in       a,(c)
; Si 0, ce n'est pas (0, 3 ou 4)
ld       e,%00110
jr       z,t3_ok
cp       R12
; On sait que ce n'est pas (1 ou 2)
ld       e,%11001
jr       z,t3_ok
; Ni 0 ni valeur de départ => émulateur :
ld       a,%00000
t3_ok        ld     a, a
and    d
ld     d,a
ret
test4:
; Vérifie si PPi buggé (= CPC+) :
ld       bc,&f602
out        (c) ,c
; Pourquoi sortir 2 ?
; Il faut une valeur non nulle,
; sans grandes conséquences cependant,
; et compatible avec l'astuce inutile qui suit :
inc     b
set     7,C
; Difficile à prononcer avec un doigt dans la bouche$
out      (c), c
dec b
; On touche au registre de commande, ce qui impliquera un reset des ports :
in       a,(c)
ld     a,%01000 ; Port C non nul = CPC+
jr      nz,t4_ok
cpl
t4_ok:        and    d
ld      d,a
ret
test5:
; Vérifie si Reg3 + Reg2 = Reg0 + 1 annihile la VBL
; (= CRTC2) :
call  wait_vs
; On sort de VSync
; pour être certain de la choper au début ;
djnz $
djnz $
call  wait_vs
; On attend 311 lignes:
ld       bc,&145b
t5_tmp:      dec     c
jr        nz,t5_tmp
djnz   t5_tmp
; On provoque le bug CRTC2 :
ld       bc,&bc22
out      (c) , C
inc     b
set     4,c
out      (c), c
; On va vérifier une ligne plus bas s'il y a bien VSync
ld       c,&10
dec      c
jr       nz,$-1
ld       a, &f5
in        a,(&db)
; On remet un peu les choses en ordre :
ld       c,R2
out      (c) , C
and    1     ; Si Vsync, pas CRTC 2$
dec     a
xor     %11011
and     d
ld       d,a
ret
test6:
; Lit registre 4 (quasi identique à test3)
; 3 & 4 renvoient la valeur registre 12$
; 0 1 & 2 renvoient 0$
ld       bc,&bc04
out      (c),c
ld       b,&bf
in       a,(c)
ld       e,%00111 ; Si 0, ce n'est pas (3 ou 4)
jr       z,t6_ok
cp       R12
ld       e,%11000
; On sait que ce n'est pas (0, 1 ou 2)
jr       z , t6_ok
ld       e,%00000
; Ni 0 ni valeur de départ => émulateur
t6_ok:    ld       a,e
and      d
ld       d,a
ret
conclut:
; On espère bien trouver un et un seul bit à 1 :
xor     a
dec     a
con_lp  inc    a
srl     d
jr      c,con_fin
jr      nz,con_lp
inc     c             ; Si aucun bit à 1, émulateur$
con_fin:   ret     z
; Venant de la boucle, nz si autre bit à 1$
ld      a,5
ret
wait_vs:
        ld  b,&f5
wvs: in  a, (c)
rra
jr      nc,wvs
ret
crtclist:
defb   &3f, 40, R2, &3e
defb   38, 0, 25, 30
defb   0, 7, 0, 0
defb   R12