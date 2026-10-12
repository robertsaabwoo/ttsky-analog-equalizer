#!/usr/bin/env python3
"""B1 analysis: tail current and CML swing per bias scheme over PVT.

    b1_analyze.py            (reads B1_*.log in this directory)

Each scheme's current is scaled so that tt / typ / 27 C / 1.8 V is 54 uA, the
CML latch's design current; swing = scaled current x the load resistor measured
at the same corner. Reports the min / max swing and current over all 135
points per scheme, and the worst corners. Pure stdlib (../../../../CLAUDE.md).
"""
import glob
import os
import re

TEMPS = [-40.0, 42.5, 125.0]       # dc temp -40 125 82.5
pts = {}                            # (mos, rc, vdd, temp) -> (ia, ib, ic, rl)
for log in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)), "B1_*.log"))):
    mos, rc = re.match(r".*B1_(\w+?)_(\w+)\.log", log).groups()
    vdd, rows = None, []
    for line in open(log):
        m = re.match(r"#VDD ([\d.]+)", line)
        if m:
            vdd, rows = float(m.group(1)), []
            continue
        m = re.match(r"\s*(\d+)\s+([-\d.e+]+)\s+([-\d.e+]+)\s+([-\d.e+]+)\s+([-\d.e+]+)\s+([-\d.e+]+)", line)
        if m and vdd is not None:
            k = int(m.group(1))
            vals = [float(m.group(i)) for i in range(3, 7)]
            pts[(mos, rc, vdd, TEMPS[k])] = vals
assert pts, "no data parsed"
ref = pts[("tt", "typ", 1.8, 42.5)] if ("tt", "typ", 1.8, 42.5) in pts else None
# the sweep has -40 / 42.5 / 125; use the 42.5 C point as the nominal reference
names = {0: "A  today (vbias 0.9 V on the gate)", 1: "B  mirror of tiny_pll_bias_gen",
         2: "C  res_high_po reference + mirror"}
print(f"{len(pts)} PVT points; nominal = tt / typ / 1.8 V / 42.5 C (the sweep's middle point)")
for s in range(3):
    scale = 54e-6 / ref[s]
    cur = {k: v[s] * scale for k, v in pts.items()}
    sw = {k: v[s] * scale * v[3] for k, v in pts.items()}
    nom = sw[("tt", "typ", 1.8, 42.5)]
    lo = min(sw, key=sw.get)
    hi = max(sw, key=sw.get)
    print(f"\n{names[s]}")
    print(f"  tail current {min(cur.values()) * 1e6:6.1f} .. {max(cur.values()) * 1e6:6.1f} uA")
    print(f"  swing        {sw[lo]:.3f} .. {sw[hi]:.3f} V  (nominal {nom:.3f} V; "
          f"{(sw[lo] / nom - 1) * 100:+.0f} % / {(sw[hi] / nom - 1) * 100:+.0f} %)")
    print(f"  lowest at  {lo[0]}/{lo[1]}/{lo[2]} V/{lo[3]:.0f} C;  highest at {hi[0]}/{hi[1]}/{hi[2]} V/{hi[3]:.0f} C")
    vt = {}
    for k, v in sw.items():
        vt.setdefault(k[2], []).append(v)
    print("  swing range by VDD: " + "  ".join(f"{v} V: {min(x):.3f}..{max(x):.3f}" for v, x in sorted(vt.items())))
