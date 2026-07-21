v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 260 -140 340 -140 {
lab=vin+}
N 340 -170 340 -140 {
lab=vin+}
N 340 -170 410 -170 {
lab=vin+}
N 340 -140 340 10 {
lab=vin+}
N 340 10 340 20 {
lab=vin+}
N 340 20 410 20 {
lab=vin+}
N 280 -110 280 40 {
lab=vin-}
N 260 -110 280 -110 {
lab=vin-}
N 280 -110 370 -110 {
lab=vin-}
N 770 -280 770 -130 {
lab=#net1}
N 770 -280 820 -280 {
lab=#net1}
N 790 -240 820 -240 {
lab=#net2}
N 790 -240 790 -110 {
lab=#net2}
N 370 -110 410 -110 {
lab=vin-}
N 280 80 410 80 {
lab=vin-}
N 280 40 280 80 {
lab=vin-}
N 710 60 780 60 {
lab=#net3}
N 780 20 780 60 {
lab=#net3}
N 780 20 820 20 {
lab=#net3}
N 710 80 820 80 {
lab=#net4}
N 780 -110 850 -110 {
lab=#net2}
N 1150 -130 1210 -130 {
lab=#net5}
N 1210 -190 1210 -130 {
lab=#net5}
N 1210 -190 1270 -190 {
lab=#net5}
N 1230 -150 1270 -150 {
lab=#net6}
N 1230 -150 1230 -110 {
lab=#net6}
N 1150 -110 1230 -110 {
lab=#net6}
N 710 -110 780 -110 {
lab=#net2}
N 710 -130 780 -130 {
lab=#net1}
N 780 -170 780 -130 {
lab=#net1}
N 780 -170 850 -170 {
lab=#net1}
C {devices/lab_wire.sym} 410 60 0 0 {name=p12 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 410 40 0 0 {name=p13 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 410 100 0 0 {name=p19 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 710 -170 0 1 {name=p5 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 710 -150 0 1 {name=p4 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 710 20 0 1 {name=p6 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 710 40 0 1 {name=p8 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1120 20 0 1 {name=p9 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 1120 40 0 1 {name=p10 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1150 -170 0 1 {name=p11 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 850 -150 0 0 {name=p15 sig_type=std_logic lab=clk+}
C {devices/lab_wire.sym} 850 -130 0 0 {name=p16 sig_type=std_logic lab=clk-}
C {devices/lab_wire.sym} 850 -90 0 0 {name=p17 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 820 40 0 0 {name=p18 sig_type=std_logic lab=clk+}
C {devices/lab_wire.sym} 820 60 0 0 {name=p20 sig_type=std_logic lab=clk-}
C {devices/lab_wire.sym} 820 100 0 0 {name=p22 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 1120 60 0 1 {name=p26 sig_type=std_logic lab=B+}
C {devices/lab_wire.sym} 1120 80 0 1 {name=p27 sig_type=std_logic lab=B-}
C {devices/opin.sym} 1120 -240 0 0 {name=p23 lab=down}
C {devices/lab_wire.sym} 820 -260 0 0 {name=p25 sig_type=std_logic lab=B-}
C {devices/lab_wire.sym} 820 -220 0 0 {name=p28 sig_type=std_logic lab=B+}
C {robs_xor_tune.sym} 970 -250 0 0 {name=x6}
C {devices/opin.sym} 1570 -150 0 0 {name=p29 lab=up}
C {devices/lab_wire.sym} 1270 -170 0 0 {name=p30 sig_type=std_logic lab=B-}
C {devices/lab_wire.sym} 1270 -130 0 0 {name=p31 sig_type=std_logic lab=B+}
C {robs_xor_tune.sym} 1420 -160 0 0 {name=x7}
C {devices/lab_wire.sym} 1570 -170 0 1 {name=p24 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1570 -190 0 1 {name=p32 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 1120 -260 0 1 {name=p33 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1120 -280 0 1 {name=p34 sig_type=std_logic lab=VDD}
C {devices/ipin.sym} 260 -140 0 0 {name=p7 lab=vin+
}
C {devices/ipin.sym} 260 -110 0 0 {name=p1 lab=vin-
}
C {devices/ipin.sym} 410 -150 0 0 {name=p2 lab=clk+
}
C {devices/ipin.sym} 410 -130 0 0 {name=p3 lab=clk-
}
C {devices/ipin.sym} 410 -90 0 0 {name=p21 lab=vbias
}
C {devices/iopin.sym} 120 -470 2 1 {name=p38 lab=VDD


}
C {devices/iopin.sym} 120 -430 0 0 {name=p40 lab=VSS


}
C {d_flip_flop_tune.sym} 560 -130 0 0 {name=x5}
C {d_flip_flop_tune.sym} 560 60 0 0 {name=x1}
C {d_flip_flop_tune.sym} 1000 -130 0 0 {name=x2}
C {d_flip_flop_tune.sym} 970 60 0 0 {name=x3}
C {devices/lab_wire.sym} 1150 -150 0 1 {name=p14 sig_type=std_logic lab=VSS}
