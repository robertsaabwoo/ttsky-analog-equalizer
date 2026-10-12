v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=VDD}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=VSS}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=vin+}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=vo+}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=vin-}
C {devices/iopin.sym} -400 200 0 0 {name=p6 lab=vo-}
C {devices/iopin.sym} -400 240 0 0 {name=p7 lab=vctrl}
C {devices/lab_pin.sym} 220 -30 0 0 {name=l1 sig_type=std_logic lab=vo-}
C {devices/lab_pin.sym} 180 0 0 0 {name=l2 sig_type=std_logic lab=vin-}
C {devices/lab_pin.sym} 220 30 0 0 {name=l3 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 220 0 0 0 {name=l4 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 200 0 0 0 {name=M4
L=1
W=3
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
C {devices/lab_pin.sym} 480 -30 0 0 {name=l5 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 440 0 0 0 {name=l6 sig_type=std_logic lab=vctrl}
C {devices/lab_pin.sym} 480 30 0 0 {name=l7 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 480 0 0 0 {name=l8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 460 0 0 0 {name=M5
L=0.15
W=9
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
C {devices/lab_pin.sym} 740 -30 0 0 {name=l9 sig_type=std_logic lab=vo+}
C {devices/lab_pin.sym} 700 0 0 0 {name=l10 sig_type=std_logic lab=vin+}
C {devices/lab_pin.sym} 740 30 0 0 {name=l11 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 740 0 0 0 {name=l12 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 720 0 0 0 {name=M1
L=1
W=3
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
C {devices/lab_pin.sym} 980 30 0 0 {name=l13 sig_type=std_logic lab=vo+}
C {devices/lab_pin.sym} 980 -30 0 0 {name=l14 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 960 0 0 0 {name=l15 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 980 0 0 0 {name=R1
L=20
W=1
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 1240 30 0 0 {name=l16 sig_type=std_logic lab=vo-}
C {devices/lab_pin.sym} 1240 -30 0 0 {name=l17 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1220 0 0 0 {name=l18 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 1240 0 0 0 {name=R2
L=20
W=1
model=res_high_po
spiceprefix=X
mult=1}
