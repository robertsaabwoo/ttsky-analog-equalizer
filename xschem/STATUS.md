# Repository status — branch layout & the state of the real design files

Last updated 2026-08-02.

## Branch layout (after the 2026-08-02 reorganization)

| branch | what it holds |
|---|---|
| `main` | The **validated CDR** work: shrunk-cap lock (§16), the startup precharge cell (§17), and the T0/T1 PVT results (§18-20). This is the fast-forward of the old `cdr-shrunk-cap-jitter` up to commit `e3e3062` (`§20`), plus loose design/test files archived here. |
| `ctle-tuning` | `main` **plus the CTLE characterization/retune** (§C1-C22): `tuning/ctle/`, `CTLE_tune.sch`, `NOTES_CTLE.md`. Ongoing CTLE tuning continues here. |
| `chipalooza-proposal` | The Chipalooza Challenge #2 (IHP SG13CMOS5L) design proposal, `PROPOSAL.md`. |
| `cdr-shrunk-cap-jitter` | The original combined branch (CDR + CTLE), left intact as the pre-split reference. |

Read `tuning/HANDOFF.md` and `tuning/NOTES.md` (CDR), and `tuning/ctle/NOTES_CTLE.md`
(CTLE, on `ctle-tuning`) for the full history.

## The real design files still carry pre-validation tuning — DO NOT trust them yet

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
