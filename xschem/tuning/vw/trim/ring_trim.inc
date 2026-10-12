* Ring coarse trim (option 5), 2026-10-12. Sized with the R1T bench (gen_r1t.py).
*
* ring_trim3: one per ring output node (5 stages x 2 sides = 10), all sharing
* three active-low control lines b0n..b2n. Each bit switches an xhigh_po leg in
* parallel with that node's load: lower R -> faster ring (the ring is RC-limited
* above ~0.8 V, NOTES 20b). The pMOS switch sits at the VDD end so it stays in
* deep triode; the poly sets the value (the IHP ring-coarse-tune pMOS-as-resistor
* trim was only ~43 % effective).
*
* Sizing history (all R1T, tt/27C, vctrl 0.79 V, untrimmed ring 608 MHz):
*  - res_high_po legs (W=1, L=94/187): their capacitance SLOWED the ring to
*    ~380 MHz. Moved to xhigh_po W=0.35 (2 kohm/sq, 6x shorter for the same R).
*  - 2 fast bits + 2 switched MIM caps (slow): caps never needed (every corner
*    sits below 600.6 MHz with the trim off), and 2 fast bits gave ~11 % steps,
*    coarser than the ~6 % window the 0.79 V seed can pull in from. -> 3 bits.
*  - the idle legs' capacitance slows the ring ~17 % with every bit off
*    (608 -> 503 MHz). An always-on 90 k xhigh_po leg to shift the range back
*    up bought only ~1 % (a leg's capacitance grows with its length). Instead
*    the ring's own load is shortened: ring_inverter_t, L 23 -> 20.
*  - leg 2 L 4.0 (was 5.25): bit 2 was ~1 LSB weak (c3 582 vs c4 587 MHz).
.subckt ring_trim3 nd VDD VSS b0n b1n b2n
XR0 nd a0 VSS sky130_fd_pr__res_xhigh_po_0p35 L=21 mult=1
XP0 a0 b0n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 mult=1
XR1 nd a1 VSS sky130_fd_pr__res_xhigh_po_0p35 L=10.5 mult=1
XP1 a1 b1n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 mult=1
XR2 nd a2 VSS sky130_fd_pr__res_xhigh_po_0p35 L=4.0 mult=1
XP2 a2 b2n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 mult=1
.ends

* ring_inverter_t: the frozen ring_inverter (xschem/ring_inverter.sch) with the
* load resistors shortened L 23 -> 20 (~13 % less R) to recentre the trim range.
.subckt ring_inverter_t VDD VSS vin+ vo+ vin- vo- vctrl
XM4 vo- vin- net1 VSS sky130_fd_pr__nfet_01v8 L=1 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1
XM5 net1 vctrl VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=9 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1
XM1 vo+ vin+ net1 VSS sky130_fd_pr__nfet_01v8 L=1 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1
XR1 vo+ VDD VSS sky130_fd_pr__res_high_po W=1 L=20 mult=1
XR2 vo- VDD VSS sky130_fd_pr__res_high_po W=1 L=20 mult=1
.ends
