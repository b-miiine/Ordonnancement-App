function sol = methode_johnson(inst, crit)
% METHODE_JOHNSON  Johnson pour un flow shop à 2 machines, ou à 3 machines si
%   min(M1) >= max(M2) ou min(M3) >= max(M2) (cas particulier de Johnson).
%   Renvoie [] si la méthode n'est pas applicable.
    sol = [];
    if ~strcmp(inst.type, 'FS'), return; end
    P = inst.P;
    if inst.m == 2
        seq = johnson(P(:, 1), P(:, 2));
    elseif inst.m == 3 && (min(P(:, 1)) >= max(P(:, 2)) || min(P(:, 3)) >= max(P(:, 2)))
        seq = johnson(P(:, 1) + P(:, 2), P(:, 2) + P(:, 3));
    else
        return;
    end
    sol = planifier(inst, seq);
    sol.method = 'Johnson';
end
