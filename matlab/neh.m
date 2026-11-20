function sol = neh(inst, crit)
% NEH  Heuristique de Nawaz-Enscore-Ham (insertion) pour le flow shop.
%   On trie les lots par durée totale décroissante, puis on insère chaque lot à
%   la position qui donne la meilleure valeur du critère choisi.
    n = inst.n;
    p = sum(inst.P, 2);
    [~, ord] = sortrows([-p, (1:n)']);
    seq = ord(1);
    for t = 2:n
        j = ord(t);
        meilleur = inf;
        for pos = 1:t
            cand = [seq(1:pos-1), j, seq(pos:end)];
            z = objectif(inst, planifier(inst, cand), crit);
            if z < meilleur - 1e-12, meilleur = z; bs = cand; end
        end
        seq = bs;
    end
    sol = planifier(inst, seq);
    sol.method = 'NEH';
end
