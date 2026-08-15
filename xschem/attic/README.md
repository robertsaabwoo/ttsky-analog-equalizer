# attic — retired development and testbench schematics

Nothing in here is part of the chip. These are the exploration schematics, old
testbenches and the original TinyTapeout PLL blocks the CDR was derived from.
They were moved out of `xschem/` on 2026-08-15 so that the top level contains
**only** what the taped-out macro actually instantiates.

They are kept rather than deleted because the design logs cite them heavily —
`tuning/NOTES.md`, `tuning/ctle/NOTES_CTLE.md`, `STATUS.md` and `README.md` all
refer to files in here, and deleting them would leave those references dangling.

## They still work

`attic` is on `XSCHEM_LIBRARY_PATH` (see `../xschemrc`), so symbols resolve in
both directions — a schematic in here can instantiate one from the parent, and
`tuning/ctle/subckt_src.sch` can still instantiate `D2S_amp.sym` from in here.
Both directions were verified by netlisting after the move.

**Do not remove `attic` from `XSCHEM_LIBRARY_PATH`.** xschem resolves a missing
symbol *silently* — you get a truncated netlist with "Symbol not found" and
rc=0, not a failure. That is the single most expensive trap in this repo.

## What is in here

| group | files |
|---|---|
| CDR testbenches | `CDR_tb`, `CDR_single`, `full_tb`, `alexander_loop`, `alexander_loop_tb`, `testbench`, `just_in_case` |
| CTLE testbenches | `CTLE_testbench`, `CTLE_WITH_LATCH` |
| the old output chain | `D2S_amp`, `double_inverter`, `s2d`, `TSPC_Latch` |
| demux experiments | `demux`, `demux_tb`, `demux_testbench`, `one_to_two_demux`, `one_two_demux_tb`, `divide_by_two`, `divide_by_two_tb` |
| ring/VCO benches | `ring_oscillator_tb`, `vco_testbench`, `diff_savefile` |
| original TinyTapeout PLL | `tiny_pll`, `tiny_pll_divider`, `tiny_pll_divider_cell`, `tiny_pll_pfd`, `tiny_pll_pfd_sr_latch`, `tiny_pll_vco`, `tiny_pll_vco_inv` |

Two things worth knowing about these:

- **`D2S_amp` is no longer in the signal path.** The old chain was
  `CTLE → latch → latch → D2S_amp → inverter_chain`. The CDR's recovered clock is
  already single-ended and rail-to-rail, so the macro drives `inverter_chain`
  directly. `D2S_amp` was §C12's "narrowest link in the chain" — that concern is
  moot now.
- **The `tiny_pll_pfd` / divider path is a documented dead end.** The CDR is
  reference-less; a PFD needs an independent trusted `clk_ref` which this chip
  does not have. See `tuning/NOTES.md` §15c before reconsidering it.

`CTLE_WITH_LATCH.sch` in particular is the architecture the old `docs/info.md`
described, where the retiming latches were clocked from **ideal pulse sources** —
i.e. the clock was not actually being recovered. It is superseded by
`../ctle_cdr_rx.sch`.
