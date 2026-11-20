function D = delai_nowait(inst, i, j, cum)
% DELAI_NOWAIT  Délai minimal entre le début du lot i et celui du lot j qui le suit.
%   D(i,j) = max sur k de [ C(i,k) + S_k(i,j) - C(j,k-1) ]
%   où C(i,k) = durée cumulée du lot i de M1 à Mk (cum = cumsum(P, 2)).
    m = size(cum, 2);
    D = -inf;
    for k = 1:m
        if k == 1, cprec = 0; else cprec = cum(j, k-1); end
        D = max(D, cum(i, k) + temps_prep(inst, i, j, k) - cprec);
    end
end
