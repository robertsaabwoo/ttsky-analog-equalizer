#!/usr/bin/env python3
"""U2 analysis: vctrl disturbance per decision, per C2 configuration.

    u2_analyze.py U2_c2.raw

For each configuration (deck header), from 3 UI to the end:
  * fast step: the part of vctrl faster than ~0.25 UI (vctrl minus its own
    0.25-UI moving average), pk-pk and RMS -- the switching-spike kick a larger
    C2 should absorb;
  * across R: vctrl - C1 node, pk-pk -- the proportional kick;
  * drift: change of the C1 node per data transition -- the integral step.
Pure stdlib (../../../CLAUDE.md).
"""
import os
import sys
from statistics import pstdev

UI = 1.665e-9
raw = sys.argv[1]
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "u1_analyze.py")).read()
exec(src.split("for raw in sys.argv")[0])   # read_raw
hdr = open(os.path.join(os.path.dirname(raw) or ".", "decks", "U2_c2.spice")).read().splitlines()[:4]
labels = hdr[2].split()[2:]
bits = [int(c) for c in hdr[3].split()[2]]
ntr = sum(1 for n in range(4, len(bits)) if bits[n] != bits[n - 1])
names, rows = read_raw(raw)
t = [r[0] for r in rows]
dt = 2e-12
T = [3 * UI + i * dt for i in range(int((t[-1] - 3 * UI) / dt) - 1)]


def resample(col):
    out, j = [], 0
    for x in T:
        while t[j + 1] < x:
            j += 1
        f = (x - t[j]) / (t[j + 1] - t[j])
        out.append(rows[j][col] + f * (rows[j + 1][col] - rows[j][col]))
    return out


print(f"{ntr} data transitions after 3 UI")
print("config     fast step pp   fast RMS   across R pp   C1 drift/transition")
for k, lab in enumerate(labels):
    vc, c1 = resample(1 + 2 * k), resample(2 + 2 * k)
    m = int(0.25 * UI / dt)
    s = sum(vc[:m])
    fast = []
    for i in range(len(vc) - m):
        fast.append(vc[i + m // 2] - s / m)
        s += vc[i + m] - vc[i]
    vr = [a - b for a, b in zip(vc, c1)]
    print(f"{lab:9s}  {(max(fast) - min(fast)) * 1e3:8.1f} mV  {pstdev(fast) * 1e3:6.2f} mV  "
          f"{(max(vr) - min(vr)) * 1e3:8.1f} mV   {(c1[-1] - c1[0]) / ntr * 1e3:+7.2f} mV")
