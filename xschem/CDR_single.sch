v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 110 460 150 460 {
lab=Vss}
N 150 440 150 460 {
lab=Vss}
N 60 360 150 360 {
lab=#net1}
N 150 360 150 400 {
lab=#net1}
N 210 290 210 300 {
lab=Vdd}
N 210 290 240 290 {
lab=Vdd}
N 240 270 240 290 {
lab=Vdd}
N 190 520 190 540 {
lab=Vss}
N 190 540 210 540 {
lab=Vss}
N 210 520 210 540 {
lab=Vss}
N 60 -80 60 360 {
lab=#net1}
N -190 -300 -190 -280 {
lab=Vdd}
N -190 -300 -170 -300 {
lab=Vdd}
N -170 -300 -170 -280 {
lab=Vdd}
N -180 -310 -180 -300 {
lab=Vdd}
N -190 120 -190 140 {
lab=Vss}
N -190 140 -170 140 {
lab=Vss}
N -170 120 -170 140 {
lab=Vss}
N -310 -210 -310 -180 {
lab=bias_p}
N -310 -180 -230 -180 {
lab=bias_p}
N -280 50 -230 50 {
lab=bias_n}
N -230 20 -230 50 {
lab=bias_n}
N 310 380 340 380 {
lab=#net2}
N -50 -80 60 -80 {
lab=#net1}
N -670 -660 -670 -640 {
lab=Vdd}
N -670 -660 -650 -660 {
lab=Vdd}
N -650 -660 -650 -640 {
lab=Vdd}
N -660 -670 -660 -660 {
lab=Vdd}
N -670 -360 -670 -340 {
lab=Vss}
N -670 -340 -650 -340 {
lab=Vss}
N -650 -360 -650 -340 {
lab=Vss}
N -410 -90 -230 -90 {
lab=#net3}
N -230 -120 -230 -90 {
lab=#net3}
N -410 -110 -290 -110 {
lab=#net4}
N -290 -110 -290 -40 {
lab=#net4}
N -290 -40 -230 -40 {
lab=#net4}
N -410 -150 -370 -150 {
lab=Vdd}
N -370 -170 -370 -150 {
lab=Vdd}
N -410 -130 -330 -130 {
lab=Vss}
N -330 -140 -330 -130 {
lab=Vss}
N 230 -110 240 -110 {
lab=Vdd}
N 230 -110 230 -90 {
lab=Vdd}
N 230 -90 240 -90 {
lab=Vdd}
N 190 -100 230 -100 {
lab=Vdd}
N 230 -70 240 -70 {
lab=Vss}
N 230 -70 230 -50 {
lab=Vss}
N 230 -50 240 -50 {
lab=Vss}
N 190 -60 230 -60 {
lab=Vss}
N 340 -250 340 -190 {
lab=#net1}
N 10 -250 340 -250 {
lab=#net1}
N 10 -250 10 -80 {
lab=#net1}
N 340 380 430 380 {
lab=#net2}
C {tiny_pll_vco.sym} 230 400 0 0 {name=x1}
C {devices/lab_wire.sym} 110 460 0 0 {name=p2 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 150 420 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 190 300 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 240 270 0 0 {name=p6 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 190 540 0 0 {name=p8 sig_type=std_logic lab=Vss
}
C {tiny_pll_charge_pump.sym} -130 -80 0 0 {name=x6}
C {devices/lab_wire.sym} -180 -310 0 0 {name=p14 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -190 140 0 0 {name=p35 sig_type=std_logic lab=Vss
}
C {tiny_pll_bias_gen.sym} -750 -480 0 0 {name=x8}
C {devices/lab_wire.sym} -660 -670 0 0 {name=p43 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -670 -340 0 0 {name=p44 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -870 -480 0 0 {name=p45 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -870 -460 0 0 {name=p46 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -610 -500 0 1 {name=p47 sig_type=std_logic lab=bias_p
}
C {devices/lab_wire.sym} -610 -440 0 1 {name=p48 sig_type=std_logic lab=bias_n
}
C {devices/lab_wire.sym} -310 -210 0 1 {name=p49 sig_type=std_logic lab=bias_p
}
C {devices/lab_wire.sym} -280 50 0 0 {name=p37 sig_type=std_logic lab=bias_n
}
C {devices/iopin.sym} -1070 -180 2 1 {name=p38 lab=Vdd


}
C {devices/iopin.sym} -1070 -140 0 0 {name=p40 lab=Vss


}
C {devices/ipin.sym} -710 -130 0 0 {name=p7 lab=vin+
}
C {tiny_pll_loop_filter.sym} 340 -70 0 0 {name=x2}
C {alexander_phase_detector.sym} -560 -110 0 0 {name=x3}
C {devices/lab_wire.sym} -370 -170 0 0 {name=p1 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -330 -140 0 0 {name=p5 sig_type=std_logic lab=Vss
}
C {devices/ipin.sym} -710 -90 0 0 {name=p9 lab=vin-
}
C {devices/lab_wire.sym} 190 -100 0 0 {name=p11 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 190 -60 0 0 {name=p12 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -710 -150 0 0 {name=p15 sig_type=std_logic lab=rclk+
}
C {devices/lab_wire.sym} -710 -110 0 0 {name=p16 sig_type=std_logic lab=rclk-
}
C {devices/opin.sym} 430 380 0 0 {name=p32 lab=rclk+}
C {devices/ipin.sym} -710 -70 0 0 {name=p18 lab=vbias
}
