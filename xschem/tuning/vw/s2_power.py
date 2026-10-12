#!/usr/bin/env python3
"""Per-block supply current from a flattened chain log (meas lines of the V* sources).

    s2_power.py S2_cx_ref.log [decks/S2_cx_ref.spice]

Groups the metered leaf cells by the '* SRC' labels in the deck: CTLE, PD
latches, PD converters, PD XORs, cml_bias, ring, clock converters, output
chains, loop (pump/bias gen/filter/precharge). Averages are over the deck's
last 400 ns. Pure stdlib (../../../CLAUDE.md).
"""
import os
import re
import sys

log = sys.argv[1]
deck = sys.argv[2] if len(sys.argv) > 2 else os.path.join("decks", os.path.basename(log)[:-4] + ".spice")
labels = {}
for line in open(deck):
    m = re.match(r"\* SRC (\S+) (\S+)", line)
    if m:
        labels[m.group(1)] = m.group(2)
cur = {}
for line in open(log):
    m = re.match(r"(v\S+)\s+=\s+([-\d.e+]+)\s+from", line)
    if m and m.group(1) in labels:
        cur[m.group(1)] = -float(m.group(2)) * 1e6


def group(path):
    leaf = path.split("/")[-1]
    if "CTLE" in leaf:
        return "CTLE"
    if "cml_pd" in path:
        if "cml_latch" in leaf:
            return "PD latches"
        if "cml2cmos" in leaf:
            return "PD converters"
        return "PD XORs"
    if "cml_bias" in leaf:
        return "cml_bias reference"
    if "ring" in path:
        return "ring core"
    if "diff_amp_inv" in leaf:
        return "clock buffer (diff_amp_inv)"
    if "cml2cmos" in leaf:
        return "recovered-clock converters"
    if "inverter_chain" in leaf:
        return "output inverter_chains"
    return "loop (pump, bias gen, filter, precharge)"


tot = {}
for s, i in cur.items():
    g = group(labels[s])
    tot[g] = tot.get(g, 0.0) + i
for g, i in sorted(tot.items(), key=lambda x: -x[1]):
    print(f"  {g:42s} {i:8.1f} uA")
print(f"  {'TOTAL (metered leaves)':42s} {sum(tot.values()):8.1f} uA = {sum(tot.values()) * 1.8e-3:.2f} mW")
