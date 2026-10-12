#!/usr/bin/env python3
"""Summarise a C3 closed-loop run next to the frozen design's P0 run.

    ./collect_cml.py [variant]        # default: dai

Reads results/C3_chain_<variant>.log (this experiment) and
../power/results/P0_chain.log (the frozen design, same stimulus and window).
Pure stdlib.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
VDD = 1.8


def load(log, deck):
    t = open(log).read()
    if "exit rc=0" not in t:
        sys.exit(f"{log}: run did not finish cleanly")
    m = {}
    for k, v in re.findall(r"^(\S+)\s+=\s+(\S+)", t, re.M):
        try:
            m[k.lower()] = float(v)
        except ValueError:
            pass
    src = re.findall(r"^\* SRC (\S+) (.+)$", open(deck).read(), re.M)
    return m, src


# (row name, test on the frozen label, test on the CML label)
ROWS = [
    ("CTLE", lambda l: l.endswith("CTLE"), lambda l: l.endswith("CTLE")),
    ("PD latches", lambda l: "d_latch" in l,
     lambda l: "cml_latch" in l),
    ("PD XORs", lambda l: "robs_xor" in l, lambda l: "cml_xor" in l),
    ("PD -> charge pump converters (up/down)", lambda l: False,
     lambda l: "cml_pd" in l and "cml2cmos" in l),
    ("Ring core (5 stages)", lambda l: "ring_inverter" in l,
     lambda l: "ring_inverter" in l),
    ("Clock buffer diff_amp_inv", lambda l: "diff_amp_inv" in l,
     lambda l: "diff_amp_inv" in l),
    ("Recovered-clock drivers (rclk+/rclk-)",
     lambda l: "inverter_buffer" in l or "single_inverter" in l,
     lambda l: "cml2cmos" in l and "cml_pd" not in l),
    ("Output inverter_chain x2", lambda l: "inverter_chain" in l,
     lambda l: "inverter_chain" in l),
    ("Charge pump + bias gen + loop filter + precharge",
     lambda l: any(k in l for k in ("charge_pump", "bias_gen", "loop_filter",
                                    "vctrl_precharge")),
     lambda l: any(k in l for k in ("charge_pump", "bias_gen", "loop_filter",
                                    "vctrl_precharge"))),
]


def grouped(m, src, which):
    cur = {s: -m[s] * 1e6 for s, _ in src}  # uA
    out, used = [], set()
    for name, tf, tc in ROWS:
        test = tf if which == 0 else tc
        mem = [s for s, lab in src if s not in used and test(lab)]
        used.update(mem)
        out.append(sum(cur[s] for s in mem))
    left = [lab for s, lab in src if s not in used]
    assert not left, f"ungrouped: {left}"
    return out, sum(cur.values())


def main():
    variant = sys.argv[1] if len(sys.argv) > 1 else "dai"
    mc, sc = load(os.path.join(HERE, "results", f"C3_chain_{variant}.log"),
                  os.path.join(HERE, "decks", f"C3_chain_{variant}.spice"))
    pw = os.path.join(HERE, "..", "power")
    mf, sf = load(os.path.join(pw, "results", "P0_chain.log"),
                  os.path.join(pw, "decks", "P0_chain.spice"))
    gf, tf = grouped(mf, sf, 0)
    gc, tc = grouped(mc, sc, 1)
    deck = open(os.path.join(HERE, "decks", f"C3_chain_{variant}.spice")).read()
    vtail = re.search(r"vtail=(\S+)\)", deck).group(1)
    print(f"## C3 ({variant}, vtail = {vtail} V) vs the frozen design (P0)\n")
    for lab, m in (("frozen", mf), ("CML", mc)):
        f = m.get("f_mhz")
        print(f"- {lab}: recovered clock {f:.2f} MHz, vctrl {m['vctrl_a']:.4f} -> "
              f"{m['vctrl_b']:.4f} V, ripple {m['vctrl_pp'] * 1e3:.1f} mV pp"
              if f else f"- {lab}: **no clock measured in the window**")
    if "up_duty" in mc:
        print(f"- CML up / down duty: {mc['up_duty'] / VDD:.3f} / {mc['dn_duty'] / VDD:.3f}")
    print(f"- vtail source current: {-mc.get('vtailcur', 0) * 1e6:.2f} uA\n")
    print("| block | frozen (uA) | CML (uA) | change (uA) |")
    print("|---|---|---|---|")
    for (name, _, _), a, b in zip(ROWS, gf, gc):
        print(f"| {name} | {a:.1f} | {b:.1f} | {b - a:+.1f} |")
    print(f"| **total** | **{tf:.1f}** | **{tc:.1f}** | **{tc - tf:+.1f}** |")
    print(f"\n**{tf * VDD / 1e3:.2f} mW -> {tc * VDD / 1e3:.2f} mW "
          f"({100 * (tc - tf) / tf:+.0f} %)**")


if __name__ == "__main__":
    main()
