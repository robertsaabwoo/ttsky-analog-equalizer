# Building this layout in Magic — a working plan

Written for someone who knows the circuit but is new to Magic. Read
`LAYOUT_HANDOFF.md` first for *what* the design is; this is *how* to draw it.

---

## 0. The mental model

Magic is a layout editor where you paint rectangles of process layers and place
instances of other cells. For analog sky130 you almost never draw a transistor by
hand — the PDK has a **parameterised device generator**: you ask for an nfet with
W=5, L=0.15, and it creates a cell called something like
`sky130_fd_pr__nfet_01v8_BBNS5X` with correct diffusion, poly, contacts and
implants. You then place that cell.

So the loop for every block is:

1. **generate** the devices it needs
2. **place** them sensibly
3. **wire** them with metal1/metal2
4. **label** each wire that is a pin, and **mark the label as a port**
5. **`:drc check`** until clean
6. **`./lvs_cell.sh <cell>`** until it matches
7. move up one level and use that cell as a building block

The cell hierarchy in Magic should mirror the schematic hierarchy exactly. If you
do that, LVS works at every level and you never debug the whole chip at once.

---

## 1. Setup

```bash
export PDK_ROOT=/home/ttuser/pdk
export PDK=sky130A
cd mag
make magic            # opens $(PROJECT_NAME).mag
```

Inside Magic, the command line is at the bottom — commands start with `:`.
Mouse: **left** sets one corner of the box, **right** sets the other, **middle**
paints the current layer into the box.

To work on a specific cell rather than the top:

```
:load d_latch          # open (or create) d_latch.mag
:save                  # save it
:writeall              # save every modified cell — use this, it is easy to
                       # lose a subcell edit otherwise
```

---

## 2. The golden rule: verify every cell before you build on it

I wrote you a tool for this:

```bash
./lvs_cell.sh d_latch
```

It extracts that one cell and compares it against the same cell in the schematic
netlist. **Use it after every single block.** `make lvs` only checks the whole
chip, which tells you nothing useful until the very end.

### It already found something

There is a half-finished `d_latch.mag` in this directory from an earlier session.
Running the tool on it right now gives:

```
Number of nets: 17  **Mismatch**   |  Number of nets: 14  **Mismatch**
(no matching pin)                  |  vout+
(no matching pin)                  |  vin+     ...
Final result: Top level cell failed pin matching.
```

Two lessons in one output, and both will happen to you:

- **17 nets vs 14** — the devices are placed but not fully wired, so terminals
  that should be one net are still separate.
- **"no matching pin"** even though the labels exist — **a label is not a port
  until you make it one.** This is the single most common Magic beginner trap.

Also note that `d_latch.mag` has an **`XR2` that the current schematic does not
have** — it was drawn against the pre-promotion d_latch. Treat it as a reference
for what device placement looks like, not as work to finish.

---

## 3. Recommended build order

Bottom-up, easiest first so you learn the flow on something forgiving.

### Warm-up — learn the tool (do these first)

| # | cell | devices | why this one |
|---|---|---|---|
| 1 | `single_inverter` | 2 | The whole flow end to end in the smallest possible cell. Two transistors, four wires. Do this one twice if the first is messy. |
| 2 | `inverter_chain` | 6 | Same idea, now a chain. You will build two of these; they drive the output pads. |
| 3 | `inverter_buffer` | 4 | More multi-finger devices (`nf=4`, `nf=8`). |

### Tier 1 — the remaining leaf cells (no subcells)

| # | cell | devices | notes |
|---|---|---|---|
| 4 | `robs_xor` | 8 | All identical W=2 devices. Good practice at regular placement. |
| 5 | `d_latch` | 13 | **The workhorse — 8 copies end up in the chip.** Spend real time here; every improvement pays off ×8. Redraw rather than patch the stale one. |
| 6 | `ring_inverter` | 5 | **5 copies, and they must match.** See §5. |
| 7 | `diff_amp_inv` | 10 | Differential pair — draw it symmetrically. |
| 8 | `CTLE` | 8 | Contains the MiM cap. See §5. |
| 9 | `vctrl_precharge` | 9 | Contains the L=120 µm resistor and an 8×8 µm MOS cap. See §5. |
| 10 | `tiny_pll_loop_filter_cap1` | 1 | One device, `mult=6` — six fingers/copies. |
| 11 | `tiny_pll_loop_filter_cap2` | 1 | One device. |
| 12 | `tiny_pll_loop_filter_res` | 1 | One resistor, L=15. |
| 13 | `tiny_pll_bias_gen_res` | 3 | Three L=1.8 resistors. |
| 14 | `tiny_pll_bias_gen` | 13 | Current mirrors — **match the mirror pairs.** |
| 15 | `tiny_pll_charge_pump` | 5 | Contains a standard cell (`sky130_fd_sc_hd__inv_1`) — instantiate it from the sky130 std cell library, do not draw it. |

### Tier 2 — cells built from Tier 1

| # | cell | contains |
|---|---|---|
| 16 | `d_flip_flop` | 2 × `d_latch` |
| 17 | `ring_oscillator` | 5 × `ring_inverter` + 1 × `diff_amp_inv` |
| 18 | `tiny_pll_loop_filter` | `cap1` + `cap2` + `res` |

### Tier 3 and up

| # | cell | contains |
|---|---|---|
| 19 | `alexander_phase_detector` | 4 × `d_flip_flop` + 2 × `robs_xor` |
| 20 | `CDR` | `ring_oscillator`, `tiny_pll_loop_filter`, `alexander_phase_detector`, `diff_amp_inv`, `tiny_pll_charge_pump`, `tiny_pll_bias_gen`, `inverter_buffer`, `single_inverter`, `vctrl_precharge` |
| 21 | `ctle_cdr_rx` | `CTLE` + `CDR` + 2 × `inverter_chain` |
| 22 | `tt_um_robertsaabwoo_ctle_clock_recovery` | one `ctle_cdr_rx`, wired to the pads |

At step 22 you are wiring the macro to the TT frame:
`vinp→ua[0]`, `vinm→ua[1]`, `vbias→ua[2]`, `clkout_p→uo_out[0]`,
`clkout_n→uo_out[1]`, plus `VDPWR`/`VGND`. Then `make lvs` should finally match.

---

## 4. Exact device list per cell

Sizes are µm. Where `W` is absent it is the default `W=1`. `nf` is fingers.

```
CTLE (8)                        d_latch (13)
  M1  nfet  W=20  L=0.3           M1,M3,M4,M5,M6,M7  nfet W=5 L=0.15
  M2  nfet  W=20  L=0.5           M2                 nfet W=8 L=0.15
  M4  nfet  W=20  L=0.3           M9,M11             nfet W=1 L=0.15
  R1,R2  res_high_po  W=1 L=20    M8,M10             pfet W=3 L=0.15
  R3,R4  res_high_po  W=1 L=5.0   R1,R3  res_high_po_0p69 L=7
  CS  cap_mim_m3_1  18 x 18

robs_xor (8)                    ring_inverter (5)
  M1,M2,M3,M5  pfet W=2 L=0.15    M1,M4  nfet W=3
  M4,M6,M7,M8  nfet W=2 L=0.15    M5     nfet W=9 L=0.15   <- replica of MBD
                                  R1,R2  res_high_po W=1 L=23

diff_amp_inv (10)               inverter_chain (6)
  M2,M6  nfet W=3 L=0.15          M1 pfet W=2  L=0.15
  M3     nfet W=2                 M2 nfet W=1  L=0.15
  M1,M5  nfet W=6 L=0.5           M3 pfet W=6  L=0.15 nf=4
  M4     nfet W=8 L=0.15 nf=4     M4 nfet W=3  L=0.15 nf=2
  R1,R2  res_high_po W=1  L=17.5  M5 pfet W=16 L=0.15 nf=8
  R3,R4  res_high_po W=0.5 L=10   M6 nfet W=8  L=0.15 nf=4

inverter_buffer (4)             single_inverter (2)
  M3 pfet W=6  L=0.15 nf=4        M1 pfet W=16 L=0.15 nf=8
  M4 nfet W=7  L=0.15 nf=2        M2 nfet W=8  L=0.15 nf=4
  M5 pfet W=16 L=0.15 nf=8
  M6 nfet W=8  L=0.15 nf=4

vctrl_precharge (9)             tiny_pll_charge_pump (5)
  R1    res_xhigh_po_0p35 L=120    MNSRC nfet W=1 L=1
  MCPOR nfet W=8 L=8               MNSW  nfet W=0.5 L=0.15
  MP1   pfet W=1 L=1               MPSW  pfet W=1 L=0.15
  MN1   nfet W=0.5                 MPSRC pfet W=2 L=1
  MP2   pfet W=2 L=0.15            INV   sky130_fd_sc_hd__inv_1  (std cell)
  MN2   nfet W=1 L=0.15
  MBP   pfet W=6                  loop filter
  MBD   nfet W=6 L=0.15            cap1  nfet W=4   L=0.6  mult=6
  MSW   nfet W=8 L=0.6             cap2  nfet W=1.1 L=2
                                   res   res_xhigh_po_0p35 L=15
tiny_pll_bias_gen (13)          tiny_pll_bias_gen_res (3)
  MNMIR,MNDIO,MNSU1  nfet W=1      R0,R1,R2  res_xhigh_po_0p35 L=1.8
  MPDIO  pfet W=2
  MPMIR  pfet W=2 mult=2
  MNEN1,MNSU2,MNEN2  nfet W=0.5 L=0.15
  MPEN1,MPEN2,MPSU1,MPSU2  pfet W=0.5 L=0.15
```

### Device cells already generated

An earlier session left these in `mag/`, and the bounding boxes scale at exactly
200 internal units per µm of width, which identifies them:

| generated cell | is |
|---|---|
| `sky130_fd_pr__nfet_01v8_648S5X` | nfet W=1, L=0.15 |
| `sky130_fd_pr__nfet_01v8_BBNS5X` | nfet W=5, L=0.15 |
| `sky130_fd_pr__nfet_01v8_QLNS5P` | nfet W=8, L=0.15 |
| `sky130_fd_pr__pfet_01v8_XGAKDL` | pfet W=3, L=0.15 |
| `sky130_fd_pr__res_high_po_0p69_SBL2T3` | res_high_po_0p69, L=7 |
| `sky130_fd_pr__nfet_01v8_LNEWK8` | unused by `d_latch` — check its parameters before reusing |

The first five are exactly the `d_latch` device set, so you can reuse them
directly. Generate new ones with the **Devices** menu in the Magic toolbar, or
`:magic::gencell sky130_fd_pr__nfet_01v8` which opens the parameter dialog.

---

## 5. Things specific to *this* design

**The ring oscillator is the one place where sloppiness shows up as a spec
failure.** Its five `ring_inverter` stages should be placed in a row, identical
orientation, identical routing per stage. Asymmetry becomes recovered-clock
duty-cycle error — and there is already a known duty-cycle problem (`rclk-` is
~61% vs `rclk+` ~33%), so do not add to it.

**`MBD` in `vctrl_precharge` is a deliberate replica of `M5` in
`ring_inverter`.** Both are nfet with L=0.15 (W=6 and W=9). That replica
relationship is why the startup circuit tracks the VCO over PVT and why 45/45
PVT corners pass. **Lay them out the same way** — same orientation, same finger
style, ideally the same generated cell where widths allow. Do not let one become
multi-finger and the other single.

**The MiM cap (`CS`, 18×18 µm in the CTLE) sits above metal3.** It costs almost
no floor area if you place logic underneath it. Do not reserve 324 µm² of empty
silicon for it.

**The long resistors define the shape of things.** `res_high_po` W=1, L=20–23 —
22 of them. And `vctrl_precharge`'s `R1` is `res_xhigh_po_0p35` at **L=120 µm**,
which will not fit as a straight strip; serpentine it. Decide the resistor
orientation early because it sets the aspect ratio of the CTLE, the d_latches and
the ring.

**Match the current mirrors** in `tiny_pll_bias_gen` (`MNMIR`/`MNDIO`,
`MPMIR`/`MPDIO`) — common-centroid or at least identical orientation and
adjacent placement.

**Differential pairs** (`CTLE` M1/M4, `diff_amp_inv` M1/M5 and M2/M6,
`d_latch` M1/M4) want symmetric placement and symmetric routing.

**Area is not tight.** 1162 µm² of drawn devices in a 75 603 µm² tile. Spend the
space on guard rings, wide supplies and matching. Do not cram.

---

## 6. Magic commands you will actually use

```
:load <cell>        open/create a cell        :save / :writeall   save
:getcell <cell>     place an instance         :edit               descend into instance
:expand / :unexpand see inside instances      :select             select under cursor
:copy  :move        duplicate / relocate      :array <x> <y>      tile an instance
:paint <layer>      paint into the box        :erase <layer>
:box                print box coordinates     :grid               toggle grid
:label <name>       label the box on a layer
:port make          MAKE THAT LABEL A PORT    <- LVS needs this
:drc check          run DRC on the cell       :drc why            explain errors here
:drc count          how many errors left
:feedback why       what magic complained about
```

Ports, concretely: put the box on the metal of the pin, `:label vin+`, then
`:port make`. Without `:port make` LVS reports "no matching pin" even though you
can see the label — that is exactly what the stale `d_latch` shows.

Port names must match the schematic **exactly**, including `+`/`-`:
`vout+ vout- vin+ vin- VDD VSS clk+ clk- vbias` for `d_latch`.

---

## 7. Traps

- **A missing symbol/cell is resolved silently.** Truncated result, no error.
  If a count looks wrong, believe the count.
- **`make lvs` skips netgen if `lvs.report` is newer than its inputs** — you get
  a stale pass/fail with no circuit contents. `rm -f lvs.report *.lvs.spice`
  before a real re-check. `lvs_cell.sh` always re-extracts, so it is safe.
- **Regenerate the source netlist after any schematic change**, or you are
  checking against a stale reference:
  ```bash
  cd ../xschem && xschem -n -s -x -q --rcfile ./xschemrc -o simulation ctle_cdr_rx_lvs.sch
  ```
- **`make start` will silently keep the existing top `.mag`** — delete it first if
  you ever change the template.
- **Do not modify `tiny_pll_charge_pump`'s schematic.** It is already taped out.
  You still have to *lay it out*, but the devices are fixed.
- **Save subcells.** `:save` only saves the current cell; `:writeall` saves all.

---

## 8. A reasonable first session

1. `make magic`, then `:load single_inverter`
2. Generate a pfet W=16 L=0.15 nf=8 and an nfet W=8 L=0.15 nf=4
3. Place them, wire drains together, wire the gates together
4. Label and `:port make`: `VDD`, `VSS`, `IN`, `OUT`
5. `:drc check` until `:drc count` is 0
6. `:save`
7. `./lvs_cell.sh single_inverter` until it says **MATCHES**

When that works you have used every part of the flow, and everything after it is
the same thing at larger scale.
