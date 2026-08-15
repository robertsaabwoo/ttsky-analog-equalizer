v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 710 120 770 120 {
lab=Vdd}
N 770 120 770 170 {
lab=Vdd}
N 710 140 710 180 {
lab=Vss}
N 720 -140 730 -140 {
lab=#net1}
N 340 -120 420 -120 {
lab=clk-}
N 340 -100 420 -100 {
lab=clk+}
N 370 140 410 140 {
lab=clk-}
N 360 120 410 120 {
lab=clk+}
N 220 -160 220 -40 {
lab=vin+}
N 220 -160 420 -160 {
lab=vin+}
N 240 -140 420 -140 {
lab=vin-}
N 240 -140 240 -20 {
lab=vin-}
N 170 100 410 100 {
lab=vin-}
N 720 -120 780 -120 {
lab=Vdd}
N 780 -120 780 -70 {
lab=Vdd}
N 720 -100 720 -60 {
lab=Vss}
N 710 80 830 80 {
lab=vout0+}
N 710 100 800 100 {
lab=vout0-}
N 1210 -140 1220 -140 {
lab=vout1-}
N 830 -120 910 -120 {
lab=clk+}
N 830 -100 910 -100 {
lab=nclk_in}
N 710 -160 910 -160 {
lab=#net2}
N 730 -140 910 -140 {
lab=#net1}
N 1210 -120 1270 -120 {
lab=Vdd}
N 1270 -120 1270 -70 {
lab=Vdd}
N 1210 -100 1210 -60 {
lab=Vss}
N 1220 -140 1250 -140 {
lab=vout1-}
N 1210 -160 1270 -160 {
lab=vout1+}
N 340 330 420 330 {
lab=Vss}
N 420 310 420 330 {
lab=Vss}
N 220 -40 220 80 {
lab=vin+}
N 220 80 410 80 {
lab=vin+}
N 240 -20 240 100 {
lab=vin-}
N 170 80 220 80 {
lab=vin+}
N 340 310 390 310 {
lab=Vdd}
N 20 370 40 370 {
lab=vbias}
N 40 310 40 370 {
lab=vbias}
C {devices/lab_wire.sym} 340 -100 0 0 {name=p9 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 340 -120 0 0 {name=p15 sig_type=std_logic lab=clk-
}
C {d_latch.sym} 560 120 0 0 {name=x3}
C {devices/lab_wire.sym} 770 170 0 0 {name=p27 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 710 180 0 0 {name=p30 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 410 160 0 0 {name=p81 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 360 120 0 0 {name=p98 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 370 140 0 0 {name=p99 sig_type=std_logic lab=clk-
}
C {d_latch.sym} 570 -120 0 0 {name=x4}
C {devices/lab_wire.sym} 780 -70 0 0 {name=p19 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 720 -60 0 0 {name=p20 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 910 -80 0 0 {name=p41 sig_type=std_logic lab=vbias
}
C {d_latch.sym} 1060 -120 0 0 {name=x8}
C {devices/lab_wire.sym} 1270 -70 0 0 {name=p42 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1210 -60 0 0 {name=p43 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 830 -120 0 0 {name=p45 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 830 -100 0 0 {name=p46 sig_type=std_logic lab=clk-
}
C {devices/iopin.sym} -240 140 0 0 {name=p1 lab=Vdd


}
C {devices/iopin.sym} -240 170 0 0 {name=p2 lab=Vss


}
C {divide_by_two.sym} 190 300 0 0 {name=x1}
C {devices/ipin.sym} 40 270 0 0 {name=p3 lab=pclk_in
}
C {devices/lab_wire.sym} 420 310 0 0 {name=p5 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 390 310 0 0 {name=p6 sig_type=std_logic lab=Vdd
}
C {devices/opin.sym} 340 270 0 0 {name=p10 lab=clk+}
C {devices/ipin.sym} 170 80 0 0 {name=p12 lab=vin+
}
C {devices/ipin.sym} 170 100 0 0 {name=p13 lab=vin-
}
C {devices/opin.sym} 1270 -160 0 0 {name=p17 lab=vout1+}
C {devices/opin.sym} 1250 -140 0 0 {name=p14 lab=vout1-}
C {devices/opin.sym} 830 80 0 0 {name=p18 lab=vout0+}
C {devices/opin.sym} 800 100 0 0 {name=p21 lab=vout0-}
C {devices/ipin.sym} 420 -80 0 0 {name=p16 lab=vbias
}
C {devices/opin.sym} 340 290 0 0 {name=p4 lab=clk-}
C {devices/ipin.sym} 40 290 0 0 {name=p7 lab=nclk_in
}
C {devices/lab_wire.sym} 20 370 0 0 {name=p8 sig_type=std_logic lab=vbias
}
