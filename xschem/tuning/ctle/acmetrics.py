#!/usr/bin/env python3
"""Summarize a CTLE AC response written by ngspice `wrdata` (freq, gain_dB).

usage: acmetrics.py <file.dat> [nyquist_Hz]

Prints: DC gain, peak gain + frequency, boost (peak-DC), gain at Nyquist,
gain at Nyquist/2, high-frequency -3dB point relative to the peak.
Pure stdlib (numpy is not installed on this VM).
"""
import sys


def load(path):
    pts = []
    with open(path) as f:
        for line in f:
            p = line.split()
            if len(p) < 2:
                continue
            try:
                pts.append((float(p[0]), float(p[1])))
            except ValueError:
                continue
    return pts


def at(pts, f):
    """log-frequency linear interpolation of the dB curve"""
    if f <= pts[0][0]:
        return pts[0][1]
    if f >= pts[-1][0]:
        return pts[-1][1]
    from math import log10
    for i in range(1, len(pts)):
        if pts[i][0] >= f:
            f0, g0 = pts[i - 1]
            f1, g1 = pts[i]
            t = (log10(f) - log10(f0)) / (log10(f1) - log10(f0))
            return g0 + t * (g1 - g0)
    return pts[-1][1]


def cross_after(pts, ipk, level):
    """first frequency above index ipk where the curve falls through `level`"""
    from math import log10
    for i in range(ipk + 1, len(pts)):
        if pts[i][1] <= level:
            f0, g0 = pts[i - 1]
            f1, g1 = pts[i]
            if g0 == g1:
                return f1
            t = (g0 - level) / (g0 - g1)
            return 10 ** (log10(f0) + t * (log10(f1) - log10(f0)))
    return None


def summarize(path, nyq=300e6, label=None):
    pts = load(path)
    if not pts:
        print(f"{path}: no data")
        return None
    gdc = at(pts, 1e6)
    ipk = max(range(len(pts)), key=lambda i: pts[i][1])
    gpk, fpk = pts[ipk][1], pts[ipk][0]
    f3 = cross_after(pts, ipk, gpk - 3.0)
    m = {
        "dc_dB": gdc,
        "peak_dB": gpk,
        "fpeak_Hz": fpk,
        "boost_dB": gpk - gdc,
        "g_nyq_dB": at(pts, nyq),
        "g_halfnyq_dB": at(pts, nyq / 2),
        "eq_dB": at(pts, nyq) - at(pts, nyq / 2),
        "f3dB_Hz": f3,
    }
    tag = label or path
    print(f"{tag}:")
    print(f"  DC gain            {m['dc_dB']:+7.2f} dB   ({10**(m['dc_dB']/20):.3f} V/V)")
    print(f"  peak gain          {m['peak_dB']:+7.2f} dB  @ {m['fpeak_Hz']/1e9:8.3f} GHz")
    print(f"  boost (pk - DC)    {m['boost_dB']:+7.2f} dB")
    print(f"  gain @ Nyq/2 {nyq/2/1e6:6.1f}MHz {m['g_halfnyq_dB']:+7.2f} dB")
    print(f"  gain @ Nyq   {nyq/1e6:6.1f}MHz {m['g_nyq_dB']:+7.2f} dB")
    print(f"  equalization Nyq-Nyq/2 {m['eq_dB']:+7.2f} dB")
    print(f"  -3dB (from peak)   {('%.3f GHz' % (f3/1e9)) if f3 else 'beyond sweep'}")
    return m


if __name__ == "__main__":
    nyq = float(sys.argv[2]) if len(sys.argv) > 2 else 300e6
    summarize(sys.argv[1], nyq)
