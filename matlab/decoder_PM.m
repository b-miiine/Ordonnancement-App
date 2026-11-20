function sol = decoder_PM(inst, seq)
% DECODER_PM  Planning sur machines parallèles (PM, QM, RM) par ordonnancement de liste.
%   Les lots sont pris dans l'ordre de seq ; chacun va sur la machine qui lui donne
%   la date de fin la plus petite (égalité : machine de plus petit numéro).
%   Durées : PM = pj ; QM = pj / vi ; RM = pij.
    n = inst.n;  m = inst.m;
    S = zeros(n, 1);  C = zeros(n, 1);  M = zeros(n, 1);
    libre = zeros(1, m);  dernier = zeros(1, m);
    seq = seq(:)';
    for t = 1:numel(seq)
        j = seq(t);
        meilleur = inf;
        for i = 1:m
            deb = max(inst.r(j), libre(i) + temps_prep(inst, dernier(i), j, i));
            fin = deb + duree_machine(inst, j, i);
            if fin < meilleur - 1e-12
                meilleur = fin;  bi = i;  bdeb = deb;
            end
        end
        S(j) = bdeb;  C(j) = meilleur;  M(j) = bi;
        libre(bi) = meilleur;  dernier(bi) = j;
    end
    sol.seq = seq;  sol.S = S;  sol.C = C;  sol.M = M;
    sol.assign = M;
    sol.method = '';
end

function p = duree_machine(inst, j, i)
    switch inst.type
        case 'PM', p = inst.P(j, 1);
        case 'QM', p = inst.P(j, 1) / inst.v(i);
        case 'RM', p = inst.P(j, i);
    end
end
