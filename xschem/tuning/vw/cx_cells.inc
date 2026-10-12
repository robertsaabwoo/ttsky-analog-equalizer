* cx_cells.inc -- CML phase detector with STATIC CMOS XORs (sandbox, 2026-10-11)
* Same 8 CML latches as cml_pd (cells from ../cml/.netlists/cml_cells.inc), but
* the latch outputs Q5, Q2 and B are converted to CMOS and XORed in static CMOS,
* so the charge pump is switched by full-rail static-CMOS edges, as in the
* frozen alexander_phase_detector. x3 is a plain cml_dff: the level-shifted
* slave existed only for the CML XOR's input common mode.
*   down = Q5 xor B,  up = Q2 xor B   (same logic as the frozen PD)

* cx6: the frozen robs_xor, which needs true + complement inputs -> 6 converters
.subckt cml_pd_cx6 VDD VSS down up ck ckb d db vbias
x5 q5 q5b d db VDD VSS ck ckb vbias cml_dff
x1 q1 q1b d db VDD VSS ckb ck vbias cml_dff
x2 q2 q2b q5 q5b VDD VSS ck ckb vbias cml_dff
x3 b bb q1 q1b VDD VSS ck ckb vbias cml_dff
xc5p a5 q5 q5b VDD VSS vbias cml2cmos
xc5m a5b q5b q5 VDD VSS vbias cml2cmos
xc2p a2 q2 q2b VDD VSS vbias cml2cmos
xc2m a2b q2b q2 VDD VSS vbias cml2cmos
xcbp bp b bb VDD VSS vbias cml2cmos
xcbm bm bb b VDD VSS vbias cml2cmos
x6 a5 VDD bm VSS down a5b bp robs_xor
x7 a2 VDD bm VSS up a2b bp robs_xor
.ends

* cx3: standard-cell xor2_1, true inputs only -> 3 converters
.subckt cml_pd_cx3 VDD VSS down up ck ckb d db vbias
x5 q5 q5b d db VDD VSS ck ckb vbias cml_dff
x1 q1 q1b d db VDD VSS ckb ck vbias cml_dff
x2 q2 q2b q5 q5b VDD VSS ck ckb vbias cml_dff
x3 b bb q1 q1b VDD VSS ck ckb vbias cml_dff
xc5 a5 q5 q5b VDD VSS vbias cml2cmos
xc2 a2 q2 q2b VDD VSS vbias cml2cmos
xcb bp b bb VDD VSS vbias cml2cmos
x6 a5 bp down VDD VSS cx_xor
x7 a2 bp up VDD VSS cx_xor
.ends

* one standard-cell XOR as a leaf cell, so the chain flattener meters it
.subckt cx_xor A B X VDD VSS
x0 A B VSS VSS VDD VDD X sky130_fd_sc_hd__xor2_1
.ends

* cx3w: cx3 with the three PD converters at 2x tail current (W=2): at sf/125C on
* cml_bias the 18 uA converters skew Q5/Q2/B and the static XORs glitch (U9_cx)
.subckt cml2cmos_w2 out inp inm VDD VSS vbias
XM1 x inp t VSS sky130_fd_pr__nfet_01v8 L=0.15 W=2 nf=1 ad={2*0.29} as={2*0.29} pd={2*(2+0.29)} ps={2*(2+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XM2 y inm t VSS sky130_fd_pr__nfet_01v8 L=0.15 W=2 nf=1 ad={2*0.29} as={2*0.29} pd={2*(2+0.29)} ps={2*(2+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XP1 x x VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 ad={1*0.29} as={1*0.29} pd={2*(1+0.29)} ps={2*(1+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XP2 y x VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 ad={1*0.29} as={1*0.29} pd={2*(1+0.29)} ps={2*(1+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XMt t vbias VSS VSS sky130_fd_pr__nfet_01v8 L=0.5 W=2 nf=1 ad={2*0.29} as={2*0.29} pd={2*(2+0.29)} ps={2*(2+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XPi1 z y VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 ad={1*0.29} as={1*0.29} pd={2*(1+0.29)} ps={2*(1+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XNi1 z y VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1 ad={0.5*0.29} as={0.5*0.29} pd={2*(0.5+0.29)} ps={2*(0.5+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XPi2 out z VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 ad={2*0.29} as={2*0.29} pd={2*(2+0.29)} ps={2*(2+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0
XNi2 out z VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1 ad={1*0.29} as={1*0.29} pd={2*(1+0.29)} ps={2*(1+0.29)} nrd=0 nrs=0 sa=0 sb=0 sd=0.ends
.subckt cml_pd_cx3w VDD VSS down up ck ckb d db vbias
x5 q5 q5b d db VDD VSS ck ckb vbias cml_dff
x1 q1 q1b d db VDD VSS ckb ck vbias cml_dff
x2 q2 q2b q5 q5b VDD VSS ck ckb vbias cml_dff
x3 b bb q1 q1b VDD VSS ck ckb vbias cml_dff
xc5 a5 q5 q5b VDD VSS vbias cml2cmos_w2
xc2 a2 q2 q2b VDD VSS vbias cml2cmos_w2
xcb bp b bb VDD VSS vbias cml2cmos_w2
x6 a5 bp down VDD VSS cx_xor
x7 a2 bp up VDD VSS cx_xor
.ends
