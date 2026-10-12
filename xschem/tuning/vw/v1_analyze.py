#!/usr/bin/env python3
"""V1: where does the locked loop's vctrl wander come from? Frozen vs CML.

    v1_analyze.py V1_frozen.dat [V1_cml.dat ...] [--from 5000] [--to 6000]

Each .dat is an ngspice `wrdata` of, in order: vctrl (x2_net1), the C1 node
(x2_x2.cap_plus), up (x2_net2), down (x2_net3), the recovered clock. wrdata
writes a (time, value) pair per vector on every line.

The loop filter is R in series with C1, with C2 across both, so
    vctrl = v(C1) + v(R)
and v(R) is the instantaneous proportional kick of the charge pump, while v(C1)
is the integrated history. Splitting the wander between the two says whether
the loop is being kicked harder (proportional path) or is integrating a
longer-lived imbalance (integral path).

Pure stdlib (../../../CLAUDE.md).
"""
import sys
from statistics import mean, pstdev

UI = 1.665e-9
VTH = 0.9
args = [a for a in sys.argv[1:]]
t0, t1 = 5000e-9, 6000e-9
if "--from" in args:
    i = args.index("--from"); t0 = float(args[i + 1]) * 1e-9; del args[i:i + 2]
if "--to" in args:
    i = args.index("--to"); t1 = float(args[i + 1]) * 1e-9; del args[i:i + 2]


def load(path):
    t, cols = [], [[] for _ in range(5)]
    with open(path) as f:
        for line in f:
            p = line.split()
            if len(p) < 10:
                continue
            x = float(p[0])
            if x < t0 - 20e-9 or x > t1:
                continue
            t.append(x)
            for k in range(5):
                cols[k].append(float(p[2 * k + 1]))
    return t, cols


def resample(t, v, dt):
    n = int((t1 - t0) / dt)
    out, j = [], 0
    for i in range(n):
        x = t0 + i * dt
        while t[j + 1] < x:
            j += 1
        f = (x - t[j]) / (t[j + 1] - t[j])
        out.append(v[j] + f * (v[j + 1] - v[j]))
    return out


def pulses(t, v):
    """Widths of the high pulses of a logic waveform inside the window."""
    w, start = [], None
    for i in range(len(t) - 1):
        if t[i] < t0:
            continue
        if v[i] < VTH <= v[i + 1]:
            start = t[i]
        elif v[i] >= VTH > v[i + 1] and start is not None:
            w.append(t[i] - start)
            start = None
    return w


def pct(xs, q):
    s = sorted(xs)
    return s[min(len(s) - 1, int(q * len(s)))]


for path in args:
    t, (vc, c1, up, dn, ck) = load(path)
    dt = 5e-12
    VC, C1, UP, DN = (resample(t, x, dt) for x in (vc, c1, up, dn))
    VR = [a - b for a, b in zip(VC, C1)]
    u = [x > VTH for x in UP]
    d = [x > VTH for x in DN]
    n = len(u)
    fu, fd = sum(u) / n, sum(d) / n
    both = sum(1 for a, b in zip(u, d) if a and b) / n
    net = [(1 if a else 0) - (1 if b else 0) for a, b in zip(u, d)]
    print(f"\n=== {path}  ({t0*1e9:.0f}-{t1*1e9:.0f} ns)")
    print(f"up high {fu:.3f}  down high {fd:.3f}  BOTH high {both:.3f}  "
          f"net (up-down) {fu - fd:+.4f}")
    for name, w in (("up", pulses(t, up)), ("down", pulses(t, dn))):
        if w:
            print(f"  {name:4s} pulses {len(w):4d}  width mean {mean(w)/UI:.2f} UI  "
                  f"p10 {pct(w, .1)/UI:.2f}  p90 {pct(w, .9)/UI:.2f}  max {max(w)/UI:.2f} UI")
    print(f"vctrl     mean {mean(VC):.4f}  RMS {pstdev(VC)*1e3:6.2f} mV  pp {(max(VC)-min(VC))*1e3:6.1f} mV")
    print(f"  C1 node mean {mean(C1):.4f}  RMS {pstdev(C1)*1e3:6.2f} mV  pp {(max(C1)-min(C1))*1e3:6.1f} mV")
    print(f"  across R      RMS {pstdev(VR)*1e3:6.2f} mV  pp {(max(VR)-min(VR))*1e3:6.1f} mV")
    # the net charge-pump drive averaged over sliding windows: how long-lived
    # is an imbalance? (a pure dither averages out fast; a slow wander does not)
    for ns in (5, 20, 50):
        m = int(ns * 1e-9 / dt)
        s = sum(net[:m]); avg = []
        for i in range(0, n - m, m // 4):
            avg.append(sum(net[i:i + m]) / m)
        print(f"  net drive averaged over {ns:3d} ns: RMS {pstdev(avg):.3f}  "
              f"max |.| {max(abs(x) for x in avg):.3f}")
    # per-UI decision sequence: +1 up-dominant, -1 down-dominant, 0 neither
    k = int(UI / dt)
    seq = []
    for i in range(0, n - k, k):
        s = sum(net[i:i + k])
        seq.append(0 if abs(s) < k // 4 else (1 if s > 0 else -1))
    nz = [x for x in seq if x]
    runs, r = [], 1
    for a, b in zip(nz, nz[1:]):
        if a == b:
            r += 1
        else:
            runs.append(r); r = 1
    runs.append(r)
    print(f"  decisions per UI: {len(nz)} of {len(seq)} UIs, same-sign runs mean "
          f"{mean(runs):.2f}  p90 {pct(runs, .9)}  max {max(runs)}")
