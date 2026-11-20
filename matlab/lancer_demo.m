% LANCER_DEMO  Démonstration : recommandation de méthode sur le cas des faisceaux de câbles.
%   Modifier les paramètres ci-dessous, puis lancer :  lancer_demo
clear; clc;
addpath(fileparts(mfilename('fullpath')));

% --- Paramètres que l'utilisateur de l'application choisit ---------------------------
type      = 'FS';                 % 'FS', 'JS', 'PM', 'QM', 'RM'
avecPrep  = true;                 % temps de préparation
noWait    = true;                 % contrainte no-wait (flow shop)
avecDates = false;                % dates d'arrivée, délais, poids
criteres  = {'Cmax'};             % ex. {'Cmax','TT'}
poids     = 1;                    % ex. [0.7 0.3]
methode   = 'FIFO';               % méthode choisie par l'utilisateur
% ----------------------------------------------------------------------------------------

inst = exemple_faisceaux(type, avecPrep, noWait, avecDates);
crit = creer_crit(criteres, poids);
res  = recommander(inst, crit, methode);
afficher_tableau(res);

% Gantt de la méthode choisie et de la méthode recommandée
ic = res.choisie;  ib = res.meilleure;
figure('Position', [100 100 900 600]);
if ~isempty(ic)
    subplot(2, 1, 1);  tracer_gantt(inst, res.tableau(ic).sol, ['Méthode choisie : ' res.tableau(ic).nom]);
end
subplot(2, 1, 2);  tracer_gantt(inst, res.tableau(ib).sol, ['Méthode recommandée : ' res.tableau(ib).nom]);

% Taux de fonctionnement et d'arrêt de la méthode recommandée
t = taux_machines(inst, res.tableau(ib).sol);
for k = 1:inst.m
    fprintf('M%d : TFR = %.1f %%   TAR = %.1f %%\n', k, 100 * t.TFR(k), 100 * t.TAR(k));
end