# Setup

Make sure the $PDK_ROOT & $PDK environment variables are setup.

You will need a recent version of Magic and Netgen:

* https://github.com/RTimothyEdwards/magic
* https://github.com/RTimothyEdwards/netgen

# Update files for your project name

* update mag/Makefile to set your project name at the top of the file
* update src/project.v to match your project name

# Initialise the project

Run:

    make start

This sets up a .mag file ready to start working. It includes all the pins for Tiny Tapeout and 2 power lines.

The default is to use a 1x2 block (the smallest). If you need more space - [check here](https://tinytapeout.com/specs/analog/).

# Work on the project

	make magic

# Run LVS

Update src/project.v to add the cells you've used. This Verilog can be treated as blackbox, gatelevel Verilog. So the blackboxed cells don't need to exist, but 
if you want LVS to check your wiring, then the names and wires should all match your intended layout.

If your design includes custom analog blocks, then you can also add their spice netlists to the mag/tcl/lvs_netgen.tcl. 

Then run:

    make lvs

# Run DRC

It's best to be checking DRC as you are drawing your layout. You can check from the commandline like this:

    make drc

# Update the GDS and LEF

Once your layout is ready to submit generate the GDS and LEF:

    make update_gds

Then head to https://app.tinytapeout.com to submit your design onto the next shuttle.

# Note on the 2x2 tile (2026-08-15)

`info.yaml` declares `tiles: "2x2"` and `TEMPLATE_FILE` is `tt_analog_2x2.def`.

Be aware that **the 1x2 and 2x2 templates differ only in `DIEAREA` and the
standard-cell `ROW` definitions** — the pin set and their positions are
byte-identical. So `make start` draws the same frame either way, and the
generated `.mag` has the same ~151.7 x 225.8 um bounding box. That is not a bug:
the 2x2 simply gives you a 334.88 um wide die instead of 161 um, and the extra
width to the right just has no template geometry in it.

Two things follow, for whoever starts the layout:

* `tcl/tt-analog-draw.tcl` only draws power stripes at x = 1 um and x = 4 um
  (see its `POWER_STRIPES` list). That was sized for a 161 um wide die. A 334.88
  um die wants more straps across the width — add them to that list before
  drawing, rather than routing power ad hoc later.
* `make start` will silently keep a pre-existing `$(PROJECT_NAME).mag` instead of
  rebuilding it from the template. Delete the `.mag` first if you change
  `TEMPLATE_FILE`, or you will get the old frame back with no warning.

# Floorplan budget (measured 2026-08-15, from the ctle_cdr_rx netlist)

Device inventory of the whole macro, flattened:

| model | count | drawn um2 |
|---|---:|---:|
| `res_high_po` (L=17.5-23, the load/degeneration resistors) | 22 | 370.0 |
| `cap_mim_m3_1` (the CTLE degeneration cap, 18x18) | 1 | 324.0 |
| `nfet_01v8` | 169 | 299.6 |
| `res_high_po_0p69` (the d_latch loads) | 16 | 77.3 |
| `res_xhigh_po_0p35` | 5 | 49.1 |
| `pfet_01v8` | 47 | 42.2 |
| `sky130_fd_sc_hd__inv_1` | 1 | ~0 |
| **total** | **261** | **1162** |

Per block: CTLE 396 um2 (mostly the one MiM cap), CDR 755 um2, each output
inverter chain 5.4 um2.

**Area is not the constraint, and never was.** Drawn area is 1162 um2. Even at a
5x hand-layout multiplier (contacts, diffusion extension, well spacing, guard
rings, routing channels) that is ~5800 um2, and a realistic hand layout of 216
transistors plus 43 long poly resistors lands somewhere around 10-20k um2:

    1x2 tile   161.00 x 225.76 um =  36 347 um2
    2x2 tile   334.88 x 225.76 um =  75 603 um2

So **1x2 would have fit** with room to spare. 2x2 was chosen for layout comfort,
not necessity — matched placement for the 5-stage differential ring, guard rings
around the CTLE, and generous routing channels are all easier with the extra
width. If tile budget ever matters more than that comfort, dropping back to 1x2
is a two-line change (`info.yaml: tiles` and `TEMPLATE_FILE` here) and the
numbers above say it would still fit.

Things that will actually shape the floorplan, rather than the area total:

* **The 43 poly resistors are long thin strips**, not blobs — `res_high_po` at
  W=1 um, L=20-23 um. They dominate the *shape* of the CTLE and the d_latches
  even though they are a small fraction of the area. Plan serpentines or a
  resistor row early.
* **The MiM cap sits above metal3**, so it can overlap logic below it and costs
  almost nothing in floor area if placed deliberately.
* **The ring oscillator wants symmetry.** Its five `ring_inverter` stages and the
  `diff_amp_inv` should be placed as a matched row; asymmetry there shows up
  directly as recovered-clock duty-cycle error.
