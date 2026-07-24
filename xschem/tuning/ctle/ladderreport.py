#!/usr/bin/env python3
"""Rank CTLE sizings against three channels at once (reads a ladder.spice log).

Each `#PT`-tagged block holds wrdata rows of
    f ga f ia f gb f ib f gc f ic
i.e. combined (channel+CTLE) and channel-only differential responses in dB for
the 1 pF, 2 pF and 4 pF channels.

For each channel we report:
  ripple  worst deviation of the combined response from its own DC value
          anywhere in DC..Nyquist.  0 dB == the channel has been exactly undone.
  @Nyq    absolute combined gain at Nyquist -- how much signal the next stage
          actually gets on the worst-case data pattern.

usage: ladderreport.py <log> [nyquist_Hz] [sort_channel] [labels_csv]

labels_csv renames the three channels (default "1p,2p,4p"); ladder_tt.spice uses
the Tiny Tapeout pin channels, so pass e.g. "500/5p,350/3p,200/1.5p".
"""
import sys
from math import log10

CH = ["1p", "2p", "4p"]


def blocks(path):
    key, rows = None, []
    for line in open(path):
        if line.startswith("#PT"):
            if key is not None:
                yield key, rows
            key, rows = line[3:].strip(), []
            continue
        p = line.split()
        if len(p) != 12:
            continue
        try:
            v = [float(x) for x in p]
        except ValueError:
            continue
        rows.append((v[0], v[1], v[3], v[5], v[7], v[9], v[11]))
    if key is not None:
        yield key, rows


def at(rows, col, f):
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


def chan_metrics(rows, comb_col, nyq):
    dc = at(rows, comb_col, 1e6)
    ripple = max(abs(r[comb_col] - dc) for r in rows if 1e6 <= r[0] <= nyq)
    return ripple, at(rows, comb_col, nyq)


def main():
    global CH
    path = sys.argv[1]
    nyq = float(sys.argv[2]) if len(sys.argv) > 2 else 300e6
    if len(sys.argv) > 4:
        CH = sys.argv[4].split(",")
    sortch = sys.argv[3] if len(sys.argv) > 3 else CH[1]
    ci = CH.index(sortch)

    out = []
    for key, rows in blocks(path):
        if not rows:
            continue
        m = [chan_metrics(rows, 1 + 2 * i, nyq) for i in range(3)]
        out.append((key, m))
    out.sort(key=lambda e: e[1][ci][0])

    print(f"Nyquist = {nyq/1e6:.0f} MHz.  Sorted by ripple on the {sortch} channel.")
    print("ripple = worst dB deviation of channel+CTLE from its own DC value over "
          "DC..Nyquist")
    print("@Nyq   = absolute channel+CTLE gain at Nyquist, dB")
    print()
    print(f"{'sizing':<28}" + "".join(f"{'ch ' + c:>18}" for c in CH))
    print(f"{'':<28}" + "".join(f"{'ripple':>9}{'@Nyq':>9}" for _ in CH))
    print("-" * 84)
    for key, m in out:
        print(f"{key:<28}" + "".join(f"{r:9.2f}{g:+9.2f}" for r, g in m))


if __name__ == "__main__":
    main()
