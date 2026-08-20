![tests](../../workflows/test/badge.svg) ![docs](../../workflows/docs/badge.svg)

# Analog CTLE + Clock Recovery — a 600 Mb/s receiver front end

A fully analog receiver front end for Tiny Tapeout (sky130, custom GDS): a
continuous-time linear equalizer (CTLE) that undoes the loss of the chip's own
analog pin path, feeding a **reference-less bang-bang clock-and-data-recovery
loop** that locks an on-chip ring oscillator to the incoming data. There is no
reference clock on the chip — the output clock is generated from the data
itself, which is why `clock_hz` is 0 and the harness `clk` pin is unused.

- **[Project datasheet](docs/info.md)** — how it works, pinout, how to test on hardware.
- **[Verification methodology](docs/DESIGN.md)** — what was simulated, how, and what each number means.
- **Design logs** — [`xschem/tuning/NOTES.md`](xschem/tuning/NOTES.md) (CDR, §1-§20)
  and [`xschem/tuning/ctle/NOTES_CTLE.md`](xschem/tuning/ctle/NOTES_CTLE.md)
  (CTLE and end-to-end, §C1-§C26). Chronological, including the dead ends.

## State of the project

| | |
|---|---|
| **Works** | The full chain is simulated end to end and locks: 200 mVpp differential in through a worst-case model of the TT analog pin path → CTLE → CDR → a recovered 600.64 MHz clock, on both an alternating 0101 pattern and PRBS7. |
| **Verified** | ngspice: AC across 27 PVT corners, transient eye diagrams at the corner extremes, 45-corner PVT on the startup cell, an 11-corner VCO tuning-range sweep, and four 3 µs full-chain transients (pattern, polarity, amplitude). Netlist-level: the promoted schematics were compared subcircuit-by-subcircuit against the validated sandbox — all 17 leaf subcircuits matched. |
| **Not done** | **Layout.** Nothing has been drawn. `mag/` holds the empty 2×2 frame, the toolchain, and a proven-to-run `make lvs` that today correctly reports 0 devices on the layout side against 224 on the source side. Also not done: PVT on the *combined* loop, and a trustworthy sampling-phase jitter measurement (see the table). |
| **Known limitation** | The ring oscillator cannot reach 600 MHz at 125 °C or at a 1.62 V supply. This is characterised, understood (it is RC-limited by the load resistor, not current-starved) and **accepted**, not fixed — see §20b. |

Because there is no GDS yet, the Tiny Tapeout `gds` workflow is gated on the
existence of `gds/` and skips itself rather than failing; there is deliberately
no GDS badge above until there is something real behind it.

## Measured results

Every number below comes from a specific simulation recorded in the design
logs, cited in the last column. Nothing here is estimated or extrapolated.

| quantity | value | where it comes from |
|---|---|---|
| Channel: TT analog pin path (spec worst case, 500 Ω / 5 pF) | pole at 63.7 MHz, **−13.7 dB at Nyquist** (300 MHz) | §C16 |
| Eye at the pad before equalization, 200 mVpp in | **fully closed** (−5 mV, 0.000 UI) | §C16 |
| CTLE gain at Nyquist | +11.71 … +14.40 dB over 27 PVT corners (+13.32 dB nominal) | §C18, §C20 |
| CTLE boost (Nyquist gain − DC gain) | +6.30 … +7.90 dB over 27 PVT corners | §C18 |
| Channel + CTLE combined at Nyquist | **−2.03 … +0.66 dB** — flat to ±2 dB over the whole corner box | §C18 |
| Equalized eye, worst corner (ss / 125 °C / 1.62 V) | **174 mV, 0.350 UI** | §C22 |
| Equalized eye, nominal / best corner | 232 mV, 0.430 UI / 273 mV, 0.485 UI | §C22 |
| CTLE output common mode across corners | moves 362 mV (1.149 → 1.511 V) | §C22 |
| End-to-end lock frequency (0101, spec-worst channel) | **600.64 MHz** on 600.6 Mb/s data (+0.006 %) | §C23 |
| Control voltage at lock | 0.791 V end-to-end vs 0.792 V for the CDR alone — the same lock point | §C23, §17e |
| Signal at the CTLE input → output (0101) | 63.7 mV → 299 mV differential (≈ 4.7×) | §C23 |
| PRBS7 acquisition | settles in ~3 µs vs ~1 µs for 0101; overshoots +37 mV, then −26 mV, then −2.7 mV — a damped ring | §C25-B |
| Residual control-voltage ripple | 33.7 mV pp (0101) → 93.8 mV pp (PRBS7) | §C25-A, §C25-B |
| Ripple mechanism | bang-bang quantisation: 1.27 µA × 1.665 ns / 121 fF ≈ 17 mV per update, ~35 mV pp predicted vs 33.7 mV measured | §C25-E |
| Charge-pump up/down match | 1.263 µA up vs 1.284 µA down (1.6 %); both-on leakage 20.6 nA → 2.0 mV per 7-UI run | §C25-E |
| Power-up polarity independence | precharge releases at 126.49 vs 126.56 ns; both polarities converge to 0.799-0.801 V | §C25-C |
| Input sensitivity | 200 mVpp comfortable; **100 mVpp marginal** (path stays linear — 2.00× at the input, 1.92× at the output — but the loop wanders ±40 mV) | §C25-D |
| Cycle-to-cycle jitter, full chain on PRBS7 | 24.59 ps RMS = **1.48 % UI**; 128.8 ps pk-pk = 7.74 % UI | §C26 |
| Cycle-to-cycle jitter, CDR alone on ideal data | 0.68 % UI RMS, 2.5 % UI pk-pk | §16b |
| Sampling-phase error vs the data eye | **not measured.** §C26 produced a phase-wander figure against a best-fit clock in a window that still contained settling; it is documented there as not usable, and the correct measurement is specified but has not been run | §C26 |
| Startup precharge across PVT | **45/45 corners pass** from a cold supply ramp with no `.ic`: seed 0.693-0.908 V, release 136-167 ns | §20a |
| VCO tuning range (tt / 27 °C) | 514-621 MHz; 6 of 11 swept corners pass, the 5 failures are 125 °C and 1.62 V | §20b |
| Combined-loop PVT | **not measured** — the T2 tier is generated and ready but was never run | `xschem/tuning/HANDOFF.md` §5 |
| Flattened device count (source side of LVS) | 224 devices, 129 nets | `mag/LAYOUT_HANDOFF.md` |
| Die area | 2×2 tiles = 334.88 × 225.76 µm = 75 603 µm² | `mag/LAYOUT_HANDOFF.md` |

The headline is the second and fifth rows together: **the eye is already shut at
the pad**, and one CTLE stage reopens it to 174 mV / 0.350 UI at the worst
corner. The equalizer is not an optimization here, it is what makes the link
exist at all.

## Signal path

```
                            THE CHANNEL IS THE CHIP'S OWN PIN
                        (TT spec: < 500 Ω series, < 5 pF pad
                         = a 63.7 MHz pole, -13.7 dB at Nyquist)

  200 mVpp diff        ┌───────────┐        64 mVpp        ┌────────────────┐
  600.6 Mb/s   ─ua[0]─►│  R  ──┬── │──────── eye closed ──►│      CTLE      │
  PRBS7        ─ua[1]─►│       C   │                       │  degenerated   │
                       └───────────┘                       │   diff pair    │
                          pad RC                           └───────┬────────┘
                                                                   │ 299 mVpp
                                                      equalized data│ eye reopened
     ua[2] = vbias (~0.9 V, external)                              │
                                                                   ▼
   ┌───────────────────────────── CDR (reference-less) ─────────────────────────┐
   │                                                                            │
   │   ┌──────────────────────┐   up   ┌────────────┐      ┌─────────────────┐  │
   │   │  Alexander phase     ├───────►│   charge   ├─────►│   loop filter   │  │
   │   │  detector            │  down  │    pump    │      │  (~10x smaller  │  │
   │   │  4x DFF + 2x XOR     ├───────►│            │      │   than a PLL's) │  │
   │   └──────────▲───────────┘        └────────────┘      └────────┬────────┘  │
   │              │                                          vctrl  │ 0.791 V   │
   │              │ sampling clock                                  ▼           │
   │              │                    ┌───────────────────────────────────┐    │
   │              └────────────────────┤  5-stage differential ring VCO    │    │
   │                                   └─────────────────┬─────────────────┘    │
   │   ┌─────────────────────┐                           │                      │
   │   │ startup precharge   │──── seeds vctrl for       │                      │
   │   │ (M5-replica bias)   │     ~130 ns, then         │                      │
   │   └─────────────────────┘     removes itself        │                      │
   └─────────────────────────────────────────────────────┼──────────────────────┘
                                                         │
                                    ┌────────────────────┴────────────────────┐
                                    ▼                                         ▼
                            inverter chain                            inverter chain
                                    │                                         │
                                    ▼                                         ▼
                          uo[0] recovered clock                     uo[1] inverted phase
                            600.64 MHz, full rate               (also loads the ring
                                                                 symmetrically — not
                                                                 a true complement)
```

The loop is **phase-only**: an Alexander detector reports early/late, never
frequency. That has two consequences that drive most of the design log — the
loop filter had to shrink ~10× from its PLL-derived values for acquisition to
be possible at all (§16), and cold start needed a real startup circuit because
~50 % of power-ups otherwise never acquired (§17).

## Repository layout

| path | what |
|---|---|
| `xschem/ctle_cdr_rx.sch` | **the analog macro that gets laid out** — CTLE → CDR → output buffers |
| `xschem/ctle_cdr_rx_lvs.sch` | one-instance wrapper; netlisting this is what emits a `.subckt` for netgen |
| `xschem/CTLE.sch`, `xschem/CDR.sch` | the two main blocks, and the 20 cells below them |
| `xschem/STATUS.md` | state of the real design files, and the 2026-08-15 promotion |
| `xschem/attic/` | retired testbenches and exploration schematics, kept because the logs cite them |
| `xschem/tuning/` | the simulation sandbox: testbenches, decks and the PVT harness |
| `xschem/tuning/NOTES.md` | the CDR design log, §1-§20 |
| `xschem/tuning/ctle/NOTES_CTLE.md` | the CTLE and end-to-end design log, §C1-§C26 |
| `xschem/tuning/HANDOFF.md` | current state and open items |
| `xschem/tuning/c25_summary.txt` | raw `meas` output of the four 3 µs end-to-end runs |
| `docs/DESIGN.md` | verification methodology — start here to understand *how* it was checked |
| `src/project.v` | blackbox Verilog: the pad ↔ macro wiring that LVS checks |
| `mag/` | Magic layout: `make lvs` / `make drc` / `make update_gds`, plus `LAYOUT_HANDOFF.md` |
| `test/` | repository-consistency tests (pytest, no PDK or simulator needed) |

## Tests

The test suite checks the things that rot silently: that `info.yaml`,
`src/project.v` and the magic top cell still agree on the module name, tiles and
pin mapping; that every symbol in the frozen xschem hierarchy still resolves
(xschem netlists a missing symbol *silently*, which is the exact failure mode
these catch); and that the documentation does not cite design-log sections or
files that no longer exist.

```console
$ pip install -r test/requirements.txt
$ pytest test/
```

No PDK, no ngspice, no magic, no network. The whole suite runs in well under a
second, and runs on every push via `.github/workflows/test.yaml`.

## Running the simulations

Simulations on the development VM must go through
`xschem/tuning/safe_ngspice.sh`, which caps memory and wall-clock time and
watches `/proc/meminfo`. That is not a style preference — an unguarded ngspice
has already OOM-crashed this machine once. See `CLAUDE.md` for the full rules
and for the tool traps (xschem, ngspice and sky130 corner handling) that cost
real time on this project.

## What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

## Analog projects

For specifications and instructions, see the [analog specs page](https://tinytapeout.com/specs/analog/).

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
