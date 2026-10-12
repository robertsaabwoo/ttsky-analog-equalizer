#!/usr/bin/env python3
"""B2 analysis: pump current and proportional kick (Icp x R_filter) over PVT.

    b2_analyze.py        (reads B2_*.log here)

Up and down currents as magnitudes; kick = mean(|up|, |down|) x R_filter.
Pure stdlib (../../../../CLAUDE.md).
"""
import glob
import os
import re

pts = {}
for log in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), "B2_*.log"))):
    mos, rc = re.match(r".*B2_(\w+?)_(\w+)\.log", log).groups()
    vdd = None
    for line in open(log):
        m = re.match(r"#VDD ([\d.]+)", line)
        if m:
            vdd = float(m.group(1))
            continue
        m = re.match(r"\s*(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)", line)
        if m and vdd is not None:
            try:
                v = [abs(float(m.group(i))) for i in range(2, 8)]
            except ValueError:
                continue
            pts[(mos, rc, vdd, v[0])] = v[1:]
print(f"{len(pts)} PVT points")
for name, k in (("a  tiny_pll_bias_gen", 0), ("b  cp_bias (xhigh_po reference)", 2)):
    icp = {p: (v[k] + v[k + 1]) / 2 for p, v in pts.items()}
    mis = {p: abs(v[k] - v[k + 1]) / ((v[k] + v[k + 1]) / 2) for p, v in pts.items()}
    kick = {p: icp[p] * v[4] for p, v in pts.items()}
    lo, hi = min(icp, key=icp.get), max(icp, key=icp.get)
    klo, khi = min(kick, key=kick.get), max(kick, key=kick.get)
    print(f"\n{name}")
    print(f"  Icp   {icp[lo] * 1e6:.2f} .. {icp[hi] * 1e6:.2f} uA  ({icp[hi] / icp[lo]:.2f}x)   "
          f"lowest {lo[0]}/{lo[1]}/{lo[2]}V/{lo[3]:.0f}C, highest {hi[0]}/{hi[1]}/{hi[2]}V/{hi[3]:.0f}C")
    print(f"  kick  {kick[klo] * 1e3:.1f} .. {kick[khi] * 1e3:.1f} mV  ({kick[khi] / kick[klo]:.2f}x)")
    print(f"  up/down mismatch: max {max(mis.values()) * 100:.1f} %")
