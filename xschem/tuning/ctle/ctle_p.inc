* ctle_p.inc — parametrized copy of xschem/CTLE.sch (source-degenerated diff pair)
*
*   VDD --[R1 Lload]-- outp                outm --[R2 Lload]-- VDD
*                       |                   |
*   inp --|M1 Win/Lin   |                   |   Win/Lin M4|-- inm
*                       sp                  sm
*                       |                   |
*              [Rdeg Ldeg || Cdeg Wcap]  [Rdeg || Cdeg]
*                       |                   |
*                       +-------- st -------+
*                                 |
*                        vbias --|M2 Wtail/Ltail
*                                 |
*                                VSS
*
* Defaults below reproduce the as-drawn CTLE.sch exactly.
.param Win=10 Lin=0.3
.param Wtail=20 Ltail=0.5
.param Lload=16
.param Ldeg=0.69
.param Wcap=13
.param Mload=1 Mdeg=1 Mcap=1

.subckt ctle_p outp outm inp inm VDD VSS vbias
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
XC2 sp st sky130_fd_pr__cap_mim_m3_1 W='Wcap' L='Wcap' MF='Mcap' m='Mcap'
XC1 sm st sky130_fd_pr__cap_mim_m3_1 W='Wcap' L='Wcap' MF='Mcap' m='Mcap'
.ends
