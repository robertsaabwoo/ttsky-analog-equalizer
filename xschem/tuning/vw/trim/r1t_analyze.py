#!/usr/bin/env python3
"""R1T table: ring MHz per trim state at vctrl 0.79 (the seed) / 1.05 (top).

    r1t_analyze.py decks/*.log
"""
import re
import sys

for log in sys.argv[1:]:
    m = dict(re.findall(r"^(\w+_v\dp\d\d_[ab])\s+=\s+([-\d.e+]+)", open(log).read(), re.M))
    keys = []
    for k in m:
        if k[:-2] not in keys:
            keys.append(k[:-2])
    states = []
    for k in keys:
        st = k.rsplit("_v", 1)[0]
        if st not in states:
            states.append(st)
    if not states:
        print(f"{log}: no data")
        continue
    cells = []
    for st in states:
        fs = []
        for v in ("0p79", "1p05"):
            a, b = m.get(f"{st}_v{v}_a"), m.get(f"{st}_v{v}_b")
            fs.append(f"{22 / (float(b) - float(a)) / 1e6:.0f}" if a and b else "-")
        cells.append(f"{st}:{fs[0]}/{fs[1]}")
    print(f"{log.split('/')[-1][:-4]:20s} " + "  ".join(cells))
