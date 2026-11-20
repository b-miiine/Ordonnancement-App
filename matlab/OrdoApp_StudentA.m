function OrdoApp_StudentA
% Interface d'aide a l'ordonnancement (MATLAB uifigure / uitabgroup).
% Compatible MATLAB R2019a et connectee au noyau :
% creer_inst, creer_crit, recommander, tracer_gantt, taux_machines.

addpath(fileparts(mfilename('fullpath')));

% Exemple faisceaux de reference (6 lots, 4 machines)
faisceauxRows = {
    'J1', 1, 12, 15, 30,  8,  0,  75, 2;
    'J2', 2, 25, 30, 60, 15,  5, 105, 3;
    'J3', 3, 20, 25, 45, 12, 10, 110, 3;
    'J4', 1, 10, 12, 25,  6,  0,  65, 1;
    'J5', 1,  8, 10, 20,  5,  8,  60, 1;
    'J6', 2, 15, 18, 35,  9,  3,  95, 2};
faisceauxSetup = [3 8 12; 8 3 10; 12 10 3];

fig = uifigure('Name', 'Aide a l''ordonnancement', 'Position', [80 60 1200 760]);
tg  = uitabgroup(fig, 'Position', [10 10 1180 740]);

tab1 = uitab(tg, 'Title', '1. Probleme');
tab2 = uitab(tg, 'Title', '2. Donnees');
tab3 = uitab(tg, 'Title', '3. Methode');
tab4 = uitab(tg, 'Title', '4. Resultats');
tabs = {tab1, tab2, tab3, tab4};

% --- Onglet 1 : Probleme ---
uilabel(tab1, 'Position', [25 655 180 25], 'Text', 'Environnement');
env = uidropdown(tab1, 'Position', [210 655 260 28], ...
    'Items', {'Flow shop', 'Machines paralleles PM', 'Machines paralleles QM', 'Machines paralleles RM', 'Job shop'}, ...
    'Value', 'Flow shop', ...
    'ValueChangedFcn', @(~,~) majDimensionsEtRegles());

uilabel(tab1, 'Position', [25 605 180 25], 'Text', 'Nombre de lots (n)');
spnN = uieditfield(tab1, 'numeric', 'Position', [210 605 90 28], ...
    'Limits', [1 200], 'RoundFractionalValues', 'on', 'Value', 6, ...
    'ValueChangedFcn', @(~,~) redimensionnerTableau());

uilabel(tab1, 'Position', [320 605 150 25], 'Text', 'Nombre de machines (m)');
spnM = uieditfield(tab1, 'numeric', 'Position', [475 605 90 28], ...
    'Limits', [1 50], 'RoundFractionalValues', 'on', 'Value', 4, ...
    'ValueChangedFcn', @(~,~) redimensionnerTableau());

uilabel(tab1, 'Position', [25 550 180 25], 'Text', 'Criteres a optimiser');
cbC   = uicheckbox(tab1, 'Position', [210 550 90 25], 'Text', 'Cmax', 'Value', true);
cbTT  = uicheckbox(tab1, 'Position', [310 550 90 25], 'Text', 'TT',   'Value', false);
cbTFT = uicheckbox(tab1, 'Position', [410 550 90 25], 'Text', 'TFT',  'Value', false);

uilabel(tab1, 'Position', [25 505 180 25], 'Text', 'Poids (ex. 1 ou 0.6 0.4)');
edtPoids = uieditfield(tab1, 'text', 'Position', [210 505 260 28], 'Value', '1');

uilabel(tab1, 'Position', [25 450 180 25], 'Text', 'Contraintes actives');
cbSetup  = uicheckbox(tab1, 'Position', [210 450 180 25], 'Text', 'Temps de preparation', ...
    'Value', true, 'ValueChangedFcn', @(~,~) majContraintesDonnees());
cbNoWait = uicheckbox(tab1, 'Position', [395 450 130 25], 'Text', 'No-wait', 'Value', true);
cbR      = uicheckbox(tab1, 'Position', [210 415 160 25], 'Text', 'Dates arrivee (r_j)', ...
    'Value', false, 'ValueChangedFcn', @(~,~) majContraintesDonnees());
cbD      = uicheckbox(tab1, 'Position', [375 415 160 25], 'Text', 'Delais (d_j)', ...
    'Value', false, 'ValueChangedFcn', @(~,~) majContraintesDonnees());
cbW      = uicheckbox(tab1, 'Position', [540 415 150 25], 'Text', 'Poids lots (w_j)', ...
    'Value', false, 'ValueChangedFcn', @(~,~) majContraintesDonnees());

% --- Onglet 2 : Donnees ---
lblContraintesEtat = uilabel(tab2, 'Position', [20 675 1130 25], ...
    'Text', 'Donnees du cas faisceaux : les colonnes r, d, w et la preparation suivent les contraintes cochees dans l''onglet 1.');
tbl = uitable(tab2, 'Data', faisceauxRows, 'Position', [20 420 1130 245], ...
    'ColumnName', {'Lot', 'Famille', 'M1', 'M2', 'M3', 'M4', 'r', 'd', 'w'}, ...
    'ColumnEditable', true(1, 9), 'ColumnWidth', {65, 80, 70, 70, 70, 70, 70, 70, 70});

lblSetup = uilabel(tab2, 'Position', [20 365 340 25], 'Text', 'Matrice de preparation Sfam (minutes)');
setupTbl = uitable(tab2, 'Data', faisceauxSetup, 'Position', [20 225 320 130], ...
    'ColumnName', {'A', 'B', 'C'}, 'RowName', {'A', 'B', 'C'}, 'ColumnEditable', true(1, 3));

uibutton(tab2, 'push', 'Text', 'Charger exemple faisceaux', ...
    'Position', [370 315 210 34], 'ButtonPushedFcn', @(~,~) chargerFaisceaux());

uibutton(tab2, 'push', 'Text', 'Importer fichier (.csv/.txt)', ...
    'Position', [370 265 210 34], 'ButtonPushedFcn', @(~,~) importerFichier());

uilabel(tab2, 'Position', [370 220 760 35], ...
    'Text', 'Astuce : modifiez n ou m dans l''onglet 1. Probleme pour ajuster le tableau, ou importez un fichier CSV/TXT.');

% --- Onglet 3 : Methode ---
uilabel(tab3, 'Position', [25 655 180 25], 'Text', 'Methode de reference');
method = uidropdown(tab3, 'Position', [210 655 280 28], ...
    'Items', {'FIFO', 'LIFO', 'SPT', 'LPT', 'EDD', 'WSPT', 'WDD', 'Johnson', 'CDS', 'NEH', 'Plus proche voisin', 'Recherche locale', 'Enumeration'}, ...
    'Value', 'FIFO');

% --- Onglet 4 : Resultats ---
uibutton(tab4, 'push', 'Text', 'Calculer / comparer', ...
    'Position', [20 665 180 35], 'ButtonPushedFcn', @(~,~) runCalculation());

result  = uitextarea(tab4, 'Position', [20 475 460 175], 'Editable', 'off');
compTbl = uitable(tab4, 'Position', [20 85 460 375], 'ColumnEditable', false);
ax      = uiaxes(tab4, 'Position', [505 95 640 555]);
title(ax, 'Diagramme de Gantt'); xlabel(ax, 'Temps (min)'); ylabel(ax, 'Machine');

% --- Boutons Precedent / Suivant sur chaque onglet ---
for idx = 1:4
    if idx > 1
        uibutton(tabs{idx}, 'push', 'Text', '<- Precedent', ...
            'Position', [20 20 130 34], 'ButtonPushedFcn', @(~,~) allerOnglet(idx - 1));
    end
    if idx < 4
        uibutton(tabs{idx}, 'push', 'Text', 'Suivant ->', ...
            'Position', [1020 20 130 34], 'ButtonPushedFcn', @(~,~) allerOnglet(idx + 1));
    end
end

majDimensionsEtRegles();

    function allerOnglet(targetIdx)
        tg.SelectedTab = tabs{targetIdx};
    end

    function majDimensionsEtRegles()
        isFS = strcmp(env.Value, 'Flow shop');
        if isFS
            cbNoWait.Enable = 'on';
        else
            cbNoWait.Enable = 'off';
            cbNoWait.Value = false;
        end
        redimensionnerTableau();
    end

    function majContraintesDonnees()
        nCols = size(tbl.Data, 2);
        if nCols < 6, return; end

        editMask = true(1, nCols);
        editMask(end - 2) = logical(cbR.Value);
        editMask(end - 1) = logical(cbD.Value);
        editMask(end)     = logical(cbW.Value);
        tbl.ColumnEditable = editMask;

        if cbSetup.Value
            setupTbl.Enable = 'on';
            lblSetup.Enable = 'on';
            etatS = 'Prep: ACTIF';
        else
            setupTbl.Enable = 'off';
            lblSetup.Enable = 'off';
            etatS = 'Prep: DESACTIVE';
        end

        etatR = 'r: DESACTIVE (0)';   if cbR.Value, etatR = 'r: ACTIF'; end
        etatD = 'd: DESACTIVE (inf)'; if cbD.Value, etatD = 'd: ACTIF'; end
        etatW = 'w: DESACTIVE (1)';   if cbW.Value, etatW = 'w: ACTIF'; end

        lblContraintesEtat.Text = sprintf('Contraintes dans Donnees ->  %s  |  %s  |  %s  |  %s', ...
            etatR, etatD, etatW, etatS);
    end

    function redimensionnerTableau()
        n = round(spnN.Value);
        m = round(spnM.Value);

        if strcmp(env.Value, 'Machines paralleles PM') || strcmp(env.Value, 'Machines paralleles QM')
            mCols = 1;
        else
            mCols = m;
        end

        oldData = tbl.Data;
        nOld = size(oldData, 1);
        mOld = max(1, size(oldData, 2) - 5);

        newData = cell(n, mCols + 5);
        for i = 1:n
            if i <= nOld
                lotName = oldData{i, 1};
                famVal  = oldData{i, 2};
                rVal    = oldData{i, end - 2};
                dVal    = oldData{i, end - 1};
                wVal    = oldData{i, end};
            else
                lotName = sprintf('J%d', i);
                famVal  = mod(i - 1, 3) + 1;
                rVal    = 0;
                dVal    = 100;
                wVal    = 1;
            end

            newData{i, 1} = lotName;
            newData{i, 2} = famVal;
            for k = 1:mCols
                if i <= nOld && k <= mOld
                    newData{i, 2 + k} = oldData{i, 2 + k};
                else
                    newData{i, 2 + k} = 10;
                end
            end
            newData{i, 2 + mCols + 1} = rVal;
            newData{i, 2 + mCols + 2} = dVal;
            newData{i, 2 + mCols + 3} = wVal;
        end

        colNames  = {'Lot', 'Famille'};
        colWidths = {65, 75};
        for k = 1:mCols
            colNames{end+1}  = sprintf('M%d', k); %#ok<AGROW>
            colWidths{end+1} = 65; %#ok<AGROW>
        end
        colNames  = [colNames, {'r', 'd', 'w'}];
        colWidths = [colWidths, {65, 65, 65}];

        tbl.ColumnName  = colNames;
        tbl.ColumnWidth = colWidths;
        tbl.Data        = newData;
        majContraintesDonnees();
    end

    function chargerFaisceaux()
        env.Value      = 'Flow shop';
        spnN.Value     = 6;
        spnM.Value     = 4;
        cbSetup.Value  = true;
        cbNoWait.Value = true;
        majDimensionsEtRegles();
        tbl.Data      = faisceauxRows;
        setupTbl.Data = faisceauxSetup;
        majContraintesDonnees();
    end

    function importerFichier()
        [fname, fpath] = uigetfile({'*.csv;*.txt', 'Fichiers donnees (*.csv, *.txt)'}, ...
            'Selectionner un fichier de donnees');
        if isequal(fname, 0), return; end
        fullp = fullfile(fpath, fname);
        try
            M = readmatrix(fullp);
            if isempty(M) || size(M, 2) < 2
                uialert(fig, 'Fichier vide ou format non reconnu.', 'Erreur import');
                return;
            end
            [nImp, mImp] = size(M);
            spnN.Value = nImp;
            spnM.Value = mImp;
            majDimensionsEtRegles();
            mCols = size(tbl.Data, 2) - 5;
            dNew = tbl.Data;
            for i = 1:nImp
                dNew{i, 1} = sprintf('J%d', i);
                dNew{i, 2} = 1;
                for k = 1:mCols
                    if k <= mImp
                        dNew{i, 2 + k} = M(i, k);
                    else
                        dNew{i, 2 + k} = 10;
                    end
                end
            end
            tbl.Data = dNew;
        catch ME
            uialert(fig, ME.message, 'Erreur lecture fichier');
        end
    end

    function runCalculation()
        criteres = {};
        if cbC.Value,   criteres{end+1} = 'Cmax'; end %#ok<AGROW>
        if cbTT.Value,  criteres{end+1} = 'TT';   end %#ok<AGROW>
        if cbTFT.Value, criteres{end+1} = 'TFT';  end %#ok<AGROW>
        if isempty(criteres)
            uialert(fig, 'Selectionnez au moins un critere.', 'Critere manquant');
            return;
        end

        poids = str2num(edtPoids.Value); %#ok<ST2NM>
        if isempty(poids)
            poids = ones(1, numel(criteres)) / numel(criteres);
        elseif numel(poids) == 1 && numel(criteres) > 1
            poids = repmat(poids, 1, numel(criteres));
        elseif numel(poids) ~= numel(criteres)
            uialert(fig, 'Le nombre de poids doit correspondre au nombre de criteres.', 'Poids invalides');
            return;
        end
        poids = poids / sum(poids);

        D = tbl.Data;
        n = size(D, 1);
        mCols = size(D, 2) - 5;
        m = round(spnM.Value);

        P   = zeros(n, mCols);
        fam = zeros(n, 1);
        r   = zeros(n, 1);
        d   = inf(n, 1);
        w   = ones(n, 1);

        for q = 1:n
            fam(q)  = double(D{q, 2});
            for k = 1:mCols
                P(q, k) = double(D{q, 2 + k});
            end
            if cbR.Value, r(q) = double(D{q, 2 + mCols + 1}); end
            if cbD.Value, d(q) = double(D{q, 2 + mCols + 2}); end
            if cbW.Value, w(q) = double(D{q, 2 + mCols + 3}); end
        end
        SF = double(setupTbl.Data);

        switch env.Value
            case 'Flow shop',              codeType = 'FS';
            case 'Machines paralleles PM', codeType = 'PM';
            case 'Machines paralleles QM', codeType = 'QM';
            case 'Machines paralleles RM', codeType = 'RM';
            case 'Job shop',               codeType = 'JS';
            otherwise,                     codeType = 'FS';
        end

        opts = struct('m', m, 'r', r, 'd', d, 'w', w, ...
            'fam', fam, 'Sfam', SF, 'setup', logical(cbSetup.Value), ...
            'noWait', logical(cbNoWait.Value));
        if strcmp(codeType, 'QM')
            opts.v = ones(1, m);
        end

        inst = creer_inst(codeType, P, opts);
        crit = creer_crit(criteres, poids);
        res  = recommander(inst, crit, method.Value);

        compTbl.ColumnName = res.entetes;
        compTbl.Data       = res.cellules;

        ib = res.meilleure;
        solBest = res.tableau(ib).sol;
        t = taux_machines(inst, solBest);
        tauxTxt = cell(inst.m, 1);
        for k = 1:inst.m
            tauxTxt{k} = sprintf('M%d: TFR=%.1f%% / TAR=%.1f%%', k, 100*t.TFR(k), 100*t.TAR(k));
        end

        contrActives = {};
        if cbSetup.Value,  contrActives{end+1} = 'prep';   end %#ok<AGROW>
        if cbNoWait.Value, contrActives{end+1} = 'nowait'; end %#ok<AGROW>
        if cbR.Value,      contrActives{end+1} = 'r';      end %#ok<AGROW>
        if cbD.Value,      contrActives{end+1} = 'd';      end %#ok<AGROW>
        if cbW.Value,      contrActives{end+1} = 'w';      end %#ok<AGROW>
        if isempty(contrActives), contrActives = {'aucune'}; end

        result.Value = [{res.message}; ...
            {sprintf('Sequence : %s | Contraintes : %s', num2str(solBest.seq), strjoin(contrActives, ', '))}; ...
            tauxTxt];

        tracer_gantt(inst, solBest, ['Recommandee : ' res.tableau(ib).nom], ax);
    end
end