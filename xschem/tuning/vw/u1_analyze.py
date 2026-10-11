#!/usr/bin/env python3
"""U1 analysis: delay from each data transition to the charge-pump current.

    u1_analyze.py U1_cml.raw [U1_frozen.raw ...]

Reads the bit pattern and the clock offsets from the deck header (decks/U1_*.spice)
and the charge-pump output current per offset from the rawfile. A charge-pump
pulse starts when |icp| crosses half the nominal 1.26 uA. Each pulse is matched
to the data transition that caused it: the pipeline depth (whole UIs) is found
as the offset that matches the most pulses, then the delay is measured from the
transition's mid-point to the pulse start. Also reported: the sign of the
decision (up = +, clock late) and the charge per decision in units of
Icp x 1 UI (1.0 = one full-strength 1-UI pulse).
Pure stdlib (../../../CLAUDE.md).
"""
import os
import sys
from statistics import mean, median, pstdev

UI = 1.665e-9
ICP = 1.26e-6
TR_MID = 50e-12        # gen_cml.pwl: transitions start at n*UI, 100 ps long


def read_raw(path):
    names, rows, nv, mode, cur = [], [], None, None, []
    with open(path) as f:
        for line in f:
            s = line.strip()
            if s.startswith("No. Variables:"):
                nv = int(s.split(":")[1])
            elif s.startswith("Variables:"):
                mode = "vars"
            elif s.startswith("Values:"):
                mode = "vals"
            elif mode == "vars" and s:
                names.append(s.split()[1])
                if len(names) == nv:
                    mode = None
            elif mode == "vals" and s:
                cur.append(float(s.split()[-1]))
                if len(cur) == nv:
                    rows.append(cur)
                    cur = []
    return names, rows


for raw in sys.argv[1:]:
    design = os.path.basename(raw)[3:-4]
    deck = os.path.join(os.path.dirname(raw) or ".", "decks", f"U1_{design}.spice")
    hdr = open(deck).read().splitlines()[:3]
    phases = [float(x) for x in hdr[1].split("offsets")[1].split("UI")[0].split()]
    bits = [int(c) for c in hdr[2].split()[2]]
    trans = [n * UI + TR_MID for n in range(1, len(bits)) if bits[n] != bits[n - 1]]
    names, rows = read_raw(raw)
    t = [r[0] for r in rows]
    print(f"\n=== {design}: {len(trans)} data transitions")
    print("offset   pulses  sign(+=up)  pipeline  delay median   spread(RMS)   charge/decision")
    for k, ph in enumerate(phases):
        i = [r[k + 1] for r in rows]
        t0 = 10 * UI
        # pulse starts and the charge in each pulse
        starts, q, inside, acc, sgn = [], [], False, 0.0, 0
        for j in range(1, len(t)):
            if t[j] < t0:
                continue
            dt = t[j] - t[j - 1]
            if not inside and abs(i[j]) > ICP / 2:
                inside, acc, sgn = True, 0.0, (1 if i[j] > 0 else -1)
                # interpolate the crossing
                a, b = abs(i[j - 1]), abs(i[j])
                starts.append((t[j - 1] + dt * (ICP / 2 - a) / (b - a) if b != a else t[j], sgn))
            if inside:
                acc += i[j] * dt
                if abs(i[j]) < ICP / 4:
                    inside = False
                    q.append(acc / (ICP * UI))
        if not starts:
            print(f"{ph:+6.2f}   no charge-pump pulses")
            continue
        tr_in = [x for x in trans if x >= t0 - 4 * UI]
        best = None
        for m in range(0, 6):
            d = []
            for ts, _ in starts:
                cands = [ts - x for x in tr_in if m * UI <= ts - x < (m + 1) * UI]
                if cands:
                    d.append(cands[0])
            if best is None or len(d) > len(best[1]):
                best = (m, d)
        m, d = best
        signs = [s for _, s in starts]
        print(f"{ph:+6.2f}   {len(starts):5d}   {mean(signs):+5.2f}      {m} UI   "
              f"{median(d)*1e12:7.1f} ps = {median(d)/UI:4.2f} UI  {pstdev(d)*1e12:6.1f} ps   "
              f"{mean(abs(x) for x in q):5.2f}")
