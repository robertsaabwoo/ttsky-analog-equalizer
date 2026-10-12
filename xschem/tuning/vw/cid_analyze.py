#!/usr/bin/env python3
"""CID analysis: sampling-phase drift and recovery around each identical-digit run.

    cid_analyze.py CID_scaled_chain.raw CID_scaled.dat cid_layout.txt

Phase of every rising edge of the recovered clock against the ideal bit grid,
relative to its median over bits 150-300 (settled PRBS before the first run),
in UI. For each run: the phase change across the run, the peak excursion from
the run's start to 100 bits later, the bits after the run until the phase is
back within 2x the pre-run RMS, whether it slipped (> 0.5 UI), the worst eye at
the sampling instants in that window (CTLE output at each clock edge), and
vctrl / C1 movement across the run. Pure stdlib (../../../CLAUDE.md).
"""
import bisect
import sys
from statistics import median, pstdev

UI = 1.665e-9
raw, dat, lay = sys.argv[1:4]

names, rows, nv, mode, cur = [], [], None, None, []
with open(raw) as f:
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
t = [r[0] for r in rows]
ck = [r[1] for r in rows]
eye = [r[2] - r[3] for r in rows]

edges, samp = [], []
for i in range(1, len(t)):
    if ck[i - 1] < 0.9 <= ck[i]:
        e = t[i - 1] + (t[i] - t[i - 1]) * (0.9 - ck[i - 1]) / (ck[i] - ck[i - 1])
        edges.append(e)
        j = bisect.bisect(t, e)
        samp.append(eye[j])
# phase vs grid, unwrapped
ph, prev = [], None
for e in edges:
    p = (e / UI) % 1.0
    if prev is not None:
        while p - prev > 0.5:
            p -= 1
        while p - prev < -0.5:
            p += 1
    ph.append(p)
    prev = p
bit_of = [round(e / UI - (p % 1.0)) for e, p in zip(edges, ph)]


def at_bits(a, b):
    return [k for k, n in enumerate(bit_of) if a <= n < b]


base_k = at_bits(150, 300)
p0 = median(ph[k] for k in base_k)
rel = [p - p0 for p in ph]
rms0 = pstdev(rel[k] for k in base_k)
print(f"pre-run (bits 150-300): phase RMS {rms0 * 100:.2f} % UI, worst |eye| at sampling "
      f"{min(abs(samp[k]) for k in base_k) * 1e3:.0f} mV")

vt, vv, vc1 = [], [], []
with open(dat) as f:
    for line in f:
        p = line.split()
        if len(p) >= 4:
            vt.append(float(p[0]))
            vv.append(float(p[1]))
            vc1.append(float(p[3]))


def v_at(x, arr):
    return arr[min(bisect.bisect(vt, x), len(vt) - 1)]


print("run  | phase change over run | peak excursion | recover (bits) | slip | worst |eye| | vctrl / C1 change over run")
for line in open(lay):
    start, length = map(int, line.split())
    ks = at_bits(start - 2, start + length + 100)
    kr0 = [k for k in ks if bit_of[k] <= start][-1]
    kr1 = [k for k in ks if bit_of[k] <= start + length][-1]
    change = rel[kr1] - rel[kr0]
    peak = max(abs(rel[k] - rel[kr0]) for k in ks)
    rec = None
    for k in ks:
        if bit_of[k] > start + length and abs(rel[k]) < 2 * max(rms0, 0.01):
            rec = bit_of[k] - (start + length)
            break
    slip = any(abs(rel[k]) > 0.5 for k in ks)
    worst = min(abs(samp[k]) for k in ks)
    ta, tb = start * UI, (start + length) * UI
    dv = (v_at(tb, vv) - v_at(ta, vv)) * 1e3
    dc = (v_at(tb, vc1) - v_at(ta, vc1)) * 1e3
    print(f"{length:3d}  |   {change * 100:+7.2f} % UI          |  {peak * 100:6.2f} % UI    |   "
          f"{rec if rec is not None else '>100':>5}        | {'YES' if slip else 'no ':3s}  | "
          f"{worst * 1e3:5.0f} mV   | {dv:+6.1f} / {dc:+6.1f} mV")
