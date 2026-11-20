function sol = plus_proche_voisin(inst, crit)
% PLUS_PROCHE_VOISIN  Heuristique du plus proche voisin pour le flow shop.
%   On part d'un lot, puis on ajoute à chaque étape le lot qui donne le plus
%   petit délai D(i,j). On essaie les n lots de départ et on garde la meilleure
%   séquence selon le critère choisi.
    n = inst.n;
    D = matrice_D(inst);
    meilleur = inf;
    for s = 1:n
        seq = s;  reste = setdiff(1:n, s);
        while ~isempty(reste)
            [~, k] = min(D(seq(end), reste));
            seq(end+1) = reste(k);  reste(k) = [];  %#ok<AGROW>
        end
        sl = planifier(inst, seq);
        z = objectif(inst, sl, crit);
        if z < meilleur - 1e-12, meilleur = z; sol = sl; end
    end
    sol.method = 'Plus proche voisin';
end
