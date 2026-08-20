# Repository-consistency tests

```console
$ pip install -r test/requirements.txt
$ pytest test/
```

No PDK, no ngspice, no magic, no network, no simulation. The suite parses files
that are already in the repository and finishes in well under a second, so it
can run on every push on a stock GitHub runner
(`.github/workflows/test.yaml`).

This is an analog project: the *circuit* is verified by ngspice, in decks under
`xschem/tuning/`, and those runs are far too heavy for CI (a single end-to-end
transient is 400-1200 s and has OOM-crashed the development VM). What these
tests cover instead is everything around the circuit that can silently drift out
of agreement.

| file | what it checks |
|---|---|
| `test/test_info_yaml.py` | `info.yaml` against `src/project.v` and `mag/`: the top module name, the standard Tiny Tapeout port list, `tiles`, `analog_pins` against the documented `ua[]` entries, which `uo_out` bits are actually driven, that the magic top cell and `PROJECT_NAME` still match, and that no template markers survive |
| `test/test_schematic_hierarchy.py` | the frozen xschem design: every symbol reachable from `xschem/ctle_cdr_rx.sch` resolves, every symbol has a schematic, the expected blocks are still instantiated (5 ring stages, 4 flip-flops + 2 XORs in the phase detector, the precharge cell in the CDR), instance names are unique, and the macro pin list still matches the blackbox in `src/project.v` |
| `test/test_docs_consistency.py` | the prose: no Tiny Tapeout template residue in `docs/info.md`, every design-log section cited by the documentation exists, every file path named in the documentation exists, every row of the README results table names its source, and no GDS badge is shown while no GDS exists |
| `test/ttcheck.py` | the shared parsers (xschem `.sch`/`.sym`, structural Verilog, design-log section indices) |

The hierarchy test earns its place for a specific reason: **xschem resolves a
missing symbol silently**. Move or rename a `.sym` and you do not get an error —
you get a truncated netlist, which is the netlist LVS then trusts. Re-walking
the hierarchy from the chip top catches that in milliseconds without needing
xschem installed.

The tests are written as `unittest` test cases so they also run without pytest:

```console
$ python3 -m unittest discover -s test -t test
```
