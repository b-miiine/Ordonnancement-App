function crit = calibrer_crit(inst, crit)
% CALIBRER_CRIT  Fixe les valeurs de référence qui normalisent un critère multiple.
%   Les références sont les valeurs obtenues avec la règle FIFO. Avec un seul
%   critère, aucune normalisation n'est nécessaire (référence = 1).
    if numel(crit.noms) == 1
        crit.ref = 1;
        return;
    end
    sol = planifier(inst, regle_priorite(inst, 'FIFO'));
    v = evaluer(inst, sol);
    for c = 1:numel(crit.noms)
        crit.ref(c) = max(v.(crit.noms{c}), 1);
    end
end
