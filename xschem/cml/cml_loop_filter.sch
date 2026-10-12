v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=VGND}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=VNB}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=VPWR}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=VPB}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=vctl}
C {devices/lab_pin.sym} 220 -30 0 0 {name=l1 sig_type=std_logic lab=VGND}
C {devices/lab_pin.sym} 180 0 0 0 {name=l2 sig_type=std_logic lab=cap_plus}
C {devices/lab_pin.sym} 220 30 0 0 {name=l3 sig_type=std_logic lab=VGND}
C {devices/lab_pin.sym} 220 0 0 0 {name=l4 sig_type=std_logic lab=VNB}
C {sky130_fd_pr/nfet_01v8.sym} 200 0 0 0 {name=MC1
L=0.6
W=4
nf=1
mult=16
ad="'int((nf+1)/2) * W/nf * 0.29'"
as="'int((nf+2)/2) * W/nf * 0.29'"
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'"
nrs="'0.29 / W'"
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 460 30 0 0 {name=l5 sig_type=std_logic lab=cap_plus}
C {devices/lab_pin.sym} 460 -30 0 0 {name=l6 sig_type=std_logic lab=vctl}
C {devices/lab_pin.sym} 440 0 0 0 {name=l7 sig_type=std_logic lab=VNB}
C {sky130_fd_pr/res_xhigh_po_0p35.sym} 460 0 0 0 {name=R
L=5.7
model=res_xhigh_po_0p35
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 740 -30 0 0 {name=l8 sig_type=std_logic lab=VGND}
C {devices/lab_pin.sym} 700 0 0 0 {name=l9 sig_type=std_logic lab=vctl}
C {devices/lab_pin.sym} 740 30 0 0 {name=l10 sig_type=std_logic lab=VGND}
C {devices/lab_pin.sym} 740 0 0 0 {name=l11 sig_type=std_logic lab=VNB}
C {sky130_fd_pr/nfet_01v8.sym} 720 0 0 0 {name=MC2
L=2
W=2.94
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'"
as="'int((nf+2)/2) * W/nf * 0.29'"
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'"
nrs="'0.29 / W'"
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
