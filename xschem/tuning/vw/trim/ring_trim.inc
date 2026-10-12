* ring_trim_node: coarse frequency trim on ONE ring output node (option 5).
* Legs are xhigh_po W=0.35, not res_high_po: a first try with res_high_po
* W=1 L=94/187 SLOWED the ring to ~380 MHz (its body capacitance loads the node).
* Ten of these (five stages x two outputs) share four control lines.
*   f0n, f1n  active-low: a pMOS from VDD switches an xhigh_po leg (~60 k / 30 k)
*             in parallel with
*             the stage's 7.4 k res_high_po load -> lower R -> faster ring
*             (the ring is RC-limited above ~0.85 V; NOTES 20b, IHP RING_DUAL_LOOP 4)
*   s0, s1    active-high: an nMOS switches a MIM cap onto the node -> slower
* The switch sits on the far side of the R / C, so it sees a small swing and
* the stage cell itself is untouched (same idea as IHP ring-coarse-tune).
.subckt ring_trim_node nd VDD VSS f0n f1n s0 s1
.param rf0l=10.5 rf1l=5.25 cs0w=1.5 cs1w=2.2
XRf0 nd a0 VSS sky130_fd_pr__res_xhigh_po_0p35 L=rf0l mult=1
XPf0 a0 f0n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 mult=1
XRf1 nd a1 VSS sky130_fd_pr__res_xhigh_po_0p35 L=rf1l mult=1
XPf1 a1 f1n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 mult=1
XCs0 nd c0 sky130_fd_pr__cap_mim_m3_1 W=cs0w L=cs0w MF=1
XNs0 c0 s0 VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1 mult=1
XCs1 nd c1 sky130_fd_pr__cap_mim_m3_1 W=cs1w L=cs1w MF=1
XNs1 c1 s1 VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1 mult=1
.ends
