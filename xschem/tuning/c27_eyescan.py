#!/usr/bin/env python3
"""Where is the eye centre, relative to the rclkp rising edge I measured at?

rclkp is the BUFFERED OUTPUT pin, downstream of the output inverter chain, not
the phase detector's internal sampling clock. So "eye at the rclkp rising edge"
is the eye at some unknown fixed offset from the true sampling instant.

Sweep an offset tau across one UI, sample |coutp-coutm| at (each rclkp rising
edge + tau), and report the distribution. The tau that maximises the margin is
the eye centre as seen by the recovered clock; the gap between that and tau=0
is how far my published number was offset from the real sampling instant.
"""
from statistics import mean

path = "/home/ttuser/ssh_analog/ttsky-analog-equalizer/xschem/tuning/c27_chain.raw"
UI, VTH, TSTART = 1.665e-9, 0.9, 4.0e-6

names, rows, nvars = [], [], None
with open(path) as f:
    inv = invars = False; pend = []
    for line in f:
        s = line.strip()
        if inv:
            if not s: continue
            pend.append(float(s.split()[-1]))
            if len(pend) == nvars: rows.append(pend); pend = []
            continue
        if s.startswith("No. Variables:"): nvars = int(s.split(":")[1])
        elif s.startswith("Variables:"): invars = True
        elif s.startswith("Values:"): inv, invars = True, False
        elif invars:
            p = s.split()
            if len(p) >= 2: names.append(p[1].lower())

ix = {n: i for i, n in enumerate(names)}
it = ix["time"]; ick = [i for n,i in ix.items() if "rclkp" in n][0]
ip = [i for n,i in ix.items() if "coutp" in n][0]
im = [i for n,i in ix.items() if "coutm" in n][0]
t   = [r[it] for r in rows]
clk = [r[ick] for r in rows]
dif = [r[ip] - r[im] for r in rows]

edges = []
for i in range(1, len(t)):
    if clk[i-1] < VTH <= clk[i]:
        f = (VTH - clk[i-1])/(clk[i]-clk[i-1])
        e = t[i-1] + f*(t[i]-t[i-1])
        if e >= TSTART: edges.append(e)

# index map for fast interpolation
def sample_at(x):
    lo, hi = 0, len(t)-1
    while lo < hi-1:
        mid = (lo+hi)//2
        if t[mid] <= x: lo = mid
        else: hi = mid
    if t[hi] == t[lo]: return dif[lo]
    f = (x - t[lo])/(t[hi]-t[lo])
    return dif[lo] + f*(dif[hi]-dif[lo])

print(f"edges in settled window: {len(edges)}")
print(f"{'tau (UI)':>9} {'mean|d| mV':>11} {'min|d| mV':>10} {'n<25mV':>7} {'n<50mV':>7}")
best = None
for k in range(21):
    tau = (k/20.0 - 0.5) * UI          # -0.5 .. +0.5 UI
    mags = [abs(sample_at(e + tau)) for e in edges if TSTART <= e+tau <= t[-1]-1e-12]
    n25 = sum(1 for m in mags if m < 25e-3)
    n50 = sum(1 for m in mags if m < 50e-3)
    row = (tau/UI, mean(mags)*1e3, min(mags)*1e3, n25, n50)
    print(f"{row[0]:>9.3f} {row[1]:>11.2f} {row[2]:>10.2f} {row[3]:>7d} {row[4]:>7d}")
    if best is None or row[1] > best[1]: best = row
print(f"\nBEST margin at tau = {best[0]:+.3f} UI : mean {best[1]:.2f} mV, "
      f"min {best[2]:.2f} mV, {best[3]} samples < 25 mV")
print(f"tau = 0 (what I published) is {abs(best[0]):.3f} UI away from that optimum.")
