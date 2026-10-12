#!/usr/bin/env python3
"""Extract the charge-pump current for ONE phase decision from the U1 benches.

    u1_templates.py U1_frozen.raw U1_cml.raw ...  -> templates.json

For each design: the measured pump current around an isolated data transition
(bits ..0 0 1 1..), from the transition to +3 UI, averaged into UI/NSUB bins
(bin averages keep each switching spike's charge exactly). The `up` template is
taken at clock offset -0.03 UI and the `down` template at +0.10 UI (the U1
characteristic flips sign between +0.03 and +0.10). bbloop.py --template uses
these in place of its ideal rectangular pulse, so injection onto C2 is in the
loop model. Pure stdlib (../../../CLAUDE.md).
"""
import json
import os
import sys

UI = 1.665e-9
NSUB = 32
SPAN = 3          # UI after the transition

src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "u1_analyze.py")).read()
exec(src.split("for raw in sys.argv")[0])   # read_raw

out = {}
for raw in sys.argv[1:]:
    design = os.path.basename(raw)[3:-4]
    hdr = open(os.path.join(os.path.dirname(raw) or ".", "decks", f"U1_{design}.spice")).read().splitlines()[:3]
    phases = [float(x) for x in hdr[1].split("offsets")[1].split("UI")[0].split()]
    bits = [int(c) for c in hdr[2].split()[2]]
    n = next(m for m in range(12, 50) if bits[m] != bits[m - 1] and bits[m - 2] == bits[m - 1]
             and bits[m + 1] == bits[m] and bits[m + 2] == bits[m])
    names, rows = read_raw(raw)
    t = [r[0] for r in rows]
    tpl = {}
    for name, ph in (("up", -0.03), ("down", 0.10)):
        k = phases.index(ph) + 1
        bins = []
        for s in range(SPAN * NSUB):
            a, b = n * UI + s * UI / NSUB, n * UI + (s + 1) * UI / NSUB
            q = 0.0
            for j in range(1, len(t)):
                lo, hi = max(t[j - 1], a), min(t[j], b)
                if hi > lo:
                    q += 0.5 * (rows[j - 1][k] + rows[j][k]) * (hi - lo)
            bins.append(q / (b - a))
        tpl[name] = bins
        print(f"{design:7s} {name:4s}: charge {sum(bins) * UI / NSUB / (1.26e-6 * UI):+.2f} Icp*UI")
    out[design] = tpl
json.dump({"nsub": NSUB, "ui": UI, "templates": out}, open("templates.json", "w"))
