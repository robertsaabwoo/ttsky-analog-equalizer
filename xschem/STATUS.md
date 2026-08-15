# Repository status — branch layout & the state of the real design files

Last updated 2026-08-15.

> **2026-08-15: the real design files now hold the validated design.** The
> section below titled "The real design files still carry pre-validation tuning"
> described the state *before* that promotion and is kept only as history. See
> "Promotion, 2026-08-15" immediately below for what is now true.

## Promotion, 2026-08-15

Every validated block was copied out of the `tuning/` sandbox into its real name
and its internal `*_tune.sym` references rewritten. The promotion was verified at
**netlist** level, not by eye: `CDR.sch` was re-netlisted and compared against the
validated `tuning/e2e_blocks.inc`, and **all 17 leaf subcircuits matched exactly**
with an identical top-level instance list.

Promoted: `CTLE`, `CDR`, `ring_oscillator`, `ring_inverter`, `diff_amp_inv`,
`alexander_phase_detector`, `d_flip_flop`, `d_latch`, `robs_xor`,
`inverter_buffer`, `tiny_pll_loop_filter{,_cap1,_cap2}`. New blocks with no
previous real counterpart: **`single_inverter`**, **`vctrl_precharge`**.

`tiny_pll_charge_pump` and `tiny_pll_bias_gen` were deliberately NOT touched —
the charge pump is already taped out.

Two consequences to be aware of:

- **`CDR.sym` gained a `vbias` pin** (6 pins → 7). It is the only promoted block
  whose interface changed. `full_tb.sch` and `demux_tb.sch` instantiate the old
  6-pin `CDR.sym` and are now stale; they are development testbenches, not part
  of the chip path, and were left alone.
- The stale hand-edits in `stash@{0}` are now **definitively superseded**. Do not
  pop them. They can be dropped once someone is confident nothing is wanted.

### New top-level for tapeout

`xschem/ctle_cdr_rx.sch` is the analog macro that Tiny Tapeout instantiates:
`CTLE → CDR → two inverter chains`, with pins
`vinp vinm vbias clkout_p clkout_n VDPWR VGND`. `ctle_cdr_rx_lvs.sch` is a
one-instance wrapper that exists solely so xschem emits a `.subckt` for netgen
(netlisting `ctle_cdr_rx.sch` directly makes it the top and emits no subckt).
`src/project.v` instantiates `ctle_cdr_rx` as a blackbox and defines the pad
wiring, which is what `mag/ make lvs` checks the layout against.

## Branch layout (after the 2026-08-02 reorganization)

| branch | what it holds |
|---|---|
| `main` | The **validated CDR** work: shrunk-cap lock (§16), the startup precharge cell (§17), and the T0/T1 PVT results (§18-20). This is the fast-forward of the old `cdr-shrunk-cap-jitter` up to commit `e3e3062` (`§20`), plus loose design/test files archived here. |
| `ctle-tuning` | `main` **plus the CTLE characterization/retune** (§C1-C22): `tuning/ctle/`, `CTLE_tune.sch`, `NOTES_CTLE.md`. Ongoing CTLE tuning continues here. |
| `chipalooza-proposal` | The Chipalooza Challenge #2 (IHP SG13CMOS5L) design proposal, `PROPOSAL.md`. |
| `cdr-shrunk-cap-jitter` | The original combined branch (CDR + CTLE), left intact as the pre-split reference. |

Read `tuning/HANDOFF.md` and `tuning/NOTES.md` (CDR), and `tuning/ctle/NOTES_CTLE.md`
(CTLE, on `ctle-tuning`) for the full history.

## HISTORY (pre-2026-08-15): the real design files carried pre-validation tuning

The validated design lives in the **`tuning/` sandbox** (`*_tune.sch`), not in the
promoted files at `xschem/*.sch`. The real files (`CDR.sch`, `CDR_tb.sch`,
`ring_inverter.sch`, `d_latch.sch`, `CTLE_WITH_LATCH.sch`, `CDR.sym`) were last
intentionally committed at `c9ee560 "tuned closer to 300 MHz"` — which is the
**known-wrong 300 MHz frequency plan** that §14 later identified as a 2× error and
the root of three sessions of debugging.

At the 2026-08-02 reorganization the working tree also held **stale, half-finished
hand-edits** to those same files (mtimes April-July, all predating the 2026-07-23
sandbox conclusions, and not matching them — e.g. `ring_inverter.sch` had M5 `W=3`
where the validated `ring_inverter_tune.sch` uses `W=9`). Those edits were **stashed,
not committed**:

```
git stash list        # stash@{0}: "STALE pre-validation real-design edits ..."
git stash show -p stash@{0}
```

**Do not `stash pop` these onto the design as-is.** Promotion of the validated
design into the real files should be re-derived from the `tuning/` conclusions
(HANDOFF §4 numbers, NOTES §14/§16/§17, NOTES_CTLE §C17/C20), not from that stash.
The stash is kept only so nothing is silently lost.

## Files deliberately NOT committed

- **Empty xschem templates** (68 B stubs): `untitled.sch`, `demux_tbsch`,
  `alexander_single.sch`.
- **`LA_Limiter.sch/.sym`** — abandoned per NOTES_CTLE §C12/§C15/§C21.4; left
  untracked deliberately (deleting is unrecoverable, committing revives dead WIP).
- **Simulation outputs / data dumps** — `*.raw`, `*.out`, `xschem/vin.txt`,
  `xschem/vip.txt`, and the untracked `tuning/ctle/*.log`/`*.dat` outputs. All are
  regenerable from sources and are gitignored (VM OOM risk per `../CLAUDE.md`).
- **Generated netlists** (e.g. `tuning/CDR_tune_tb.spice`) — regenerate from the
  `.sch` via the netlisting recipe in `../CLAUDE.md` §2.
