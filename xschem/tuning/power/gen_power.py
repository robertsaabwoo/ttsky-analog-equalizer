#!/usr/bin/env python3
"""Generate the power-analysis decks from a FRESH netlist of the real macro.

    ./gen_power.py [--netlist PATH] [--cload 50f] [--tstop 1000n]

Without --netlist, xschem is run on ../../ctle_cdr_rx_lvs.sch first, so the
decks always measure the frozen design, never a hand copy.

ngspice cannot report the current of a subcircuit, only of a voltage source.
So the hierarchy is flattened down to its leaf cells, and every leaf instance
gets its OWN ideal 1.8 V supply source -- an ammeter. Ideal sources at the
same voltage are electrically identical to one shared rail, so this changes
nothing about the circuit; it only makes the current of each cell visible.
Inside d_latch the output inverters are moved onto a second source as well,
so the CML core and the CML->CMOS inverters are reported separately.

Decks written to decks/:
  P0_chain     whole macro, closed loop, PRBS7 through the 500 ohm / 5 pF pad
               model (the C23/C25 conditions), per-cell supply current at lock
  P1_latch     one d_latch, transparent, DC sweep of input differential at
               input CM 0.9 V and 1.3 V: core vs inverter current, transfer
  P2_flop      one d_flip_flop at CTLE-output levels (300 mV diff pp, CM 1.3 V,
               600.6 Mb/s): power split, illegal both-low time, captured bits
  P3_ring      clock generator (ring + diff_amp_inv x2 + buffers) vs vctrl:
               current and frequency, to bound how much P0 depends on where
               vctrl sits inside its ripple

Pure stdlib (numpy is not installed on this VM and must not be).
"""
import argparse
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
XSCHEM_DIR = os.path.normpath(os.path.join(HERE, "..", ".."))
TUNING = os.path.normpath(os.path.join(HERE, ".."))
DECKS = os.path.join(HERE, "decks")
NETDIR = os.path.join(HERE, ".netlists")
PDK = os.environ.get("PDK_ROOT", "/home/ttuser/pdk")
LIB = f".lib {PDK}/sky130A/libs.tech/ngspice/sky130.lib.spice tt"
SCHD = f".include {PDK}/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice"

# Hierarchy levels that are flattened. Everything else is a leaf, and gets its
# own supply source. d_flip_flop is expanded so each of the 8 latches in the
# phase detector is visible on its own.
EXPAND = {"ctle_cdr_rx", "CDR", "ring_oscillator", "alexander_phase_detector",
          "d_flip_flop"}
# Port names that are a positive supply (or an n-well tied to it) on a leaf.
SUPPLY_PORTS = {"VDD", "VPWR", "VPB", "VDPWR"}
GROUND_PORTS = {"VSS", "VGND", "VNB"}


# ---------------------------------------------------------------- netlist ---
def netlist_fresh():
    os.makedirs(NETDIR, exist_ok=True)
    env = dict(os.environ, PDK_ROOT=PDK, PWD=XSCHEM_DIR)
    cmd = ["xschem", "-n", "-s", "-x", "-q", "--rcfile", "xschemrc",
           "-o", NETDIR, "ctle_cdr_rx_lvs.sch"]
    r = subprocess.run(cmd, cwd=XSCHEM_DIR, env=env, capture_output=True,
                       text=True)
    out = r.stdout + r.stderr
    # xschem resolves a missing symbol SILENTLY (CLAUDE.md §3) -- check for it
    if r.returncode != 0 or "not found" in out.lower():
        sys.exit(f"xschem netlisting failed or missed a symbol:\n{out}")
    return os.path.join(NETDIR, "ctle_cdr_rx_lvs.spice")


def parse(path):
    """Return {name: (ports, [instance/device lines])}, continuation joined."""
    lines = []
    for raw in open(path):
        raw = raw.rstrip("\n")
        if raw.startswith("+") and lines:
            lines[-1] += " " + raw[1:].strip()
        else:
            lines.append(raw)
    subs, cur = {}, None
    for ln in lines:
        s = ln.strip()
        if not s or s.startswith("*"):
            continue
        low = s.lower()
        if low.startswith(".subckt"):
            tok = s.split()
            cur = tok[1]
            subs[cur] = (tok[2:], [])
        elif low.startswith(".ends"):
            cur = None
        elif cur is not None:
            subs[cur][1].append(s)
    return subs


def split_inst(line, subs):
    """Instance line -> (name, nets, cell, params) for a subckt instance,
    or None for a primitive device."""
    tok = line.split()
    for i in range(1, len(tok)):
        if tok[i] in subs:
            return tok[0], tok[1:i], tok[i], tok[i + 1:]
    return None


def count_devices(cell, subs, memo={}):
    if cell in memo:
        return memo[cell]
    n = 0
    for ln in subs[cell][1]:
        si = split_inst(ln, subs)
        n += count_devices(si[2], subs) if si else 1
    memo[cell] = n
    return n


def safe(net):
    # '+' in a node name silently vanishes from the rawfile (CLAUDE.md §3)
    return net.replace("+", "p").replace("-", "m")


# ------------------------------------------------------- split d_latch cell ---
def split_latch_subckt(subs):
    """d_latch with its PMOS (= the output inverters' pull-ups) on port VDDI."""
    ports, body = subs["d_latch"]
    out = [".subckt d_latch__split " + " ".join(ports) + " VDDI"]
    npmos = 0
    for ln in body:
        if "pfet" in ln:
            tok = ln.split()
            # Xname d g s b model ... -> move source and bulk to VDDI
            assert tok[3] == "VDD" and tok[4] == "VDD", ln
            tok[3] = tok[4] = "VDDI"
            ln = " ".join(tok)
            npmos += 1
        out.append(ln)
    out.append(".ends")
    assert npmos == 2, f"expected the 2 inverter PMOS in d_latch, got {npmos}"
    return "\n".join(out) + "\n"


# ----------------------------------------------------------------- flatten ---
class Flat:
    def __init__(self, subs):
        self.subs = subs
        self.lines = []      # leaf instance lines
        self.sources = []    # (source name, net, label)
        self.devices = 0

    def walk(self, cell, path, portmap, label):
        ports, body = self.subs[cell]
        for ln in body:
            si = split_inst(ln, self.subs)
            if si is None:
                raise SystemExit(f"primitive device inside expanded cell {cell}: {ln}")
            name, nets, child, params = si
            mapped = [portmap.get(n, safe("_".join(path + [n])) if path else safe(n))
                      for n in nets]
            cpath = path + [name.lower()]
            clabel = f"{label}/{name}:{child}" if label else f"{name}:{child}"
            if child in EXPAND:
                cports = self.subs[child][0]
                self.walk(child, cpath, dict(zip(cports, mapped)), clabel)
                continue
            self.leaf(child, cpath, mapped, params, clabel)

    def leaf(self, cell, path, nets, params, label):
        cports = self.subs[cell][0]
        tag = "_".join(path)
        vdd = f"vdd_{tag}"
        nets = [vdd if p.upper() in SUPPLY_PORTS else n for p, n in zip(cports, nets)]
        self.sources.append((f"V{tag}", vdd, label))
        self.devices += count_devices(cell, self.subs)
        if cell == "d_latch":
            vddi = f"vddi_{tag}"
            self.sources.append((f"V{tag}_i", vddi, label + " [output inverters]"))
            self.lines.append(f"{tag} " + " ".join(nets) + f" {vddi} d_latch__split")
        else:
            self.lines.append(f"{tag} " + " ".join(nets + [cell] + params))


def subckt_text(subs):
    out = []
    for name, (ports, body) in subs.items():
        out.append(f".subckt {name} " + " ".join(ports))
        out.extend(body)
        out.append(".ends")
    return "\n".join(out) + "\n" + split_latch_subckt(subs)


def supply_block(sources, volts="1.8"):
    return "\n".join(f"{s} {net} 0 {volts}" for s, net, _ in sources)


# ------------------------------------------------------------------- decks ---
HEADER = """* GENERATED by gen_power.py -- do not edit; re-run the generator.
* Power analysis of the frozen ctle_cdr_rx macro, tt / 27 C / 1.8 V.
* See ../POWER.md for what each number means.
"""


def deck_chain(subs, cload, tstop):
    f = Flat(subs)
    top = {"vinp": "cinp", "vinm": "cinm", "vbias": "vbias",
           "clkout_p": "clkout_p", "clkout_n": "clkout_n",
           "VDPWR": "vtie", "VGND": "0"}
    f.walk("ctle_cdr_rx", [], top, "")
    t1 = tstop - 400  # ns -- the measurement window is the last 400 ns
    meas = [f"meas tran {s.lower()} avg i({s}) from={t1}n to={tstop}n"
            for s, _, _ in f.sources]
    labels = [f"* SRC {s.lower()} {lab}" for s, _, lab in f.sources]
    save = " ".join(f"i({s})" for s, _, _ in f.sources)
    return f.devices, f"""{HEADER}* P0: whole macro, closed loop, PRBS7 at 600.6 Mb/s, 200 mVpp diff, CM 0.9 V,
* through the TT analog pin model (500 ohm / 5 pF per leg) -- the C23/C25 setup.
* Every leaf cell has its own 1.8 V source; the source -> cell map is below.
* Output pins loaded with cload = {cload} each (an ASSUMPTION: the uo_out load
* is not documented anywhere in the repo; see POWER.md for the scaling).
* Leaf devices instantiated: {f.devices}
{chr(10).join(labels)}
{LIB}
{SCHD}
.include {NETDIR}/subckts.inc
.include {TUNING}/e2e_prbs3u.inc
.options method=gear reltol=0.001 abstol=1e-12
.param vcm=0.9 amp=0.2 rpad=500 cpad=5p
{supply_block(f.sources)}
* VDPWR used as a logic tie (bias_gen en, diff_amp_inv vctrl) -- not a supply
Vtie vtie 0 1.8
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
* .op treats a capacitor as an open, so the precharge one-shot is dead without
* this (NOTES.md §19)
.ic v(x2_x20.nrc)=0
.control
  save {save} i(Vtie) i(Vb) v(x2_net1) v(clkout_p) v(x2_net2) v(x2_net3)
  tran 20p {tstop}n
{chr(10).join('  ' + m for m in meas)}
  meas tran vtie avg i(Vtie) from={t1}n to={tstop}n
  meas tran vb avg i(Vb) from={t1}n to={tstop}n
  meas tran vctrl_a avg v(x2_net1) from={t1}n to={t1 + 200}n
  meas tran vctrl_b avg v(x2_net1) from={t1 + 200}n to={tstop}n
  meas tran vctrl_pp pp v(x2_net1) from={t1}n to={tstop}n
  meas tran e_a when v(clkout_p)=0.9 rise=1 td={t1}n
  meas tran e_b when v(clkout_p)=0.9 rise=201 td={t1}n
  let f_mhz = 200/(e_b-e_a)/1e6
  print f_mhz
* charge-pump activity: CDR net2 = up, net3 = down (for comparison with ../cml)
  meas tran up_duty avg v(x2_net2) from={t1}n to={tstop}n
  meas tran dn_duty avg v(x2_net3) from={t1}n to={tstop}n
* startup: the precharge cell's current while it is seeding vctrl
  meas tran precharge_start avg i(Vx2_x20) from=1n to=120n
.endc
.end
"""


def deck_latch():
    return f"""{HEADER}* P1: one d_latch, transparent (clk+ = 1.8 V), DC sweep of the input
* differential at input CM 0.9 V (the §12a condition) and 1.3 V (mid-range of
* the CTLE output CM, which moves 1.149-1.511 V over PVT, §C22).
* Core (load resistors, pairs, tail) and output inverters on separate sources.
{LIB}
.include {NETDIR}/subckts.inc
VC  vdd  0 1.8
VI  vddi 0 1.8
VB  vb 0 0.9
VCP ckp 0 1.8
VCM ckm 0 0
VCMV cmv 0 0.9
VD  vd 0 0
EP  ip 0 vol='v(cmv) + v(vd)/2'
EM  im 0 vol='v(cmv) - v(vd)/2'
X1 op om ip im vdd 0 ckp ckm vb vddi d_latch__split
.control
set width=250
set height=10000
foreach cm 0.9 1.3
  alter VCMV dc=$cm
  dc VD -0.6 0.6 0.1
  let icore_ua=-i(VC)*1e6
  let iinv_ua=-i(VI)*1e6
  echo "#LATCH CM=$cm"
  print vd v(x1.net1) v(x1.net2) v(op) v(om) icore_ua iinv_ua
end
.endc
.end
"""


def deck_flop(bits):
    ui, tr, a = 1.665e-9, 100e-12, 0.15
    pts = [(0.0, a / 2 * (1 if bits[0] else -1))]
    for i in range(1, len(bits)):
        t = i * ui
        v = a / 2 * (1 if bits[i] else -1)
        pts += [(t, pts[-1][1]), (t + tr, v)]
    pwl = " ".join(f"{t:.4e} {v:.4f}" for t, v in pts)
    tstop = len(bits) * ui
    return f"""{HEADER}* P2: one d_flip_flop built from two d_latch__split, at the levels the phase
* detector actually sees: 300 mV diff pp (the C23 CTLE output), CM 1.3 V,
* 600.6 Mb/s, ideal full-rail clock with the rising edge at mid-bit.
* BITS {' '.join(map(str, bits))}
{LIB}
.include {NETDIR}/subckts.inc
VC  vdd  0 1.8
VI  vddi 0 1.8
VB  vb 0 0.9
VD  vd 0 PWL({pwl})
VCP ckp 0 PULSE(0 1.8 0.7325n 100p 100p 0.7325n 1.665n)
VCM ckm 0 PULSE(1.8 0 0.7325n 100p 100p 0.7325n 1.665n)
EP  ip 0 vol='1.3 + v(vd)'
EM  im 0 vol='1.3 - v(vd)'
* same wiring as d_flip_flop: master transparent while clk+ is low
XM mp mm ip im vdd 0 ckm ckp vb vddi d_latch__split
XS q qn mp mm vdd 0 ckp ckm vb vddi d_latch__split
.control
  save v(ckp) v(q) v(qn) v(mp) v(mm) v(xm.net1) v(xm.net2) i(VC) i(VI)
  tran 5p {tstop * 1e9:.3f}n
  meas tran icore avg i(VC) from=5n to={tstop * 1e9:.3f}n
  meas tran iinv  avg i(VI) from=5n to={tstop * 1e9:.3f}n
  let blm = (v(mp) lt 0.9) * (v(mm) lt 0.9)
  let bls = (v(q) lt 0.9) * (v(qn) lt 0.9)
  meas tran bothlow_master avg blm from=5n to={tstop * 1e9:.3f}n
  meas tran bothlow_slave  avg bls from=5n to={tstop * 1e9:.3f}n
  wrdata P2_flop.dat v(ckp) v(q) v(qn) v(xm.net1) v(xm.net2)
.endc
.end
"""


def deck_ring(subs):
    # the CDR's clock path, flattened: ring (5 stages + its diff_amp_inv),
    # the CDR's diff_amp_inv, inverter_buffer, single_inverter
    f = Flat(subs)
    ports = subs["CDR"][0]
    pm = {p: safe(p) for p in ports}
    pm.update({"Vdd": "vtie", "Vss": "0"})
    keep = []
    for ln in subs["CDR"][1]:
        si = split_inst(ln, subs)
        if si[2] in ("ring_oscillator", "diff_amp_inv", "inverter_buffer",
                     "single_inverter"):
            keep.append(ln)
    saved = subs["CDR"]
    subs["CDR__clk"] = (saved[0], keep)
    f.walk("CDR__clk", [], {**pm, "net1": "vctrl"}, "")
    del subs["CDR__clk"]
    names = [s for s, _, _ in f.sources]
    labels = [f"* SRC {s.lower()} {lab}" for s, _, lab in f.sources]
    meas = "\n".join(f"    meas tran {s.lower()} avg i({s}) from=60n to=100n"
                     for s in names)
    return f"""{HEADER}* P3: clock generator alone vs vctrl (lock point is 0.791-0.799 V, §C23/§C25).
* vctrl is an ideal source here; each point is a fresh 100 ns transient with a
* kick, because an all-symmetric operating point is the ring's metastable state.
{chr(10).join(labels)}
{LIB}
.include {NETDIR}/subckts.inc
{supply_block(f.sources)}
Vtie vtie 0 1.8
Vc  vctrl 0 0.791
Ik  x1_net1 0 PULSE(0 50u 1n 50p 50p 200p 1e3)
{chr(10).join(f.lines)}
.control
  save {' '.join(f'i({s})' for s in names)} v(rclkp)
  foreach vc 0.70 0.75 0.791 0.83 0.87
    alter Vc dc=$vc
    tran 5p 100n
    echo "#RING vctrl=$vc"
{meas}
    meas tran e_a when v(rclkp)=0.9 rise=1 td=60n
    meas tran e_b when v(rclkp)=0.9 rise=21 td=60n
    let f_mhz = 20/(e_b-e_a)/1e6
    print f_mhz
  end
.endc
.end
"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--netlist")
    ap.add_argument("--cload", default="50f")
    ap.add_argument("--tstop", type=int, default=1000, help="P0 length, ns")
    a = ap.parse_args()
    net = a.netlist or netlist_fresh()
    subs = parse(net)
    for need in EXPAND | {"d_latch"}:
        assert need in subs, f"{need} missing from {net}"
    os.makedirs(DECKS, exist_ok=True)
    os.makedirs(NETDIR, exist_ok=True)
    with open(os.path.join(NETDIR, "subckts.inc"), "w") as fh:
        fh.write(subckt_text(subs))
    ndev, chain = deck_chain(subs, a.cload, a.tstop)
    total = count_devices("ctle_cdr_rx", subs)
    # every device of the macro must land in exactly one metered leaf
    assert ndev == total, f"flattening lost devices: {ndev} vs {total}"
    bits = [1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 1,
            1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1]
    for name, text in [("P0_chain", chain), ("P1_latch", deck_latch()),
                       ("P2_flop", deck_flop(bits)), ("P3_ring", deck_ring(subs))]:
        with open(os.path.join(DECKS, name + ".spice"), "w") as fh:
            fh.write(text)
        print(f"wrote decks/{name}.spice")
    print(f"P0 meters {ndev} devices (all of ctle_cdr_rx), cload={a.cload}, "
          f"tstop={a.tstop} ns")


if __name__ == "__main__":
    main()
