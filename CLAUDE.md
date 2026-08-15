# ttsky-analog-equalizer — working notes for agents

sky130 analog design in xschem + ngspice. A CTLE / limiting-amp / CDR receiver
chain for TinyTapeout.

**Read `xschem/tuning/HANDOFF.md` first** — it is the full state of the project,
what is finished, what is open, and the traps.

**If this session is about LAYOUT, read `mag/LAYOUT_HANDOFF.md` instead** — it is
self-contained: what the macro is, the pad mapping, the toolchain commands, the
device inventory per block, floorplan guidance, what must not be changed, and
the traps already hit. As of 2026-08-15 the schematic design is frozen and
netlist-verified, the LVS flow is proven to run, and nothing has been drawn yet.

---

## 1. THE VM IS WEAK — this constraint overrides convenience

7.8 GB RAM, 4 CPU. **It has already been crash-rebooted once by an unguarded
ngspice**, losing scratch work. Standing user directives, still in force:

> "make sure the task is fast and not CPU intense, this is a VM and you can crash
> the laptop if it is too crazy" · "Make sure not to run any intensive commands
> anymore" · "you can still run tests but simple ones" · "can you not perform a
> sweep?"

Rules:

- **Never run two ngspice at once.** Strictly sequential.
- **Always wrap ngspice in `xschem/tuning/safe_ngspice.sh`** — hard `ulimit -v`,
  wall-clock `timeout`, `/proc/meminfo` watchdog, `nice`.
  `safe_ngspice.sh <deck> <log> [mem_mb] [timeout_s] [floor_mb]`
- **Never use a bare `write foo.raw`.** It stores every node at every timepoint —
  that is what OOM-crashed the VM. Always `save` an explicit vector list first.
- A full CDR transient is ~15-20 min. Ask before starting anything in that class.
- No parameter sweeps in the "launch N sims" sense. Sweep *inside* one ngspice run
  with `alter` + a `foreach`/repeat loop instead (see `pvt/gen_pvt.py::make_t0`).

## 2. Netlisting from the shell

```bash
cd xschem/tuning
export PDK_ROOT=/home/ttuser/pdk
xschem -n -s -x -q --rcfile ../xschemrc -o ~/.xschem/simulations <name>.sch
```

`-r` is `--no_readline`, **not** rcfile — passing it silently produces a truncated
netlist with "Symbol not found" for everything.

## 3. Traps that cost real time here (all verified the hard way)

- **`.op` treats a capacitor as an OPEN.** Any power-on-reset / startup circuit is
  therefore dead on arrival in a deck that starts from an operating point. The CDR
  testbench needs `.ic v(x1.x20.nrc)=0` for its precharge one-shot to fire at all.
  Symptom when missing: everything frozen, a ~5 mV "clock". See NOTES.md §19.
- **`let clkp = v(clk+)` silently produces nothing.** ngspice parses the `+` as an
  operator; the vector just never appears in the `.raw`, with no error. Copy such
  nodes with a unity VCVS instead: `Eclkp clkp 0 clk+ 0 1`. The same hazard applies
  to xschem graph `node` fields.
- **A ring oscillator started from `uic` never oscillates** — all-nodes-at-zero is
  exactly its metastable DC point. Kick one node: `.ic v(vo+)=1.8`.
- **xschem netlisting fails with rc=1 and NO diagnostic when driven from a
  subdirectory.** `subprocess` sets the child's cwd but leaves the inherited `PWD`
  pointing at the parent, and xschem's Tcl layer trusts `PWD`. Stamp it explicitly.
- **The `.op` NaN spam is cosmetic** — hundreds of `<<NAN, error=7>>` lines are
  ngspice's operating-point report choking on unfilled noise-model params. The tran
  is fine. Filter with `grep -v "NAN, error"`.
- **numpy is not installed.** Analysis scripts are pure stdlib. Do not pip install.
- In sky130, **MOS corners and R/C corners are independent axes**: `.lib ss` moves
  only transistors, `.lib hh`/`ll` only R and C. The stock `.lib` sections cannot
  combine them — emit the underlying `.include` lines directly.

## 4. Layout of the repo

| path | what |
|---|---|
| `xschem/` | the real design (`CTLE.sch`, `CDR.sch`, `tiny_pll*`, …) |
| `xschem/tuning/` | the CDR sandbox — `*_tune.sch` copies that are safe to edit |
| `xschem/tuning/NOTES.md` | **the master log**, §1-§20, chronological |
| `xschem/tuning/HANDOFF.md` | current state + open items. Start here. |
| `xschem/tuning/pvt/` | PVT harness (`gen_pvt.py`, `run_pvt.sh`, `collect_pvt.py`) |
| `xschem/tuning/safe_ngspice.sh` | the resource guard. Use it. |
| `xschem/ctle_cdr_rx.sch` | **the analog macro that gets laid out** (CTLE → CDR → output buffers) |
| `xschem/ctle_cdr_rx_lvs.sch` | one-instance wrapper; netlist THIS to get a `.subckt` for netgen |
| `mag/LAYOUT_HANDOFF.md` | **start here for layout work** |
| `src/project.v` | blackbox Verilog: the pad ↔ macro wiring that `make lvs` checks |

`pvt/decks/`, `pvt/results/`, `pvt/.netlists/` are gitignored and regenerated.

## 5. Conventions

- Commit and push as you go — the VM has crashed before and lost work.
- `tuning/` is a sandbox: never edit the taped-out `tiny_pll_charge_pump` layout.
- Record *negative* results in NOTES.md too. Several dead ends here were
  re-attempted across sessions because the failure had not been written down.
