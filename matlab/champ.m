function v = champ(s, nom, defaut)
% CHAMP  Lit un champ optionnel d'une structure (valeur par défaut si absent ou vide).
    if isstruct(s) && isfield(s, nom) && ~isempty(s.(nom))
        v = s.(nom);
    else
        v = defaut;
    end
end
