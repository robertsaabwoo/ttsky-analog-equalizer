* ctle_f.inc — same topology as ctle_p2.inc, but the sizes are SUBCKT parameters
* instead of global .params, so two instances in one deck can be sized
* differently.  Needed for the cascade experiments (stage 1 and stage 2 want
* different degeneration).  Override per instance:
*   x1 outp outm inp inm VDD VSS vbias ctle_f Win=20 Ldeg=3.0 Wcap=24
.subckt ctle_f outp outm inp inm VDD VSS vbias
+ Win=10 Lin=0.3 Wtail=20 Ltail=0.5 Lload=20 Ldeg=1.5 Wcap=18
+ Mload=1 Mdeg=1 Mcap=1
XM1 outp inp sp VSS sky130_fd_pr__nfet_01v8 L='Lin' W='Win' nf=1
+ ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29'
+ pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)'
+ nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 outm inm sm VSS sky130_fd_pr__nfet_01v8 L='Lin' W='Win' nf=1
+ ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29'
+ pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)'
+ nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM2 st vbias VSS VSS sky130_fd_pr__nfet_01v8 L='Ltail' W='Wtail' nf=1
+ ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29'
+ pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)'
+ nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR1 outp VDD VSS sky130_fd_pr__res_high_po W=1 L='Lload' mult='Mload' m='Mload'
XR2 outm VDD VSS sky130_fd_pr__res_high_po W=1 L='Lload' mult='Mload' m='Mload'
XR3 sp st VSS sky130_fd_pr__res_high_po W=1 L='Ldeg' mult='Mdeg' m='Mdeg'
XR4 sm st VSS sky130_fd_pr__res_high_po W=1 L='Ldeg' mult='Mdeg' m='Mdeg'
XCS sp sm sky130_fd_pr__cap_mim_m3_1 W='Wcap' L='Wcap' MF='Mcap' m='Mcap'
.ends
