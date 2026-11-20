function D = matrice_D(inst)
% MATRICE_D  Matrice n x n des délais no-wait D(i,j) (infini sur la diagonale).
    n = inst.n;
    cum = cumsum(inst.P, 2);
    D = inf(n, n);
    for i = 1:n
        for j = 1:n
            if i ~= j, D(i, j) = delai_nowait(inst, i, j, cum); end
        end
    end
end
