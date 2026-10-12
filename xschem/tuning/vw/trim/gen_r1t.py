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
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "suite"))
import gen_r1  # noqa: E402

SUITE = os.path.join(HERE, "..", "suite", "cml_full")
NODES = ["x2_t7", "x2_t8"] + [f"x2_x1_n{i}" for i in (1, 2, 3, 4, 5, 6, 9, 10)]
# state -> (f0, f1, s0, s1) as "on" flags; f* are active-low pMOS gates
STATES = {"N": (0, 0, 0, 0), "F1": (1, 0, 0, 0), "F2": (0, 1, 0, 0), "F3": (1, 1, 0, 0),
          "S1": (0, 0, 1, 0), "S2": (0, 0, 0, 1), "S3": (0, 0, 1, 1)}
VCTRL = [0.79, 1.05]


def deck(src):
    gen_r1.VCTRL = []                  # take gen_r1's netlist, write our own control
    s = gen_r1.deck("cml_full", src)
    s = s[:s.index(".control")]
    vdd = float([l for l in s.splitlines() if l.startswith("Vtie ")][0].split()[3])
    out = [s.rstrip(), f".include {os.path.join(HERE, 'ring_trim.inc')}",
           "Vf0n f0n 0 0", "Vf1n f1n 0 0", "Vs0 s0 0 0", "Vs1 s1 0 0"]
    out += [f"Xtr{i} {n} vdd_trim 0 f0n f1n s0 s1 ring_trim_node" for i, n in enumerate(NODES)]
    out += [f"Vtrim vdd_trim 0 {vdd}", ".control", "  save v(x2_t7) v(x2_t8)"]
    for st, (f0, f1, s0, s1) in STATES.items():
        out += [f"  alter Vf0n dc={0 if f0 else vdd}", f"  alter Vf1n dc={0 if f1 else vdd}",
                f"  alter Vs0 dc={vdd if s0 else 0}", f"  alter Vs1 dc={vdd if s1 else 0}"]
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
