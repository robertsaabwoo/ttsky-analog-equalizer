# VCO / CDR tuning log

All work here happens on **copies** in this directory — nothing under the main
`xschem/` tree has been touched. Copies are named with a `_tune` suffix and
reference each other (never the originals) so they're a fully independent
sandbox. Original files stay as documented in `../README.md`.

Files:
- `ring_inverter_tune.sch/.sym` — copy of `ring_inverter.sch/.sym`, values edited here.
- `ring_oscillator_tune.sch/.sym` — copy of `ring_oscillator.sch/.sym`, points at `ring_inverter_tune.sym`. Reuses the original `diff_amp_inv.sym` unchanged (found via xschem's library path).
- `ring_oscillator_tune_tb.sch` — copy of `ring_oscillator_tb.sch`, points at `ring_oscillator_tune.sym`, writes `vco_tune_tb.raw`, `tran` extended to 60n (was 30n) for better settling/period averaging at lower frequencies.
- `CDR_tune.sch/.sym` — copy of `CDR.sch/.sym`, points at `ring_oscillator_tune.sym`, and has the diff_amp_inv bias fix described below.
- `CDR_tune_tb.sch` — copy of `CDR_tb.sch`, points at `CDR_tune.sym`, writes `CDR_tune_tb.raw`, `tran` extended to 60n.

**Netlisting gotcha:** always `cd` into `xschem/` (not `xschem/tuning/`) and pass
`tuning/<file>.sch` as a relative path, e.g. `xschem -n -x -q
tuning/ring_oscillator_tune_tb.sch`. Running from inside `tuning/` directly
fails to find `xschemrc` and every `devices/*` symbol comes back "IS MISSING"
in the netlist. This is an xschem quirk, not a bug in the copies.

Also fixed a real bug in `xschem/simulation/check_swing.sh` (my own tool, not
a design file): ngspice's batch-mode exit code is non-zero even on a fully
clean `load` + `.measure` run (it flags "no `.tran`/`.dc` was run" as a
warning-level exit), which was aborting sweep scripts that used `set -e`. The
script now always exits 0; real problems still show up as `Error: measure
... failed!` text in its output.

## 1. Baseline sanity check

Before changing anything, netlisted+simulated the as-copied
`ring_oscillator_tune_tb.sch` (still `L=23` on the load resistors, `vctrl=0.9V`)
and confirmed it reproduces the original exactly:

```
vo+: pp=0.4049V  max=1.249V  min=0.844V  period=1.6647ns (600.7 MHz)
vo-: pp=0.4049V  (same period)
```

Matches the numbers in `../README.md`'s benchmark section bit-for-bit. Sandbox is trustworthy.

## 2. Target frequency

Inferred from `CDR_tb.sch`'s input stimulus (`PULSE(... 1.67n 3.33n)`, i.e. a
300.3 MHz square wave on `vin+`/`vin-`) and the "tuned closer to 300 MHz"
commit message already in this branch's history. Assuming **~300MHz center
frequency at nominal vbias=0.9V** is the goal — flag if that's wrong.

## 3. Load-resistor (R1/R2 of `ring_inverter`) sweep, vctrl=0.9V fixed

Swept `L` on both `res_high_po` load resistors (`W=1` unchanged) in
`ring_inverter_tune.sch` — this sets the per-stage RC delay and was the most
area-cheap knob available (no new devices, no topology change).

| R (L, µm) | vo+ pp (V) | period (ns) | freq (MHz) |
|-----------|-----------|--------------|------------|
| 23 (orig) | 0.4049    | 1.665        | 600.7      |
| 30        | 0.4008    | 2.007        | 498.2      |
| 35        | 0.3966    | 2.273        | 440.0      |
| 40        | 0.3920    | 2.549        | 392.4      |
| 46        | 0.3864    | 2.888        | 346.2      |
| **54**    | **0.3793**| **3.342**    | **299.2**  |
| 55        | 0.3785    | 3.399        | 294.2      |
| 56        | 0.3778    | 3.455        | 289.4      |
| 65        | 0.3720    | 3.956        | 252.8      |
| 80        | 0.3667    | 4.780        | 209.2      |

Frequency vs R is smooth and monotonic; swing degrades gracefully (~7% loss
going from L=23 to L=54, still healthy). **Chose L=54** — lands at 299.2 MHz,
within 0.4% of the 300.3 MHz target, at vctrl=0.9V.

Area impact: doubling+ a poly resistor's L from 23 to 54µm (both R1 and R2,
×5 stages = 10 resistors total) is a modest, well-understood area cost for a
passive — no new device count, should still be tiny-tapeout-friendly. Have
not run a physical area check (no layout done yet), just flagging that this
is the kind of change that's cheap to walk back if it turns out to matter.

**Applied to `ring_inverter_tune.sch`: R1/R2 L = 23 → 54.**

## 4. Control-voltage (Kvco) sweep at R=54

| vctrl (V) | vo+ pp (V) | vo+ max/min | freq (MHz) |
|-----------|-----------|-------------|------------|
| 0.3       | ~0 (3.5e-11) | —        | dead (not oscillating) |
| 0.5       | ~0 (1.1e-9)  | —        | dead |
| 0.7       | 0.237     | 1.161 / 0.924 | oscillating, but never crosses the 0.9V measurement threshold (min sits at 0.924V) — swing is real but reduced and DC-shifted up |
| **0.9**   | **0.379** | **1.24/0.86** | **299.2** (nominal/target) |
| 1.1       | 0.375     | —           | 315.4 |
| 1.3       | 0.374     | —           | 319.0 |
| 1.5       | 0.374     | —           | 320.8 |

**Finding — VCO has a hard dead zone below ~vctrl=0.5-0.6V:** the oscillator
doesn't just slow down at low control voltage, it stops entirely (tail
device M5 drops out of saturation / conduction). Above ~0.9V, frequency only
climbs slowly and saturates around 320MHz by vctrl=1.5V — the tuning range is
real but skewed almost entirely to the *high* side of the 0.9V nominal point,
and the *low* side is a cliff, not a gentle rolloff. This was already true in
the original (untuned) R=23 design too — it isn't something this resistor
change introduced, just something the sweep exposed.

## 5. `CDR_tune`: retuned VCO + diff_amp_inv bias fix, combined

`../README.md` documents a specific hypothesis for why `CDR_tb.sch`'s output
never swings: the outer `diff_amp_inv` (x4 in `CDR.sch`) has its tail-bias
pin wired to `vbias` (0.9V) while the working, identical stage inside
`ring_oscillator.sch` (x6) has the same pin wired to `Vdd`. Tested the fix in
`CDR_tune.sch`: changed the `lab_wire` at the x4 vctrl pin (originally
`lab=vbias`) to `lab=Vdd`, on top of using the retuned `ring_oscillator_tune`.

Result on `clk+`/`clk-` (the CDR's recovered clock output):

```
clk+: pp=5.9mV   max=0.964V  min=0.958V   (was pp=52mV, max=1.69V, min=1.64V before)
clk-: pp=5.2mV   max=0.963V  min=0.958V
```

The bias fix **did** move that stage's DC operating point from pinned-near-Vdd
down to sitting right at mid-rail (0.96V, very close to the 0.9V logic
threshold) — a real improvement in isolation. But the swing collapsed even
further (5-6mV vs 52mV), so on its own this fix does not produce a working
recovered clock either. Traced why:

```
x1.net1        (VCO control voltage, charge pump/loop filter output)  = 0.663V flat, pp≈0
x1.net4/net5   (ring_oscillator's own vo+/vo- feeding x4)             = pp≈32µV, ~1.042V flat
x1.x1.net7/net8 (raw ring-inverter core taps)                        = pp≈1.5µV, ~1.744V flat -- dead
```

**The ring oscillator core itself has completely stopped oscillating in this
run** — net1 (its control voltage) landed at 0.663V, which per the Kvco table
above is right in this VCO's dead zone. Compare: in the *original, unfixed*
CDR_tb run, net1 sat at ~1.7-1.76V (near Vdd, comfortably above the dead
zone, which is *why* the ring core there was still oscillating fine at
~600MHz even though the design overall didn't work).

**So the two changes interact badly:** fixing the diff_amp_inv bias changed
the loop's transient dynamics enough that the charge pump/loop-filter node
(net1) now settles into the VCO's dead zone instead of above it. This isn't
a sign the bias fix is wrong — it's a sign the deeper, actual blocker is the
**VCO's dead zone below ~0.6V control voltage**. A bang-bang/Alexander loop
with no valid feedback clock has no defined equilibrium; net1 will drift to
essentially whatever the charge pump's up/down asymmetry and leakage happen
to produce, and right now there's a real chance it drifts somewhere the VCO
can't run at all — which then starves the phase detector of any clock edges
to correct on, and it can never recover (no clock -> no correction -> stuck).

This looks like the actual root cause of "CDR doesn't work," ahead of (or in
addition to) the diff_amp_inv bias mismatch. A ring-oscillator-based
bang-bang CDR generally needs the VCO to keep oscillating (even if slowly)
across its *entire* reachable control-voltage range, precisely so the loop
always has something to lock onto no matter where it starts.

## 6. M5 (tail device) resize — you approved trying this

Swept M5's `W` (keeping `L=0.15`) at several vctrl values to find the
dead-zone edge:

| vctrl | W=3 (orig) | W=9 | W=20 | W=30 | W=40 | W=60 |
|-------|-----------|-----|------|------|------|------|
| 0.5   | dead | dead | dead | dead | dead | dead |
| 0.55  | —    | —   | —    | dead | dead | dead |
| 0.6   | dead | dead | dead | dead | dead (pp~2e-7) | alive but weak, pp=0.26V, no clean crossing |
| 0.65  | dead | **alive, pp=0.372V, 248.9MHz** | alive, pp=0.384V, 252.0MHz | — | — | — |

**Finding: widening M5 does not eliminate the dead zone, it only moves its
edge down slightly** (~0.7V -> ~0.65V with W=9, and even W=60 — 20x the
original width — still can't sustain oscillation at vctrl=0.55V). This is
consistent with the tail device being in subthreshold below its Vgs
threshold (~0.5-0.6V for this sky130 nfet): subthreshold current is
exponential in Vgs and only weakly affected by W, so no reasonable amount of
widening pushes the live region down to arbitrarily low control voltages —
this is a device-physics wall, not a sizing miss.

**Applied W=3 -> W=9 to M5** (modest 3x, `L=0.15` unchanged) — gets some
dead-zone improvement without a large area increase. Re-checked VCO center
frequency at vctrl=0.9V with R=54 still in place: **318.9MHz** (was 299.2MHz
before widening M5 — widening the tail device sped the ring back up somewhat,
expected since more current flows for the same vctrl). Off target by ~6%;
left as-is for the next experiment since the point was to test the loop, not
re-hit 300.0MHz exactly (would just nudge R up again afterward).

## 7. CDR loop retest: retuned VCO + bias fix + wider M5, together

Re-ran `CDR_tune_tb.sch` (bias fix from §5 + R=54 + M5 W=9) at the original
60ns transient:

```
clk+: pp=0.235V   max=1.102V  min=0.866V   period=3.799ns (263.2MHz)
clk-: pp=0.234V   max=1.101V  min=0.866V   (matching)

x1.x1.net7/net8 (ring core): pp=0.449V, clearly oscillating (was dead before)
x1.net4/net5   (osc's own buffered out): pp=0.397V, healthy
x1.net1 (VCO control): still flat at 0.664V, pp~2mV
```

**Big jump from §5**: `clk+`/`clk-` went from ~6mV pp (dead) to 235mV pp with
a real, measurable period. The dead-zone fix worked — the ring core and both
buffer stages are alive and swinging.

**But it's not locking.** Extended the transient to 300ns (10p tstep, same
resolution) to give the loop time to converge — `net1` is still completely
flat (pp=2.3mV) across the *entire* 300ns, not just the first 60ns. Traced
further: the phase detector's own `up`/`down` outputs (`x1.net2`, `x1.net3`,
feeding the charge pump) are also both pinned near Vdd (1.76-1.81V, <55mV
ripple) for the whole run — i.e. the charge pump isn't getting real bang-bang
correction pulses at all, so `net1` never has a reason to move.

**Likely explanation:** `clk+`/`clk-` at 235mV pp, centered around ~0.98V,
is nowhere near a full 1.8V rail-to-rail digital swing (only ~13% of it).
The `alexander_phase_detector`'s D-flip-flops (built from `d_latch`, which
uses `clk+`/`clk-` to switch pass-gate-style sampling transistors) most
likely need a real digital clock swing to sample cleanly — a weak analog-ish
swing like this probably isn't reliably toggling those switches, so the
phase detector can't produce valid up/down decisions no matter how good the
VCO itself now is.

So there appear to be two compounding problems, not one: (a) the dead VCO
[fixed, this section], and (b) **the recovered clock never reaches a clean
digital swing**, so even with a live VCO the phase detector can't read it
properly and the loop can't close.

## 8. Tried cascading more `diff_amp_inv` stages open-loop (your suggestion)

Your idea: amplify the swing *outside* the VCO's resonant loop by chaining
differential-inverter/diff-amp stages open-chain (not wrapped into an
oscillator), so gain compounds stage-over-stage, and route the final stage's
output to both the phase detector and the external pins instead of the weak
intermediate tap.

Implemented in `CDR_tune.sch`: added two more `diff_amp_inv` instances (`x9`,
`x10`) in series after the existing `x4`, each with `vctrl` tied to `Vdd`
(same bias-fix pattern as x4). Chain: `ring_oscillator net4/net5 -> x4 ->
preamp+/- -> x9 -> preamp2+/- -> x10 -> rclk+/-`. Moved the external
`rclk+`/`rclk-` output opins to sit at `x10`'s output (previously at `x4`'s);
the phase detector's existing remote `rclk+`/`rclk-` tags needed no change
since they already reference the final net name by label, which now resolves
to `x10`'s output instead of `x4`'s.

Netlisted clean (no missing symbols), simulated the full 300ns transient
clean (no errors). Measured swing at each stage:

```
x1.net4/net5 (VCO's own output, x4's input)     : pp = 0.397 V
x1.preamp+/-  (x4 output / x9 input)             : pp = 0.228 V
x1.preamp2+/- (x9 output / x10 input)            : pp = 0.160 V
clk+/clk-     (x10 output / final)               : pp = 0.125 V
```

**Result: each added stage made the swing *smaller*, not bigger.** `x4` alone
already attenuates (0.397V in -> 0.228V out, gain ≈ 0.57), which we'd
actually already seen in the original ring_oscillator benchmark (net7/net8 at
~1.44Vpp in, x6's own vo+/vo- at ~0.4Vpp out — same attenuation, we just
hadn't framed it as "gain < 1" until now). Cascading two more copies of the
*same, as-sized* stage compounds that attenuation instead of building gain,
exactly like chaining several volume-down knobs. **The idea is right — chain
differential stages open-loop, don't touch the resonant loop, route the
final tap to both consumers — but `diff_amp_inv` as currently sized is a
buffer/level-shifter (gm·R < 1), not a gain stage, so cascading more copies
of it can't work.** To make this approach pay off, whatever stage gets
cascaded needs `gm·R > 1` — either resize `diff_amp_inv`'s own transistors/
resistors (more `gm` and/or more load R) so each copy actually amplifies, or
use a different existing stage that already has real gain (e.g. a single
`ring_inverter` half, used open-loop instead of in the ring, might behave
differently — untested).

Reverted `CDR_tune.sch` to the two-stage (`x4` only) version for now, since
adding two attenuating stages was strictly worse than the §7 baseline
(125mV pp final vs 235mV pp with x4 alone) — no reason to keep the extra
stages in until they can actually provide gain.

## 9. Resized `diff_amp_inv`'s own load resistors for real gain (your call: option 1)

Copied `diff_amp_inv.sch/.sym` -> `diff_amp_inv_tune.sch/.sym` and rewired
both places it's used (`x6` inside `ring_oscillator_tune.sch`, `x4` inside
`CDR_tune.sch`) to the tuned copy, so the gain fix applies consistently
everywhere in the sandbox. Swept both load-resistor pairs together (`R3/R4`
and `R1/R2`, the two internal gain stages), scaling each stage's resistor
length by a common factor from its original value:

| factor | R3/R4 L | R1/R2 L | vo+ pp (standalone VCO tb, vctrl=0.9V) | freq (MHz) |
|--------|---------|---------|------------------------------------------|-----------|
| 1 (orig) | 1    | 1.75    | 0.374 V                                   | 318.9     |
| 4      | 4       | 7.0     | 0.903 V                                   | 318.6     |
| 8      | 8       | 14.0    | 1.638 V                                   | 318.3     |
| 12     | 12      | 21.0    | 1.757 V                                   | 318.2     |
| 16     | 16      | 28.0    | 1.828 V                                   | 318.2     |
| 20     | 20      | 35.0    | 1.861 V                                   | 318.3     |

Frequency is essentially unaffected by this change at every factor (as
expected — this stage is downstream of the resonant ring, not part of it).
**Picked factor=10** (`R3/R4 L=10`, `R1/R2 L=17.5`) — at this point
`vo+`/`vo-` on the standalone VCO testbench reach max=1.83V/min=0.12V,
essentially full rail-to-rail and nicely centered, without excessive area
growth beyond what's needed.

### Full CDR loop retest with the gain-fixed buffer

Ran `CDR_tune_tb.sch` (retuned VCO §3/§6 + bias fix §5 + gain-fixed
`diff_amp_inv_tune` this section) for the full 300ns transient:

```
clk+: pp=1.710V  max=1.825V  min=0.115V   period=3.840ns (260.4 MHz)
clk-: pp=1.712V  max=1.827V  min=0.115V   (matching)

x1.net2 (up)   : pp=2.09V, max=1.93V, min=-0.16V, REAL period=36.4ns
x1.net3 (down) : pp=2.07V, max=1.93V, min=-0.14V, REAL period=9.6ns
x1.net1 (VCO control): pp=16.6mV, range 0.658-0.675V (was ~2mV, essentially frozen, before)
```

**This is the qualitative breakthrough:** `clk+`/`clk-` now reach real
rail-to-rail digital swing (1.71V pp out of 1.8V). More importantly, the
phase detector's `up`/`down` outputs (`net2`/`net3`) are **no longer
pinned** — they show real amplitude (~2V pp, i.e. genuinely switching) and
real, distinct periods, meaning the phase detector is now actually producing
valid bang-bang decisions instead of nothing.

Checked whether `net1` (the VCO control voltage / charge pump output) is
trending anywhere or just noise-jittering, via `.measure ... AVG ... FROM=
... TO=...` over three windows of the 300ns run:

```
0-50ns average:    0.66487 V
125-175ns average: 0.66764 V
250-300ns average: 0.66957 V
```

**`net1` is climbing steadily and monotonically** — roughly +17-19µV per ns,
consistent across both halves of the window (not just noise). This is
exactly the direction it needs to move: our recovered clock is currently
running slower (260MHz) than the 300.3MHz input, so a correctly-functioning
bang-bang loop should push the control voltage up to speed the VCO up — which
is precisely what's happening.

**Caveat: at this rate, full convergence to ~0.9V (our target lock point)
would take roughly 13-14µs of simulated time** — far more than the 300ns
tested so far (300ns took ~72s of wall-clock ngspice time; 13.5µs at a
similar rate would be very roughly 45-60 minutes of simulation, not
confirmed). So: this run demonstrates the loop is now *directionally
correct and alive*, not that it has fully locked yet. A charge pump current
this small relative to the loop filter cap gives a slow-but-presumably-stable
loop — normal for a real PLL, but slow to brute-force-verify via transient
alone.

## 10. Faster convergence testing method + a real "false lock" finding

You asked (a) whether there's a faster way to test convergence than a
45-60 minute brute-force transient, and (b) flagged clock jitter as a big
consideration. Addressing (a) first, since it changes what's testable:

**Method used:** temporarily shrunk the loop filter's two MOS caps
(`tiny_pll_loop_filter_cap1_tune`/`cap2_tune`, copies) by exactly **10x each**
(cap1: `L 6->0.6`, cap2: `W 11->1.1` — same 10x factor on both, so their
*ratio* is preserved). This is a simulation-speed trick, not a design
change: since the loop's steady-state equilibrium point is a DC/quasi-static
balance condition (where average charge-pump current is zero), it does not
depend on the loop filter's absolute cap values — only the *time* to get
there does, and that scales down by ~10x when the caps are 10x smaller. So:
this run's *settling point* should be representative of the real design;
only its *convergence time* is compressed (real caps would take ~10x longer
to reach the same point).

Ran the sped-up sandbox for 1.5µs (10x the earlier 300ns budget covers the
same effective ~15µs of "real" loop time). Tracked `net1` in six 150ns
windows:

```
0-150ns:     0.6741 V
300-450ns:   0.6922 V
600-750ns:   0.7025 V
900-1050ns:  0.7064 V   <- peak
1200-1350ns: 0.7039 V
1350-1500ns: 0.7023 V
```

**It settles.** Climbs, slightly overshoots at ~0.706V, then relaxes back to
~0.702V and holds — classic damped 2nd-order step response, a real
equilibrium, not just "still drifting, ran out of patience." This confirms
the loop is stable (doesn't run away or oscillate wildly).

**But directly measuring `clk+`'s actual period late in the run
(TD=1400n) shows it settled at the wrong frequency:**

```
clk+ period (late in run): 3.489-3.491 ns  -> 286.5 MHz
vin+ period (reference):   3.330 ns        -> 300.3 MHz (exact, by design)
```

**~4.6% frequency error at steady state — this is not true lock, it's a
stable false lock.** This is consistent with a well-known real limitation of
Alexander/bang-bang phase detectors: they only sense *phase* (early/late),
not frequency, directly. When there's a frequency error, the net up/down
bias that drives correction comes from a slow "beat" between the two
frequencies, which gets weaker as the error shrinks — the loop can settle at
a stable point where the (weak, asymmetric) correction happens to balance
before the frequency error reaches zero, especially if there's any charge
pump up/down current mismatch. Real CDR designs commonly pair a bang-bang
detector with a separate frequency detector or wider-range assist loop for
exactly this reason — a bare Alexander detector often isn't sufficient for
frequency *acquisition*, only for fine phase tracking once already close.

**Practical implication:** this makes VCO center-frequency accuracy (§3, §6)
even more important than "just get close" — the smaller the initial
frequency error the phase-only loop has to correct, the smaller (and maybe
tolerable) the residual false-lock offset. It may also be worth checking the
charge pump's up vs. down current symmetry (a static mismatch there is a
classic cause of exactly this kind of residual offset) — haven't done that
yet.

**On jitter:** holding off on jitter measurement until frequency lock itself
is resolved — characterizing jitter on a signal that's running ~4.6% off
frequency isn't meaningful yet. Once we're within true lock (or decide the
false-lock offset is small enough to accept), the plan is: extract all
`clk+` threshold-crossing times from the raw waveform (post-process in
Python rather than one `.measure` at a time), compute cycle-to-cycle period
jitter (std/pp of consecutive periods) and phase jitter relative to `vin+`'s
edges (tracking error each cycle) — that's the right way to quantify it once
there's a real lock point to measure jitter around.

## 11. Charge pump check (no CP modification) + the actual root cause

**Constraint:** the `tiny_pll_charge_pump` already has a taped-out layout, so
it is treated as frozen — diagnose only, fix on the VCO side.

### CP up/down current measurement (diagnosis)

Built a standalone CP testbench (scratchpad only, no repo files touched):
two `tiny_pll_charge_pump` instances sharing one real `tiny_pll_bias_gen`,
wired exactly as in `CDR_tune`. One instance forced to up=1/down=0, the other
up=0/down=1. Swept the forced `out` voltage and read the current each
delivers:

| Vout | I_up (µA) | I_down (µA) | mismatch (down vs up) |
|------|-----------|-------------|----------------------|
| 0.50 | 1.2647    | 1.2352      | −2.34% |
| 0.60 | 1.2643    | 1.2532      | −0.87% |
| **0.65** | **1.2640** | **1.2617** | **−0.18%** ← crossover |
| 0.70 | 1.2638    | 1.2698      | +0.48% |
| 0.80 | 1.2632    | 1.2851      | +1.73% |
| 0.90 | 1.2615    | 1.2980      | +2.89% |
| 1.10 | 1.2540    | 1.3074      | +4.26% |

The CP is actually **well designed**: up and down match to better than 0.2%
around 0.65-0.70V (`MPSRC` W=2 pfet vs `MNSRC` W=1 nfet — sized to compensate
for pfet/nfet mobility, and it works). The mismatch only grows away from that
point. **No reason to modify the charge pump. Its layout can be reused as-is.**

### VCO-side fix attempt (per the layout constraint)

Hypothesis at the time: the loop settles wherever the CP's net charge is
zero (~0.66-0.70V, the crossover), so if the VCO is re-centered to produce
300.3MHz *at that voltage*, the resting point and the correct frequency
coincide. Tuned R at vctrl=0.70V on the standalone VCO tb:

| R (L) | freq @ vctrl=0.70V |
|-------|--------------------|
| 54    | 285.7 MHz |
| **50.75** | **300.4 MHz** ← essentially exact vs 300.3MHz target |
| 48    | 313.5 MHz |
| 45    | 329.1 MHz |

**Applied R = 54 -> 50.75.** Full loop re-run (1.5µs, sped-up caps):
settles at net1 = 0.6864V, `clk+` period 3.4414ns = **290.6 MHz** — improved
from 286.5MHz (4.6% error) to 290.6MHz (3.2% error), but *still not locked*,
and the loop clearly "absorbed" most of the VCO change rather than tracking it.

### Root cause found: the phase detector outputs are stuck high

Measured the average level of the PD's `up` (`x1.net2`) and `down`
(`x1.net3`) outputs over six consecutive 25ns windows late in the run:

```
up:   1.824  1.659  1.802  1.704  1.825  1.660   (V, avg)
down: 1.822  1.805  1.801  1.810                 (V, avg)
```

On a 1.8V rail, **both `up` and `down` sit high ~92-100% of the time.** A
working bang-bang PD should toggle these roughly 50/50. Instead both current
sources are on almost continuously, so the charge pump delivers only the
*difference* between them — which is exactly the mismatch curve measured
above, and which is zero at ~0.65-0.70V.

**That fully explains every observation so far:** `net1` always settles at
~0.67-0.70V because that is the charge pump's own internal current
crossover, *not* a frequency-lock point. The VCO then simply free-runs at
whatever frequency that voltage happens to give. The loop is not closed in
any functional sense — the PD is not steering it.

It also explains why §9's result looked better than it was: after the gain
fix, `up`/`down` did show ~2V pp (they dip occasionally, hence real "period"
readings), which read as "now switching" — but the *duty cycle* shows they
are mostly parked high, which the pp/period measurements alone did not
reveal. Lesson for future measurement: for logic-level nodes, check
**average/duty cycle**, not just peak-to-peak and period.

**Consequences for next steps:**
- Do not modify the charge pump (it is innocent, and its layout is reusable).
- Further VCO frequency tuning is premature — while the PD is not steering,
  the VCO's center frequency only sets where it free-runs, and any R value
  can be made to "look right" without the loop actually working. R=50.75 is
  kept for now but should be re-tuned once the PD works and a real lock
  point exists.
- Jitter measurement remains premature for the same reason (§10) — there is
  no lock to measure jitter around yet.
- The real work is in `alexander_phase_detector.sch` and its
  `d_flip_flop`/`d_latch` building blocks: find why both XOR outputs sit
  high. Best next test is a **standalone PD testbench** — drive `vin+/vin-`
  and `clk+/clk-` with known, deliberately phase-shifted sources and check
  that `up`/`down` respond correctly to early vs. late clock. That isolates
  PD correctness from all loop dynamics.

## Where things stand

Five changes are stacked in the sandbox, all sizing-only, none touching the
charge pump: retuned VCO frequency (§3, revised in §11 to R=50.75), widened
M5 tail device to shrink the dead zone (§6), diff_amp_inv bias fix (§5), and
real gain in diff_amp_inv (§9). The VCO subsystem is now genuinely healthy —
correct center frequency, near rail-to-rail output swing, no dead zone at the
operating point.

**But the loop is not closed:** the phase detector's `up`/`down` outputs sit
high ~92-100% of the time instead of toggling ~50/50, so the charge pump just
settles at its own current-crossover voltage and the VCO free-runs there
(§11). Everything that looked like "the loop is converging" was the charge
pump finding its own balance point, not phase locking.

**Next step is the phase detector, not the VCO or the charge pump.** Suggested:
a standalone `alexander_phase_detector` testbench driven with known,
deliberately phase-shifted clock/data, to check `up`/`down` respond correctly
to early vs. late — isolating PD correctness from loop dynamics. Jitter
characterization stays queued behind that.

---

# §12. Component-level isolation tests (parallel agent testing)

Four components of the PD hierarchy were tested standalone in ngspice, each
in an isolated scratchpad, using extracted flattened subckts rather than
xschem schematics. No repo files were modified by these tests.

## 12a. `d_latch` — core is FINE, but has a small-swing input threshold

**Working correctly:**
- Clock polarity: **clk+ HIGH = transparent, clk+ LOW = hold** (verified
  empirically, not assumed).
- Latch timing/storage is correct: tracks input when transparent, ignores
  input changes during hold, updates on next transparent phase.
- Retention is excellent: held for 47ns with the input flipped, output
  drooped from 1.7990V to a minimum of 1.7922V (essentially zero droop).
- At full-rail input, outputs are true CMOS rails: vout+ pp = 1.868V,
  vout- pp = 1.838V, and averages 0.885V / 0.841V — i.e. healthy ~50% duty.

**The defect — CML common mode vs. inverter trip point mismatch:**
- The CML load resistors put the internal nodes' common mode at **1.467V**
  (both net1 and net2 with zero differential input).
- The output CMOS inverter (pfet W=2 / nfet W=1) has a trip point of
  **0.870V** — i.e. the CML common mode sits ~0.6V *above* where the
  inverter switches.
- Consequence: the latch needs roughly **≥0.47V differential at vin** for
  the transparent phase to resolve at all, and **~0.6V** for a clean CMOS
  high. Measured DC transfer (transparent phase, vcm 0.9V):

| vdiff | net1  | vout+ |
|-------|-------|-------|
| 0.00  | 1.467 | 0.000 (vout- also 0.000 — illegal both-low state) |
| 0.30  | 1.007 | 0.046 |
| 0.40  | 0.920 | 0.282 |
| 0.45  | 0.884 | 0.696 |
| 0.50  | 0.852 | 1.099 |
| 0.60  | 0.798 | 1.644 |
| 1.80  | 0.566 | 1.799 |

- Below that threshold, **both vout+ and vout- read 0V simultaneously** — a
  non-complementary illegal state — and the correct level only appears
  *after* the clock enters hold, when the cross-coupled pair regenerates.
  So at small swing the latch is effectively half a clock cycle late and
  emits a glitch during every transparent phase.
- With a 400mV pp input the averages skew badly (vout+ 0.640V,
  vout- 0.372V) **while pp still reads a healthy 1.83V** — another instance
  of the "good pp, bad average" trap. Reinforces that duty/average must be
  a first-class metric.

**Relevance to the CDR bug — important nuance:**
In the *current* `CDR_tune` the PD's inputs are comfortably above this
threshold (`vin+/vin-` are full-rail complementary from the testbench;
`clk+/clk-` are now ~1.71V pp each after the §9 gain fix, so ~3.4V
differential). So this threshold is **probably not** what is pinning
`up`/`down` high today — the decisive answer has to come from the
phase-detector-level test.

But it does two useful things:
1. **It retroactively explains the earlier dead loop.** When `clk` was only
   52mV pp (§5) or 235mV pp (§7), it was far below the ~0.5V differential
   the latch needs — so the flip-flops genuinely could not sample at all.
   That confirms the §9 gain fix was necessary, not incidental.
2. **It sets a hard design margin to respect from now on: the recovered
   clock must stay ≥0.5V differential, ideally ≥0.6V, at the PD inputs.**
   Worth treating as a pass/fail gate in any test framework.

The common-mode/trip-point mismatch is also a genuine robustness weakness
even when it is not the active blocker — it burns most of the available
margin and would likely get worse across PVT corners (untested, all work so
far is nominal `tt`).

## 12b. `robs_xor` — gate is logically CORRECT, but has a hard "both-low = stuck high" mode

**Working correctly:** standard 8T complementary XOR, correctly wired (no
floating node, no missing/duplicated connection, no always-on path). Static
truth table is perfect and rail-to-rail:

| A | B | xor_out | I(VDD) |
|---|---|---------|--------|
| 0 | 0 | 0.32 µV | 0.5 nA |
| 0 | 1 | 1.79998 V | 5.6 nA |
| 1 | 0 | 1.79999 V | 4.1 nA |
| 1 | 1 | 5.9 µV | 7.8 nA |

With clean full-rail complementary inputs at 300MHz it toggles ~50/50
(duty 45.6% vs ideal 50%), biased slightly LOW — not high.

**Failure mode 1 — non-complementary inputs park the output (no crowbar):**
all 8 degenerate states give a defined rail (max static current 11.6nA), but
the output goes input-independent:

| A, A- | B, B- | xor_out |
|-------|-------|---------|
| both low (0,0) | any | **1.8 V — STUCK HIGH** |
| both high (1,1) | any | 0 V — stuck low |
| any | B,B- both low | **1.8 V — STUCK HIGH** |
| any | B,B- both high | 0 V — stuck low |

Mechanism: with A=A-=0, XM5 and XM2 are both on while XM6/XM7 are both off —
the pull-down network is entirely disabled and the pull-up always has a path.

**Failure mode 2 — input common mode below ~0.75V also parks it high**
(PDN is a *series* nfet stack, so the top device needs Vgs well above Vth,
while the pfets see a huge Vsg when the input low level is 0.2-0.3V):

| Input CM | xor_out avg | xor_out pp |
|----------|-------------|------------|
| 0.4 V | **1.792 V** | 0.26 V |
| 0.6 V | **1.679 V** | 0.55 V |
| 0.7 V | 1.206 V | 1.83 V |
| 0.9 V | 0.554 V | 1.77 V |

**Sizing oddity worth noting:** `XM3` is W=16 nf=8 while all seven other
devices are W=2 nf=1. It sits in series with a W=2 pfet so it adds no drive —
only ~8x gate capacitance, loading both `xor_out` and the `B` input. It also
causes a 0.27V overshoot above the rail (2.07V peak on a 1.8V supply) by
coupling the B edge onto the output — a reliability/overvoltage concern
independent of the logic issue. Drive is weak generally: at CL=200fF the
output pp collapses to 1.02V.

## 12c. ROOT CAUSE CONFIRMED — measured directly in the real CDR

The XOR agent's key structural observation: **both XOR instances share the
same `B+`/`B-` nets**, so a single bad B pair jams `up` AND `down` together:

```
x6 net1 VDD B- VSS down net2 B+ robs_xor    <- down = XOR(net1/net2, B+/B-)
x7 net5 VDD B- VSS up   net6 B+ robs_xor    <- up   = XOR(net5/net6, B+/B-)
x3 VDD VSS B+ B- net3 clk+ clk- net4 vbias d_flip_flop   <- B+/B- = Q/Qn of flop x3
```

Measured `B+`/`B-` directly in `CDR_tune_tb.raw` (window 1000-1100ns, 5608
samples):

```
B+ : avg=0.3869V  min=-0.111  max=1.800  pp=1.911  %time>0.9V = 21.8%
B- : avg=0.6126V  min=-0.015  max=1.809  pp=1.823  %time>0.9V = 34.5%

B+ plus B- averages to 0.9996V   (a true complementary pair must average ~1.8V)
%time BOTH LOW  (illegal): 43.7%
%time BOTH HIGH (illegal):  0.0%
%time complementary (ok) : 56.3%
```

**`B+` and `B-` are in the illegal both-low state 43.7% of the time.** Note
both show a perfectly healthy ~1.9V pp — the pp measurement gives no hint of
the problem at all. Third instance of the same trap.

### The complete causal chain (each link independently measured)

1. `d_latch` fed less than ~0.47V differential outputs **both vout+ and
   vout- low** — an illegal, non-complementary state (§12a, measured).
2. In the real CDR, flop x3's outputs `B+`/`B-` sit in exactly that
   both-low state **43.7% of the time** (measured above).
3. `robs_xor` with its B pair both low is forced **permanently HIGH**,
   independent of its other input (§12b, measured).
4. Both XORs share `B+`/`B-`, so `up` and `down` jam high **together**
   (netlist, verified).
5. The charge pump therefore has both current sources on nearly
   continuously, delivers only their small difference, and settles at its own
   current-crossover voltage (~0.66-0.70V) instead of a phase-lock point
   (§11, measured).
6. The VCO free-runs at whatever frequency that voltage gives → 290.6MHz vs
   300.3MHz, no lock.

That is a complete, evidence-backed explanation of the CDR failure.

### Still open: *why* do the flops emit non-complementary outputs?

The degradation is not confined to x3 — every flop output pair fails the
complementarity check (a true pair should sum to ~1.8V):

```
net1/net2 (flop x5 out): 0.608 + 0.494 = 1.10V
net5/net6 (flop x2 out): 0.632 + 0.511 = 1.14V
net3/net4 (flop x1 out): 0.506 + 0.623 = 1.13V
B+/B-     (flop x3 out): 0.387 + 0.613 = 1.00V   <- worst, and it is the shared one
```

Even the *first-stage* flops (x5, x1) degrade, despite being fed full-rail
`vin+/vin-` and a ~1.71V pp clock — so weak PD input swing is NOT the
explanation. Two candidates, not yet separated:
- **Speed**: the d_latch was verified healthy standalone at a 4ns clock
  (250MHz); the real circuit runs 3.33ns (300MHz). The CML pair may not have
  time to regenerate.
- **Loading**: the XOR's oversized `XM3` (W=16 nf=8) presents a large gate
  cap, and *two* of them hang on `B+` — consistent with `B+` being the worst
  of the four pairs. The XOR agent measured that loading skews its output low
  and collapses swing (CL=200fF -> pp 1.02V).

The `d_flip_flop` agent (still running) should separate these.

## 12d. `d_flip_flop` and `alexander_phase_detector` — PD ARCHITECTURE IS SOUND

**This is the good news, and it corrects §12c.**

### The PD works correctly when driven properly (measured, 300MHz, full rail)

Phase sweep, 300MHz clk, 1010 NRZ data, full-rail complementary inputs:

| phase | up_avg | dn_avg | diff |
|-------|--------|--------|------|
| 0     | 1.8012 | 0.1235 | **+1.678** |
| 30-150| 1.8012 | 0.1232 | **+1.678** |
| 180   | 0.1271 | 1.8004 | **-1.673** |
| 210-330| 0.1271| 1.8005 | **-1.673** |

**The up/down difference DOES change sign** (between 150° and 180°, and again
on wraparound) — two zero crossings per UI, exactly correct bang-bang
behaviour. Hard saturation with no proportional region is expected for an
ideal bang-bang PD on jitter-free square waves.

Frequency-error test (clk 300MHz vs data 333Mb/s, 11% error) gives a textbook
beat: diff swings the full ±1.74 with a ~30ns beat period = exactly
1/33.3MHz, the frequency difference. The detector phase-slips at precisely
the right rate.

**Conclusion: no miswire, no wrong clock polarity, no XOR fed the wrong pair.
The Alexander topology and wiring are correct. This is a levels/drive
problem, not an architecture problem — no redesign needed.**

`d_flip_flop` separately confirmed as a genuine RISING-edge-triggered FF on
clk+ (Q updates 56-180ps after each clk+ rise, never at falls; no
transparency — data changed mid-master-window did not appear until the next
rising edge). Master/slave clocking verified correct: instance x1 (master)
is wired with clk swapped, so master is transparent when clk+ is LOW and
slave when clk+ is HIGH.

### CORRECTION to §12c: the origin is x5, not x3/B+/B-

`avg(Q)+avg(Qn)` per flop pair (a legal complementary pair must sum to ~1.8V):

| pair | full-rail | 400mVpp weak |
|------|-----------|--------------|
| A (x5, net1/net2) | 1.712 | **1.085**  <- FIRST flop, driven directly by vin |
| B (x1, net3/net4) | 1.723 | 1.224 |
| C (x2, net5/net6) | 1.729 | 1.301 |
| B+/B- (x3)        | 1.677 | **1.044** |
| up / down         | 1.801 / 0.123 | 1.804 / **0.777** |

The illegal both-low state **originates at flop x5** — the first CML stage
that sees the external input — and propagates down the chain. B+/B- measures
worst only because it is furthest downstream and accumulates degradation.
**So §12c's framing was wrong: B+/B- being 43.7% both-low is a downstream
symptom, not the origin. Fixing x3 or the XOR would not help.**

### The real margin problem

**Even at FULL rail the pair sums are 1.68-1.73V, not 1.8V.** The CML latch
never fully resolves even with ideal inputs — there is only ~5% margin before
it falls into the illegal both-low state. That thin margin is the underlying
fragility, and it is consistent with §12a's finding that the CML common mode
(1.467V) is badly mismatched to the output inverter trip point (0.870V).

### What is actually degrading the input in the REAL CDR: the clock

Measured at the PD inputs in `CDR_tune_tb.raw` (window 1000-1100ns):

```
clk+ avg = 0.7405 V     clk- avg = 0.7435 V
clk+ plus clk- = 1.484 V   (a clean complementary pair must sum to ~1.8V)

clk+ rise (15-85%) = 525 ps      clk+ fall = 170 ps    <- 3x asymmetric
vin+ rise (15-85%) =   6.9 ps    (ideal source, for scale)
```

**The recovered clock is itself not a clean complementary pair**, and its
rise is 3x slower than its fall. Both clk+ and clk- average well below
mid-rail, i.e. they spend time both-low together — feeding exactly the
pathology the CML latch cannot tolerate.

**Root of the asymmetry — and it is a consequence of my own §9 change.**
`diff_amp_inv` is a resistor-loaded differential pair: pull-DOWN is an active
nfet (fast, 170ps) while pull-UP is through the load resistor (slow RC,
525ps). §9 increased those load resistors 10x to buy voltage gain — which
also made the pull-up RC ~10x slower. So §9 traded edge symmetry and duty
cycle for swing. The swing was necessary, but it came at a cost that was not
measured at the time.

### Historical evidence: buffers used to exist here

`git log` for `alexander_phase_detector.sch` shows one commit, f84b81e:
*"redid the alexander loop, using proper flip flops, **used a lot of
inverters to tune the D latch and various amplifiers**, now it works as a
minimum viable product"*.

The stale `~/.xschem/simulations/alexander_phase_detector.spice` (generated
Feb 18 04:42; the `.sch` was edited Feb 18 05:11, i.e. AFTER) wires
`x1 -> net8/net6` and `x3 <- net9/net10` — **different nets**, meaning
buffering devices sat between the edge-sample flop and the retiming flop.
The current schematic has `x3` take `net3/net4` from `x1` directly, with
nothing in between. So inter-stage buffering existed in a working state and
was removed in the last edit before the commit. The repo still contains
`inverter_buffer.sch/.sym`, `double_inverter.sch/.sym` and
`inverter_chain.sch/.sym`, currently unused.

### Where this points

The CML->CMOS interface is the problem, in two places:
1. The recovered clock reaching the PD needs fast, symmetric, genuinely
   rail-to-rail edges — a CMOS buffer/inverter after `diff_amp_inv` is the
   textbook fix and would decouple "gain" from "edge quality" so §9's
   resistor increase is no longer forced to do both jobs.
2. The `d_latch`'s own CML common mode (1.467V) vs inverter trip (0.870V)
   mismatch leaves only ~5% margin even under ideal drive; worth fixing on
   its own for robustness, independent of the clock.

Both are additions/changes to the signal path rather than pure resizing, so
flagging for approval before proceeding.

### Method note — a confounded experiment to redo

A `diff_amp_inv` resistor-factor sweep run at this point produced nonsense
(pp=0 at low factors, a negative fall time). Cause: `ring_oscillator_tune_tb.sch`
still had `V5` (vctrl) left at **0.7V** from the §11 work rather than 0.9V,
so low-factor points sat in the VCO dead zone, and the TRIG/TARG window
picked wrong edges. Those numbers are discarded — do not trust them. Any
redo must reset vctrl explicitly and validate the edge-measurement window.

---

# §13. Session 3 — the lost gain fix, and the complementarity finding

## 13a. CRITICAL PROCESS FAILURE: the §9 gain fix was silently lost

At the start of this session `diff diff_amp_inv.sch tuning/diff_amp_inv_tune.sch`
came back **empty** — the tuned copy had reverted to factor=1 (stock) values.
The §9 fix (`R3/R4 L=10`, `R1/R2 L=17.5`) was gone.

**How:** the confounded resistor sweep documented in the "method note" above
(which ran *after* §12d) wrote R values into `diff_amp_inv_tune.sch` on each
iteration. It was abandoned as untrustworthy and **left the file at factor=1**.
Nothing restored it. §12d's measurements were taken with the fix present; every
run after that point silently had no gain fix at all.

**Cost:** two full simulation variants (A, B below) plus a completely wrong
conclusion — I measured the stock stage attenuating 376mV -> 219mV and reported
it as a new finding ("diff_amp_inv is natively lossy, don't cascade it"). §9's
own sweep table already had that number in the factor=1 row (0.374V). I
re-derived a known number from a clobbered file and read it as new evidence.

**Lesson for future models — two rules:**
1. **Any sweep script that writes into a design file must restore the chosen
   value on exit**, including on abort. Prefer generating per-point copies over
   mutating one file in place.
2. **Before trusting any measurement, `diff` the tuned file against its
   original** and confirm the intended deltas are actually present. A sandbox
   copy silently identical to the original is indistinguishable from a fix
   that "stopped working."

Restored `R3/R4 L=10`, `R1/R2 L=17.5`.

## 13b. Sizing fixes applied (from the §12 agent findings)

Both are pure sizing, on new sandbox copies. Created `robs_xor_tune`,
`d_latch_tune`, `d_flip_flop_tune`, `alexander_phase_detector_tune` (each
repointed at the tuned children) so the whole PD hierarchy is sandboxed.

- `robs_xor_tune` XM3: `W=16 nf=8` -> `W=2 nf=1`. It sits in series with a W=2
  pfet so it added no drive, only ~8x gate cap — and *two* of them hang on
  `B+` (§12b/§12c).
- `d_latch_tune` output inverters M8/M10: pfet `W=2` -> `W=3` (nfet stays W=1),
  giving the ~3:1 ratio sky130's mobility difference wants (§12a).

## 13c. Variant matrix

All runs: `CDR_tune_tb.sch`, `tran 20p 1500n`, 10x-shrunk loop filter caps.

| variant | build | clk+ pp | clk+ + clk- | up / dn | vctrl (late) |
|---------|-------|---------|-------------|---------|--------------|
| A | buffers only, **no gain fix** | 0.018 V (dead) | 3.60 (both railed) | 0.16 / 0.67 | 0.227 (crashed) |
| B | A + 13b sizing fixes | 0.018 V (dead) | — | 0.023 / 0.456 | 0.019 (crashed) |
| C | B + **gain fix restored** | **1.875 V** | **1.468 V** | 1.75 / 1.80 | **0.694 (settled)** |
| D | C + buffer trip trimmed to 0.806 V | 1.887 V | 1.521 V | 1.74 / 1.80 | 0.692 (settled) |

**A and B are void** — they ran without the gain fix (13a). Their only real
content is that the 13b sizing fixes did move `up`/`down` off the rail
(0.83/0.86 -> 0.023/0.456), confirming the XOR "lost LOW level" issue is fixed.

**C is the healthiest the loop has ever been:** clock rail-to-rail and
*sustained* for the full 1.5us (earlier variants died), and vctrl reaches a
stable equilibrium instead of running away into the dead zone.

C frequency: `clk+` period 3.3736ns = **296.4 MHz** vs `vin+` 3.330ns =
300.3 MHz -> **1.3% error** (was 4.6% in §10, 3.2% in §11 — best yet).

## 13d. A failed prediction, and why it was never dimensionally possible

Hypothesis for C's 1.468V sum: the buffer's trip (0.867V) sat above the
`clkraw` common mode (0.805V), squeezing duty to 41%. Trimmed stage-1 nfet
`W=3 -> W=7` (trip -> 0.806V). Result = variant D: sum moved 1.468 -> 1.521V.
Essentially nothing.

**It could never have worked, and arithmetic would have shown that before
spending the run.** Measured edges in C:

```
clkraw+   rise 233ps / fall 118ps      duty 39.5%
clk+      rise  48ps / fall  34ps      duty 41.0%   <- buffer sharpened edges 5x
VCO net4  duty 44.6%
```

Edges are ~48ps on a 3374ps period = **1.4% of a cycle**. Moving the slice
level by 60mV on a 1.7V edge shifts timing by ~18ps = **~0.5% of duty**. The
gap to close was 9%. Neither trip point nor edge asymmetry can explain a 9%
duty error — both are an order of magnitude too small.

**Method rule: before running a 3.5-minute sim to test a fix, do the
order-of-magnitude arithmetic on whether the mechanism can produce an effect
of the required size.** Two of this session's runs were spent on mechanisms
that were dimensionally incapable of mattering.

## 13e. THE REAL FINDING: independent single-ended slicing destroys complementarity

In both C and D, **clk+ and clk- have the SAME duty (~41%), not complementary
duties (41%/59%)**. That is structurally impossible for a true differential
pair, and it is the whole reason the sum is 1.47V instead of 1.8V.

**Cause — and it is the buffer architecture added last session, not a sizing
miss.** `x11` and `x12` were two *independent single-ended* `inverter_buffer`
instances, each slicing its own input against its own trip point with no
knowledge of the other. When the common mode sits off the trip point, **both
outputs skew the same direction**, and complementarity is destroyed — feeding
exactly the both-low condition §12a/§12d showed the CML latch cannot tolerate.

So the buffers did not fail to fix the problem; **they caused this version of
it.** No ratio trimming on those buffers can ever work — the structure cannot
preserve complementarity by construction. (This also retroactively explains
why D's careful trim was pointless: it trimmed both slicers *equally*, so the
skew stayed common-mode.)

**A differential signal must be sliced differentially.**

## 13f. Variant E — clk- derived by inversion (user-approved architecture change)

Change: buffer `clkraw+` -> `rclk+` (unchanged `x11`), then derive
`rclk-` by **inverting `rclk+`** with a new single CMOS inverter, instead of
slicing `clkraw-` independently.

New cell `single_inverter_tune.sch/.sym` (pfet W=16 nf=8 / nfet W=8 nf=4,
matching the buffer's output-stage drive). Netlist verified:

```
x11 Vdd Vss clkraw+ rclk+ inverter_buffer_tune
x12 Vdd Vss rclk+   rclk- single_inverter_tune
```

Complementarity now holds **by construction** — the sum is 1.8V regardless of
where the trip point lands, which also removes most of the PVT fragility of a
hand-matched trip. `clkraw-` is left dangling (x4 still drives it); harmless,
but it means half the differential path is now unused and could be reclaimed.

**Known cost:** `rclk-` lags `rclk+` by one inverter delay (~20-30ps, ~0.8% of
a UI) — a static phase offset a bang-bang loop should absorb, not jitter. It
does discard the true-differential timing the CML path was designed around.

**RESULT: the complementarity fix WORKED — and it moved the failure.**
If it does close the loop, the proper follow-up is a real differential-to-
single-ended slicer (one stage on `clkraw+ - clkraw-`), which preserves
complementarity *and* timing.

## 13g. Component scorecard as of this session

| block | standalone | in-system | key number |
|-------|-----------|-----------|------------|
| charge pump | GOOD | innocent | up/down match <0.2% at 0.65-0.70V (§11). Layout reusable — do not modify |
| bias gen | GOOD | GOOD | no issue found |
| loop filter | GOOD | GOOD | clean damped 2nd-order settle (§10) |
| Alexander PD arch | GOOD | wiring correct | diff sign flips +1.678 -> -1.673; correct 1/33.3MHz beat (§12d) |
| d_flip_flop | GOOD | — | true rising-edge FF, 56-180ps (§12d) |
| VCO core | GOOD | thin margin | 296.4MHz vs 300.3 = 1.3% error |
| robs_xor | logic perfect | parks high | stuck at 1.8V when its input pair is both-low (§12b) |
| d_latch | core fine | illegal states | CML CM 1.467V vs inverter trip 0.870V (§12a) |
| diff_amp_inv | OK with §9 fix | mis-centered | 1.72V pp but centered 0.80V, not 0.90V |
| inverter_buffer | works as a buffer | **broke complementarity** | see 13e |
| CTLE | UNTESTED | UNTESTED | deprioritized by user; never characterized |

**Two standing risks not yet addressed:**
1. **`d_latch` has ~5% margin even at full rail** — complementary pairs sum to
   1.68-1.73V, not 1.8V, at nominal `tt` with ideal inputs (§12d). This is the
   deepest fragility in the design and no fix has been attempted.
2. **vctrl rests at 0.694V, only ~45mV above the VCO dead-zone cliff (~0.65V).**
   §6 proved widening the tail device cannot remove that cliff (subthreshold
   physics; W=60 still dead at 0.55V). Any downward excursion kills the clock
   outright — the exact failure mode variants A and B died from.

**Nothing outside `tuning/` has been modified.** No PVT/corner simulation has
been run on any of this work — everything is nominal `tt`.

## 13h. Variant E result — complementarity fixed, failure relocated to the slave latch

`clk+ avg 0.7455 + clk- avg 1.0502 = 1.796 V` — **complementarity restored**
(was 1.468V). And every flop output pair is now legal:

```
pair            avg(Q) + avg(Qn)      (was, §12d, in-circuit)
x5  net1/net2   0.000 + 1.744 = 1.744   (was 1.10)
x1  net3/net4   0.000 + 1.799 = 1.799   (was 1.13)
x2  net5/net6   0.000 + 1.799 = 1.799   (was 1.14)
x3  B+/B-       0.000 + 1.799 = 1.799   (was 1.00)
```

**The illegal both-low state that §12c/§12d identified as the root cause is
GONE.** `up`/`down` also came off the high rail: 1.75/1.80 -> 0.075/0.079.

**But the loop still does not lock, for a new reason: the PD is now DC-frozen.**
Every pair is legal *and constant* — Q pinned at 0V, Qn at 1.8V, not toggling.
Both XORs therefore see equal inputs and sit LOW ~96% of the time, so both
charge-pump sources are off, the pump delivers ~nothing, and vctrl is frozen
at 0.7003-0.7016V. We traded "both parked HIGH" for "both parked LOW".

### Traced to the slave latch, with a clean mechanism

Inside the first flop (x5), master and slave behave completely differently:

```
MASTER out (x5.net1/net2):  pp = 1.872 V, rails -0.03 to 1.89   <- toggling fine
SLAVE  CML (x5.x2.net1):    avg = 1.792 V, pp = 0.200 V         <- pinned at VDD
SLAVE  CML (x5.x2.net2):    avg = 0.602 V, pp = 0.829 V
SLAVE  out Q:               pp = 0.0147 V                        <- FROZEN
SLAVE  out Qn:              pp = 1.308 V
```

The master writes correctly; **the slave is latched hard and cannot be
overwritten.** Supporting rails are all healthy — `vbias` = 0.9000V exactly,
`vin+` full-rail toggling, `clk+` pp 1.87V, `clk-` pp 1.90V. Nothing is
starved; the slave simply never gets written.

### Why the slave and not the master — the duty cycle asymmetry

`clk+` duty is **41%**, so `clk-` duty is **59%**. In `d_flip_flop`, the master
is deliberately wired with the clock swapped (§12d). Therefore:

- **master transparent 59% of each cycle** -> long write window -> works
- **slave transparent 41% of each cycle** -> short write window -> jams

That single fact explains the master/slave split exactly.

### Compounding cause — the latch's sample:hold ratio is 1:1

`d_latch` topology (from the netlist):

```
sample pair : XM1/XM4  W=5, steered by XM6 (clk+) W=5
hold  pair  : XM3/XM5  W=5 cross-coupled, steered by XM7 (clk-) W=5
tail        : XM2 W=8 (vbias)
loads       : XR3/XR1 res_high_po_0p69 L=7
```

Sample and regeneration pairs are **equally sized**. A CML latch normally wants
the sample pair stronger than the regeneration pair (~1.5:1 to 2:1) so a new
value can overpower the stored one. At 1:1, with only a 41% transparent
window, the slave cannot win — consistent with the measured hard latch
(one CML node pinned at 1.792V, i.e. essentially zero current in that load).

**This is §12a/§12d's "~5% margin" fragility finally becoming the active
blocker, exactly as flagged.**

### Two concrete sizing levers (both pure sizing, no architecture change)

1. **Sample:hold ratio** — widen `d_latch` XM1/XM4 (W=5 -> ~8), and/or narrow
   XM3/XM5 (W=5 -> ~3), so a new value can overwrite the held one.
2. **Clock duty toward 50%** — the 41/59 split originates upstream (VCO core
   is already 44.6%, `diff_amp_inv` degrades it to 39.5%). Fixing duty helps
   the slave *and* removes the master/slave asymmetry entirely.

Lever 1 is the more direct fix for the jam; lever 2 fixes the underlying
asymmetry and benefits every stage. They are independent and can be tested
separately. **Neither has been tried yet.**

### Note on the E architecture itself

The inverter-derived `clk-` did exactly what it was supposed to (sum 1.796V,
all pairs legal) and should be kept. `clkraw-` is now dangling — `x4` still
drives it but nothing reads it. Worth noting that E *creates* the 41/59 duty
split as a strict complement: previously both clocks were skewed the same way
(41/41), now one is 41 and the other 59. So E converted a complementarity
error into a duty error. A proper differential slicer on `clkraw+ - clkraw-`
would fix both at once and remains the right long-term answer.

---

# §14. Session 4 — THE LOOP LOCKS. Root cause was a factor-of-2 frequency plan error.

## 14a. The target frequency in §2 was wrong by 2x

`CDR_tb.sch` drives the data input with:

```
V2 vin+ PULSE(0 1.8 0 10p 10p 1.67n 3.33n)
```

§2 read this as "a 300.3 MHz square wave" and set the VCO target to 300 MHz.
That is the wrong quantity. For a CDR what matters is the **symbol period, which
is 1.67 ns** — this is an alternating 1010 pattern at **600 Mb/s**. An Alexander
PD requires its clock at the **baud rate**, so the recovered clock target is
**600 MHz**.

**The original, untuned ring oscillator ran at 600.7 MHz. It was already correct
by design.** The retune in §3/§11 (R: 23 -> 54 -> 50.75) walked the VCO to
~296 MHz — exactly half the required rate — and every session since has been
debugging the consequences.

### Confirmed directly on a standalone PD bench

Drove `alexander_phase_detector_tune` with the *actual* `CDR_tb` data stimulus
(toggling every 1.67 ns) and varied only the clock frequency:

| clock | up pp | down pp | up avg | down avg |
|-------|-------|---------|--------|----------|
| 296 MHz | **0.003 V** | **0.006 V** | 1.79999 | 1.79999 |
| 600 MHz | 1.972 V | 1.958 V | 0.386 | 1.566 |

At 296 MHz the PD is completely dead with both outputs DC-pinned high — **this is
exactly the symptom §11 diagnosed as "both up and down parked high."** Sampling a
1010 pattern at half the baud rate always lands on the same bit polarity, so every
flop output freezes at a constant value. That is also precisely §13h's "PD is now
DC-frozen, Q pinned at 0 V, Qn at 1.8 V, all four pairs legal but constant."

## 14b. Two mechanisms from §13h are refuted — do not pursue them

**Lever 1 ("sample:hold ratio is 1:1, new value can't overpower the stored one")
is not a real mechanism.** The netlist shows a proper current-steering CML latch:

```
XM6 net3 clk+ net4   <- steers tail to sample pair XM1/XM4
XM7 net5 clk- net4   <- steers tail to regen pair XM3/XM5
```

These are **mutually exclusive** under a rail-to-rail clock. When clk+ is high,
XM7 is fully off and the cross-coupled pair receives *zero* tail current — there
is nothing to overpower. The 1:1 sizing is irrelevant to overwrite strength.

**Lever 2 ("41% duty starves the slave's write window") is refuted empirically.**
Standalone `d_flip_flop_tune`, 300 MHz, full-rail data, duty swept:

| duty | 50% | 45% | 41% | 35% | 30% |
|------|-----|-----|-----|-----|-----|
| Q pp | 1.851 | 1.851 | 1.851 | 1.851 | 1.851 |
| avg(Q)+avg(Qn) | 1.761 | 1.761 | 1.761 | 1.761 | 1.761 |

Identical at every duty down to 30%. Also tested variant E's skewed `clk-`
(clk- = inverted clk+ delayed by 0/25/50/100 ps): still healthy, sum degrades
only 1.758 -> 1.715. **The flip-flop is not the problem under any clock condition
that could be constructed.** The freeze was always the 2x frequency error.

## 14c. Change applied and the result

Single change: `ring_inverter_tune.sch` R1/R2 `L = 50.75 -> 23`. Verified by
`diff` against the original that the only remaining delta is M5 `W=3 -> W=9`
(§6), per the §13a lesson. Everything else from §5/§9/§13b/§13f kept as-is.
Full `CDR_tune_tb` re-run, `tran 20p 1500n`, 10x-shrunk loop filter caps.

```
clk+ pp        = 1.876 V                       (rail-to-rail)
clk+ avg 0.641 + clk- avg 1.152 = 1.792 V      (complementary — variant E holds)

up   avg = 0.586 V   pp = 1.952 V              <- NOT pinned
down avg = 1.275 V   pp = 1.902 V              <- NOT pinned

vctrl: 0.755 (100-250ns) -> 0.792 (600-750ns) -> 0.792 (1350-1500ns)   settled
```

`up` and `down` now sit at genuinely different, intermediate levels — the first
time in this log that the PD is producing real bang-bang decisions rather than
parking at a rail. (Note the §11 lesson applied: these are **averages**, not pp.)

### Frequency — this is the result

```
clk+ period (700-800ns,  40 cycles): 1.6644 ns -> 600.83 MHz
clk+ period (1400-1500ns, 40 cycles): 1.6653 ns -> 600.47 MHz
data symbol period:                   1.6650 ns -> 600.60 MBaud

frequency error: -0.02 %
```

**The CDR is frequency-locked.** Best previous result was 1.3% error (§13c) and
that was against a target that was itself wrong by 2x. Lock is stable across both
measurement windows.

Bonus: vctrl settling at 0.792 V sits ~140 mV above the ~0.65 V dead-zone cliff,
versus ~45 mV of margin in §13g. Standing risk 2 from §13g is substantially
reduced (not eliminated).

## 14d. Caveats — what this run does NOT yet establish

1. **Loop filter caps are still 10x shrunk** (§10 speed trick). The equilibrium
   should be unchanged but the real design settles ~10x slower. A confirming run
   with real caps has not been done.
2. **Duty is now ~35.6%** (clk+ avg 0.641/1.8), worse than §13's 41%, though
   complementarity holds at 1.792 V. It locked anyway, but this is margin being
   spent for nothing. The proper differential slicer on `clkraw+ - clkraw-`
   (§13f) remains the right fix and would address duty and complementarity together.
3. **Jitter has never been measured.** It is finally meaningful to measure —
   there is now a real lock to measure around. This is the obvious next task.
4. **Nominal `tt` only.** No PVT/corner runs on any of this work.
5. **M5 `W=9` (§6) was chosen to fight a dead zone at the wrong target frequency.**
   Worth re-testing whether W=3 now suffices, which would recover the area.
6. `d_latch`'s CML common mode (1.467 V) vs inverter trip (~0.87 V) mismatch
   (§12a, §13g standing risk 1) is still unaddressed. It did not block lock, but
   it remains the thinnest margin in the design.

## 14e. Method lesson

Three sessions of increasingly deep component-level debugging (§11-§13) were spent
on a system whose **frequency plan was wrong by 2x**. Every component investigated
was found to be individually healthy, and each session concluded by relocating the
failure rather than resolving it — §11 "both parked high", §13h "both parked low".
That pattern (every block passes standalone, the system still fails, the failure
keeps moving) is a strong signal to **re-derive the top-level spec from the
stimulus** before continuing to divide and conquer.

Concretely: **verify the testbench's own numbers before tuning to them.** The
symbol period, not the square-wave frequency, sets the CDR clock rate.


# §15. Session 6 — real-cap acquisition fails; the root cause is architectural, not a tuning miss

## 15a. The problem, stated precisely

§14 locks the loop at 600.6 MHz **but only with the 10x-shrunk loop-filter caps**
(§10 speed trick). With the **real production caps** (cap1 `L=6 W=4 mult=6`,
cap2 `W=11 L=2`) the loop **does not acquire lock** from cold start:

- At t=0 vctrl=0, there is no recovered clock, so the Alexander PD has nothing to
  compare against and **parks `down` high** -> the charge pump net-*discharges*
  the filter. vctrl briefly kicks to ~0.75 V then bleeds back down.
- With shrunk caps vctrl moves fast enough to grab a clock and acquire before it
  falls through the VCO's ~0.65 V dead-zone cliff. With real (10x bigger) caps
  vctrl moves ~10x slower, drifts through the cliff first, the VCO dies, the clock
  vanishes, the PD stays parked, and vctrl sticks at ~0.5 V for the whole run.

An **idealized** test (force vctrl >= 0.72 V) makes the whole loop lock cleanly at
600 MHz -> every block is individually healthy. **The only failure is acquisition:
the transient path to lock, not any block.**

## 15b. The source-follower clamp is dead (do not revisit)

Plan tried: raise ring R to 23.5 to lift the lock point (~0.9 V) and widen the
cliff->lock window, then hold vctrl up with an NFET source-follower clamp
(gate from a Vdd resistor divider, source = vctrl). It **cannot thread the window**:

| Rbot L | gate V | vctrl floor | result |
|--------|--------|-------------|--------|
| 11     | 1.194  | ~0.50 V     | dead (below cliff) |
| 12     | 1.225  | **0.53 V**  | dead (below cliff) — run_A this session |
| 13     | 1.253  | ~1.0 V      | loop acquires but overshoots ABOVE lock window |

~28 mV of gate voltage flips the floor from 0.53 V to 1.0 V — **near-vertical
transfer**, jumping straight over the 0.65-0.9 V target. In subthreshold the
follower is a high-impedance node: it either doesn't hold or lets the loop
overshoot. No manufacturable gate value lands vctrl in the window. Abandoned.

## 15c. Root cause — a PLL was repurposed as a CDR, deleting frequency acquisition

The blocks are from the TinyTapeout **PLL**, which acquires frequency with a
**reference clock + divider + phase-FREQUENCY detector (PFD)** (`tiny_pll_pfd`,
4 SR latches; `tiny_pll_divider`, 4-bit programmable). A PFD drives vctrl toward
the correct frequency **from any start** — true frequency pull-in — so large
(slow) loop caps are fine, even desirable (low jitter) in a PLL.

We built a **CDR** by removing the reference/divider/PFD and dropping in an
Alexander **bang-bang** phase detector. A bang-bang PD corrects **phase only —
zero frequency pull-in.** It can only lock if the VCO already runs near 600 MHz.
So:

- The VCO is fine (600 MHz at vctrl~0.79 V). The caps only feed the loop filter.
- The real caps are correctly sized for a loop that HAD a PFD. Removing the PFD
  removed the mechanism that made slow caps OK. **Not a frequency limit; a missing
  frequency-acquisition mechanism.**

### Can we reuse the PLL's PFD + divider? No — there is no reference clock.

The PFD needs an independent, accurate frequency source on `clk_ref`. Our ring
oscillator is the `clk_vco` side (the thing being tuned — a loop can't lock to
itself). The data stream `vin+` is only a **phase** reference (irregular edges ->
no clean frequency). **Decision (user, session 6): the CDR is reference-less; there
is no reference clock available.** The PFD path is therefore unusable and ruled out.

## 15d. Chosen direction — validate the shrunk caps as the legitimate CDR design

Reframe: a bang-bang CDR *wants* higher loop bandwidth (smaller caps) than a PLL.
The shrunk caps may not be a "cheat" — they may be the correct CDR retune, since
smaller caps -> higher bandwidth -> acquire before drifting into the dead zone,
which is exactly what we see. The only legitimate objection to small caps is
**jitter** (too much bandwidth tracks noise onto the recovered clock), and jitter
has never been measured. Plan (user-directed, running overnight, single sims only,
niced + nohup): measure jitter on the shrunk-cap lock; if acceptable, the shrunk
caps ARE the design and no clamp/startup circuit is needed. See §16.


# §16. Session 6 (cont.) — jitter on the shrunk-cap lock is small; shrunk caps look legitimate

## 16a. Setup

Branch `cdr-shrunk-cap-jitter`. Config: shrunk caps (cap1 `L=0.6 W=4 mult=6`,
cap2 `W=1.1 L=2`) + ring R=23 (the §14 600.6 MHz lock point). `tran 20p 2000n`,
real production loop filter NOT used (this branch is the shrunk-cap validation).
Jitter extracted in python (`runs/analyze_jitter.py`, pure stdlib) from a
`wrdata` dump of `v(clk+)`, over the locked window 1200-2000 ns, rising crossings
through 0.9 V with linear interpolation.

## 16b. Result — locks dead-on, jitter is small

- vctrl settles at **0.792 V**, clk+ swings rail-rail (pp 1.877 V), `down`
  dithers at 1.275 V avg (healthy bang-bang, not parked).
- Frequency **600.616 MHz** (+0.003% vs 600.6 target) over 479 periods.
- **RMS period jitter 11.27 ps = 0.68% UI.**
- **pk-pk period jitter 41.12 ps = 2.47% UI.**
- Periods cluster at ~1645 and ~1686 ps (+-20 ps around 1665 ps mean) — the
  classic bang-bang two-state limit-cycle dither, not numerical noise. Numerical
  floor here is ~0.1 ps (reltol 1e-3 -> ~1.8 mV / ~18 mV·ps^-1 slew).

**Interpretation:** a bang-bang CDR wants higher loop bandwidth (smaller caps)
than a PLL; the shrunk caps give clean acquisition AND only ~0.7% UI RMS hunting
jitter. On this stimulus the shrunk caps are a legitimate CDR retune, not a cheat.

## 16c. The one caveat that can still break this — CID (consecutive identical digits)

The testbench data `V2 vin+ = PULSE(...1.67n 3.33n)` is a **0101 clock pattern —
every symbol has a transition.** That is the optimistic case for a CDR. Real data
(PRBS) has **runs of no transitions**; during a run the bang-bang PD gets no phase
info and the VCO runs **open-loop**, so vctrl/phase drift. Crucially, **smaller
caps drift MORE per cycle** (less stored charge, higher sensitivity), so CID could
hurt the shrunk-cap design specifically — exactly what the 0101 jitter number does
NOT capture. This is the decisive remaining test: stress with a data run of K
identical symbols and measure recovered-clock phase drift. See §16e.

## 16e. CID stress result — shrunk caps PASS (runs of 5/10/15 UI, loop stays locked)

Built a PWL data stimulus (`runs/cid.spice`) = the 0101 pattern with three
no-transition bursts inserted: run lengths **5, 10, 15 UI** at ~1200/1367/1542 ns,
separated by ~90-cycle alternating recovery regions. Same shrunk-cap + R=23 config.
`wrdata cid.dat v(clk+) v(x1.net1)`, analyzed by `runs/cid_analyze.py`.

| window        | f (MHz) | vctrl range   | note              |
|---------------|---------|---------------|-------------------|
| baseline lock | 600.57  | 0.774-0.811   | normal dither     |
| RUN5          | 607.4   | 0.802-0.815   | coasts open-loop  |
| RUN10         | 606.2   | 0.800-0.813   | coasts open-loop  |
| RUN15         | 602.8   | 0.784-0.801   | coasts open-loop  |
| end (relock)  | 600.41  | 0.772-0.813   | fully re-locked   |

- **Loop never loses lock.** During a blind run the VCO coasts with only ~1%
  frequency offset (~5% UI phase slip over 10 UI), then the PD pulls it back within
  the ~90-cycle recovery region (back to 600.3-600.4 MHz).
- **vctrl drifts <20 mV during runs, and UPWARD (toward 0.80 V) — the SAFE
  direction, away from the 0.65 V dead-zone cliff.** Never approaches danger.
- 15 UI > PRBS15 max run; 8b/10b max run is 5. Real coded data is well covered.

**Conclusion: shrunk caps pass both jitter (§16b) and CID (§16e) — a legitimate CDR
retune, not a cheat. No clamp/startup circuit is required for data-driven behavior.**
Remaining open item is cold-start acquisition robustness (§16f), a distinct
initial-condition question.

## 16f. Watch item — cold-start acquisition is sensitive to the t=0 data seed

Discovered while building the CID test: the FIRST CID attempt failed to acquire
(vctrl stuck ~18 uV, VCO dead the whole run) purely because the PWL source had
`vin+ = 1.8` at t=0 — the `.op` DC seed had the OPPOSITE data polarity to the
`PULSE` sources (which sit at `vin+=0, vin-=1.8` before their first edge). Matching
the PULSE seed (prepend a pre-edge so `vin+` starts at 0) made it lock normally.
So the §14/§16 lock may depend on a favorable power-up data polarity. A real link
can power up on either polarity -> **must verify the loop acquires from the opposite
`.op` seed too** (test queued, §16g). If it fails, a cold-start aid (the §15 startup
precharge, now for acquisition robustness rather than for real caps) may be
warranted even with shrunk caps.

## 16g. Polarity robustness test — FAIL: acquisition depends on power-up polarity

Re-run safely under `safe_ngspice.sh` (memcap 2.5G, watchdog, 1200n, save-limited,
no raw — `runs/pol_light.spice`). Opposite `.op` seed = swap the two PULSE initial
values so `vin+` starts HIGH. **Result: the loop NEVER acquires.**
- e_vctrl (40-120n) = 18 uV, m_vctrl (600-700n) = 18 uV, l_vctrl (1100-1200n) = 18 uV
  — vctrl stuck at ~0 the whole run.
- l_cp_pp (1100-1200n) = 6 mV — clk+ not swinging, VCO dead.
- c600/c660 crossings "out of interval" — no clock ever oscillated.

The ONLY change vs the locking §16b jitter run is the swapped power-up polarity, so
this is a genuine effect: **the §14/§16 lock depends on a favorable initial data
polarity.** Cold-start kicks vctrl up only when the t=0 PD/latch state (set by the
`.op` data seed) drives `up`; from the other seed the CP net-discharges and vctrl
never clears the 0.65 V dead-zone cliff. Mechanistically identical to the real-cap
failure (§15a), just triggered by polarity instead of cap size.

**Implication:** shrunk caps fix cap-size acquisition and pass jitter+CID, but
cold-start is not polarity-robust. A real link can power up either way (~50% fail).
So a polarity-independent cold-start aid IS needed even with shrunk caps — the §15
startup precharge, now justified for cold-start robustness (NOT for real caps).
Next: validate that precharging vctrl to ~0.79 V lets the bad polarity acquire
(§16h).

## (superseded) earlier note — polarity test had been paused after a VM crash

The opposite-`.op`-seed acquisition test (`pol.spice`: swap the two PULSE initial
values so `vin+` starts HIGH, otherwise identical to §16b) was launched but the VM
crashed mid-run and it produced no output. **User directive after the crash: stop
running the heavy CDR sims on this VM.** So §16g is left OPEN and is the FIRST thing
to check when a run environment is available:
  - Expect PASS -> shrunk caps fully validated on cold-start.
  - If FAIL -> the loop only acquires for a favorable power-up polarity; add the
    §15 startup precharge as an acquisition aid (not for real caps, but for
    polarity-independent cold start).
Netlist is ready at `runs/pol.spice` (regenerable from schematics + the swap).
Each CDR tran is ~8-10 min single-threaded and is heavy for this VM: run ONE at a
time, `nice`d, and not while doing other work.

## 16d. Method note — the .op NaN spam is cosmetic

The batch log prints hundreds of `lintnoi/llambda/... <<NAN, error=7>>` lines. That
is ngspice's `.op` operating-point report choking on unfilled noise-model params;
it does NOT affect the tran run (exit 0, tran completes, meas + wrdata all valid).
Ignore it, or drop the `.op` line to silence it.
