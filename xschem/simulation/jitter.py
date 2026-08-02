#!/usr/bin/env python3
"""Jitter / phase analysis for the CDR recovered clock.

SPICE has no notion of phase -- it only produces voltage-vs-time. Phase is
reconstructed here by finding threshold crossings and linearly interpolating
between the two bracketing samples, which resolves well below the timestep.

Usage:
    # 1. dump the nodes you need out of a .raw (ngspice)
    ngspice -b <<'EOF'
    .control
    load ~/.xschem/simulations/CDR_tune_tb.raw
    set wr_singlescale
    wrdata win.txt v(clk+) v(vin+)
    .endc
    .end
    EOF

    # 2. analyse (col 1 = time, col 2 = clock, col 3 = data)
    ./jitter.py win.txt --settle 600n

IMPORTANT -- always read the noise-floor line first. `vin+` is an ideal PULSE
source, so any jitter reported for it is pure numerical artifact from timestep
control / LTE. If that floor is not orders of magnitude below the clock's
jitter, the result is not trustworthy: tighten reltol or reduce the max
timestep and re-run.
"""
import argparse
import statistics as st
import sys


def scale(s):
    """Accept SPICE-style suffixes: 600n, 1.5u, 200p."""
    s = str(s).strip().lower()
    mult = {'p': 1e-12, 'n': 1e-9, 'u': 1e-6, 'm': 1e-3}
    if s and s[-1] in mult:
        return float(s[:-1]) * mult[s[-1]]
    return float(s)


def load(path):
    t, a, b = [], [], []
    for line in open(path):
        p = line.split()
        if len(p) < 3:
            continue
        try:
            t.append(float(p[0])); a.append(float(p[1])); b.append(float(p[2]))
        except ValueError:
            continue  # header line
    return t, a, b


def crossings(t, v, th=0.9, tmin=0.0, edge='both'):
    """Threshold crossing times, linearly interpolated between samples."""
    out = []
    for i in range(1, len(v)):
        if t[i] <= tmin:
            continue
        rise = v[i - 1] < th <= v[i]
        fall = v[i - 1] >= th > v[i]
        if (edge == 'rise' and rise) or (edge == 'fall' and fall) \
           or (edge == 'both' and (rise or fall)):
            dv = v[i] - v[i - 1]
            frac = 0.0 if dv == 0 else (th - v[i - 1]) / dv
            out.append(t[i - 1] + frac * (t[i] - t[i - 1]))
    return out


def report_periods(label, edges, ui=None):
    if len(edges) < 3:
        print(f"{label}: too few edges ({len(edges)}) -- nothing to measure")
        return None
    p = [edges[i + 1] - edges[i] for i in range(len(edges) - 1)]
    c2c = [p[i + 1] - p[i] for i in range(len(p) - 1)]
    mean = st.mean(p)
    print(f"{label}")
    print(f"  edges {len(edges)}   mean period {mean * 1e12:9.2f} ps"
          f"  -> {1e-6 / mean:8.2f} MHz")
    print(f"  period jitter    std {st.pstdev(p) * 1e12:7.3f} ps"
          f"   pp {(max(p) - min(p)) * 1e12:8.3f} ps")
    print(f"  cycle-to-cycle   std {st.pstdev(c2c) * 1e12:7.3f} ps"
          f"   pp {(max(c2c) - min(c2c)) * 1e12:8.3f} ps")
    if ui:
        print(f"  period jitter    {st.pstdev(p) / ui:7.5f} UI rms")
    return mean


def report_phase(clk, dat, settle, ui):
    """Sampling phase of each clock edge on the data-transition grid.

    Wrapped into [-0.5, +0.5) then unwrapped, so slow drift stays visible
    instead of folding back. Without the unwrap, edges near the +-0.5
    boundary alias and wildly inflate the apparent jitter.
    """
    if not dat:
        print("no data transitions found -- skipping phase analysis")
        return
    t0 = dat[0]
    ph, prev, acc = [], None, 0
    for te in clk:
        w = ((te - t0) / ui + 0.5) % 1.0 - 0.5
        if prev is not None:
            d = w - prev
            if d > 0.5:
                acc -= 1
            elif d < -0.5:
                acc += 1
        ph.append((te, w + acc))
        prev = w
    s = [p for te, p in ph if te >= settle]
    if len(s) < 10:
        print("not enough settled edges for phase analysis")
        return
    n = max(1, len(s) // 5)
    print("\nSampling phase (settled window, on the data-transition grid)")
    print(f"  n {len(s)}   std {st.pstdev(s):.5f} UI"
          f"  ({st.pstdev(s) * ui * 1e12:.2f} ps rms)")
    print(f"  pp {max(s) - min(s):.5f} UI"
          f"  ({(max(s) - min(s)) * ui * 1e12:.1f} ps)")
    drift = st.mean(s[-n:]) - st.mean(s[:n])
    print(f"  drift {st.mean(s[:n]):+.5f} -> {st.mean(s[-n:]):+.5f} UI"
          f"   (delta {drift:+.5f})")
    # A locked loop holds phase; a frequency offset shows a monotonic ramp.
    verdict = "LOCKED (phase stationary)" if abs(drift) < 0.05 \
        else "NOT LOCKED (phase drifting -- frequency offset remains)"
    print(f"  => {verdict}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('file', help='wrdata output: time, clock, data')
    ap.add_argument('--settle', default='0',
                    help='ignore everything before this time (e.g. 600n)')
    ap.add_argument('--threshold', type=float, default=0.9)
    args = ap.parse_args()

    settle = scale(args.settle)
    th = args.threshold
    t, clk_v, dat_v = load(args.file)
    if not t:
        sys.exit(f"no numeric data parsed from {args.file}")

    dat_all = crossings(t, dat_v, th, 0.0, 'both')
    if len(dat_all) < 3:
        sys.exit("could not find data transitions -- check column order")
    spacing = [dat_all[i + 1] - dat_all[i] for i in range(len(dat_all) - 1)]
    ui = st.median(spacing)

    print(f"UI (data symbol period) = {ui * 1e12:.3f} ps"
          f"  -> {1e-6 / ui:.2f} MBaud\n")

    # Noise floor first: the data source is ideal, so its jitter is artifact.
    report_periods("NOISE FLOOR -- ideal data source (artifact only)",
                   crossings(t, dat_v, th, settle, 'rise'))
    print()
    report_periods("RECOVERED CLOCK", crossings(t, clk_v, th, settle, 'rise'), ui)

    report_phase(crossings(t, clk_v, th, 0.0, 'rise'), dat_all, settle, ui)

    # Duty sets the Alexander edge/centre sampler separation: the two flops are
    # clocked on opposite clock edges, so their spacing IS the high time.
    rises = crossings(t, clk_v, th, settle, 'rise')
    falls = crossings(t, clk_v, th, settle, 'fall')
    hi, j = [], 0
    for r in rises:
        while j < len(falls) and falls[j] < r:
            j += 1
        if j < len(falls):
            hi.append(falls[j] - r)
    if hi:
        print(f"\nclk high time {st.mean(hi) * 1e12:.1f} ps"
              f" = {st.mean(hi) / ui:.3f} UI")
        print(f"  => Alexander edge/centre sampler separation"
              f" {st.mean(hi) / ui:.3f} UI (ideal 0.500)")


if __name__ == '__main__':
    main()
