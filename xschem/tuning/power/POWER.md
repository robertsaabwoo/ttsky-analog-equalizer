# Power analysis — `ctle_cdr_rx`, tt / 27 °C / 1.8 V

Where the supply current goes in the frozen macro, measured cell by cell in
ngspice with the loop **closed and locked on PRBS7**. Measured 2026-10-05.

Everything here is reproducible from this directory — see [Reproducing](#reproducing).
Nominal corner only, schematic level (no layout parasitics). The limits of the
numbers are listed at the end.

## Headline

| | |
|---|---|
| **Total, locked, PRBS7** | **4.86 mA → 8.74 mW** from the 1.8 V rail |
| recovered clock during the measurement | 601.05 MHz |
| `vctrl` during the measurement | 0.797 → 0.793 V, 93.7 mV pp ripple (§C25-B measured 93.8 mV pp) |
| `up` / `down` duty (fraction of time high, same window) | 0.206 / 0.318 (added 2026-10-06; the rerun reproduced every other number exactly. The log's `up_duty`/`dn_duty` are average *voltages*, 0.371 / 0.573 V; divide by 1.8 V) |
| `vbias` pin (`ua[2]`) | ~0 µA — gates only, as `docs/info.md` says |
| always-on bias current (CML-style tails + CTLE) | **4.31 mA, 89 %** |
| CMOS switching current (all inverters, XORs, drivers) | 0.54 mA, 11 % |

**About 89 % of the power is static bias current, which flows whatever the data
is doing.** More than half the chip's power is in the phase detector's eight
latches, and most of the rest is in the clock path that feeds them.

## Where it goes

Measured with P0, averaged over 600–1000 ns of a closed-loop run. Each output pin
is loaded with 50 fF, which is an assumption (see the Limits section).

| function | block | instances | current (µA) | power (µW) | share |
|---|---|---|---|---|---|
| **Phase detector** | latch cores, first rank (sample the analog CTLE output) | 2 | 624.5 | 1124 | 12.9 % |
| | latch cores, the other six (their inputs are already full-rail CMOS) | 6 | **1860.5** | **3349** | **38.3 %** |
| | latch output inverters (CML→CMOS), all 8 latches | 8 | 70.8 | 127 | 1.5 % |
| | `robs_xor` ×2 | 2 | 7.2 | 13 | 0.1 % |
| | *subtotal* | | *2563.0* | *4613* | *52.8 %* |
| **Clock generation** | ring oscillator core (5 × `ring_inverter`) | 5 | 636.6 | 1146 | 13.1 % |
| | `diff_amp_inv` at the ring output (inside `ring_oscillator`) | 1 | 517.7 | 932 | 10.7 % |
| | `diff_amp_inv` x4 in `CDR` (makes `clkraw`) | 1 | 536.5 | 966 | 11.0 % |
| | `inverter_buffer` + `single_inverter` (`rclk+` / `rclk-`) | 2 | 212.5 | 383 | 4.4 % |
| | *subtotal* | | *1903.3* | *3426* | *39.2 %* |
| **Outputs** | `inverter_chain` ×2 → `uo_out[0:1]`, 50 fF each | 2 | 251.6 | 453 | 5.2 % |
| **Equalizer** | CTLE | 1 | 133.5 | 240 | 2.7 % |
| **Loop** | charge pump | 1 | 1.2 | 2 | 0.0 % |
| | bias generator | 1 | 3.7 | 7 | 0.1 % |
| | `vctrl_precharge` (after it releases) | 1 | 0.2 | 0.4 | 0.0 % |
| | loop filter (well/bulk leakage only) | 1 | 0.0 | 0 | 0.0 % |
| **Total** | | 34 cells | **4856.5** | **8742** | 100 % |

The per-cell table (all 34 meters) is printed by `collect_power.py`.

## What the numbers say

**1. The phase detector's latches are 51 % of the chip, and three-quarters of
that is in latches that don't need to be CML.**
Each latch core draws ~290–320 µA whether it toggles or not. Only the two
first-rank masters (inside flops `x5` and `x1` of `alexander_phase_detector`)
see the small analog CTLE output. The other six get full-rail CMOS from the
latch before them, so for them the current-steering front end buys nothing.
Those six cores draw 1.86 mA, 38 % of the chip, the largest single item here.

**2. The CML→CMOS inverters are cheap. The large swing they force on the
latch is not.**
All 16 output inverters together draw 71 µA (1.5 %). The cost is indirect: to
drive an inverter whose trip point is ~0.87 V, the latch core needs a ~1.2 V
single-ended swing instead of a CML-style ~0.4 V. With the same load resistor,
that takes roughly 3× the current (P1, P2).

**3. The two `diff_amp_inv` stages draw 1.05 mA (22 %), and nothing regulates
that current.** Both are instantiated with their `vctrl` (tail-gate) pin tied to
`VDPWR`, so the tail runs at full gate drive. Their current is the same at every
`vctrl` (P3: 515–541 µA each from 0.70 to 0.87 V), so it tracks the supply
voltage, not a bias. Each one draws as much as the entire ring core.

**4. The ring core is the oscillator's tuning mechanism, so its current moves
with frequency.** It draws 617 µA at the lock point and rises ~4.9 µA per mV of
`vctrl` (P3: 616 → 807 µA from 0.791 to 0.83 V). Above ~0.83 V the current keeps
rising but the frequency doesn't: 610.5 MHz at 0.83 V, 608.4 MHz at 0.87 V. That
is the RC-limited regime documented in NOTES §20b.

**5. The latch current depends on the CTLE's output common mode.** The latch
tail is voltage-biased from `vbias` and sits in triode, so the current follows
the input CM: 173 µA per latch at CM 0.9 V and 305 µA at CM 1.3 V (P1, balanced
input). The CTLE output CM moves 1.149–1.511 V over PVT (§C22), so the phase
detector's power, and its resolve threshold, will move with it. This has not
been simulated at the corners.

**6. The loop itself is essentially free.** Charge pump, bias generator, loop
filter and the released precharge together draw 5 µA (0.1 %). The precharge
draws 126 µA only while seeding `vctrl` for the first ~120 ns, then 0.2 µA.

**7. The CTLE is cheap for what it does:** 134 µA, 2.7 %.

## Supporting measurements

### P2 — one flip-flop at the levels the phase detector actually sees

300 mV diff pp, CM 1.3 V, 600.6 Mb/s, ideal full-rail clock, rising edge at mid-bit.

- bits captured correctly: **28 / 28**
- two latch cores 619.0 µA, four output inverters 24.9 µA
- time with both outputs below 0.9 V (the illegal state): master 36.7 %, slave 6.2 %
- master |net1 − net2| at the clock edge / +100 ps / +300 ps: 590 / 1017 / 1194 mV

So the latch's illegal both-low state is real but harmless here. It happens in
the master while the master is transparent, and the slave only reads the master
while the master is holding and fully regenerated. This is why the
phase detector works despite the ~0.47 V resolve threshold reported in NOTES
§12a. That threshold is for CM 0.9 V; at the CTLE's actual output CM it is far
lower (P1).

### P1 — one latch, transparent, DC (balanced rows and the resolve point)

| input CM | vdiff (V) | net1 = net2 at balance | vout± at balance | vdiff for a full output | core (µA) | inverters (µA, peak) |
|---|---|---|---|---|---|---|
| 0.9 V | 0 | 1.467 V | both 0.000 V | ≥ 0.6 V (vout 1.70 V) | 173 – 261 | 34.1 |
| 1.3 V | 0 | 1.215 V | both 0.005 V | ≥ 0.2–0.3 V (vout 1.62–1.79 V) | 305 – 317 | 28.7 |

At balance both inverters read low, which is the non-complementary state from
§12a. The full sweep is in `collect_power.py`'s output.

### P3 — clock generator alone, `vctrl` from an ideal source

| vctrl (V) | f (MHz) | ring core (µA) | ring `diff_amp_inv` (µA) | CDR `diff_amp_inv` (µA) | buffers (µA) |
|---|---|---|---|---|---|
| 0.70 | no full-swing clock | 216.5 | 531.8 | 525.0 | 90.3 |
| 0.75 | 571.3 | 411.1 | 515.0 | 529.9 | 100.9 |
| **0.791** | **602.6** | **616.1** | 517.1 | 536.1 | 105.3 |
| 0.83 | 610.5 | 806.7 | 520.8 | 540.5 | 107.8 |
| 0.87 | 608.4 | 914.2 | 521.5 | 541.3 | 107.5 |

At the lock point, P3's ring core (616 µA) and `diff_amp_inv` currents match
P0's (637, 518, 537 µA) to within a few percent. The buffers draw more in P0
(213 vs 105 µA) because there they also drive the phase detector's eight clock
inputs and the two output chains.

## Limits of these numbers

- **One corner: tt / 27 °C / 1.8 V.** Points 3–5 above say which currents will
  move at other corners (supply, `vctrl`, CTLE output CM). None of that has been
  simulated.
- **Schematic only.** There are no wiring parasitics. Post-layout, the CMOS
  switching share (11 %) will grow; the bias-current share will not.
- **The output load is an assumption.** No `uo_out` load is documented anywhere
  in the repo. Each output chain's switching current scales by
  C·V·f ≈ 1.08 µA per fF per pin at 601 MHz, so 50 fF accounts for ~54 µA of
  each chain's 125 µA.
- **The loop was not fully settled.** PRBS7 takes ~3 µs to settle (§C25-B); this
  window is 0.6–1.0 µs, with `vctrl` at 0.797 → 0.793 V against the settled
  0.799 V. At 4.9 µA/mV of ring current, that is under 20 µA (< 0.5 % of the total).
- **The supply is ideal.** There's no IR drop, and every cell gets its own ideal
  1.8 V source so its current can be read. That is electrically identical to one
  shared ideal rail.

## Reproducing

```bash
cd xschem/tuning/power
./run_power.sh            # all four decks, sequentially, then prints the report
./run_power.sh P1 P2 P3   # just the cheap ones (seconds each)
CLOAD=100f ./run_power.sh P0   # another output-pin load
./collect_power.py        # re-print the report from existing results/
```

| file | what it does |
|---|---|
| `gen_power.py` | netlists `../../ctle_cdr_rx_lvs.sch` with xschem (and fails if a symbol is missing), flattens the hierarchy to its leaf cells, gives every leaf its own supply source, splits each `d_latch` into core and inverter supplies, checks that all 223 devices are metered, and writes `decks/` |
| `run_power.sh` | regenerates, then runs each deck **one at a time** through `../safe_ngspice.sh` into `results/`, then collects |
| `collect_power.py` | parses `results/` and prints the tables above as Markdown; pure stdlib |
| `decks/`, `results/`, `.netlists/` | generated, gitignored |

| deck | what | cost |
|---|---|---|
| P0_chain | whole macro, closed loop, PRBS7, 1 µs | **~7 min** on this VM |
| P1_latch | one latch, DC sweep at CM 0.9 and 1.3 V | ~10 s |
| P2_flop | one flip-flop transient at CTLE-output levels | ~15 s |
| P3_ring | clock path at 5 `vctrl` values | ~30 s |

The 223 metered devices are the source side of LVS. `mag/LAYOUT_HANDOFF.md`
counts 224 because netgen expands the charge pump's `sky130_fd_sc_hd__inv_1`
into two transistors, where the generator counts it as one cell.
