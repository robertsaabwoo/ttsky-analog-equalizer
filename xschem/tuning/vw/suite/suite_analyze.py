#!/usr/bin/env python3
"""Closed-loop PVT suite results: one row per corner.

    suite_analyze.py <design-dir> [...]

Per corner (from <corner>.dat, <corner>_chain.raw, <corner>.log):
  vctrl   100-ns averages at 0.5 / 1.0 / 2.0 / 2.5 / 2.9 us -- settled when the
          last three agree within a few mV
  f       recovered-clock frequency over 2-3 us (data rate: 600.60 MHz)
  LOCK    |f - 600.6| < 0.5 MHz and vctrl settled within 15 mV over 2-2.9 us
  period / phase RMS and samples < 25 mV, over 2-3 us (../../c27_analyze.py)
  I       total metered supply current over the last 400 ns
Rows for corners that did not run say so. Reads .dat/.raw or their .gz. Pure stdlib (../../../../CLAUDE.md).
"""
import bisect
import gzip
import glob
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
C27 = os.path.join(HERE, "..", "..", "c27_analyze.py")
UI = 1.665e-9


def opn(path):
    return gzip.open(path, "rt") if path.endswith(".gz") else open(path)


def vavgs(dat):
    t, v = [], []
    with opn(dat) as f:
        for line in f:
            p = line.split()
            if len(p) >= 2:
                t.append(float(p[0]))
                v.append(float(p[1]))
    out = []
    for a in (0.5, 1.0, 2.0, 2.5, 2.9):
        i, j = bisect.bisect(t, a * 1e-6), bisect.bisect(t, (a + 0.1) * 1e-6)
        seg = v[i:j]
        out.append(sum(seg) / len(seg) if seg else float("nan"))
    return out


def freq(raw):
    t, c, n, mode, cur = [], [], None, None, []
    with opn(raw) as f:
        for line in f:
            s = line.strip()
            if s.startswith("No. Variables:"):
                n = int(s.split(":")[1])
            elif s.startswith("Values:"):
                mode = 1
            elif mode and s:
                cur.append(float(s.split()[-1]))
                if len(cur) == n:
                    t.append(cur[0])
                    c.append(cur[1])
                    cur = []
    e = [t[i] for i in range(1, len(t)) if t[i] >= 2e-6 and c[i - 1] < 0.9 <= c[i]]
    return (len(e) - 1) / (e[-1] - e[0]) / 1e6 if len(e) > 10 else float("nan")


def c27(raw):
    tmp = None
    if raw.endswith(".gz"):
        tmp = tempfile.NamedTemporaryFile("w", suffix=".raw", dir="/dev/shm", delete=False)
        with gzip.open(raw, "rt") as f:
            tmp.writelines(f)
        tmp.close()
        raw = tmp.name
    out = subprocess.run([sys.executable, C27, raw, "1.665", "2000"], capture_output=True, text=True).stdout
    if tmp:
        os.unlink(tmp.name)
    g = lambda pat: (re.search(pat, out) or [None, "nan"])[1]
    return (g(r"period RMS\s*:\s*[\d.]+ ps = ([\d.]+) % UI"), g(r"phase RMS\s*:\s*[\d.]+ ps = ([\d.]+) % UI"),
            g(r"samples < 25 mV: (\d+ of \d+)"))


def current(log):
    tot = 0.0
    for line in open(log):
        m = re.match(r"(vx\S*)\s+=\s+([-\d.e+]+)\s+from", line)
        if m:
            tot += -float(m.group(2))
    return tot * 1e6


for d in sys.argv[1:]:
    print(f"\n=== {os.path.basename(d.rstrip('/'))}")
    print(f"{'corner':20s} vctrl@0.5/1/2/2.5/2.9us          f(MHz)   LOCK  period%UI phase%UI  <25mV       I(uA)")
    for deck in sorted(glob.glob(os.path.join(d, "*.spice"))):
        tg = os.path.basename(deck)[:-6]
        dat, raw, log = (os.path.join(d, tg + x) for x in (".dat", "_chain.raw", ".log"))
        dat, raw = (p + ".gz" if not os.path.exists(p) and os.path.exists(p + ".gz") else p for p in (dat, raw))
        if not (os.path.exists(dat) and os.path.exists(raw)):
            st = open(log).read().strip().splitlines()[-1] if os.path.exists(log) else "not run"
            print(f"{tg:20s} -- no data ({st})")
            continue
        va = vavgs(dat)
        f = freq(raw)
        settled = max(va[2:]) - min(va[2:]) < 0.015
        lock = abs(f - 600.6) < 0.5 and settled
        pr, ph, nz = c27(raw)
        cur = current(log) if os.path.exists(log) else float("nan")
        print(f"{tg:20s} {' '.join(f'{x:.3f}' for x in va)}  {f:7.2f}   {'yes' if lock else 'NO ':3s}   "
              f"{pr:>6s}   {ph:>6s}   {nz:>10s}  {cur:7.1f}")
