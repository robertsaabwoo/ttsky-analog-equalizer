#!/usr/bin/env python3
"""Report CTLE AC metrics for every point in a concatenated sweep file.

The file is a sequence of blocks:
    #PT <key> <val> <key> <val> ...
    <freq> <gain_out_dB> <freq> <gain_in_dB>
    ...

Column 2 is the differential response measured at the CTLE output (channel
INCLUDED, since the AC source sits before the channel); column 4 is the
differential response at the CTLE input (channel only).  CTLE-alone response
is column2 - column4.

usage: sweepreport.py <all.dat> [nyquist_Hz]
"""
import sys
from math import log10


def blocks(path):
    key, rows = None, []
    with open(path) as f:
        for line in f:
            if line.startswith("#PT"):
                if key is not None:
                    yield key, rows
                key, rows = line[3:].strip(), []
                continue
            p = line.split()
            if len(p) >= 4:
                try:
                    rows.append((float(p[0]), float(p[1]), float(p[3])))
                except ValueError:
                    pass
    if key is not None:
        yield key, rows


def interp(rows, col, f):
    if f <= rows[0][0]:
        return rows[0][col]
    if f >= rows[-1][0]:
        return rows[-1][col]
    for i in range(1, len(rows)):
        if rows[i][0] >= f:
            f0, f1 = rows[i - 1][0], rows[i][0]
            g0, g1 = rows[i - 1][col], rows[i][col]
            t = (log10(f) - log10(f0)) / (log10(f1) - log10(f0))
            return g0 + t * (g1 - g0)
    return rows[-1][col]


def metrics(rows, nyq):
    """all metrics on the *combined* channel+CTLE response, plus CTLE-only peaking"""
    ctle = [(r[0], r[1] - r[2]) for r in rows]          # CTLE alone
    comb = [(r[0], r[1]) for r in rows]                 # channel + CTLE

    def at(seq, f):
        return interp([(a, b, 0) for a, b in seq], 1, f)

    cdc = at(ctle, 1e6)
    ipk = max(range(len(ctle)), key=lambda i: ctle[i][1])
    cpk, fpk = ctle[ipk][1], ctle[ipk][0]

    # combined-response flatness: how far the channel+CTLE response at Nyquist
    # sits below its own low-frequency value.  0 dB == perfectly equalized.
    kdc = at(comb, 1e6)
    # ripple = worst deviation of the combined response from its own DC value
    # anywhere in DC..Nyquist.  This is the single number that says "flat".
    ripple = max(abs(g - kdc) for f, g in comb if 1e6 <= f <= nyq)
    return {
        "ctle_dc": cdc,
        "ctle_pk": cpk,
        "f_pk": fpk,
        "boost": cpk - cdc,
        "comb_dc": kdc,
        "comb_nyq": at(comb, nyq) - kdc,
        "comb_half": at(comb, nyq / 2) - kdc,
        "out_nyq_abs": at(comb, nyq),
        "ripple": ripple,
    }


def main():
    path = sys.argv[1]
    nyq = float(sys.argv[2]) if len(sys.argv) > 2 else 300e6
    print(f"Nyquist = {nyq/1e6:.0f} MHz     (combined = channel + CTLE)")
    print()
    print(f"{'point':<26} {'CTLEdc':>7} {'boost':>6} {'fpk':>7} "
          f"{'@Nyq/2':>7} {'@Nyq':>6} {'ripple':>7} {'|H|@Nyq':>8}")
    print("-" * 84)
    for key, rows in blocks(path):
        if not rows:
            continue
        m = metrics(rows, nyq)
        print(f"{key:<26} {m['ctle_dc']:+7.2f} {m['boost']:+6.2f} "
              f"{m['f_pk']/1e9:6.2f}G {m['comb_half']:+7.2f} "
              f"{m['comb_nyq']:+6.2f} {m['ripple']:7.2f} {m['out_nyq_abs']:+8.2f}")
    print()
    print("CTLE dc / boost / comb@* in dB.  comb@Nyq is the combined response at")
    print("Nyquist relative to its own DC value: 0.00 dB == flat == fully equalized.")


if __name__ == "__main__":
    main()
