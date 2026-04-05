v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -70 100 -40 100 {
lab=Vdd}
N -40 60 -40 100 {
lab=Vdd}
N -60 60 -40 60 {
lab=Vdd}
N -70 120 -10 120 {
lab=Vss}
N 380 140 410 140 {
lab=Vdd}
N 410 100 410 140 {
lab=Vdd}
N 390 100 410 100 {
lab=Vdd}
N 380 160 440 160 {
lab=Vss}
N 810 180 840 180 {
lab=Vdd}
N 840 140 840 180 {
lab=Vdd}
N 820 140 840 140 {
lab=Vdd}
N 810 200 870 200 {
lab=Vss}
N -70 140 80 140 {
lab=#net1}
N -70 160 80 160 {
lab=#net2}
N 380 200 510 200 {
lab=#net3}
N 380 180 510 180 {
lab=#net4}
N 810 220 940 220 {
lab=#net5}
N 810 240 940 240 {
lab=#net6}
N -350 40 890 40 {
lab=#net7}
N -380 40 -350 40 {
lab=#net7}
N -480 240 10 240 {
lab=#net8}
N 10 240 20 240 {
lab=#net8}
N 20 240 20 310 {
lab=#net8}
N 20 340 1270 340 {
lab=#net8}
N 20 310 20 340 {
lab=#net8}
N 890 40 1330 40 {
lab=#net7}
N -480 120 -370 120 {
lab=#net8}
N -480 120 -480 240 {
lab=#net8}
N -380 100 -370 100 {
lab=#net7}
N -380 40 -380 100 {
lab=#net7}
N 1240 220 1270 220 {
lab=Vdd}
N 1270 180 1270 220 {
lab=Vdd}
N 1250 180 1270 180 {
lab=Vdd}
N 1240 240 1300 240 {
lab=Vss}
N 1240 260 1270 260 {
lab=#net8}
N 1270 260 1270 340 {
lab=#net8}
N 1240 280 1310 280 {
lab=#net7}
N 1310 280 1320 280 {
lab=#net7}
N 1330 40 1330 280 {
lab=#net7}
N 1320 280 1330 280 {
lab=#net7}
N 1270 260 1380 260 {
lab=#net8}
N 1380 260 1380 300 {
lab=#net8}
N 1380 300 1390 300 {
lab=#net8}
N 1300 320 1390 320 {
lab=#net7}
N 1300 280 1300 320 {
lab=#net7}
N 1690 300 1720 300 {
lab=Vdd}
N 1720 260 1720 300 {
lab=Vdd}
N 1700 260 1720 260 {
lab=Vdd}
N 1690 320 1750 320 {
lab=Vss}
C {ring_inverter.sym} -220 130 0 0 {name=x1}
C {devices/lab_wire.sym} -60 60 0 0 {name=p2 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -10 120 0 0 {name=p3 sig_type=std_logic lab=Vss
}
C {ring_inverter.sym} 230 170 0 0 {name=x2}
C {devices/lab_wire.sym} 390 100 0 0 {name=p13 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 440 160 0 0 {name=p14 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 80 180 0 0 {name=p19 sig_type=std_logic lab=vctrl
}
C {ring_inverter.sym} 660 210 0 0 {name=x3}
C {devices/lab_wire.sym} 820 140 0 0 {name=p20 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 870 200 0 0 {name=p21 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 510 220 0 0 {name=p26 sig_type=std_logic lab=vctrl
}
C {devices/iopin.sym} 70 -110 0 0 {name=p1 lab=Vdd


}
C {devices/iopin.sym} 70 -80 0 0 {name=p5 lab=Vss


}
C {devices/ipin.sym} -370 140 0 0 {name=p7 lab=vctrl

}
C {devices/opin.sym} 1690 360 0 0 {name=p12 lab=vo+}
C {devices/opin.sym} 1690 340 0 0 {name=p16 lab=vo-}
C {devices/lab_wire.sym} 1250 180 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1300 240 0 0 {name=p6 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 940 260 0 0 {name=p8 sig_type=std_logic lab=vctrl
}
C {ring_inverter.sym} 1090 250 0 0 {name=x5}
C {diff_amp_inv.sym} 1540 330 0 0 {name=x4}
C {devices/lab_wire.sym} 1700 260 0 0 {name=p9 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1750 320 0 0 {name=p10 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1390 340 0 0 {name=p11 sig_type=std_logic lab=Vdd
}
