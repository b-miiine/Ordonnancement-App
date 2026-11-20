function res = methode_enumeration(inst, crit, nmax)
% ENUMERATION  Teste toutes les séquences (n!) et renvoie la meilleure et la pire.
%   res.sol      meilleur planning (en cas d'égalité : séquence la plus petite
%                dans l'ordre lexicographique, pour un résultat reproductible)
%   res.pire     pire planning
%   res.valeurs  valeur de l'objectif pour chaque séquence testée
%   res.nbOpt    nombre de séquences optimales ; res.optSeqs : ces séquences
%   res.exact    true si le résultat est un optimum global (flow shop de permutation) ;
%                pour les autres environnements, c'est la meilleure liste de priorité.
    if nargin < 3, nmax = 9; end
    n = inst.n;
    if n > nmax
        error('enumeration : %d lots, trop pour tester les %d! séquences (maximum %d).', n, n, nmax);
    end
    Q = perms(1:n);
    N = size(Q, 1);
    z = zeros(N, 1);
    for t = 1:N
        z(t) = objectif(inst, planifier(inst, Q(t, :)), crit);
    end
    tol = 1e-9 * max(1, max(abs(z)));
    iopt = find(z <= min(z) + tol);
    ipire = find(z >= max(z) - tol);
    opt = sortrows(Q(iopt, :));
    pire = sortrows(Q(ipire, :));
    res.sol = planifier(inst, opt(1, :));
    res.sol.method = 'Enumération';
    res.pire = planifier(inst, pire(1, :));
    res.pire.method = 'Pire séquence';
    res.valeurs = z;
    res.nbOpt = size(opt, 1);
    res.optSeqs = opt;
    res.exact = strcmp(inst.type, 'FS');
end
