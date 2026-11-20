function P = generer_taillard(n, m, seed)
% GENERER_TAILLARD  Génère une instance de flow shop de Taillard (1993) à partir de sa graine.
%   P = generer_taillard(20, 5, 873654221) donne l'instance ta001 (20 lots, 5 machines).
%   Générateur congruentiel de Taillard : durées tirées dans [1, 99], machine par machine.
%   P est la matrice n x m (lot x machine).
    a = 16807;  b = 127773;  c = 2836;  M = 2^31 - 1;
    x = seed;
    D = zeros(m, n);
    for i = 1:m
        for j = 1:n
            k = floor(x / b);
            x = a * mod(x, b) - k * c;
            if x < 0, x = x + M; end
            D(i, j) = 1 + floor(x / M * 99);
        end
    end
    P = D';
end
