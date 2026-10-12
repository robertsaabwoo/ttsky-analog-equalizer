v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=A}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=B}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=X}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=VDD}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=VSS}
C {devices/lab_pin.sym} 140 -20 0 0 {name=l1 sig_type=std_logic lab=A}
C {devices/lab_pin.sym} 140 20 0 0 {name=l2 sig_type=std_logic lab=B}
C {devices/lab_pin.sym} 260 0 0 0 {name=l3 sig_type=std_logic lab=X}
C {sky130_stdcells/xor2_1.sym} 200 0 0 0 {name=x0
VGND=VSS
VNB=VSS
VPB=VDD
VPWR=VDD
prefix=sky130_fd_sc_hd__}
