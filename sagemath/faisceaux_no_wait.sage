# SageMath script — flow shop no-wait, case des faisceaux.
# Exécuter dans SageMath : sage faisceaux_no_wait.sage
from itertools import permutations

P = [
    [12,15,30,8],   # J1
    [25,30,60,15],  # J2
    [20,25,45,12],  # J3
    [10,12,25,6],   # J4
    [8,10,20,5],    # J5
    [15,18,35,9]    # J6
]
fam = [0,1,2,0,0,1]  # A=0, B=1, C=2
Sfam = [[3,8,12],[8,3,10],[12,10,3]]

def transition(i, j, setup=True):
    ci = [sum(P[i][:k+1]) for k in range(4)]
    cjprev = [0] + [sum(P[j][:k]) for k in range(1,4)]
    s = [0,0,0,0]
    if setup:
        s[1] = Sfam[fam[i]][fam[j]]  # préparation sur M2 uniquement
    return max(ci[k] + s[k] - cjprev[k] for k in range(4))

def evaluate(seq, setup=True):
    start_last = 0
    for i,j in zip(seq[:-1], seq[1:]):
        start_last += transition(i,j,setup)
    return start_last + sum(P[seq[-1]])

def label(seq):
    return " - ".join("J%d" % (i+1) for i in seq)

for setup in [False, True]:
    best = None
    best_seq = []
    ties = []
    for seq in permutations(range(6)):
        c = evaluate(seq, setup)
        if best is None or c < best:
            best = c
            best_seq = [seq]
        elif c == best:
            best_seq.append(seq)
    print("Avec préparation M2" if setup else "Sans préparation")
    print("Cmax optimal =", best)
    print("Une séquence optimale =", label(best_seq[0]))
    print("Nombre de séquences ex aequo =", len(best_seq))
    print()

# Vérification de l'exemple manuel J4 -> J5 -> J1 (indices 3,4,0)
seq_demo = (3,4,0)
assert transition(3,4,False) == 29
assert transition(4,0,False) == 11
assert evaluate(seq_demo,False) == 105
print("Contrôle 3 lots J4-J5-J1 : Cmax = 105 min — OK")
