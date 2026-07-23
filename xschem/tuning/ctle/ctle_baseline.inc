.subckt CTLE vout+ vout- vin+ vin- VDD VSS vbias
*.iopin VDD
*.iopin VSS
*.ipin vin+
*.ipin vin-
*.ipin vbias
*.opin vout-
*.opin vout+
XM1 vout+ vin+ net1 VSS sky130_fd_pr__nfet_01v8 L=0.3 W=10 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)'
+ ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM2 net3 vbias VSS VSS sky130_fd_pr__nfet_01v8 L=0.5 W=20 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)'
+ ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 vout- vin- net2 VSS sky130_fd_pr__nfet_01v8 L=0.3 W=10 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)'
+ ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR1 vout+ VDD VSS sky130_fd_pr__res_high_po W=1 L=16 mult=1 m=1
XR2 vout- VDD VSS sky130_fd_pr__res_high_po W=1 L=16 mult=1 m=1
XR3 net1 net3 VSS sky130_fd_pr__res_high_po W=1 L=0.69 mult=1 m=1
XC2 net1 net3 sky130_fd_pr__cap_mim_m3_1 W=13 L=13 MF=1 m=1
XR4 net2 net3 VSS sky130_fd_pr__res_high_po W=1 L=0.69 mult=1 m=1
XC1 net2 net3 sky130_fd_pr__cap_mim_m3_1 W=13 L=13 MF=1 m=1
.ends
