#!/usr/bin/env python3
"""Is the phase detector alive? up/down time-high, pulse counts and ranges.

    pd_activity.py U7_*.raw   (or U4_*.raw)

Window UIs 8-28 (24 of the PRBS's transitions fall in UIs 10-58 for U1; here
it is 20 UI). A working bang-bang PD fires one line ~0.6 of the time at a
fixed offset and holds the other low; both lines stuck high (or both low)
means no phase information reaches the pump. Pure stdlib (../../../CLAUDE.md).
"""
import os
import re
import sys

UI = 1.665e-9
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "u1_analyze.py")).read()
exec(src.split("for raw in sys.argv")[0])   # read_raw

print(f"{'run':18s} up_high dn_high  up_pulses dn_pulses  up range (V)  dn range (V)  verdict")
for raw in sys.argv[1:]:
    tag = os.path.basename(raw)[3:-4]
    names, rows = read_raw(raw)
    idx = {re.sub(r"^[vi]\((.*)\)$", r"\1", n).lower(): i for i, n in enumerate(names)}
    t = [r[0] for r in rows]
    W = [j for j in range(1, len(t)) if 8 * UI <= t[j] <= 28 * UI]
    res = []
    for s in ("up0", "dn0"):
        vs = [rows[j][idx[s]] for j in W]
        vdd = max(1.6, max(vs))
        hi = sum(t[j] - t[j - 1] for j in W if rows[j][idx[s]] > 0.9) / (20 * UI)
        pul = sum(1 for j in W if rows[j - 1][idx[s]] <= 0.9 < rows[j][idx[s]])
        res.append((hi, pul, min(vs), max(vs)))
    (uh, up, umin, umax), (dh, dp, dmin, dmax) = res
    if uh > 0.95 and dh > 0.95:
        verdict = "DEAD: both stuck high"
    elif uh < 0.02 and dh < 0.02:
        verdict = "DEAD: both low"
    elif min(uh, dh) < 0.05 and max(uh, dh) > 0.3:
        verdict = "ok"
    else:
        verdict = "suspect"
    print(f"{tag:18s} {uh:6.2f} {dh:6.2f}   {up:5d}    {dp:5d}     {umin:.2f}..{umax:.2f}    "
          f"{dmin:.2f}..{dmax:.2f}    {verdict}")
