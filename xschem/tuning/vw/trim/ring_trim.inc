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

* ring_trim3: option 5, revised after R1T (2026-10-12). The cap states above
* were never needed (every corner sits below 600.6 MHz with the trim off, the
* off-state parasitics alone slow the ring ~13 %), and two fast bits gave
* ~11 % steps, coarser than the ~6 % window the seed can pull in from.
* So: three binary-weighted fast legs, no caps, active-low pMOS switches.
.subckt ring_trim3 nd VDD VSS b0n b1n b2n
* XRB: always-on leg. The idle legs' own capacitance slows the ring ~18 % with
* every bit off (R1T, tt: 608 -> 497 MHz at vctrl 0.79), so the whole code
* range sits too slow; this shifts it back up so code 0 is ~0.88x the
* untrimmed ring (slow enough for tt_ll / -40 C) and code 7 reaches 125 C.
.param l0=21 l1=10.5 l2=5.25 lb=15.6
XRB nd VDD VSS sky130_fd_pr__res_xhigh_po_0p35 L=lb mult=1
XR0 nd a0 VSS sky130_fd_pr__res_xhigh_po_0p35 L=l0 mult=1
XP0 a0 b0n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 mult=1
XR1 nd a1 VSS sky130_fd_pr__res_xhigh_po_0p35 L=l1 mult=1
XP1 a1 b1n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 mult=1
XR2 nd a2 VSS sky130_fd_pr__res_xhigh_po_0p35 L=l2 mult=1
XP2 a2 b2n VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 mult=1
.ends
