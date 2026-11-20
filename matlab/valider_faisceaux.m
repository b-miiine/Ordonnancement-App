function valider_faisceaux
% Validation indépendante par énumération exhaustive : 6! = 720 séquences.
P = [12 15 30 8; 25 30 60 15; 20 25 45 12; ...
     10 12 25 6; 8 10 20 5; 15 18 35 9];
fam = [1 2 3 1 1 2]';
SF = [3 8 12; 8 3 10; 12 10 3];
N = 6; allSeq = perms(1:N);
best0 = inf; best1 = inf; seq0=[]; seq1=[];
for q=1:size(allSeq,1)
    s=allSeq(q,:);
    c0=calcNoWait(s,P,fam,SF,false);
    c1=calcNoWait(s,P,fam,SF,true);
    if c0<best0, best0=c0; seq0=s; end
    if c1<best1, best1=c1; seq1=s; end
end
fprintf('Sans préparation : Cmax=%g, séquence=%s\n',best0,mat2str(seq0));
fprintf('Avec préparation : Cmax=%g, séquence=%s\n',best1,mat2str(seq1));
assert(best0==239,'Le contrôle sans préparation doit donner 239.');
assert(best1==239,'Le contrôle avec préparation doit donner 239.');
end

function cmax=calcNoWait(seq,P,fam,SF,useSetup)
start=0;
for q=1:length(seq)-1
    i=seq(q); j=seq(q+1);
    ci=cumsum(P(i,:)); cjprev=[0 cumsum(P(j,1:end-1))];
    st=zeros(1,size(P,2));
    if useSetup, st(2)=SF(fam(i),fam(j)); end
    start=start+max(ci+st-cjprev);
end
cmax=start+sum(P(seq(end),:));
end
