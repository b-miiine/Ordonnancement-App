function sol = decoder_FS(inst, seq)
% DECODER_FS  Planning d'un flow shop de permutation pour la séquence seq.
%   Attente permise : Sjk = max( Cj,k-1 ; C(précédent),k + préparation ).
%   No-wait         : chaque lot démarre à max( début précédent + D(i,j) ; rj ).
%   La préparation est anticipée : elle peut commencer dès que la machine est libre.
    n = inst.n;  m = inst.m;  P = inst.P;
    S = zeros(n, m);  C = zeros(n, m);
    seq = seq(:)';
    if inst.noWait
        cum = cumsum(P, 2);
        debut = zeros(n, 1);
        for t = 1:numel(seq)
            j = seq(t);
            if t == 1
                d0 = inst.r(j);
            else
                i = seq(t-1);
                d0 = max(debut(i) + delai_nowait(inst, i, j, cum), inst.r(j));
            end
            debut(j) = d0;
            S(j, :) = d0 + [0, cum(j, 1:m-1)];
            C(j, :) = d0 + cum(j, :);
        end
    else
        for t = 1:numel(seq)
            j = seq(t);
            for k = 1:m
                if k == 1, pret = inst.r(j); else pret = C(j, k-1); end
                if t > 1
                    i = seq(t-1);
                    libre = C(i, k) + temps_prep(inst, i, j, k);
                else
                    libre = 0;
                end
                S(j, k) = max(pret, libre);
                C(j, k) = S(j, k) + P(j, k);
            end
        end
    end
    sol.seq = seq;  sol.S = S;  sol.C = C;
    sol.M = repmat(1:m, n, 1);
    sol.method = '';
end
