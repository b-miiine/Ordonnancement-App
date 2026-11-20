function inst = creer_inst(type, P, opts)
% CREER_INST  Construit la structure "inst" décrivant un problème d'ordonnancement.
%
%   inst = creer_inst(type, P, opts)
%
%   type : 'PM' (machines parallèles identiques), 'QM' (vitesses différentes),
%          'RM' (durées indépendantes par machine), 'FS' (flow shop), 'JS' (job shop)
%   P    : durées
%            PM, QM : vecteur n x 1 (durée du lot j)
%            RM     : matrice n x m (durée du lot j sur la machine i)
%            FS     : matrice n x m (durée du lot j sur la machine k)
%            JS     : matrice n x m (durée de la k-ième opération du lot j)
%   opts : structure facultative, champs possibles :
%            m          nombre de machines (PM, QM)
%            v          vitesses des machines (QM), vecteur 1 x m
%            r, d, w    dates d'arrivée, délais de livraison, poids (vecteurs n x 1)
%            fam, Sfam  famille de chaque lot et matrice de préparation entre familles
%            setup      true si les temps de préparation sont actifs
%            setupMach  vecteur 1 x m : machines sur lesquelles la préparation s'applique
%            noWait     true pour la contrainte no-wait (flow shop)
%            route      matrice n x m : machine de la k-ième opération (job shop)
    if nargin < 3, opts = struct(); end
    type = upper(type);
    n = size(P, 1);
    switch type
        case {'PM', 'QM'}
            m = champ(opts, 'm', 2);
            P = P(:, 1);
        case {'RM', 'FS', 'JS'}
            m = size(P, 2);
        otherwise
            error('creer_inst : type inconnu "%s" (PM, QM, RM, FS ou JS).', type);
    end
    inst.type      = type;
    inst.n         = n;
    inst.m         = m;
    inst.P         = P;
    inst.v         = champ(opts, 'v', ones(1, m));
    inst.r         = champ(opts, 'r', zeros(n, 1));  inst.r = inst.r(:);
    inst.d         = champ(opts, 'd', inf(n, 1));    inst.d = inst.d(:);
    inst.w         = champ(opts, 'w', ones(n, 1));   inst.w = inst.w(:);
    inst.fam       = champ(opts, 'fam', ones(n, 1)); inst.fam = inst.fam(:);
    inst.Sfam      = champ(opts, 'Sfam', 0);
    inst.setup     = champ(opts, 'setup', false);
    inst.setupMach = champ(opts, 'setupMach', true(1, m));
    inst.noWait    = champ(opts, 'noWait', false);
    if strcmp(type, 'JS')
        inst.route = champ(opts, 'route', repmat(1:m, n, 1));
    else
        inst.route = [];
    end
    if any(inst.w <= 0), error('creer_inst : les poids doivent être > 0.'); end
end
