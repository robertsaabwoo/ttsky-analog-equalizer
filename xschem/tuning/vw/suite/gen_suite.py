#!/usr/bin/env python3
"""Closed-loop PVT suite: cold start -> acquisition -> lock -> jitter, per corner.

    gen_suite.py <design> [<design> ...]       # writes <design>/<corner>.spice

The tier the project never ran (HANDOFF: "T2 PVT tier was never run"): the
whole macro, closed loop, from power-up with the precharge, at each corner.
Designs (flattened chain decks, every leaf cell metered):
  cml_full  ../decks/S3_full.spice   CML: scaled filter, cml_pd_cx3w, cml_bias,
                                     cml_clkbuf, cp_bias
  cml_buf   ../decks/S3_buf.spice    as cml_full but the pump on tiny_pll_bias_gen
  frozen    ../V1_frozen.spice       the frozen design (power/P0's netlist)
Per corner: MOS / R+C corner and temperature (../../pvt/gen_pvt.py
corner_block), every supply source at the corner's VDD, PRBS7 through the
500 ohm / 5 pF pad model, 3 us; the vctrl/C1 initial conditions are dropped so
the precharge does the start (its own .ic on the POR node stays, see
docs/SIMULATION_TRAPS.md section 1). suite_analyze.py reads the results.
Pure stdlib (../../../../CLAUDE.md).
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VW = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(VW, "..", "pvt"))
from gen_pvt import corner_block  # noqa: E402

BASES = {"cml_full": os.path.join(VW, "decks", "S3_full.spice"),
         "cml_buf": os.path.join(VW, "decks", "S3_buf.spice"),
         "frozen": os.path.join(VW, "V1_frozen.spice")}
# (mos, rc, temp, vdd): nominal first, then process at 27 C, cold, supply, hot
CORNERS = [("tt", "typ", 27, 1.8), ("ss", "typ", 27, 1.8), ("ff", "typ", 27, 1.8),
           ("sf", "typ", 27, 1.8), ("fs", "typ", 27, 1.8),
           ("tt", "typ", -40, 1.8), ("ss", "typ", -40, 1.8), ("ff", "typ", -40, 1.8),
           ("tt", "typ", 27, 1.62), ("tt", "typ", 27, 1.98),
           ("tt", "hh", 27, 1.8), ("tt", "ll", 27, 1.8),
           ("tt", "typ", 125, 1.8)]
TSTOP = 3000


def tag(c):
    mos, rc, t, v = c
    return f"{mos}_{rc}_{t}C_{v:.2f}V".replace(".", "p").replace("-", "m")


def deck(design, c):
    mos, rc, t, v = c
    s = open(BASES[design]).read()
    lib = re.search(r"^\.lib \S+sky130\.lib\.spice tt\s*$", s, re.M)
    assert lib, "no tt .lib line"
    s = s[:lib.start()] + corner_block(mos, rc, t) + s[lib.end():]
    # every 1.8 V source (per-cell supplies, the logic tie) -> the corner's VDD
    s, n = re.subn(r"^(V\S+ \S+ 0) 1\.8\s*$", rf"\g<1> {v}", s, flags=re.M)
    assert n > 5, n
    # cold start: keep only the precharge's POR .ic
    s = re.sub(r"^\.ic .*$", ".ic v(x2_x20.nrc)=0", s, flags=re.M)
    s = re.sub(r"tran 20p \d+n", f"tran 20p {TSTOP}n", s)
    s = re.sub(r"from=\d+n to=\d+n", f"from={TSTOP - 400}n to={TSTOP}n", s)
    s = re.sub(r"td=\d+n", f"td={TSTOP - 400}n", s)
    # outputs named per corner
    s = re.sub(r"write \S+_chain\.raw", f"write {tag(c)}_chain.raw", s)
    s = re.sub(r"wrdata \S+\.dat", f"wrdata {tag(c)}.dat", s)
    for prbs in ("e2e_prbs3u.inc",):
        s = s.replace(prbs, "e2e_prbs6u.inc")
    assert f"{tag(c)}.dat" in s and f"{tag(c)}_chain.raw" in s
    return f"* SUITE {design} {tag(c)}: cold start, {TSTOP} ns\n" + s


if __name__ == "__main__":
    for d in sys.argv[1:]:
        os.makedirs(os.path.join(HERE, d), exist_ok=True)
        for c in CORNERS:
            with open(os.path.join(HERE, d, f"{tag(c)}.spice"), "w") as fh:
                fh.write(deck(d, c))
        print(f"{d}: {len(CORNERS)} decks")
