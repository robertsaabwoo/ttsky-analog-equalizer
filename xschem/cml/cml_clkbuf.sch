v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=VDD}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=VSS}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=vo-}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=vo+}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=vin-}
C {devices/iopin.sym} -400 200 0 0 {name=p6 lab=vin+}
C {devices/iopin.sym} -400 240 0 0 {name=p7 lab=vbn}
C {devices/lab_pin.sym} 220 -30 0 0 {name=l1 sig_type=std_logic lab=vo-_temp}
C {devices/lab_pin.sym} 180 0 0 0 {name=l2 sig_type=std_logic lab=vin-}
C {devices/lab_pin.sym} 220 30 0 0 {name=l3 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 220 0 0 0 {name=l4 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 200 0 0 0 {name=M2
L=0.15
W=3
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 480 -30 0 0 {name=l5 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 440 0 0 0 {name=l6 sig_type=std_logic lab=vbn}
C {devices/lab_pin.sym} 480 30 0 0 {name=l7 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 480 0 0 0 {name=l8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 460 0 0 0 {name=M3
L=0.5
W=0.96
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 740 -30 0 0 {name=l9 sig_type=std_logic lab=vo+_temp}
C {devices/lab_pin.sym} 700 0 0 0 {name=l10 sig_type=std_logic lab=vin+}
C {devices/lab_pin.sym} 740 30 0 0 {name=l11 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 740 0 0 0 {name=l12 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 720 0 0 0 {name=M6
L=0.15
W=3
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 980 30 0 0 {name=l13 sig_type=std_logic lab=vo+_temp}
C {devices/lab_pin.sym} 980 -30 0 0 {name=l14 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 960 0 0 0 {name=l15 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 980 0 0 0 {name=R3
L=10
W=0.5
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 1240 30 0 0 {name=l16 sig_type=std_logic lab=vo-_temp}
C {devices/lab_pin.sym} 1240 -30 0 0 {name=l17 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1220 0 0 0 {name=l18 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 1240 0 0 0 {name=R4
L=10
W=0.5
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 1520 -30 0 0 {name=l19 sig_type=std_logic lab=vo-}
C {devices/lab_pin.sym} 1480 0 0 0 {name=l20 sig_type=std_logic lab=vo-_temp}
C {devices/lab_pin.sym} 1520 30 0 0 {name=l21 sig_type=std_logic lab=net2}
C {devices/lab_pin.sym} 1520 0 0 0 {name=l22 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 1500 0 0 0 {name=M1
L=0.5
W=6
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 220 170 0 0 {name=l23 sig_type=std_logic lab=net2}
C {devices/lab_pin.sym} 180 200 0 0 {name=l24 sig_type=std_logic lab=vbn}
C {devices/lab_pin.sym} 220 230 0 0 {name=l25 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 220 200 0 0 {name=l26 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 200 200 0 0 {name=M4
L=0.5
W=8.9
nf=2
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 480 170 0 0 {name=l27 sig_type=std_logic lab=vo+}
C {devices/lab_pin.sym} 440 200 0 0 {name=l28 sig_type=std_logic lab=vo+_temp}
C {devices/lab_pin.sym} 480 230 0 0 {name=l29 sig_type=std_logic lab=net2}
C {devices/lab_pin.sym} 480 200 0 0 {name=l30 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 460 200 0 0 {name=M5
L=0.5
W=6
nf=1
mult=1
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 720 230 0 0 {name=l31 sig_type=std_logic lab=vo+}
C {devices/lab_pin.sym} 720 170 0 0 {name=l32 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 700 200 0 0 {name=l33 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 720 200 0 0 {name=R1
L=17.5
W=1
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_pin.sym} 980 230 0 0 {name=l34 sig_type=std_logic lab=vo-}
C {devices/lab_pin.sym} 980 170 0 0 {name=l35 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 960 200 0 0 {name=l36 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 980 200 0 0 {name=R2
L=17.5
W=1
model=res_high_po
spiceprefix=X
mult=1}
