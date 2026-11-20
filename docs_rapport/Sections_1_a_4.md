# Rapport — Sections 1 à 4 (première rédaction)

## 1. Introduction

### 1.1 Contexte
Dans un atelier de production, plusieurs lots doivent être affectés et ordonnancés sur des ressources limitées. L'ordre de passage des lots, les dates d'arrivée, les délais de livraison et les temps de changement de série influencent directement les performances de l'atelier. Une séquence qui réduit la durée totale de production ne minimise pas nécessairement les retards de livraison ou le temps total de séjour des lots.

### 1.2 Problématique
Le projet consiste à développer une application d'aide à l'ordonnancement sous MATLAB App Designer. L'utilisateur décrit son environnement de production, renseigne les durées et les contraintes, sélectionne un ou plusieurs critères, puis compare différentes méthodes d'ordonnancement. L'application doit également recommander la méthode la plus adaptée aux critères choisis.

La question centrale est donc : pour un atelier, des données et des critères donnés, quelle méthode compatible fournit la meilleure solution parmi les méthodes testées, et quel gain apporte-t-elle par rapport à la méthode initialement choisie ?

### 1.3 Objectifs
Les objectifs sont :
- représenter plusieurs environnements : machines parallèles, flow shop et job shop ;
- prendre en compte les dates d'arrivée, délais, poids, temps de préparation et contrainte no-wait ;
- calculer les critères Cmax, TT et TFT ;
- comparer des règles de priorité, heuristiques et méthodes exactes sur les petits cas ;
- présenter le planning sous forme de diagramme de Gantt et d'un tableau comparatif ;
- recommander une méthode selon les critères et leurs poids.

### 1.4 Cas d'étude
Le cas des faisceaux de câbles constitue l'exemple de démonstration. Les lots traversent quatre postes : coupe, sertissage, assemblage et test. Les familles de faisceaux induisent des temps de préparation sur le poste de sertissage. Les valeurs de traitement et de préparation sont des hypothèses réalistes du cahier des charges et ne doivent pas être présentées comme des mesures d'une usine réelle.

## 2. Fondements théoriques

### 2.1 Notations
On note :
- `J={1,...,n}` l'ensemble des lots ;
- `M={1,...,m}` l'ensemble des machines ;
- `p_jk` la durée de traitement du lot j sur la machine k ;
- `r_j` sa date d'arrivée ;
- `d_j` son délai de livraison ;
- `w_j` son poids ou niveau d'importance ;
- `S_k(i,j)` le temps de préparation sur la machine k lors du passage du lot i au lot j ;
- `S_jk` et `C_jk` les dates de début et de fin du lot j sur la machine k.

### 2.2 Environnements d'ordonnancement
**Machines parallèles.** Plusieurs machines réalisent la même fonction. Dans le cas PM, elles ont des vitesses identiques ; dans QM, leurs vitesses diffèrent ; dans RM, la durée d'un lot dépend de la machine affectée.

**Flow shop.** Tous les lots suivent la même gamme de machines dans le même ordre. Dans le flow shop de permutation, l'ordre des lots est identique sur toutes les machines. L'attente entre deux machines peut être permise ou interdite.

**Job shop.** Chaque lot possède sa propre gamme. Deux lots peuvent donc visiter les machines dans des ordres différents, ce qui rend la construction du planning plus complexe.

### 2.3 Contraintes
La date d'arrivée impose `S_j1 ≥ r_j`. Le délai `d_j` intervient dans le calcul des retards. Le poids `w_j` permet de distinguer l'importance des lots dans certaines règles ou fonctions objectif. Les temps de préparation dépendent de la succession des familles sur une machine. Enfin, la contrainte no-wait interdit l'attente d'un lot entre deux machines successives du flow shop.

### 2.4 Critères de performance
Le makespan est la date de fin du dernier lot :
`Cmax = max_j C_j`.

Le retard du lot j est :
`T_j = max(0, C_j − d_j)`,
et le retard total :
`TT = Σ_j T_j`.

Le temps de séjour du lot j est :
`F_j = C_j − r_j`,
et le temps total de séjour :
`TFT = Σ_j (C_j − r_j)`.

Ces critères peuvent être contradictoires. Une méthode peut réduire Cmax tout en augmentant TT. En multicritère, on normalise chaque critère par la meilleure valeur observée parmi les méthodes compatibles, puis on calcule un score pondéré :
`Score(a) = Σ_c α_c × [f_c(a) / f_c*]`, avec `Σ_c α_c = 1`.
La méthode de score minimal est recommandée. Il faut traiter séparément les critères dont la meilleure valeur est nulle pour éviter une division par zéro.

## 3. Méthodes d'ordonnancement

### 3.1 Règles de priorité
FIFO classe les lots selon leur date d'arrivée croissante ; LIFO selon l'ordre inverse. SPT privilégie les durées courtes et LPT les durées longues. EDD classe selon les délais de livraison croissants. WSPT utilise le rapport `p_j/w_j` croissant. La règle WDD est une règle de délai pondéré dont la formule exacte doit être confirmée avec l'enseignant avant l'implémentation définitive.

Ces règles construisent une priorité ou une séquence ; elles ne produisent pas seules un planning complet. Un décodeur propre à l'environnement transforme ensuite cette priorité en dates de début et de fin.

### 3.2 Méthodes dédiées au flow shop
L'algorithme de Johnson donne une solution optimale pour le flow shop à deux machines sous les hypothèses classiques. CDS construit plusieurs problèmes fictifs à deux machines et applique Johnson afin d'obtenir des séquences candidates pour un nombre supérieur de machines. NEH construit une séquence progressivement en insérant les lots selon leur durée totale décroissante et en conservant à chaque étape la meilleure insertion.

Pour le no-wait avec temps de préparation, une transition entre deux lots successifs peut être évaluée par :
`D(i,j) = max_k [C(i,k) + S_k(i,j) − C(j,k−1)]`.
La séquence est évaluée par la somme des délais de transition et de la durée du dernier lot.

### 3.3 Méthodes générales
La recherche locale améliore une solution initiale par échanges ou insertions de lots. L'énumération exhaustive évalue toutes les permutations ; elle est utile pour les petites instances et permet de vérifier l'optimalité de méthodes comme Johnson. Sa complexité factorielle limite son utilisation aux petits nombres de lots.

### 3.4 Comparaison et recommandation
Les méthodes doivent être comparées sur le même jeu de données et avec le même décodeur. L'application filtre les méthodes incompatibles avec l'environnement, calcule les critères pour chaque planning réalisable et classe les méthodes selon le score multicritère choisi.

## 4. Conception de l'application

### 4.1 Architecture générale
L'architecture suit la chaîne :
Saisie → structure `inst` → méthode → décodeur → planning → évaluateur → recommandeur → affichage.

La séparation entre méthodes, décodeurs et évaluateur évite de réécrire les calculs des critères pour chaque algorithme. La structure `inst` contient l'environnement, les dimensions, les durées, les dates, les poids, les familles, la matrice de préparation, l'option no-wait et les gammes du job shop. La structure `sol` contient la méthode, la séquence, les affectations, les dates de début et de fin et les critères calculés.

### 4.2 Organisation de l'interface
L'interface est organisée en quatre onglets :
1. **Problème** : environnement, critères, poids multicritères et contraintes ;
2. **Données** : durées, dates d'arrivée, délais, poids, familles, matrice de préparation et import de fichiers ;
3. **Méthode** : choix parmi les méthodes compatibles ;
4. **Résultats** : séquence, diagramme de Gantt, valeurs des critères, tableau comparatif et recommandation.

Les choix incompatibles avec l'environnement sont désactivés afin d'éviter des configurations incohérentes. Les entrées doivent être contrôlées : dimensions, valeurs positives, familles connues, poids strictement positifs et gammes valides.

### 4.3 Prototype et intégration
Le prototype MATLAB fourni avec cette livraison matérialise les quatre onglets et permet de tester l'énumération du cas flow shop no-wait des faisceaux. Il constitue une base d'interface ; les décodeurs des machines parallèles et du job shop, ainsi que le moteur multicritère complet, doivent être raccordés au noyau développé par l'étudiant B.

### 4.4 Validation
La validation combine quatre niveaux : calcul manuel sur de petits exemples, comparaison de Johnson avec l'énumération, reproduction des résultats de contrôle du cas faisceaux, puis tests sur des benchmarks externes Taillard et job shop. Les hypothèses de données ajoutées pour r, d et w doivent être identifiées explicitement dans les tableaux et dans le rapport.
