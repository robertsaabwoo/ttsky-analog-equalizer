#!/usr/bin/env python3
"""C1T: option A closed loop (suite cml_full deck) with the ring trim at a fixed code.

    gen_c1t.py <corner>:<state> [...]     -> closed/<corner>.spice

<state> is a key of gen_r1t.STATES (c0 .. c7, the 3-bit trim code). Cold start, same
stimulus, window and outputs as the suite, so ../suite/suite_analyze.py reads
the results:  ../suite/suite_analyze.py closed
Run with ../suite/run_suite.sh ../trim/closed <corner> ...  (one ngspice at a time).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from gen_r1t import NODES, STATES, SUITE, trimmed_ring  # noqa: E402


def deck(corner, state):
    s = trimmed_ring(open(os.path.join(SUITE, corner + ".spice")).read())
    vdd = float([l for l in s.splitlines() if l.startswith("Vtie ")][0].split()[3])
    bits = STATES[state]
    add = [f"* C1T trim state {state}",
           f".include {os.path.join(HERE, 'ring_trim.inc')}",
           f"Vtrim vdd_trim 0 {vdd}",
           *[f"Vb{b}n b{b}n_s 0 {0 if on else vdd}" for b, on in enumerate(bits)],
           *[f"Rb{b}n b{b}n_s b{b}n 1k" for b in range(3)]]
    add += [f"Xtr{i} {n} vdd_trim 0 b0n b1n b2n ring_trim3" for i, n in enumerate(NODES)]
    i = s.index(".control")
    return s[:i] + "\n".join(add) + "\n" + s[i:]


if __name__ == "__main__":
    os.makedirs(os.path.join(HERE, "closed"), exist_ok=True)
    for arg in sys.argv[1:]:
        c, st = arg.split(":")
        open(os.path.join(HERE, "closed", c + ".spice"), "w").write(deck(c, st))
        print(f"closed/{c}.spice  trim {st}")
