function [P, info] = lire_taillard(fichier)
% LIRE_TAILLARD  Lit un fichier d'instance de flow shop au format Taillard.
%   Format : n m graine UB LB, puis m lignes de n durées (une ligne par machine).
%   P = matrice n x m (lot x machine) ; info = struct(seed, UB, LB).
    f = fopen(fichier, 'r');
    if f < 0, error('lire_taillard : impossible d''ouvrir %s', fichier); end
    v = fscanf(f, '%f');
    fclose(f);
    n = v(1);  m = v(2);
    info.seed = v(3);  info.UB = v(4);  info.LB = v(5);
    P = reshape(v(6:5 + n * m), n, m);
end
