#!/usr/bin/env python3
"""U1 analysis: how much charge each phase decision puts into the loop filter.

    u1_analyze.py U1_frozen.raw U1_cml.raw [...]

Reads the bit pattern and clock offsets from the deck header (decks/U1_*.spice)
and the charge-pump output current per offset from the rawfile, over UIs
10-58. Per offset it reports, per data transition:
  * net charge, in units of Icp x 1 UI (1.0 = one clean 1-UI pulse at the
    nominal 1.26 uA). This is what sets the bang-bang loop's wander
    (bbloop.py --width): the switching spikes at each pulse edge are tens of
    uA for a few ps and change it substantially, so it is integrated, not
    inferred from pulse width;
  * time the pump is on (|i| > Icp/2), in UI;
  * the decision's sign (+ = up).
The first version of this script matched pulses to transitions to get a
delay; merged back-to-back pulses made that unreliable, so it was replaced.
Pure stdlib (../../../CLAUDE.md).
"""
import os
import sys
from statistics import mean, median, pstdev

UI = 1.665e-9
ICP = 1.26e-6
TR_MID = 50e-12        # gen_cml.pwl: transitions start at n*UI, 100 ps long


def read_raw(path):
    names, rows, nv, mode, cur = [], [], None, None, []
    with open(path) as f:
        for line in f:
            s = line.strip()
            if s.startswith("No. Variables:"):
                nv = int(s.split(":")[1])
            elif s.startswith("Variables:"):
                mode = "vars"
            elif s.startswith("Values:"):
                mode = "vals"
            elif mode == "vars" and s:
                names.append(s.split()[1])
                if len(names) == nv:
                    mode = None
            elif mode == "vals" and s:
                cur.append(float(s.split()[-1]))
                if len(cur) == nv:
                    rows.append(cur)
                    cur = []
    return names, rows


for raw in sys.argv[1:]:
    design = os.path.basename(raw)[3:-4]
    deck = os.path.join(os.path.dirname(raw) or ".", "decks", f"U1_{design}.spice")
    hdr = open(deck).read().splitlines()[:3]
    phases = [float(x) for x in hdr[1].split("offsets")[1].split("UI")[0].split()]
    bits = [int(c) for c in hdr[2].split()[2]]
    names, rows = read_raw(raw)
    t = [r[0] for r in rows]
    a, b = 10 * UI, 58 * UI
    ntr = sum(1 for n in range(11, 58) if bits[n] != bits[n - 1])
    print(f"\n=== {design}: {ntr} data transitions in UIs 10-58")
    print("offset   net charge/transition   on-time/transition   peak |i|")
    for k, ph in enumerate(phases):
        q = on = peak = 0.0
        for j in range(1, len(t)):
            if not a <= t[j] <= b:
                continue
            dt = t[j] - t[j - 1]
            i = rows[j][k + 1]
            q += i * dt
            peak = max(peak, abs(i))
            if abs(i) > ICP / 2:
                on += dt
        print(f"{ph:+6.2f}   {q / (ICP * UI) / ntr:+6.2f} Icp*UI           "
              f"{on / UI / ntr:5.2f} UI           {peak * 1e6:6.1f} uA")
