function nechecs = test_validation()
% TEST_VALIDATION
% Verifie le code sur les resultats de controle et sur des cas connus.
% Compatible MATLAB R2019.
% Lancer : test_validation

    addpath(fileparts(mfilename('fullpath')));
    nechecs = 0;
    crit = creer_crit({'Cmax'});

    fprintf('\n=== 1. Exemple a la main : 3 lots J4, J5, J1 ===\n');

    inst = exemple_faisceaux('FS', false, true, false);
    sub = sous_instance(inst, [4 5 1]);
    cum = cumsum(sub.P, 2);

    nechecs = nechecs + verifier( ...
        'D(J4,J5)', delai_nowait(sub, 1, 2, cum), 29);

    nechecs = nechecs + verifier( ...
        'D(J5,J1)', delai_nowait(sub, 2, 3, cum), 11);

    sol = planifier(sub, [1 2 3]);
    ev = evaluer(sub, sol);

    nechecs = nechecs + verifier( ...
        'Cmax(J4,J5,J1)', ev.Cmax, 105);


    fprintf('\n=== 2. Cas des faisceaux : resultats de controle ===\n');

    % Colonnes :
    % preparation, noWait, Cmax naive attendu, meilleur Cmax attendu

    cas = {
        false, true,  264, 239;
        true,  true,  267, 239;
        false, false, 261, 239
    };

    noms = {
        'no-wait sans preparation'
        'no-wait avec preparation'
        'flow shop classique sans preparation'
    };

    for c = 1:size(cas, 1)

        inst = exemple_faisceaux( ...
            'FS', cas{c, 1}, cas{c, 2}, false);

        en = methode_enumeration(inst, crit, 8);

        % Sequence naive J1 a J6
        sol_naif = planifier(inst, 1:6);
        ev_naif = evaluer(inst, sol_naif);

        nechecs = nechecs + verifier( ...
            ['naif J1..J6, ' noms{c}], ...
            ev_naif.Cmax, cas{c, 3});

        % Meilleure solution par enumeration
        ev_best = evaluer(inst, en.sol);

        nechecs = nechecs + verifier( ...
            ['meilleure, ' noms{c}], ...
            ev_best.Cmax, cas{c, 4});


        if c == 1

            nechecs = nechecs + verifier( ...
                'nombre de sequences optimales', ...
                en.nbOpt, 2);

            attendues = [
                5 1 3 2 6 4;
                5 1 6 3 2 4
            ];

            nechecs = nechecs + verifier( ...
                'sequences optimales attendues', ...
                isequal(en.optSeqs, attendues), true);

        elseif c == 2

            nechecs = nechecs + verifier( ...
                'sequence optimale no-wait avec preparation', ...
                isequal(en.sol.seq, [5 1 6 3 2 4]), true);

            ev_pire = evaluer(inst, en.pire);

            nechecs = nechecs + verifier( ...
                'pire sequence : Cmax', ...
                ev_pire.Cmax, 301);

            sol_test = planifier(inst, [3 4 6 1 5 2]);
            ev_test = evaluer(inst, sol_test);

            nechecs = nechecs + verifier( ...
                'J3,J4,J6,J1,J5,J2 : Cmax', ...
                ev_test.Cmax, 301);

        end
    end


    fprintf('\n=== 3. Faisabilite des plannings aleatoires ===\n');

    rand('state', 1); %#ok<RAND>

    types = {'FS', 'JS', 'PM', 'QM', 'RM'};

    nok = 0;
    ntot = 0;

    for ti = 1:numel(types)

        for essai = 1:40

            inst = exemple_faisceaux( ...
                types{ti}, ...
                rand > 0.5, ...
                strcmp(types{ti}, 'FS') && rand > 0.5, ...
                rand > 0.5);

            seq = randperm(inst.n);
            sol = planifier(inst, seq);

            [ok, msgs] = verifier_planning(inst, sol);

            ntot = ntot + 1;
            nok = nok + ok;

            if ~ok
                fprintf('   %s : %s\n', ...
                    types{ti}, strjoin(msgs, '; '));
            end

        end
    end

    nechecs = nechecs + verifier( ...
        sprintf('plannings faisables (%d tests)', ntot), ...
        nok, ntot);


    fprintf('\n=== 4. Machines paralleles : exemple a la main ===\n');

    o.m = 2;
    o.d = [5 5 6 8]';

    ip = creer_inst('PM', [4 3 2 5]', o);

    sp = planifier(ip, [1 2 3 4]);
    v = evaluer(ip, sp);

    nechecs = nechecs + verifier( ...
        'PM FIFO : Cmax', v.Cmax, 9);

    nechecs = nechecs + verifier( ...
        'PM FIFO : TFT', v.TFT, 21);

    nechecs = nechecs + verifier( ...
        'PM FIFO : TT', v.TT, 1);

    nechecs = nechecs + verifier( ...
        'PM FIFO : machines (1,2,2,1)', ...
        isequal(sp.assign', [1 2 2 1]), true);


    % Machines paralleles avec vitesses differentes
    iq = creer_inst('QM', [6 4]', struct('m', 2, 'v', [1 2]));

    sq = planifier(iq, [1 2]);

    nechecs = nechecs + verifier( ...
        'QM : lot 1 sur M2 de vitesse 2 -> fin 3', ...
        sq.C(1), 3);


    fprintf('\n=== 5. Johnson = enumeration (30 instances aleatoires) ===\n');

    ok2 = 0;

    for essai = 1:30

        P = randi(20, 6, 2);

        i2 = creer_inst('FS', P);

        sj = methode_johnson(i2, crit);
        evj = evaluer(i2, sj);
        cj = evj.Cmax;

        res_enum = methode_enumeration(i2, crit, 7);
        ev_enum = evaluer(i2, res_enum.sol);
        ce = ev_enum.Cmax;

        ok2 = ok2 + (cj == ce);

    end

    nechecs = nechecs + verifier( ...
        'Johnson optimal', ok2, 30);


    fprintf('\n=== 6. Instance de Taillard ta001 ===\n');

    P = generer_taillard(20, 5, 873654221);

    fprintf('   premieres durees generees : %s\n', ...
        mat2str(P(1:8, 1)'));

    nechecs = nechecs + verifier( ...
        'borne inferieure ta001 (publiee : 1232)', ...
        borne_inf(P), 1232);

    it = creer_inst('FS', P);


    % NEH
    tic;
    sn = neh(it, crit);
    tn = toc;

    evn = evaluer(it, sn);
    cn = evn.Cmax;


    % CDS
    sc = cds(it, crit);
    evc = evaluer(it, sc);
    cc = evc.Cmax;


    % NEH + recherche locale
    tic;
    sl = recherche_locale(it, crit, sn.seq);
    tl = toc;

    evl = evaluer(it, sl);
    cl = evl.Cmax;


    fprintf(['   CDS = %g | NEH = %g (%.1f s) | ' ...
        'NEH + recherche locale = %g (%.1f s) | ' ...
        'meilleure valeur connue = 1278\n'], ...
        cc, cn, tn, cl, tl);

    nechecs = nechecs + verifier( ...
        'aucun resultat sous l optimum 1278', ...
        all([cc cn cl] >= 1278), true);

    fprintf('   ecarts a 1278 : CDS %.2f %% | NEH %.2f %% | NEH + RL %.2f %%\n', ...
        (cc - 1278) / 1278 * 100, ...
        (cn - 1278) / 1278 * 100, ...
        (cl - 1278) / 1278 * 100);


    fprintf('\n=== 7. Job shop classique ft06 (optimum connu : 55) ===\n');

    ij = exemple_ft06();

    resultats = [];

    regles = {'FIFO', 'LIFO', 'SPT', 'LPT'};

    for r = 1:numel(regles)

        nom_regle = regles{r};

        s = planifier(ij, regle_priorite(ij, nom_regle));

        [ok, msgs] = verifier_planning(ij, s);

        nechecs = nechecs + verifier( ...
            ['ft06 ' nom_regle ' faisable'], ok, true);

        evr = evaluer(ij, s);

        resultats(end+1) = evr.Cmax; %#ok<AGROW>

    end

    fprintf('   regles FIFO, LIFO, SPT, LPT : %s\n', ...
        mat2str(resultats));


    % Enumeration des listes de priorite
    en = methode_enumeration(ij, crit, 8);

    ev_en = evaluer(ij, en.sol);

    fprintf('   meilleure liste de priorite (720 listes) : Cmax = %g\n', ...
        ev_en.Cmax);


    % Recherche locale
    sl = recherche_locale(ij, crit, en.sol.seq);

    ev_sl = evaluer(ij, sl);

    nechecs = nechecs + verifier( ...
        'ft06 : Cmax >= optimum 55', ...
        ev_sl.Cmax >= 55, true);


    fprintf('   ecart a l optimum 55 : %.1f %%\n', ...
        (ev_en.Cmax - 55) / 55 * 100);


    fprintf('\n=== Bilan : %d test(s) en echec ===\n\n', nechecs);

end


% =========================================================
% FONCTION DE VERIFICATION DES RESULTATS
% =========================================================

function e = verifier(nom, obtenu, attendu)

    if isequal(obtenu, attendu) || ...
       (isnumeric(obtenu) && isnumeric(attendu) && ...
       numel(obtenu) == 1 && numel(attendu) == 1 && ...
       abs(obtenu - attendu) < 1e-9)

        fprintf('  PASS  %s\n', nom);
        e = 0;

    else

        fprintf('  FAIL  %s : obtenu %s, attendu %s\n', ...
            nom, mat2str(obtenu), mat2str(attendu));

        e = 1;

    end

end


% =========================================================
% BORNE INFERIEURE DE TAILLARD
% =========================================================

function lb = borne_inf(P)

% Borne inferieure de Taillard :
% max sur les machines de (plus petit avant + charge + plus petit apres)

    [n, m] = size(P);

    lb = 0;

    for k = 1:m

        if k > 1
            tete = min(sum(P(:, 1:k-1), 2));
        else
            tete = 0;
        end

        if k < m
            queue = min(sum(P(:, k+1:m), 2));
        else
            queue = 0;
        end

        lb = max(lb, tete + sum(P(:, k)) + queue);

    end

    lb = max(lb, max(sum(P, 2)));

end