function s = temps_prep(inst, i, j, k)
% TEMPS_PREP  Temps de préparation entre le lot i (précédent) et le lot j sur la machine k.
%   Renvoie 0 s'il n'y a pas de lot précédent (i = 0), si la préparation est
%   désactivée ou si elle ne s'applique pas à la machine k.
    s = 0;
    if ~inst.setup || i == 0, return; end
    if k <= numel(inst.setupMach) && inst.setupMach(k)
        s = inst.Sfam(inst.fam(i), inst.fam(j));
    end
end
