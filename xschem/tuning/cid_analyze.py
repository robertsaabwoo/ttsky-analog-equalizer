#!/usr/bin/env python3
"""CID stress analysis. cid.dat from `wrdata cid.dat v(clk+) v(x1.net1)`:
columns t, clk+, t, vctrl (4 cols). For each window report mean clk period
(recovered-clock frequency during the no-transition run) and vctrl drift.
Pure stdlib.

Usage: cid_analyze.py <cid.dat>
"""
import sys
from statistics import mean, stdev

fn = sys.argv[1]
T, CK, VC = [], [], []
with open(fn) as f:
    for line in f:
        p = line.split()
        if len(p) < 4:
            continue
        try:
            t = float(p[0]); ck = float(p[1]); vc = float(p[3])
        except ValueError:
            continue
        T.append(t); CK.append(ck); VC.append(vc)

def period_in(t0, t1, vth=0.9):
    cr = []
    for i in range(1, len(T)):
        if t0 <= T[i] <= t1 and CK[i-1] < vth <= CK[i]:
            fr = (vth - CK[i-1]) / (CK[i] - CK[i-1])
            cr.append(T[i-1] + fr*(T[i]-T[i-1]))
    if len(cr) < 2:
        return None, 0
    per = [cr[i]-cr[i-1] for i in range(1, len(cr))]
    return per, len(cr)

def vc_in(t0, t1):
    v = [VC[i] for i in range(len(T)) if t0 <= T[i] <= t1]
    return (min(v), max(v), mean(v)) if v else (None, None, None)

ps = 1e12
# (label, t0_ns, t1_ns)
wins = [
    ("baseline (locked)", 1150, 1195),
    ("RUN5   no-trans",   1200.5, 1207.1),
    ("recover post-5",    1210, 1360),
    ("RUN10  no-trans",   1367.0, 1382.0),
    ("recover post-10",   1385, 1535),
    ("RUN15  no-trans",   1541.8, 1565.1),
    ("recover post-15",   1568, 1750),
    ("end (relock)",      1900, 2000),
]
print(f"{'window':20s} {'Tmean(ps)':>10s} {'f(MHz)':>9s} {'per_pp(ps)':>10s} "
      f"{'vc_min':>7s} {'vc_max':>7s} {'vc_drift(mV)':>12s}  ncyc")
for lab, a, b in wins:
    per, ncr = period_in(a*1e-9, b*1e-9)
    vmin, vmax, vavg = vc_in(a*1e-9, b*1e-9)
    if per:
        Tm = mean(per); f = 1/Tm/1e6; pp = (max(per)-min(per))*ps
        print(f"{lab:20s} {Tm*ps:10.2f} {f:9.2f} {pp:10.2f} "
              f"{vmin:7.4f} {vmax:7.4f} {(vmax-vmin)*1e3:12.2f}  {ncr}")
    else:
        print(f"{lab:20s} {'--':>10s} {'--':>9s} {'--':>10s} "
              f"{vmin if vmin is None else f'{vmin:7.4f}'} ... few cycles")
