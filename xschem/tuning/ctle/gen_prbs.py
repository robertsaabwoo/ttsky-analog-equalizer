#!/usr/bin/env python3
"""Write a PRBS7 PWL data source for the CTLE eye testbench.

    gen_prbs.py <out.inc> [ui_ns] [trf_ps] [nbits]

Emits a single 0/1-level PWL source `Vdata dsrc 0 PWL(...)`; the testbench
scales it to the wanted differential amplitude and common mode with two
behavioural sources, so amplitude stays an `alterparam`-able .param.
PRBS7 = x^7 + x^6 + 1, 127 bits, which is what a TinyTapeout-scale link
tester would plausibly send.
"""
import sys

out = sys.argv[1] if len(sys.argv) > 1 else "prbs.inc"
ui = float(sys.argv[2]) if len(sys.argv) > 2 else 1.665e-9   # 600.6 Mb/s
trf = float(sys.argv[3]) if len(sys.argv) > 3 else 100e-12   # data edge rate
nbits = int(sys.argv[4]) if len(sys.argv) > 4 else 127

# PRBS7
reg = 0x7F
bits = []
for _ in range(nbits):
    fb = ((reg >> 6) ^ (reg >> 5)) & 1
    reg = ((reg << 1) | fb) & 0x7F
    bits.append(fb)

pts = [(0.0, float(bits[0]))]
t = 0.0
for i in range(1, len(bits)):
    t = i * ui
    if bits[i] != bits[i - 1]:
        pts.append((t - trf / 2, float(bits[i - 1])))
        pts.append((t + trf / 2, float(bits[i])))
pts.append((len(bits) * ui, float(bits[-1])))

with open(out, "w") as f:
    f.write(f"* PRBS7, {nbits} bits, UI={ui*1e9:.4f} ns, tr/tf={trf*1e12:.0f} ps\n")
    f.write(f".param ui={ui} tsim={len(bits)*ui}\n")
    f.write("Vdata dsrc 0 PWL(\n")
    for i, (tt, v) in enumerate(pts):
        f.write(f"+ {tt:.6e} {v:.1f}\n")
    f.write("+ )\n")

with open(out.replace(".inc", "_bits.txt"), "w") as f:
    f.write("".join(str(b) for b in bits) + "\n")
    f.write(f"{ui}\n")

print(f"{out}: {len(bits)} bits, {len(pts)} PWL points, tsim={len(bits)*ui*1e9:.1f} ns")
