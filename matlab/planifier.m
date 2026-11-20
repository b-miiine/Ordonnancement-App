function sol = planifier(inst, seq)
% PLANIFIER  Transforme une séquence (ou liste de priorité) en planning complet.
    switch inst.type
        case {'PM', 'QM', 'RM'}, sol = decoder_PM(inst, seq);
        case 'FS',               sol = decoder_FS(inst, seq);
        case 'JS',               sol = decoder_JS(inst, seq);
        otherwise, error('planifier : type inconnu "%s".', inst.type);
    end
end
