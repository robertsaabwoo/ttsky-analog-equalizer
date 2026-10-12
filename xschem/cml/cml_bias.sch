v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=VDD}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=VSS}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=vbn}
C {devices/lab_pin.sym} 200 30 0 0 {name=l1 sig_type=std_logic lab=vbn}
C {devices/lab_pin.sym} 200 -30 0 0 {name=l2 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 180 0 0 0 {name=l3 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po_0p69.sym} 200 0 0 0 {name=Rr
L=112
model=res_high_po_0p69
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 480 -30 0 0 {name=l4 sig_type=std_logic lab=vbn}
C {devices/lab_pin.sym} 440 0 0 0 {name=l5 sig_type=std_logic lab=vbn}
C {devices/lab_pin.sym} 480 30 0 0 {name=l6 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 480 0 0 0 {name=l7 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 460 0 0 0 {name=D
L=0.5
W=0.75
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 740 -30 0 0 {name=l8 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 700 0 0 0 {name=l9 sig_type=std_logic lab=vbn}
C {devices/lab_pin.sym} 740 30 0 0 {name=l10 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 740 0 0 0 {name=l11 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 720 0 0 0 {name=Cd
L=5
W=5
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
