function noms = lister_methodes(inst, nmax)
% LISTER_METHODES  Méthodes compatibles avec le problème (pour remplir la liste déroulante de l'application).
    if nargin < 2, nmax = 8; end
    noms = {'FIFO', 'LIFO', 'SPT', 'LPT', 'EDD', 'WSPT', 'WDD'};
    if strcmp(inst.type, 'FS')
        if ~isempty(methode_johnson(inst, creer_crit({'Cmax'}))), noms{end+1} = 'Johnson'; end
        if inst.m >= 2, noms = [noms, {'CDS', 'NEH', 'Plus proche voisin'}]; end
    end
    noms{end+1} = 'Recherche locale';
    if inst.n <= nmax, noms{end+1} = 'Enumération'; end
end
