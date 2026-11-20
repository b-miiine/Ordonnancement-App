# Noyau de calcul d'ordonnancement (MATLAB) : travail de l'étudiant B


Ce dossier contient le noyau de calcul de l'application : structures de données, décodeurs, critères,
méthodes, moteur de recommandation, Gantt et tests. L'interface App Designer (étudiant A) s'appuie dessus.

**Test effectué sous GNU Octave 8.4** (compatible MATLAB, mais pas encore lancé sous MATLAB lui-même).
Les fichiers sont en UTF-8 : si les accents s'affichent mal, ouvrez-les avec l'encodage UTF-8.

## Démarrage

```matlab
cd ordo_matlab        % ou addpath('chemin/vers/ordo_matlab')
test_validation       % 28 vérifications, doit afficher "0 test(s) en échec"
lancer_demo           % démonstration sur le cas des faisceaux (tableau + Gantt + TFR/TAR)
```

## Utilisation en quelques lignes

```matlab
inst = exemple_faisceaux('FS', true, true, false);   % flow shop, préparation, no-wait, sans dates
crit = creer_crit({'Cmax'});                         % ou creer_crit({'Cmax','TT'}, [0.7 0.3])
res  = recommander(inst, crit, 'FIFO');              % lance toutes les méthodes compatibles
afficher_tableau(res);                               % tableau comparatif + message de recommandation
tracer_gantt(inst, res.tableau(res.meilleure).sol, 'Méthode recommandée');
t = taux_machines(inst, res.tableau(res.meilleure).sol);   % t.TFR, t.TAR par machine
```

Données personnelles :

```matlab
o.r = [0 5 0 10]';  o.d = [30 40 25 60]';  o.w = [1 2 1 3]';   % arrivées, délais, poids
o.fam = [1 1 2 2]';  o.Sfam = [2 6; 6 2];  o.setup = true;      % familles et préparation
o.noWait = false;
inst = creer_inst('FS', [4 3 5; 2 6 3; 5 2 4; 3 3 3], o);        % 4 lots, 3 machines
```

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `creer_inst`, `creer_crit`, `calibrer_crit` | Structure du problème ; choix et normalisation des critères |
| `evaluer`, `objectif` | Cmax, TT, TFT (et Lmax, nT, TWT, TWFT) ; valeur à minimiser |
| `decoder_PM`, `decoder_FS`, `decoder_JS`, `planifier` | Séquence → planning (parallèles, flow shop avec no-wait, job shop) |
| `delai_nowait`, `matrice_D`, `temps_prep` | Délai no-wait D(i,j) et temps de préparation |
| `regle_priorite` | FIFO, LIFO, SPT, LPT, EDD, WSPT, WDD |
| `johnson`, `methode_johnson`, `cds`, `neh`, `plus_proche_voisin` | Méthodes flow shop |
| `recherche_locale`, `enumeration` | Amélioration locale ; test de toutes les séquences |
| `recommander`, `afficher_tableau`, `lister_methodes` | Moteur de recommandation, affichage, méthodes compatibles |
| `tracer_gantt`, `taux_machines`, `verifier_planning`, `ops_machines` | Gantt, TFR/TAR, contrôle de faisabilité |
| `exemple_faisceaux`, `exemple_ft06`, `generer_taillard`, `lire_taillard`, `sous_instance` | Jeux de données |
| `test_validation`, `lancer_demo` | Tests et démonstration |

## Conventions

- `inst.type` : `'PM'`, `'QM'`, `'RM'`, `'FS'`, `'JS'`. Une séquence `seq` est un vecteur de numéros de lots ;
  pour le job shop, c'est une liste de priorité (le premier lot est le plus prioritaire).
- Un planning `sol` contient `seq`, `S` et `C` (débuts et fins, lots x opérations), `M` (machine de chaque opération).
- La préparation est **anticipée** : elle peut commencer dès que la machine est libre, avant l'arrivée du lot.
  Pas de préparation pour le premier lot de chaque machine.
- TFR = temps de traitement de la machine / Cmax. Le temps de préparation n'est **pas** compté comme du fonctionnement.
- Critères multiples : l'objectif est la somme pondérée des critères divisés par leur valeur avec la règle FIFO.
  Le classement final de `recommander` utilise une autre normalisation (valeur / meilleure valeur parmi les méthodes).

## Limites à connaître

- **Job shop** : le décodeur construit un planning actif selon une liste de priorité. La « meilleure liste »
  n'est donc pas un optimum global (sur ft06 : 59 contre un optimum de 55).
- **Machines parallèles** : même principe (affectation par date de fin la plus petite). L'énumération donne la
  meilleure liste, pas l'optimum global.
- **Flow shop** : l'énumération est un optimum exact (permutations). Elle est limitée à n <= 8 dans `recommander`
  (n <= 9 si on appelle `enumeration` directement).
- **Johnson** n'est optimal que pour Cmax, sans préparation, sans no-wait et sans dates d'arrivée.
- `exemple_faisceaux(..., true)` : les dates d'arrivée, délais et poids sont des **propositions** à valider par le groupe.
- Non traités : recuit simulé, front de Pareto, préemption.

## Brancher le noyau dans App Designer (pour l'étudiant A)

```matlab
% Callback du bouton "Calculer"
inst = creer_inst(app.TypeDropDown.Value, app.P, opts);       % opts : struct r, d, w, fam, Sfam, setup, noWait...
crit = creer_crit(app.CriteresListBox.Value, poids);
app.MethodeDropDown.Items = lister_methodes(inst);            % méthodes compatibles seulement
res  = recommander(inst, crit, app.MethodeDropDown.Value);
app.UITable.ColumnName = res.entetes;
app.UITable.Data = res.cellules;                              % tableau comparatif
app.MessageLabel.Text = res.message;                          % recommandation
tracer_gantt(inst, res.tableau(res.meilleure).sol, 'Méthode recommandée', app.GanttAxes);
```
