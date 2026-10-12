# `xschem/cml/` — the low-power CML receiver

A second design of the `ctle_cdr_rx` macro: same CTLE, same ring oscillator,
same taped-out charge pump, same ports (`vinp vinm vbias clkout_p clkout_n
VDPWR VGND`), at **1.84 mA / 3.32 mW instead of 4.86 mA / 8.74 mW** (tt / 27 °C
/ 1.8 V, locked on PRBS7). The frozen design in `../` is untouched.

Everything here is **generated** from the netlists that were simulated, and
**netgen-verified** against them. Do not edit the `.sch` / `.sym` files by hand:
change `../tuning/vw/*.inc` (or the tops in `gen_cml_sch.py`), regenerate, and
re-verify.

```bash
cd xschem/cml
./gen_cml_sch.py A      # A: pump on cp_bias; B: pump on tiny_pll_bias_gen; AB: both
./verify.sh             # xschem netlist vs reference.spice, every cell, in netgen
```

`verify.sh` passes only when every cell matches in **topology and properties**.
netgen prints "Circuits match uniquely" even when a W or L differs, and reports
that on a separate "Property errors" line; a negative control (one W changed
by 11 %) confirmed it, so the script checks both.

## What changed against the frozen design, and why

Each change was found with a short isolated test; the evidence is in
`../tuning/cml/CML.md` and the benches in `../tuning/vw/`.

| block | frozen | here | why |
|---|---|---|---|
| PD latches (8) | `d_latch`: ~1.2 V swing into CMOS inverters, ~310 µA each | `cml_latch`: 0.4 V swing, no inverters, ~58 µA each | the swing existed only to drive the inverters (power study, `../tuning/power/POWER.md`) |
| PD logic | `robs_xor` on the latch inverters | `cml_pd_cx3w`: three `cml2cmos_w2` converters (~36 µA) into two `sky130_fd_sc_hd__xor2_1` | a CML XOR needed a level-shifted input that collapsed at fast-NMOS corners; 18 µA converters skewed at sf/125 °C |
| tail bias of every CML cell | the `vbias` pin voltage on each gate | `cml_bias`: `res_high_po` resistor into a diode, mirrored (`vbn`) | voltage bias let the current, and the swing, follow the NMOS corner: swing 0.19–0.66 V over PVT vs 0.30–0.50 V (B1) |
| clock buffer | 2 × `diff_amp_inv`, tails on VDD | `cml_clkbuf`: one stage pair, L=0.5 tails on `vbn` | ~1 mA saved; the weakened buffer on an ideal 0.85 V gate lost the clock at sf/125 °C and ff/125 °C (B4) |
| recovered clock | `inverter_buffer` + `single_inverter` | two `cml2cmos` (one per phase) | 213 → 60 µA, and a true complement |
| loop filter | R 86.3 kΩ, C1 109 fF, C2 16 fF | `cml_loop_filter`: R 33.2 kΩ, C1 291 fF, C2 43.5 fF | the frozen PD's XOR glitch cancels ~61 % of each decision's charge at tt; the CML PD does not glitch, so the filter is scaled to give the same effective loop deliberately |
| pump bias (option A only) | `tiny_pll_bias_gen` | `cp_bias`: `xhigh_po` resistor reference | pump current 13.6x over PVT -> 2.5x; kick Icp x R_filter 10.9x -> 1.7x (B2) |

## The two options

- **A — `ctle_cdr_rx_cml`**: the pump biased by `cp_bias`.
- **B — `ctle_cdr_rx_cml_bg`**: the pump biased by the original `tiny_pll_bias_gen`.

They differ in one cell. A holds the loop gain much steadier over PVT; B keeps
the original bias generator. At tt they are within run-to-run scatter of each
other in jitter; the corner results decide (see `../tuning/cml/CML.md`).

## Cells

| cell | what |
|---|---|
| `cml_latch`, `cml_dff` | CML latch (resistor loads, saturated tail) and master-slave flop |
| `cml2cmos`, `cml2cmos_w2` | CML-to-CMOS converter (mirror-loaded pair + 2 inverters); `_w2` = 2x tail |
| `cx_xor` | `sky130_fd_sc_hd__xor2_1` as a leaf cell |
| `cml_pd_cx3w` | Alexander bang-bang PD: 4 CML flops, 3 converters, 2 XORs |
| `cml_bias` | tail-current reference (`vbn`), ~16 µA |
| `cml_clkbuf` | the clock buffer, on `vbn` |
| `cp_bias` | charge-pump bias reference (option A) |
| `cml_loop_filter` | the scaled loop filter, flat |
| `ring_core` | the five frozen `ring_inverter` stages, without the frozen buffer |
| `CDR_cml`, `CDR_cml_bg` | the CDR, options A / B |
| `ctle_cdr_rx_cml`, `ctle_cdr_rx_cml_bg` | the macro, options A / B |
| `cml_lvs.sch` | one-instance wrapper for netlisting (like `../ctle_cdr_rx_lvs.sch`) |

## Not done here

- No layout. Nothing in `../../mag/` corresponds to this design yet.
- `src/project.v` still instantiates the frozen macro; the ports are identical,
  so switching is a module-name change once a layout exists.
- No Monte-Carlo mismatch, no post-layout simulation.
