v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {LVS/source-netlist wrapper.

Netlisting ctle_cdr_rx.sch on its own makes it the TOP of the netlist, so
xschem emits its contents flat with no `.subckt` wrapper.  netgen needs a
named cell to match the layout instance against, so this trivial wrapper
INSTANTIATES ctle_cdr_rx instead -- which makes xschem emit
`.subckt ctle_cdr_rx ... .ends` plus the whole block hierarchy below it.

Netlist this file (not ctle_cdr_rx.sch) to produce the spice that
mag/tcl/lvs_netgen.tcl feeds to netgen as the source side.} -230 -230 0 0 0.4 0.4 {}
N -230 -30 -150 -30 {
lab=vinp}
N -230 -10 -150 -10 {
lab=vinm}
N -230 10 -150 10 {
lab=vbias}
N 150 -30 230 -30 {
lab=clkout_p}
N 150 -10 230 -10 {
lab=clkout_n}
N 150 10 230 10 {
lab=VDPWR}
N 150 30 230 30 {
lab=VGND}
C {ctle_cdr_rx.sym} 0 0 0 0 {name=x1}
C {devices/ipin.sym} -230 -30 0 0 {name=p1 lab=vinp}
C {devices/ipin.sym} -230 -10 0 0 {name=p2 lab=vinm}
C {devices/ipin.sym} -230 10 0 0 {name=p3 lab=vbias}
C {devices/opin.sym} 230 -30 0 0 {name=p4 lab=clkout_p}
C {devices/opin.sym} 230 -10 0 0 {name=p5 lab=clkout_n}
C {devices/iopin.sym} 230 10 0 0 {name=p6 lab=VDPWR}
C {devices/iopin.sym} 230 30 0 0 {name=p7 lab=VGND}
