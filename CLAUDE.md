# ttsky-analog-equalizer — working notes for contributors

sky130 analog design in xschem + ngspice: a CTLE / limiting-amp / CDR receiver
chain for Tiny Tapeout.

This file is the operating manual for anyone — human or agent — doing work in
this repository. It exists because the compute environment has hard limits that
are not obvious, and because several bugs here were re-discovered after their
fix had already been found once and not written down.

**Start with `xschem/tuning/HANDOFF.md`** — the full state of the project: what
is finished, what is open, and the traps.

**For LAYOUT work, read `mag/LAYOUT_HANDOFF.md` instead** — it is self-contained:
the macro, the pad mapping, the toolchain commands, the device inventory per
block, floorplan guidance, what must not be changed, and the traps already hit.
As of 2026-08-15 the schematic design is frozen and netlist-verified, the LVS
flow is proven to run, and nothing has been drawn yet.

---

## 1. Compute budget — this constraint overrides convenience

The development VM has **7.8 GB of RAM and 4 CPUs**. An unguarded ngspice has
previously exhausted host memory and forced a reboot, losing scratch work. The
rules below are not stylistic:

- **Never run two ngspice processes at once.** Strictly sequential.
- **Always wrap ngspice in `xschem/tuning/safe_ngspice.sh`** — it applies a hard
  `ulimit -v`, a wall-clock `timeout`, a `/proc/meminfo` watchdog and `nice`.
  `safe_ngspice.sh <deck> <log> [mem_mb] [timeout_s] [floor_mb]`
- **Never use a bare `write foo.raw`.** It stores every node at every timepoint,
  which is what exhausted memory. Always `save` an explicit vector list first,
  and pass an explicit vector list to `write`.
- A full CDR transient costs ~7-20 minutes; a 6 µs run costs ~20-25. Confirm
  before starting anything in that class.
- No parameter sweeps in the "launch N simulations" sense. Sweep *inside* one
  ngspice run with `alter` and a `foreach`/repeat loop — see
  `pvt/gen_pvt.py::make_t0`.
- **numpy is not installed, and must not be.** Analysis scripts are pure stdlib.

## 2. Netlisting from the shell

```bash
cd xschem/tuning
export PDK_ROOT=/home/ttuser/pdk
xschem -n -s -x -q --rcfile ../xschemrc -o ~/.xschem/simulations <name>.sch
```

Note that `-r` is `--no_readline`, **not** an rcfile flag. Passing it silently
produces a truncated netlist with "Symbol not found" for everything.

## 3. Traps

The simulation traps that cost real time here — all verified the hard way, all
of them silent failures — are written up in **[`docs/SIMULATION_TRAPS.md`](docs/SIMULATION_TRAPS.md)**.
Read it before writing a deck. It covers `.op` treating capacitors as opens,
node names containing `+` vanishing from the rawfile, rings that will not start,
`.measure` on a nonexistent edge index, PWL sources running out mid-transient,
measuring a loop before it has settled, and why sky130 MOS and R/C corners
cannot be combined through the stock `.lib` sections.

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
| `model/` | real-number behavioural model of the macro + self-checking testbench |
| `src/project.v` | blackbox Verilog: the pad ↔ macro wiring that `make lvs` checks |
| `test/` | repository-consistency tests; `pytest test/` or `python3 -m unittest discover -s test -t test` |

`pvt/decks/`, `pvt/results/`, `pvt/.netlists/` are gitignored and regenerated.

## 5. Conventions

- Commit and push as you go — work has been lost to a crash here before.
- `tuning/` is a sandbox: never edit the taped-out `tiny_pll_charge_pump` layout.
- The schematics are **frozen and netlist-verified**. Documentation, tests and
  the behavioural model are the places to make changes.
- Record *negative* results in the notes too. Several dead ends here were
  re-attempted across sessions because the failure had not been written down.
- Any number that appears in `README.md` or `docs/` must cite the log section it
  came from. `test/test_docs_consistency.py` enforces this.
