#!/usr/bin/env python3
"""
gen_pvt.py -- generate every PVT corner deck for the CDR / precharge tests.

Netlists the schematics with xschem (so the decks can never drift from the
schematics), then stamps each one with a corner / temperature / supply and
writes it to pvt/decks/.  Generates ONLY -- runs nothing.

    ./gen_pvt.py            # generate all tiers
    ./gen_pvt.py --list     # just print what would be generated

Tiers (see README.md for the full rationale and pass criteria):
    T0  ring-oscillator tuning range   ~1 min each   cheap
    T1  precharge cell alone           ~1 min each   cheap
    T2  full CDR loop, bad polarity    ~15-20 min    HEAVY, run sparingly
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TUNE = os.path.dirname(HERE)
XSCHEMRC = os.path.join(os.path.dirname(TUNE), "xschemrc")
PDK_ROOT = os.environ.get("PDK_ROOT", "/home/ttuser/pdk")
NG = f"{PDK_ROOT}/sky130A/libs.tech/ngspice"
DECKS = os.path.join(HERE, "decks")
NETLIST_CACHE = os.path.join(HERE, ".netlists")

# ---------------------------------------------------------------- corner axes
# NOTE: in sky130 the MOS corner and the R/C corner are INDEPENDENT axes.
# .lib ss moves only the transistors; .lib hh/ll move only R and C.  We emit
# the include lines directly so the two can be combined, which the stock .lib
# sections cannot do.  This matters here because the precharge release time is
# an R*C product while the bias level is a MOSFET threshold.
RC_FILES = {
    "typ": "res_typical__cap_typical",
    "hh": "res_high__cap_high",   # slowest POR ramp -> latest release
    "ll": "res_low__cap_low",     # fastest POR ramp -> earliest release
}


def vtag(v):
    """1.8 -> '1p80'.  str(1.80) is '1.8', which silently produced '1p8' and
    made the T1a deck names disagree with T1b/T1c -- --only then matched nothing."""
    return f"{v:.2f}".replace(".", "p")


def corner_block(mos, rc, temp):
    rcf = RC_FILES[rc]
    return "\n".join([
        f"* corner: mos={mos} rc={rc} temp={temp}C",
        ".param mc_mm_switch=0",
        ".param mc_pr_switch=0",
        f'.include "{NG}/corners/{mos}.spice"',
        f'.include "{NG}/r+c/{rcf}.spice"',
        f'.include "{NG}/r+c/{rcf}__lin.spice"',
        f'.include "{NG}/corners/{mos}/specialized_cells.spice"',
        f".temp {temp}",
        "",
    ])


def strip_stock_lib(src):
    """Remove the hard-coded `.lib ... tt` line; we supply our own corner."""
    return re.sub(r"^\.lib\s+\S*sky130\.lib\.spice\s+\w+\s*$", "", src,
                  flags=re.M)


# ------------------------------------------------------------------ netlisting
def xschem_netlist(sch):
    """Netlist <sch>.sch into .netlists/ and return the file's text."""
    os.makedirs(NETLIST_CACHE, exist_ok=True)
    # PWD must be stamped explicitly: subprocess sets the child's real cwd but
    # leaves the inherited PWD pointing at OUR directory, and xschem's Tcl layer
    # trusts PWD when it looks for the design / a project-local xschemrc.  Without
    # this, netlisting silently fails with rc=1 and no diagnostic whenever
    # gen_pvt.py is invoked from anywhere other than tuning/.
    env = dict(os.environ, PDK_ROOT=PDK_ROOT, PWD=TUNE)
    cmd = ["xschem", "-n", "-s", "-x", "-q", "--rcfile", XSCHEMRC,
           "-o", NETLIST_CACHE, f"{sch}.sch"]
    r = subprocess.run(cmd, cwd=TUNE, env=env, capture_output=True, text=True)
    out = os.path.join(NETLIST_CACHE, f"{sch}.spice")
    if not os.path.exists(out):
        sys.exit(f"xschem failed to netlist {sch} (rc={r.returncode})\n"
                 f"  cmd: {' '.join(cmd)}\n  cwd: {TUNE}\n"
                 f"  stdout: {r.stdout}\n  stderr: {r.stderr}")
    return open(out).read()


def as_subckt(src):
    """xschem comments out the .subckt of a top-level schematic; undo that."""
    src = re.sub(r"^\*\*\.subckt", ".subckt", src, flags=re.M)
    src = re.sub(r"^\*\*\.ends", ".ends", src, flags=re.M)
    src = re.sub(r"^\.end\s*$", "", src, flags=re.M)
    src = re.sub(r"^\*\.iopin.*$", "", src, flags=re.M)
    return src


# --------------------------------------------------------------------- T0 deck
# Ring oscillator open-loop: sweep vctrl inside ONE ngspice run via `alter`,
# so the whole f(vctrl) curve for a corner costs a single invocation.
T0_VCTRL = [0.60, 0.65, 0.70, 0.75, 0.79, 0.85, 0.90, 1.00, 1.20, 1.40]


def make_t0(ring_sub, mos, rc, temp, vdd):
    swing = vdd
    body = [
        f"* T0 VCO tuning range  mos={mos} rc={rc} T={temp}C vdd={vdd}",
        corner_block(mos, rc, temp),
        ring_sub,
        f"V3 Vdd 0 {vdd}",
        "V1 Vss 0 0",
        "V5 vctrl 0 0.79",
        "x1 Vdd Vss vctrl vo+ vo- ring_oscillator_tune",
        # A ring started from uic sits exactly on its metastable DC point and
        # never oscillates.  Kick one node so every corner starts identically.
        f".ic v(vo+)={vdd}",
        ".options method=gear reltol=1e-3 abstol=1e-12",
        ".control",
        "  save v(vo+) v(vctrl)",
    ]
    for v in T0_VCTRL:
        tag = f"v{str(v).replace('.', 'p')}"
        body += [
            f"  alter V5 dc={v}",
            "  tran 5p 150n uic",
            # 20 periods between the 10th and 30th rising crossing: skips the
            # startup transient, then averages out any per-cycle asymmetry.
            # 150 ns leaves room for 30 periods even at the slow corners --
            # at 80 ns the slow corners ran out of window and the point
            # vanished from the log entirely, looking like a dead oscillator.
            f"  meas tran {tag}_a WHEN v(vo+)={swing/2:.4f} RISE=10",
            f"  meas tran {tag}_b WHEN v(vo+)={swing/2:.4f} RISE=30",
        ]
    body += [".endc", ".end", ""]
    return "\n".join(body)


# --------------------------------------------------------------------- T1 deck
# Precharge cell alone, driven by a REAL supply ramp with uic and no .ic
# anywhere -- this is the test that proves the cell self-starts.
def make_t1(cell_sub, mos, rc, temp, vdd):
    return "\n".join([
        f"* T1 precharge cell  mos={mos} rc={rc} T={temp}C vdd={vdd}",
        corner_block(mos, rc, temp),
        cell_sub,
        f"V1 VDD 0 PWL(0 0 50n {vdd})",
        "X1 VDD 0 vctl vctrl_precharge_tune",
        "* loop-filter + ring gate load seen by the switch",
        "C2 vctl 0 19f",
        "R1 vctl capp 86k",
        "C1 capp 0 124f",
        "Cring vctl 0 60f",
        ".options method=gear reltol=1e-3 abstol=1e-12",
        ".control",
        "  save v(vctl) v(X1.nbias) v(X1.pre) v(X1.nrc) v(VDD)",
        "  tran 200p 900n uic",
        "  meas tran nb_h    FIND v(X1.nbias) AT=80n",
        "  meas tran vc_h    FIND v(vctl)     AT=80n",
        "  meas tran vc_h2   FIND v(vctl)     AT=120n",
        "  meas tran t_rel   WHEN v(X1.pre)=%.4f FALL=1" % (vdd / 2),
        "  meas tran vc_end  FIND v(vctl)     AT=900n",
        "  meas tran vdd_chk FIND v(VDD)      AT=80n",
        ".endc",
        ".end",
        "",
    ])


# --------------------------------------------------------------------- T2 deck
# Full CDR loop.  Bad power-up polarity (the §16g case that never acquired
# without help) is the one that actually exercises the precharge.
def make_t2(tb, mos, rc, temp, vdd, polarity):
    src = strip_stock_lib(tb)
    half = vdd / 2
    src = src.replace("V3 Vdd GND 1.8", f"V3 Vdd GND {vdd}")
    src = src.replace("V5 net2 GND 0.9", f"V5 net2 GND {half}")
    if polarity == "bad":
        src = src.replace("V2 vin+ GND PULSE(0 1.8 0 10p 10p 1.67n 3.33n)",
                          f"V2 vin+ GND PULSE({vdd} 0 0 10p 10p 1.67n 3.33n)")
        src = src.replace("V4 net1 GND PULSE(1.8 0 0 10p 10p 1.67n 3.33n)",
                          f"V4 net1 GND PULSE(0 {vdd} 0 10p 10p 1.67n 3.33n)")
    else:
        src = src.replace("V2 vin+ GND PULSE(0 1.8 0 10p 10p 1.67n 3.33n)",
                          f"V2 vin+ GND PULSE(0 {vdd} 0 10p 10p 1.67n 3.33n)")
        src = src.replace("V4 net1 GND PULSE(1.8 0 0 10p 10p 1.67n 3.33n)",
                          f"V4 net1 GND PULSE({vdd} 0 0 10p 10p 1.67n 3.33n)")

    ctrl = "\n".join([
        # The ONLY initial condition: the POR cap is discharged at power-up.
        # (.op treats a cap as an open, so nrc would solve to VDD and the
        # one-shot could never fire.  vctrl itself is NOT seeded.)
        ".ic v(x1.x20.nrc)=0",
        ".control",
        "  save v(x1.net1) v(clk+) v(x1.x20.pre) v(x1.x20.nbias)",
        "  tran 20p 1200n",
        "  meas tran t_rel   WHEN v(x1.x20.pre)=%.4f FALL=1" % half,
        "  meas tran h_vctrl AVG v(x1.net1) FROM=60n   TO=110n",
        "  meas tran e_vctrl AVG v(x1.net1) FROM=200n  TO=300n",
        "  meas tran m_vctrl AVG v(x1.net1) FROM=600n  TO=700n",
        "  meas tran l_vctrl AVG v(x1.net1) FROM=1100n TO=1200n",
        "  meas tran l_cp_pp PP  v(clk+)    FROM=1100n TO=1200n",
        "  meas tran nb_end  FIND v(x1.x20.nbias) AT=1200n",
        "  meas tran c600 WHEN v(clk+)=%.4f RISE=600" % half,
        "  meas tran c660 WHEN v(clk+)=%.4f RISE=660" % half,
        ".endc",
        "",
    ])
    old = re.search(r"\.op\n\.control\n.*?\.endc\n", src, re.S)
    if not old:
        sys.exit("T2: could not find the .op/.control block in CDR_tune_tb")
    src = src.replace(old.group(0), ctrl)
    # our corner block replaces the stock .lib line
    src = src.replace("**** begin user architecture code",
                      "**** begin user architecture code\n"
                      + corner_block(mos, rc, temp))
    return src


# ------------------------------------------------------------------- the grids
def grids():
    """Yield (tier, name, mos, rc, temp, vdd, extra)."""
    # ---- T0: is 600 MHz even reachable, and is 0.79 V above the cliff?
    for mos in ("tt", "ss", "ff"):
        for temp in (-40, 27, 125):
            yield ("T0", f"T0_{mos}_typ_{temp}C_{vtag(1.80)}", mos, "typ", temp, 1.80, None)
    for vdd in (1.62, 1.98):
        yield ("T0", f"T0_tt_typ_27C_{vtag(vdd)}", "tt", "typ", 27, vdd, None)

    # ---- T1a: cell over the MOS x T x V box (RC typical)
    for mos in ("tt", "ss", "ff"):
        for temp in (-40, 27, 125):
            for vdd in (1.62, 1.80, 1.98):
                yield ("T1", f"T1_{mos}_typ_{temp}C_{vtag(vdd)}",
                       mos, "typ", temp, vdd, None)
    # ---- T1b: RC extremes -- these are what actually move t_rel
    for mos in ("tt", "ss", "ff"):
        for rc in ("hh", "ll"):
            for temp in (-40, 125):
                yield ("T1", f"T1_{mos}_{rc}_{temp}C_{vtag(1.80)}", mos, rc, temp, 1.80, None)
    # ---- T1c: skew corners (INV_A trip point is a p/n ratio)
    for mos in ("sf", "fs"):
        for temp in (-40, 27, 125):
            yield ("T1", f"T1_{mos}_typ_{temp}C_{vtag(1.80)}", mos, "typ", temp, 1.80, None)

    # ---- T2: the expensive one.  Bad polarity is the case that needs the cell.
    for mos, temp in (("ss", 125), ("ss", -40), ("ff", 125), ("ff", -40)):
        yield ("T2", f"T2_bad_{mos}_typ_{temp}C_{vtag(1.80)}", mos, "typ", temp, 1.80, "bad")
    for vdd in (1.62, 1.98):
        yield ("T2", f"T2_bad_tt_typ_27C_{vtag(vdd)}",
               "tt", "typ", 27, vdd, "bad")
    # one good-polarity regression at the worst-case corner found above
    yield ("T2", f"T2_good_ss_typ_125C_{vtag(1.80)}", "ss", "typ", 125, 1.80, "good")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true", help="print the grid, generate nothing")
    ap.add_argument("--tier", action="append", help="only this tier (repeatable)")
    a = ap.parse_args()

    want = set(a.tier) if a.tier else {"T0", "T1", "T2"}
    grid = [g for g in grids() if g[0] in want]

    if a.list:
        for tier, name, mos, rc, temp, vdd, extra in grid:
            print(f"{tier}  {name}")
        print(f"\n{len(grid)} decks "
              f"(T0={sum(1 for g in grid if g[0]=='T0')}, "
              f"T1={sum(1 for g in grid if g[0]=='T1')}, "
              f"T2={sum(1 for g in grid if g[0]=='T2')})")
        return

    print("netlisting schematics with xschem ...")
    ring = as_subckt(xschem_netlist("ring_oscillator_tune"))
    cell = as_subckt(xschem_netlist("vctrl_precharge_tune"))
    tb = xschem_netlist("CDR_tune_tb")
    # sanity: the precharge must actually be in the loop netlist
    if "vctrl_precharge_tune" not in tb:
        sys.exit("CDR_tune_tb netlist has no vctrl_precharge_tune instance!")

    os.makedirs(DECKS, exist_ok=True)
    for tier, name, mos, rc, temp, vdd, extra in grid:
        if tier == "T0":
            txt = make_t0(ring, mos, rc, temp, vdd)
        elif tier == "T1":
            txt = make_t1(cell, mos, rc, temp, vdd)
        else:
            txt = make_t2(tb, mos, rc, temp, vdd, extra)
        open(os.path.join(DECKS, name + ".spice"), "w").write(txt)
    print(f"wrote {len(grid)} decks to {DECKS}")


if __name__ == "__main__":
    main()
