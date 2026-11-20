function sol = decoder_JS(inst, seq)
% DECODER_JS  Planning actif d'un job shop (principe de Giffler-Thompson).
%   seq est une liste de priorité : le lot en position 1 est le plus prioritaire.
%   À chaque étape : on repère l'opération qui peut finir le plus tôt, on forme
%   l'ensemble des opérations en conflit sur sa machine, et on retient celle
%   dont le lot est le plus prioritaire. La préparation (si active) est ajoutée
%   entre deux lots consécutifs sur une même machine.
    n = inst.n;  m = inst.m;  q = size(inst.P, 2);
    seq = seq(:)';
    prio = zeros(1, n);  prio(seq) = 1:numel(seq);
    S = zeros(n, q);  C = zeros(n, q);
    nxt = ones(n, 1);
    pret = inst.r(:);
    libre = zeros(1, m);  dernier = zeros(1, m);
    for etape = 1:(n * q)
        cand = find(nxt <= q)';
        est = inf(n, 1);  ect = inf(n, 1);  mk = zeros(n, 1);
        for j = cand
            k = inst.route(j, nxt(j));
            mk(j) = k;
            est(j) = max(pret(j), libre(k) + temps_prep(inst, dernier(k), j, k));
            ect(j) = est(j) + inst.P(j, nxt(j));
        end
        [~, js] = min(ect);
        ks = mk(js);
        conflit = cand(mk(cand)' == ks & est(cand)' < ect(js) - 1e-12);
        conflit = union(conflit, js);
        [~, pos] = min(prio(conflit));
        j = conflit(pos);
        o = nxt(j);
        S(j, o) = est(j);  C(j, o) = ect(j);
        pret(j) = ect(j);  libre(ks) = ect(j);  dernier(ks) = j;
        nxt(j) = nxt(j) + 1;
    end
    sol.seq = seq;  sol.S = S;  sol.C = C;
    sol.M = inst.route;
    sol.method = '';
end
