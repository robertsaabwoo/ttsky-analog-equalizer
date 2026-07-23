# PVT test suite for the CDR startup precharge (§18)

Everything here is **built but not run**. Generating decks is free; running them
is not. Invoke a tier when you actually want the answer.

    ./gen_pvt.py                 # netlist the schematics + write all 63 decks
    ./run_pvt.sh T0              # then a tier at a time
    ./collect_pvt.py T0          # table with PASS/FAIL

`decks/`, `results/` and `.netlists/` are gitignored — they are regenerated from
the schematics, so a deck can never silently drift from the design.

---

## Why this suite exists

§17 built `vctrl_precharge_tune`, the POR one-shot that seeds vctrl above the VCO
dead-zone cliff at power-up so the reference-less bang-bang CDR can acquire from
*either* power-up data polarity. It was validated only at **tt / 27 °C / 1.8 V**.

Two of its properties age differently across PVT, and that asymmetry is the whole
point of the suite:

- the **hold level** is `Vgs` of a diode-connected NMOS that is a scaled replica of
  the ring tail device M5. It is *supposed* to track: if the cliff moves with
  threshold, the seed moves with it. **T1 checks that this tracking actually works.**
- the **release time** `t_rel` is an `R x C` — a poly resistor and a MOS gate cap.
  Nothing makes that track anything. It only has to stay inside a window.
  **T1b (RC corners) is the test that can actually break it.**

And there is a third thing that PVT can break which has nothing to do with the
precharge at all: the VCO might simply not reach 600 MHz at a corner. **T0 exists to
separate that failure from a precharge failure**, so a red T2 result can be
diagnosed instead of guessed at.

---

## Corner axes

In sky130 the MOS corner and the R/C corner are **independent**: `.lib ss` moves only
the transistors, `.lib hh`/`ll` move only R and C. The stock `.lib` sections cannot
express "slow transistors *and* high resistors", so `gen_pvt.py` emits the underlying
`.include` lines directly and combines them freely.

| axis | values | what it moves |
|---|---|---|
| MOS | `tt ss ff sf fs` | thresholds, inverter trip points, the M5 replica |
| RC | `typ` / `hh` (res+cap high) / `ll` (res+cap low) | **`t_rel`** |
| temp | −40, 27, 125 °C | everything |
| VDD | 1.62, 1.80, 1.98 V (±10 %) | bias current, VCO range, data swing |

Supply corners scale the data swing and `vbias` with VDD, since both are
rail-referenced in this testbench.

---

## The tiers

### T0 — VCO tuning range (11 decks, ~1 min each, cheap)

Ring oscillator open-loop. Sweeps vctrl over
`0.60 … 1.40 V` **inside a single ngspice run** via `alter`, so one invocation gives
the whole `f(vctrl)` curve for a corner.

Answers: *where is the dead-zone cliff at this corner, and is 600.6 MHz still
reachable?*

**PASS** = the ring oscillates at the 0.79 V seed **and** 600.6 MHz lies inside the
achievable frequency range.

> A ring started from `uic` sits exactly on its metastable DC point and never
> oscillates, so each deck kicks one node with `.ic v(vo+)=VDD`. Every corner
> therefore starts identically and the comparison is fair.

Measured tt/27 °C/1.8 V baseline (already run):

```
0.60:    -   0.65:    -   0.70:  514   0.75:  571   0.79:  602
0.85:  609   0.90:  610   1.00:  615   1.20:  619   1.40:  621
```

Note how narrow this is: **514–621 MHz**, and it flattens hard above 0.9 V. The
600.6 MHz target sits at vctrl ≈ 0.785 V on the steep part of the curve, with only
~20 MHz of headroom above it. That is the number to watch at ss/125 °C — if the
curve drops far enough that 600.6 MHz falls off the top, the loop cannot lock at
that corner **for reasons that have nothing to do with the precharge**, and the fix
would be the ring resistor, not this cell.

### T1 — precharge cell alone (45 decks, ~10 s each, cheap)

The cell driven by a **real supply ramp** (`PWL(0 0 50n VDD)`) with `uic` and **no
`.ic` anywhere in the deck**. Every node starts at 0, exactly like a cold power-up.
This is the test that proves the cell self-starts rather than being helped by an
initial condition.

- **T1a** MOS {tt,ss,ff} × T {−40,27,125} × VDD {1.62,1.80,1.98} — 27 decks
- **T1b** MOS {tt,ss,ff} × RC {hh,ll} × T {−40,125} — 12 decks — *the `t_rel` test*
- **T1c** MOS {sf,fs} × T {−40,27,125} — 6 decks — INV_A's trip point is a p/n
  ratio, so the skew corners are where the one-shot timing is most exposed

**PASS** = all four of:

| criterion | window | why |
|---|---|---|
| `nbias` hold | `[cliff+0.03, 1.10]` V | must clear the cliff, must not slam the rail |
| seed above cliff | `vc_h > cliff` | the entire purpose of the cell |
| switch drop | `abs(vc_h − nb_h) < 50 mV` | MSW must actually pass the bias |
| release | `40 ns ≤ t_rel ≤ 600 ns` | long enough for the VCO to be alive (≥ ~25 UI), short enough not to stall lock |

The cliff is **not** hardcoded: `collect_pvt.py` reads the per-corner cliff out of
the matching T0 result and judges T1 against *that*. Run T0 before T1 and the
criterion sharpens automatically; run T1 alone and it falls back to 0.65 V.

Measured tt/27 °C/1.8 V baseline (already run): `nbias 0.801, seed 0.801, release
149 ns` — identical to the hand-built §17d deck, which is what validates the harness.

### T2 — full CDR loop (7 decks, **~15–20 min each**, HEAVY)

The whole loop, **bad power-up polarity** — the §16g case that never acquired
without help. The only initial condition is `.ic v(x1.x20.nrc)=0`, i.e. the POR cap
is discharged at power-up. vctrl itself is never seeded.

> `.op` treats a capacitor as an open, so without that one `.ic` the POR node would
> solve to VDD and the one-shot could never fire. It is not a hidden vctrl seed —
> T1 proves the same cell self-starts with no `.ic` at all.

Decks: `ss`/`ff` × −40/125 °C, plus `tt` at 1.62 V and 1.98 V, plus **one
good-polarity regression** at ss/125 °C to confirm the cell does not break the
polarity that already worked.

**PASS** = clock alive (`l_cp_pp > 1.0 V`) **and** vctrl not railed **and**
frequency within 0.5 % of 600.6 MHz.

The verdict string always states whether the **cell** did its job (`cell OK` vs
`CELL DID NOT SEED`, from `t_rel` and `h_vctrl`) separately from whether the **loop**
locked, and a railed vctrl is reported explicitly as *"VCO tuning range exhausted,
not a precharge failure"*. Cross-check any T2 failure against the T0 curve for the
same corner before touching the cell.

---

## Running it safely on this VM

The VM is weak (7.8 GB / 4 CPU) and has been crashed once by an unguarded ngspice.
`run_pvt.sh` therefore:

- runs **strictly one ngspice at a time** — never parallel
- wraps every run in `../safe_ngspice.sh` (hard `ulimit -v`, wall-clock `timeout`,
  `/proc/meminfo` watchdog, `nice`)
- checks free RAM **before** starting each run and aborts the tier if it is below the
  floor, rather than only reacting once a run is already eating memory
- is **resumable**: any deck whose log already contains `exit rc=` is skipped

Guards per tier: T0/T1 use memcap 1500 MB, timeout 600 s; T2 uses 2500 MB, 1800 s.

    ./run_pvt.sh T1                      # whole tier, resumable
    ./run_pvt.sh T2 --budget 3600        # stop STARTING runs after an hour
    ./run_pvt.sh T2 --only T2_bad_ss_typ_125C_1p80
    ./run_pvt.sh T1 --force              # re-run even completed decks

`--budget` never kills a run in flight; it only stops launching new ones, so an
interrupted session resumes cleanly.

### Rough cost

| tier | decks | each | total |
|---|---|---|---|
| T0 | 11 | ~65 s | **~12 min** |
| T1 | 45 | ~10 s | **~8 min** |
| T2 | 7 | ~15–20 min | **~2 h** |

Suggested order: **T0 first** (it defines the cliffs that sharpen T1's criteria and
tells you which corners the VCO can even reach), then **T1**, and only then T2 —
and T2 in chunks with `--budget`.
