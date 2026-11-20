function t = taux_machines(inst, sol)
% TAUX_MACHINES  Taux de fonctionnement (TFR) et d'arrêt (TAR) de chaque machine.
%   TFR(k) = temps de traitement de la machine k / Cmax ;  TAR(k) = 1 - TFR(k).
    L = ops_machines(inst, sol);
    ev = evaluer(inst, sol);
    cmax = ev.Cmax;
    busy = zeros(1, inst.m);
    for k = 1:inst.m
        if ~isempty(L{k}), busy(k) = sum(L{k}(:, 3) - L{k}(:, 2)); end
    end
    t.busy = busy;
    t.TFR  = busy / cmax;
    t.TAR  = 1 - t.TFR;
end
