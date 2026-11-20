# Calculs manuels — Étudiant A

## 1. Flow shop no-wait à 3 lots
Données : J4=(10,12,25,6), J5=(8,10,20,5), J1=(12,15,30,8).
Pour J4→J5 :
D=max(10−0, 22−8, 47−18, 53−38)=29.
Pour J5→J1 :
D=max(8−0, 18−12, 38−27, 43−57)=11.
La durée totale de J1 vaut 65. Donc Cmax=29+11+65=105 min.
Débuts : J4 à 0 ; J5 à 29 ; J1 à 40.

## 2. Machines parallèles identiques — FIFO et EDD
Données proposées :
J1(p=6,r=0,d=8,w=2), J2(3,2,7,1), J3(8,0,12,3), J4(4,1,9,2).
Décodage : prendre les lots selon la règle puis affecter chacun à la machine la plus tôt disponible ; début=max(r_j, disponibilité machine). En cas d'égalité, choisir M1.

FIFO : ordre J1,J3,J4,J2.
M1 : J1 [0,6], J4 [6,10]. M2 : J3 [0,8], J2 [8,11].
Cmax=11 ; TFT=Σ(Cj−rj)=6+9+8+9=32 ; TT=Σmax(0,Cj−dj)=0+4+0+1=5.

EDD : ordre J2,J1,J4,J3.
M1 : J2 [2,5], J4 [5,9]. M2 : J1 [0,6], J3 [6,14].
Cmax=14 ; TFT=3+6+8+14=31 ; TT=0+0+0+2=2.
Conclusion : FIFO minimise Cmax dans cet exemple, EDD minimise TT et TFT.

## 3. Flow shop 2 machines — Johnson et énumération
J1=(3,8), J2=(7,4), J3=(5,6).
Johnson : minimum 3 sur M1 pour J1 → première place ; minimum suivant 4 sur M2 pour J2 → dernière place ; J3 au milieu. Séquence J1,J3,J2.
Planning : M1 J1[0,3], J3[3,8], J2[8,15]. M2 J1[3,11], J3[11,17], J2[17,21]. Cmax=21.
Les six séquences donnent : J1-J2-J3=21 ; J1-J3-J2=21 ; J2-J1-J3=25 ; J2-J3-J1=26 ; J3-J1-J2=23 ; J3-J2-J1=24. Johnson atteint l'optimum 21 ; deux séquences sont optimales.

## 4. Job shop 2 machines — priorité SPT
J1 : M1(3) puis M2(2). J2 : M2(2) puis M1(4). J3 : M1(2) puis M2(4).
Règle pédagogique : parmi les opérations prêtes, priorité à la plus courte ; chaque opération est placée à son premier créneau compatible avec la disponibilité de sa machine et la fin de l'opération précédente du même lot. En cas d'égalité, J2 avant J3.
Planning :
J2-M2 [0,2] ; J3-M1 [0,2] ; J1-M1 [2,5] ; J3-M2 [2,6] ; J2-M1 [5,9] ; J1-M2 [6,8].
Cmax=9. Les précédences de chaque lot et l'absence de chevauchement machine sont respectées.

## Note de rigueur
Les trois derniers jeux de données sont des exemples pédagogiques créés pour le projet, pas des benchmarks publiés. La règle de dispatching job shop doit être nommée précisément dans le rapport et alignée sur le décodeur Giffler–Thompson réellement codé par l'étudiant B ; le tableau ci-dessus illustre une construction SPT à créneaux au plus tôt.
