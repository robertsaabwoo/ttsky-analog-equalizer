#!/usr/bin/env python3
"""Generate the all-CML experiment decks (sandbox -- the frozen design is untouched).

    ./gen_cml.py [--set key=value ...] [--netlist PATH]

Decks written to decks/:
  C1_pd     unit test, cheap. (a) one cml_latch, transparent, DC: current and
            swing at input CM 1.3 / 1.6 V. (b) the phase detector's
            characteristic: the CML PD and the ORIGINAL PD side by side, each
            clocked at seven fixed phase offsets against the same PRBS7 at
            CTLE-output levels. The sign of <up> - <down> vs phase must agree
            between the two, or the closed loop would push the wrong way.
See CML.md for the results and the reasoning.
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "power"))
sys.path.insert(0, HERE)
import gen_power as gp  # noqa: E402  (netlisting, parsing, flattening)
from cells import DEFAULT, cells  # noqa: E402

DECKS = os.path.join(HERE, "decks")
NETDIR = os.path.join(HERE, ".netlists")
UI = 1.665e-9
PHASES = [-0.3, -0.1, 0.1, 0.3]
WITH_ORIGINAL = False


def prbs7(n, seed=0x7F):
    s, out = seed, []
    for _ in range(n):
        b = ((s >> 6) ^ (s >> 5)) & 1
        s = ((s << 1) | b) & 0x7F
        out.append(b)
    return out


def pwl(bits, amp, tr=100e-12):
    pts = [(0.0, amp / 2 * (1 if bits[0] else -1))]
    for i in range(1, len(bits)):
        v = amp / 2 * (1 if bits[i] else -1)
        pts += [(i * UI, pts[-1][1]), (i * UI + tr, v)]
    return " ".join(f"{t:.5e} {v:.4f}" for t, v in pts)


def write_netlists(netlist):
    os.makedirs(NETDIR, exist_ok=True)
    subs = gp.parse(netlist)
    with open(os.path.join(NETDIR, "frozen.inc"), "w") as fh:
        fh.write(gp.subckt_text(subs))
    return subs


# --------------------------------------------------------------- topology ---
RING_CORE = """.subckt ring_core Vdd Vss vctrl t7 t8
x1 Vdd Vss t7 n1 t8 n2 vctrl ring_inverter
x2 Vdd Vss n1 n4 n2 n3 vctrl ring_inverter
x3 Vdd Vss n4 n5 n3 n6 vctrl ring_inverter
x5 Vdd Vss n5 n9 n6 n10 vctrl ring_inverter
x4 Vdd Vss n9 t7 n10 t8 vctrl ring_inverter
.ends
"""
# Same five stages and taps as ring_oscillator.sch (t7/t8 = its net7/net8).
# Clock polarity is traced from CDR.sch: the PD's clk+ follows net7 through two
# non-inverting diff_amp_inv stages and inverter_buffer, so ck = t7 here.


def clock_lines(variant):
    if variant == "none":
        return []  # the ring's taps ARE ck/ckb, see ring_taps()
    # the ring's own diff_amp_inv, but with its tail gate on `vtail` instead
    # of VDD (vo- follows vin- = t7, so ck = vo-)
    return ["x9 Vdd Vss ck ckb t7 t8 vtail diff_amp_inv"]


def ring_taps(variant):
    """No buffer: the PD is clocked straight off the ring taps."""
    return "ck ckb" if variant == "none" else "t7 t8"


def cdr_cml(variant):
    body = [f".subckt CDR_cml_{variant} Vdd Vss vin+ vin- vbias rclk+ rclk- vtail",
            "x6 Vdd Vdd Vss Vss net1 net2 net3 bias_n bias_p tiny_pll_charge_pump",
            "x8 Vss Vss Vdd Vdd bias_n Vdd Vss bias_p tiny_pll_bias_gen",
            "x2 Vss Vss Vdd Vdd net1 tiny_pll_loop_filter",
            f"x1 Vdd Vss net1 {ring_taps(variant)} ring_core"]
    body += clock_lines(variant)
    body += ["x3 Vdd Vss net3 net2 ck ckb vin+ vin- vbias cml_pd",
             # recovered clock for the output pins: one converter per phase,
             # so both ring taps are loaded identically
             "x11 rclk+ ck ckb Vdd Vss vbias cml2cmos",
             "x12 rclk- ckb ck Vdd Vss vbias cml2cmos",
             "x20 Vdd Vss net1 vctrl_precharge",
             ".ends"]
    top = [f".subckt top_cml_{variant} vinp vinm vbias clkout_p clkout_n VDPWR VGND vtail",
           "x1 eq_p eq_m vinp vinm VDPWR VGND vbias CTLE",
           f"x2 VDPWR VGND eq_p eq_m vbias rclk_p rclk_m vtail CDR_cml_{variant}",
           "x3 VDPWR VGND rclk_p clkout_p inverter_chain",
           "x4 VDPWR VGND rclk_m clkout_n inverter_chain",
           ".ends"]
    return "\n".join(body + top) + "\n"


def topology_text():
    return RING_CORE + cdr_cml("none") + cdr_cml("dai")


# ------------------------------------------------------------ C2: the ring ---
C2_VCTRL = [0.75, 0.791, 0.83, 0.87, 0.95]
C2_VTAIL = [0.75, 0.8, 0.85, 0.9, 0.95, 1.1, 1.3]


def dump_lines(dump, tp, tn):
    """J1: ASCII dump of the clock at three points in the chain, for j1_analyze.py."""
    if not dump:
        return ""
    return f"""
  let ring = v({tp})-v({tn})
  let buf = v(ck)-v(ckb)
  let rclk = v(rclkp)-0.9
  set filetype=ascii
  write {dump} ring buf rclk
"""


# K1: fine vctrl sweep at the chosen vtail, for the VCO gain at the lock point
K1_VCTRL = [0.770, 0.775, 0.780, 0.785, 0.790, 0.795, 0.800, 0.805, 0.810, 0.820]


def deck_ring(variant, sweep_v=None, sweep_t=None, nbits=70, dump=None):
    """Clock side only, open loop, vctrl from an ideal source. Per point: ring
    frequency, clock swing at the PD, recovered-clock duty, per-block current."""
    if sweep_v is None:
        sweep_v, sweep_t = (C2_VCTRL, [1.8]) if variant == "none" else ([0.791], C2_VTAIL)
    tp, tn = ring_taps(variant).split()
    clk = clock_lines(variant)
    clk = [l.replace(" Vdd Vss ", " vdd_buf 0 ", 1) for l in clk]
    bits = prbs7(nbits)
    t0, t1 = 60e-9, nbits * UI
    blocks = ["ring", "buf", "pd", "clk", "out"]
    loops = []
    for vc in sweep_v:
        for vt in sweep_t:
            loops.append((vc, vt))
    body = "\n".join(
        f"""  alter Vc dc={vc}
  alter Vt dc={vt}
  tran 5p {t1:.4e}
  echo "#RING vctrl={vc} vtail={vt}"
  meas tran ta when v({tp})=v({tn}) rise=1 td={t0:.3e}
  meas tran tb when v({tp})=v({tn}) rise=21 td={t0:.3e}
  let f_mhz = 20/(tb-ta)/1e6
  print f_mhz
  let ckd = v(ck)-v(ckb)
  meas tran ck_pp pp ckd from={t0:.3e} to={t1:.4e}
  meas tran ck_min min v(ck) from={t0:.3e} to={t1:.4e}
  meas tran ck_max max v(ck) from={t0:.3e} to={t1:.4e}
  meas tran duty avg v(rclkp) from={t0:.3e} to={t1:.4e}
  meas tran out_pp pp v(clkout_p) from={t0:.3e} to={t1:.4e}
""" + "\n".join(f"  meas tran i_{b} avg i(V{b}) from={t0:.3e} to={t1:.4e}" for b in blocks)
        for vc, vt in loops)
    return f"""* GENERATED by gen_cml.py -- do not edit.
* C2 ({variant}): clock side of the CML CDR, open loop, vctrl from an ideal source.
* Load = one cml_pd (fed PRBS7 at CTLE levels), two cml2cmos clock converters,
* two inverter_chain output drivers with 50 fF each.
.lib {gp.PDK}/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include {NETDIR}/frozen.inc
.include {NETDIR}/cml_cells.inc
.include {NETDIR}/cml_top.inc
.options method=gear reltol=0.001
Vring vdd_ring 0 1.8
Vbuf  vdd_buf  0 1.8
Vpd   vdd_pd   0 1.8
Vclk  vdd_clk  0 1.8
Vout  vdd_out  0 1.8
Vb vbias 0 0.9
Vc vctrl 0 0.791
Vt vtail 0 1.8
Vd vd 0 PWL({pwl(bits, 0.15)})
Ep dp 0 vol='1.3 + v(vd)'
Em dm 0 vol='1.3 - v(vd)'
x1 vdd_ring 0 vctrl {ring_taps(variant)} ring_core
* kick: an all-symmetric operating point is the ring's metastable state
Ik {tp} 0 PULSE(0 50u 1n 50p 50p 200p 1e3)
{chr(10).join(clk)}
x3 vdd_pd 0 dn up ck ckb dp dm vbias cml_pd
x11 rclkp ck ckb vdd_clk 0 vbias cml2cmos
x12 rclkm ckb ck vdd_clk 0 vbias cml2cmos
x13 vdd_out 0 rclkp clkout_p inverter_chain
x14 vdd_out 0 rclkm clkout_n inverter_chain
Cp clkout_p 0 50f
Cn clkout_n 0 50f
.control
  set width=250
  save v({tp}) v({tn}) v(ck) v(ckb) v(rclkp) v(clkout_p) {' '.join(f'i(V{b})' for b in blocks)}
{body}{dump_lines(dump, tp, tn)}
.endc
.end
"""


# ------------------------------------------------------ C3: closed loop ---
def deck_chain(subs, variant, vtail, cload="50f", tstop=1000):
    gp.EXPAND.update({f"top_cml_{variant}", f"CDR_cml_{variant}", "ring_core",
                      "cml_pd", "cml_dff", "cml_dff_ls"})
    f = gp.Flat(subs)
    top = {"vinp": "cinp", "vinm": "cinm", "vbias": "vbias",
           "clkout_p": "clkout_p", "clkout_n": "clkout_n",
           "VDPWR": "vtie", "VGND": "0", "vtail": "vtail"}
    f.walk(f"top_cml_{variant}", [], top, "")
    t1 = tstop - 400
    src = f.sources
    meas = [f"meas tran {s.lower()} avg i({s}) from={t1}n to={tstop}n" for s, _, _ in src]
    labels = [f"* SRC {s.lower()} {lab}" for s, _, lab in src]
    return f"""* GENERATED by gen_cml.py -- do not edit.
* C3 ({variant}, vtail={vtail}): the CML CDR, closed loop, same stimulus and
* window as power/P0_chain (PRBS7, 200 mVpp, 500 ohm / 5 pF pad, cload {cload}).
* Every leaf cell has its own supply source.
* Leaf devices instantiated: {f.devices}
{chr(10).join(labels)}
.lib {gp.PDK}/sky130A/libs.tech/ngspice/sky130.lib.spice tt
{gp.SCHD}
.include {NETDIR}/frozen.inc
.include {NETDIR}/cml_cells.inc
.include {NETDIR}/cml_top.inc
.include {gp.TUNING}/e2e_prbs3u.inc
.options method=gear reltol=0.001 abstol=1e-12
.param vcm=0.9 amp=0.2 rpad=500 cpad=5p
{gp.supply_block(src)}
Vtie vtie 0 1.8
Vtail vtail 0 {vtail}
Vb  vbias 0 0.9
Edinp dinp 0 vol='vcm + 0.5*amp*(v(dsrc)-0.5)'
Edinm dinm 0 vol='vcm - 0.5*amp*(v(dsrc)-0.5)'
Rpadp dinp cinp 'rpad'
Cpadp cinp 0    'cpad'
Rpadm dinm cinm 'rpad'
Cpadm cinm 0    'cpad'
Clp clkout_p 0 {cload}
Cln clkout_n 0 {cload}
{chr(10).join(f.lines)}
.ic v(x2_x20.nrc)=0
.control
  save {' '.join(f'i({s})' for s, _, _ in src)} i(Vtie) i(Vtail) v(x2_net1) v(clkout_p) v(x2_net2) v(x2_net3)
  tran 20p {tstop}n
{chr(10).join('  ' + m for m in meas)}
  meas tran vtie avg i(Vtie) from={t1}n to={tstop}n
  meas tran vtailcur avg i(Vtail) from={t1}n to={tstop}n
  meas tran vctrl_a avg v(x2_net1) from={t1}n to={t1 + 200}n
  meas tran vctrl_b avg v(x2_net1) from={t1 + 200}n to={tstop}n
  meas tran vctrl_pp pp v(x2_net1) from={t1}n to={tstop}n
  meas tran e_a when v(clkout_p)=0.9 rise=1 td={t1}n
  meas tran e_b when v(clkout_p)=0.9 rise=201 td={t1}n
  let f_mhz = 200/(e_b-e_a)/1e6
  print f_mhz
  meas tran up_duty avg v(x2_net2) from={t1}n to={tstop}n
  meas tran dn_duty avg v(x2_net3) from={t1}n to={tstop}n
  set filetype=ascii
  wrdata C3_{variant}_vctrl.dat v(x2_net1)
.endc
.end
""", f.devices


def deck_jitter(subs, variant, vtail):
    """C4: the C27 measurement on the CML chain -- 6 us of PRBS7, settling
    proven by three separated vctrl windows, and an ASCII dump of the
    recovered clock plus the CTLE output pair for ../c27_analyze.py."""
    text, ndev = deck_chain(subs, variant, vtail, tstop=6000)
    text = text.replace("e2e_prbs3u.inc", "e2e_prbs6u.inc")
    text = text.replace("* C3 (", "* C4 jitter, C27 method (", 1)
    extra = """  meas tran vctrl_w4 avg v(x2_net1) from=3900n to=4000n
  meas tran vctrl_w5 avg v(x2_net1) from=4900n to=5000n
  meas tran vctrl_w6 avg v(x2_net1) from=5800n to=5900n
  meas tran vctrl_ripp pp v(x2_net1) from=5800n to=5900n
  meas tran e2400 when v(rclk_p)=0.9 rise=2400
  meas tran e3400 when v(rclk_p)=0.9 rise=3400
  let f1000_mhz = 1000/(e3400-e2400)/1e6
  print f1000_mhz
  let rclkp = v(rclk_p)
  let coutp = v(eq_p)
  let coutm = v(eq_m)
  set filetype=ascii
  write C4_chain.raw rclkp coutp coutm
"""
    text = text.replace("  set filetype=ascii\n  wrdata", extra + "  wrdata")
    text = text.replace("v(x2_net2) v(x2_net3)", "v(x2_net2) v(x2_net3) v(rclk_p) v(eq_p) v(eq_m)")
    text = text.replace(f"wrdata C3_{variant}_vctrl.dat", f"wrdata C4_{variant}_vctrl.dat")
    assert "C4_chain.raw" in text and "prbs6u" in text
    return text, ndev


def deck_pd(params, nbits=80):
    bits = prbs7(nbits)
    tstop = nbits * UI
    t1 = 20 * UI
    lines, meas, save = [], [], []
    for k, ph in enumerate(PHASES):
        # clock rising edge (mid-swing crossing) at bit centre + ph*UI
        tr_c, tr_o = 300e-12, 100e-12
        td_c = 0.5 * UI + ph * UI - tr_c / 2
        td_o = 0.5 * UI + ph * UI - tr_o / 2
        pw_c, pw_o = UI / 2 - tr_c, UI / 2 - tr_o
        lines += [
            f"* phase {ph:+.2f} UI",
            # ring-like clock for CML: 0.8 <-> 1.8 V, slow edges
            f"Vck{k}  ck{k}  0 PULSE(0.8 1.8 {td_c:.4e} {tr_c} {tr_c} {pw_c:.4e} {UI})",
            f"Vckb{k} ckb{k} 0 PULSE(1.8 0.8 {td_c:.4e} {tr_c} {tr_c} {pw_c:.4e} {UI})",
            # full-rail CMOS clock for the original PD
            f"Vok{k}  ok{k}  0 PULSE(0 1.8 {td_o:.4e} {tr_o} {tr_o} {pw_o:.4e} {UI})",
            f"Vokb{k} okb{k} 0 PULSE(1.8 0 {td_o:.4e} {tr_o} {tr_o} {pw_o:.4e} {UI})",
            f"Vsn{k} vn{k} 0 1.8",
            f"Vso{k} vo{k} 0 1.8",
            f"xn{k} vn{k} 0 dn{k} up{k} ck{k} ckb{k} dp dm vbias cml_pd",
            # the original PD is NOT a usable reference in this open-loop bench:
            # its edge flop (x1) sits in the latch's both-low state from the
            # operating point and never leaves it (CML.md). Kept for the record.
            f"xo{k} vo{k} 0 od{k} ou{k} ok{k} okb{k} dp dm vbias alexander_phase_detector"
            if WITH_ORIGINAL else "*",
        ]
        for tag, sig in ((f"n{k}", f"up{k}"), (f"n{k}d", f"dn{k}"),
                         (f"o{k}", f"ou{k}"), (f"o{k}d", f"od{k}")):
            meas.append(f"meas tran a_{tag} avg v({sig}) from={t1:.4e} to={tstop:.4e}")
        meas.append(f"meas tran i_n{k} avg i(Vsn{k}) from={t1:.4e} to={tstop:.4e}")
        meas.append(f"meas tran i_o{k} avg i(Vso{k}) from={t1:.4e} to={tstop:.4e}")
        save += [f"v(up{k})", f"v(dn{k})", f"v(ou{k})", f"v(od{k})",
                 f"i(Vsn{k})", f"i(Vso{k})"]
    return f"""* GENERATED by gen_cml.py -- do not edit.
* C1: CML latch DC + phase-detector characteristic, CML vs original, tt/27C/1.8V
* PHASES {' '.join(str(p) for p in PHASES)}
* PARAMS {' '.join(f'{k}={v}' for k, v in params.items())}
.lib {gp.PDK}/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include {NETDIR}/frozen.inc
.include {NETDIR}/cml_cells.inc
.options method=gear reltol=0.001
Vb vbias 0 0.9
* data at CTLE-output levels: 300 mV diff pp, CM 1.3 V
Vd vd 0 PWL({pwl(bits, 0.15)})
Ep dp 0 vol='1.3 + v(vd)'
Em dm 0 vol='1.3 - v(vd)'
* (a) one transparent cml_latch for the DC check
VL vl 0 1.8
VCM cmv 0 1.3
VDF vdf 0 0
ELp lp 0 vol='v(cmv) + v(vdf)/2'
ELm lm 0 vol='v(cmv) - v(vdf)/2'
VLk lk 0 1.8
VLkb lkb 0 0.8
xl lq lqb lp lm vl 0 lk lkb vbias cml_latch
VLs vls 0 1.8
xls sq sqb lp lm vls 0 lk lkb vbias cml_latch_ls
{chr(10).join(lines)}
.control
  set width=250
  set height=10000
  foreach cm 1.3 1.6
    alter VCM dc=$cm
    dc VDF -0.4 0.4 0.1
    let il_ua=-i(VL)*1e6
    let ils_ua=-i(VLs)*1e6
    echo "#LATCH CM=$cm"
    print v(vdf) v(lq) v(lqb) il_ua v(sq) v(sqb) ils_ua
  end
  save {' '.join(save)}
  tran 5p {tstop:.4e}
{chr(10).join('  ' + m for m in meas)}
.endc
.end
"""

SIZE_WT = [2, 3, 4, 5, 6]


def deck_size(params):
    """C0: tail-width sweep for the latch / level-shifted latch / XOR, DC only."""
    inst = []
    for w in SIZE_WT:
        t = f"_w{w}"
        inst += [
            f"Vl{t} vl{t} 0 1.8",
            f"xl{t} lq{t} lqb{t} ap am vl{t} 0 ckh ckl vbias cml_latch{t}",
            f"Vs{t} vs{t} 0 1.8",
            f"xs{t} sq{t} sqb{t} ap am vs{t} 0 ckh ckl vbias cml_latch_ls{t}",
            f"Vx{t} vx{t} 0 1.8",
            # XOR: a from a plain latch (CM ~1.6), b from a level-shifted one
            f"xx{t} xo{t} xob{t} ap am bp bm vx{t} 0 vbias cml_xor{t}",
        ]
    prints = " ".join(f"v(lq{t}) v(lqb{t}) v(sq{t}) v(sqb{t}) v(xo{t}) v(xob{t}) "
                      f"i(Vl{t}) i(Vs{t}) i(Vx{t})" for t in (f"_w{w}" for w in SIZE_WT))
    return f"""* GENERATED by gen_cml.py -- do not edit.
* C0: DC sizing of the CML tails. Inputs fully switched (+-0.2 V per leg).
* WT {' '.join(map(str, SIZE_WT))}
.lib {gp.PDK}/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include {NETDIR}/cml_size.inc
Vb vbias 0 0.9
Vckh ckh 0 1.8
Vckl ckl 0 0.8
Vacm acm 0 1.6
Vad ad 0 0.4
Eap ap 0 vol='v(acm) + v(ad)/2'
Eam am 0 vol='v(acm) - v(ad)/2'
Vbcm bcm 0 1.2
Vbd bd 0 0.4
Ebp bp 0 vol='v(bcm) + v(bd)/2'
Ebm bm 0 vol='v(bcm) - v(bd)/2'
{chr(10).join(inst)}
.control
  set width=400
  foreach acm 1.3 1.6
    foreach bd 0.4 -0.4
      alter Vacm dc=$acm
      alter Vbd dc=$bd
      op
      echo "#SIZE acm=$acm bd=$bd"
      print {prints}
    end
  end
.endc
.end
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--netlist")
    ap.add_argument("--set", action="append", default=[], help="cell param key=value")
    ap.add_argument("--variant", default="none", choices=["none", "dai"],
                    help="C3 clock buffer: none, or the ring's diff_amp_inv")
    ap.add_argument("--vtail", type=float, default=1.8,
                    help="C3: tail-gate voltage of that diff_amp_inv")
    a = ap.parse_args()
    params = dict(DEFAULT)
    for kv in a.set:
        k, v = kv.split("=")
        assert k in DEFAULT, f"unknown param {k}"
        params[k] = float(v)
    netlist = a.netlist or gp.netlist_fresh()
    write_netlists(netlist)
    with open(os.path.join(NETDIR, "cml_cells.inc"), "w") as fh:
        fh.write(cells(params))
    with open(os.path.join(NETDIR, "cml_size.inc"), "w") as fh:
        fh.write("".join(cells({**params, "lat_Wt": w, "xor_Wt": w}, f"_w{w}")
                         for w in SIZE_WT))
    os.makedirs(DECKS, exist_ok=True)
    with open(os.path.join(DECKS, "C0_size.spice"), "w") as fh:
        fh.write(deck_size(params))
    with open(os.path.join(DECKS, "C1_pd.spice"), "w") as fh:
        fh.write(deck_pd(params))
    with open(os.path.join(NETDIR, "cml_top.inc"), "w") as fh:
        fh.write(topology_text())
    for v in ("none", "dai"):
        with open(os.path.join(DECKS, f"C2_ring_{v}.spice"), "w") as fh:
            fh.write(deck_ring(v))
    with open(os.path.join(DECKS, "K1_kvco_dai.spice"), "w") as fh:
        fh.write(deck_ring("dai", K1_VCTRL, [a.vtail]))
    # J1: open loop, ideal vctrl -- the only thing that can move a clock edge
    # is the data, through the PD's load on the clock lines. "quiet" holds the
    # data constant as the control.
    j1 = deck_ring("dai", [0.79], [a.vtail], nbits=240, dump="J1_prbs.raw")
    with open(os.path.join(DECKS, "J1_clkjit_dai.spice"), "w") as fh:
        fh.write(j1)
    q = j1.replace("J1_prbs.raw", "J1_quiet.raw")
    q = q.replace(q[q.index("Vd vd 0 PWL("):q.index("\n", q.index("Vd vd 0 PWL("))], "Vd vd 0 0.075")
    with open(os.path.join(DECKS, "J1_quiet_dai.spice"), "w") as fh:
        fh.write(q)
    # the closed loop is generated for the variant/vtail chosen from C2
    subs = gp.parse(netlist)
    for path in ("cml_cells.inc", "cml_top.inc"):
        subs.update(gp.parse(os.path.join(NETDIR, path)))
    text, ndev = deck_chain(subs, a.variant, a.vtail)
    with open(os.path.join(DECKS, f"C3_chain_{a.variant}.spice"), "w") as fh:
        fh.write(text)
    jtext, _ = deck_jitter(subs, a.variant, a.vtail)
    with open(os.path.join(DECKS, f"C4_jitter_{a.variant}.spice"), "w") as fh:
        fh.write(jtext)
    print(f"wrote decks: C0_size C1_pd C2_ring_none C2_ring_dai "
          f"C3_chain_{a.variant} (vtail={a.vtail}, {ndev} devices metered)")


if __name__ == "__main__":
    main()
