# LAYOUT HANDOFF — everything a layout session needs

Written 2026-08-15, at the point where the schematic design was frozen,
netlist-verified and the LVS toolchain proven to run. **Nothing has been drawn
yet.** This file is the starting point for a session dedicated to layout.

Read `../CLAUDE.md` first for the VM rules — they apply to magic and netgen too.

---

## 1. What you are laying out

One analog macro: **`ctle_cdr_rx`** — a 600 Mb/s receiver front end.

```
ua[0] ─┐                        ┌─ Alexander PD ──┐
       ├─► CTLE ──► equalized ──┤  charge pump    │──► clkout_p ──► uo_out[0]
ua[1] ─┘            data        │  loop filter    │──► clkout_n ──► uo_out[1]
                                └─ ring VCO ◄─────┘
ua[2] = vbias
```

**Macro pins** (this order, from `xschem/simulation/ctle_cdr_rx_lvs.spice`):

```
.subckt ctle_cdr_rx vinp vinm vbias clkout_p clkout_n VDPWR VGND
```

**Pad mapping** (defined in `src/project.v`, which is what LVS checks against):

| macro pin | TT pad | note |
|---|---|---|
| `vinp` | `ua[0]` | differential input + |
| `vinm` | `ua[1]` | differential input − |
| `vbias` | `ua[2]` | external ~0.9 V reference |
| `clkout_p` | `uo_out[0]` | recovered clock |
| `clkout_n` | `uo_out[1]` | inverted phase — **also loads the ring symmetrically, do not delete** |
| `VDPWR` / `VGND` | supplies | |

`uo_out[7:2]`, all `uio_*` and all digital inputs are **physically unconnected**
— deliberately. `project.v` leaves them undriven so it keeps matching a layout
with no tie cells in it. Do not add tie-offs in layout without changing
`project.v` to match.

---

## 2. Current state

- `tt_um_robertsaabwoo_ctle_clock_recovery.mag` is the **empty 2x2 frame**,
  generated from `tt_analog_2x2.def`. Pins and two power stripes, no devices.
- `make lvs` **runs correctly end to end**. It reports `LVS FAIL` only because
  the layout side has 0 devices; the source side correctly flattens to 224
  devices. That is the expected answer today and it proves the plumbing works:

  ```
  Circuit 1 (layout): 0 device instances, 53 disconnected pins
  Circuit 2 (source): 224 device instances, 129 nets
  ```

- Die area: **2x2 = 334.88 × 225.76 µm = 75 603 µm²**.

---

## 3. Toolchain

```bash
export PDK_ROOT=/home/ttuser/pdk PDK=sky130A
cd mag
make magic        # open the layout
make drc          # batch DRC
make lvs          # layout vs src/project.v + the xschem netlist
make update_gds   # writes ../gds/*.gds and ../lef/*.lef when done
```

`make lvs` reads the source netlist from
`../xschem/simulation/ctle_cdr_rx_lvs.spice`. **Regenerate it if any schematic
changes:**

```bash
cd ../xschem
xschem -n -s -x -q --rcfile ./xschemrc -o simulation ctle_cdr_rx_lvs.sch
```

Netlist the **`_lvs` wrapper**, not `ctle_cdr_rx.sch` itself — netlisting the
macro directly makes it the netlist top and emits no `.subckt`, which leaves
netgen with no cell to match.

KLayout is fine for viewing and for the sky130 DRC deck, but the whole flow here
(extraction, LVS, GDS/LEF write) is **magic-based**. Do not migrate it.

---

## 4. Hierarchy and device inventory

224 devices, 129 nets. By block, with drawn device area:

| block | devices | drawn µm² | dominated by |
|---|---:|---:|---|
| `CTLE` | 8 | 396.0 | the one MiM cap (324 µm²) |
| `ring_oscillator` | 35 | 321.9 | `res_high_po` loads |
| `alexander_phase_detector` | 120 | 137.3 | `res_high_po_0p69` |
| `vctrl_precharge` | 9 | 119.7 | the 8×8 POR cap (64 µm²) |
| `diff_amp_inv` | 10 | 55.1 | `res_high_po` |
| `tiny_pll_loop_filter` | 3 | 21.8 | MOS caps |
| `tiny_pll_bias_gen` | 15 | 11.4 | |
| `inverter_chain` (×2) | 6 each | 5.4 each | |
| `inverter_buffer` | 4 | 5.5 | |
| `single_inverter` | 2 | 3.6 | |
| `tiny_pll_charge_pump` | 5 | 3.2 | **taped out — see §6** |
| **total** | **224** | **1162** | |

Leaf cells worth knowing: `d_latch` (13 devices, 16.6 µm²) — there are **eight**
of them inside the PD; `ring_inverter` (5 devices, 53.4 µm²) — there are **five**
in the ring.

By device class (netgen's own count, the authoritative one):

```
nfet_01v8        135      res_high_po        22
pfet_01v8         44      res_high_po_0p69   16
pfet_01v8_hvt      1      res_xhigh_po_0p35   5
cap_mim_m3_1       1
```

---

## 5. Floorplan guidance

**Area is not the constraint.** 1162 µm² drawn against 75 603 µm² available —
even at a 5× hand-layout multiplier that is ~5800 µm². A 1x2 tile would have fit;
2x2 was chosen for comfort (see `README.md` here). So optimise for **matching and
clean supplies, not density.**

What actually shapes the floorplan:

1. **The ring oscillator wants symmetry above everything else.** Five identical
   `ring_inverter` stages plus `diff_amp_inv`. Place them as a matched row with
   identical routing per stage. Asymmetry here shows up directly as
   recovered-clock duty-cycle error — and there is already a known duty-cycle
   problem (§7), so do not add to it.

2. **The long poly resistors dictate shape, not area.** `res_high_po` at W=1 µm,
   L=20–23 µm each, 22 of them; plus 16 `res_high_po_0p69` at L=7. And the
   precharge's POR resistor is `res_xhigh_po_0p35` at **L=120 µm** — that one
   needs a serpentine. Plan a resistor row/field early; these are thin strips and
   they will define the aspect ratio of the CTLE, the d_latches and the ring.

3. **The MiM cap is nearly free floor area.** `cap_mim_m3_1` 18×18 µm sits above
   metal3, so it can overlap logic placed beneath it. Do not spend 324 µm² of
   floor on it.

4. **The PD is device-count-heavy but area-light** — 120 devices in 137 µm².
   Treat it as a dense block; it is 8 × `d_latch` + 2 × `robs_xor`.

5. **Leave headroom around `tiny_pll_loop_filter`.** `cap1` is the one device
   that may still change size — see §8.

6. **Widen the power straps before you draw.** `tcl/tt-analog-draw.tcl` draws
   stripes only at x = 1 µm and x = 4 µm, which was sized for the 161 µm wide
   1x2 die. On a 334.88 µm die you want more. Edit its `POWER_STRIPES` list and
   regenerate, rather than patching power in afterwards.

---

## 6. Hard constraints — do not change these

- **`tiny_pll_charge_pump` is already taped out.** Do not modify it. It was
  measured on 2026-08-15 and is well matched (1.263 µA up / 1.284 µA down,
  1.6 % mismatch); it is not a problem and needs no rework.
- **The device sizing in `xschem/*.sch` is validated.** It was promoted from the
  `tuning/` sandbox and verified netlist-for-netlist — all 17 leaf subcircuits
  matched exactly. Do not "tidy" device sizes during layout.
- **`MBD` in `vctrl_precharge` is a scaled replica of the ring's tail device
  `M5`.** That is deliberate — it makes the startup seed track the VCO over PVT,
  which is why 45/45 PVT corners pass. **If M5 is ever resized, resize MBD
  identically.** Match them in layout too.
- **`stash@{0}` in git holds stale pre-validation edits. Never pop it.**

---

## 7. Traps already hit — do not rediscover these

- **`make start` silently keeps a pre-existing `$(PROJECT_NAME).mag`** instead of
  rebuilding from the template. Changing `TEMPLATE_FILE` alone does nothing; the
  first 2x2 regeneration here produced a 1x2 frame with no warning. Delete the
  `.mag` first.
- **The 1x2 and 2x2 `.def` files are identical except for `DIEAREA` and the
  std-cell rows.** Same pins, same positions. So the generated `.mag` bbox does
  not change and looks wrong. `info.yaml: tiles` is what claims the area.
- **`mag/.gitignore` ignores `*def`**, so the template `.def` is not in git. The
  Makefile has `wget` rules for both.
- **`rclk-` is not a true complement of `rclk+`.** It is `rclk+` through an
  inverter, so it carries that inverter's delay and threshold offset — measured
  duty cycles are ~33 % and ~61 %. This is structural and confirmed present even
  in a cleanly locked loop. Do not design anything in layout assuming 50 % duty
  or exact complementarity.
- **xschem netlisting fails with rc=1 and no diagnostic when driven from a
  subdirectory** — `PWD` is inherited and trusted. Stamp it explicitly.
- **`make lvs` silently skips netgen if `lvs.report` is newer than its
  prerequisites.** You get only the pass/fail line from the shell check, with no
  circuit contents — so a stale report looks exactly like a fresh run. If you
  need a genuine re-verification, `rm -f lvs.report *.lvs.spice` first. This bit
  during the 2026-08-15 cleanup: a "re-verify" printed nothing and had in fact
  re-run nothing.
- **`xschem/attic/` must stay on `XSCHEM_LIBRARY_PATH`** (set in
  `xschem/xschemrc`). Symbols resolve across it in both directions. A missing
  symbol is resolved *silently* — truncated netlist, "Symbol not found", rc=0.

---

## 8. Open items that could still change devices

Layout can start now; these are the only things that might move a device.

1. **`cap1` in `tiny_pll_loop_filter` may grow.** It is `nfet_01v8 W=4 L=0.6
   mult=6` ≈ 121 fF. The residual control-voltage dither is set by bang-bang
   quantisation, `ΔV = Icp·UI/C = 1.27 µA × 1.665 ns / 121 fF ≈ 17 mV` per
   update — which matches the measured 33.7 mV pk-pk ripple on 0101. If jitter
   work concludes the dither must come down, the lever is raising `mult`, at the
   cost of slower acquisition (the §16 trade). Doubling it costs ~14 µm².
   **Leave room.**
2. **Jitter is not fully characterised.** Cycle-to-cycle is fine (1.48 % UI RMS).
   The long-term phase measurement was confounded and needs redoing on a ≥5 µs
   run — see `xschem/tuning/ctle/NOTES_CTLE.md` §C26. This is verification of a
   frozen design, not a design change; it can run while you draw.
3. **`info.yaml: author` is blank** and will likely fail the docs CI.

---

## 9. VM rules (from `../CLAUDE.md`, they still apply)

7.8 GB RAM, 4 CPU, and it has been crash-rebooted once by an unguarded ngspice.

- Never run two ngspice at once. Always wrap them in
  `xschem/tuning/safe_ngspice.sh`.
- Never a bare `write foo.raw` — always an explicit vector list.
- **Interactive tool use steals ~3× from a background sim.** Measured: the same
  3 µs run took 1189 s while this session was running xschem/magic/netgen
  concurrently, and 391 s when it was not. If a long sim matters, stay off the
  box.
- magic and netgen are installed and behave; verilator is installed and
  `src/project.v` lints clean.

---

## 10. The other documents

| file | what |
|---|---|
| `README.md` (here) | 2x2 caveats, floorplan budget, power-strap note |
| `../xschem/STATUS.md` | state of the real design files, promotion record |
| `../xschem/tuning/HANDOFF.md` | overall project state and open items |
| `../xschem/tuning/NOTES.md` | CDR design log, §1–§20 |
| `../xschem/tuning/ctle/NOTES_CTLE.md` | CTLE + end-to-end log, §C1–§C26 |
| `../docs/info.md` | the datasheet — how it works, pinout, how to test |
| `../CLAUDE.md` | VM rules and tool traps |
