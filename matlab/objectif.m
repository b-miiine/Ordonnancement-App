function z = objectif(inst, sol, crit)
% OBJECTIF  Valeur à minimiser : somme pondérée des critères normalisés.
    v = evaluer(inst, sol);
    z = 0;
    for c = 1:numel(crit.noms)
        z = z + crit.poids(c) * v.(crit.noms{c}) / crit.ref(c);
    end
end
