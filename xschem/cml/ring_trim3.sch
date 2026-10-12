v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=nd}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=VDD}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=VSS}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=b0n}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=b1n}
C {devices/iopin.sym} -400 200 0 0 {name=p6 lab=b2n}
C {devices/lab_pin.sym} 200 30 0 0 {name=l1 sig_type=std_logic lab=nd}
C {devices/lab_pin.sym} 200 -30 0 0 {name=l2 sig_type=std_logic lab=a0}
C {devices/lab_pin.sym} 180 0 0 0 {name=l3 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_xhigh_po_0p35.sym} 200 0 0 0 {name=R0
L=21
model=res_xhigh_po_0p35
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 480 30 0 0 {name=l4 sig_type=std_logic lab=a0}
C {devices/lab_pin.sym} 440 0 0 0 {name=l5 sig_type=std_logic lab=b0n}
C {devices/lab_pin.sym} 480 -30 0 0 {name=l6 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 480 0 0 0 {name=l7 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 460 0 0 0 {name=P0
L=0.15
W=1
nf=1
mult=1
model=pfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 720 30 0 0 {name=l8 sig_type=std_logic lab=nd}
C {devices/lab_pin.sym} 720 -30 0 0 {name=l9 sig_type=std_logic lab=a1}
C {devices/lab_pin.sym} 700 0 0 0 {name=l10 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_xhigh_po_0p35.sym} 720 0 0 0 {name=R1
L=10.5
model=res_xhigh_po_0p35
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 1000 30 0 0 {name=l11 sig_type=std_logic lab=a1}
C {devices/lab_pin.sym} 960 0 0 0 {name=l12 sig_type=std_logic lab=b1n}
C {devices/lab_pin.sym} 1000 -30 0 0 {name=l13 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1000 0 0 0 {name=l14 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 980 0 0 0 {name=P1
L=0.15
W=1
nf=1
mult=1
model=pfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 1240 30 0 0 {name=l15 sig_type=std_logic lab=nd}
C {devices/lab_pin.sym} 1240 -30 0 0 {name=l16 sig_type=std_logic lab=a2}
C {devices/lab_pin.sym} 1220 0 0 0 {name=l17 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_xhigh_po_0p35.sym} 1240 0 0 0 {name=R2
L=4.0
model=res_xhigh_po_0p35
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 1520 30 0 0 {name=l18 sig_type=std_logic lab=a2}
C {devices/lab_pin.sym} 1480 0 0 0 {name=l19 sig_type=std_logic lab=b2n}
C {devices/lab_pin.sym} 1520 -30 0 0 {name=l20 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1520 0 0 0 {name=l21 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 1500 0 0 0 {name=P2
L=0.15
W=2
nf=1
mult=1
model=pfet_01v8
spiceprefix=X}
