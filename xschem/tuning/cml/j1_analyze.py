#!/usr/bin/env python3
"""J1: cycle-to-cycle jitter of the clock at three points in the CML chain.

    j1_analyze.py results/J1_prbs.raw [t_start_ns]

Reads the ASCII rawfile written by the J1 decks (vectors ring, buf, rclk, each
already offset so that 0 is its crossing threshold) and reports, per vector,
the mean period and the RMS / pk-pk of period(n+1) - period(n), rising edges.
With vctrl from an ideal source the transient has no noise source, so any
cycle-to-cycle jitter here is deterministic: the data, coupled into the clock.
Pure stdlib (../../../CLAUDE.md).
"""
import sys
from statistics import mean, pstdev

path = sys.argv[1]
TSTART = float(sys.argv[2]) * 1e-9 if len(sys.argv) > 2 else 60e-9
UI = 1.665e-9

names, rows = [], []
with open(path) as f:
    mode = None
    for line in f:
        s = line.strip()
        if s.startswith("No. Variables:"):
            nv = int(s.split(":")[1])
        elif s.startswith("Variables:"):
            mode = "vars"
        elif s.startswith("Values:"):
            mode, cur = "vals", []
        elif mode == "vars" and s:
            names.append(s.split()[1])
            if len(names) == nv:
                mode = None
        elif mode == "vals" and s:
            parts = s.split()
            cur.append(float(parts[-1]))
            if len(cur) == nv:
                rows.append(cur)
                cur = []

t = [r[0] for r in rows]
for k, name in enumerate(names[1:], start=1):
    v = [r[k] for r in rows]
    edges = [t[i] + (t[i + 1] - t[i]) * (-v[i]) / (v[i + 1] - v[i])
             for i in range(len(t) - 1)
             if t[i] >= TSTART and v[i] < 0 <= v[i + 1]]
    per = [b - a for a, b in zip(edges, edges[1:])]
    c2c = [b - a for a, b in zip(per, per[1:])]
    if len(c2c) < 2:
        print(f"{name:5s} too few edges ({len(edges)})")
        continue
    print(f"{name:5s} edges {len(edges):4d}  f {1e-6/mean(per):7.2f} MHz  "
          f"period pk-pk {1e12*(max(per)-min(per)):6.2f} ps  "
          f"c2c RMS {1e12*pstdev(c2c):6.2f} ps ({100*pstdev(c2c)/UI:5.2f} % UI)  "
          f"pk-pk {1e12*(max(c2c)-min(c2c)):6.2f} ps")
