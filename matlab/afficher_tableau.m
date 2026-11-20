function afficher_tableau(res)
% AFFICHER_TABLEAU  Affiche le tableau comparatif de recommander dans la fenêtre de commande.
    fprintf('\n%-4s %-20s %8s %8s %8s %8s   %s\n', 'Rang', 'Méthode', 'Cmax', 'TT', 'TFT', 'Score', 'Remarque');
    fprintf('%s\n', repmat('-', 1, 90));
    for r = 1:size(res.cellules, 1)
        c = res.cellules(r, :);
        fprintf('%-4d %-20s %8.4g %8.4g %8.4g %8.3f   %s\n', c{1}, c{2}, c{3}, c{4}, c{5}, c{6}, c{7});
    end
    fprintf('\n%s\n\n', res.message);
end
