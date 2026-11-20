function inst = exemple_faisceaux(type, avecPrep, noWait, avecDates)
% EXEMPLE_FAISCEAUX  Cas d'étude de la version 1 : 6 lots de faisceaux de câbles.
%   inst = exemple_faisceaux('FS', true, true, false)
%   type      : 'FS' (défaut), 'JS', 'PM', 'QM' ou 'RM' (variantes de démonstration à 2 machines)
%   avecPrep  : temps de préparation sur M2 (défaut false)
%   noWait    : contrainte no-wait, flow shop seulement (défaut false)
%   avecDates : ajoute des dates d'arrivée, délais et poids (défaut false)
%
%   ATTENTION : r, d et w ci-dessous sont des PROPOSITIONS pour tester TT et TFT.
%   Ils doivent être validés par le groupe (voir le plan du projet).
    if nargin < 1, type = 'FS'; end
    if nargin < 2, avecPrep = false; end
    if nargin < 3, noWait = false; end
    if nargin < 4, avecDates = false; end
    P = [12 15 30  8;
         25 30 60 15;
         20 25 45 12;
         10 12 25  6;
          8 10 20  5;
         15 18 35  9];            % durées : lots x machines
    o.fam  = [1 2 3 1 1 2]';      % familles : A=1, B=2, C=3
    o.Sfam = [ 3  8 12;
               8  3 10;
              12 10  3];          % préparation entre familles
    o.setup = avecPrep;
    o.noWait = noWait;
    if avecDates
        o.r = [0 0 0 10 20 30]';             % PROPOSITION
        o.d = [120 200 150 100 90 190]';     % PROPOSITION
        o.w = [1 3 2 1 1 2]';                % PROPOSITION
    end
    switch upper(type)
        case 'FS'
            o.setupMach = [0 1 0 0];
            inst = creer_inst('FS', P, o);
        case 'JS'
            o.setupMach = [0 1 0 0];
            o.noWait = false;
            inst = creer_inst('JS', P, o);
        case 'PM'
            o.m = 2;  o.noWait = false;
            inst = creer_inst('PM', sum(P, 2), o);
        case 'QM'
            o.m = 2;  o.v = [1 1.5];  o.noWait = false;
            inst = creer_inst('QM', sum(P, 2), o);
        case 'RM'
            o.noWait = false;
            inst = creer_inst('RM', [sum(P, 2), round(sum(P, 2) .* [1.2; 0.8; 1.0; 1.3; 0.9; 1.1])], o);
        otherwise
            error('exemple_faisceaux : type inconnu "%s".', type);
    end
end
