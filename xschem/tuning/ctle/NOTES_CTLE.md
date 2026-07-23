# CTLE — characterization and retune

Session 8, 2026-07-23. Sandbox for the CTLE, in the style of `../NOTES.md`.
The CDR thread is parked (see `../HANDOFF.md`); this file only covers the CTLE.

Everything here obeys the VM rules in `../../../CLAUDE.md`: all ngspice runs go
through `../safe_ngspice.sh`, sweeps happen *inside* one ngspice process with
`alterparam` + `reset`, and nothing writes a bare `.raw`. The heaviest run in
this file is a 211 ns transient that takes **20 s**.

---

## C1. There is only one CTLE, and it never had a testbench conclusion

`xschem/CTLE.sch` is **byte-identical on all seven branches**
(`main`, `CDR`, `custom_vco`, `cdr-shrunk-cap-jitter`, `added_third_d_ltch`,
`sim-lock-fake-caps`, `vctrl-clamp-fix`) and has exactly one commit in its
history, `cdf48d4 "initial commit of CTLE, with basic DLATCH 1:2 mux"`. So there
is no earlier/better variant hiding on another branch to recover.

What *does* differ between branches is the downstream and the testbenches:

| file | variation |
|---|---|
| `CTLE.sch` | none — identical everywhere |
| `CTLE_testbench.sch` | none — identical everywhere |
| `CTLE_WITH_LATCH.sch` | differs on `main` and `added_third_d_ltch`; plus a large **uncommitted** working-tree edit that strips the d_latch/demux tail down to CTLE → D2S_amp → inverter_chain |
| `D2S_amp.sch` | `main` / `added_third_d_ltch` carry a **wider** version (input pair W=10, tail W=20) vs. W=1/W=1 on the CDR branches |

`../NOTES.md:1007` recorded the CTLE as `UNTESTED | UNTESTED | deprioritized by
user; never characterized`. That was accurate.

## C2. Baseline: the "CTLE" has no peaking at all

`ac_base.spice` — differential AC drive at Vcm = 0.9 V, vbias = 0.9 V, 50 fF of
load on each output (the alexander PD's `d_latch` gates are W=5/L=0.15, so the
CDR presents ~25-40 fF; 50 fF is the conservative number used throughout).

```
DC gain            +10.35 dB   (3.293 V/V)
peak gain          +10.35 dB  @ DC          <-- no peak
boost (pk - DC)     +0.00 dB
-3 dB               0.72 GHz
```

Operating point, and the reason:

| quantity | value |
|---|---|
| Id per side | 89.3 µA (179 µA tail) |
| gm of M1 | 1.18 mS |
| Rload (`res_high_po W=1 L=16`) | **5.45 kΩ** |
| Rdeg (`res_high_po W=1 L=0.69`) | **597 Ω** — *not* 220 Ω; the head/contact resistance of a short `res_high_po` dominates |
| gm·Rs | 0.71 → max possible boost 4.7 dB |
| output CM | 1.313 V |

With Cs = 338 fF per side (`cap_mim_m3_1 W=13 L=13`, ~2 fF/µm²) the zero sits at
1/(2π·597·338f) ≈ **790 MHz**, and the output pole 1/(2π·5.45k·C_out) lands in
the same decade. **The zero and the pole cancel**, so the response is flat and
the circuit is a plain 10 dB differential amplifier, not an equalizer.

That is the whole bug. Both halves of it matter: the zero is an octave and a
half above Nyquist *and* gm·Rs is too small for much boost.

## C3. The load is a resistor, not a current source — and that is load-bearing

`bias2.spice`. The tail M2 (W=20/L=0.5, gate at 0.9 V) sits at **Vds = 38-65 mV
against Vdsat = 224 mV**, i.e. deep in triode, in every configuration tried.
There is no headroom to fix it: at Vcm = 0.9 V, body effect puts M1's Vgs near
0.78 V, which leaves the source nodes at ~0.12 V and the tail node at ~0.06 V.

Consequences, both directions:

- **Bad:** no real common-mode rejection, and the bias current is set by
  (Vcm − Vgs)/(Rdeg + Rtail_triode). See C7 — the gain falls off a cliff below
  Vcm = 0.9 V.
- **Good, and unexpected:** it makes the design *very* PVT-stable (C6), because
  both gm and the current move together and gm·Rs barely changes.

Do not "fix" the tail without first raising the input common mode; there is no
room for a saturated tail current source at Vcm = 0.9 V on a 1.8 V rail with
degeneration in the source.

## C4. The fix: one bridging cap instead of two caps to the tail

A cap `C` placed directly across the two source nodes looks like `2C` from each
source node to the differential virtual ground. So it buys **2× the effective
degeneration capacitance for half the MIM area — 4× the area efficiency** —
while leaving the DC path (Rdeg to the shared tail) untouched.

```
        as drawn                          retuned
   sp --[Rdeg]--+--[Rdeg]-- sm      sp --[Rdeg]--+--[Rdeg]-- sm
   sp --[Cs  ]--+--[Cs  ]-- sm      sp -----[ Cs ]----------- sm
                st                                st
   2 x 13x13 MIM = 338 um^2         1 x 18x18 MIM = 324 um^2
   Cs_eff = 338 fF per side         Cs_eff = 1.30 pF per side
```

Same area. Four times the effective capacitance. This is the single change that
makes a real zero affordable.

## C5. Chosen point and what it buys

Swept in `sweep2.spice` / `sweep3.spice` (Lload × Ldeg × Wcap, 24 + 27 AC points,
each sweep one ngspice process). Ranking metric is *ripple* — the worst deviation
of the **channel + CTLE** response from its own DC value anywhere in DC..Nyquist.
0 dB ripple means the channel has been exactly undone.

| | as drawn | **retuned** |
|---|---|---|
| Rload | `res_high_po W=1 L=16` (5.45 kΩ) | `W=1 L=20` (6.72 kΩ) |
| Rdeg | `W=1 L=0.69` (597 Ω) | `W=1 L=1.5` (854 Ω) |
| Cdeg | 2 × `cap_mim_m3_1 13×13`, each to tail | 1 × `cap_mim_m3_1 18×18`, bridging |
| CTLE DC gain | +10.35 dB | +10.31 dB |
| boost | +0.00 dB | **+2.35 dB** @ 290 MHz |
| ripple over DC..300 MHz | 3.71 dB | **0.75 dB** |
| gain at 300 MHz | +6.64 dB | **+9.78 dB** |
| output CM | 1.313 V | 1.265 V |
| MIM area | 338 µm² | 324 µm² |

Input pair, tail device and bias are **unchanged** — the retune is three
resistor/capacitor sizes plus one rewire.

## C6. PVT: 27 corners, all fine

`ac_corner.spice`, run at `tt`/`ss`/`ff` × −40/27/125 °C × 1.62/1.8/1.98 V.

| | min | max |
|---|---|---|
| CTLE DC gain | +9.20 dB (ss/125 °C) | +10.93 dB (ff/−40 °C) |
| boost | +1.83 dB | +3.03 dB |
| combined response at Nyquist | −1.17 dB | +0.14 dB |
| ripple | 0.71 dB | 1.13 dB |
| gain at Nyquist | +8.03 dB | +11.06 dB |

Worst corner is `ss / 125 °C / 1.62 V` and it still delivers +8.0 dB at Nyquist
with 1.1 dB of ripple. Nothing here needs a corner-specific fix. (Contrast with
the ring oscillator, whose temperature limit is a real accepted failure —
`../HANDOFF.md` §2.)

## C7. The input common mode is the real cliff — 0.9 V sits on its edge

`cmsens.spice`, tuned design, Vcm swept:

| Vcm | CTLE DC gain | boost | ripple | gain @ 300 MHz |
|---|---|---|---|---|
| 0.7 V | +5.39 dB | +0.80 dB | 2.42 dB | +2.91 dB |
| 0.8 V | +8.86 dB | +1.74 dB | 1.17 dB | +7.65 dB |
| **0.9 V** | +10.31 dB | +2.35 dB | 0.75 dB | +9.78 dB |
| 1.0 V | +10.96 dB | +2.70 dB | 0.89 dB | +10.79 dB |
| 1.1 V | +11.13 dB | +2.84 dB | 0.92 dB | +11.08 dB |
| 1.2 V | +10.42 dB | +2.65 dB | 0.75 dB | +10.16 dB |

The optimum is **1.0-1.1 V, not 0.9 V**, and below 0.9 V it degrades fast — at
0.7 V the equalizer is gone (0.8 dB of boost) and the gain has dropped 5 dB.
0.9 V is exactly on the shoulder. If the inputs are AC-coupled (so the CM is
ours to choose), bias them at 1.05 V: it is free, worth ~+1.3 dB at Nyquist, and
it moves the design off the cliff edge.

## C8. Large signal: linear to ~±300 mV, hard-limiting above ~700 mVpp

`dcxfer.spice`, differential in vs differential out at Vcm = 0.9 V:

| Vid (mVpp diff) | gain | compression |
|---|---|---|
| 200 | 3.25 | −0.06 dB |
| 400 | 3.18 | −0.25 dB |
| 600 | 3.05 | −0.62 dB |
| 800 | 2.86 | −1.18 dB |
| 1200 | 2.32 | −2.99 dB |
| 3600 | 1.23 | −8.5 dB |

**`CTLE_testbench.sch` and `CTLE_WITH_LATCH.sch` drive the CTLE with 0→1.8 V
rail swings on each input — 3.6 Vpp differential, which is −8.5 dB compressed.**
At that amplitude the pair is a limiter and equalization is meaningless: no
tuning of this block could have shown up in those testbenches. Any CTLE test
must use a small-signal input (≤400 mVpp differential is comfortably linear).
That is very likely why the block was never characterized successfully before.

## C9. Eyes: PRBS7 at 600.6 Mb/s, and the retune's actual worth

`eye2.spice` + `eyemetrics.py`. One 211 ns transient drives three RC channels in
parallel (500 Ω against 1p/2p/4p → poles at 318/159/80 MHz) from the same PRBS7
source, and each channel feeds both CTLEs, so all nine waveforms come from one
solve and are directly comparable. Input 200 mVpp differential, UI = 1.665 ns.
Eye height is measured against the *known* bit sequence: worst 1-sample minus
worst 0-sample at the best sampling phase.

| channel | at CTLE input | as-drawn out | **retuned out** |
|---|---|---|---|
| 1 pF (318 MHz) | 182 mV / 0.78 UI | 551 mV / 0.640 UI | **651 mV / 0.675 UI** |
| 2 pF (159 MHz) | 118 mV / 0.57 UI | 320 mV / 0.425 UI | **517 mV / 0.555 UI** |
| 4 pF (80 MHz) | 23 mV / 0.165 UI | **9 mV / 0.020 UI** | **154 mV / 0.250 UI** |

Read the last row carefully: on the lossy channel the as-drawn CTLE **closes the
eye** (9 mV over 0.02 UI — dead), while the retuned one hands the CDR 154 mV
over a quarter of a UI. That is the difference between a link that works and one
that does not.

On the mild 1 pF channel the retune is worth only +18 % of eye height, because
that channel costs just 2.8 dB at Nyquist. **How much this retune matters
depends entirely on what the real channel is** — which is the open question in
C11.

## C10. The boost ladder — and the hard limit of one CTLE stage

`ladder.spice` + `ladderreport.py`: 48 sizings, each evaluated against all three
channels in the same AC run (three channels, three CTLE copies sharing the swept
`.param`s). `eye3.spice` then measures nine of those sizings in eyes.

Eye height / eye width at 600.6 Mb/s, 200 mVpp in, Lload = 20 throughout:

| Ldeg / Wcap | 1 pF channel | 2 pF channel | 4 pF channel |
|---|---|---|---|
| **1.5 / 18** (chosen) | **651 mV / 0.675 UI** | 521 / 0.560 | 157 / 0.255 |
| 1.5 / 21 | 651 / 0.655 | 551 / 0.545 | 211 / 0.305 |
| 1.5 / 24 | 652 / 0.635 | **560** / 0.515 | 259 / 0.335 |
| 3.0 / 18 | 490 / 0.670 | 475 / 0.560 | 226 / 0.390 |
| **3.0 / 21** | 491 / 0.640 | 488 / 0.515 | **264** / 0.400 |
| 3.0 / 24 | 493 / 0.610 | 477 / 0.470 | 256 / 0.355 |
| 5.0 / 18 | 369 / 0.655 | 370 / 0.525 | 234 / **0.435** |
| 5.0 / 21 | 371 / 0.615 | 373 / 0.470 | 210 / 0.380 |
| 5.0 / 24 | 377 / 0.575 | 377 / 0.415 | 177 / 0.310 |

Two things fall out of this table.

**There is a hard ceiling.** The 4 pF channel loses 11.8 dB at Nyquist and this
topology can supply at most ~5-6 dB of boost, so the best *ripple* achievable on
it is ~4 dB — the channel cannot be flattened by one stage, only softened. The
reachable envelope is roughly: **a channel losing up to ~6 dB at Nyquist can be
equalized flat; beyond that this CTLE improves the eye a lot but does not undo
the channel.** Undoing more needs a second stage, not a bigger degeneration cap.

**The ranking inverts with channel loss**, so the sizing is a real choice:

- **mild channel → `Ldeg 1.5 / Wcap 18`** — tallest *and* widest eye on 1 pF, and
  still best-in-class on 2 pF. This is what `CTLE_tune.sch` holds, because the
  1 pF/500 Ω channel is the only channel actually specified anywhere in the repo.
- **unknown channel → `Ldeg 3.0 / Wcap 21`** is the minimax pick: within ~25 % of
  the best eye on every one of the three channels. It costs 160 mV of eye height
  on the mild channel to buy 107 mV on the lossy one.
- `Ldeg 5.0` only wins on eye *width* on the lossiest channel, and gives up a
  third of the height everywhere. Not worth it unless the channel is known bad.

Switching between these is one resistor value and one cap value. If the channel
is still unknown at tape-out, making Rdeg switchable (a second degeneration leg
gated by an NMOS off a spare `ui[]` pin) turns this table into a runtime knob —
see C13.4.

## C11. At 1 Gb/s the retune matters more, not less

The existing testbenches run 1 Gb/s (`PULSE … 0.5n 1n`). Re-running the eye
comparison at UI = 1 ns (`eye2_1g.spice`, Nyquist 500 MHz):

| channel | as-drawn | **retuned** |
|---|---|---|
| 1 pF | 319 mV / 0.400 UI | **480 mV / 0.450 UI** |
| 2 pF | 27 mV / 0.050 UI (closed) | **216 mV / 0.265 UI** |
| 4 pF | closed | closed |

So the retune is rate-robust: it is worth +50 % at 1 Gb/s on the mild channel and
it is the difference between closed and open on the 2 pF one. Nothing about the
choice of sizing changes if the rate turns out to be 1 Gb/s rather than 600 Mb/s
— but note that at 1 Gb/s *no* sizing in the ladder flattens the 2 pF channel
(best ripple ~4 dB), so 1 Gb/s over anything lossy would need a second stage.

## C12. Chain check: D2S_amp is fine, LA_Limiter is dead as drawn

`subckt_src.sch` netlists `CTLE_tune`, `LA_Limiter` and `D2S_amp` straight out of
xschem; `chain.spice` drives the real subckts with the PRBS through the 1 pF
channel. Eye at each node:

| node | eye height | eye width | levels |
|---|---|---|---|
| channel out (CTLE in) | 183 mV | 0.785 UI | ±96 mV |
| CTLE out (differential) | 651 mV | 0.800 UI | ±366 mV |
| **LA_Limiter out** | **77 mV** | 0.730 UI | +32 / −56 mV |
| D2S_amp out (single-ended) | 1348 mV | 0.445 UI | 0.30 V / 1.73 V |

- **`D2S_amp` works well.** It takes the CTLE's differential output and hands
  back a 1.43 V single-ended swing centred sensibly (balanced DC output settles
  at 0.952 V). Its 0.445 UI eye width is the narrowest link in the chain, so it,
  not the CTLE, is what limits timing margin downstream.
- **`LA_Limiter` does not work behind this CTLE.** Two independent reasons,
  both visible in the netlist and confirmed in simulation:
  1. It is a **PMOS** input pair with its tail PMOS from VDD. With the CTLE's
     1.265 V output common mode, its tail node settles at 1.784 V, leaving the
     input pair Vsg = 0.52 V — below threshold. The pair is off and both outputs
     sit at 5 and 9 mV, i.e. at VSS. A PMOS input stage wants an input CM around
     0.6-0.8 V; the CTLE delivers 1.265 V. These two blocks cannot be
     cascaded as drawn.
  2. Its load resistors are **mismatched**: `XR3 W=1 L=4` on `vout+` against
     `XR4 W=1 L=8` on `vout-` — a 2:1 asymmetry that would give a large static
     offset even if the pair were biased correctly. Almost certainly a typo.

  `LA_Limiter.sch` is untracked WIP with no testbench, so this is not a
  regression — it is what you will hit the moment you try to use it. Either
  rebuild it with an NMOS input pair (matching the CTLE's high output CM, as
  `D2S_amp` already does), or level-shift between them.

## C13. Files

| file | what |
|---|---|
| `ctle_p.inc` | parametrized copy of the as-drawn `CTLE.sch` |
| `ctle_p2.inc` | same, with the single bridging degeneration cap |
| `ctle_baseline.inc` | the as-drawn CTLE subckt, netlisted straight out of xschem |
| `ac_base.spice` | baseline AC + operating point |
| `bias2.spice` | headroom/bias table over Lload × Ldeg |
| `sweep1/2/3.spice` | design-space sweeps (`sweepreport.py` reads the run log) |
| `ac_corner.spice` → `ac_{tt,ss,ff}.spice` | 27 PVT corners |
| `cmsens.spice` | input-common-mode sensitivity |
| `dcxfer.spice` | large-signal differential transfer |
| `gen_prbs.py`, `prbs.inc` | PRBS7 stimulus, 127 bits at 600.6 Mb/s (regenerate for other rates) |
| `eye.spice`, `eye2.spice` | eye transients (`eyemetrics.py` reads them) |
| `eye2_1g.spice` | the same comparison at 1 Gb/s (regenerate `prbs.inc` with `ui=1n` first) |
| `ladder.spice`, `ladderreport.py` | 48 sizings × 3 channels in one AC run |
| `eye3.spice` | 9 sizings × 3 channels in eyes |
| `subckt_src.sch` | netlist-source only: emits the `CTLE_tune` / `LA_Limiter` / `D2S_amp` subckts into `chain_blocks.inc` |
| `chain.spice`, `chain_dc.spice` | CTLE → LA_Limiter / D2S_amp interface check |
| `CTLE_tune.sch/.sym` | **the retuned schematic** |
| `CTLE_tune_tb.sch` | GUI/CLI testbench for it; netlists and reproduces the deck numbers exactly (+10.31 dB DC, +2.35 dB boost, +9.78 dB at Nyquist) |

`CTLE.sch` itself is **untouched** — `CTLE_tune.sch` is the sandbox copy, per the
convention in `../HANDOFF.md` §6.

### Tool traps hit here (add to the `CLAUDE.md` list)

- **ngspice does not substitute `$var` inside a filename** — `wrdata sw_$a_$b.dat`
  swallows the separators into the variable name and silently writes a file
  called `q`. Sweeps must either write to one file per ngspice run, or `shell
  cat` a temp file into the run log and tag the blocks (what `sweepreport.py`
  parses).
- **`tran 10p 'tsim'` does not expand a `.param` inside `.control`.** It fails
  with "TSTOP is invalid, must be greater than zero". Hardcode the stop time.
- **ngspice's own `echo` and a `shell` child are buffered separately**, so an
  `echo` tag can land *after* the `shell cat` data it labels. Use `shell echo`
  for the tag so both go through the same pipe.
- `let` vectors made after `op` live in the op plot; a following `ac` switches
  the current plot, and `print` then reports "vector … has zero length". Print
  before the next analysis.
- **`.op` can return an asymmetric solution for a perfectly symmetric
  differential pair.** In `chain.spice` the operating point reported
  `v(coutp) = 1.423 V`, `v(coutm) = 1.098 V` — a fictitious 325 mV offset — while
  the same circuit settles at 1.265 V on *both* outputs when you let a transient
  relax into it (`chain_dc.spice`). The mean of the bogus pair is right, which is
  what makes it easy to believe. If a differential DC number looks wrong, settle
  it with a short `tran` + `meas … AVG` before trusting it.

## C14. Open questions — these gate the next round

1. **What is the real channel?** The `R = 500 Ω / C = 1 pF` model is inherited
   from `CTLE_testbench.sch` and looks like a placeholder. C9 shows the retune is
   worth +18 % on that channel and 17× on a 4 pF one. If the intended input is a
   pattern generator through coax into a TT analog pad, the true channel is far
   milder than any of these and the CTLE is close to unnecessary; if it is a long
   FR4 trace, we should push for more boost than the +2.35 dB chosen here.
   **C10 is the answer table** — pick the row that matches the channel; no
   further simulation is needed to change the sizing, only the two numbers.
2. **Confirm 600 Mb/s.** Everything above is at UI = 1.665 ns to match the CDR.
   The existing CTLE testbenches run 1 Gb/s (`PULSE … 0.5n 1n`) — stale, or a
   different intent?
3. **Input amplitude and common mode.** C7/C8 say: keep it under ~400 mVpp
   differential, and bias the CM at 1.05 V rather than 0.9 V if we control it
   (AC-coupled input). Both need the pad-level plan.
4. **Should the boost be made switchable?** Given (1) is unknown at tape-out, a
   digitally-selected Rdeg (a second degeneration leg gated by an NMOS switch off
   one of the free `ui[]` pins) would let the boost be dialled across the whole
   C10 ladder after silicon. It is a small addition and it converts an unknown
   into a knob. **Not built — this is a design change, not a retune, so it needs
   your call.**
5. **What follows the CTLE?** C12 says `D2S_amp` works and `LA_Limiter` cannot be
   cascaded with this CTLE at all. If `LA_Limiter` is meant to be in the chain it
   needs an NMOS input pair and matched loads; if it is abandoned WIP, say so and
   it can be deleted.
