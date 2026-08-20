# The xschem design files

> **The single top level is `ctle_cdr_rx.sch`.** Everything else in this
> directory is one of its sub-blocks. Retired testbenches and exploration
> schematics live in `attic/` — see `attic/README.md`.
>
> The design is **frozen and netlist-verified** as of 2026-08-15. Read
> `STATUS.md` for the promotion record, `../docs/DESIGN.md` for how it was
> verified, and `tuning/NOTES.md` / `tuning/ctle/NOTES_CTLE.md` for the full
> chronological logs.

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

`../test/test_schematic_hierarchy.py` re-walks this hierarchy on every push and
fails if a symbol stops resolving — worth knowing about, because **xschem
resolves a missing symbol silently** and hands you a truncated netlist rather
than an error.

## `ctle_cdr_rx` pinout (the LVS contract)

```
.subckt ctle_cdr_rx vinp vinm vbias clkout_p clkout_n VDPWR VGND
```

| pin | pad | meaning |
|---|---|---|
| `vinp` / `vinm` | `ua[0]` / `ua[1]` | differential data input, straight off the analog mux |
| `vbias` | `ua[2]` | external ~0.9 V bias reference |
| `clkout_p` | `uo_out[0]` | recovered clock |
| `clkout_n` | `uo_out[1]` | inverted phase — **also loads the ring symmetrically, do not delete** |
| `VDPWR` / `VGND` | supplies | 1.8 V rails |

`../src/project.v` defines that pad mapping and is what `mag/ make lvs` checks
the layout against.

## `CDR.sym` pinout

| pin           | dir | meaning                                   |
|---------------|-----|--------------------------------------------|
| `Vdd`/`Vss`   | pwr | 1.8V rails                                  |
| `vin+`/`vin-` | in  | differential data input (post-CTLE)         |
| `vbias`       | in  | analog bias reference (0.9V)                |
| `rclk+`/`rclk-` | out | recovered clock, two phases               |

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
                                    v  vctrl (VCO control voltage)
                 tiny_pll_loop_filter (x2)  <-- vctrl_precharge (x20)
                                    |            seeds it at power-up
                                    v
                 ring_oscillator (x1)  --- vo+/vo- (~0.4Vpp) --->
                                    |
                                    v
                 diff_amp_inv (x4) -> inverter_buffer -> rclk+
                                            |
                                            +-> single_inverter -> rclk-
```

- **`alexander_phase_detector.sch`** (x3): 4× `d_flip_flop` (each built from two
  `d_latch` master/slave stages) + 2× `robs_xor` — the classic bang-bang phase
  detector. It samples `vin+/vin-` with `rclk+/rclk-` and reports only *early*
  or *late*, never frequency. Everything awkward about this loop follows from
  that: see `tuning/NOTES.md` §15c.
- **`tiny_pll_charge_pump.sch`** (x6), **`tiny_pll_bias_gen.sch`** (x8),
  **`tiny_pll_loop_filter.sch`** (x2, built from
  `tiny_pll_loop_filter_cap1/cap2/res`) — inherited from the older `tiny_pll`
  design. The charge pump is **already taped out and must not be modified**.
  The loop-filter capacitors were deliberately shrunk ~10× from their PLL values
  (§16): a bang-bang CDR wants the higher loop bandwidth, and with PLL-sized
  caps the control voltage bleeds past the oscillator's dead-zone cliff before a
  phase-only loop can acquire. The pump itself was later measured and is well
  matched — 1.6 % up/down mismatch (§C25-E).
- **`ring_oscillator.sch`** (x1) — the custom VCO: five `ring_inverter.sch`
  stages in a ring, tapped differentially and buffered by its own
  `diff_amp_inv`. Tuning range at tt/27 °C is 514-621 MHz (§20b).
- **`vctrl_precharge.sch`** (x20) — the startup cell. It seeds `vctrl` into the
  oscillator's active region for ~130 ns and then electrically removes itself
  (~1 fA leakage afterwards). Without it about half of all power-ups never
  acquired lock, depending on the incoming data polarity. Its bias is a scaled
  replica of the ring's own tail device, so the seed tracks the dead-zone cliff
  over PVT instead of being a hard-coded voltage — which is why all 45 corners
  pass (§17, §20a). **If `ring_inverter`'s M5 is ever resized, resize `MBD`
  identically or the tracking breaks.**
- **`diff_amp_inv.sch`** (x4) → **`inverter_buffer.sch`** → `rclk+`, with
  **`single_inverter.sch`** producing `rclk-`. Note that `rclk-` is *not* an
  instantaneous complement — it is `rclk+` through an inverter, so it carries
  that inverter's delay and threshold offset, and the two phases have ~33 % and
  ~61 % duty cycles (§C24). A proper differential slicer is on the open list.

## Netlisting from the shell

```sh
cd /home/ttuser/ssh_analog/ttsky-analog-equalizer/xschem/tuning
export PDK_ROOT=/home/ttuser/pdk
xschem -n -s -x -q --rcfile ../xschemrc -o ~/.xschem/simulations <name>.sch
```

`-r` is `--no_readline`, **not** rcfile — passing it silently produces a
truncated netlist with "Symbol not found" for everything. Netlisting also fails
with rc=1 and no diagnostic if it is driven from a subdirectory without
stamping `PWD` explicitly. Both traps are documented in `../CLAUDE.md` §2-§3.

## Running a simulation

**Always through `tuning/safe_ngspice.sh`**, which caps memory and wall-clock
time and watches `/proc/meminfo`:

```sh
tuning/safe_ngspice.sh <deck.spice> <log> [mem_mb] [timeout_s] [floor_mb]
```

Never use a bare `write foo.raw` — it stores every node at every timepoint,
which has already OOM-crashed the development VM once. `save` an explicit
vector list first. Never run two ngspice processes at once. See `../CLAUDE.md`
§1 for the full rules; these are not style preferences.

### Reading results without opening a GUI

Every testbench deck prints a numeric summary via `meas`, which is faster to
read than a waveform and is what the design logs quote. To re-measure from an
existing raw file:

```sh
ngspice -b <<'EOF'
.control
  load ~/.xschem/simulations/<name>.raw
  meas tran vpp  PP  v(rclkp)
  meas tran per  TRIG v(rclkp) VAL=0.9 RISE=2 TARG v(rclkp) VAL=0.9 RISE=3
  print vpp per
.endc
.end
EOF
```

`PP` tells you whether a node is swinging at all — a dead ring oscillator reads
~5 mV where a live one reads ~1.87 V. Two traps: `meas ... RISE=<n>` measures
wherever the n-th edge happens to be, so pick `n ≈ t_window / UI` rather than
assuming it lands where you want (§C24); and `let x = v(clk+)` silently
produces nothing, because ngspice parses the `+` as an operator — copy such
nodes with a unity VCVS instead.

`simulation/check_swing.sh` wraps the above for a list of nodes.
