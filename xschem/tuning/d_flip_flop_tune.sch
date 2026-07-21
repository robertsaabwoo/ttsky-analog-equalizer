v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -550 160 -470 160 {
lab=vin+}
N -470 130 -470 160 {
lab=vin+}
N -470 130 -400 130 {
lab=vin+}
N -550 190 -530 190 {
lab=vin-}
N -530 190 -440 190 {
lab=vin-}
N -440 150 -440 190 {
lab=vin-}
N -440 150 -400 150 {
lab=vin-}
N -100 130 -0 130 {
lab=#net1}
N -100 150 -0 150 {
lab=#net2}
C {d_latch_tune.sym} -250 170 0 0 {name=x1}
C {devices/lab_wire.sym} -100 170 0 1 {name=p5 sig_type=std_logic lab=Vdd}
C {devices/lab_wire.sym} -100 190 0 1 {name=p4 sig_type=std_logic lab=Vss}
C {devices/opin.sym} 300 150 0 0 {name=p23 lab=Qn}
C {devices/opin.sym} 300 130 0 0 {name=p29 lab=Q}
C {devices/ipin.sym} -550 160 0 0 {name=p7 lab=vin+
}
C {devices/ipin.sym} -550 190 0 0 {name=p1 lab=vin-
}
C {devices/ipin.sym} -400 190 0 0 {name=p2 lab=clk+
}
C {devices/ipin.sym} -400 170 0 0 {name=p3 lab=clk-
}
C {devices/ipin.sym} -400 210 0 0 {name=p21 lab=vbias
}
C {devices/iopin.sym} -690 -170 2 1 {name=p38 lab=Vdd


}
C {devices/iopin.sym} -690 -130 0 0 {name=p40 lab=Vss


}
C {d_latch_tune.sym} 150 170 0 0 {name=x2}
C {devices/lab_wire.sym} 300 170 0 1 {name=p6 sig_type=std_logic lab=Vdd}
C {devices/lab_wire.sym} 300 190 0 1 {name=p8 sig_type=std_logic lab=Vss}
C {devices/lab_wire.sym} 0 190 0 0 {name=p9 sig_type=std_logic lab=clk-}
C {devices/lab_wire.sym} 0 170 0 0 {name=p10 sig_type=std_logic lab=clk+}
C {devices/lab_wire.sym} 0 210 0 0 {name=p11 sig_type=std_logic lab=vbias}
