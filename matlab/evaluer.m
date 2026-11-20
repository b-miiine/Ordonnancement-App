function crit = evaluer(inst, sol)
% EVALUER  Calcule tous les critères à partir d'un planning.
%   Seuls les lots présents dans sol.seq sont pris en compte.
%   Cmax = max Cj ; TFT = somme(Cj - rj) ; TT = somme max(0, Cj - dj)
%   Lmax = max(Cj - dj) ; nT = nombre de lots en retard
%   TWT, TWFT = versions pondérées de TT et TFT.
    J  = sol.seq(:);
    Cj = max(sol.C(J, :), [], 2);
    r = inst.r(J);  d = inst.d(J);  w = inst.w(J);
    F = Cj - r;
    T = max(0, Cj - d);
    crit.Cmax = max(Cj);
    crit.TFT  = sum(F);
    crit.TT   = sum(T);
    if any(isfinite(d))
        L = Cj - d;
        crit.Lmax = max(L(isfinite(d)));
    else
        crit.Lmax = 0;
    end
    crit.nT   = sum(T > 0);
    crit.TWT  = sum(w .* T);
    crit.TWFT = sum(w .* F);
end
