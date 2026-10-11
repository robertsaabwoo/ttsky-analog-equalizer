#!/usr/bin/env python3
"""How finely is each rising 0.9 V crossing of the first vector resolved?
Prints the timestep that straddles each crossing, and the c2c jitter split by
whether that step is fine or coarse. Pure stdlib. Usage: edge_steps.py raw t0_ns"""
import sys
from statistics import pstdev, mean
path, t0 = sys.argv[1], float(sys.argv[2]) * 1e-9
t, v, nv, mode, cur = [], [], None, None, []
with open(path) as f:
    for line in f:
        s = line.strip()
        if s.startswith("No. Variables:"): nv = int(s.split(":")[1])
        elif s.startswith("Values:"): mode = "v"
        elif mode == "v" and s:
            cur.append(float(s.split()[-1]))
            if len(cur) == nv:
                t.append(cur[0]); v.append(cur[1]); cur = []
E, S = [], []
for i in range(len(t) - 1):
    if t[i] >= t0 and v[i] < 0.9 <= v[i + 1]:
        E.append(t[i] + (t[i+1]-t[i]) * (0.9-v[i]) / (v[i+1]-v[i])); S.append(t[i+1]-t[i])
S2 = sorted(S)
print(f"{len(E)} edges; straddling step p10 {S2[len(S2)//10]*1e12:.1f}  p50 {S2[len(S2)//2]*1e12:.1f}  "
      f"p90 {S2[9*len(S2)//10]*1e12:.1f}  max {S2[-1]*1e12:.1f} ps")
P = [b-a for a, b in zip(E, E[1:])]
C = [b-a for a, b in zip(P, P[1:])]
print(f"c2c RMS {pstdev(C)*1e12:.2f} ps")
# c2c per edge triplet, by the coarsest straddling step in the triplet
for lim in (5e-12, 10e-12, 20e-12):
    sel = [C[i] for i in range(len(C)) if max(S[i:i+3]) <= lim]
    if len(sel) > 5: print(f"  triplets with all steps <= {lim*1e12:.0f} ps: n={len(sel)} c2c RMS {pstdev(sel)*1e12:.2f} ps")
