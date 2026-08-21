#!/usr/bin/env python3
"""Regenerate the synthetic fixtures used by test/test_analysis_tools.py.

    python3 test/fixtures/make_fixtures.py

These are NOT captured simulation results and must never be presented as one.
They are hand-constructed signals whose answer is known analytically, so the
repository's own analysis scripts can be checked against something that cannot
drift: an ideal clock with exactly 20 ps of period jitter, an ideal NRZ eye
exactly 300 mV tall, and PVT logs whose measurements sit either side of the
documented pass criteria.
"""

import os

HERE = os.path.dirname(os.path.abspath(__file__))

UI = 1.665e-9          # the design UI, so the reported "% UI" is meaningful
JITTER = 20e-12        # each period is exactly UI +/- this
NCYC = 60              # even, so the mean is exactly UI and the stdev exactly JITTER
VDD = 1.8


def write_clock_raw(path):
    """An ASCII ngspice rawfile: a clean clock with a known period sequence.

    Each rising edge is a straight 0 V -> 1.8 V ramp spanning 10 ps, so the
    0.9 V crossing that jitter_parse.py interpolates lands exactly on the
    intended edge time and the recovered periods are exact.
    """
    periods = [UI + (JITTER if k % 2 == 0 else -JITTER) for k in range(NCYC)]
    edges, t = [1e-9], 1e-9
    for p in periods:
        t += p
        edges.append(t)

    pts = []
    for k, e in enumerate(edges):
        half = (periods[k] if k < len(periods) else periods[-1]) / 2
        pts += [(e - 5e-12, 0.0), (e + 5e-12, VDD),
                (e + half - 5e-12, VDD), (e + half + 5e-12, 0.0)]
    pts.sort()

    with open(path, "w") as f:
        f.write("Title: * synthetic fixture -- NOT a simulation result\n")
        f.write("Date: n/a\nPlotname: Transient Analysis\nFlags: real\n")
        f.write("No. Variables: 2\n")
        f.write(f"No. Points: {len(pts)}\n")
        f.write("Variables:\n\t0\ttime\ttime\n\t1\tv(rclkp)\tvoltage\n")
        f.write("Values:\n")
        for i, (t, v) in enumerate(pts):
            f.write(f" {i}\t{t:.15e}\n\t{v:.15e}\n\n")
    return len(pts), periods


def write_nrz_dat(path):
    """An ideal NRZ eye in ngspice `wrdata` layout: rows of `t v t v ...`.

    +/-150 mV about zero with 100 ps linear edges, so the eye is exactly
    300 mV tall at the centre of the bit and open for most of the UI.
    """
    bits = [int(c) for c in "01001101110100011011001011101000"]
    ui, trf, amp = 1e-9, 100e-12, 0.15
    dt = ui / 20

    def level(b):
        return amp if b else -amp

    def v(t):
        i = int(t // ui)
        if i >= len(bits):
            i = len(bits) - 1
        frac = t - i * ui
        prev = level(bits[i - 1]) if i > 0 else level(bits[0])
        cur = level(bits[i])
        if frac < trf and prev != cur:
            return prev + (cur - prev) * (frac / trf)
        return cur

    n = int(len(bits) * ui / dt)
    with open(path, "w") as f:
        f.write("#EYE synthetic ideal NRZ -- NOT a simulation result\n")
        for k in range(n):
            t = k * dt
            f.write(f" {t:.8e}  {v(t):.8e} \n")
    return bits, n


def write_pvt_logs(d):
    """T0/T1 corner logs that sit either side of the documented criteria."""
    def t0(path, freqs):
        # collect_pvt derives f = 20 / (b - a); emit the pair for each vctrl
        with open(path, "w") as f:
            f.write("* synthetic fixture -- NOT a simulation result\n")
            for vc, mhz in freqs.items():
                a = 1e-6
                b = a + 20.0 / (mhz * 1e6)
                tag = f"{vc:.2f}".replace(".", "p")
                f.write(f"v{tag}_a = {a:.9e}\n")
                f.write(f"v{tag}_b = {b:.9e}\n")
            f.write("exit rc=0\n")

    # a corner that brackets the 600.6 MHz baud rate, and one that does not
    t0(os.path.join(d, "T0_pass.log"),
       {0.70: 514.0, 0.75: 560.0, 0.79: 602.0, 0.85: 615.0, 1.00: 621.0})
    t0(os.path.join(d, "T0_slow.log"),
       {0.70: 474.0, 0.75: 500.0, 0.79: 533.0, 0.85: 542.0, 1.00: 546.0})

    with open(os.path.join(d, "T1_pass.log"), "w") as f:
        f.write("* synthetic fixture -- NOT a simulation result\n")
        f.write("nb_h = 8.200000e-01\nvc_h = 7.900000e-01\n"
                "t_rel = 1.500000e-07\nexit rc=0\n")
    with open(os.path.join(d, "T1_fail.log"), "w") as f:
        f.write("* synthetic fixture -- NOT a simulation result\n")
        # seed below the cliff: the precharge would not start the oscillator
        f.write("nb_h = 6.600000e-01\nvc_h = 6.400000e-01\n"
                "t_rel = 1.500000e-07\nexit rc=0\n")


if __name__ == "__main__":
    n, per = write_clock_raw(os.path.join(HERE, "ideal_clock.raw"))
    print(f"ideal_clock.raw   {n} points, {len(per)} periods, "
          f"UI {UI*1e12:.1f} ps +/- {JITTER*1e12:.0f} ps")
    bits, n = write_nrz_dat(os.path.join(HERE, "ideal_nrz.dat"))
    print(f"ideal_nrz.dat     {n} rows, {len(bits)} bits, 300 mV eye")
    write_pvt_logs(HERE)
    print("T0_pass.log T0_slow.log T1_pass.log T1_fail.log")
