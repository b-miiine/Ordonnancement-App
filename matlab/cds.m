function sol = cds(inst, crit)
% CDS  Heuristique de Campbell-Dudek-Smith pour le flow shop.
%   Pour l = 1..m-1, on se ramène à 2 machines fictives (somme des l premières
%   machines, somme des l dernières), on applique Johnson, puis on garde la
%   séquence qui donne la meilleure valeur du critère choisi.
    m = inst.m;  P = inst.P;
    meilleur = inf;
    for l = 1:(m - 1)
        a = sum(P(:, 1:l), 2);
        b = sum(P(:, m-l+1:m), 2);
        s = planifier(inst, johnson(a, b));
        z = objectif(inst, s, crit);
        if z < meilleur - 1e-12, meilleur = z; sol = s; end
    end
    sol.method = 'CDS';
end
