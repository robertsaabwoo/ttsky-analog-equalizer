#!/usr/bin/env python3
"""Analyse the C27 chain dump: clock jitter AND the eye consumed at the sampling instant.

    c27_analyze.py [c27_chain.raw] [ui_ns] [t_start_ns]

C26 (NOTES_CTLE.md §C26) produced a phase number that could not be quoted, for
three reasons. This script fixes the two that are analysis-side, and the deck
fixes the third (window):

  * phase error is referenced to the IDEAL BIT GRID (n * UI), allowing only a
    constant offset -- not to a best-fit constant-period clock. A CDR is
    supposed to track the data, and the data grid here is exactly UI, so the
    ideal grid is the physically meaningful reference;
  * it reports the SAMPLING-INSTANT EYE: the differential CTLE output
    v(coutp)-v(coutm) interpolated at each recovered-clock rising edge. That is
    the figure of merit that actually decides BER -- raw phase wander is not,
    because a bang-bang loop has unbounded low-frequency wander by construction.

Unlike jitter_parse.py (which assumes a single voltage vector), this reads a
multi-vector ASCII rawfile and selects columns by name.

Pure stdlib: numpy is not installed on this VM and must not be (../../CLAUDE.md).
"""
import sys
from statistics import mean, pstdev

path = sys.argv[1] if len(sys.argv) > 1 else "c27_chain.raw"
UI = float(sys.argv[2]) * 1e-9 if len(sys.argv) > 2 else 1.665e-9
TSTART = float(sys.argv[3]) * 1e-9 if len(sys.argv) > 3 else 4.0e-6
VTH = 0.9

# ---- read the ASCII rawfile, keeping every column --------------------------
names, rows, nvars, npts = [], [], None, None
with open(path) as f:
    in_values = in_vars = False
    pending = []
    for line in f:
        s = line.strip()
        if in_values:
            if not s:
                continue
            pending.append(float(s.split()[-1]))
            if len(pending) == nvars:
                rows.append(pending)
                pending = []
            continue
        if s.startswith("No. Variables:"):
            nvars = int(s.split(":")[1])
        elif s.startswith("No. Points:"):
            npts = int(s.split(":")[1])
        elif s.startswith("Variables:"):
            in_vars = True
        elif s.startswith("Values:"):
            in_values, in_vars = True, False
        elif in_vars:
            # "<idx>\t<name>\t<type>"
            parts = s.split()
            if len(parts) >= 2:
                names.append(parts[1].lower())

print(f"{path}: {len(rows)} points, {nvars} vars {names} (declared {npts})")
if len(rows) < 1000:
    sys.exit("too few points -- did the write produce what was expected?")


def col(want):
    """Index of the first variable whose name contains `want`."""
    for i, n in enumerate(names):
        if want in n:
            return i
    sys.exit(f"variable matching {want!r} not found in {names}")


it, ick = 0, col("rclkp")
ip, im = col("coutp"), col("coutm")
t = [r[it] for r in rows]
clk = [r[ick] for r in rows]
diff = [r[ip] - r[im] for r in rows]

# ---- rising-edge times by linear interpolation, + the data sampled there ---
edges, samples = [], []
for i in range(1, len(t)):
    if clk[i - 1] < VTH <= clk[i]:
        f = (VTH - clk[i - 1]) / (clk[i] - clk[i - 1])
        edges.append(t[i - 1] + f * (t[i] - t[i - 1]))
        samples.append(diff[i - 1] + f * (diff[i] - diff[i - 1]))

use = [(e, s) for e, s in zip(edges, samples) if e >= TSTART]
print(f"rising edges: {len(edges)} total, {len(use)} in the settled window "
      f"(>= {TSTART*1e9:.0f} ns)")
if len(use) < 100:
    sys.exit("too few settled edges -- was the run long enough?")
ue = [e for e, _ in use]
us = [s for _, s in use]

# ---- 1. cycle-to-cycle period jitter (comparable to C26's usable number) ---
per = [b - a for a, b in zip(ue, ue[1:])]
print("\n--- period (cycle-to-cycle) ---")
print(f"  mean period : {mean(per)*1e12:9.2f} ps   (ideal UI {UI*1e12:.2f} ps)")
print(f"  mean error  : {(mean(per)-UI)*1e12:9.2f} ps = {(mean(per)-UI)/UI*100:+.3f} % UI")
print(f"  period RMS  : {pstdev(per)*1e12:9.2f} ps = {pstdev(per)/UI*100:.2f} % UI")
print(f"  period pk-pk: {(max(per)-min(per))*1e12:9.2f} ps = {(max(per)-min(per))/UI*100:.2f} % UI")

# ---- 2. phase error vs the IDEAL grid, constant offset removed -------------
# n is the edge index in UI from the first settled edge; the loop may sit
# anywhere in the eye, so a constant offset is legitimate and is removed.
n0 = ue[0]
idx = [round((e - n0) / UI) for e in ue]
resid = [e - (n0 + k * UI) for e, k in zip(ue, idx)]
off = mean(resid)
ph = [r - off for r in resid]
skipped = len(idx) - len(set(idx))
print("\n--- phase error vs the ideal 1665.00 ps grid (constant offset removed) ---")
if skipped:
    print(f"  NOTE: {skipped} duplicate grid slots -- the clock slipped a UI; "
          f"phase numbers below are unreliable if this is large.")
print(f"  phase RMS   : {pstdev(ph)*1e12:9.2f} ps = {pstdev(ph)/UI*100:.2f} % UI")
print(f"  phase pk-pk : {(max(ph)-min(ph))*1e12:9.2f} ps = {(max(ph)-min(ph))/UI*100:.2f} % UI")

# ---- 3. THE figure of merit: eye consumed at the sampling instant ----------
# |differential| at the sampling instant. A sample near 0 V is a sample taken
# at a data transition, i.e. the sampling phase has walked out of the eye.
mag = [abs(s) for s in us]
mag_s = sorted(mag)
worst = mag_s[0]
p01 = mag_s[max(0, len(mag_s) // 100)]
print("\n--- sampling-instant differential eye (|v(coutp)-v(coutm)| at the clock edge) ---")
print(f"  mean |diff| : {mean(mag)*1e3:9.2f} mV")
print(f"  min  |diff| : {worst*1e3:9.2f} mV   <-- worst sample in the window")
print(f"  1st pctile  : {p01*1e3:9.2f} mV")
print(f"  samples < 25 mV: {sum(1 for m in mag if m < 25e-3)} of {len(mag)}")
print(f"  samples < 50 mV: {sum(1 for m in mag if m < 50e-3)} of {len(mag)}")
print("\n  (a sample near 0 mV = the clock edge landed on a data transition.)")
