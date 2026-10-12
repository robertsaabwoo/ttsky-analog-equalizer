#!/usr/bin/env python3
"""R1 table: open-loop ring frequency (MHz) vs vctrl, per corner (gen_r1.py).

    r1_analyze.py r1/<design> [...]

'-' = the ring did not make 40 cycles in 110 ns (dead or below ~360 MHz).
'*' marks the first vctrl at or above the precharge seed where f >= 655 MHz:
in the closed-loop suite the loop ran away from starts above ~655 MHz.
"""
import glob
import os
import re
import sys

for d in sys.argv[1:]:
    print(f"\n=== {d}")
    rows = []
    for log in sorted(glob.glob(os.path.join(d, "*.log"))):
        m = dict(re.findall(r"^(v\dp\d\d_[ab])\s+=\s+([-\d.e+]+)", open(log).read(), re.M))
        vs = sorted({k[:-2] for k in m})
        if not rows:
            print(f"{'corner':20s} " + " ".join(f"{v[1:].replace('p', '.'):>6s}" for v in vs))
            rows = vs
        cells = []
        for v in rows:
            a, b = m.get(v + "_a"), m.get(v + "_b")
            cells.append(f"{30 / (float(b) - float(a)) / 1e6:6.0f}" if a and b else "     -")
        print(f"{os.path.basename(log)[:-4]:20s} " + " ".join(cells))
