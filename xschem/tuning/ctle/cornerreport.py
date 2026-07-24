#!/usr/bin/env python3
"""Summarise a 27-corner ac_corner*.spice log (#PT-tagged blocks of `f gdb f gind`).

On the spec-worst TT channel the combined response can no longer be flattened,
so `ripple` is not the useful metric here -- what matters is
  boost   the CTLE's OWN peaking (gdb - gind, peak minus DC): what it contributes
  @Nyq    the absolute combined gain at Nyquist: what the next stage receives
Prints the per-corner table and the min/max envelope.  usage:
    cornerreport.py <log>... [nyquist_Hz]
"""
import sys
from math import log10


def blocks(path):
    key, rows = None, []
    for line in open(path):
        if line.startswith("#PT"):
            if key is not None:
                yield key, rows
            key, rows = line[3:].strip(), []
            continue
        p = line.split()
        if len(p) != 4:
            continue
        try:
            v = [float(x) for x in p]
        except ValueError:
            continue
        rows.append((v[0], v[1], v[3]))
    if key is not None:
        yield key, rows


def at(rows, col, f):
    if f <= rows[0][0]:
        return rows[0][col]
    for i in range(1, len(rows)):
        if rows[i][0] >= f:
            f0, f1 = rows[i - 1][0], rows[i][0]
            g0, g1 = rows[i - 1][col], rows[i][col]
            t = (log10(f) - log10(f0)) / (log10(f1) - log10(f0))
            return g0 + t * (g1 - g0)
    return rows[-1][col]


def main():
    args = sys.argv[1:]
    nyq = 300e6
    if args and not args[-1].endswith(".log"):
        nyq = float(args.pop())

    print(f"Nyquist = {nyq/1e6:.0f} MHz")
    print("ctle_dc/ctle_Nyq = CTLE alone (combined minus channel-only), dB")
    print("boost            = CTLE alone, peak minus DC, dB")
    print("@Nyq             = combined channel+CTLE gain at Nyquist, dB\n")
    print(f"{'corner':<28}{'ctle_dc':>9}{'boost':>8}{'ctle_Nyq':>10}{'@Nyq':>8}")
    print("-" * 63)
    env = []
    for path in args:
        mos = path.split("_")[-1].split(".")[0]
        for key, rows in blocks(path):
            if not rows:
                continue
            solo = [(f, g - i) for f, g, i in rows]
            dc = solo[0][1]
            peak = max(s[1] for s in solo)
            cn = at([(f, v, v) for f, v in solo], 1, nyq)
            comb = at(rows, 1, nyq)
            env.append((peak - dc, cn, comb))
            print(f"{mos + ' ' + key:<28}{dc:+9.2f}{peak - dc:+8.2f}"
                  f"{cn:+10.2f}{comb:+8.2f}")
    if env:
        print("-" * 63)
        print(f"{'ENVELOPE (min..max)':<28}{'':>9}"
              f"{min(e[0] for e in env):+8.2f}{min(e[1] for e in env):+10.2f}"
              f"{min(e[2] for e in env):+8.2f}")
        print(f"{'':<28}{'':>9}{max(e[0] for e in env):+8.2f}"
              f"{max(e[1] for e in env):+10.2f}{max(e[2] for e in env):+8.2f}")


if __name__ == "__main__":
    main()
