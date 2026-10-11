#!/usr/bin/env python3
"""U5 analysis -- see gen_u5.py for what each copy isolates.

    u5_analyze.py U5_survey.raw

Window UIs 8-28. Reference for B/C/D: U4 tt/27C/1.8V (vctrl 0.79 V, ideal
vbias): main +34.09 fC, opposing -20.88 fC, 61.3 % cancelled.
Pure stdlib (../../../CLAUDE.md).
"""
import os
import re
import sys
from statistics import pstdev

UI = 1.665e-9
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "u1_analyze.py")).read()
exec(src.split("for raw in sys.argv")[0])   # read_raw

names, rows = read_raw(sys.argv[1])
idx = {re.sub(r"^[vi]\((.*)\)$", r"\1", n): i for i, n in enumerate(names)}
t = [r[0] for r in rows]
W = [j for j in range(1, len(t)) if 8 * UI <= t[j] <= 28 * UI]


def col(n):
    return [rows[j][idx[n]] for j in W]


def charge(n):
    qp = qn = 0.0
    for j in W:
        q = rows[j][idx[n]] * (t[j] - t[j - 1])
        if q > 0:
            qp += q
        else:
            qn += q
    qm, qo = (qp, qn) if abs(qp) >= abs(qn) else (qn, qp)
    return qm * 1e15, qo * 1e15, abs(qo) / abs(qm) * 100 if qm else 0.0


def glitches(n):
    ex, on, pk = [], None, 0.0
    for j in W:
        v = rows[j][idx[n]]
        if v > 0.9 and on is None:
            on, pk = t[j], v
        if on is not None:
            pk = max(pk, v)
        if v <= 0.9 and on is not None:
            ex.append((t[j] - on, pk))
            on = None
    return [e for e in ex if e[0] < 0.3 * UI], len(ex)


print("== A: frozen PD at +0.10 UI (other decision sign)")
for line in ("upA", "dnA"):
    g, n = glitches(line)
    print(f"  {line}: {n} excursions, {len(g)} glitches (<0.3 UI)" +
          (f", widths {sorted(round(w * 1e12) for w, _ in g)[len(g) // 2]} ps median, "
           f"peak {sorted(p for _, p in g)[len(g) // 2]:.2f} V median" if g else ""))
m, o, c = charge("iA")
print(f"  pump: main {m:+.2f} fC, opposing {o:+.2f} fC, cancelled {c:.1f} %")

print("== B/C: pump charge sharing vs vctrl (U4 reference at 0.79 V: +34.09 / -20.88 fC, 61.3 %)")
for k, v in (("iB", 0.65), ("iC", 0.95)):
    m, o, c = charge(k)
    pk = max(abs(x) for x in col(k)) * 1e6
    print(f"  vctrl {v:.2f} V: main {m:+.2f} fC, opposing {o:+.2f} fC, cancelled {c:.1f} %, peak {pk:.1f} uA")

print("== D: eight latch tails fed through 500 ohm from vbias")
vb = col("vbD")
print(f"  vbias at the latches: mean {sum(vb) / len(vb):.4f} V, pk-pk {(max(vb) - min(vb)) * 1e3:.1f} mV, "
      f"RMS {pstdev(vb) * 1e3:.2f} mV")
m, o, c = charge("iD")
print(f"  pump: main {m:+.2f} fC, opposing {o:+.2f} fC, cancelled {c:.1f} %")

print("== E vs F: PD sampling kickback on the CTLE output")
de = [a - b for a, b in zip(col("eqEp"), col("eqEm"))]
df = [a - b for a, b in zip(col("eqFp"), col("eqFm"))]
k = [a - b for a, b in zip(de, df)]
ce = [(a + b) / 2 for a, b in zip(col("eqEp"), col("eqEm"))]
cf = [(a + b) / 2 for a, b in zip(col("eqFp"), col("eqFm"))]
kc = [a - b for a, b in zip(ce, cf)]
print(f"  CTLE diff output swing (unloaded): pk-pk {(max(df) - min(df)) * 1e3:.0f} mV")
print(f"  differential kick (loaded - unloaded): pk-pk {(max(k) - min(k)) * 1e3:.1f} mV, RMS {pstdev(k) * 1e3:.2f} mV")
print(f"  common-mode shift/kick: mean {sum(kc) / len(kc) * 1e3:+.1f} mV, pk-pk {(max(kc) - min(kc)) * 1e3:.1f} mV")
