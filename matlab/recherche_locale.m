function sol = recherche_locale(inst, crit, seq0, maxIter)
% RECHERCHE_LOCALE  Amélioration d'une séquence par échanges et insertions.
%   À chaque itération on teste tous les échanges de deux lots et toutes les
%   insertions d'un lot à une autre position, et on applique le meilleur mouvement.
%   On s'arrête quand plus aucun mouvement n'améliore le critère.
    if nargin < 4, maxIter = 100; end
    n = inst.n;
    cur = seq0(:)';
    zc = objectif(inst, planifier(inst, cur), crit);
    for it = 1:maxIter
        meilleur = zc;  bs = [];
        for a = 1:n-1
            for b = a+1:n
                s = cur;  s([a b]) = s([b a]);
                z = objectif(inst, planifier(inst, s), crit);
                if z < meilleur - 1e-9, meilleur = z; bs = s; end
                s = cur;  e = s(a);  s(a) = [];  s = [s(1:b-1), e, s(b:end)];
                z = objectif(inst, planifier(inst, s), crit);
                if z < meilleur - 1e-9, meilleur = z; bs = s; end
                s = cur;  e = s(b);  s(b) = [];  s = [s(1:a-1), e, s(a:end)];
                z = objectif(inst, planifier(inst, s), crit);
                if z < meilleur - 1e-9, meilleur = z; bs = s; end
            end
        end
        if isempty(bs), break; end
        cur = bs;  zc = meilleur;
    end
    sol = planifier(inst, cur);
    sol.method = 'Recherche locale';
end
