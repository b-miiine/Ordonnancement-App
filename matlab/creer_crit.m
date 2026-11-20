function crit = creer_crit(noms, poids)
% CREER_CRIT  Définit le ou les critères à optimiser.
%   crit = creer_crit({'Cmax'})                       un seul critère
%   crit = creer_crit({'Cmax','TT'}, [0.7 0.3])       plusieurs critères pondérés
%   Critères disponibles : Cmax, TT, TFT, Lmax, nT, TWT, TWFT.
    if ischar(noms), noms = {noms}; end
    if nargin < 2, poids = ones(1, numel(noms)); end
    valides = {'Cmax', 'TT', 'TFT', 'Lmax', 'nT', 'TWT', 'TWFT'};
    for c = 1:numel(noms)
        if ~any(strcmp(noms{c}, valides))
            error('creer_crit : critère inconnu "%s".', noms{c});
        end
    end
    crit.noms  = noms;
    crit.poids = poids(:)' / sum(poids);
    crit.ref   = ones(1, numel(noms));
end
