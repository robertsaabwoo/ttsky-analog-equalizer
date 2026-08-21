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

The **minimax alternative** of C10 (`Ldeg 3.0 / Wcap 21`) was run over the same
27 corners (`ac_corner_mm.spice`) so that switching to it needs no further
qualification: CTLE DC gain +6.93..+8.34 dB, boost +4.35..+5.97 dB, gain at
Nyquist +8.04..+11.40 dB. Equally PVT-stable — it simply over-equalizes the mild
1 pF channel on purpose (3.2-4.2 dB of ripple there), which is the price of
being right about a lossier one. Both sizings are qualified; pick by channel.

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

## C14. Open questions as of §C13 — ANSWERED in §C15, kept for the record

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

---

# The channel is the Tiny Tapeout pin itself

## C15. The answers, 2026-07-24

All of C14 is now settled by the user:

> "it is supposed to clean up a differential signal input, make it 600 Mb/s,
> abandon the LA_Limiter. Basically it should take whatever input that comes in
> and remove the inevitable noise that the low pass filter in the tiny tapeout
> pins will cause"

So:

1. **The channel is not external at all — it is the TT analog pin path.**
   `tinytapeout.com/specs/analog/` guarantees pad → user project is
   **< 500 Ω series and < 5 pF**. Not a placeholder: a specification, and a
   *bound*, so the design target is the bound.
2. **600 Mb/s confirmed** — UI 1.665 ns, Nyquist 300 MHz, same as the CDR.
3. **`LA_Limiter` is abandoned.** §C12's incompatibility is now moot; the block
   is out of the chain. Its files are untracked, so nothing to revert.

`info.yaml` asks for `analog_pins: 2` — `ua[0]`/`ua[1]`, the differential pair.
The rest of `info.yaml` is still the unfilled template.

## C16. This changes the answer completely: the eye is CLOSED at the pad

The three channels everything up to §C14 was measured against (500 Ω × 1/2/4 pF)
were all *milder* than the spec worst case. Lumping the full 5 pF at the CTLE
input — pessimistic, since the spec does not say how the C splits either side of
the R — gives a pole at **63.7 MHz**, which is **4.7× below Nyquist**:

| TT channel | pole | loss at 300 MHz | eye at the pad, 600 Mb/s, 200 mVpp in |
|---|---|---|---|
| 500 Ω / 5.0 pF (spec worst) | 63.7 MHz | −13.7 dB | **−5 mV / 0.000 UI — fully closed** |
| 350 Ω / 3.0 pF (mid) | 151.6 MHz | −7.2 dB | 114 mV / 0.555 UI |
| 200 Ω / 1.5 pF (optimistic) | 530.5 MHz | −1.6 dB | 198 mV / 0.870 UI |

**At the guaranteed worst case, 600 Mb/s NRZ does not survive the pin.** The eye
is not merely degraded, it is shut. This is the strongest possible argument for
the block: the CTLE is not an optimization here, it is what makes the link exist.
It also means the old `Ldeg 1.5 / Wcap 18` point was tuned for the wrong channel —
on the real one it recovers only 46 mV / 0.090 UI.

The ISI is linear, so a linear equalizer genuinely inverts it — a closed eye at
the pad is recoverable, unlike one closed by noise or by a nonlinearity.

## C17. Retuned against the real channel

`ladder_tt.spice` (45 sizings × 3 TT channels, one AC run) then four eye runs,
`eye_tt.spice` → `eye_tt6.spice`. Two things the ladder got *wrong* and only the
eyes got right, both worth remembering:

- **Ripple is the wrong metric once the channel cannot be flattened.** The
  ripple-optimal sizing on the 500 Ω/5 pF channel (`Ldeg 12`) gives an eye of
  114 mV / 0.295 UI; the eye-optimal one gives 232 mV / 0.430 UI while scoring
  *worse* on ripple. When the residual is several dB no matter what, minimizing
  it stops correlating with the eye. Rank by eye directly.
- **The optimum was outside the first grid.** The `Ldeg ≤ 3.0` range inherited
  from §C10 topped out at 0.355 UI. Extending to 5.0 found 0.430 UI; 6.0/8.0/12.0
  then fall off again. Always probe past the edge of a flat-topped optimum.

Final sizing, and how it got there:

| axis | from | to | why |
|---|---|---|---|
| `Win` | 10 | **20** | boost is capped by gm·Rdeg, so gm is the lever. Saturates here — Win 30 and 40 buy ≤ 0.005 UI for 2× the current and input cap (`eye_tt4.log`) |
| `Lload` | 20 | **20** | unchanged |
| `Ldeg` | 1.5 (854 Ω) | **5.0** | the whole point: far more degeneration than the 1 pF channel wanted |
| `Wcap` | 18 | **18** | unchanged — 324 µm² of MIM, same as before |

Eyes at 600.6 Mb/s, 200 mVpp differential at the source:

| | old point (Win 10 / Ldeg 1.5) | **final (Win 20 / Ldeg 5.0)** |
|---|---|---|
| 500 Ω / 5.0 pF | 46 mV / 0.090 UI | **232 mV / 0.430 UI** |
| 200 Ω / 1.5 pF | 651 mV / 0.755 UI | 407 mV / 0.745 UI |

**5× the height and 4.8× the timing margin on the channel that matters**, paid
for with swing on the optimistic channel that was never in short supply. Supply
current is ~180 µA per stage.

Where the previous ceiling estimate was wrong: §C10 said this topology tops out
at ~5-6 dB of boost. With `Win 20` and `Ldeg 5.0` it delivers **+6.3..+7.9 dB
across all 27 PVT corners**. The ceiling was an artifact of the sizing range
swept, not of the topology. The §C10 statement "a channel losing more than ~6 dB
at Nyquist cannot be flattened by one stage" is **withdrawn** — one stage undoes
13.7 dB of tilt here, near-exactly at the Nyquist point.

## C18. PVT on the real channel: 27 corners, and it is remarkably flat

`ac_corner_tt.spice` → `ac_tt_{tt,ss,ff}.spice`, read by `cornerreport.py`.
tt/ss/ff × −40/27/125 °C × 1.62/1.8/1.98 V, all against 500 Ω / 5 pF:

| | min | max | spread |
|---|---|---|---|
| CTLE DC gain | +5.59 dB | +6.51 dB | 0.9 dB |
| **CTLE boost** | **+6.30 dB** | **+7.90 dB** | 1.6 dB |
| CTLE gain at Nyquist | +11.71 dB | +14.40 dB | 2.7 dB |
| combined channel+CTLE at Nyquist | −2.03 dB | +0.66 dB | 2.7 dB |

Worst corner is `ss / 125 °C / 1.62 V`, best is `ff / −40 °C / 1.98 V`. The
combined response at Nyquist stays within ±2 dB of flat over the entire corner
box — the CTLE's 13.55 dB of gain at Nyquist very nearly cancels the channel's
13.7 dB of loss, by construction. As in §C6 the tail device sitting in triode
(§C3) is what buys this stability.

Note this is qualified against a *fixed* worst-case channel. The pin RC is not a
PVT axis we control — it is whatever the shuttle gives us, bounded by the spec.
The optimistic-channel column of §C17 is the check that the same sizing does not
over-equalize if the real pin turns out to be better than the bound: it does not,
0.745 UI there.

## C19. Two stages: tried, rejected

`eye_tt2.spice` cascades two CTLEs (`ctle_f.inc` exists for this — same topology
with *subckt* parameters, so two instances can be sized differently).

| on 500 Ω / 5 pF | height | width |
|---|---|---|
| one stage | 243 mV | **0.340 UI** |
| two identical stages | **560 mV** | 0.240 UI |
| boost then gain | 254 mV | 0.285 UI |

The cascade **doubles a swing we already have enough of and gives up 0.10 UI of
timing margin** — and timing margin is the scarce quantity for the CDR's
Alexander phase detector, not amplitude. Rejected.

It also stacks the common mode the wrong way: DC-coupled, stage 2 sees 1.23 V in
and settles at **0.72 V out**, below the 1.0-1.1 V optimum of §C7 and heading for
the cliff. Any future cascade needs AC coupling or a level shift between stages.

(The upside, if a second stage is ever wanted for another reason: driven hard it
limits, so it would subsume what `LA_Limiter` was for.)

## C20. State

`CTLE_tune.sch` now holds `Win 20 / Lin 0.3 / Lload 20 / Ldeg 5.0 / Wcap 18`.
Netlisted through `subckt_src.sch` and re-simulated (`verify_sch.spice`) it
reproduces the deck exactly: **+6.19 dB DC, +7.14 dB boost, +13.32 dB at
Nyquist, −0.43 dB combined** at tt/27 °C/1.8 V — 0.01 dB agreement.

`xschem/CTLE.sch` is **still untouched.** The channel question that was blocking
promotion is answered, so promoting is now a decision about *when*, not *what*.

### New files

| file | what |
|---|---|
| `ladder_tt.spice` | 45 sizings × 3 TT channels, one AC run (`ladderreport.py … "500/5p,350/3p,200/1.5p"`) |
| `eye_tt.spice` | 6 sizings × 3 TT channels, eyes |
| `eye_tt2.spice` | one stage vs two, worst + optimistic channel |
| `eye_tt3.spice` | fine sweep, Ldeg 2.2-4.0 × Wcap 21-27 |
| `eye_tt4.spice` | the `Win` axis (30, 40) — saturated |
| `eye_tt5/6.spice` | past the edge of the grid: Ldeg 4-8 × Wcap 15-21. `eye_tt5` found the optimum |
| `ctle_f.inc` | CTLE with *subckt* params, for cascades |
| `ac_corner_tt.spice` → `ac_tt_{tt,ss,ff}.spice` | 27 corners on the worst TT channel |
| `cornerreport.py` | reads those; reports CTLE-alone boost and combined @Nyq |
| `verify_sch.spice`, `ctle_tune_sch.inc` | schematic-vs-deck cross-check |

### One more tool trap

- **`shell echo` tags can land mid-line.** ngspice's transient progress output
  (`Reference value : …`) has no trailing newline, so a `shell echo "#EYE …"`
  tag gets appended to the *end* of that line and `eyemetrics.py`'s
  `line.startswith("#EYE")` never fires — the log looks fine to the eye and
  parses as zero blocks. Emit a blank `shell echo ""` first, or clean with
  `sed 's/.*#EYE/#EYE/' raw.log | grep -v "Reference value"` (what the `*_clean.log`
  files are).

## C22. Eye across PVT — the check C18 could not make

C18 qualified the corners in **AC**, which is not the same as qualifying the eye:
gain in dB does not map linearly onto an opening in mV, and the group-delay
change over corners moves the sampling phase. `eye_pvtc_{worst,best}.spice` run
the actual PRBS7 eye at the two extremes of the box, on 500 Ω / 5 pF:

| corner | eye height | eye width | output CM |
|---|---|---|---|
| `ss / 125 °C / 1.62 V` (worst) | **174 mV** | **0.350 UI** | 1.149 V |
| `tt / 27 °C / 1.8 V` (nominal) | 232 mV | 0.430 UI | ~1.27 V |
| `ff / −40 °C / 1.98 V` (best) | 273 mV | 0.485 UI | 1.511 V |

**The eye never closes.** Worst case is still 174 mV into a slicer and 0.350 UI
of timing margin — that is the number to design the rest of the chain against,
not the 0.430 UI of C17.

The thing this exposes that AC could not: **the output common mode moves 362 mV
over the corner box** (1.149 → 1.511 V). Anything DC-coupled to this output has to
tolerate that swing, and per C7 the CTLE's own input CM optimum is a narrow
1.0-1.1 V — which is why the C19 cascade is a bad idea for a second reason.
`D2S_amp` is DC-coupled to this node and has never been checked against it.

### Trap: `reset` throws away `alter`, but keeps `alterparam`

The first version of this deck looped the corners inside `.control` with
`set temp = …` / `alter VDD = …` before a `reset`, and produced **identical
numbers for every corner** — no error, no warning. `reset` re-reads the circuit
from the parsed netlist, discarding instance `alter`s; `alterparam` changes the
parameter itself and does survive, which is why every earlier sweep in this
directory worked and made the bug easy to miss. The MOS corner appeared to work
(it comes from `.lib`), so only temperature and supply were silently ignored.
Corners are now one hardcoded deck each, with `.temp` as a netlist card.

If a sweep produces suspiciously identical results, check that what you are
sweeping is an `alterparam`, not an `alter`.

## C21. What is actually open now

1. **Promote into `CTLE.sch`?** The sizing is settled and PVT-qualified. This is
   two device widths, two resistor lengths and one rewire (delete `C1`, move `C2`
   to bridge the source nodes). Held only because `CTLE.sch` is the taped-out-path
   schematic and `../HANDOFF.md` §6 says the sandbox copy is the safe place.
2. **Input common mode.** §C7's cliff is unchanged and still costs ~1.3 dB at
   Nyquist. If `ua[0]`/`ua[1]` are AC-coupled at the board, bias at **1.05 V**
   rather than 0.9 V — free margin. Needs the board plan.
3. **`D2S_amp` is now the narrowest link** (§C12: 0.445 UI) and has never been
   tuned. With the CTLE delivering 0.430 UI on the worst channel these are
   comparable, so it is the next block worth measuring.
4. **Delete `LA_Limiter.sch/.sym`?** Abandoned per §C15. They are untracked, so
   deleting them is unrecoverable — left in place deliberately.
5. **Switchable boost** (§C14.4) is now much less compelling: the pin RC is a
   fixed spec, not a per-board unknown, and one sizing covers the whole
   500 Ω/5 pF → 200 Ω/1.5 pF range at ≥ 0.43/0.745 UI. Recommend dropping it.

---

# §C23. END-TO-END: CTLE + CDR locks through the pad LPF (the merge gate)

Session 2026-08-02. First time the CTLE and the CDR are simulated as **one loop**
— the §C12 chain check stopped at the CTLE output and never fed the CDR. This is
the gate the user set before promoting the CTLE to `main`.

## Setup

`tuning/e2e_ctle_cdr_tb.spice` + `tuning/e2e_blocks.inc`. The subckts were harvested
from a **fresh** netlist of `CDR_tune_tb.sch` (the stale untracked `CDR_tune_tb.spice`
had NO precharge x20 and the old dual-buffer clock — do not reuse it), so the CDR is
the validated design: variant-E clock (`single_inverter_tune`), `x20
vctrl_precharge_tune` on vctrl, the `_tune` PD hierarchy.

Chain: `200 mVpp diff 0101 @ CM 0.9 V → 500 Ω/5 pF pad LPF on BOTH legs → CTLE_tune
→ CDR_tune → recovered clock`. Small-signal input on purpose (C8: rail input is
8.5 dB compressed and EQ can't show). CTLE straight into the CDR, no limiter between
(user's choice — the point was to find out whether the CTLE's swing suffices).
Guarded run (`safe_ngspice.sh`, 3 GB / 1200 s), tran 20p 1500n, exit 0.

## Result — IT LOCKS (spec-worst channel, tt/27 °C)

| quantity | value | note |
|---|---|---|
| lock frequency | **600.64 MHz** | +0.006 % vs the 600.6 Mb/s data |
| vctrl (locked) | **0.791 V** | = the standalone lock point (§17e 0.792 V) → real lock |
| vctrl dither | 33 mV pp | healthy bang-bang |
| recovered clk swing | **1.870 V** | rail-to-rail (a dead VCO reads ~5 mV) |
| precharge release | 126.5 ns | fired normally |
| data at CTLE input | 63.7 mV pp diff | pad LPF crushed 200 mVpp → 64 mV (eye ~closed at the pad) |
| CTLE output | **299 mV pp diff** | equalized back up ~4.7× (+13.5 dB) |

The physics closes: channel loss at Nyquist ~13.7 dB, CTLE gain at Nyquist ~13.5 dB
(§C18), net ≈ flat, and the CDR locks at the **same** vctrl/frequency it reaches with
ideal full-rail data. The CTLE's 299 mV differential was enough to drive the
Alexander PD — better than the static-eye estimate (§C22 232 mV / §12a's ~0.5 V
latch threshold) suggested, because the PD samples the boosted transition swing.

## What this does and does NOT establish

**Does:** the CTLE is the enabler — a signal that is ~closed at the pad (64 mV) is
equalized to a swing the CDR locks on, end to end, at 600.6 MHz. The two blocks are
compatible as-drawn (CTLE out CM 1.265 V into the CDR data input) with no limiter.

**Does NOT yet cover (before merge):**
- only `rclk+` (rclkp) was `meas`'d; `rclk-` is complementary by the variant-E
  inverter construction (§13h sum 1.796 V) but was not explicitly measured here —
  add a `meas` on rclkm next run;
- one power-up data polarity only (the precharge makes cold start
  polarity-independent §17e/f, but the e2e case was not run both ways);
- a 0101 clock pattern, not PRBS/CID — real data with runs (§16e covered CID for the
  CDR alone with ideal data, not through the CTLE);
- tt/27 °C only — no PVT on the combined loop;
- 200 mVpp input; sensitivity (smaller input) not swept.

Files: `tuning/e2e_ctle_cdr_tb.spice`, `tuning/e2e_parse.spice` (op/parse check),
`tuning/e2e_blocks.inc` (regenerate the CDR part from a fresh `CDR_tune_tb.sch`
netlist if the design changes).

---

# §C24. Closing the C23 gaps: real data (PRBS7) and the second clock phase

Session 2026-08-15. C23 left five things open before merge. This section closes
the first two and turns the third into a **new, load-bearing open question**.

## Setup

`tuning/e2e_prbs_tb.spice` + `tuning/e2e_prbs.inc` (1250-bit PRBS7 PWL from
`ctle/gen_prbs.py`, max run length 7 UI, verified). Same chain as C23 —
200 mVpp diff at CM 0.9 V → 500 Ω/5 pF pad LPF on both legs → `CTLE` → `CDR` —
but with **PRBS7 instead of 0101** and with `meas` on **both** recovered clock
phases. `tran 20p 2000n` (not 1500n: the halved transition density was expected
to slow acquisition). Analysis time **1451 s**.

## Result

| quantity | window | value | C23 (0101) |
|---|---|---|---|
| vctrl | 1.0-1.1 µs | 0.791 V | — |
| vctrl | 1.8-1.9 µs | **0.828 V** | 0.791 V |
| vctrl ripple | 1.8-1.9 µs | **161 mV pp** | 33 mV pp |
| rclk+ swing | 1.8-1.9 µs | 1.867 V | 1.870 V |
| rclk− swing | 1.8-1.9 µs | **1.929 V** | not measured |
| rclk+ + rclk− , mean | 1.8-1.9 µs | 1.794 V | — |
| rclk+ + rclk− , pk-pk | 1.8-1.9 µs | **2.201 V** | — |
| rclk+ mean / rclk− mean | 1.8-1.9 µs | 0.619 V / 1.175 V | — |
| data at CTLE input | 1.8-1.9 µs | 172 mV pp diff | 63.7 mV (0101) |
| CTLE output | 1.8-1.9 µs | 636 mV pp diff | 299 mV (0101) |
| precharge release | — | 126.6 ns | 126.5 ns |

(The CTLE input/output swings are larger than C23's because PRBS7 contains long
runs; a run of 7 lets the pad LPF settle to the rail, so the pk-pk over the
window is the *low-frequency* swing, not the Nyquist swing C23 measured on 0101.
These two numbers are not comparable — do not read 636 mV as "the CTLE got
better".)

## GAP 1 — CLOSED: rclk− exists, but it is not an instantaneous complement

rclk− is real, rail-to-rail (1.93 V), and complementary **on average**: the sum
of the two phases has a mean of 1.794 V, reproducing §13h's 1.796 V.

But the mean was hiding the shape. **The sum swings 2.20 V pk-pk**, and the two
phases have very different duty cycles — rclk+ sits high ~33 % of the time,
rclk− ~61 %. They do not sum to 100 %, so there is both a duty-cycle error and a
non-overlap between them.

The cause is structural and was already on the open list as "proper differential
slicer" (§13f, HANDOFF §5): rclk− is not generated differentially, it is
`rclk+` pushed through `single_inverter` (`x12` in `CDR.sch`). It therefore
inherits that inverter's propagation delay and threshold offset. §13h's
average-sum check could never have caught this.

**Consequence for the chip:** rclk− is usable as a second output and it does
load the ring symmetrically, but it must NOT be documented as a clean
complement, and nothing should be built that assumes a 50 % duty cycle on
either phase.

## GAP 3 — the loop does NOT settle on PRBS7 within 2 µs

This is the important result, and it is a **negative** one.

At 1.05 µs vctrl is 0.791 V — exactly the standalone lock point (§17e) and the
C23 lock point. By 1.85 µs it has climbed to **0.828 V** and is dithering
**161 mV pk-pk**, 5× the 33 mV of C23. A bang-bang loop's lock voltage is set by
what the VCO needs to run at the baud rate, which is pattern-independent — so a
*different* vctrl at 1.85 µs than at 1.05 µs means the loop is still moving, not
that PRBS has a different lock point. **It is still acquiring at 2 µs.**

The mechanism is credible: PRBS7 has ~50 % transition density against 0101's
100 %, so the Alexander PD issues roughly half as many corrections per unit
time, and its runs of up to 7 identical bits leave the charge pump unattended
for ~11.7 ns at a stretch. The loop filter was deliberately shrunk ~10× (§16) to
make acquisition possible at all — that same high loop bandwidth is what lets
vctrl wander so far during a CID run. **The §16 cap shrink and CID tolerance are
in direct tension, and §16e only tested CID for the CDR alone with ideal
full-rail data.**

### Trap: `meas ... RISE=<n>` measures wherever the n-th edge happens to be

The frequency numbers this run first produced (599.59 / 599.86 MHz) looked like
a slightly-low lock. They are not wrong, but they do not describe the window
everything else was measured in: `RISE=600` lands at 600 × 1.665 ns ≈ **1.00 µs**,
i.e. in the acquisition phase, while every other `meas` used 1800-1900 ns. Pick
the edge index from the time you want: `n ≈ t_window / UI`. The deck now measures
at RISE=1080/1140 and keeps the early pair as an explicit drift indicator.

## What is now open

1. **Does it lock on PRBS7 at all, and when?** Needs a longer transient (~3 µs,
   est. 35-40 min) with the corrected measurement windows. **This is the real
   merge gate now** — C23's "it locks" was established on a 0101 pattern, which
   is the easiest possible input for a bang-bang PD.
2. If it does not settle, the fix is a loop-filter re-balance: the §16 shrink was
   sized against 0101. Re-deriving it against PRBS is a design change, not a
   tuning tweak.
3. C23 gaps still untouched: **both power-up polarities** and **input
   sensitivity** (smaller than 200 mVpp). Both were deprioritised behind (1) —
   there is little point characterising sensitivity of a loop whose settling is
   unconfirmed.
4. PVT on the combined loop — still untouched.

Files: `tuning/e2e_prbs_tb.spice`, `tuning/e2e_prbs.inc` (generated),
`tuning/e2e_prbs.log`.

---

# §C25. The 0101 control, and a mechanism for the PRBS drift

Session 2026-08-15, batch `run_c25.sh` (four decks, 3 µs each).

## C25-A: the 0101 control settles perfectly

The A/B baseline §C24 lacked. Same chain, same corrected measurement windows,
alternating 0101 — and it is **locked beyond argument**:

| window | vctrl |
|---|---|
| 1.0-1.1 µs | 0.79139 V |
| 1.8-1.9 µs | 0.79160 V |
| 2.4-2.5 µs | 0.79150 V |
| 2.8-2.9 µs | 0.79160 V |

**0.2 mV of spread over 1.8 µs.** Ripple 33.7 mV. Frequency at 2.80-2.90 µs is
600.577 MHz (rclk+) / 600.523 MHz (rclk−) against 600.6 Mb/s data — inside
0.02 %. Channel-in 63.7 mV pp, CTLE-out 298.3 mV pp.

Three things this establishes:

1. The corrected `RISE=1680/1740` windows work, so §C24's PRBS numbers are not
   a measurement artefact.
2. **The promoted real files reproduce §C23 exactly** (63.7 mV / 299 mV /
   0.791 V / 600.6 MHz) — an independent confirmation of the netlist-level
   promotion check.
3. `rsum_pp` is **2.218 V** here too, with rclk+ / rclk− means of 0.640 V and
   1.153 V — i.e. **the recovered-clock duty-cycle asymmetry of §C24 is present
   in a perfectly locked loop on the easiest possible pattern.** It is
   structural (the `single_inverter`), not a symptom of failing to settle.

## Mechanism for the PRBS drift — charge-pump mismatch integrating over CIDs

Derived from the netlist, no simulation needed. It predicts what C25-B should
show, so it is written down *before* that result, not after.

The phase detector is a textbook Alexander. Tracing `alexander_phase_detector`:
`x5` samples data on clk+ (call it `d[n]`), `x1` samples on clk− (the crossing
sample `e[n]`), `x2` and `x3` retime both by one cycle (`d[n-1]`, `e[n]`), and
the two XORs give

    up   = d[n-1] XOR e[n]        (x7)
    down = e[n]   XOR d[n]        (x6)

**When there is no data transition, `d[n-1] == d[n]`, so `up == down`** — they
go high or low *together*, for the whole run of identical bits.

Now the charge pump (`tiny_pll_charge_pump`, the taped-out block):

    MNSW  gate = down   (nfet, W=0.5)
    MPSW  gate = upb    (pfet, W=1)  where upb = INV(up)   <- sky130_fd_sc_hd__inv_1
    MNSRC gate = bias_n (nfet, W=1  L=1)
    MPSRC gate = bias_p (pfet, W=2  L=1)

With `up == down == 0`: MNSW off, and `upb`=1 turns MPSW off. Neutral.
With `up == down == 1`: MNSW on, and `upb`=0 turns MPSW **on as well**. Both
legs conduct, and the net current onto the filter is the **up/down mismatch**
`Ip − In` — for the entire run.

So roughly half of all CID runs leak the mismatch current continuously. On
**0101 there are no runs at all**, which is exactly why every result up to §C23
looked clean.

Magnitude check: PRBS7's longest run is 7 UI = 11.7 ns; the integrating cap is
`cap1` = nfet W=4 L=0.6 at **mult=6** ≈ 14.4 µm² of gate ≈ 120 fF. Producing
§C24's 161 mV excursion needs

    I = C·ΔV/Δt = 120 fF × 0.161 V / 11.7 ns ≈ 1.7 µA

of net mismatch — entirely plausible for a pump whose two source devices are
W=1 nfet against W=2 pfet and whose UP path carries an extra inverter delay
(`upb`) that the DOWN path does not.

### What this means for the fix

**The charge pump must not be touched** — it is already taped out. So the
levers are:

1. **Increase `cap1`'s `mult`.** ΔV scales as 1/C for the same leaked charge.
   But §16 shrank this filter ~10× precisely to make acquisition possible at
   all, so this trades directly against acquisition. The right experiment is a
   `mult` ladder to find the smallest cap that both acquires *and* survives a
   7-UI run — §16 only ever bounded one side of that.
2. **Accept it if the phase error stays inside the eye.** vctrl wander is only
   fatal if it moves the sampling instant out of the 0.350 UI the CTLE delivers
   at the worst corner (§C22). That is a jitter question, not a vctrl question,
   and it has not been measured through the CTLE.
3. A run-length-limiting line code (8b/10b) would remove the mechanism outright,
   but that is a spec change, not a design fix.

Do **not** conclude "the loop filter is wrong" from §C24 alone — on this
analysis the filter is a victim of pump mismatch, and simply re-deriving it
against PRBS without understanding that would re-open the §16 acquisition
problem for no reason.

## C25-B: IT DOES SETTLE ON PRBS7 — §C24's conclusion was premature

The merge gate passes. §C24 stopped at 2 µs and reported "still acquiring"; it
had in fact caught the loop **at the peak of an overshoot**.

Full 3 µs, 391 s of analysis, `Reference value : 2.99999e-06` (i.e. it really
finished). The first two windows reproduce §C24 to **seven significant figures**
(0.7910886 V, 0.8281071 V; early frequency 599.5863 MHz — identical), so this is
the same trajectory continued, not a different run:

| window | vctrl | Δ from previous |
|---|---|---|
| 1.0-1.1 µs | 0.79109 V | — |
| 1.8-1.9 µs | 0.82811 V | **+37.0 mV**  ← where §C24 stopped |
| 2.4-2.5 µs | 0.80188 V | −26.2 mV |
| 2.8-2.9 µs | 0.79921 V | −2.7 mV |

That is a **damped ring, not a runaway**: +37, −26, −2.7 mV, converging on
~0.799 V against the 0101 case's 0.7916 V. Ripple decays the same way,
161 mV pp at 1.8-1.9 µs → **93.8 mV pp** at 2.8-2.9 µs. Frequency at the end is
600.24 MHz (rclk+) / 600.64 MHz (rclk−) against 600.6 Mb/s data.

**So the CDR does acquire on real data.** What PRBS7 costs, relative to 0101:

| | 0101 (C25-A) | PRBS7 (C25-B) |
|---|---|---|
| settled by | ~1 µs | ~3 µs |
| final vctrl | 0.7916 V | 0.7992 V |
| overshoot | none measurable | +37 mV |
| residual ripple | 33.7 mV pp | 93.8 mV pp |

Roughly **3× the acquisition time and 2.8× the residual dither**. Both are
consistent with the §C25 charge-pump mechanism — half the CID runs leak the
up/down mismatch onto the filter, which both slows convergence and sets a
dither floor — and the ~1.7 µA estimate there still stands as the thing to
confirm with `cp_mismatch.spice`.

### What is still open after this

The gate is passed, but two numbers are *not* yet established:

1. **Jitter through the CTLE.** 93.8 mV of residual vctrl dither is only fatal
   if it walks the sampling instant out of the 0.350 UI the CTLE delivers at the
   worst corner (§C22). vctrl dither is not the same as phase error, and the
   phase error has never been measured on this chain. **This is now the real
   remaining risk, not settling.**
2. The two phases disagree on frequency by 0.4 MHz (600.24 vs 600.64). Both
   come from the same oscillator, so that is not a real frequency difference —
   it is the §C24 duty-cycle asymmetry corrupting where each waveform crosses
   the 0.9 V measuring threshold. Harmless for the measurement, but another
   reminder not to treat rclk− as a clean complement.

### Operational note: foreground work slows the guarded background sim

C25-A took 1189 s and C25-B took 391 s for the *same* 3 µs span. The difference
is not the circuit — it is that during C25-A this session was concurrently
running full-hierarchy xschem netlisting, magic and netgen, and during C25-B it
was only writing files and running git. `nice -n 15` deprioritises the sim, so
interactive tool use steals from it by a factor of ~3. If a long run's wall time
matters, stay off the box.

## C25-C: data polarity — the gap-2 question is answered, the verdict flag is not

`vctrl` trajectories, deck B (normal) against deck C (data inverted):

| window | B (pol +) | C (pol −) |
|---|---|---|
| 1.0-1.1 µs | 0.79109 | 0.78839 |
| 1.8-1.9 µs | 0.82811 | 0.79190 |
| 2.4-2.5 µs | 0.80188 | 0.79410 |
| 2.8-2.9 µs | 0.79921 | 0.80100 |
| deltas (mV) | +37.0, −26.2, −2.7 | +3.5, +2.2, +6.9 |

**What C23 gap 2 actually asked is answered, and the answer is good:**

- precharge release **126.49 ns** (C) vs **126.56 ns** (B) — the startup cell is
  polarity-independent through the CTLE, exactly as §17e/f claimed for the CDR
  alone;
- `cin_swing` is **identical to four figures** (183.3 mV both) — the pad LPF and
  CTLE path are polarity-symmetric, as they must be;
- both runs converge into the same 0.799-0.801 V region.

Inverting the data cannot change *when* transitions happen, so the Alexander PD
should be indifferent to polarity — and in steady state it is. What differs is
the **acquisition path**: the first PD decisions after power-up have the
opposite sense, so B overshoots to 0.828 V and rings back down while C creeps up
from 0.788 V. Same destination, different route.

### The `STILL MOVING` flag on C is not trustworthy, and neither is C's frequency

Two measurement problems, both mine:

1. **The 5 mV verdict threshold is arbitrary** and is separating B (2.7 mV) from
   C (6.9 mV) on a difference that means little. C's deltas are +3.5, +2.2, +6.9
   — not a decaying sequence, so it is genuinely still moving, but "still moving
   by 7 mV while sitting 2 mV from where B settled" is not a failure.
2. **C's 602.58 MHz is inside the noise floor of its own measurement.** The VCO
   slope near lock is ~357 MHz/V (§20b: 514-621 MHz over ~0.65-0.95 V), so
   78.9 mV pp of `vctrl` ripple is **±14 MHz of instantaneous frequency**. A
   60-cycle (~100 ns) window cannot resolve a 2 MHz offset out of that. It is
   not evidence of a frequency error. (Deck A could resolve it — 33.7 mV of
   ripple, and it read 600.577 MHz against 600.6.)

**Fix for any future lock test: average over ~600 cycles, not 60.** Locked-ness
is a statement about the *average* rate matching the baud rate, and 100 ns is
simply too short a lever under this much dither. `RISE=1200` → `RISE=1800` costs
nothing extra and averages 10× better.

Do not edit `run_c25.sh` while the batch is executing — bash reads scripts
incrementally and will misbehave. Change it after.

## C25-D: input sensitivity — 200 mVpp is comfortable, 100 mVpp is marginal

Halving the source amplitude to 100 mVpp (C23 gap 5).

The **signal path scales linearly and cleanly**, which is itself worth having:

| | 200 mVpp (C25-B) | 100 mVpp (C25-D) | ratio |
|---|---|---|---|
| at CTLE input, after the pad | 183.3 mV | 91.6 mV | 2.00× |
| at CTLE output | 667.8 mV | 347.9 mV | 1.92× |

Exactly 2× at the input and near-2× at the output confirms the CTLE is
operating in its linear region at both levels, as §C8 claimed — no compression,
so equalisation is doing its job at both amplitudes. The recovered clock is
still rail-to-rail (1.870 V) and the precharge still releases at 126.5 ns.

**But the loop behaves noticeably worse:**

| window | vctrl |
|---|---|
| 1.0-1.1 µs | 0.79247 |
| 1.8-1.9 µs | 0.79509 |
| 2.4-2.5 µs | **0.83349** |
| 2.8-2.9 µs | 0.79779 |

That is not a drift and not a decaying ring — it is a **large low-frequency
wander**, +38 mV then −36 mV between adjacent windows, with `w4` landing back
near `w1`. The loop is tracking, not diverging, but it is swinging ±40 mV about
its lock point on top of 75.8 mV pp of ripple. Nothing like it appears at
200 mVpp.

Likely cause: at 348 mV differential the CTLE is handing the Alexander PD's
latches roughly half the swing they get at 200 mVpp. §12a measured only ~5 %
CML/inverter margin in `d_latch`, and §C23 noted the PD works better than the
static-eye estimate because it samples the *boosted transition* swing. Halve
that and occasional sampling errors become likely, each producing a burst of
wrong corrections — which is what ±40 mV of wander looks like.

**Sensitivity conclusion: 200 mVpp differential at the pad is comfortable;
100 mVpp is marginal.** The link works at 100 mVpp but with materially degraded
loop behaviour, so it should not be quoted as the sensitivity limit. Finding the
actual limit needs a ladder (150, 125 mVpp) — not run.

Caveat on all four `STILL MOVING` verdicts in this batch: they come from four
100 ns averages 400-900 ns apart, which is a very coarse probe of a loop that
wanders slowly. They are enough to rank B (quiet) against D (wandering), and not
enough for much else. §C26 measures phase error properly.

## C25-E: the charge-pump hypothesis is WRONG — measured, and it fails by 80×

`cp_mismatch.spice`, holding the pump output at the 0.791 V lock point:

| state | current |
|---|---|
| both legs OFF (`up=down=0`) | **44.9 pA** |
| UP only (`up=1, down=0`) | +1.263 µA |
| DOWN only (`up=0, down=1`) | −1.284 µA |
| **both ON (`up=down=1`, the CID case)** | **−20.6 nA** |

The structural half of §C25 was right: both-off is clean (45 pA), and both-on
does leave a residual. **The quantitative half was badly wrong.** The mismatch is
20.6 nA — **1.6 % of the leg current**, not the ~1.7 µA I predicted. Over a 7-UI
run on ~121 fF that moves vctrl by

    ΔV = 20.6 nA × 11.7 ns / 121 fF = **2.0 mV**

against the 161 mV actually observed in §C24. **The hypothesis accounts for 1.2 %
of the effect and is refuted.** The charge pump is well matched and needs no
defending; it is not the problem.

(It is also worth noting the mismatch changes sign across the range — +2.3 nA at
0.65 V, −20.6 nA at 0.791 V, −42.5 nA at 0.95 V — so the pump is perfectly
balanced somewhere near 0.66 V and slightly net-down at the lock point.)

### What actually sets the dither: bang-bang quantisation

The real mechanism is the ordinary one, and the numbers fall out immediately.
Each phase-detector decision dumps one leg's current for about one UI:

    ΔV per update = Icp × UI / C = 1.27 µA × 1.665 ns / 121 fF ≈ 17 mV

A bang-bang loop at lock hunts by ±1 update, so the expected ripple is ~2× that,
**≈ 35 mV pk-pk — against 33.7 mV measured on 0101 (§C25-A).** Inverting the
argument, the ripple implies an effective capacitance of 2.11 fC / 17 mV ≈
124 fF against 121 fF of `cap1` by geometry. The simple model lands on the
measurement.

So the dither is not a defect, it is the **quantisation step of a bang-bang loop
whose loop filter was deliberately shrunk ~10× in §16**. And PRBS makes it worse
for a reason that has nothing to do with the pump: during a run of identical bits
there are no transitions, so the loop is **blind** — phase error accumulates
uncorrected for up to 7 UI, and the loop then has to walk it back. That is the
standard CID penalty, and it scales with run length, which is exactly the 2.8×
seen between 0101 and PRBS7.

**Correcting the §C25 conclusion:** the lever is still `cap1`'s `mult` (bigger C
→ smaller step per update → less dither, at the cost of slower acquisition —
the §16 trade), but the reason is quantisation, not pump mismatch. Nothing about
the taped-out charge pump needs to change.

### The lesson

§C25 wrote down a mechanism from netlist topology alone, complete with an
order-of-magnitude estimate, and labelled it a prediction. The topology reasoning
survived; the magnitude was off by ~80×, because "both legs on" says nothing
about *how well matched* the legs are — and that is the entire quantity. Reading
a schematic tells you which effects exist, never how big they are.

---

# §C26. Jitter through the chain — partial, and the measurement needs redoing

Ran `e2e_c26_jitter.spice` (the C25-B chain with the recovered clock dumped) and
`jitter_parse.py`. 162 287 points, 1799 rising edges, 722 of them after 1800 ns.

## Cycle-to-cycle jitter — believable, and acceptable

| | value | as % UI |
|---|---|---|
| mean period | 1662.97 ps | — |
| ideal UI | 1665.00 ps | — |
| mean error | −2.03 ps | −0.122 % |
| period RMS | 24.59 ps | **1.48 %** |
| period pk-pk | 128.81 ps | **7.74 %** |

1.48 % UI RMS cycle-to-cycle is a plausible degradation from §16b's 0.68 % UI
for the CDR alone on ideal full-rail data — roughly 2×, for real data through a
channel that closes the eye at the pad. **This number is fine.**

## The phase-wander number is NOT usable as measured

The parser also reports 33.8 % UI RMS / 148 % UI pk-pk of phase error against a
best-fit constant-period clock. **Do not quote that.** Three problems:

1. **The window still contains settling.** `vctrl` is 0.8019 V at 2.4-2.5 µs and
   0.7992 V at 2.8-2.9 µs — still moving. Measuring accumulated phase over
   1.2 µs of a loop that is still converging measures the convergence, not the
   jitter.
2. **A best-fit constant-period clock is the wrong reference for a CDR.** The
   recovered clock is supposed to track the *data*; the correct reference is the
   ideal bit grid at 1665.00 ps, not a line fitted to the clock's own drift.
3. **Bang-bang CDRs have unbounded low-frequency phase wander by construction.**
   Accumulated phase against a free-running reference grows without limit; what
   matters for BER is phase error *relative to the data*, which the loop tracks
   out. A long window makes this look arbitrarily bad.

The −0.122 % mean period offset is ~2.2σ given the 24.6 ps spread over 721
samples (standard error 0.92 ps), so it is suggestive of a small residual
frequency offset but **not conclusive** — and it is confounded by (1) anyway.

## Deck bug: RISE=1800 does not exist

`meas tran e1800 WHEN v(rclkp)=0.9 RISE=1800` **failed** — there are only 1799
rising edges in the whole 3 µs run, because the clock does not start until the
precharge releases at ~126 ns. 3000 ns / 1.665 ns = 1802 UI *of data*, but the
clock gets ~1799 of them. So the 600-cycle averaging fix from §C25-C did not
actually execute this run. Use RISE ≤ ~1750, or better, derive the index from
`(t_end − t_release)/UI` rather than `t_end/UI`.

## What a correct jitter measurement needs

- a **longer run** (≥ 5 µs) so there is a genuinely settled span to measure in,
  with the analysis window starting well after `vctrl` stops moving;
- phase error referenced to the **ideal 1665.00 ps grid**, not a best fit;
- and the honest figure of merit is not raw phase wander but **how much of the
  0.350 UI eye (§C22) is consumed at the sampling instant** — which needs the
  data eye and the clock edge in the same measurement, not the clock alone.

`jitter_parse.py` computes both statistics correctly; it is the reference and
the window that are wrong, not the arithmetic.

# §C27. Jitter, measured properly — and the sampling phase is the real risk

`e2e_c27_jitter.spice` + `c27_analyze.py`. 6 µs, 324 663 points, 3601 rising
edges, 1201 of them in the settled window (4.0-6.0 µs).

This is the run §C26 asked for. All three of its defects are fixed: the window
is genuinely settled, phase is referenced to the ideal 1665.00 ps bit grid
rather than a best-fit clock, and the CTLE output is dumped alongside the clock
so the eye consumed at the sampling instant can be measured directly.

**A trap on the way in:** `e2e_prbs3u.inc` is 1850 bits = 3.08 µs, and a PWL
source holds its final value forever. Running 6 µs against it would have gone
flat DC at the halfway point, blinded the loop, and produced a confident jitter
number that was really a measurement of the data source running out.
Regenerated at 3700 bits (`e2e_prbs6u.inc`). Added to `docs/SIMULATION_TRAPS.md`.

## Settling — proven inside the deck this time

| window | vctrl |
|---|---|
| 3.9-4.0 µs | 0.79327 V |
| 4.9-5.0 µs | 0.79968 V |
| 5.8-5.9 µs | 0.79384 V |

Non-monotonic and spanning 6.4 mV against 61.8 mV pp of residual ripple in the
same window: this is dither, not drift. Contrast §C26, where the two windows
moved monotonically and the "jitter" measured was partly convergence.

Frequency over 1000 cycles inside the settled span: **600.666 MHz** against
600.6006 Mb/s data, +0.011 %.

## Cycle-to-cycle jitter — better than §C26 reported

| | value | % UI |
|---|---|---|
| mean period | 1665.08 ps | +0.005 % error |
| period RMS | **18.45 ps** | **1.11 %** |
| period pk-pk | 111.50 ps | 6.70 % |

§C26's 24.59 ps / 1.48 % was measured across a window that still contained
settling. In a genuinely settled window it is 18.45 ps / 1.11 %. **Quote this
number, not §C26's.**

## Phase wander — real, and it is not a measurement artifact

| | value | % UI |
|---|---|---|
| phase RMS vs the ideal grid | 199.08 ps | **11.96 %** |
| phase pk-pk | 1286.25 ps | **77.25 %** |
| linear ramp across the window | −26.60 ps | −1.60 % |
| detrended RMS | 198.94 ps | 11.95 % |

The detrend is the check that this is not §C26's mistake in a new form: if a
residual frequency offset were inflating the number, removing the linear ramp
would collapse it. It does not — 199.08 → 198.94 ps. The wander is genuine
bang-bang dither.

Mechanism, and it is consistent with what was already measured: 93.8 mV pp of
`vctrl` ripple (§C25-B) on a 357 MHz/V oscillator is ±16 MHz of instantaneous
frequency, ±2.7 % of 600 MHz. Phase accumulates fast at that swing.

## The number that actually matters: the eye at the sampling instant

|v(coutp)−v(coutm)| interpolated at each of the 1201 settled clock edges:

| | value |
|---|---|
| mean | 181.46 mV |
| 1st percentile | 23.91 mV |
| minimum | **2.51 mV** |
| samples below 25 mV | **13 of 1201 (1.1 %)** |
| samples below 50 mV | 58 of 1201 (4.8 %) |

**This is a worse answer than the project has been assuming, and it is the
honest one.** A sample near 0 mV means the clock edge landed on a data
transition rather than in the eye. About 1 % of samples land within 25 mV of
the decision threshold, which is where noise and comparator offset decide the
bit rather than the data.

Put against the eye budget: the CTLE delivers 0.350 UI at the worst PVT corner
(§C22), so ±0.175 UI of margin. Phase error is 0.120 UI RMS — the eye edge sits
at only ~1.46σ. That is not a comfortable link.

## What this does and does not say

- It does **not** say the design fails. This is the nominal corner, the eye is
  wide, and the loop tracks — frequency lock is exact to 0.011 % and there are
  no cycle slips (`c27_analyze.py` checks for duplicate grid slots and found
  none).
- It **does** say the margin is thinner than "it locks" implies, and that the
  residual `vctrl` ripple is not cosmetic: it converts directly into sampling
  phase error at 357 MHz/V.
- The obvious lever is loop-filter capacitance — more C means less ripple per
  bang-bang update and less phase dither, at the cost of acquisition time.
  §15 established that PLL-sized capacitors are too large to acquire at all, so
  there is a real optimum in between and it has not been searched.
- **Not done:** this is one corner and one pattern. The combined-loop PVT tier
  (T2) is still generated-but-never-run, and phase error at the ss/125 °C/1.62 V
  corner — where the eye is 0.350 UI rather than nominal — is unmeasured. That
  is the run that would decide whether this design closes.
