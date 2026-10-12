#!/usr/bin/env python3
"""B4: the clock buffer at corners -- frozen diff_amp_inv on an ideal vtail vs cml_clkbuf on cml_bias.

    gen_b4.py        # writes B4_<corner>.spice

Per corner, two independent copies of the CML clock side, each: ring_core
(vctrl from an ideal 0.79 V source, kicked to start) -> buffer -> the final PD
(cml_pd_cx3w, fed PRBS7 at CTLE levels) + the two recovered-clock cml2cmos:
  o  diff_amp_inv, tail gate on an ideal vtail = 0.85 V (today's sandbox)
  n  cml_clkbuf (bias/cml_clkbuf.inc) on vbn from cml_bias; PD and converters
     also on vbn (the verified design)
b4_analyze.py reports ring frequency, the clock swing and levels at the PD,
and the buffer's current, per copy. The ring's frequency at a fixed vctrl
moves with the corner (and cannot reach 600 MHz at 125 C, the accepted
limitation of NOTES §20b); this test is about the buffer, not lock.
Pure stdlib (../../../../CLAUDE.md).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VW = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(VW, "..", "pvt"))
sys.path.insert(0, os.path.join(VW, "..", "cml"))
sys.path.insert(0, os.path.join(VW, "..", "power"))
from gen_pvt import corner_block  # noqa: E402
from gen_cml import NETDIR, RING_CORE, prbs7, pwl, UI  # noqa: E402
import gen_power as gp  # noqa: E402

CORNERS = [("tt", 27), ("sf", 27), ("ss", 27), ("sf", 125), ("fs", -40), ("ff", 125)]
NB = 70


def copy(p, buf):
    """one clock side; p = node prefix."""
    bias = "vbn" if buf == "new" else "vbias"
    lines = [f"x{p}r vdd_{p}ring 0 vctrl {p}t7 {p}t8 ring_core",
             f"I{p}k {p}t7 0 PULSE(0 50u 1n 50p 50p 200p 1e3)"]
    if buf == "new":
        lines.append(f"x{p}b vdd_{p}buf 0 {p}ck {p}ckb {p}t7 {p}t8 vbn cml_clkbuf")
    else:
        lines.append(f"x{p}b vdd_{p}buf 0 {p}ck {p}ckb {p}t7 {p}t8 vtail diff_amp_inv")
    lines += [f"x{p}pd vdd_{p}pd 0 {p}dn {p}up {p}ck {p}ckb dp dm {bias} cml_pd_cx3w",
              f"x{p}c1 {p}rp {p}ck {p}ckb vdd 0 {bias} cml2cmos",
              f"x{p}c2 {p}rm {p}ckb {p}ck vdd 0 {bias} cml2cmos",
              f"V{p}ring vdd_{p}ring 0 1.8", f"V{p}buf vdd_{p}buf 0 1.8", f"V{p}pd vdd_{p}pd 0 1.8"]
    return lines


def deck(mos, temp):
    bits = prbs7(NB)
    t0, t1 = 60e-9, NB * UI
    meas = []
    for p in ("o", "n"):
        meas += [f"  meas tran {p}ta when v({p}t7)=v({p}t8) rise=1 td={t0:.3e}",
                 f"  meas tran {p}tb when v({p}t7)=v({p}t8) rise=21 td={t0:.3e}",
                 f"  let {p}f_mhz = 20/({p}tb-{p}ta)/1e6",
                 f"  print {p}f_mhz",
                 f"  let {p}ckd = v({p}ck)-v({p}ckb)",
                 f"  meas tran {p}ck_pp pp {p}ckd from={t0:.3e} to={t1:.4e}",
                 f"  meas tran {p}ck_min min v({p}ck) from={t0:.3e} to={t1:.4e}",
                 f"  meas tran {p}ck_max max v({p}ck) from={t0:.3e} to={t1:.4e}",
                 f"  meas tran {p}rp_pp pp v({p}rp) from={t0:.3e} to={t1:.4e}",
                 f"  meas tran {p}i_buf avg i(V{p}buf) from={t0:.3e} to={t1:.4e}",
                 f"  meas tran {p}i_pd avg i(V{p}pd) from={t0:.3e} to={t1:.4e}"]
    return f"""* B4 ({mos} {temp}C): clock buffer -- o = diff_amp_inv @ vtail 0.85 V, n = cml_clkbuf @ cml_bias
{corner_block(mos, "typ", temp)}
.include {gp.PDK}/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.include {NETDIR}/frozen.inc
.include {NETDIR}/cml_cells.inc
.include {VW}/cx_cells.inc
.include {HERE}/cml_bias.inc
.include {HERE}/cml_clkbuf.inc
{RING_CORE}
.options method=gear reltol=0.001
Vdd vdd 0 1.8
Vb vbias 0 0.9
Vt vtail 0 0.85
Vc vctrl 0 0.79
xref vdd 0 vbn cml_bias
Vd vd 0 PWL({pwl(bits, 0.15)})
Ep dp 0 vol='1.3 + v(vd)'
Em dm 0 vol='1.3 - v(vd)'
{chr(10).join(copy("o", "old") + copy("n", "new"))}
.control
  set width=200
  save v(ot7) v(ot8) v(nt7) v(nt8) v(ock) v(ockb) v(nck) v(nckb) v(orp) v(nrp) i(Vobuf) i(Vnbuf) i(Vopd) i(Vnpd)
  tran 5p {t1:.4e}
{chr(10).join(meas)}
.endc
.end
"""


if __name__ == "__main__":
    for m, t in CORNERS:
        with open(os.path.join(HERE, f"B4_{m}_{t}C.spice"), "w") as fh:
            fh.write(deck(m, t))
    print("wrote " + " ".join(f"B4_{m}_{t}C.spice" for m, t in CORNERS))
