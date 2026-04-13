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
lab=#net9}
N 1240 280 1310 280 {
lab=#net10}
N 1310 280 1320 280 {
lab=#net10}
N 1320 280 1330 280 {
lab=#net10}
N 1270 260 1350 260 {
lab=#net9}
N 1330 280 1350 280 {
lab=#net10}
N 1320 330 1350 330 {
lab=vctrl}
N 1350 300 1350 330 {
lab=vctrl}
N 1270 340 1650 340 {
lab=#net8}
N 1650 320 1650 340 {
lab=#net8}
N 1330 40 1650 40 {
lab=#net7}
N 1650 300 1700 300 {
lab=#net7}
N 1700 40 1700 300 {
lab=#net7}
N 1650 40 1700 40 {
lab=#net7}
N 1650 260 1680 260 {
lab=Vdd}
N 1680 220 1680 260 {
lab=Vdd}
N 1660 220 1680 220 {
lab=Vdd}
N 1650 280 1710 280 {
lab=Vss}
N 1650 320 1700 320 {
lab=#net8}
N 1670 390 1700 390 {
lab=Vdd}
N 1700 340 1700 390 {
lab=Vdd}
N 2000 300 2030 300 {
lab=Vdd}
N 2030 260 2030 300 {
lab=Vdd}
N 2010 260 2030 260 {
lab=Vdd}
N 2000 320 2060 320 {
lab=Vss}
N 2060 310 2060 320 {
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
C {devices/opin.sym} 2000 360 0 0 {name=p12 lab=vo+}
C {devices/opin.sym} 2000 340 0 0 {name=p16 lab=vo-}
C {devices/lab_wire.sym} 1250 180 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1300 240 0 0 {name=p6 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 940 260 0 0 {name=p8 sig_type=std_logic lab=vctrl
}
C {ring_inverter.sym} 1090 250 0 0 {name=x5}
C {ring_inverter.sym} 1500 290 0 0 {name=x4}
C {devices/lab_wire.sym} 1320 330 0 0 {name=p9 sig_type=std_logic lab=vctrl
}
C {devices/lab_wire.sym} 1660 220 0 0 {name=p10 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1710 280 0 0 {name=p11 sig_type=std_logic lab=Vss
}
C {diff_amp_inv.sym} 1850 330 0 0 {name=x6}
C {devices/lab_wire.sym} 1670 390 0 0 {name=p15 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 2010 260 0 0 {name=p17 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 2060 310 0 0 {name=p18 sig_type=std_logic lab=Vss
}
