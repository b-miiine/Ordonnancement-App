function res = recommander(inst, crit, methodeChoisie, opts)
% RECOMMANDER  Lance toutes les méthodes compatibles, les classe et recommande la meilleure.
%
%   res = recommander(inst, crit, methodeChoisie, opts)
%
%   methodeChoisie : nom de la méthode choisie par l'utilisateur ('' si aucune)
%   opts.nmax      : taille maximale pour l'énumération (défaut 8)
%
%   Méthodes lancées : FIFO, LIFO, SPT, LPT, EDD, WSPT, WDD (tous les environnements) ;
%   Johnson, CDS, NEH, Plus proche voisin (flow shop) ; Recherche locale (à partir de la
%   meilleure solution trouvée) ; Énumération (si n <= nmax).
%
%   Classement : score = somme pondérée de (valeur du critère / meilleure valeur
%   du critère parmi les méthodes). Un score de 1 signifie "meilleur sur tous les critères".
    if nargin < 3, methodeChoisie = ''; end
    if nargin < 4, opts = struct(); end
    nmax = champ(opts, 'nmax', 8);
    crit = calibrer_crit(inst, crit);
    tab = struct('nom', {}, 'sol', {}, 'val', {}, 'z', {}, 'note', {});

    regles = {'FIFO', 'LIFO', 'SPT', 'LPT', 'EDD', 'WSPT', 'WDD'};
    for k = 1:numel(regles)
        s = planifier(inst, regle_priorite(inst, regles{k}));
        tab = ajouter(tab, inst, crit, regles{k}, s, '');
    end
    if strcmp(inst.type, 'FS')
        sj = methode_johnson(inst, crit);
        if ~isempty(sj)
            note = '';
            if inst.setup || inst.noWait || any(inst.r > 0)
                note = 'optimal pour Cmax seulement sans préparation, sans no-wait et sans arrivées';
            end
            tab = ajouter(tab, inst, crit, 'Johnson', sj, note);
        end
        if inst.m >= 2
            tab = ajouter(tab, inst, crit, 'CDS', cds(inst, crit), '');
            tab = ajouter(tab, inst, crit, 'NEH', neh(inst, crit), '');
            tab = ajouter(tab, inst, crit, 'Plus proche voisin', plus_proche_voisin(inst, crit), '');
        end
    end
    [~, ib] = min([tab.z]);
    tab = ajouter(tab, inst, crit, 'Recherche locale', ...
                  recherche_locale(inst, crit, tab(ib).sol.seq), 'part de la meilleure solution trouvée');
    if inst.n <= nmax
        en = methode_enumeration(inst, crit, nmax);
        if en.exact
            note = sprintf('optimum exact (%d séquences testées, %d optimales)', numel(en.valeurs), en.nbOpt);
        else
            note = 'meilleure liste de priorité (pas un optimum global)';
        end
        tab = ajouter(tab, inst, crit, 'Enumération', en.sol, note);
    end

    % Scores normalisés
    nc = numel(crit.noms);  nm = numel(tab);
    V = zeros(nm, nc);
    for i = 1:nm
        for c = 1:nc, V(i, c) = tab(i).val.(crit.noms{c}); end
    end
    ref = min(V, [], 1);
    score = zeros(nm, 1);
    for i = 1:nm
        for c = 1:nc
            if ref(c) > 0, ratio = V(i, c) / ref(c); else ratio = 1 + V(i, c); end
            score(i) = score(i) + crit.poids(c) * ratio;
        end
    end
    for i = 1:nm, tab(i).score = score(i); end
    tol = 1e-9;
    ib = find(score <= min(score) + tol, 1, 'first');
    exaequo = find(score <= min(score) + tol)';
    noms = {tab.nom};
    ic = find(strcmpi(noms, methodeChoisie), 1);

    % Message de recommandation
    if nc == 1, txtCrit = crit.noms{1}; else txtCrit = strjoin(crit.noms, ' + '); end
    msg = sprintf('Pour minimiser %s, la meilleure méthode testée est %s', txtCrit, tab(ib).nom);
    if nc == 1
        msg = sprintf('%s (%s = %.4g).', msg, crit.noms{1}, V(ib, 1));
    else
        msg = sprintf('%s (score %.3f).', msg, score(ib));
    end
    if numel(exaequo) > 1
        msg = sprintf('%s Ex aequo : %s.', msg, strjoin(noms(exaequo(exaequo ~= ib)), ', '));
    end
    if ~isempty(ic)
        if any(exaequo == ic)
            msg = sprintf('%s Votre méthode %s est déjà parmi les meilleures.', msg, tab(ic).nom);
        elseif nc == 1
            gain = (V(ic, 1) - V(ib, 1)) / max(V(ic, 1), eps) * 100;
            msg = sprintf('%s Votre méthode %s donne %.4g : gain possible de %.1f %%.', ...
                          msg, tab(ic).nom, V(ic, 1), gain);
        else
            msg = sprintf('%s Votre méthode %s a un score de %.3f.', msg, tab(ic).nom, score(ic));
        end
    elseif ~isempty(methodeChoisie)
        msg = sprintf('%s (La méthode "%s" n''est pas disponible pour ce problème.)', msg, methodeChoisie);
    end

    % Tableau trié (pour l'affichage et pour un uitable d'App Designer)
    [~, ordre] = sortrows([score, (1:nm)']);
    entetes = {'Rang', 'Méthode', 'Cmax', 'TT', 'TFT', 'Score', 'Remarque'};
    cell_t = cell(nm, numel(entetes));
    for r = 1:nm
        i = ordre(r);
        cell_t(r, :) = {r, tab(i).nom, tab(i).val.Cmax, tab(i).val.TT, tab(i).val.TFT, ...
                        score(i), tab(i).note};
    end
    res.tableau  = tab;
    res.crit     = crit;
    res.meilleure = ib;
    res.choisie  = ic;
    res.ordre    = ordre;
    res.message  = msg;
    res.entetes  = entetes;
    res.cellules = cell_t;
end

function tab = ajouter(tab, inst, crit, nom, sol, note)
    sol.method = nom;
    e.nom = nom;  e.sol = sol;  e.val = evaluer(inst, sol);
    e.z = objectif(inst, sol, crit);  e.note = note;
    if isempty(tab), tab = e; else tab(end+1) = e; end
end
