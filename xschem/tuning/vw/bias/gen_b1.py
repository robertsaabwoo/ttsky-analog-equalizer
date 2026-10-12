#!/usr/bin/env python3
"""B1: which tail-bias scheme keeps the CML swing constant over PVT? DC only.

    gen_b1.py && run_b1.sh && b1_analyze.py

The CML tails are voltage-biased today (vbias pin on the gate), so their
current tracks the NMOS corner and the swing (I x R_load) with it -- the cause
of the CML PD's one-sided behaviour at sf/ff (U8/U9) and of the frozen PD's
death at ss/fs (U4/U6). Three schemes, each a W=3 L=0.5 tail at Vds = 0.4 V:
  A  today: gate on vbias = 0.9 V (ideal pin)
  B  mirror of tiny_pll_bias_gen (beta multiplier, xhigh_po resistor): an
     L=1 W=1 copy of the charge pump's current source, scaled in analysis
  C  res_high_po_0p69 L=28 from VDD into an nfet W=3 L=0.5 diode, mirrored
     1:1 -- I ~ (VDD - Vgs)/R in the SAME resistor material as the loads, so
     the swing I x R_load ~ (VDD - Vgs) x R_load/R_ref should hold.
Swing = tail current x one load resistor (res_high_po_0p69 L=14), each
scheme's current normalised to its own tt/27C/1.8V value x 54 uA (the CML
latch's design current). Corners: MOS tt/ss/ff/sf/fs x R/C typ/hh/ll,
temperature -40..125 C by a DC sweep, VDD 1.62/1.8/1.98.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "pvt"))
sys.path.insert(0, os.path.join(HERE, "..", "..", "cml"))
from gen_pvt import corner_block  # noqa: E402
from gen_cml import NETDIR  # noqa: E402

MOS = ["tt", "ss", "ff", "sf", "fs"]
RC = ["typ", "hh", "ll"]
VDDS = [1.62, 1.8, 1.98]


def deck(mos, rc):
    loops = []
    for v in VDDS:
        loops += [f"  alter Vdd dc={v}",
                  "  dc temp -40 125 82.5",
                  f"  echo \"#VDD {v}\"",
                  "  let ia = -i(Vda)",
                  "  let ib = -i(Vdb)",
                  "  let ic = -i(Vdc)",
                  "  let rl = (v(vdd) - v(rl)) / 10e-6",
                  "  print ia ib ic rl"]
    return f"""* B1 ({mos}, rc={rc}): tail-bias schemes vs PVT (gen_b1.py)
{corner_block(mos, rc, 27)}
.include {NETDIR}/frozen.inc
Vdd vdd 0 1.8
Vb vbias 0 0.9
* A: today's tail, gate on vbias
Vda da 0 0.4
XA da vbias 0 0 sky130_fd_pr__nfet_01v8 W=3 L=0.5
* B: tiny_pll_bias_gen, and a copy of the pump's current source
xbg 0 0 vdd vdd bn vdd 0 bp tiny_pll_bias_gen
Vdb db 0 0.4
XB db bn 0 0 sky130_fd_pr__nfet_01v8 W=1 L=1
* C: res_high_po reference into a diode, mirrored 1:1
XRr gc vdd 0 sky130_fd_pr__res_high_po_0p69 L=28
XD gc gc 0 0 sky130_fd_pr__nfet_01v8 W=3 L=0.5
Vdc dc 0 0.4
XC dc gc 0 0 sky130_fd_pr__nfet_01v8 W=3 L=0.5
* the CML load resistor, measured with 10 uA
XRL rl vdd 0 sky130_fd_pr__res_high_po_0p69 L=14
Il rl 0 10u
.control
  set width=200
{chr(10).join(loops)}
.endc
.end
"""


if __name__ == "__main__":
    for m in MOS:
        for r in RC:
            with open(os.path.join(HERE, f"B1_{m}_{r}.spice"), "w") as fh:
                fh.write(deck(m, r))
    print(f"wrote {len(MOS) * len(RC)} decks")
