<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project is a fully analog front end that recovers a clean digital clock from a degraded differential
analog input signal. The chain is captured in `xschem/CTLE_WITH_LATCH.sch` and is built out of four reusable
sub-blocks:

1. **`CTLE.sch`** -- a continuous-time linear equalizer (differential pair with resistor/capacitor source
   degeneration). It takes the differential input pair `vin+`/`vin-` and a `vbias` reference, and boosts the
   high-frequency content that a lossy channel would otherwise attenuate, producing an equalized differential
   output.
2. **`d_latch.sch`** -- an analog differential latch. Two instances run in series on the CTLE's output (a
   master/slave pair), retiming the equalized signal into a clean, full-swing differential clock.
3. **`D2S_amp.sch`** -- a differential-to-single-ended amplifier that converts the retimed differential signal
   down to one node.
4. **`inverter_chain.sch`** -- a tapered inverter chain that squares up and buffers that node into a strong,
   rail-to-rail digital output.

The signal path used for the chip is: `CTLE -> latch -> latch (master/slave pair) -> D2S_amp -> inverter_chain`,
which is the "vout0" path in `CTLE_WITH_LATCH.sch` (instances `x1 -> x4 -> x8 -> x2 -> x6`). A second, shorter
path (`x1 -> x3 -> x5 -> x7`, "vout1", a single-latch version of the same idea) also exists in the schematic
for comparison -- it is one latch stage "ahead" of the chip output and is not brought out to a pad.

**Pinout:**
- `ua[0]` (`vin+`) / `ua[1]` (`vin-`) -- differential analog input pair, driven straight into the CTLE.
- `ua[2]` (`vbias`) -- external analog bias reference used by the CTLE, both latches, and the D2S amp.
- `uo[0]` -- the recovered digital clock, driven by the inverter chain at the end of the vout0 path.

**Known open item:** in `CTLE_WITH_LATCH.sch`, the latches' `clk+`/`clk-` inputs are currently driven by ideal
pulse sources for simulation only -- they are not yet wired to a pin-derived signal on the real chip. Sourcing
the latch clock (e.g. from the raw `vin+`/`vin-` pads, or elsewhere) is still open design work.

Note also that the resistor/capacitor network at the front of `CTLE_WITH_LATCH.sch` (which turns `vin+`/`vin-`
into `vin+_bad`/`vin-_bad`) is a simulation-only model of a lossy channel used to stress-test the CTLE -- it is
not part of the fabricated design. On the real chip, `ua[0]`/`ua[1]` connect directly to the CTLE's `vin+`/`vin-`
pins.

`src/project.v` is an empty stub module. This is a pure-analog project: the actual signal path lives in the
hand-drawn `xschem`/layout, not in synthesizable RTL, so `uo_out[0]` is bonded directly to the inverter chain's
output at the layout level rather than being driven by Verilog logic.

`xschem/demux.sch`, `xschem/demux_testbench.sch`, and `xschem/CTLE_testbench.sch` are simulation/exploration
schematics used during development and are not part of the top-level signal path described above.

## How to test

The design is verified in ngspice using the simulation schematics in `xschem/`:

1. Open `xschem/CTLE_WITH_LATCH.sch` (the full chain: CTLE + latch pair + D2S amp + inverter chain) in xschem.
2. Run the embedded `.control` block (`tran 10p 20n`), which drives `vin+`/`vin-` with a degraded/noisy
   differential pulse pair (through the on-chip-lossy-channel stimulus and `TRNOISE` sources) and `vbias` with
   a fixed 0.9 V reference.
3. Probe the `vout0` net (chip output path) and confirm it is a clean, full-swing (0 V / 1.8 V) square wave
   despite the degraded input, i.e. that the CTLE + latch pair successfully "recreated" a clock from the analog
   input.
4. `xschem/CTLE_testbench.sch` isolates just the CTLE + a single D2S/inverter stage for faster iteration on the
   equalizer alone.

On real hardware, apply a differential clock-like signal (through a lossy channel, cable, or attenuator if you
want to reproduce the "bad channel" stress test) to `ua[0]`/`ua[1]`, hold `ua[2]` at a steady ~0.9 V bias, and
observe a clean recovered digital clock on `uo_out[0]`.

## External hardware

- A differential signal source / function generator (or two single-ended sources) to drive `ua[0]`/`ua[1]`.
- A stable ~0.9 V reference (e.g. a bench supply or resistor divider) for `ua[2]` (`vbias`).
- An oscilloscope or logic analyzer to observe the recovered clock on `uo_out[0]`.
