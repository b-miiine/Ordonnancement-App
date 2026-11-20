function seq = johnson(a, b)
% JOHNSON  Règle de Johnson pour deux machines (durées a sur M1, b sur M2).
%   Les lots avec a <= b passent d'abord, par a croissant ; les autres ensuite,
%   par b décroissant.
    a = a(:);  b = b(:);
    idx = (1:numel(a))';
    U = idx(a <= b);
    V = idx(a >  b);
    [~, o1] = sortrows([a(U), U]);
    [~, o2] = sortrows([-b(V), V]);
    seq = [U(o1); V(o2)]';
end
