function [ok, msgs] = verifier_planning(inst, sol)
% VERIFIER_PLANNING  Contrôle qu'un planning respecte toutes les contraintes.
%   Vérifie : dates d'arrivée, enchaînement des opérations d'un lot, no-wait,
%   durées, absence de chevauchement et temps de préparation sur chaque machine.
    tol = 1e-9;  msgs = {};
    J = sol.seq(:)';
    q = size(sol.C, 2);
    if any(sol.S(J, 1) < inst.r(J) - tol)
        msgs{end+1} = 'une opération démarre avant la date d''arrivée';
    end
    if q > 1
        ecart = sol.S(J, 2:q) - sol.C(J, 1:q-1);
        if any(ecart(:) < -tol), msgs{end+1} = 'opérations d''un lot qui se chevauchent'; end
        if inst.noWait && any(abs(ecart(:)) > tol)
            msgs{end+1} = 'contrainte no-wait violée';
        end
    end
    if any(strcmp(inst.type, {'FS', 'JS'}))
        dur = sol.C(J, :) - sol.S(J, :);
        if any(abs(dur(:) - reshape(inst.P(J, :), [], 1)) > tol)
            msgs{end+1} = 'durée d''opération incorrecte';
        end
    end
    L = ops_machines(inst, sol);
    for k = 1:inst.m
        a = L{k};
        for t = 2:size(a, 1)
            besoin = a(t-1, 3) + temps_prep(inst, a(t-1, 1), a(t, 1), k);
            if a(t, 2) < besoin - tol
                msgs{end+1} = sprintf('machine %d : chevauchement ou préparation non respectée (lots %d -> %d)', ...
                                      k, a(t-1, 1), a(t, 1)); %#ok<AGROW>
            end
        end
    end
    ok = isempty(msgs);
end
