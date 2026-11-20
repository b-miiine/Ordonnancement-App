function L = ops_machines(inst, sol)
% OPS_MACHINES  Opérations de chaque machine, triées par date de début.
%   L{k} est une matrice [lot, début, fin] pour la machine k.
    J = sol.seq(:)';
    q = size(sol.C, 2);
    tout = zeros(0, 4);
    for j = J
        for o = 1:q
            tout(end+1, :) = [sol.M(j, o), j, sol.S(j, o), sol.C(j, o)]; %#ok<AGROW>
        end
    end
    L = cell(1, inst.m);
    for k = 1:inst.m
        a = tout(tout(:, 1) == k, 2:4);
        if ~isempty(a), a = sortrows(a, [2 3]); end
        L{k} = a;
    end
end
