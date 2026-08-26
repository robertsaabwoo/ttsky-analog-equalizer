#-----------------------------------------------------------------------
# res_high_po_gencell.tcl
#
# Adds a Magic device generator for sky130_fd_pr__res_high_po at ARBITRARY
# width. The sky130A PDK ships generators only for the five fixed widths
# (0p35, 0p69, 1p41, 2p85, 5p73); this design uses W=1 and W=0.5, so
# `magic::gencell sky130::sky130_fd_pr__res_high_po` fails with
# "No import routine" and 22 of the 224 devices cannot be auto-generated.
#
# This is legitimate rather than a hack:
#   - the SPICE model is fully parameterised in w and l
#     (libs.ref/sky130_fd_pr/spice/sky130_fd_pr__res_high_po.model.spice,
#      ".subckt sky130_fd_pr__res_high_po r0 r1 b + w=1 l=1")
#   - magic's extractor already emits the arbitrary-width device
#     (sky130A.tech:5877, "l=l+0.16 w=w", no width constraint)
#   - magic's DRC enforces only a 0.35 um minimum (sky130A.tech:4683);
#     the discrete-width line above it is a comment, not a rule
#   - every *_draw proc for the five fixed widths is byte-identical except
#     mask_clearance on 0p35, so res_draw itself is width-agnostic
#
# CAVEAT: the foundry qualifies res_high_po at the five discrete widths.
# W=1 and W=0.5 are modelled and DRC-clean but not on that list. That is a
# design question, not a tooling one -- see mag/LAYOUT_HANDOFF.md.
#
# Load with:  source tcl/res_high_po_gencell.tcl
#-----------------------------------------------------------------------

namespace eval sky130 {}

# Defaults: as sky130_fd_pr__res_high_po_0p69_defaults, but with the width
# unpinned -- wmin at the DRC floor and wmax 0, which res_check reads as
# "no upper clamp" (sky130A.tcl:4710).
proc sky130::sky130_fd_pr__res_high_po_defaults {} {
    return {w 1.000 l 1.00 m 1 nx 1 wmin 0.350 lmin 0.50 \
		rho 319.8 val 0 dummy 0 dw 0.0 term 194.82 \
		sterm 0.0 caplen 0 guard 1 glc 1 grc 1 gtc 1 gbc 1 \
		compatible {sky130_fd_pr__res_high_po \
		sky130_fd_pr__res_high_po_0p35 \
		sky130_fd_pr__res_high_po_0p69 sky130_fd_pr__res_high_po_1p41 \
		sky130_fd_pr__res_high_po_2p85 sky130_fd_pr__res_high_po_5p73} \
		snake 0 full_metal 1 wmax 0 n_guard 0 hv_guard 0 vias 1 \
		viagb 0 viagt 0 viagl 0 viagr 0}
}

# The -spice import path, so W/L come straight off the netlist line.
proc sky130::sky130_fd_pr__res_high_po_convert {parameters} {
    return [sky130::res_convert $parameters]
}

proc sky130::sky130_fd_pr__res_high_po_check {parameters} {
    return [sky130::res_check sky130_fd_pr__res_high_po $parameters]
}

proc sky130::sky130_fd_pr__res_high_po_dialog {parameters} {
    sky130::res_dialog sky130_fd_pr__res_high_po $parameters
}

# Geometry is width-independent above 0.35 um, so defer to the 0p69 drawing
# routine rather than duplicating its rule dictionary.
proc sky130::sky130_fd_pr__res_high_po_draw {parameters} {
    return [sky130::sky130_fd_pr__res_high_po_0p69_draw $parameters]
}
