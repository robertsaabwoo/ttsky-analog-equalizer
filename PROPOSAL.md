# Equalizing Serial-Link Receiver Front-End with Programmable CTLE and Reference-Less CDR

**Chipalooza Challenge #2 (IHP SG13CMOS5L) — Design Proposal**

*This document contains no personal or institutional details. Designer CV(s) and the
list of available test equipment are submitted separately, per the challenge rules.*

---

## 1. Type of IP block

A **mixed-signal serial-link receiver (RX) front-end**: a continuous-time linear
equalizer (CTLE) with **digitally programmable boost**, followed by a
**reference-less bang-bang (Alexander) clock-and-data-recovery (CDR)** loop. The
block accepts a degraded differential NRZ data stream at the analog input,
equalizes the loss introduced by the pad and the shared-pin analog multiplexer, and
recovers a clean retimed data stream together with a synchronous recovered clock —
with **no external reference clock required**.

This is a self-contained SoC building block of the SERDES-RX / programmable-filter
class explicitly invited by the challenge brief, useful to any SoC that must receive
serial data over a lossy on-chip or chip-to-chip path.

**Why it fits this challenge specifically.** The rules state that projects share
analog pins through analog multiplexers, and ask each designer to state the
tolerable pad-to-project series resistance. That mux+pad path is a first-order
low-pass channel — precisely the loss this CTLE is built to invert. The equalizer
is therefore not an add-on: it is what allows a high-rate serial receiver to work
*behind a shared analog pin at all*. The block turns the challenge's shared-pin
constraint into its reason for existing.

## 2. Functional description

Signal path: **differential input → programmable CTLE → differential-to-single-ended /
limiting stage → slicer → Alexander phase detector → charge pump + loop filter →
ring VCO → recovered clock/data.**

- **CTLE.** A source-degenerated differential pair whose degeneration RC sets a
  transfer zero that boosts high frequencies to cancel the channel's pole. Boost is
  made programmable by switching parallel degeneration legs in and out via digital
  control bits, so the equalization can be matched to the actual pad+mux loss after
  fabrication. A single bridging degeneration capacitor across the source nodes
  gives roughly 4× the effective degeneration capacitance for the same MIM area. On
  the 3.3 V analog rail the input pair runs with a genuine saturated tail current
  source (referenced to the provided bandgap current), removing the headroom
  compromise the 1.8 V prototype was forced into.

- **CDR.** A reference-less bang-bang architecture. The recovered clock is generated
  by a current-starved ring VCO whose control voltage is set by the loop; there is
  no external reference clock and no phase-frequency detector. An Alexander phase
  detector (built from CML latches / flip-flops) compares the recovered clock
  against the data edges and steers a charge pump into the loop filter. Because a
  bang-bang PD corrects **phase only**, frequency is established by centering the VCO
  and by a **self-timed startup precharge cell** that seeds the control voltage above
  the VCO's oscillation threshold at power-up — making cold-start independent of the
  power-up data polarity.

  The frequency plan (ring-VCO center, loop-filter values, precharge release timing)
  is deliberately chosen for a single baud rate, so the block is **single-rate by
  design**. Supporting additional rates means instantiating N internally-tuned
  frequency-set cores (VCO + loop filter) and multiplexing between them under digital
  control, while reusing the CTLE, phase detector and startup cell unchanged — a
  planned optional extension, not part of the v1 committed specification.

- **References / resources used.** 3.3 V analog and 1.2 V digital supplies; the
  1.2 V bandgap; up to 2 bandgap-referenced bias voltages and up to 2
  bandgap-referenced current sources (CTLE tail, VCO and charge-pump bias); digital
  control/test lines per §3.

**Device strategy (recommended; to be confirmed at Schematic Review).** Baseline the
design in **CMOS on the 3.3 V analog rail** — the closest port of the proven
prototype, and the 3.3 V headroom directly fixes the biasing compromises seen at
1.8 V. If the SG13CMOS5L variant exposes SiGe HBTs, an HBT gain/limiting core is an
attractive enhancement (higher fT → sharper edges, lower CTLE current, better
noise). This proposal commits to the CMOS baseline; an HBT core will be evaluated as
an optional enhancement once device availability in this specific process variant is
confirmed.

## 3. I/O, including test ports

Analog levels are referenced to the 3.3 V analog supply; digital control and
observation are referenced to the 1.2 V digital supply.

**Signal I/O (analog)**

| Name | Dir | Description |
|---|---|---|
| `RXP`, `RXN` | in | Differential NRZ data input, from the shared analog pins via the mux. AC-coupling recommended; input common mode set internally. |

**Recovered outputs (digital, 1.2 V)**

| Name | Dir | Description |
|---|---|---|
| `RDATA` | out | Recovered / retimed data |
| `RCLK` | out | Recovered clock at the baud rate |
| `LOCK` | out | Lock / activity indicator |

**Digital control (1.2 V)**

| Name | Dir | Description |
|---|---|---|
| `EN` | in | Block enable / power-down |
| `RST` | in | CDR reset (re-arm startup precharge); the block also self-starts without it |
| `BOOST[2:0]` | in | CTLE boost select (8 steps) |
| `RATE_SEL` | in | *Reserved / not populated in v1.* Rate-band select — wired only if optional multi-rate variants are built. |

**Test / observability ports**

| Name | Type | Description |
|---|---|---|
| `EQ_MON` | analog out | Buffered CTLE output tap, for eye / frequency-response measurement |
| `VCTRL_MON` | analog out | VCO control (loop-filter) voltage, for lock / acquisition observability |
| `TCLK_DIV` | digital out | Recovered clock divided (e.g. ÷8) for low-bandwidth jitter / frequency measurement |

Total digital control + test lines used: ≤ 12 of the 16 available. Analog test taps
are high-impedance-buffered so they can share a muxed test pin. Pin and wrapper
mapping will be finalized against the challenge's template repository (TBD in the
brief).

**Shared-pin note (required by the rules).** The receiver tolerates a
pad-to-project series resistance up to the value in §4 combined with the pad+mux
capacitance; the CTLE compensates the resulting pole. This bounds the mux switch
resistance the challenge organizers can allocate to this slot.

## 4. Target specification

Values are design targets for SG13CMOS5L, grounded in the prototype and to be
confirmed in post-layout PVT. "Absolute limit" = do-not-exceed / guaranteed not to
damage.

| Parameter | Min | Typ | Max | Absolute limit | Notes |
|---|---|---|---|---|---|
| Data rate (NRZ) | — | 600 Mb/s | — | — | Single-rate; UI = 1.665 ns. Frequency plan fixed by design |
| Analog supply (VDDA) | 2.97 V | 3.3 V | 3.63 V | 3.6 V (device) | ±10 % |
| Digital supply (VDDD) | 1.08 V | 1.2 V | 1.32 V | 1.5 V (device) | ±10 % |
| Operating temperature | 0 °C | 27 °C | 110 °C | — | Commercial; −40 °C a goal |
| Input amplitude (diff pp) | 50 mV (sensitivity) | 200 mV | 400 mV (linear) | rail (limits, no damage) | ≤ 400 mVpp keeps CTLE linear |
| Input common mode | — | internally set | — | rail | AC-coupling recommended |
| Tolerable pad→input series R | — | — | ~1 kΩ (TBD w/ template) | — | Sets mux switch budget |
| Channel loss compensated @ Nyquist | — | — | ~14 dB | — | Pad+mux pole (e.g. ~64 MHz worst case) |
| CTLE DC gain | +4 dB | +6 dB | +8 dB | — | Boost-code dependent |
| CTLE programmable boost | 0 dB | — | +8 dB | — | 8 steps (`BOOST[2:0]`), ~1 dB/step |
| CTLE −3 dB bandwidth | 400 MHz | — | — | — | Comfortably above the 300 MHz Nyquist |
| Recovered-clock RMS jitter | — | 0.7 % UI | 2 % UI | — | Prototype: 0.68 % UI |
| Recovered-clock pk-pk jitter | — | 2.5 % UI | 5 % UI | — | Bang-bang dither |
| CID tolerance (run length) | 15 UI | — | — | — | Covers 8b/10b and PRBS15 |
| Lock / acquisition time | — | — | 2 µs | — | From enable, worst power-up polarity |
| Recovered-data BER | — | < 1e-9 | — | — | 1e-12 goal, nominal channel |
| Total power | — | 6 mW | 12 mW | — | Analog 3.3 V + digital 1.2 V |
| RX latency (in → `RDATA`) | — | few UI | — | — | To be reported post-layout |

**Known limitation, carried forward and bounded.** A bang-bang PD has no frequency
acquisition, so the VCO must start near target — handled by VCO centering plus the
startup precharge cell. In the prototype the ring VCO's tuning range narrowed at
temperature extremes; the 3.3 V rail and IHP devices are expected to improve this,
and holding the committed range to **0–110 °C** keeps it inside a verified window.
The VCO tuning range versus temperature is the first item to confirm at Schematic
Review.

## 5. Test plan (validation through measurement)

Bench: a pattern generator / BERT drives differential NRZ into `RXP`/`RXN` through a
**calibrated channel** that emulates the pad+mux path (defined series R + shunt C)
and, optionally, an additional lossy trace. A real-time or sampling oscilloscope and
the BERT capture the outputs; a temperature chamber and programmable supplies cover
PVT.

1. **CTLE frequency response / boost per code** — swept-sine or step/PRBS at
   `EQ_MON`; extract DC gain, peak boost and −3 dB bandwidth for each `BOOST[2:0]`
   code; verify monotonic ~1 dB steps.
2. **Eye diagrams** — at `EQ_MON` (post-EQ) and reconstructed from `RDATA`; measure
   eye height and width versus channel loss and versus boost code; confirm the eye
   that is closed at the pad is reopened after equalization.
3. **BER / bathtub** — BER versus channel loss, input amplitude (sensitivity), and
   boost code; horizontal and vertical bathtub curves for timing and voltage margin.
4. **Recovered-clock jitter** — from `RCLK` (and `TCLK_DIV` for low-bandwidth
   capture); RMS and peak-to-peak in UI, in lock.
5. **CDR acquisition and robustness** — lock time from `EN`/`RST` for both power-up
   data polarities (observed via `VCTRL_MON`); CID tolerance with PRBS7, PRBS15 and
   8b/10b patterns; lock range.
6. **Input sensitivity and linearity** — minimum input amplitude for the target BER;
   compression onset.
7. **PVT sign-off** — repeat the core measurements over 0–110 °C and supplies ±10 %,
   at the process corners, in post-layout simulation and, where equipment allows, on
   silicon.

**Reproducibility.** All stimuli, decks and analysis scripts live in the public
repository; results are summarized as plots, with raw data regenerable on demand
from the sources. Verification runs end-to-end on open-source EDA tools (ngspice with
the IHP open PDK).

**Submitted separately (not in this document):** list of available test equipment;
designer CV(s).
