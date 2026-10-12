* cml_clkbuf -- the clock buffer for the CML design (item 1, 2026-10-12)
* A copy of the frozen diff_amp_inv with both tail transistors moved to L=0.5
* so they mirror cml_bias's diode (W=0.75 L=0.5, ~18 uA per um of W) on vbn,
* replacing the ideal vtail = 0.85 V source. Widths set for the currents the
* frozen cell drew at vtail = 0.85 V, tt/27C (B3a): stage 1 17.2 uA, stage 2
* 194 uA (stage-2 W trimmed 10.8 -> 8.9 for its Vds, B3b). Loads unchanged (res_high_po, the reference's material, so the swing
* tracks the reference). The frozen diff_amp_inv is untouched.
.subckt cml_clkbuf VDD VSS vo- vo+ vin- vin+ vbn
XM2 vo-_temp vin- net1 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=3 nf=1
XM3 net1 vbn VSS VSS sky130_fd_pr__nfet_01v8 L=0.5 W=0.96 nf=1
XM6 vo+_temp vin+ net1 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=3 nf=1
XR3 vo+_temp VDD VSS sky130_fd_pr__res_high_po W=0.5 L=10 mult=1
XR4 vo-_temp VDD VSS sky130_fd_pr__res_high_po W=0.5 L=10 mult=1
XM1 vo- vo-_temp net2 VSS sky130_fd_pr__nfet_01v8 L=0.5 W=6 nf=1
XM4 net2 vbn VSS VSS sky130_fd_pr__nfet_01v8 L=0.5 W=8.9 nf=2
XM5 vo+ vo+_temp net2 VSS sky130_fd_pr__nfet_01v8 L=0.5 W=6 nf=1
XR1 vo+ VDD VSS sky130_fd_pr__res_high_po W=1 L=17.5 mult=1
XR2 vo- VDD VSS sky130_fd_pr__res_high_po W=1 L=17.5 mult=1
.ends
