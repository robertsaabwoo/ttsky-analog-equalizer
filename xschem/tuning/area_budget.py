#!/usr/bin/env python3
"""Device inventory + rough area budget for the ctle_cdr_rx macro.

Flattens the xschem netlist hierarchy and reports, per top-level block, how many
devices of each kind there are and how much DRAWN area they occupy.

Drawn area is W*L for a MOS gate or a poly resistor body. Real occupied area is
larger -- contacts, diffusion extension, well spacing, guard rings. The
multipliers at the bottom are the usual rules of thumb for hand layout in
sky130; treat the result as a floorplan sanity check, not a commitment.
"""
import re
import sys
from collections import defaultdict

PATH = "/home/ttuser/ssh_analog/ttsky-analog-equalizer/xschem/simulation/ctle_cdr_rx_lvs.spice"

# ---- parse: join continuations, split into subckts -------------------------
subs, cur, buf, out = {}, None, [], []


def flush():
    if buf:
        (subs[cur] if cur else out).append(" ".join(" ".join(buf).split()))
        buf.clear()


for raw in open(PATH):
    s = raw.strip()
    if not s or s.startswith("*"):
        continue
    if s.startswith("+"):
        buf.append(s[1:].strip())
        continue
    flush()
    low = s.lower()
    if low.startswith(".subckt"):
        cur = s.split()[1]
        subs[cur] = []
    elif low.startswith(".ends"):
        cur = None
    elif low.startswith("."):
        pass
    else:
        buf.append(s)
flush()


def params(line):
    return dict(re.findall(r"(\w+)\s*=\s*'?([-\d.eE+]+)'?", line))


def devices(name, mult=1, acc=None):
    """Recursively accumulate (model -> [count, area_um2]) for subckt `name`."""
    acc = defaultdict(lambda: [0, 0.0]) if acc is None else acc
    for line in subs.get(name, []):
        tok = line.split()
        if not tok or not tok[0][0].lower() == "x":
            continue
        # the model/subckt is the sky130_* token if there is one (MOS lines wrap
        # and their trailing tokens are fragments of ad/pd expressions), else the
        # last bare word (a subckt call)
        sky = [t for t in tok[1:] if t.startswith("sky130_")]
        if sky:
            target = sky[0]
        else:
            words = [t for t in tok[1:] if "=" not in t]
            target = words[-1] if words else ""
        if target in subs:
            devices(target, mult, acc)
            continue
        p = params(line)
        W, L = float(p.get("W", 0) or 0), float(p.get("L", 0) or 0)
        nf = float(p.get("nf", 1) or 1)
        m = float(p.get("mult", 1) or 1) * float(p.get("m", 1) or 1)
        if "res_high_po_0p69" in target:
            W = W or 0.69
        elif "res_xhigh_po_0p35" in target:
            W = W or 0.35
        a = W * L * m * mult
        acc[target][0] += m * mult
        acc[target][1] += a
    return acc


TOP = "ctle_cdr_rx"
blocks = []
for line in subs[TOP]:
    tok = line.split()
    words = [t for t in tok[1:] if "=" not in t]
    blocks.append((tok[0], words[-1]))

print(f"{'instance':<8} {'block':<16} {'devices':>8} {'drawn um2':>11}")
print("-" * 48)
grand = defaultdict(lambda: [0, 0.0])
for inst, blk in blocks:
    acc = devices(blk)
    n = sum(v[0] for v in acc.values())
    a = sum(v[1] for v in acc.values())
    print(f"{inst:<8} {blk:<16} {n:>8.0f} {a:>11.1f}")
    for k, v in acc.items():
        grand[k][0] += v[0]
        grand[k][1] += v[1]
print("-" * 48)
N = sum(v[0] for v in grand.values())
A = sum(v[1] for v in grand.values())
print(f"{'TOTAL':<25} {N:>8.0f} {A:>11.1f}\n")

print(f"{'model':<38} {'count':>6} {'drawn um2':>11}")
print("-" * 58)
for k in sorted(grand, key=lambda x: -grand[x][1]):
    n, a = grand[k]
    print(f"{k:<38} {n:>6.0f} {a:>11.1f}")

print(f"""
--- floorplan sanity check -------------------------------------------
drawn device area                {A:8.0f} um2
x3 (hand layout, contacts/spacing/wells, typical)   {A*3:8.0f} um2
x5 (conservative, guard rings + routing channels)   {A*5:8.0f} um2

2x2 analog tile available        {334.88*225.76:8.0f} um2
1x2 analog tile (what it was)    {161.0*225.76:8.0f} um2""")
