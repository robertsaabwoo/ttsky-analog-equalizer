# Simulation traps in sky130 + ngspice

Every item here cost real debugging time on this project, and every one of them
**fails silently** — the simulator returns a plausible number rather than an
error. They are written down because several were re-discovered across sessions
after the first fix was made and not recorded.

If you are reading this as a reviewer rather than a user: this file is the part
of the project I would most want to be judged on. Getting a CDR to lock is
mostly a matter of not being fooled by your own measurements.

---

## 1. `.op` treats a capacitor as an open circuit

Any power-on-reset or startup circuit is therefore **dead on arrival** in a deck
that begins from an operating point. The CDR's `vctrl` precharge one-shot never
fires without an explicit initial condition:

```spice
.ic v(x1.x20.nrc)=0
```

**Symptom when missing:** everything frozen, and a "recovered clock" of a few
millivolts. It looks like a broken circuit, not a broken testbench. See
`xschem/tuning/NOTES.md` §19.

## 2. `let clkp = v(clk+)` silently produces nothing

ngspice parses the `+` in a node name as an operator. The vector simply never
appears in the rawfile — **no error, no warning**. Copy such a node through a
unity-gain VCVS first:

```spice
Eclkp clkp 0 clk+ 0 1
```

The same hazard applies to the `node` field of an xschem graph.

## 3. A ring oscillator started from `uic` never oscillates

All-nodes-at-zero is exactly the ring's metastable DC point, and a perfectly
symmetric simulator has no noise to break it. It will sit there forever. Kick
one node:

```spice
.ic v(vo+)=1.8
```

Real silicon starts on thermal noise; the simulator has none unless you ask.

## 4. A `.measure` on an edge index that does not exist fails silently

```spice
meas tran e1800 WHEN v(rclkp)=0.9 RISE=1800
```

A 3 µs run at 600 Mb/s looks like it should contain 1802 UI, so `RISE=1800`
seems safe. But the recovered clock does not start until the precharge releases
at ~126 ns, so there are only ~1799 rising edges — and the measurement, and
every `let` derived from it, quietly did not happen.

**Derive the index from `(t_end − t_release)/UI`, not `t_end/UI`,** and leave
margin. This one invalidated an entire overnight run (§C26).

## 5. A PWL source holds its last value forever

`e2e_prbs3u.inc` contains 1850 bits = 3.08 µs of data. Run a 6 µs transient
against it and the back half of the simulation is **flat DC** — the CDR goes
blind, the loop wanders, and the run produces a jitter number that is really a
measurement of the data source running out. Regenerate the pattern to cover the
full transient (`ctle/gen_prbs.py`), and assert `tsim > tran` before launching.

## 6. Measuring a loop before it has settled measures the settling

§C26 reported 33.8 % UI RMS of phase error. That number was not jitter: `vctrl`
was still drifting across the measurement window, so the measurement captured
convergence. The fix is to **prove settling inside the deck itself**, with two
or three separated averaging windows that must agree, before any jitter number
is quoted from that window. §C27 does this.

Related: **a best-fit constant-period clock is the wrong reference for a CDR.**
The recovered clock is supposed to track the data, so the reference is the ideal
bit grid. And a bang-bang loop has unbounded low-frequency phase wander by
construction — measure phase error *relative to the data*, over a bounded
window, or the answer gets arbitrarily worse the longer you look.

## 7. The `.op` NaN spam is cosmetic

Hundreds of `<<NAN, error=7>>` lines are ngspice's operating-point report
choking on unfilled noise-model parameters. The transient is fine. Filter with
`grep -v "NAN, error"`.

## 8. MOS corners and R/C corners are independent axes

In sky130, `.lib ss` moves only the transistors; `.lib hh` / `ll` move only R
and C. The stock `.lib` sections **cannot be combined** to get, say, slow
devices with high-value resistors. Emit the underlying `.include` lines
directly. Anything that claims to be a true worst-case corner without doing this
is only cornering one axis.

## 9. xschem netlisting fails with rc=1 and no diagnostic from a subdirectory

`subprocess` sets the child's working directory but leaves the inherited `PWD`
environment variable pointing at the parent, and xschem's Tcl layer trusts
`PWD`. Stamp it explicitly. Relatedly, `-r` is `--no_readline`, **not** an rcfile
flag — passing it produces a truncated netlist full of "Symbol not found",
with a zero exit status.

---

## The same class of bug in the behavioural model

`model/rx_cdr_rnm.sv` had one too, and it is worth recording because it is the
digital-domain twin of the analog traps above. The Alexander phase detector was
written as a combinational function of the data and edge samples. Those two
registers update half a UI apart, so for half of every UI the detector compared
the *new* edge sample against the *old* data pair, and pumped the loop in an
essentially arbitrary direction. `vctrl` walked into the supply rail and the
VCO pinned at its maximum.

The model still compiled, still simulated, and still produced a waveform. An
Alexander PD must make **one registered decision per UI**. See the comment at
the declaration of `up`/`dn`.
