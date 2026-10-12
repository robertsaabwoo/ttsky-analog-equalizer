#!/usr/bin/env python3
"""CML cells for the all-CML phase-detector experiment (sandbox only).

The frozen design converts to CMOS inside every latch (two inverters per
latch), which forces each latch core to swing ~1.2 V. This experiment keeps
everything between the ring and the charge pump in CML at a ~0.4 V swing, and
converts to CMOS only where a CMOS signal is genuinely needed: `up` and `down`
into the (taped-out, unchanged) charge pump, and the recovered clock for the
output pins. See CML.md.

    cells(params) -> SPICE text defining:
      cml_latch      q qb d db VDD VSS ck ckb vbias     (transparent while ck > ckb)
      cml_latch_ls   same, with a shared resistor from VDD that drops the output
                     common mode -- used where the output drives the LOWER pair
                     of a CML XOR, which needs a lower input CM than the upper
      cml_dff        Q Qb D Db VDD VSS ck ckb vbias     (master on ckb, slave on ck)
      cml_dff_ls     same, slave is cml_latch_ls
      cml_xor        out outb a ab b bb VDD VSS vbias    (out = a XOR b; b is the
                     lower pair and needs the lower CM)
      cml2cmos       out inp inm VDD VSS vbias           (out = inp > inm, CMOS)
      cml_pd         VDD VSS down up ck ckb d db vbias   (Alexander PD, same
                     wiring and same up/down meaning as alexander_phase_detector)

All sizes come from the params dict so gen_cml.py can sweep them.
"""

DEFAULT = dict(
    # latch: load resistor length (res_high_po_0p69, ~0.55 kohm/um incl.
    # contacts), data/regen pair W, clock pair W, tail W/L
    lat_Lr=14, lat_Wd=2, lat_Wc=2, lat_Wt=3, lat_Lt=0.5,
    # extra series resistor for the level-shifted latch
    lat_Lcm=15,
    # XOR
    xor_Lr=14, xor_Wa=2, xor_Wb=2, xor_Wt=3, xor_Lt=0.5,
    # CML -> CMOS: NMOS pair W, PMOS mirror W, tail W/L, inverter scale
    c2c_Wp=2, c2c_Wm=1, c2c_Wt=1, c2c_Lt=0.5, c2c_inv=1,
)

RES = "sky130_fd_pr__res_high_po_0p69"


def mos(name, d, g, s, b, w, l=0.15, kind="n"):
    model = f"sky130_fd_pr__{kind}fet_01v8"
    a = f"{w}*0.29"
    p = f"2*({w}+0.29)"
    return (f"X{name} {d} {g} {s} {b} {model} L={l} W={w} nf=1 "
            f"ad={{{a}}} as={{{a}}} pd={{{p}}} ps={{{p}}} nrd=0 nrs=0 sa=0 sb=0 sd=0")


def latch(name, p, ls):
    top = "top" if ls else "VDD"
    out = [f".subckt {name} q qb d db VDD VSS ck ckb vbias"]
    # q follows d: d high pulls qb low
    out += [
        mos("Md", "qb", "d", "s1", "VSS", p["lat_Wd"]),
        mos("Mdb", "q", "db", "s1", "VSS", p["lat_Wd"]),
        mos("Mr1", "q", "qb", "s2", "VSS", p["lat_Wd"]),
        mos("Mr2", "qb", "q", "s2", "VSS", p["lat_Wd"]),
        mos("Mc", "s1", "ck", "tail", "VSS", p["lat_Wc"]),
        mos("Mcb", "s2", "ckb", "tail", "VSS", p["lat_Wc"]),
        mos("Mt", "tail", "vbias", "VSS", "VSS", p["lat_Wt"], p["lat_Lt"]),
        f"XR1 q {top} VSS {RES} L={p['lat_Lr']}",
        f"XR2 qb {top} VSS {RES} L={p['lat_Lr']}",
    ]
    if ls:
        out.append(f"XRcm top VDD VSS {RES} L={p['lat_Lcm']}")
    out.append(".ends")
    return out


def cells(p=None, suffix=""):
    """suffix renames every subckt (name -> name+suffix), so several sizings
    can coexist in one netlist."""
    p = {**DEFAULT, **(p or {})}
    L = []
    L += latch("cml_latch", p, False)
    L += latch("cml_latch_ls", p, True)
    for name, slave in (("cml_dff", "cml_latch"), ("cml_dff_ls", "cml_latch_ls")):
        L += [f".subckt {name} Q Qb D Db VDD VSS ck ckb vbias",
              # master transparent while ck is LOW, as in d_flip_flop
              "xm m mb D Db VDD VSS ckb ck vbias cml_latch",
              f"xs Q Qb m mb VDD VSS ck ckb vbias {slave}",
              ".ends"]
    # Gilbert XOR. A node is pulled LOW when its pair conducts, so the node
    # that conducts on (a&b)|(ab&bb) -- XNOR -- is the XOR output:
    #   out  low on XNOR  ->  out = a XOR b      (C1 caught the reverse)
    L += [".subckt cml_xor out outb a ab b bb VDD VSS vbias",
          mos("Mb1", "n1", "b", "tail", "VSS", p["xor_Wb"]),
          mos("Mb2", "n2", "bb", "tail", "VSS", p["xor_Wb"]),
          mos("Ma1", "out", "a", "n1", "VSS", p["xor_Wa"]),
          mos("Ma2", "outb", "ab", "n1", "VSS", p["xor_Wa"]),
          mos("Ma3", "outb", "a", "n2", "VSS", p["xor_Wa"]),
          mos("Ma4", "out", "ab", "n2", "VSS", p["xor_Wa"]),
          mos("Mt", "tail", "vbias", "VSS", "VSS", p["xor_Wt"], p["xor_Lt"]),
          f"XR1 out VDD VSS {RES} L={p['xor_Lr']}",
          f"XR2 outb VDD VSS {RES} L={p['xor_Lr']}",
          ".ends"]
    # CML -> CMOS: NMOS pair into a PMOS mirror (y follows inp), then two
    # inverters so out follows inp
    k = p["c2c_inv"]
    L += [".subckt cml2cmos out inp inm VDD VSS vbias",
          mos("M1", "x", "inp", "t", "VSS", p["c2c_Wp"]),
          mos("M2", "y", "inm", "t", "VSS", p["c2c_Wp"]),
          mos("P1", "x", "x", "VDD", "VDD", p["c2c_Wm"], kind="p"),
          mos("P2", "y", "x", "VDD", "VDD", p["c2c_Wm"], kind="p"),
          mos("Mt", "t", "vbias", "VSS", "VSS", p["c2c_Wt"], p["c2c_Lt"]),
          mos("Pi1", "z", "y", "VDD", "VDD", round(1 * k, 3), kind="p"),
          mos("Ni1", "z", "y", "VSS", "VSS", round(0.5 * k, 3)),
          mos("Pi2", "out", "z", "VDD", "VDD", round(2 * k, 3), kind="p"),
          mos("Ni2", "out", "z", "VSS", "VSS", round(1 * k, 3)),
          ".ends"]
    # Alexander PD with the same wiring as alexander_phase_detector:
    #   x5: data sample on ck   (Q5)      x1: edge sample on ckb (Q1)
    #   x2: Q5 delayed one bit  (Q2)      x3: Q1 retimed on ck   (B)
    #   down = Q5 xor B         up = Q2 xor B
    L += [".subckt cml_pd VDD VSS down up ck ckb d db vbias",
          "x5 q5 q5b d db VDD VSS ck ckb vbias cml_dff",
          "x1 q1 q1b d db VDD VSS ckb ck vbias cml_dff",
          "x2 q2 q2b q5 q5b VDD VSS ck ckb vbias cml_dff",
          "x3 b bb q1 q1b VDD VSS ck ckb vbias cml_dff_ls",
          "x6 dn dnb q5 q5b b bb VDD VSS vbias cml_xor",
          "x7 u ub q2 q2b b bb VDD VSS vbias cml_xor",
          "x8 down dn dnb VDD VSS vbias cml2cmos",
          "x9 up u ub VDD VSS vbias cml2cmos",
          ".ends"]
    text = "\n".join(L) + "\n"
    if suffix:
        import re
        names = ["cml_latch_ls", "cml_latch", "cml_dff_ls", "cml_dff", "cml_xor",
                 "cml2cmos", "cml_pd"]
        text = re.sub(r"\b(" + "|".join(names) + r")\b", r"\1" + suffix, text)
    return text


if __name__ == "__main__":
    print(cells())
