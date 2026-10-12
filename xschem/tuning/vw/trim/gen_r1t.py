#!/usr/bin/env python3
"""R1T: the R1 bench (../suite/gen_r1.py) with the coarse trim on all ten ring nodes.

    gen_r1t.py [corner-tag ...]     -> decks/<corner>.spice  (default: all 13)

One ngspice run per corner: every trim state x every vctrl point, by `alter`
(CLAUDE.md section 1). Ring loading is option A's closed loop exactly (the
suite deck minus pump / filter / precharge / CTLE), plus ring_trim.inc.
Option-5 question: is there, at every corner, a trim state that puts
600.6 MHz near the precharge seed (0.79 V), on the rising part of f(vctrl)?
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "suite"))
import gen_r1  # noqa: E402

SUITE = os.path.join(HERE, "..", "suite", "cml_full")
NODES = ["x2_t7", "x2_t8"] + [f"x2_x1_n{i}" for i in (1, 2, 3, 4, 5, 6, 9, 10)]
# ring_trim3: code 0..7, bit k on = leg k switched in (active-low pMOS gate)
STATES = {f"c{k}": tuple((k >> b) & 1 for b in range(3)) for k in range(8)}
VCTRL = [0.75, 0.79]


def trimmed_ring(s):
    """Point the five ring stages at ring_inverter_t (shorter load, ring_trim.inc)."""
    s, n = re.subn(r"^(x2_x1_x\d+ .*) ring_inverter$", r"\1 ring_inverter_t", s, flags=re.M)
    assert n == 5, n
    return s


def deck(src):
    gen_r1.VCTRL = []                  # take gen_r1's netlist, write our own control
    s = gen_r1.deck("cml_full", src)
    s = trimmed_ring(s[:s.index(".control")])
    vdd = float([l for l in s.splitlines() if l.startswith("Vtie ")][0].split()[3])
    out = [s.rstrip(), f".include {os.path.join(HERE, 'ring_trim.inc')}",
           "Vb0n b0n 0 0", "Vb1n b1n 0 0", "Vb2n b2n 0 0"]
    out += [f"Xtr{i} {n} vdd_trim 0 b0n b1n b2n ring_trim3" for i, n in enumerate(NODES)]
    out += [f"Vtrim vdd_trim 0 {vdd}", ".control", "  save v(x2_t7) v(x2_t8)"]
    for st, bits in STATES.items():
        out += [f"  alter Vb{b}n dc={0 if on else vdd}" for b, on in enumerate(bits)]
        for v in VCTRL:
            t = f"{st}_v{v:.2f}".replace(".", "p")
            out += [f"  alter Vctl dc={v}", "  tran 10p 90n uic",
                    f"  meas tran {t}_a when v(x2_t7)=v(x2_t8) rise=8",
                    f"  meas tran {t}_b when v(x2_t7)=v(x2_t8) rise=30"]
    out += [".endc", ".end", ""]
    return "\n".join(out)


if __name__ == "__main__":
    tags = sys.argv[1:] or sorted(f[:-6] for f in os.listdir(SUITE) if f.endswith(".spice"))
    os.makedirs(os.path.join(HERE, "decks"), exist_ok=True)
    for t in tags:
        open(os.path.join(HERE, "decks", t + ".spice"), "w").write(deck(os.path.join(SUITE, t + ".spice")))
    print(f"{len(tags)} decks")
