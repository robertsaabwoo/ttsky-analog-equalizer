# All-CML phase detector — power experiment (sandbox)

**Question:** how much power does the CDR save if the logic between the ring and
the charge pump stays in CML at a ~0.4 V swing, the strong `diff_amp_inv`
clock buffers are removed or weakened, and the signal is converted to CMOS only
where CMOS is actually needed (`up`/`down` into the charge pump, and the
recovered clock for the output pins)?

**Answer, tt / 27 °C / 1.8 V, closed loop on PRBS7:** the loop locks (601.10
MHz, same stimulus as `../power/` P0) and the macro goes from **4.86 mA / 8.74 mW
to 1.86 mA / 3.34 mW (−62 %)**. **But jitter is worse:**
period jitter 2.77 % UI RMS against 1.11 % for the frozen design (§C27; both
figures are the RMS of the period, which `c27_analyze.py` labels
"cycle-to-cycle" -- see the J1 section), sampling-phase error 13.9 % against
12.0 % UI RMS, and 1.8 % against 1.1 % of samples within 25 mV of the decision
threshold (C4, below). **Cause located (2026-10-11): all of it is slow `vctrl`
wander**, which is ~2x the frozen design's; the clock path adds almost nothing
(J1). Why the CML PD makes the loop wander more is the open question.

Sandbox only: the frozen schematics are untouched. Measured 2026-10-05/06.

## What was changed

| | frozen design | this experiment |
|---|---|---|
| PD latches (8) | `d_latch`: resistor-loaded current-steering core swinging ~1.2 V, voltage-biased triode tail (173–305 µA, follows input CM), two output inverters each | `cml_latch`: same topology, no inverters, ~0.4 V swing, saturated tail, **54 µA**, nearly CM-independent |
| XORs (2) | `robs_xor`, static CMOS | `cml_xor`, Gilbert cell, 53 µA. Its lower pair needs a lower input CM, so the latch that feeds it (`x3`'s slave) is `cml_latch_ls`: a shared series resistor drops its output CM to ~1.18 V |
| CMOS conversion | inside every latch (16 inverters) | `cml2cmos` on `up` and `down` only (~18 µA each) |
| clock to PD | ring → `diff_amp_inv` → `diff_amp_inv` → `inverter_buffer` (rail to rail) | ring → **one** `diff_amp_inv`, its tail gate on a separate `vtail` = 0.85 V instead of VDD |
| recovered clock to the pins | `inverter_buffer` + `single_inverter` | two `cml2cmos` (one per phase, so both ring taps are loaded equally) |
| CTLE, ring, charge pump, bias gen, loop filter, precharge, output `inverter_chain`s | — | unchanged (frozen cells) |

Cells: `cells.py`. Topology: `gen_cml.py` (`CDR_cml_*`, `ring_core`).

## Result — closed loop (C3) vs the frozen design (P0)

Same stimulus and window: PRBS7 at 600.6 Mb/s, 200 mVpp through the 500 Ω / 5 pF
pad model, 50 fF on each output pin, averaged 600–1000 ns.

| block | frozen (µA) | CML (µA) | change (µA) |
|---|---|---|---|
| CTLE | 133.5 | 133.5 | 0 |
| PD latches (incl. the frozen design's output inverters) | 2555.8 | 423.5 | **−2132.3** |
| PD XORs | 7.2 | 106.4 | +99.2 |
| PD → charge pump converters (`up`/`down`) | — | 37.0 | +37.0 |
| ring core (5 stages) | 636.6 | 631.2 | −5.4 |
| clock buffer `diff_amp_inv` | 1054.2 (2 at full tail) | 211.8 (1 at `vtail` 0.85 V) | **−842.4** |
| recovered-clock drivers (`rclk+`/`rclk-`) | 212.5 | 57.2 | −155.4 |
| output `inverter_chain` ×2 | 251.6 | 252.0 | 0 |
| charge pump + bias gen + loop filter + precharge | 5.2 | 4.6 | 0 |
| **total** | **4856.5** | **1857.1** | **−2999.4 (−62 %)** |

| | frozen | CML |
|---|---|---|
| recovered clock in the window | 601.05 MHz | 601.10 MHz |
| `vctrl` (two halves of the window) | 0.7967 → 0.7934 V | 0.7964 → 0.7953 V |
| **`vctrl` ripple** | **93.7 mV pp** | **188.3 mV pp** |
| `up` / `down` duty | not measured | 0.237 / 0.299 |

Now the largest items are the ring core (631 µA, which stays CML: it is the
tuning element), the output drivers (252 µA, set by the assumed pin load), the
buffer (212 µA) and the CTLE (134 µA).

## How it got there — every step, including the dead ends

**C0, sizing.** The first latch guess (tail W = 1) gave only 16 µA and a
0.12 V swing. A DC sweep of tail width (C0) set **W = 3 → 54 µA, 0.39 V swing**
for the latch and 53 µA for the XOR. The current is the same at input CM
1.3 V and 1.6 V (54 vs 55 µA), unlike the frozen latch (173 vs 305 µA). With
`lat_Lcm` = 15 the level-shifted latch sits at ~1.18 V CM.

**C1, the phase detector's characteristic.** Four CML PDs were clocked at fixed
phase offsets against the same PRBS7 at CTLE-output levels (300 mV diff pp,
CM 1.3 V, ideal 0.8–1.8 V ring-like clock):

| clock phase | up | down |
|---|---|---|
| −0.3, −0.1 UI (early) | 0.000 | 0.574 |
| +0.1, +0.3 UI (late) | 0.567 | 0.000 |

That is a clean bang-bang characteristic: the outputs are mutually exclusive
and flip sign through zero. They fire about once per data transition: the
duty is 0.57, against a transition density of 0.533 in the measurement window.
That is one ~1 UI pulse per transition, slightly widened by the converter's
edges. Early clock gives
`down`, which slows the ring, which is the right direction. **PD current
580 µA**, against 2563 µA for the frozen PD in P0.

- *Bug caught here:* the first `cml_xor` had its drains swapped and computed
  XNOR. Waveform dumps showed the flops were right and the XOR inverted; fixed
  in `cells.py`.
- *Negative result, unexplained:* the **original** `alexander_phase_detector`
  is not usable as a reference in this open-loop bench. Its edge flop (`x1`)
  sits at exactly 0 V for the whole run, which is the latch's both-low illegal
  state, apparently entered from the operating point. In the real closed loop
  it evidently works, since the frozen design locks. The polarity was therefore
  checked from the netlist logic instead (down = Q5⊕B, up = Q2⊕B, the same
  wiring as the frozen PD). `WITH_ORIGINAL` in `gen_cml.py` re-enables it.

**C2, can the ring drive the PD directly?** **No.** With the CML PD and the two
clock converters hung straight on the ring taps (no buffer), the ring tops out
at **~555 MHz** (508.5 / 539.7 / 549.8 / 549.6 / 554.6 MHz at `vctrl` 0.75 …
0.95 V). Unloaded it makes 602 MHz at 0.791 V and is RC-limited above ~0.83 V
(§20b), so it had ~2 % of headroom and the extra gate load takes ~10 %.

**C2, sweeping the `diff_amp_inv` tail gate** (one buffer, `vctrl` = 0.791 V).
With the buffer, the ring runs at 606–610 MHz again. The existing two-stage
`diff_amp_inv` only works as a variable-strength buffer in a narrow window:

| `vtail` (V) | buffer (µA) | clock at the PD, diff pp | `ck` range (V) | PD (µA) | verdict |
|---|---|---|---|---|---|
| 0.55–0.70 | 2–35 | ≤ 0.09 | stuck high | 583–585 | no clock |
| 0.75 | 72 | 0.22 | 1.55–1.66 | 580 | too weak |
| 0.80 | 131 | 0.46 | 1.33–1.57 | 583 | works, CM high |
| **0.85** | **212** | **0.78** | **1.03–1.43** | 567 | **chosen** |
| 0.90 | 311 | 0.70 | 0.80–1.15 | 502 | clock CM too low, PD starts to starve |
| 0.95–1.3 | 414–612 | collapses | ≤ 0.74 | 176–237 | second stage saturates |
| 1.8 (frozen) | 534 | 3.33 | 0.12–1.79 | 506 | works, full current |

**C3, closed loop** at `vtail` = 0.85 V: locks, numbers above.

## Jitter (C4) — the C27 measurement on this chain

C4 is C3 run for 6 µs. Like C27, it dumps the recovered clock together with
the CTLE output pair, and `../c27_analyze.py` measures them against the ideal
bit grid. The clock analysed is `rclk_p`, the `cml2cmos` output; C27 analysed
the frozen design's `rclkp` (`inverter_buffer`), which is the same position in
the chain.

**The loop is not settled at 4 µs, so C27's window cannot be reused.** The
`vctrl` averages are 0.8326 V (3.9–4.0 µs), 0.7911 V (4.9–5.0 µs) and 0.7878 V
(5.8–5.9 µs): a 41 mV move, then 3.3 mV. Analysed from 4 µs, the run shows 5
cycle slips. The table therefore uses the window from 5 µs (601 edges):

| | frozen (§C27, from 4 µs) | CML (C4, from 5 µs) |
|---|---|---|
| mean period | — (601.05 MHz in P0) | 1664.87 ps (−0.008 % UI) |
| period RMS (`c27_analyze.py`'s "cycle-to-cycle") | 18.45 ps = 1.11 % UI | **46.16 ps = 2.77 % UI** |
| true cycle-to-cycle RMS, adjacent periods (`edge_steps.py`) | 12.63 ps = 0.76 % UI | 24.86 ps = 1.49 % UI |
| period pk-pk | 111.5 ps = 6.70 % UI | 292.8 ps = 17.58 % UI |
| sampling-phase error RMS | 199 ps = 11.96 % UI | 231.6 ps = 13.91 % UI |
| sampling-phase error pk-pk | 77 % UI | 76.8 % UI |
| eye at the sampling instant, mean | 181 mV | 162.3 mV |
| samples < 25 mV from threshold | 13 / 1201 (1.1 %) | 11 / 601 (1.8 %) |
| `vctrl` ripple, settled 100 ns window | — | 115.6 mV pp |

**Hypotheses tested and ruled out:**

1. *"The CML PD fires up and down at once near lock."* At settled lock in C4,
   `up`/`down` duty is 0.481 / 0.504, summing to ~1.0. But the frozen design
   (P0 rerun with duty added, same 0.6–1.0 µs window as C3) shows
   **0.371 / 0.573, summing to 0.94**, against the CML design's 0.237 / 0.299
   in that window. The frozen PD is *more* active, not less, so activity does
   not explain the difference.
2. *"The 18 µA `up`/`down` converters add loop latency."* C3 rerun with
   `c2c_Wt=3` (56 µA per converter): ripple **220.5 mV pp**, worse rather than
   better (188.3 at `c2c_Wt=1`). Converter drive is not the lever.

3. *"The CML ring locks on a steeper part of the VCO curve."* K1 (2026-10-11)
   swept `vctrl` 0.770–0.820 V in 5 mV steps, open loop, against the same
   sweep of the frozen clock path (`../power/decks/K1_kvco_frozen.spice`,
   P3 with a finer `foreach`):

   | vctrl (V) | 0.770 | 0.775 | 0.780 | 0.785 | 0.790 | 0.795 | 0.800 | 0.810 | 0.820 |
   |---|---|---|---|---|---|---|---|---|---|
   | frozen (MHz) | 589.8 | 593.5 | 596.8 | 599.6 | 602.2 | 604.3 | 606.2 | 608.9 | 610.4 |
   | CML, `vtail` 0.85 (MHz) | 596.9 | 600.2 | 603.2 | 605.7 | 607.9 | 609.8 | 611.3 | 613.5 | 614.5 |

   Neither curve has a sharp knee; both flatten smoothly. The CML ring is
   ~6 MHz faster at equal `vctrl`, so it reaches 601 MHz lower on the curve,
   where Kvco is ~0.65 MHz/mV against ~0.55 for the frozen ring at its own
   601 MHz point: ~20 % more gain, not the 2.5x in jitter.

**Where the cycle-to-cycle jitter is NOT coming from: `vctrl`.** In C4's settled
window (5–6 µs), `vctrl` minus its own one-UI moving average is only 1.7 mV
RMS. At ~0.65 MHz/mV that is under ~3 ps of period change per cycle, against
46 ps measured. The cycle-to-cycle jitter must enter after the ring: the
weakened buffer, the `cml2cmos` converters, or data-dependent kickback from the
PD's latches onto a clock line driven by a 212 µA buffer. The *slow* `vctrl`
wander is real and larger than the frozen design's (C4 116 mV pp vs C27 62 mV
pp, same 5.8–5.9 µs window, same loop filter and charge pump); it moves on a
20–90 ns time scale (autocorrelation crosses zero at ~20 ns) and plausibly
explains the worse sampling-phase error, which is a separate problem.

**J1 (2026-10-11): the clock path is clean -- the jitter is `vctrl`.** Open
loop, ideal `vctrl` 0.79 V, 400 ns at a 5 ps step, CML PD fed PRBS7
(`J1_clkjit_dai`) or constant data (`J1_quiet_dai`); `j1_analyze.py`, rising
edges from 60 ns:

| point | PRBS data, c2c RMS | constant data |
|---|---|---|
| ring tap (`t7`−`t8`) | 0.00 ps | 0.00 ps |
| buffer out (`ck`−`ckb`) | 0.53 ps | 0.00 ps |
| `rclk_p` (`cml2cmos`) | 0.90 ps | 0.00 ps |

Data-dependent kickback from the CML latches onto the weak clock line is real
but ~1 ps: it is not the 46 ps.

**Then where?** `c27_analyze.py` labels `pstdev(period)` as "cycle-to-cycle".
It is period jitter, which is exactly what slow `vctrl` wander produces. Each
C4 period predicted from `vctrl` (averaged over that period, through the K1
curve) against the measured period: **correlation 0.972**, predicted RMS 37.0 ps
against 46.2 ps measured (the K1 curve is open-loop and loaded slightly
differently). Edge-time interpolation is not an artifact: the step straddling
every `rclk_p` crossing is <= 20 ps in both C4 and C27 (`edge_steps.py`), and
restricting to the finest steps does not change the result. The C27 1.11 % UI
figure quoted elsewhere as "cycle-to-cycle" is the same period-RMS metric.

So the CML design has **one** problem, not two: the loop's `vctrl` wanders
~2x more (44.5 mV RMS, 283 mV pp over 5–6 µs; 116 vs 62 mV pp in the
5.8–5.9 µs window). The charge pump and loop filter are identical, so the
difference is in what the PD tells the pump. The leading candidate: with R
~80 kΩ and 1.26 µA, a pump pulse puts ~100 mV across R at once. The frozen
PD's `up` and `down` overlap (duty sum 0.94 at a transition density of ~0.5),
and overlapping pulses cancel in the pump; the CML PD's are cleanly exclusive
(C1), so every decision lands as a full kick. Testing this needs `up`, `down`
and the C1 node saved in a settled closed loop, for both designs.

**A trap found along the way:** in C3's 0.6–1.0 µs window the loop is still
acquiring (`vctrl` moved 0.8115 → 0.7858 V within the window in the
`c2c_Wt=3` run). Ripple from that window mixes acquisition with dither, so
C3-vs-P0 ripple comparisons are suggestive at best. Only settled 6 µs runs
(~28 min each) compare jitter properly.

## Open items, in priority order

1. **Find the jitter mechanism.** Not yet tested:
   - the clock-path delay through the weakened `diff_amp_inv`, which is inside
     the loop: try `vtail` 0.8 against 0.9 at settled lock;
   - the PD's effective gain near the decision point. A 0.4 V-swing edge
     latch resolves less sharply than the frozen 1.2 V one; a larger
     `lat_Wt`/swing on the edge sampler (`x1`, `x3`) alone would test this;
   - a frozen-design 6 µs run with `up`/`down` duty recorded, to compare
     duty at settled lock rather than during acquisition.
2. **`vtail` = 0.85 V is an ideal source here.** On chip it needs a bias. The
   likely route is resizing the buffer tail so the existing 0.9 V `vbias` pad
   gives the same ~212 µA.
3. **The buffer is the stock `diff_amp_inv`, used far from its design point.**
   A single-stage CML buffer sized for this load would probably do the job for
   less than 212 µA, and would not have the collapse above 0.9 V.
4. **Nominal corner only.** The frozen design's PVT story (precharge 45/45,
   VCO reach, CTLE 27 corners) has not been repeated for any of this.
5. **Margin of the 0.4 V-swing logic** against mismatch and PVT is unknown.
   That margin is the reason the frozen latch swings 1.2 V.

## Reproducing

```bash
cd xschem/tuning/cml
./run_cml.sh                     # everything, sequentially, then the comparison
./run_cml.sh C3_chain_dai        # just the closed loop
VTAIL=0.8 ./run_cml.sh C3_chain_dai
./collect_cml.py dai             # re-print the comparison from results/
```

`collect_cml.py` needs `../power/results/P0_chain.log` (run
`../power/run_power.sh P0` once).

| deck | what | cost on this VM |
|---|---|---|
| C0_size | latch / level-shifted latch / XOR, DC, tail width 2–6 | seconds |
| C1_pd | 4 CML PDs at fixed clock phases, PRBS7 at CTLE levels | ~8.5 min |
| C2_ring_none | clock side, no buffer, `vctrl` sweep (5 points) | ~5 min |
| C2_ring_dai | clock side, one `diff_amp_inv`, `vtail` sweep (7 points) | ~6 min |
| C3_chain_dai | whole macro, closed loop, metered per cell | ~3.5–10 min |
| K1_kvco_dai | ring + one buffer at `vtail`, fine `vctrl` sweep, 10 points | ~17 min |
| J1_clkjit_dai, J1_quiet_dai | open-loop clock dump, PRBS / constant data; `./j1_analyze.py results/J1_prbs.raw` | ~4-5 min each |
| C4_jitter_dai | C3 for 6 µs, writes `C4_chain.raw`; then `python3 ../../c27_analyze.py C4_chain.raw 1.665 5000` in `results/` | **~28 min** |

| file | what it does |
|---|---|
| `cells.py` | the CML cells, sizes in one dict (`DEFAULT`) |
| `gen_cml.py` | netlists the frozen design (via `../power/gen_power.py`), writes the cells, the CML topology and the decks; `--set key=value`, `--variant`, `--vtail` |
| `run_cml.sh` | runs decks one at a time through `../safe_ngspice.sh`, then collects |
| `collect_cml.py` | C3 vs P0 table |
| `decks/`, `results/`, `.netlists/` | generated, gitignored |
