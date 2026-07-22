#!/usr/bin/env python3
"""Bang-bang hunting jitter of the recovered clock from an ngspice wrdata dump
of time + v(clk+). Noiseless transient -> data/pattern-dependent (bang-bang
dither) jitter, not device-noise jitter. Pure stdlib (no numpy).

Usage: analyze_jitter.py <datfile> [t_start_ns] [t_end_ns] [vthresh]
"""
import sys
from statistics import mean, pstdev, stdev

fn = sys.argv[1]
t0 = float(sys.argv[2]) * 1e-9 if len(sys.argv) > 2 else 1200e-9
t1 = float(sys.argv[3]) * 1e-9 if len(sys.argv) > 3 else 2000e-9
vth = float(sys.argv[4]) if len(sys.argv) > 4 else 0.9

ts, vs = [], []
with open(fn) as f:
    for line in f:
        p = line.split()
        if len(p) < 2:
            continue
        try:
            t = float(p[0]); v = float(p[1])
        except ValueError:
            continue
        if t0 <= t <= t1:
            ts.append(t); vs.append(v)

if len(ts) < 10:
    print(f"ERROR: too few samples in [{t0*1e9:.0f},{t1*1e9:.0f}] ns: {len(ts)}")
    sys.exit(1)

vmin, vmax = min(vs), max(vs)
cross = []
for i in range(1, len(vs)):
    if vs[i-1] < vth <= vs[i]:
        frac = (vth - vs[i-1]) / (vs[i] - vs[i-1])
        cross.append(ts[i-1] + frac * (ts[i] - ts[i-1]))

if len(cross) < 3:
    print(f"ERROR: <3 rising crossings. vmin/vmax={vmin:.4f}/{vmax:.4f}")
    sys.exit(1)

periods = [cross[i] - cross[i-1] for i in range(1, len(cross))]
mT = mean(periods)
freq = 1.0 / mT
rms = stdev(periods)
pp = max(periods) - min(periods)
ps = 1e12

print(f"window            : {t0*1e9:.0f}-{t1*1e9:.0f} ns   thresh {vth} V")
print(f"samples in window : {len(vs)}")
print(f"rising crossings  : {len(cross)}  ({len(periods)} periods)")
print(f"vmin / vmax       : {vmin:.4f} / {vmax:.4f} V  (swing {vmax-vmin:.4f})")
print(f"mean period       : {mT*ps:.3f} ps")
print(f"frequency         : {freq/1e6:.3f} MHz  (target 600.6, err {(freq/600.6e6-1)*100:+.3f}%)")
print(f"RMS period jitter : {rms*ps:.3f} ps   ({rms/mT*100:.4f} % UI)")
print(f"pk-pk period jit  : {pp*ps:.3f} ps   ({pp/mT*100:.4f} % UI)")
print(f"min / max period  : {min(periods)*ps:.3f} / {max(periods)*ps:.3f} ps")
