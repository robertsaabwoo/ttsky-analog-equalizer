#!/usr/bin/env python3
"""B2: charge-pump current over PVT, tiny_pll_bias_gen vs cp_bias. DC only.

    gen_b2.py && run_b2.sh

Two copies of the real tiny_pll_charge_pump per bias source, one forced up and
one forced down, output held at 0.79 V (the lock point); bias from
  a  tiny_pll_bias_gen (today: beta multiplier on xhigh_po)
  b  cp_bias.inc (xhigh_po resistor reference)
plus the scaled loop filter's resistor (xhigh_po_0p35 L=5.7) measured with
10 uA, so Icp x R_filter (the proportional kick) can be compared. Same PVT grid
as B1. Pure stdlib (../../../../CLAUDE.md).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "pvt"))
sys.path.insert(0, os.path.join(HERE, "..", "..", "cml"))
from gen_pvt import corner_block  # noqa: E402
from gen_cml import NETDIR  # noqa: E402
from gen_b1 import MOS, RC, VDDS  # noqa: E402


def deck(mos, rc):
    loops = []
    for v in VDDS:
        loops += [f"  alter Vdd dc={v}", "  alter Vhi dc=" + str(v), "  dc temp -40 125 82.5",
                  f"  echo \"#VDD {v}\"",
                  "  let aup = -i(Vau)", "  let adn = i(Vad)", "  let bup = -i(Vbu)", "  let bdn = i(Vbd)",
                  "  let rf = (v(vdd) - v(rf)) / 10e-6",
                  "  print aup adn bup bdn rf"]
    return f"""* B2 ({mos}, rc={rc}): charge-pump current, bias_gen vs cp_bias (gen_b2.py)
{corner_block(mos, rc, 27)}
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.include {NETDIR}/frozen.inc
.include {HERE}/cp_bias.inc
Vdd vdd 0 1.8
Vhi hi 0 1.8
* a: tiny_pll_bias_gen
xbga 0 0 vdd vdd bna vdd 0 bpa tiny_pll_bias_gen
xcau vdd vdd 0 0 oau hi 0 bna bpa tiny_pll_charge_pump
xcad vdd vdd 0 0 oad 0 hi bna bpa tiny_pll_charge_pump
Vau oau 0 0.79
Vad oad 0 0.79
* b: cp_bias
xbgb vdd 0 bnb bpb cp_bias
xcbu vdd vdd 0 0 obu hi 0 bnb bpb tiny_pll_charge_pump
xcbd vdd vdd 0 0 obd 0 hi bnb bpb tiny_pll_charge_pump
Vbu obu 0 0.79
Vbd obd 0 0.79
* the scaled loop filter's resistor
XRf rf vdd 0 sky130_fd_pr__res_xhigh_po_0p35 L=5.7 mult=1
If rf 0 10u
.control
  set width=200
{chr(10).join(loops)}
.endc
.end
"""


if __name__ == "__main__":
    for m in MOS:
        for r in RC:
            with open(os.path.join(HERE, f"B2_{m}_{r}.spice"), "w") as fh:
                fh.write(deck(m, r))
    print(f"wrote {len(MOS) * len(RC)} decks")
