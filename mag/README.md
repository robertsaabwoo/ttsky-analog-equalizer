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
