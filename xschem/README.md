# CDR / CTLE analog design notes

> **The single top level is `ctle_cdr_rx.sch`.** Everything else in this
> directory is one of its sub-blocks. Retired testbenches and exploration
> schematics live in `attic/` — see `attic/README.md`.
>
> Much of the text below predates that and describes the CTLE and CDR as
> separate, un-wired blocks. **That is history**: they were wired together and
> verified end to end (`tuning/ctle/NOTES_CTLE.md` §C23-§C26), then the validated
> sandbox was promoted into these files. Read `STATUS.md` for the current state.

## Directory layout

| | |
|---|---|
| `ctle_cdr_rx.sch` | **the chip top level** — CTLE → CDR → two inverter chains |
| `ctle_cdr_rx_lvs.sch` | one-instance wrapper. **Netlist this**, not the macro — netlisting the macro directly makes it the netlist top and emits no `.subckt` for netgen |
| `CTLE.sch`, `CDR.sch`, … | the sub-blocks, 22 cells in total, all reachable from the top |
| `attic/` | retired dev and testbench schematics, still on the library path |
| `tuning/` | the simulation sandbox, decks and design logs |
| `simulation/` | generated netlists (gitignored) |

The chip signal flow:

```
 ua[0]/ua[1] -> [ CTLE ] -> [ CDR ] -> [ inverter_chain x2 ] -> uo_out[0]/uo_out[1]
                (equalizer)  (bang-bang loop)
```

## CDR.sym pinout

| pin           | dir | meaning                                   |
|---------------|-----|--------------------------------------------|
| `Vdd`/`Vss`   | pwr | 1.8V rails                                  |
| `vin+`/`vin-` | in  | differential clock/data input (post-CTLE)   |
| `vbias`       | in  | analog bias reference (0.9V in testbenches) |
| `rclk+`/`rclk-` | out | recovered clock                           |

## Inside `CDR.sch` — the bang-bang loop

```
                 +------------------------------------------------+
                 |                                                 |
 vin+/vin- ----->|  alexander_phase_detector (x3)                  |
 rclk+/rclk- --->|    up/down -----+                               |
                 +-----------------|-------------------------------+
                                    v
                 tiny_pll_charge_pump (x6)  <-- bias_p/bias_n from
                                    |            tiny_pll_bias_gen (x8)
                                    v  net1 (VCO control voltage)
                 tiny_pll_loop_filter (x2)  (cap to net1)
                                    |
                                    v
                 ring_oscillator (x1)  --- net4/net5 (~0.4Vpp) --->
                                    |
                                    v
                 diff_amp_inv (x4)  ---> rclk+/rclk- (fed back to x3, and out)
```

- **`alexander_phase_detector.sch`** (x3): 4x `d_flip_flop` (each built from two
  `d_latch.sch` master/slave stages) + 2x `robs_xor` — the classic bang-bang
  phase detector, sampling `vin+/vin-` with `rclk+/rclk-` and producing up/down.
- **`tiny_pll_charge_pump.sch`** (x6), **`tiny_pll_bias_gen.sch`** (x8),
  **`tiny_pll_loop_filter.sch`** (x2, built from `tiny_pll_loop_filter_cap1/cap2/res`)
  — lifted essentially unchanged from the older `tiny_pll` design (see the
  now-scratch `tiny_pll*.sch` files for the original PLL they came from). Charge
  pump output / loop filter node is `net1`, which is the VCO control voltage.
- **`ring_oscillator.sch`** (x1) — the **custom VCO** (this is what the
  `custom_vco` branch is about), replacing the old `tiny_pll_vco`. It's 5
  `ring_inverter.sch` stages in a ring, tapped differentially at `net7`/`net8`,
  followed by its *own* `diff_amp_inv` (buffering `net7`/`net8` down to a clean
  `vo+`/`vo-` at reduced swing).
- **`diff_amp_inv.sch`** (x4, at the CDR level) — a second buffer stage that is
  supposed to take the ring oscillator's `vo+`/`vo-` (wired to `net4`/`net5` here)
  and turn it into rail-to-rail `rclk+`/`rclk-`. **This is the current suspect —
  see "Known issue" below.**

## File inventory

Traced by recursively following `C {...}` component references from the two
real top-level testbenches (`CDR_tb.sch`, `CTLE_testbench.sch`/`CTLE_WITH_LATCH.sch`).

**Load-bearing (part of CDR/CTLE today):**

`CDR.sch/.sym`, `CDR_tb.sch`, `CTLE.sch/.sym`, `CTLE_testbench.sch`,
`CTLE_WITH_LATCH.sch`, `D2S_amp.sch/.sym`, `alexander_phase_detector.sch/.sym`,
`d_flip_flop.sch/.sym`, `d_latch.sch/.sym`, `diff_amp_inv.sch/.sym`,
`inverter_chain.sch/.sym`, `ring_inverter.sch/.sym`, `ring_oscillator.sch/.sym`,
`robs_xor.sch/.sym`, `tiny_pll_bias_gen.sch/.sym(+_res)`,
`tiny_pll_charge_pump.sch/.sym`, `tiny_pll_loop_filter.sch/.sym(+_cap1/_cap2/_res)`.

**Benchmark testbench (not part of CDR, but useful as a known-good reference):**

- `ring_oscillator_tb.sch` — standalone VCO testbench, drives `vctrl` with a DC
  source and outputs `vo+`/`vo-`. This is the "known good, swings properly"
  circuit referenced throughout this doc.

**Scratch / experimental / superseded (safe to ignore or clean up later):**

`alexander_loop.sch`, `alexander_loop_tb.sch`, `alexander_single.sch`,
`CDR_single.sch`, `demux*.sch`, `diff_savefile.sch`, `divide_by_two*.sch/.sym`,
`double_inverter.sch/.sym`, `full_tb.sch` (an alternate CDR testbench that adds
a `D2S_amp` single-ending stage — not the tracked canonical one, but similar to
`CDR_tb.sch`), `inverter_buffer.sch/.sym`, `just_in_case.sch`, `LA_Limiter.sch/.sym`,
`one_to_two_demux.sch/.sym`, `one_two_demux_tb.sch`, `s2d.sch/.sym`,
`testbench.sch`, `tiny_pll.sch/.sym` and its old `tiny_pll_divider*`,
`tiny_pll_pfd*`, `tiny_pll_vco*` children (the **old** VCO/PFD this branch is
replacing), `TSPC_Latch.sch/.sym`, `untitled.sch`, `vco_testbench.sch` (old VCO's
testbench, superseded by `ring_oscillator_tb.sch`).

Everything untracked in `git status` that's listed above as scratch can be
committed or dropped at your discretion — none of it is referenced by `CDR.sch`
or `CTLE.sch`.

## Running a simulation from the terminal (no xschem/gaw GUI needed)

xschem's default netlist output directory is `~/.xschem/simulations` (see
`netlist_dir` in `xschemrc`). Every testbench schematic already has a
`simulator_commands_shown` block with a `.control ... tran ... write <name>.raw
... .endc`, so netlisting + simulating is two commands:

```sh
cd /home/ttuser/ssh_analog/ttsky-analog-equalizer/xschem

# 1. Netlist the schematic (headless, no X server needed)
xschem -n -x -q CDR_tb.sch          # -> ~/.xschem/simulations/CDR_tb.spice

# 2. Run the embedded transient analysis and write the .raw waveform file
cd ~/.xschem/simulations
ngspice -b CDR_tb.spice             # -> CDR_tb.raw  (per its .control block)
```

Same pattern for the benchmark:

```sh
cd /home/ttuser/ssh_analog/ttsky-analog-equalizer/xschem
xschem -n -x -q ring_oscillator_tb.sch
cd ~/.xschem/simulations
ngspice -b ring_oscillator_tb.spice   # writes VCO_tb.raw (hardcoded write name
                                       # inside ring_oscillator_tb.sch's command
                                       # block — a minor leftover, not a bug that
                                       # affects the result)
```

Check the ngspice run log for `Error`/`singular`/`NaN` — a normal run only prints
device-parameter dumps (from `.op`) plus the `Total analysis time` summary at the end.

### Detecting swing/oscillation without opening a graph

Once a `.raw` file exists, load it back into ngspice batch mode and use
`.measure` — no GUI required:

```sh
ngspice -b <<'EOF'
.control
  load ~/.xschem/simulations/CDR_tb.raw
  meas tran vpp   PP  v(clk+)
  meas tran vmax  MAX v(clk+)
  meas tran vmin  MIN v(clk+)
  meas tran per   TRIG v(clk+) VAL=0.9 RISE=2 TARG v(clk+) VAL=0.9 RISE=3
  print vpp vmax vmin per
.endc
.end
EOF
```

`PP` (peak-to-peak) tells you if a node is swinging at all; the `TRIG`/`TARG`
pair gives the toggle period between two rising 0.9V (mid-rail) crossings
(skipping the first crossing to dodge startup transients). If a node never
crosses 0.9V, the period measurement fails with `out of interval` — that
failure is itself diagnostic (the node is stuck near a rail, not toggling).

A reusable version of this is checked in at
**`xschem/simulation/check_swing.sh`**:

```sh
cd xschem/simulation
./check_swing.sh CDR_tb.raw vin+ clk+ clk-
```

It takes a raw file (looked up in `~/.xschem/simulations` by default, override
with `SIMDIR=`) and any number of node names, and prints PP/max/min/period for
each.

## Benchmark: ring_oscillator (known good)

`ring_oscillator_tb.sch` with `vctrl=0.9V` (its DC bias source) confirms the
measurement method works and gives reference numbers to compare against:

```
vo+_pp  = 0.405 V     vo+_max = 1.249 V   vo+_min = 0.844 V
vo-_pp  = 0.405 V     period  = 1.665 ns  (~600 MHz)
```

Healthy differential rail swing (~0.4Vpp, well above the ~0.05Vpp noise floor
seen on the broken CDR output below) and a clean, consistent period — this is
what "swing detected" looks like.

## Current CDR status (as of this branch)

Running the same check on `CDR_tb.sch` (full differential 300MHz-ish input
pulse on `vin+`/`vin-`, `vbias=0.9V`):

```
vin+_pp = 1.800 V   (input is healthy, full rail swing, period = 3.33ns)
clk+_pp = 0.052 V   clk+_max = 1.689 V   clk+_min = 1.636 V   -> period: no crossing at 0.9V
clk-_pp = 0.053 V   clk-_max = 1.688 V   clk-_min = 1.635 V   -> period: no crossing at 0.9V
```

The recovered clock output is **not swinging** — it sits ~50mV pp, pinned near
the upper rail. This matches the expectation that the CDR doesn't work well yet.

### Diagnostic trace of *why* — leading hypothesis

Probing the internal loop nodes on the same run (`x1` = the `CDR` instance in
the testbench, `x1.x1` = the `ring_oscillator` instance inside `CDR.sch`):

```
x1.net1        (VCO control voltage, charge pump/loop filter output)
                 pp=0.084V   range 1.677-1.761V   -- pinned near Vdd, not settling mid-rail

x1.net4/net5   (ring_oscillator's OWN buffered vo+/vo- output, feeding diff_amp_inv x4)
                 pp≈0.39-0.40V  -- matches the healthy benchmark almost exactly

x1.x1.net7/net8 (raw ring-inverter core taps, before ring_oscillator's internal buffer)
                 pp≈1.44V, period≈1.65ns (~600MHz) -- the oscillator core IS running fine
```

So the ring oscillator core is oscillating correctly and its internal buffer
(`diff_amp_inv` x6 inside `ring_oscillator.sch`) hands off a healthy ~0.4Vpp
differential signal on `net4`/`net5` — identical to the standalone benchmark.
The signal only collapses at the **next** stage: the *outer* `diff_amp_inv`
(x4, in `CDR.sch`) that's supposed to turn that into rail-to-rail `rclk+/rclk-`.

The likely reason: in `ring_oscillator.sch`, the working `diff_amp_inv`'s tail
bias pin is tied to **`Vdd`** (fully-on tail current). In `CDR.sch`, the outer
`diff_amp_inv` (x4) has that same pin tied to **`vbias`** (~0.9V) instead —
much less tail current/gain, so it can't fully switch on the same ~0.4Vpp
input and just sags near the rail. That starves the phase detector of a real
toggling clock, which is consistent with `net1` (the charge pump output)
sitting pinned near Vdd instead of settling — the phase detector likely never
sees a valid clock edge to compare against, so the charge pump just pumps one
direction.

**Suggested first fix to try in a future tuning session:** compare the `x4`
instantiation line in `CDR.sch` against `x6` in `ring_oscillator.sch` and
either tie `x4`'s bias pin to `Vdd` (matching the known-good stage) or re-bias
it so it gets comparable tail current.

## Suggested tuning workflow going forward

1. Edit the schematic in xschem as usual.
2. Re-netlist + re-sim from the terminal (commands above) instead of opening
   the GUI each time — much faster for iterating.
3. Run `check_swing.sh` against the nodes you care about (start with `clk+`/`clk-`,
   then `x1.net1`, `x1.net4`/`net5`, `x1.x1.net7`/`net8` for the CDR) to see
   where in the chain the signal degrades.
4. Compare against the `ring_oscillator_tb.sch` benchmark numbers above whenever
   you suspect the VCO itself, since that circuit is known-good in isolation.
