# Application d'aide à l'ordonnancement : critères, contraintes, environnements et recommandation de méthode (MATLAB App Designer)

Nov 17, 2026 · @Peri · version 2 (le projet a changé de périmètre)

## 1. Contexte et problématique

La première version du projet cherchait l'ordre de lancement de 6 lots de faisceaux de câbles dans un flow shop no-wait avec temps de préparation. Le professeur a demandé de passer à une **application** : l'utilisateur décrit son atelier, l'application calcule, compare plusieurs méthodes et lui conseille la meilleure.

Ce que l'utilisateur fait dans l'application :

1. Il choisit **le ou les critères** à optimiser (Cmax, TT, TFT).
2. Il choisit **l'environnement** : machines parallèles (PM, QM, RM), flow shop sans/avec préparation, job shop sans/avec préparation.
3. Il active les **contraintes** utiles : dates d'arrivée, délais de livraison, poids, temps de préparation, no-wait.
4. Il saisit les données, puis choisit une **méthode** (FIFO, LIFO, SPT, LPT, EDD, WSPT, WDD, Johnson, CDS, NEH, …).
5. L'application calcule avec la méthode choisie, **lance aussi les autres méthodes compatibles**, puis **recommande** celle qui optimise le mieux ses critères.

**Question posée :** pour un atelier et des critères donnés, quelle méthode d'ordonnancement donne la meilleure solution, et de combien est-elle meilleure que la méthode choisie par l'utilisateur ?

Le cas des faisceaux de câbles de la version 1 devient l'**exemple de démonstration** et le **cas de validation** de l'application.

## 2. Objectifs

Six résultats sont attendus à la fin du projet :

1. Une application MATLAB App Designer qui couvre les environnements, contraintes et critères de la section 3.
2. Un noyau de calcul unique : un décodeur par environnement, un évaluateur commun pour tous les critères.
3. Une bibliothèque de méthodes : règles de priorité, heuristiques, recherche locale, énumération exacte.
4. Un moteur de recommandation qui classe toutes les méthodes compatibles selon le ou les critères choisis.
5. Des sorties lisibles : séquence, diagramme de Gantt, valeurs des critères, tableau comparatif, recommandation.
6. Une validation sur le cas des faisceaux (résultats de la section 8), sur des petits exemples faits à la main et sur des instances de benchmark.

## 3. Périmètre fonctionnel

### Environnements

| Famille | Cas traités | Remarque |
| --- | --- | --- |
| Machines parallèles | PM (identiques), QM (vitesses différentes), RM (durées indépendantes par machine) | Avec ou sans préparation |
| Flow shop | Permutation, sans préparation, avec préparation (SDST), option no-wait | Le no-wait et la préparation viennent de la version 1 |
| Job shop | Sans préparation, avec préparation | Chaque lot a sa propre gamme de machines |

### Contraintes

| Contrainte | Notation | Rôle |
| --- | --- | --- |
| Date d'arrivée | rⱼ | Un lot ne peut pas commencer avant rⱼ |
| Délai de livraison | dⱼ | Sert au calcul du retard (TT) et à la règle EDD |
| Poids | wⱼ | Importance du lot (WSPT, WDD, critères pondérés) |
| Temps de préparation | Sᵢⱼ | Dépend de la famille du lot précédent et du lot suivant |
| No-wait | | Aucun lot n'attend entre deux machines (flow shop) |

### Critères

| Critère | Définition | Statut |
| --- | --- | --- |
| Cmax | max des dates de fin Cⱼ | Obligatoire |
| TT | somme des retards Tⱼ = max(0, Cⱼ − dⱼ) | Obligatoire |
| TFT | somme des temps de séjour Fⱼ = Cⱼ − rⱼ | Obligatoire |
| Lmax, nombre de lots en retard, versions pondérées | | Bonus |

**Multi-critères :** l'utilisateur coche plusieurs critères et donne un poids αc à chacun (somme = 1). Le score d'une méthode est la somme des αc × (valeur du critère c / meilleure valeur du critère c parmi les méthodes testées). La méthode recommandée est celle de score minimal. Bonus : front de Pareto.

### Méthodes

| Méthode | Principe | PM/QM/RM | Flow shop | Job shop |
| --- | --- | --- | --- | --- |
| FIFO | Ordre croissant de rⱼ | oui | oui | oui |
| LIFO | Ordre décroissant de rⱼ | oui | oui | oui |
| SPT | Durée totale croissante | oui | oui | oui |
| LPT | Durée totale décroissante | oui | oui | oui |
| EDD | Ordre croissant de dⱼ | oui | oui | oui |
| WSPT | Ordre croissant de pⱼ / wⱼ | oui | oui | oui |
| WDD | Ordre croissant de dⱼ / wⱼ (formule à confirmer avec le professeur) | oui | oui | oui |
| Johnson | Optimal pour Cmax sur 2 machines | | m = 2 | |
| CDS | Réduction à des problèmes à 2 machines et Johnson | | oui (Cmax) | |
| NEH | Insertion des lots un par un | | oui (Cmax) | |
| Plus proche voisin | Choisir le lot de plus petit délai D(i,j) | | no-wait, préparation | |
| Recherche locale | Échanges et insertions à partir de la meilleure solution | oui | oui | oui |
| Énumération | Toutes les séquences, pour n ≤ 8 ou 9 | oui | oui | oui |

Les règles de priorité donnent une liste de lots : le décodeur de l'environnement la transforme en planning (affectation aux machines ou construction du planning job shop).

## 4. Hypothèses du modèle

- Les lots ne sont pas interrompus une fois commencés sur une machine (pas de préemption).
- Une machine traite un lot à la fois, et un lot n'est sur qu'une machine à la fois.
- Les durées, dates et délais sont des nombres connus et déterministes.
- Machines parallèles : PM utilise pⱼ, QM utilise pⱼ / vᵢ, RM utilise pᵢⱼ.
- Flow shop : tous les lots suivent la même gamme M1 → … → Mm, avec une séquence identique sur toutes les machines (permutation).
- Job shop : chaque lot a sa gamme, ses opérations s'enchaînent dans l'ordre de la gamme.
- Temps de préparation : dépendent de la famille du lot précédent et du lot suivant sur la même machine. Dans le cas des faisceaux, ils n'existent que sur M2.
- Les données du cas des faisceaux sont des valeurs réalistes supposées, pas des mesures d'usine.
- Taille visée : jusqu'à 10 lots pour l'énumération exacte, plus pour les autres méthodes.

## 5. Modèle mathématique

### Notations et critères

pⱼ,ₖ est la durée du lot j sur la machine Mk, Sⱼ,ₖ et Cⱼ,ₖ ses dates de début et de fin sur Mk, et Cⱼ = Cⱼ,m sa date de fin.

```latex
C_{max} = \max_j C_j, \qquad TFT = \sum_j (C_j - r_j), \qquad TT = \sum_j \max(0, C_j - d_j)
```

### Décodeur flow shop (attente permise)

Pour une séquence σ, avec Sfam la préparation sur la machine Mk et σ₀ un lot fictif de durée nulle :

```latex
S_{\sigma_r,k} = \max\left( C_{\sigma_{r-1},k} + S_k(\sigma_{r-1},\sigma_r), \; C_{\sigma_r,k-1} \right), \qquad S_{\sigma_r,1} \ge r_{\sigma_r}
```

### Décodeur flow shop no-wait (version 1)

Avec C(i,k) la durée cumulée du lot i de M1 à Mk et C(i,0) = 0, le délai minimal entre les débuts de i et du lot j qui le suit est :

```latex
D(i,j) = \max_{k=1,\dots,m} \left[ C(i,k) + S_k(i,j) - C(j,k-1) \right]
```

Avec les dates d'arrivée, le début du lot suivant est Sⱼ = max(Sᵢ + D(i,j), rⱼ). Le Cmax sans arrivées est :

```latex
C_{max}(\sigma) = \sum_{r=1}^{n-1} D(\sigma_r, \sigma_{r+1}) + C(\sigma_n, m)
```

Le décodeur doit toujours vérifier à la fin qu'aucun chevauchement n'apparaît sur les machines.

### Décodeur machines parallèles

On parcourt la liste de lots dans l'ordre. Chaque lot est affecté à la machine qui lui donne la date de fin la plus petite, avec un début max(rⱼ, libération de la machine + préparation éventuelle).

### Décodeur job shop

On construit un planning actif (principe de Giffler-Thompson) : à chaque étape, parmi les opérations prêtes sur la machine qui peut finir le plus tôt, on choisit celle de plus forte priorité selon la règle (FIFO, SPT, EDD, WDD, …). Avec préparation, on ajoute Sᵢⱼ entre deux lots consécutifs sur la machine.

### Exemple à la main sur 3 lots (sans temps de préparation)

Séquence J4, J5, J1, avec les durées du tableau de la section 8.

- D(J4, J5) = max(10 − 0, 22 − 8, 47 − 18, 53 − 38) = max(10, 14, 29, 15) = **29**
- D(J5, J1) = max(8 − 0, 18 − 12, 38 − 27, 43 − 57) = max(8, 6, 11, −14) = **11**
- Cmax = 29 + 11 + 65 (durée totale de J1) = **105**

| Lot | M1 | M2 | M3 | M4 |
| --- | --- | --- | --- | --- |
| J4 | 0 à 10 | 10 à 22 | 22 à 47 | 47 à 53 |
| J5 | 29 à 37 | 37 à 47 | 47 à 67 | 67 à 72 |
| J1 | 40 à 52 | 52 à 67 | 67 à 97 | 97 à 105 |

### Exemples à faire à la main pour les nouveaux critères

- [ ] 4 lots sur 2 machines parallèles identiques, avec rⱼ et dⱼ : calculer Cmax, TFT et TT pour FIFO et EDD
- [ ] 3 lots en flow shop à 2 machines : vérifier Johnson contre l'énumération
- [ ] 3 lots en job shop à 2 machines : planning et Cmax pour SPT

## 6. Méthode de travail et architecture MATLAB

### Principe

Un seul évaluateur calcule tous les critères à partir d'un planning. Chaque environnement a son décodeur, chaque méthode renvoie une liste ou une affectation. Cela rend la comparaison entre méthodes équitable.

```
Saisie (App Designer) → inst → méthode → décodeur → planning → évaluateur → recommandeur → affichage
```

### Structure des données

```matlab
inst.type   = 'PM';        % 'PM','QM','RM','FS','JS'
inst.n      = 6;           % nombre de lots
inst.m      = 4;           % nombre de machines
inst.P      = P;           % durées (n x m) ; PM/QM : n x 1
inst.v      = [];          % vitesses (1 x m) pour QM
inst.r      = zeros(6,1);  % dates d'arrivée
inst.d      = inf(6,1);    % délais de livraison
inst.w      = ones(6,1);   % poids
inst.fam    = fam;         % famille de chaque lot
inst.Sfam   = Sfam;        % préparation entre familles
inst.setup  = true;        % préparation active ?
inst.noWait = false;       % no-wait (flow shop)
inst.route  = [];          % gamme (n x m) pour le job shop

sol.method = 'EDD';        % nom de la méthode
sol.seq    = [];           % séquence de lancement
sol.assign = [];           % machine de chaque lot (parallèles)
sol.S      = [];           % dates de début (lots x machines)
sol.C      = [];           % dates de fin
sol.crit   = struct('Cmax',0,'TT',0,'TFT',0);
```

### Fichiers prévus

| Fichier | Rôle |
| --- | --- |
| `evaluer.m` | Cmax, TT, TFT à partir d'un planning |
| `decoder_PM.m`, `decoder_FS.m`, `decoder_JS.m` | Séquence → planning pour chaque environnement |
| `regle_priorite.m` | FIFO, LIFO, SPT, LPT, EDD, WSPT, WDD |
| `johnson.m`, `cds.m`, `neh.m` | Méthodes flow shop |
| `plus_proche_voisin.m` | Heuristique no-wait / préparation |
| `recherche_locale.m` | Amélioration par échanges et insertions |
| `enumeration.m` | Optimum exact pour les petits n (`perms`) |
| `recommander.m` | Lance les méthodes compatibles, calcule les scores, classe |
| `tracer_gantt.m` | Diagramme de Gantt avec `barh` |
| `OrdoApp.mlapp` | Application App Designer |

### Interface App Designer (maquette)

- Onglet **Problème** : choix de l'environnement, des contraintes (cases à cocher) et des critères (avec poids).
- Onglet **Données** : tableau de saisie des durées, rⱼ, dⱼ, wⱼ, familles ; tableau de préparation ; bouton d'import de fichier ; bouton « charger l'exemple faisceaux ».
- Onglet **Méthode** : liste déroulante des méthodes compatibles avec le problème choisi.
- Onglet **Résultats** : séquence, Gantt, critères de la méthode choisie, tableau comparatif de toutes les méthodes, message de recommandation.

Règle d'ergonomie : les méthodes et critères non compatibles avec l'environnement choisi sont grisés.

## 7. Calcul des taux de fonctionnement

On garde le calcul de la version 1, pour chaque machine, à partir du planning :

- **TFR** (taux de fonctionnement) = temps de traitement / Cmax.
- **TAR** (taux d'arrêt) = 1 − TFR.

Ils sont affichés à côté du Gantt, pour la méthode choisie et pour la méthode recommandée.

## 8. Données de l'étude et résultats de contrôle

### Cas des faisceaux de câbles (exemple de démonstration)

Durées de traitement en minutes par lot :

| Lot | Type de faisceau | Famille | M1 Coupe | M2 Sertissage | M3 Assemblage | M4 Test |
| --- | --- | --- | --- | --- | --- | --- |
| J1 | Porte | A | 12 | 15 | 30 | 8 |
| J2 | Tableau de bord | B | 25 | 30 | 60 | 15 |
| J3 | Moteur | C | 20 | 25 | 45 | 12 |
| J4 | Feu arrière | A | 10 | 12 | 25 | 6 |
| J5 | Coffre | A | 8 | 10 | 20 | 5 |
| J6 | Siège | B | 15 | 18 | 35 | 9 |

Temps de préparation sur M2 (minutes) :

| Changement entre familles | Temps |
| --- | --- |
| Même famille (A vers A, B vers B) | 3 |
| A vers B, ou B vers A | 8 |
| A vers C, ou C vers A | 12 |
| B vers C, ou C vers B | 10 |

```matlab
P = [12 15 30  8;
     25 30 60 15;
     20 25 45 12;
     10 12 25  6;
      8 10 20  5;
     15 18 35  9];      % durées : lots x machines
fam  = [1 2 3 1 1 2];   % famille : A=1, B=2, C=3
Sfam = [ 3  8 12;
         8  3 10;
        12 10  3];      % préparation entre familles
```

Pour tester les critères TT et TFT sur ce cas, il manque des dates d'arrivée, des délais et des poids : **à définir ensemble** (hypothèses réalistes, par exemple des délais serrés pour les lots J2 et J3).

- [ ] Définir r, d, w pour le cas des faisceaux et les figer

### Résultats de contrôle (version 1, à retrouver avec l'application)

| Cas | Séquence | Cmax (min) |
| --- | --- | --- |
| No-wait, sans préparation, meilleure | J5, J1, J3, J2, J6, J4 (ex aequo avec J5, J1, J6, J3, J2, J4) | 239 |
| No-wait, avec préparation, meilleure | J5, J1, J6, J3, J2, J4 | 239 |
| No-wait, ordre naïf J1 à J6, sans préparation | J1, J2, J3, J4, J5, J6 | 264 |
| No-wait, ordre naïf J1 à J6, avec préparation | J1, J2, J3, J4, J5, J6 | 267 |
| No-wait, pire séquence, avec préparation | J3, J4, J6, J1, J5, J2 | 301 |
| Flow shop classique (attente permise), ordre naïf | J1, J2, J3, J4, J5, J6 | 261 |
| Flow shop classique, meilleure, sans préparation | | 239 |

Dans l'application, ces valeurs doivent sortir avec : environnement flow shop, critère Cmax, rⱼ = 0, option no-wait et préparation cochées ou non, méthode énumération.

### Jeux de données de validation (benchmarks)

- **Benchmark de Taillard** : 120 instances de flow shop (20 à 500 lots, 5 à 20 machines), durées tirées au hasard entre 1 et 99 ([Taillard, 1993](https://edisciplinas.usp.br/pluginfile.php/7556163/mod_resource/content/0/Taillard%201993%20EJOR%20Benchmarks%20for%20basic%20sheduling%20problems.pdf)). Le paquet R [combheuristics](https://rdrr.io/github/jmsallan/combheuristics/man/Taillard_FS.html) sur GitHub en reprend les instances. Sert à valider Johnson, CDS, NEH et la recherche locale : comparer le Cmax obtenu à la meilleure valeur connue de la source (à vérifier dans le fichier, pas de mémoire).
- **Dépôt de l'université de Eindhoven** : [Job Shop Scheduling Benchmark](https://www.github.com/ai-for-decision-making-tue/Job_Shop_Scheduling_Benchmark_Environments_and_Instances), job shop, flow shop et job shop flexible avec préparation, avec lecteurs de fichiers. À vérifier : contenu du dossier `data/`, format, licence (le README indique à la fois MIT et GPLv3).
- **Petite instance de job shop classique** (type ft06, 6 lots × 6 machines) pour valider le décodeur job shop : à chercher et à vérifier dans une source fiable.

| Partie du projet | Données utilisées |
| --- | --- |
| Démonstration de l'application, Gantt, rapport | Cas des faisceaux de câbles |
| Validation des méthodes flow shop | Une petite instance de Taillard (20 lots, 5 machines) |
| Validation du décodeur job shop | Une petite instance de job shop classique |
| Validation des parallèles | Exemples faits à la main |

Limite : ces instances sont synthétiques, elles servent à valider les méthodes, pas à rendre le cas plus réaliste.

## 9. Plan de travail et état d'avancement

Les durées sont indicatives, à ajuster à la date de remise donnée par le professeur.

| Phase | Durée | Contenu | Validation |
| --- | --- | --- | --- |
| 0. Cadrage | semaine 1 | Liste des fonctions, structure `inst` et `sol` figée, données du cas faisceaux complétées | Le professeur valide le périmètre |
| 1. Noyau | semaines 1 à 2 | `evaluer`, `regle_priorite`, `enumeration`, `tracer_gantt`, TFR et TAR | Cmax = 105 sur l'exemple à 3 lots |
| 2. Environnements | semaines 2 à 4 | Décodeurs PM/QM/RM, flow shop (attente, no-wait, préparation), job shop (sans/avec préparation) | Résultats de la section 8 retrouvés |
| 3. Méthodes avancées | semaines 3 à 5 | Johnson, CDS, NEH, plus proche voisin, recherche locale | Écart à l'optimum sur petites instances, test sur Taillard |
| 4. Application et recommandation | semaines 4 à 6 | `recommander`, multi-critères, interface App Designer, import, messages d'erreur | Test par une personne extérieure au projet |
| 5. Rapport et présentation | semaines 6 à 7 | Rédaction, captures d'écran, démonstration | Relecture croisée |

L'interface (phase 4) peut commencer plus tôt avec des données factices dès que la structure `inst` est figée.

### État d'avancement au 17 novembre 2026

- [x] Choix du sujet et du titre
- [x] Étude du procédé de fabrication et recherche de sources
- [x] Premier jeu de données (cas des faisceaux)
- [x] Formule du délai no-wait et exemple à 3 lots (Cmax = 105)
- [x] Nouveau cahier des charges : application avec critères, contraintes, environnements et méthodes
- [x] Choix de la technologie : MATLAB App Designer
- [x] Définition de WDD : règle de date due pondérée
- [ ] Valider avec le professeur le périmètre de la section 3
- [ ] Figer la structure `inst` et `sol`
- [ ] Définir r, d, w pour le cas des faisceaux
- [ ] Refaire l'exemple à 3 lots à la main et tracer son Gantt
- [ ] Faire les exemples à la main pour PM, Johnson et job shop
- [ ] Noyau : évaluateur, règles de priorité, énumération, Gantt
- [ ] Décodeurs PM/QM/RM
- [ ] Décodeurs flow shop (attente, no-wait, préparation)
- [ ] Décodeur job shop (sans/avec préparation)
- [ ] Johnson, CDS, NEH, plus proche voisin, recherche locale
- [ ] Moteur de recommandation et multi-critères
- [ ] Interface App Designer
- [ ] Calcul des taux TFR et TAR
- [ ] Test sur des instances de benchmark
- [ ] Validation sous SageMath (cas des faisceaux)
- [ ] Rédaction du rapport

## 10. Répartition des tâches : étudiant A et étudiant B

Le travail est partagé en deux rôles qui s'enchaînent : A construit l'interface, les données et la vérification à la main, B écrit le noyau de calcul et les méthodes. Choisissez qui prend A et qui prend B, puis échangez les rôles pour une partie à mi-parcours, pour que chacun comprenne tout le projet.

### Étudiant A : interface, données, vérification et validation

- [ ] Compléter et valider les données du cas des faisceaux, avec r, d et w (phase 0)
- [ ] Refaire à la main l'exemple à 3 lots et les trois nouveaux exemples (phase 0 et 1)
- [ ] Explorer GitHub : format et licence des dépôts, télécharger une instance de Taillard 20 × 5 et une petite instance de job shop (phase 0 et 1)
- [ ] Construire l'interface App Designer : saisie, choix des critères, des contraintes et de l'environnement, onglets (phases 1 à 4)
- [ ] Afficher le Gantt, les tableaux comparatifs et la recommandation dans l'interface (phase 4)
- [ ] Écrire la version SageMath pour le cas des faisceaux et comparer avec MATLAB (phase 3)
- [ ] Rédiger les sections 1 à 4 du rapport : introduction, théorie, méthodes, conception (phases 2 à 5)

**Livrables :** données validées, exemples à la main, interface complète, script Sage, sections 1 à 4.

### Étudiant B : noyau de calcul, méthodes et analyse

- [ ] Écrire `evaluer.m` et `regle_priorite.m`, vérifier Cmax = 105 sur l'exemple à 3 lots (phase 1)
- [ ] Écrire `enumeration.m` et `tracer_gantt.m`, calculer TFR et TAR (phase 1)
- [ ] Écrire les décodeurs PM/QM/RM, flow shop et job shop (phase 2)
- [ ] Programmer Johnson, CDS, NEH, plus proche voisin, recherche locale (phase 3)
- [ ] Écrire `recommander.m` avec le score multi-critères (phase 4)
- [ ] Tester sur Taillard et sur le job shop classique, mesurer les écarts à l'optimum (phase 3 et 4)
- [ ] Rédiger les sections 5 et 6 du rapport : mode d'emploi et résultats (phase 5)

**Livrables :** code MATLAB commenté, jeux d'essai, tableau de validation, sections 5 et 6.

### Ensemble

- [ ] Figer la structure `inst` et `sol` avant de séparer le travail
- [ ] Relire le travail de l'autre : A relit le code et les résultats, B relit les sections théoriques et teste l'interface
- [ ] Préparer la présentation pour le professeur et s'entraîner à expliquer tout le projet
- [ ] Rédiger ensemble la section 7 du rapport : conclusion et perspectives

### Points de contrôle

Chaque point doit être validé avant de passer au suivant, pour que les deux parties s'emboîtent.

| Point | Condition à remplir | Responsable |
| --- | --- | --- |
| 1. Cadrage figé | Périmètre validé par le professeur ; `inst` et `sol` figées ; données et r, d, w du cas faisceaux fixés | A et B |
| 2. Noyau juste | MATLAB donne Cmax = 105 pour J4, J5, J1 ; exemples à la main retrouvés | B, vérifié par A |
| 3. Environnements justes | Les résultats de contrôle de la section 8 sont retrouvés (239, 264, 267, 301, 261) | B, vérifié par A |
| 4. Méthodes validées | Johnson = énumération sur petits cas ; NEH et recherche locale testés sur Taillard | B, vérifié par A |
| 5. Application complète | Un utilisateur extérieur saisit un problème et obtient une recommandation sans aide | A, testé par B |
| 6. Rapport | Sections rédigées et relues par l'autre étudiant | A et B |

**Règle d'échange :** une seule structure `inst` partagée et un seul dossier de code. Si la structure change, on prévient l'autre avant de modifier ses fonctions.

## 11. Plan du rapport

1. Introduction : pourquoi une application d'aide à l'ordonnancement
2. Théorie : critères, contraintes, environnements (notation α | β | γ)
3. Méthodes implémentées : règles de priorité, heuristiques, méthode exacte, recommandation
4. Conception de l'application : architecture, structures de données, décodeurs
5. Mode d'emploi et captures d'écran de l'interface
6. Validation et comparaison des méthodes, avec le cas des faisceaux comme exemple
7. Conclusion et perspectives

Le contexte industriel (faisceaux de câbles, usines au Maroc, temps de changement d'outils) est résumé dans la section 6 comme exemple d'application, avec les références ci-dessous.

## 12. Références

Sources repérées par recherche web le 26 octobre 2026. Nous n'avons vu que des extraits : à lire en entier avant de les citer dans le rapport final.

### Procédé de fabrication des faisceaux (cas de démonstration)

- [Wire Harness Manufacturing Guide (LCSC)](https://www.lcsc.com/blog/?p=3789) : procédé en six étapes, de la coupe au test à 100 %.
- [Electromechanical Assembly Wiring Harness Guide (Fabcon)](https://fabcon.com/articles/?p=1083) : procédé en huit étapes, essais électriques.
- [Decreasing defects in wire harnesses (Vision Engineering)](https://www.visioneng.com/resources/application-notes/wire-harness-manufacturing/) : coupe, sertissage, assemblage manuel, contrôle.
- [Auto Harness (Scribd)](https://es.scribd.com/document/72587408/Auto-Harness) : fabrication d'un faisceau automobile, assemblage par famille.
- [Wire harness manufacturing system (brevet US 6169934)](https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/6169934) : étapes de préparation, coupe, sertissage, assemblage.
- [From Spool to Assembly (Telewire Tech)](https://www.telewiretech.com/blogs/technical-resources/from-spool-to-assembly-the-custom-cable-assembly-wire-harness-manufacturing-process) : automatisation de la coupe et du sertissage, assemblage manuel.

### Temps de préparation et changement d'outils

- [Automatic cut, strip and crimp machines (Assembly Magazine)](https://assemblymag.com/articles/93685-automatic-cut-strip-and-crimp-machines) : changement d'applicateur de 5 à 6 minutes à 30 à 40 secondes.
- [Harnessing high mix, low volume (Assembly Magazine)](https://www.assemblymag.com/articles/83900-harnessing-high-mix-low-volume) : effet du temps de changement sur le temps de cycle selon la taille des lots.
- [Komax, production par lots](https://www.komaxgroup.com/expertise/batch-production) : changement automatique d'applicateur et gain de temps par poste.
- [Komax Alpha 650 (Wiring Harness News)](https://wiringharnessnews.com/?p=6244) : changement typique d'environ quinze minutes.
- [CrimpCenter 64 SP (Schleuniger)](https://photonics.com/Products/Wire_Crimping_System/pr65222) : système à changement rapide en 30 secondes.

### Contexte industriel au Maroc

- [Yazaki Europe Middle East Africa, certificat ISO 14001](https://www.yazaki-europe.com/fileadmin/user_upload/990031_Yazaki_Europe_Middle_East_Africa_ISO_14001_EN_vers.1.pdf) : sites de Kénitra, Tanger et Meknès.
- [Lear opens new automotive wiring plant in Morocco (S&P Global)](https://autotechinsight.spglobal.com/news/25853/lear-opens-new-automotive-wiring-plant-in-morocco) : usine de faisceaux à Kénitra.
- [Morocco announces $180 million in automotive wiring systems investments (Reuters via Nippon.com)](https://www.nippon.com/en/news/reu20220325KCN2LL26O/) : investissements de Yazaki, Sumitomo, TE Connectivity et Stahlschmidt.
- [CVG announces new electrical manufacturing facility in Tangier (communiqué, 2023)](https://s204.q4cdn.com/845668686/files/doc_news/Commercial-Vehicle-Group-CVG-Announces-New-Electrical-Manufacturing-Facility-in-Tangier-Morocco-2023.pdf) : usine de faisceaux à Tanger.

### Benchmarks

- [Taillard, 1993, Benchmarks for basic scheduling problems](https://edisciplinas.usp.br/pluginfile.php/7556163/mod_resource/content/0/Taillard%201993%20EJOR%20Benchmarks%20for%20basic%20sheduling%20problems.pdf) : instances de flow shop.
- [Taillard_FS (paquet R combheuristics)](https://rdrr.io/github/jmsallan/combheuristics/man/Taillard_FS.html) : instances de Taillard sur GitHub.
- [Job Shop Scheduling Benchmark (Eindhoven)](https://www.github.com/ai-for-decision-making-tue/Job_Shop_Scheduling_Benchmark_Environments_and_Instances) : job shop, flow shop, préparation.
- [Flow shop no-wait (exemple d'article)](https://arxiv.org/pdf/1903.09035) : usage des instances de Taillard pour le no-wait.

### Cours

- TD2 (atelier à deux machines, règle de Johnson), TD3 (flow shop à trois machines, algorithme CDS), TD4 (flow shop avec préparation, SDST) et TD5 (job shop), Pr S. Aqil, ENSAM Casablanca.
