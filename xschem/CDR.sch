v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 2030 -50 2030 390 {
lab=#net1}
N 1780 -270 1780 -250 {
lab=Vdd}
N 1780 -270 1800 -270 {
lab=Vdd}
N 1800 -270 1800 -250 {
lab=Vdd}
N 1790 -280 1790 -270 {
lab=Vdd}
N 1780 150 1780 170 {
lab=Vss}
N 1780 170 1800 170 {
lab=Vss}
N 1800 150 1800 170 {
lab=Vss}
N 1660 -180 1660 -150 {
lab=bias_p}
N 1660 -150 1740 -150 {
lab=bias_p}
N 1690 80 1740 80 {
lab=bias_n}
N 1740 50 1740 80 {
lab=bias_n}
N 1920 -50 2030 -50 {
lab=#net1}
N 1300 -630 1300 -610 {
lab=Vdd}
N 1300 -630 1320 -630 {
lab=Vdd}
N 1320 -630 1320 -610 {
lab=Vdd}
N 1310 -640 1310 -630 {
lab=Vdd}
N 1300 -330 1300 -310 {
lab=Vss}
N 1300 -310 1320 -310 {
lab=Vss}
N 1320 -330 1320 -310 {
lab=Vss}
N 1560 -60 1740 -60 {
lab=#net2}
N 1740 -90 1740 -60 {
lab=#net2}
N 1560 -80 1680 -80 {
lab=#net3}
N 1680 -80 1680 -10 {
lab=#net3}
N 1680 -10 1740 -10 {
lab=#net3}
N 1560 -120 1600 -120 {
lab=Vdd}
N 1600 -140 1600 -120 {
lab=Vdd}
N 1560 -100 1640 -100 {
lab=Vss}
N 1640 -110 1640 -100 {
lab=Vss}
N 1220 -40 1260 -40 {
lab=#net4}
N 1220 -40 1220 10 {
lab=#net4}
N 1220 10 1260 10 {
lab=#net4}
N 2200 -80 2210 -80 {
lab=Vdd}
N 2200 -80 2200 -60 {
lab=Vdd}
N 2200 -60 2210 -60 {
lab=Vdd}
N 2160 -70 2200 -70 {
lab=Vdd}
N 2200 -40 2210 -40 {
lab=Vss}
N 2200 -40 2200 -20 {
lab=Vss}
N 2200 -20 2210 -20 {
lab=Vss}
N 2160 -30 2200 -30 {
lab=Vss}
N 2310 -220 2310 -160 {
lab=#net1}
N 1980 -220 2310 -220 {
lab=#net1}
N 1980 -220 1980 -50 {
lab=#net1}
N 2490 440 2530 440 {
lab=Vdd}
N 2530 420 2530 440 {
lab=Vdd}
N 2490 460 2570 460 {
lab=Vss}
N 2570 450 2570 460 {
lab=Vss}
N 2030 390 2030 440 {
lab=#net1}
N 2030 440 2190 440 {
lab=#net1}
N 960 250 980 250 {
lab=vbias}
N 980 310 980 360 {
lab=Vss}
N 980 200 980 250 {
lab=vbias}
N 980 150 980 200 {
lab=vbias}
N 930 150 980 150 {
lab=vbias}
N 930 110 930 150 {
lab=vbias}
N 890 250 900 250 {
lab=#net5}
N 890 250 890 270 {
lab=#net5}
C {tiny_pll_charge_pump.sym} 1840 -50 0 0 {name=x6}
C {devices/lab_wire.sym} 1790 -280 0 0 {name=p14 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1780 170 0 0 {name=p35 sig_type=std_logic lab=Vss
}
C {tiny_pll_bias_gen.sym} 1220 -450 0 0 {name=x8}
C {devices/lab_wire.sym} 1310 -640 0 0 {name=p43 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1300 -310 0 0 {name=p44 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1100 -450 0 0 {name=p45 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1100 -430 0 0 {name=p46 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1360 -470 0 1 {name=p47 sig_type=std_logic lab=bias_p
}
C {devices/lab_wire.sym} 1360 -410 0 1 {name=p48 sig_type=std_logic lab=bias_n
}
C {devices/lab_wire.sym} 1660 -180 0 1 {name=p49 sig_type=std_logic lab=bias_p
}
C {devices/lab_wire.sym} 1690 80 0 0 {name=p37 sig_type=std_logic lab=bias_n
}
C {devices/opin.sym} 2490 500 0 0 {name=p17 lab=rclk-}
C {devices/iopin.sym} 900 -150 2 1 {name=p38 lab=Vdd


}
C {devices/iopin.sym} 900 -110 0 0 {name=p40 lab=Vss


}
C {devices/ipin.sym} 1260 -100 0 0 {name=p7 lab=vin+
}
C {tiny_pll_loop_filter.sym} 2310 -40 0 0 {name=x2}
C {alexander_phase_detector.sym} 1410 -80 0 0 {name=x3}
C {devices/lab_wire.sym} 1600 -140 0 0 {name=p1 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1640 -110 0 0 {name=p5 sig_type=std_logic lab=Vss
}
C {devices/ipin.sym} 1260 -60 0 0 {name=p9 lab=vin-
}
C {devices/lab_wire.sym} 2160 -70 0 0 {name=p11 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 2160 -30 0 0 {name=p12 sig_type=std_logic lab=Vss
}
C {devices/opin.sym} 2490 480 0 0 {name=p13 lab=rclk+}
C {devices/lab_wire.sym} 1260 -120 0 0 {name=p15 sig_type=std_logic lab=rclk+
}
C {devices/lab_wire.sym} 1260 -80 0 0 {name=p16 sig_type=std_logic lab=rclk-
}
C {devices/lab_wire.sym} 2530 420 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 2570 450 0 0 {name=p39 sig_type=std_logic lab=Vss
}
C {ring_oscillator.sym} 2340 470 0 0 {name=x1}
C {devices/vsource.sym} 890 300 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} 890 330 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} 930 110 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} 930 250 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} 980 280 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} 980 360 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1260 10 0 1 {name=p2 sig_type=std_logic lab=vbias
}
