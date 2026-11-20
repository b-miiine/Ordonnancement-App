function sub = sous_instance(inst, idx)
% SOUS_INSTANCE  Garde seulement les lots idx (dans cet ordre) : utile pour les exemples à la main.
    idx = idx(:)';
    sub = inst;
    sub.n = numel(idx);
    sub.P = inst.P(idx, :);
    sub.r = inst.r(idx);  sub.d = inst.d(idx);  sub.w = inst.w(idx);
    sub.fam = inst.fam(idx);
    if ~isempty(inst.route), sub.route = inst.route(idx, :); end
end
