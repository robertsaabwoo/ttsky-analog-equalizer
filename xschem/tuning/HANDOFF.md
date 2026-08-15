# HANDOFF — state of the project as of 2026-07-23

> ## UPDATE 2026-08-15 — read this before the rest of the file
>
> Two things below are now out of date:
>
> 1. **The sandbox has been promoted.** `xschem/*.sch` now hold the validated
>    design, verified netlist-for-netlist against `tuning/e2e_blocks.inc` (all
>    17 leaf subcircuits match exactly). See `../STATUS.md` → "Promotion,
>    2026-08-15". The chip top level is the new `xschem/ctle_cdr_rx.sch`, and
>    `src/project.v` + `mag/` are wired up for the TinyTapeout custom-GDS flow.
>
> 2. **"The CDR locks" is weaker than §1 below implies.** Everything in §1 and
>    in NOTES_CTLE §C23 was measured with either ideal data or an alternating
>    0101 pattern — the easiest possible input for a bang-bang phase detector,
>    because every bit is a transition. §C24 ran the first **PRBS7** end-to-end
>    test and the loop had **not settled after 2 µs**: vctrl drifts 0.791 →
>    0.828 V and dithers 161 mV pp (vs 33 mV on 0101). The §16 loop-filter
>    shrink was sized against 0101, and it is in direct tension with tolerating
>    runs of identical bits. **Confirming settling on real data is the open
>    merge gate.** See NOTES_CTLE §C24.
>
> Also from §C24: `rclk-` is NOT an instantaneous complement of `rclk+` — it is
> `rclk+` through an inverter, and the two phases have ~33 % / ~61 % duty
> cycles. §13h's average-sum check could not have caught this.

Written at the end of session 7, for whoever picks this up next. The user is
**pivoting to CTLE work in a new session**; the CDR thread below is finished and
parked, not abandoned mid-flight.

Read `../../CLAUDE.md` for the VM rules and the tool traps — those apply to CTLE
work exactly as much as they did to the CDR.

---

## 1. TL;DR

The CDR sandbox loop **works**: it locks at 600.6 MHz, jitter is 0.68 % UI RMS, it
survives CID runs to 15 UI, and cold start is polarity-independent thanks to a
startup precharge cell that is built, PVT-tested and passing 45/45.

The one known limitation is the **ring oscillator's tuning range**, which cannot
reach 600.6 MHz at 125 °C or at 1.62 V. **The user has explicitly accepted this and
de-scoped it.** Do not go fix it unless asked.

Branch: `cdr-shrunk-cap-jitter`. All work committed and pushed.

## 2. What was concluded about the CDR (the short version)

Chronology is in `NOTES.md`; the load-bearing conclusions:

1. **The architecture is a TinyTapeout PLL repurposed as a reference-less
   bang-bang CDR.** Removing the reference clock, divider and PFD removed all
   frequency-acquisition capability. A bang-bang PD is phase-only. **There is no
   reference clock** — the user confirmed this. Re-deriving a PFD-based fix is a
   dead end; `tiny_pll_pfd` exists in the module but needs an independent trusted
   `clk_ref`, and the VCO is the `clk_vco` side. (§15c)
2. **The 300 MHz target in §2 was a 2× error** — that was the square-wave rate, not
   the baud rate. The design is 600 Mb/s, UI 1.665 ns. Three sessions of debugging
   traced back to this. (§14)
3. **The loop-filter caps had to shrink ~10×.** With the real (PLL-sized) caps,
   vctrl bleeds through the ~0.65 V VCO dead-zone cliff before a phase-only loop
   can acquire. A bang-bang CDR legitimately wants higher loop bandwidth than a
   PLL, so this is a correct retune, not a cheat. (§16)
4. **Cold start was polarity-dependent** — ~50 % of power-ups never acquired.
   Fixed with a startup precharge. (§16g/h → §17)

### Dead ends — do not re-attempt

- **The §15 source-follower clamp.** Near-vertical subthreshold transfer; ~28 mV of
  gate voltage flips the floor from 0.53 V to 1.0 V. There is no manufacturable
  landing in the 0.65-0.9 V window. It also fights the locked loop. Permanently
  abandoned.
- **Reusing `tiny_pll_pfd` / the dividers** for frequency acquisition — see (1).

## 3. The precharge cell (`vctrl_precharge_tune`) — §17, §20a

9 devices, instantiated as `x20` on the vctrl node in `CDR_tune.sch`.

```
VDD─[R1 686k]─┬─ nrc ─|>o─ pre ─|>o─ preb
            MCPOR     INV_A      INV_B    │
           (8×8 cap)                    MBP (pfet source)
              │                            │
             VSS                        nbias ─┬─ MBD (diode nfet, M5 replica)
                                    MSW (8/0.6)│
                                    gate=pre   VSS
                                        │
                                      vctrl
```

Two design decisions that matter and should survive any rework:

- **`MBD` is a scaled replica of the ring tail M5**, so the seed is "one overdrive
  above an NMOS threshold" and *tracks the dead-zone cliff over PVT* instead of
  being a hard-coded 0.79 V. This is why all 45 T1 corners pass. **If you ever
  resize M5, resize MBD identically** or the tracking breaks.
- **`MSW` opens before the bias branch collapses** (INV_B delay) and its gate then
  sits hard at 0 V, so the cell is electrically absent afterwards (~1 fA into
  vctrl). This is precisely what the §15 clamp could not do.

Verified: seed 0.693-0.908 V across all PVT, release 136-167 ns, self-starts from a
bare supply ramp with no `.ic` anywhere. Tightest margin is **31 mV at ff/−40 °C**
— see §20a for the caveat about T0's coarse resolution there.

## 4. Numbers worth not re-deriving

| quantity | value | where |
|---|---|---|
| baud rate / UI | 600.6 Mb/s / 1.665 ns | §14 |
| lock frequency | 600.63-600.78 MHz | §17e/f |
| vctrl lock point | 0.792 V | §17e |
| locked vctrl dither | ~45 mV pk-pk | §19d |
| jitter | 0.68 % UI RMS, 2.5 % UI pk-pk | §16b |
| VCO dead-zone cliff | ~0.65 V at tt/27 °C (0.65-0.79 over PVT) | §20b |
| VCO range at tt/27 °C | 514-621 MHz | §20b |
| CP crossover | ~0.663 V — sits on the cliff | §19a |
| ring load R | `res_high_po W=1 L=23` (~7.4 kΩ) | `ring_inverter_tune.sch:116,124` |

## 5. Open items (none urgent, none blocking)

- **T2 PVT tier was never run** (7 decks × ~15-20 min ≈ 2 h). It is generated and
  ready: `cd pvt && ./run_pvt.sh T2 --budget 3600`. It tests full-loop acquisition
  at corners. Given §20b, expect the 125 °C decks to fail on VCO range — that is
  the accepted limitation, and `collect_pvt.py` reports "VCO tuning range
  exhausted, not a precharge failure" so it will be obvious.
- `tt/27 °C/1.62 V` fails T0 (592 MHz max) — a **supply**-margin issue, distinct
  from the accepted temperature one. Flag if supply tolerance comes up.
- Proper differential slicer to replace the variant-E `clkraw-` inversion (§13f).
- `d_latch` ~5 % CML/inverter margin (§12a); the duty-cycle spend (§14d).
- Ring tuning range, if the spec ever widens — see §20b for why a resistor retune
  alone cannot work.

## 6. For the CTLE work specifically

**Sessions 8-9 did this — read `ctle/NOTES_CTLE.md` (§C1-C21) first.** Short
version: `CTLE.sch` had no peaking at all (its degeneration zero landed on top of
its own output pole), and it is retuned in the sandbox copy `ctle/CTLE_tune.sch`.

The channel turned out to be **the Tiny Tapeout analog pin path itself** — spec'd
at < 500 Ω and < 5 pF, i.e. a 63.7 MHz pole, which **closes the eye completely at
the pad** at 600 Mb/s. So the CTLE is load-bearing, not an optimization. Final
sizing `Win 20 / Lload 20 / Ldeg 5.0 / Wcap 18` gives 232 mV / 0.430 UI on that
worst case and passes 27 PVT corners at +6.3..+7.9 dB of boost. `CTLE.sch` itself
is still untouched — promotion is a *when*, not a *what*, now.

Four things that will bite whoever picks this up:
- the existing CTLE testbenches drive the input pair 8.5 dB into compression, so
  equalization can never show up in them — keep test inputs ≤ 400 mVpp diff;
- **`LA_Limiter` is abandoned** (user, 2026-07-24) and could not have been
  cascaded behind the CTLE anyway (PMOS pair, wrong input CM, mismatched loads);
- a two-stage CTLE was tried and rejected — it costs timing margin (§C19);
- `D2S_amp` (0.445 UI) is now the narrowest link in the chain and untuned.

Existing files: `xschem/CTLE.sch`, `CTLE.sym`, `CTLE_testbench.sch`,
`CTLE_WITH_LATCH.sch`. Untracked/WIP at the time of writing: `LA_Limiter.sch`,
`TSPC_Latch.sch`, `inverter_buffer.sch`, `tiny_pll*.sch`, plus a `mag/` and
`magic_challenge/` directory. **`git status` was dirty on `xschem/CTLE_WITH_LATCH.sch`
and several others — check what is intentional before committing anything broad.**

Suggestions from the CDR experience that transfer:

- Copy blocks into a `tuning/`-style sandbox before editing, so the real design
  stays clean and you can diff.
- Build the testbench so it prints a numeric summary (`meas` → log) as well as
  plotting. Every "the graph looks wrong" question here was answered faster by a
  number than by a trace.
- For an AC-heavy block like a CTLE, `.ac` runs are cheap — but the same VM rules
  apply to any transient/eye-diagram work, which is not cheap.
- The PVT harness in `pvt/` is CDR-specific in its decks but the *pattern*
  (generate from schematics → run sequentially under the guard → collect with
  explicit pass criteria) is worth reusing. `run_pvt.sh` is nearly generic.

## 7. Session history map in NOTES.md

`§1-9` early tuning · `§10-13` loop bring-up, variant experiments · `§14` **the
600 MHz breakthrough** · `§15` clamp dead end + architectural root cause ·
`§16` shrunk caps, jitter, CID, polarity failure · `§17` the real precharge cell ·
`§18` PVT harness · `§19` GUI testbench fix · `§20` **PVT results, temperature
accepted**.
