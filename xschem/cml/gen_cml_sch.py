#!/usr/bin/env python3
"""Generate the xschem schematics of the low-power CML receiver from its verified netlists.

    cd xschem/cml && ./gen_cml_sch.py [A|B|AB]     (default AB: both options)

1. Assembles reference.spice: every new subcircuit, taken verbatim from the
   .inc files the simulations in xschem/tuning/vw/ used (so the schematics
   cannot drift from what was simulated), plus the scaled loop filter and the
   CDR / macro tops for both design options:
     ctle_cdr_rx_cml     pump biased by cp_bias          (option A)
     ctle_cdr_rx_cml_bg  pump biased by tiny_pll_bias_gen (option B)
2. Writes <cell>.sym and <cell>.sch for each new subcircuit. Devices are the
   PDK symbols; every device and instance pin gets a net label (lab_pin) at
   the pin's exact coordinate, so there are no wires to get wrong; ports are
   ipin/opin/iopin. Placement is a plain grid: these are machine-generated
   and meant to be read as netlists, not as drawings.
Frozen cells (CTLE, ring_inverter, tiny_pll_*, vctrl_precharge,
inverter_chain) are instantiated through their existing symbols in ../ and are
not modified. verify.sh netlists the result with xschem and compares it with
reference.spice in netgen. Pure stdlib (../../CLAUDE.md).
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
XS = os.path.dirname(HERE)
TUN = os.path.join(XS, "tuning")
PDKX = "/home/ttuser/pdk/sky130A/libs.tech/xschem"

SOURCES = [  # (file, subckts taken from it)
    (os.path.join(TUN, "cml", ".netlists", "cml_cells.inc"), ["cml_latch", "cml_dff", "cml2cmos"]),
    (os.path.join(TUN, "vw", "cx_cells.inc"), ["cml2cmos_w2", "cx_xor", "cml_pd_cx3w"]),
    (os.path.join(TUN, "vw", "bias", "cml_bias.inc"), ["cml_bias"]),
    (os.path.join(TUN, "vw", "bias", "cml_clkbuf.inc"), ["cml_clkbuf"]),
    (os.path.join(TUN, "vw", "bias", "cp_bias.inc"), ["cp_bias"]),
    (os.path.join(TUN, "vw", "trim", "ring_trim.inc"), ["ring_trim3", "ring_inverter_t"]),
]
FROZEN_SYMS = {"CTLE", "ring_inverter", "tiny_pll_charge_pump", "tiny_pll_bias_gen",
               "vctrl_precharge", "inverter_chain"}
NFET = "nfet_01v8"
PFET = "pfet_01v8"

# The scaled loop filter, flat (vw/frozen_scaled.inc: R 33.2 kohm, C1 291 fF, C2 43.5 fF),
# same ports and same devices as tiny_pll_loop_filter -> _cap1 / _res / _cap2.
LOOP_FILTER = """.subckt cml_loop_filter VGND VNB VPWR VPB vctl
XMC1 VGND cap_plus VGND VNB sky130_fd_pr__nfet_01v8 L=0.6 W=4 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=16 m=16
XR cap_plus vctl VNB sky130_fd_pr__res_xhigh_po_0p35 L=5.7 mult=1 m=1
XMC2 VGND vctl VGND VNB sky130_fd_pr__nfet_01v8 L=2 W=2.94 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
"""

# The five ring stages (ring_inverter_t: the frozen stage with L 23 -> 20 loads)
# and the 3-bit coarse trim (ring_trim3) on each of the ten ring nodes;
# b0n..b2n are active low. See ../tuning/vw/trim/ring_trim.inc.
RING_NODES = ["t7", "t8", "n1", "n2", "n3", "n4", "n5", "n6", "n9", "n10"]
RING_CORE = """.subckt ring_core Vdd Vss vctrl t7 t8 b0n b1n b2n
x1 Vdd Vss t7 n1 t8 n2 vctrl ring_inverter_t
x2 Vdd Vss n1 n4 n2 n3 vctrl ring_inverter_t
x3 Vdd Vss n4 n5 n3 n6 vctrl ring_inverter_t
x5 Vdd Vss n5 n9 n6 n10 vctrl ring_inverter_t
x4 Vdd Vss n9 t7 n10 t8 vctrl ring_inverter_t
""" + "".join(f"xt{i} {n} Vdd Vss b0n b1n b2n ring_trim3\n" for i, n in enumerate(RING_NODES)) + ".ends\n"


def cdr(name, pump_bias):
    bias = ("x8 Vdd Vss bias_n bias_p cp_bias" if pump_bias == "cp_bias"
            else "x8 Vss Vss Vdd Vdd bias_n Vdd Vss bias_p tiny_pll_bias_gen")
    return f""".subckt {name} Vdd Vss vin+ vin- vbias rclk+ rclk- b0n b1n b2n
x6 Vdd Vdd Vss Vss net1 net2 net3 bias_n bias_p tiny_pll_charge_pump
{bias}
x2 Vss Vss Vdd Vdd net1 cml_loop_filter
x1 Vdd Vss net1 t7 t8 b0n b1n b2n ring_core
x9 Vdd Vss ck ckb t7 t8 vbn cml_clkbuf
xref Vdd Vss vbn cml_bias
x3 Vdd Vss net3 net2 ck ckb vin+ vin- vbn cml_pd_cx3w
x11 rclk+ ck ckb Vdd Vss vbn cml2cmos
x12 rclk- ckb ck Vdd Vss vbn cml2cmos
x20 Vdd Vss net1 vctrl_precharge
.ends
"""


def top(name, cdr_name):
    return f""".subckt {name} vinp vinm vbias clkout_p clkout_n VDPWR VGND trim0n trim1n trim2n
x1 eq_p eq_m vinp vinm VDPWR VGND vbias CTLE
x2 VDPWR VGND eq_p eq_m vbias rclk_p rclk_m trim0n trim1n trim2n {cdr_name}
x3 VDPWR VGND rclk_p clkout_p inverter_chain
x4 VDPWR VGND rclk_m clkout_n inverter_chain
.ends
"""


def subckts(text):
    out, cur = {}, None
    for line in text.splitlines():
        s = line.strip()
        if s.lower().startswith(".subckt"):
            cur = s.split()[1]
            out[cur] = [s]
        elif cur is not None:
            out[cur].append(s)
            if s.lower().startswith(".ends"):
                cur = None
    return out


def build_reference(opts):
    parts = ["* reference.spice -- GENERATED by gen_cml_sch.py from the simulated .inc files; do not edit\n"]
    committed = os.path.join(HERE, "reference.spice")
    for path, names in SOURCES:
        if not os.path.exists(path):
            # a fresh clone: ../tuning/cml/.netlists is gitignored (regenerated by
            # ../tuning/cml/gen_cml.py); take the cells from the committed reference
            path = committed
        sc = subckts(open(path).read())
        for n in names:
            body = [l for l in sc[n] if l and not l.startswith("*")]
            parts.append("\n".join(body) + "\n")
    parts += [LOOP_FILTER, RING_CORE]
    if "A" in opts:
        parts += [cdr("CDR_cml", "cp_bias"), top("ctle_cdr_rx_cml", "CDR_cml")]
    if "B" in opts:
        parts += [cdr("CDR_cml_bg", "bias_gen"), top("ctle_cdr_rx_cml_bg", "CDR_cml_bg")]
    text = "\n".join(parts)
    with open(os.path.join(HERE, "reference.spice"), "w") as fh:
        fh.write(text)
    return subckts(text)


def parse_sym(path):
    """pin name -> (x, y) and pin order, from a .sym file's 'B 5' pin boxes."""
    pins, order = {}, []
    for line in open(path):
        m = re.match(r"B 5 (\S+) (\S+) (\S+) (\S+) \{name=([^ }]+)", line)
        if m:
            x = (float(m.group(1)) + float(m.group(3))) / 2
            y = (float(m.group(2)) + float(m.group(4))) / 2
            pins[m.group(5)] = (x, y)
            order.append(m.group(5))
    return pins, order


def split_line(line):
    """whitespace split that keeps '...' and {...} parameter expressions whole"""
    out, cur, q = [], "", None
    for ch in line:
        if q:
            cur += ch
            if ch == q:
                q = None
        elif ch in "'{":
            q = "'" if ch == "'" else "}"
            cur += ch
        elif ch.isspace():
            if cur:
                out.append(cur)
                cur = ""
        else:
            cur += ch
    if cur:
        out.append(cur)
    return out


def params(tokens):
    d = {}
    for t in tokens:
        k, v = t.split("=", 1)
        d[k] = v
    return d


def attr(k, v):
    v = v.strip()
    if v.startswith("{") and v.endswith("}"):
        v = "'" + v[1:-1] + "'"
    return f'{k}="{v}"' if (" " in v or "'" in v) else f"{k}={v}"


def write_sym(name, ports):
    """box symbol, ports down the left (inputs) -- all on the left, 20 apart, in port order."""
    h = 20 * len(ports) + 20
    lines = ["v {xschem version=3.4.5 file_version=1.2}",
             "G {type=subcircuit",
             'format="@name @pinlist @symname"',
             'template="name=x1"', "}", "V {}", "S {}", "E {}",
             f"P 4 5 -120 -20 120 -20 120 {h - 20} -120 {h - 20} -120 -20 {{}}",
             f"T {{@symname}} -100 {h - 15} 0 0 0.3 0.3 {{}}",
             f"T {{@name}} 100 -40 0 1 0.2 0.2 {{}}"]
    for i, p in enumerate(ports):
        y = 20 * i
        lines += [f"B 5 -142.5 {y - 2.5} -137.5 {y + 2.5} {{name={p} dir=inout}}",
                  f"L 7 -140 {y} -120 {y} {{}}",
                  f"T {{{p}}} -115 {y - 6} 0 0 0.15 0.15 {{}}"]
    with open(os.path.join(HERE, f"{name}.sym"), "w") as fh:
        fh.write("\n".join(lines) + "\n")
    return {p: (-140.0, 20.0 * i) for i, p in enumerate(ports)}


class Sch:
    def __init__(self):
        self.lines = ["v {xschem version=3.4.5 file_version=1.2}", "G {}", "K {}", "V {}", "S {}", "E {}"]
        self.nlab = 0

    def label(self, x, y, net):
        self.nlab += 1
        self.lines.append(f"C {{devices/lab_pin.sym}} {x:g} {y:g} 0 0 {{name=l{self.nlab} sig_type=std_logic lab={net}}}")

    def comp(self, sym, x, y, attrs):
        self.lines.append(f"C {{{sym}}} {x:g} {y:g} 0 0 {{{chr(10).join(attrs)}}}")


def write_sch(name, body, cellpins):
    hdr = body[0].split()
    ports = hdr[2:]
    sch = Sch()
    for i, p in enumerate(ports):
        sch.comp("devices/iopin.sym", -400, 40 * i, [f"name=p{i + 1} lab={p}"])
    col = 0
    for k, line in enumerate(l for l in body[1:] if l and not l.lower().startswith(".ends")):
        tok = split_line(line)
        inst = tok[0]
        x, y = 200 + 260 * (col % 6), 200 * (col // 6)
        col += 1
        model = next(t for t in tok[1:] if "=" not in t and (t.startswith("sky130") or t in cellpins or t in FROZEN_SYMS))
        mi = tok.index(model)
        nodes, prm = tok[1:mi], params(tok[mi + 1:])
        if model.startswith("sky130_fd_pr__nfet") or model.startswith("sky130_fd_pr__pfet"):
            m = model.replace("sky130_fd_pr__", "")
            sym = f"sky130_fd_pr/{m}.sym"
            pins, _ = parse_sym(os.path.join(PDKX, sym))
            for pn, net in zip(("D", "G", "S", "B"), nodes):
                sch.label(x + pins[pn][0], y + pins[pn][1], net)
            mult = prm.get("mult", prm.get("m", "1"))
            a = [f"name={inst[1:] if inst[0] in 'Xx' else inst}"]
            for kk in ("L", "W", "nf"):
                a.append(attr(kk, prm.get(kk, "1")))
            a.append(f"mult={mult}")
            for kk in ("ad", "as", "pd", "ps", "nrd", "nrs", "sa", "sb", "sd"):
                if kk in prm:
                    a.append(attr(kk, prm[kk]))
            a += [f"model={m}", "spiceprefix=X"]
            sch.comp(sym, x, y, a)
        elif model.startswith("sky130_fd_pr__res"):
            m = model.replace("sky130_fd_pr__", "")
            sym = f"sky130_fd_pr/{m}.sym"
            pins, order = parse_sym(os.path.join(PDKX, sym))
            for pn, net in zip(order, nodes):          # netlist order = symbol pin order
                sch.label(x + pins[pn][0], y + pins[pn][1], net)
            a = [f"name={inst[1:]}", f"L={prm['L']}"] + ([f"W={prm['W']}"] if "W" in prm else [])
            a += [f"model={m}", "spiceprefix=X", f"mult={prm.get('mult', '1')}"]
            sch.comp(sym, x, y, a)
        elif model == "sky130_fd_sc_hd__xor2_1":
            sym = "sky130_stdcells/xor2_1.sym"
            pins, _ = parse_sym(os.path.join(PDKX, sym))
            a_, b_, vgnd, vnb, vpb, vpwr, xo = nodes
            for pn, net in (("A", a_), ("B", b_), ("X", xo)):
                sch.label(x + pins[pn][0], y + pins[pn][1], net)
            sch.comp(sym, x, y, [f"name={inst}", f"VGND={vgnd}", f"VNB={vnb}", f"VPB={vpb}",
                                 f"VPWR={vpwr}", "prefix=sky130_fd_sc_hd__"])
        else:  # subcircuit instance: one of ours, or a frozen cell's symbol in ../
            sym = f"cml/{model}.sym" if model in cellpins else f"{model}.sym"
            if model in cellpins:
                pins, order = cellpins[model], list(cellpins[model])
            else:
                pins, order = parse_sym(os.path.join(XS, f"{model}.sym"))
                sub = SUBPORTS[model]
                order = sub
            for pn, net in zip(order, nodes):
                sch.label(x + pins[pn][0], y + pins[pn][1], net)
            sch.comp(sym, x, y, [f"name={inst}"])
    with open(os.path.join(HERE, f"{name}.sch"), "w") as fh:
        fh.write("\n".join(sch.lines) + "\n")


def frozen_ports():
    """port order of the frozen cells, from their own symbols' pin order."""
    return {n: parse_sym(os.path.join(XS, f"{n}.sym"))[1] for n in FROZEN_SYMS}


SUBPORTS = {}

if __name__ == "__main__":
    import sys
    opts = (sys.argv[1] if len(sys.argv) > 1 else "AB").upper()
    ref = build_reference(opts)
    SUBPORTS.update(frozen_ports())
    order = ["cml_latch", "cml_dff", "cml2cmos", "cml2cmos_w2", "cx_xor", "cml_pd_cx3w", "cml_bias",
             "cml_clkbuf", "cml_loop_filter", "ring_trim3", "ring_inverter_t", "ring_core"]
    if "A" in opts:
        order += ["cp_bias", "CDR_cml", "ctle_cdr_rx_cml"]
    if "B" in opts:
        order += ["CDR_cml_bg", "ctle_cdr_rx_cml_bg"]
    cellpins = {}
    for n in order:
        cellpins[n] = write_sym(n, ref[n][0].split()[2:])
    for n in order:
        write_sch(n, ref[n], cellpins)
    # LVS wrapper: one instance of each macro option, so xschem emits a
    # .subckt for every cell (as ../ctle_cdr_rx_lvs.sch does for the frozen design)
    w = Sch()
    tops = [(c, p) for c, p in (("ctle_cdr_rx_cml", "a_"), ("ctle_cdr_rx_cml_bg", "b_")) if c in order]
    for k, (cell, pre) in enumerate(tops):
        x, y = 0, 400 * k
        for p, (px, py) in cellpins[cell].items():
            w.label(x + px, y + py, pre + p)
        w.comp(f"cml/{cell}.sym", x, y, [f"name=x{k + 1}"])
    with open(os.path.join(HERE, "cml_lvs.sch"), "w") as fh:
        fh.write("\n".join(w.lines) + "\n")
    with open(os.path.join(HERE, "cells.txt"), "w") as fh:
        fh.write("\n".join(order) + "\n")
    print(f"wrote reference.spice, cml_lvs.sch and {len(order)} cells: {' '.join(order)}")
