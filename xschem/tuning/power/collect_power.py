#!/usr/bin/env python3
"""Summarise the power-analysis runs in results/ as Markdown.

    ./collect_power.py            # all decks that have a log
    ./collect_power.py > out.md

Supply currents are reported as positive numbers (current drawn FROM the rail).
Pure stdlib.
"""
import bisect
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(HERE, "results")
DECKS = os.path.join(HERE, "decks")
VDD = 1.8
MEAS = re.compile(r"^(\S+)\s+=\s+(\S+)")


def meas(text):
    out = {}
    for ln in text.splitlines():
        m = MEAS.match(ln)
        if m:
            try:
                out[m.group(1).lower()] = float(m.group(2))
            except ValueError:
                pass
    return out


def read(name):
    p = os.path.join(RES, name + ".log")
    if not os.path.exists(p):
        return None
    t = open(p).read()
    if "exit rc=0" not in t:
        print(f"> **{name}: run did not finish cleanly** -- see results/{name}.log\n")
        return None
    return t


def ua(x):
    return f"{x * 1e6:.1f}"


# Grouping of the P0 leaf cells. Order is the order of the report.
GROUPS = [
    ("CTLE", lambda l: l.endswith("CTLE")),
    ("PD latch cores -- first rank (sample the analog CTLE output)",
     lambda l: re.search(r"/x[51]:d_flip_flop/x1:d_latch$", l)),
    ("PD latch cores -- all other latches (full-rail CMOS inputs)",
     lambda l: "d_latch" in l and "[output" not in l),
    ("PD latch output inverters (CML->CMOS, all 8 latches)",
     lambda l: "[output inverters]" in l),
    ("PD XORs (robs_xor x2)", lambda l: "robs_xor" in l),
    ("Ring oscillator core (5 x ring_inverter)", lambda l: "ring_inverter" in l),
    ("Ring output diff_amp_inv (inside ring_oscillator)",
     lambda l: "ring_oscillator/x6:diff_amp_inv" in l),
    ("CDR diff_amp_inv (x4, makes clkraw)", lambda l: l.endswith("x4:diff_amp_inv")),
    ("inverter_buffer + single_inverter (rclk+/rclk-)",
     lambda l: "inverter_buffer" in l or "single_inverter" in l),
    ("Output inverter_chain x2 (to uo_out, incl. pin load)",
     lambda l: "inverter_chain" in l),
    ("Charge pump", lambda l: "charge_pump" in l),
    ("Bias generator", lambda l: "bias_gen" in l),
    ("vctrl precharge (after release)", lambda l: "vctrl_precharge" in l),
    ("Loop filter (well/bulk leakage only)", lambda l: "loop_filter" in l),
]


def p0():
    t = read("P0_chain")
    if t is None:
        return
    m = meas(t)
    deck = open(os.path.join(DECKS, "P0_chain.spice")).read()
    src = re.findall(r"^\* SRC (\S+) (.+)$", deck, re.M)
    cload = re.search(r"cload = (\S+)", deck).group(1)
    window = re.search(r"avg i\(\S+\) from=(\S+) to=(\S+)", deck).groups()
    cur = {s: -m[s] for s, _ in src}
    total = sum(cur.values())
    print("## P0 -- whole macro, closed loop, at lock\n")
    print(f"tt / 27 C / 1.8 V, PRBS7 at 600.6 Mb/s, 200 mVpp through the "
          f"500 ohm / 5 pF pad model, output pins loaded with {cload} each. "
          f"Averaged over {window[0]}-{window[1]}.\n")
    print(f"- recovered clock in the window: **{m.get('f_mhz', float('nan')):.2f} MHz**")
    print(f"- vctrl: {m['vctrl_a']:.4f} V then {m['vctrl_b']:.4f} V "
          f"(two halves of the window), {m['vctrl_pp'] * 1e3:.1f} mV pp")
    print(f"- **total supply current {ua(total)} uA = {total * VDD * 1e3:.2f} mW**")
    print(f"- vbias pin (ua[2]) draws {ua(-m['vb'])} uA; the VDPWR logic ties draw "
          f"{ua(-m['vtie'])} uA (both excluded from the total above)\n")
    print("| block | instances | current (uA) | power (uW) | share |")
    print("|---|---|---|---|---|")
    used = set()
    for name, test in GROUPS:
        members = [s for s, lab in src if s not in used and test(lab)]
        used.update(members)
        i = sum(cur[s] for s in members)
        print(f"| {name} | {len(members)} | {ua(i)} | {i * VDD * 1e6:.1f} | "
              f"{100 * i / total:.1f} % |")
    left = [s for s, _ in src if s not in used]
    assert not left, f"ungrouped sources: {left}"
    print(f"| **total** | {len(src)} | **{ua(total)}** | "
          f"**{total * VDD * 1e6:.1f}** | 100 % |\n")
    print("<details><summary>every metered cell</summary>\n")
    print("| source | cell | current (uA) |")
    print("|---|---|---|")
    for s, lab in src:
        print(f"| `{s}` | {lab} | {ua(cur[s])} |")
    print("\n</details>\n")
    if "precharge_start" in m:
        print(f"Precharge cell while seeding vctrl at power-up (1-120 ns): "
              f"{ua(-m['precharge_start'])} uA.\n")


def p1():
    t = read("P1_latch")
    if t is None:
        return
    print("## P1 -- one d_latch, transparent, DC\n")
    print("| input CM | vdiff (V) | net1 | net2 | vout+ | vout- | core (uA) | inverters (uA) |")
    print("|---|---|---|---|---|---|---|---|")
    cm = None
    for ln in t.splitlines():
        if ln.startswith("#LATCH"):
            cm = ln.split("=")[1].strip()
            continue
        f = ln.split()
        if cm and len(f) == 9 and f[0].isdigit():
            v = [float(x) for x in f[2:]]
            print(f"| {cm} | {v[0]:+.1f} | {v[1]:.3f} | {v[2]:.3f} | {v[3]:.3f} | "
                  f"{v[4]:.3f} | {v[5]:.0f} | {v[6]:.1f} |")
    print()


def p2():
    t = read("P2_flop")
    if t is None:
        return
    m = meas(t)
    deck = open(os.path.join(DECKS, "P2_flop.spice")).read()
    bits = list(map(int, re.search(r"^\* BITS (.+)$", deck, re.M).group(1).split()))
    rows = [list(map(float, l.split())) for l in open(os.path.join(RES, "P2_flop.dat"))
            if l.strip()]
    tt = [r[0] for r in rows]
    col = lambda k: [r[2 * k + 1] for r in rows]
    q, qn, n1, n2 = col(1), col(2), col(3), col(4)
    at = lambda v, x: v[min(bisect.bisect_left(tt, x), len(v) - 1)]
    ui, t0 = 1.665e-9, 0.7325e-9 + 50e-12
    errs = n = 0
    for k in range(3, len(bits) - 1):
        te = t0 + k * ui
        got = 1 if at(q, te + ui - 0.15e-9) > at(qn, te + ui - 0.15e-9) else 0
        errs += got != bits[k]
        n += 1
    regen = [abs(at(n1, t0 + 6 * ui + d) - at(n2, t0 + 6 * ui + d)) for d in
             (0, 100e-12, 300e-12)]
    print("## P2 -- one d_flip_flop at CTLE-output levels\n")
    print("300 mV diff pp, CM 1.3 V, 600.6 Mb/s, ideal full-rail clock.\n")
    print(f"- bits captured correctly: **{n - errs} / {n}**")
    print(f"- two latch cores: {ua(-m['icore'])} uA; four output inverters: "
          f"{ua(-m['iinv'])} uA")
    print(f"- time with BOTH outputs below 0.9 V: master {100 * m['bothlow_master']:.1f} %, "
          f"slave {100 * m['bothlow_slave']:.1f} %")
    print(f"- master |net1-net2| at the clock edge / +100 ps / +300 ps: "
          + " / ".join(f"{v * 1e3:.0f} mV" for v in regen) + "\n")


def p3():
    t = read("P3_ring")
    if t is None:
        return
    print("## P3 -- clock generator vs vctrl (ideal vctrl source)\n")
    print("| vctrl (V) | f (MHz) | ring core, 5 stages (uA) | ring diff_amp_inv (uA) | "
          "CDR diff_amp_inv (uA) | inverter_buffer + single_inverter (uA) |")
    print("|---|---|---|---|---|---|")
    for blk in t.split("#RING vctrl=")[1:]:
        vc = blk.split()[0]
        m = meas(blk)
        core = -sum(m[f"vx1_x{i}"] for i in (1, 2, 3, 4, 5))
        f = m.get("f_mhz")
        fs = f"{f:.1f}" if f else "no clock"
        print(f"| {vc} | {fs} | {ua(core)} | {ua(-m['vx1_x6'])} | {ua(-m['vx4'])} | "
              f"{ua(-m['vx11'] - m['vx12'])} |")
    print()


if __name__ == "__main__":
    print("<!-- generated by collect_power.py -->\n")
    for fn in (p0, p1, p2, p3):
        fn()
