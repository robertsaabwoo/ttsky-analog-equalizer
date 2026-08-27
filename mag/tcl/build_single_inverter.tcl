# build_single_inverter.tcl -- the reference answer for mag/single_inverter.mag
#
#   magic -rcfile $PDK_ROOT/sky130A/libs.tech/magic/sky130A.magicrc \
#         -noconsole -dnull tcl/build_single_inverter.tcl
#
# This draws the whole cell: two gencell devices from the LVS netlist, the
# wiring, and the four ports.  Verified 2026-08-27: DRC 0, and
# ./lvs_cell.sh single_inverter -> "Circuits match uniquely" with netgen
# folding the fingers 8->1 and 4->1.
#
# It exists as a check, not as the way to work.  Draw the cell by hand in the
# GUI; if the hand-drawn version misbehaves, run this and diff.
#
# ---------------------------------------------------------------- geometry --
# Both devices are placed with the SAME y transform, which makes every strap
# and every gate row line up between them:
#
#   * S/D straps are li1+m1 already stacked by the gencell, 0.23 um wide,
#     y = 1.095..3.095, on a 0.48 um pitch.  nf fingers give nf+1 straps,
#     alternating source/drain, so the OUTER straps are always sources:
#       pfet nf=8 -> 9 straps: 5 source (VDD), 4 drain (OUT)
#       nfet nf=4 -> 5 straps: 3 source (VSS), 2 drain (OUT)
#   * Gates are contacted ALTERNATELY top and bottom -- a poly contact will
#     not fit on adjacent gates at a 0.48 um pitch -- so the gate net needs
#     BOTH rows plus a link between them.
#   * There is no metal1 escape from the strap array: the gate pads overlap
#     the straps in x by 0.02 um.  Hence metal2 rails + via1, not metal1.
# ---------------------------------------------------------------------------

source [file join [file dirname [info script]] res_high_po_gencell.tcl]

load single_inverter
snap internal
box values 0 0 0 0

# -- devices, parameters straight from xschem/simulation/ctle_cdr_rx_lvs.spice
#    (w is TOTAL width here; -spice lets the PDK divide it by nf for us)
magic::gencell sky130::sky130_fd_pr__pfet_01v8 XM1 -spice w 16 l 0.15 nf 8 m 1
magic::gencell sky130::sky130_fd_pr__nfet_01v8 XM2 -spice w 8  l 0.15 nf 4 m 1
select clear ; select cell XM1 ; move to 1.0um 0.0um
select clear ; select cell XM2 ; move to 7.5um 0.045um
select clear

proc pb {x1 y1 x2 y2 layer} {
    box values ${x1}um ${y1}um ${x2}um ${y2}um
    paint $layer
}

# -- IN: one metal1 bar along each gate row, linked up the left edge
pb 0.00 0.660 10.20 0.935 metal1
pb 0.00 3.255 10.20 3.530 metal1
pb 0.00 0.660  0.20 3.530 metal1

# -- via1 down onto the straps.  Magic's via1 TILE carries the metal
#    enclosure, so it must be >= 0.26 um (via.1a + 2*via.4a); the 0.15 um
#    drawn cut is what the CIF writer emits inside it.
proc strapvia {x yc} {
    pb [expr {$x-0.16}] [expr {$yc-0.20}] [expr {$x+0.16}] [expr {$yc+0.20}] metal1
    pb [expr {$x-0.13}] [expr {$yc-0.13}] [expr {$x+0.13}] [expr {$yc+0.13}] via1
}
foreach x {1.835 2.795 3.755 4.715 5.675} { strapvia $x 1.5 }   ;# pfet source -> VDD
foreach x {2.315 3.275 4.235 5.195}       { strapvia $x 2.7 }   ;# pfet drain  -> OUT
foreach x {8.335 9.295 10.255}            { strapvia $x 1.5 }   ;# nfet source -> VSS
foreach x {8.815 9.775}                   { strapvia $x 2.7 }   ;# nfet drain  -> OUT

# -- guard rings.  The gencell ring is a diff+licon+li1 stack with no metal1,
#    so each needs viali (li1->m1) then via1 (m1->m2) up to its rail.
pb 2.00 0.180 2.50 0.350 viali      ;# nwell tap ring -> VDD
pb 1.94 0.060 2.56 0.460 metal1
pb 2.12 0.130 2.38 0.390 via1
pb 2.00 0.060 2.45 1.700 metal2
pb 8.00 0.225 8.50 0.395 viali      ;# psub tap ring -> VSS
pb 7.94 0.105 8.56 0.505 metal1
pb 8.12 0.175 8.38 0.435 via1
pb 8.05 0.105 8.45 1.700 metal2

# -- metal2 rails
pb 1.00 1.30  5.90 1.70 metal2      ;# VDD
pb 7.60 1.30 10.50 1.70 metal2      ;# VSS
pb 2.05 2.50 10.00 2.90 metal2      ;# OUT

# -- ports, in the schematic's order: .subckt single_inverter VDD VSS IN OUT
proc mkport {name x y layer idx} {
    box values ${x}um ${y}um ${x}um ${y}um
    label $name c $layer
    port make $idx
}
mkport VDD 3.00 1.50 metal2 1
mkport VSS 9.00 1.50 metal2 2
mkport IN  0.10 2.00 metal1 3
mkport OUT 6.80 2.70 metal2 4

box values 0 0 0 0
select clear
writeall force
drc check
drc catchup
puts "DRC-COUNT [drc list count total]"
quit -noprompt
