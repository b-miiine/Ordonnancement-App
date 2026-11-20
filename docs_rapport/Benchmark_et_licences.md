# Benchmarks et licences — Étudiant A

## Flow shop : Taillard 20 × 5
Une copie de la première instance `tai20_5.txt` est fournie dans `Data/tai20_5.txt` (20 lots × 5 machines). Elle contient l'en-tête n, m, seed, borne supérieure et borne inférieure, puis 5 lignes de 20 durées (une ligne par machine).
Choix recommandé : le fichier `tai20_5.txt` du dépôt `dwave-examples/flow-shop-scheduling`.
- Dépôt : https://github.com/dwave-examples/flow-shop-scheduling
- Le README indique que les instances Taillard sont dans `input/`, un fichier par instance, et que les noms commencent par `tai`. Le format utilisé est le format Taillard.
- Le README utilise `input/tai20_5.txt` comme fichier par défaut. Le dépôt est sous Apache License 2.0.
- Attention : le dépôt est un exemple logiciel D-Wave ; pour le projet ENSAM, on peut réutiliser le fichier d'instance en citant Taillard (1993) et le dépôt miroir, mais il faut garder les mentions de provenance et vérifier le fichier source exact avant publication.

## Job shop : ft06
Une transcription structurée des données ft06 publiées dans l'exemple Google OR-Tools est fournie dans `Data/ft06_ortools.csv` : une ligne par opération, avec machine convertie en index 1..6.
Choix recommandé : instance classique ft06 (6 jobs × 6 machines).
- Dépôt d'instances : https://github.com/SchedulingLab/jsp-instances
- Le dépôt indique une licence MIT et contient la famille `ft` ; il référence Muth & Thompson (1963). Il avertit que certaines données peuvent contenir des erreurs : vérifier contre la source d'origine.
- Pour une définition immédiatement exploitable, le code officiel OR-Tools contient les durées et les gammes de ft06 dans `jobshop_ft06_sat.py`, sous Apache License 2.0 : https://github.com/google/or-tools/blob/stable/examples/python/jobshop_ft06_sat.py
- Dans le code OR-Tools, `machines` donne la machine visitée à chaque opération et `durations` donne les durées correspondantes. Les indices de machines commencent à 0 ; les convertir en 1..6 dans MATLAB.
- Une source de documentation indépendante indique que ft06 est un cas 6×6 et que son optimum connu est 55 : https://jsp-instance-utils.readthedocs.io/en/latest/

## Taillard comme famille de données
La documentation `Taillard_FS` du paquet R `combheuristics` décrit 10 instances dans le groupe 20 jobs × 5 machines et les champs `n`, `m`, `seed`, `upper`, `lower`, `tij`. Source : https://rdrr.io/github/jmsallan/combheuristics/man/Taillard_FS.html

## Formats à prévoir dans le lecteur
- Taillard : lire l'en-tête n,m puis la matrice des temps de traitement selon l'ordre exact du fichier source ; conserver seed/borne si présents.
- ft06 OR-Tools : deux matrices de 6×6 : `machines[j][k]` et `durations[j][k]`. Convertir `machines+1` pour l'indexation MATLAB.
- Ne pas supposer que tous les dépôts partagent un format identique.

## À faire avant de figer le rapport
1. Télécharger `input/tai20_5.txt` depuis le dépôt D-Wave et archiver la copie avec son URL/commit.
2. Extraire ft06 du dépôt OR-Tools ou du dépôt SchedulingLab, archiver la licence et la source.
3. Conserver une copie de chaque LICENSE et noter la date/commit consulté.
4. Vérifier les résultats de référence et les bornes avant de calculer les écarts heuristiques.
