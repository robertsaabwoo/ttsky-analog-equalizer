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
