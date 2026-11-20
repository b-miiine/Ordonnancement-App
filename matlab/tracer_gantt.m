function tracer_gantt(inst, sol, titre, ax)
% TRACER_GANTT  Diagramme de Gantt : une ligne par machine, une couleur par lot.
%   Les temps de préparation sont dessinés en gris juste avant l'opération.
%   tracer_gantt(inst, sol, titre)       dessine dans une nouvelle figure
%   tracer_gantt(inst, sol, titre, ax)   dessine dans un axes existant (App Designer)
    if nargin < 3, titre = ''; end
    if nargin < 4 || isempty(ax), figure; ax = gca; end
    cla(ax);  hold(ax, 'on');
    n = inst.n;  m = inst.m;
    L = ops_machines(inst, sol);
    ev = evaluer(inst, sol);
    cmax = ev.Cmax;
    for k = 1:m
        y = m - k + 1;
        a = L{k};
        for t = 1:size(a, 1)
            j = a(t, 1);  deb = a(t, 2);  fin = a(t, 3);
            if t > 1
                s = temps_prep(inst, a(t-1, 1), j, k);
                if s > 0
                    rectangle('Parent', ax, 'Position', [deb - s, y - 0.4, s, 0.8], ...
                              'FaceColor', [0.8 0.8 0.8], 'EdgeColor', [0.5 0.5 0.5]);
                end
            end
            col = hsv2rgb([(j - 1) / max(n, 1), 0.45, 0.95]);
            rectangle('Parent', ax, 'Position', [deb, y - 0.4, fin - deb, 0.8], ...
                      'FaceColor', col, 'EdgeColor', [0.2 0.2 0.2]);
            text(deb + (fin - deb) / 2, y, sprintf('J%d', j), 'Parent', ax, ...
                 'HorizontalAlignment', 'center', 'FontSize', 8);
        end
    end
    set(ax, 'YTick', 1:m, 'YTickLabel', arrayfun(@(k) sprintf('M%d', k), m:-1:1, 'UniformOutput', false));
    xlim(ax, [0, cmax * 1.02]);  ylim(ax, [0.4, m + 0.6]);
    xlabel(ax, 'Temps (min)');
    title(ax, sprintf('%s   (Cmax = %g)', titre, cmax));
    box(ax, 'on');  hold(ax, 'off');
end