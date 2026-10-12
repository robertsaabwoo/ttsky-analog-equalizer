#!/usr/bin/env python3
"""U8 analysis: net pump charge per data transition vs clock offset, per corner.

    u8_analyze.py U8_*.raw

Charge in units of Icp x 1 UI, over UIs 8-28. A clean bang-bang PD reads
about the same magnitude with one sign on each side of a single crossing; the
crossing (linear interpolation) is the PD's balance point, which the loop
locks to. Values near zero over a wide range of offsets would instead mean a
dead zone or random decisions. Pure stdlib (../../../CLAUDE.md).
"""
import os
import sys

UI = 1.665e-9
ICP = 1.26e-6
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "u1_analyze.py")).read()
exec(src.split("for raw in sys.argv")[0])   # read_raw

for raw in sys.argv[1:]:
    tag = os.path.basename(raw)[3:-4]
    hdr = open(os.path.join(os.path.dirname(raw) or ".", "decks", f"U8_{tag}.spice")).read().splitlines()[:3]
    offs = [float(x) for x in hdr[1].split("offsets")[1].split("UI")[0].split()]
    bits = [int(c) for c in hdr[2].split()[2]]
    ntr = sum(1 for n in range(9, 28) if bits[n] != bits[n - 1])
    names, rows = read_raw(raw)
    t = [r[0] for r in rows]
    W = [j for j in range(1, len(t)) if 8 * UI <= t[j] <= 28 * UI]
    q = []
    for k in range(len(offs)):
        q.append(sum(rows[j][k + 1] * (t[j] - t[j - 1]) for j in W) / (ICP * UI) / ntr)
    cross = [offs[k] + (offs[k + 1] - offs[k]) * q[k] / (q[k] - q[k + 1])
             for k in range(len(q) - 1) if q[k] * q[k + 1] < 0]
    print(f"{tag:8s} " + "  ".join(f"{o:+.2f}:{v:+5.2f}" for o, v in zip(offs, q)) +
          f"   | balance at {', '.join(f'{c:+.3f}' for c in cross) or 'none'} UI")
