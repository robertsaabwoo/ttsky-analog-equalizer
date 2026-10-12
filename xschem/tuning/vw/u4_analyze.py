#!/usr/bin/env python3
"""U4 analysis: the frozen PD's opposing-line glitch and the charge it cancels.

    u4_analyze.py U4_*.raw

Per rawfile (UIs 8-28): which line carries the decisions (the one high for
longer), the glitches on the other line (excursions above VDD/2 shorter than
0.3 UI: count, width, peak), and the pump charge split by sign. "cancelled"
is the opposing charge as a fraction of the main charge; at tt/27C/1.8V U3
measured 61 %. Pure stdlib (../../../CLAUDE.md).
"""
import os
import re
import sys

UI = 1.665e-9
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "u1_analyze.py")).read()
exec(src.split("for raw in sys.argv")[0])   # read_raw

print(f"{'run':22s} glitches  width(ps)  peak(V)   main fC   opposing fC   cancelled")
for raw in sys.argv[1:]:
    tag = os.path.basename(raw)[3:-4]
    m = re.search(r"_(\d)p(\d\d)V", tag)
    vdd = float(f"{m.group(1)}.{m.group(2)}") if m else 1.8
    names, rows = read_raw(raw)
    idx = {re.sub(r"^[vi]\((.*)\)$", r"\1", n): i for i, n in enumerate(names)}
    t = [r[0] for r in rows]
    a, b = 8 * UI, 28 * UI
    high = {}
    for sig in ("up0", "dn0"):
        high[sig] = sum(t[j] - t[j - 1] for j in range(1, len(t))
                        if a <= t[j] <= b and rows[j][idx[sig]] > vdd / 2)
    main = max(high, key=high.get)
    other = "up0" if main == "dn0" else "dn0"
    ex, on, pk = [], None, 0.0
    for j in range(1, len(t)):
        if not a <= t[j] <= b:
            continue
        v = rows[j][idx[other]]
        if v > vdd / 2 and on is None:
            on, pk = t[j], v
        if on is not None:
            pk = max(pk, v)
        if v <= vdd / 2 and on is not None:
            ex.append((t[j] - on, pk))
            on = None
    gl = [e for e in ex if e[0] < 0.3 * UI]
    qp = qn = 0.0
    for j in range(1, len(t)):
        if a <= t[j] <= b:
            i = rows[j][idx["i0"]] * (t[j] - t[j - 1])
            if i > 0:
                qp += i
            else:
                qn += i
    qm, qo = (qp, qn) if abs(qp) >= abs(qn) else (qn, qp)
    w = sorted(x for x, _ in gl)
    p = sorted(y for _, y in gl)
    wtxt = f"{w[len(w) // 2] * 1e12:6.0f}" if w else "     -"
    ptxt = f"{p[len(p) // 2]:6.2f}" if p else "     -"
    print(f"{tag:22s} {len(gl):5d}    {wtxt}    {ptxt}   {qm * 1e15:+7.2f}    {qo * 1e15:+7.2f}      "
          f"{abs(qo) / abs(qm) * 100:5.1f} %")
