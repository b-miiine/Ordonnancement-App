function seq = regle_priorite(inst, nom)
% REGLE_PRIORITE  Séquence (liste de priorité) donnée par une règle de tri.
%   FIFO : rj croissant            LIFO : inverse de FIFO
%   SPT  : durée totale croissante LPT  : inverse de SPT
%   EDD  : dj croissant
%   WSPT : (durée totale / poids) croissant
%   WDD  : (dj / poids) croissant  (date due pondérée)
%   Les égalités sont départagées par l'indice du lot.
    n = inst.n;
    idx = (1:n)';
    p = duree_totale(inst);
    sens = 1;
    switch upper(nom)
        case 'FIFO', key = inst.r;
        case 'LIFO', key = inst.r;  sens = -1;
        case 'SPT',  key = p;
        case 'LPT',  key = p;       sens = -1;
        case 'EDD',  key = inst.d;
        case 'WSPT', key = p ./ inst.w;
        case 'WDD',  key = inst.d ./ inst.w;
        otherwise, error('regle_priorite : règle inconnue "%s".', nom);
    end
    [~, ord] = sortrows([sens * key(:), sens * idx]);
    seq = ord(:)';
end

function p = duree_totale(inst)
    switch inst.type
        case {'PM', 'QM'}, p = inst.P(:, 1);
        case 'RM',         p = mean(inst.P, 2);
        otherwise,         p = sum(inst.P, 2);
    end
end
