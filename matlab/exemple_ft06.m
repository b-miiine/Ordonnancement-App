function inst = exemple_ft06()
% EXEMPLE_FT06  Instance de job shop 6 x 6 de Fisher et Thompson (1963), makespan optimal = 55.
%   Source des données : instance ft06 (OR-Library / JSPLIB).
    route = [3 1 2 4 6 5;
             2 3 5 6 1 4;
             3 4 6 1 2 5;
             2 1 3 4 5 6;
             3 2 5 6 1 4;
             2 4 6 1 5 3];        % machines (numérotées de 1 à 6)
    P = [1 3 6 7 3 6;
         8 5 10 10 10 4;
         5 4 8 9 1 7;
         5 5 5 3 8 9;
         9 3 5 4 3 1;
         3 3 9 10 4 1];           % durée de chaque opération, dans l'ordre de la gamme
    inst = creer_inst('JS', P, struct('route', route));
end
