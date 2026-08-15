![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg)

# Analog CTLE + Clock Recovery — a 600 Mb/s receiver front end

A fully analog receiver front end for Tiny Tapeout (sky130, custom GDS): a
continuous-time linear equalizer that undoes the loss of the chip's own analog
pin path, feeding a **reference-less bang-bang clock-and-data-recovery loop**
that locks an on-chip ring oscillator to the incoming data. There is no
reference clock on the chip — the output clock is generated from the data
itself.

- **[Read the project datasheet](docs/info.md)** — how it works, pinout, how to test.

```
ua[0] ─┐                        ┌─ Alexander phase detector ─┐
       ├─► CTLE ──► equalized ──┤   charge pump + loop filter │──► uo[0]  recovered clock
ua[1] ─┘            data        └─ 5-stage ring oscillator ◄─┘    uo[1]  inverted phase
ua[2] = vbias
```

## Status

The design is drawn and simulated; **layout has not started**. The signal path
is verified end to end in ngspice through a worst-case model of the Tiny
Tapeout analog pin path (500 Ω / 5 pF), which on its own attenuates a 200 mV
differential input to about 64 mV — the eye is essentially shut at the pad
before any circuit touches it. The CTLE recovers roughly +13.5 dB at Nyquist,
which very nearly exactly cancels that, and the CDR then locks at 600.64 MHz.

On real data (PRBS7, with runs of up to seven identical bits) the loop still
acquires, but takes about 3x longer and settles with ~2.8x the residual control
voltage ripple. That is inherent to a bang-bang loop — during a run of identical
bits there are no transitions, so the loop is briefly blind and phase error
accumulates before it can be corrected. The open question is now
**jitter**: how much sampling-phase error that ripple produces has not been
measured. See `xschem/tuning/ctle/NOTES_CTLE.md` §C24-§C25.

## Repository layout

| path | what |
|---|---|
| `xschem/ctle_cdr_rx.sch` | **the analog macro that gets laid out** — CTLE → CDR → output buffers |
| `xschem/CTLE.sch`, `CDR.sch` | the two main blocks, and their hierarchy below |
| `xschem/STATUS.md` | state of the real design files — **start here** |
| `xschem/tuning/` | the simulation sandbox, testbenches and PVT harness |
| `xschem/tuning/NOTES.md` | the CDR design log, §1-§20 |
| `xschem/tuning/ctle/NOTES_CTLE.md` | the CTLE + end-to-end design log, §C1-§C24 |
| `xschem/tuning/HANDOFF.md` | current state and open items |
| `src/project.v` | blackbox Verilog: the pad ↔ macro wiring that LVS checks |
| `mag/` | Magic layout, `make lvs` / `make drc` / `make update_gds` |

Simulations on the development VM must be run through
`xschem/tuning/safe_ngspice.sh`, which caps memory and wall-clock time — see
`CLAUDE.md` for why that is not optional.

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
