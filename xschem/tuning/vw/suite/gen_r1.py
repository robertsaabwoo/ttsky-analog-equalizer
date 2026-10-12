#!/usr/bin/env python3
"""R1: open-loop ring frequency vs vctrl, with the exact closed-loop loading.

    gen_r1.py <design> [...]      -> r1/<design>/<corner>.spice

Takes each suite deck (<design>/<corner>.spice) and keeps everything that loads
the ring (clock buffer, PD latches, converters, output chain) but replaces the
pump, loop filter and precharge with an ideal vctrl source, and the CTLE with DC
inputs. vctrl is stepped with `alter` inside ONE ngspice run per corner
(CLAUDE.md section 1), like pvt/gen_pvt.py::make_t0 (NOTES section 20b).

Why: the closed-loop suite showed acquisition depends on where the precharge
leaves the ring -- below ~645 MHz the bang-bang loop pulls in, above ~655 it
runs away to the top of the range. This bench gives f(vctrl) per corner for
the CML ring and the frozen ring, so the seed voltage can be compared.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VCTRL = [0.70, 0.75, 0.79, 0.85, 0.90, 1.00, 1.10]
# differential ring output per design (as named in the suite decks)
RING = {"cml_full": ("x2_t7", "x2_t8"), "cml_buf": ("x2_t7", "x2_t8"),
        "frozen": ("x2_x1_net7", "x2_x1_net8")}
DROP = ("x1 ", "x2_x6 ", "x2_x2 ", "x2_x20 ")


def deck(design, src):
    s = open(src).read()
    s = s[:s.index(".control")]
    keep = []
    for line in s.splitlines():
        if line.startswith(DROP) or line.startswith(".ic"):
            continue
        keep.append(line)
    a, b = RING[design]
    vdd = re.search(r"^Vtie vtie 0 (\S+)", s, re.M).group(1)
    keep += [
        "* R1: ideal vctrl in place of pump + filter + precharge; CTLE -> DC",
        "Vctl x2_net1 0 0.79",
        "Veqp eq_p 0 1.25",
        "Veqm eq_m 0 1.05",
        f".ic v({a})={vdd} v({b})=0",
        ".control",
        f"  save v({a}) v({b})",
    ]
    for v in VCTRL:
        t = f"v{v:.2f}".replace(".", "p")
        keep += [f"  alter Vctl dc={v}",
                 "  tran 10p 110n uic",
                 f"  meas tran {t}_a when v({a})=v({b}) rise=10",
                 f"  meas tran {t}_b when v({a})=v({b}) rise=40"]
    keep += [".endc", ".end", ""]
    return "\n".join(keep)


if __name__ == "__main__":
    for d in sys.argv[1:]:
        out = os.path.join(HERE, "r1", d)
        os.makedirs(out, exist_ok=True)
        n = 0
        for f in sorted(os.listdir(os.path.join(HERE, d))):
            if f.endswith(".spice"):
                open(os.path.join(out, f), "w").write(deck(d, os.path.join(HERE, d, f)))
                n += 1
        print(f"r1/{d}: {n} decks")
