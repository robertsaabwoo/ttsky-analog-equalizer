#!/usr/bin/env python3
"""Eye height / width from an ngspice `wrdata` transient log.

    eyemetrics.py <log> [names...]

Reads the `#EYE`-tagged block of a run log: rows of
    t v1 t v2 t v3 ...
and, using the known PRBS bit sequence in prbs_bits.txt, reports for each
signal column the best-sampling-phase eye height and the eye width.

Because the bit values are known, "eye height" here is the true worst-case
separation between the lowest 1 and the highest 0 at the sampling instant —
the number a slicer actually cares about — not a picture.  Pure stdlib.
"""
import sys

SKIP = 6          # settling bits ignored at the start
NPHASE = 200


def read_block(path, tag="#EYE"):
    """Collect the wrdata rows.  ngspice's own stdout and the `shell cat` child
    are buffered independently, so the #EYE marker can land after the data it
    labels; we therefore just take every numeric wrdata row in the file."""
    rows = []
    for line in open(path):
        if line.startswith(tag):
            continue
        p = line.split()
        if len(p) < 2 or len(p) % 2:
            if rows:
                break
            continue
        try:
            vals = [float(x) for x in p]
        except ValueError:
            if rows:
                break
            continue
        rows.append([vals[0]] + vals[1::2])
    return rows


def sample(rows, t, col):
    """linear interpolation of column `col` at time t (rows are time-sorted)"""
    lo, hi = 0, len(rows) - 1
    if t <= rows[0][0]:
        return rows[0][col]
    if t >= rows[-1][0]:
        return rows[-1][col]
    while hi - lo > 1:
        mid = (lo + hi) // 2
        if rows[mid][0] <= t:
            lo = mid
        else:
            hi = mid
    t0, t1 = rows[lo][0], rows[hi][0]
    v0, v1 = rows[lo][col], rows[hi][col]
    return v0 + (v1 - v0) * (t - t0) / (t1 - t0)


def eye(rows, col, bits, ui):
    """returns (best_phase, height, width_UI, mean1, mean0, inverted)

    A common-source diff pair inverts, so the sign of the column is detected
    from the data (mean of the 1-bits vs the 0-bits at mid-bit) and undone
    before the eye is measured."""
    mid1 = [sample(rows, (i + 0.5) * ui, col) for i in range(SKIP, len(bits)) if bits[i]]
    mid0 = [sample(rows, (i + 0.5) * ui, col) for i in range(SKIP, len(bits)) if not bits[i]]
    sgn = -1.0 if (sum(mid1) / len(mid1)) < (sum(mid0) / len(mid0)) else 1.0
    best = (0.0, -1e9)
    heights = []
    for k in range(NPHASE):
        ph = k / NPHASE
        ones, zeros = [], []
        for i in range(SKIP, len(bits)):
            t = (i + ph) * ui
            if t > rows[-1][0]:
                break
            v = sgn * sample(rows, t, col)
            (ones if bits[i] else zeros).append(v)
        if not ones or not zeros:
            heights.append((ph, -1e9))
            continue
        h = min(ones) - max(zeros)
        heights.append((ph, h))
        if h > best[1]:
            best = (ph, h)
    open_frac = sum(1 for _, h in heights if h > 0) / NPHASE
    ph = best[0]
    ones = [sgn * sample(rows, (i + ph) * ui, col) for i in range(SKIP, len(bits)) if bits[i]]
    zeros = [sgn * sample(rows, (i + ph) * ui, col) for i in range(SKIP, len(bits)) if not bits[i]]
    return ph, best[1], open_frac, sum(ones) / len(ones), sum(zeros) / len(zeros), sgn


def main():
    log = sys.argv[1]
    names = sys.argv[2:]
    txt = open("prbs_bits.txt").read().split()
    bits = [int(c) for c in txt[0]]
    ui = float(txt[1])
    rows = read_block(log)
    if not rows:
        print("no #EYE block found")
        return
    ncol = len(rows[0]) - 1
    if not names:
        names = [f"col{i}" for i in range(1, ncol + 1)]
    print(f"{len(rows)} samples, {rows[-1][0]*1e9:.1f} ns, UI = {ui*1e12:.0f} ps, "
          f"{len(bits)} bits ({SKIP} skipped)")
    print()
    print(f"{'signal':<14}{'eye height':>12}{'eye width':>12}{'best phase':>12}"
          f"{'mean 1':>10}{'mean 0':>10}{'swing':>10}")
    print("-" * 80)
    for c in range(1, ncol + 1):
        ph, h, w, m1, m0, sgn = eye(rows, c, bits, ui)
        inv = " (inv)" if sgn < 0 else ""
        print(f"{names[c-1]:<14}{h*1e3:9.1f} mV{w:9.3f} UI{ph:12.3f}"
              f"{m1*1e3:9.1f}m{m0*1e3:9.1f}m{(m1-m0)*1e3:9.1f}m{inv}")
    print()
    print("eye height = min(1-samples) - max(0-samples) at the best sampling phase")
    print("eye width  = fraction of the UI over which that separation stays > 0")


if __name__ == "__main__":
    main()
