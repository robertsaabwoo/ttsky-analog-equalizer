#!/usr/bin/env python3
"""Extract recovered-clock jitter from the C26 raw dump.

    jitter_parse.py [c26_rclk.raw] [ui_ns] [t_start_ns]

Reads an ASCII ngspice rawfile containing one voltage vector, finds the rising
0.9 V crossings by linear interpolation, and reports:

  * period statistics  -- RMS and peak-to-peak cycle-to-cycle jitter;
  * phase error against the ideal bit grid (n * UI), which is the number that
    decides whether the sampling instant stays inside the eye.

Pure stdlib: numpy is not installed on this VM and must not be (../../CLAUDE.md).
"""
import sys
from statistics import mean, pstdev

path = sys.argv[1] if len(sys.argv) > 1 else "c26_rclk.raw"
UI = float(sys.argv[2]) * 1e-9 if len(sys.argv) > 2 else 1.665e-9
TSTART = float(sys.argv[3]) * 1e-9 if len(sys.argv) > 3 else 1.8e-6
VTH = 0.9

# ---- read the ASCII rawfile ------------------------------------------------
times, vals, nvars, npts = [], [], None, None
with open(path) as f:
    in_values = False
    pending = []
    for line in f:
        s = line.strip()
        if not in_values:
            if s.startswith("No. Variables:"):
                nvars = int(s.split(":")[1])
            elif s.startswith("No. Points:"):
                npts = int(s.split(":")[1])
            elif s.startswith("Values:"):
                in_values = True
            continue
        if not s:
            continue
        # a point starts with "<index>\t<value>", continuations are bare values
        parts = s.split()
        pending.append(float(parts[-1]))
        if len(pending) == nvars:
            times.append(pending[0])
            vals.append(pending[1])
            pending = []

print(f"{path}: {len(times)} points, {nvars} vars (declared {npts})")
if len(times) < 100:
    sys.exit("too few points -- did the write produce what was expected?")

# ---- rising-edge times by linear interpolation -----------------------------
edges = []
for i in range(1, len(times)):
    if vals[i - 1] < VTH <= vals[i]:
        f = (VTH - vals[i - 1]) / (vals[i] - vals[i - 1])
        edges.append(times[i - 1] + f * (times[i] - times[i - 1]))

use = [e for e in edges if e >= TSTART]
print(f"rising edges: {len(edges)} total, {len(use)} after {TSTART*1e9:.0f} ns")
if len(use) < 50:
    sys.exit("not enough settled edges to characterise")

# ---- period statistics -----------------------------------------------------
per = [use[i + 1] - use[i] for i in range(len(use) - 1)]
pm, ps = mean(per), pstdev(per)
print(f"""
--- period statistics over {len(per)} cycles, t > {TSTART*1e9:.0f} ns ---
  mean period      {pm*1e12:9.2f} ps   -> {1/pm/1e6:8.2f} MHz
  ideal UI         {UI*1e12:9.2f} ps   -> {1/UI/1e6:8.2f} MHz
  mean error       {(pm-UI)*1e12:+9.2f} ps   ({(pm-UI)/UI*100:+.3f} %)
  period RMS       {ps*1e12:9.2f} ps   = {ps/UI*100:6.3f} % UI
  period pk-pk     {(max(per)-min(per))*1e12:9.2f} ps   = {(max(per)-min(per))/UI*100:6.3f} % UI""")

# ---- phase error against the ideal grid ------------------------------------
# fit t_n = t0 + n*UI over the settled edges, then look at the residual: that
# is the accumulated phase wander the sampler actually sees.
n = list(range(len(use)))
nb, tb = mean(n), mean(use)
slope = sum((i - nb) * (t - tb) for i, t in zip(n, use)) / sum((i - nb) ** 2 for i in n)
t0 = tb - slope * nb
resid = [t - (t0 + slope * i) for i, t in zip(n, use)]
rms, pp = pstdev(resid), max(resid) - min(resid)
print(f"""--- phase error vs a best-fit clock of period {slope*1e12:.2f} ps ---
  phase RMS        {rms*1e12:9.2f} ps   = {rms/UI*100:6.3f} % UI
  phase pk-pk      {pp*1e12:9.2f} ps   = {pp/UI*100:6.3f} % UI

The eye the CTLE delivers at the worst PVT corner is 0.350 UI (C22).
Peak-to-peak phase error consumes {pp/UI/0.350*100:.1f} % of that.""")
