v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -60 80 -60 100 {
lab=vin+}
N 190 130 190 150 {
lab=vin-}
N -340 160 -320 160 {
lab=vbias}
N -320 220 -320 270 {
lab=Vss}
N -320 110 -320 160 {
lab=vbias}
N -320 60 -320 110 {
lab=vbias}
N -370 60 -320 60 {
lab=vbias}
N -370 20 -370 60 {
lab=vbias}
N -410 160 -400 160 {
lab=#net1}
N -410 160 -410 180 {
lab=#net1}
N 20 280 20 300 {
lab=clk_gen}
N 830 50 910 50 {
lab=vin+}
N 910 20 910 50 {
lab=vin+}
N 910 20 980 20 {
lab=vin+}
N 910 50 910 200 {
lab=vin+}
N 910 200 910 210 {
lab=vin+}
N 910 210 980 210 {
lab=vin+}
N 850 80 850 230 {
lab=vin-}
N 830 80 850 80 {
lab=vin-}
N 850 80 940 80 {
lab=vin-}
N 1340 -90 1340 60 {
lab=test}
N 1340 -90 1390 -90 {
lab=test}
N 1360 -50 1390 -50 {
lab=#net2}
N 1360 -50 1360 80 {
lab=#net2}
N 940 80 980 80 {
lab=vin-}
N 850 270 980 270 {
lab=vin-}
N 850 230 850 270 {
lab=vin-}
N 1350 80 1420 80 {
lab=#net2}
N 1720 60 1780 60 {
lab=test2}
N 1780 0 1780 60 {
lab=test2}
N 1780 0 1840 0 {
lab=test2}
N 1800 40 1840 40 {
lab=#net3}
N 1800 40 1800 80 {
lab=#net3}
N 1720 80 1800 80 {
lab=#net3}
N 1280 80 1350 80 {
lab=#net2}
N 1280 60 1350 60 {
lab=test}
N 1350 20 1350 60 {
lab=test}
N 1350 20 1420 20 {
lab=test}
N 1330 700 1380 700 {
lab=#net4}
N 1280 270 1280 700 {
lab=#net4}
N 1280 700 1330 700 {
lab=#net4}
N 1280 250 1340 250 {
lab=test3}
N 1340 250 1340 450 {
lab=test3}
N 1340 450 1350 450 {
lab=test3}
N 1980 440 1990 440 {
lab=test3}
N 1900 440 1980 440 {
lab=test3}
N 1860 500 1990 500 {
lab=#net4}
N 1860 500 1860 720 {
lab=#net4}
N 1310 50 1310 60 {
lab=test}
N 1800 -10 1800 -0 {
lab=test2}
N 1340 230 1340 250 {
lab=test3}
N 1350 450 1900 450 {
lab=test3}
N 1900 440 1900 450 {
lab=test3}
N 1380 720 1860 720 {
lab=#net4}
N 1380 700 1380 720 {
lab=#net4}
N 470 430 510 430 {
lab=VDD}
N 510 410 510 430 {
lab=VDD}
N 470 450 550 450 {
lab=VSS}
N 550 440 550 450 {
lab=VSS}
N 470 470 590 470 {
lab=clk-}
N 470 490 650 490 {
lab=clk+}
N 650 480 650 490 {
lab=clk+}
N 590 450 590 470 {
lab=clk-}
N 800 720 830 720 {
lab=VSS}
N 830 720 830 780 {
lab=VSS}
N 870 700 870 760 {
lab=VDD}
N 800 700 870 700 {
lab=VDD}
C {devices/vsource.sym} -240 220 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -240 250 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -240 190 0 0 {name=p5 sig_type=std_logic lab=VDD
}
C {devices/vsource.sym} -150 220 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -150 250 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -150 190 0 0 {name=p1 sig_type=std_logic lab=VSS
}
C {devices/vsource.sym} -60 130 0 0 {name=V2 value="PULSE(0 1.8 0 5p 5p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -60 160 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -60 80 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {devices/simulator_commands_shown.sym} -540 -220 0 0 {name=COMMANDS1
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 20n
  write divide_by_two_tb.raw
.endc
"}
C {devices/vsource.sym} 190 180 0 0 {name=V4 value="PULSE(1.8 0 0 5p 5p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} 190 210 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} 190 130 0 0 {name=p8 sig_type=std_logic lab=vin-
}
C {devices/vsource.sym} -410 210 0 0 {name=V5 value=1.2 savecurrent=false}
C {devices/gnd.sym} -410 240 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -370 20 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -370 160 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -320 190 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -320 270 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 830 80 0 0 {name=p2 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} 830 50 0 0 {name=p12 sig_type=std_logic lab=vin+
}
C {devices/vsource.sym} 20 330 0 0 {name=V6 value="PULSE(0 1.8 50p 5p 5p 1n 2n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} 20 360 0 0 {name=l6 lab=GND}
C {devices/lab_wire.sym} 650 480 0 0 {name=p10 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 590 450 0 0 {name=p11 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 980 250 0 0 {name=p3 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 980 230 0 0 {name=p4 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 980 290 0 0 {name=p19 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 1280 20 0 1 {name=p6 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 1280 40 0 1 {name=p7 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1280 210 0 1 {name=p16 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 1280 230 0 1 {name=p17 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 2290 440 0 1 {name=p18 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 2290 460 0 1 {name=p20 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1720 20 0 1 {name=p21 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 1420 40 0 0 {name=p22 sig_type=std_logic lab=clk+}
C {devices/lab_wire.sym} 1420 60 0 0 {name=p23 sig_type=std_logic lab=clk-}
C {devices/lab_wire.sym} 1420 100 0 0 {name=p24 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 1990 460 0 0 {name=p25 sig_type=std_logic lab=clk+}
C {devices/lab_wire.sym} 1990 480 0 0 {name=p26 sig_type=std_logic lab=clk-}
C {devices/lab_wire.sym} 1990 520 0 0 {name=p27 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 2290 480 0 1 {name=p30 sig_type=std_logic lab=B+}
C {devices/lab_wire.sym} 2290 500 0 1 {name=p31 sig_type=std_logic lab=B-}
C {devices/opin.sym} 1690 -50 0 0 {name=p32 lab=down}
C {devices/lab_wire.sym} 1390 -70 0 0 {name=p33 sig_type=std_logic lab=B-}
C {devices/lab_wire.sym} 1390 -30 0 0 {name=p34 sig_type=std_logic lab=B+}
C {robs_xor.sym} 1540 -60 0 0 {name=x6}
C {devices/opin.sym} 2140 40 0 0 {name=p35 lab=up}
C {devices/lab_wire.sym} 1840 20 0 0 {name=p36 sig_type=std_logic lab=B-}
C {devices/lab_wire.sym} 1840 60 0 0 {name=p37 sig_type=std_logic lab=B+}
C {robs_xor.sym} 1990 30 0 0 {name=x7}
C {devices/lab_wire.sym} 2140 20 0 1 {name=p38 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 2140 0 0 1 {name=p39 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 1690 -70 0 1 {name=p40 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1690 -90 0 1 {name=p41 sig_type=std_logic lab=VDD}
C {d_flip_flop.sym} 1130 60 0 0 {name=x5}
C {d_flip_flop.sym} 1130 250 0 0 {name=x1}
C {d_flip_flop.sym} 1570 60 0 0 {name=x2}
C {d_flip_flop.sym} 2140 480 0 0 {name=x3}
C {devices/lab_wire.sym} 1720 40 0 1 {name=p47 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 980 100 0 0 {name=p42 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 980 40 0 0 {name=p43 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 980 60 0 0 {name=p44 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 1310 50 0 1 {name=p13 sig_type=std_logic lab=test}
C {devices/lab_wire.sym} 1800 -10 0 1 {name=p14 sig_type=std_logic lab=test2}
C {devices/lab_wire.sym} 1340 230 0 1 {name=p15 sig_type=std_logic lab=test3}
C {devices/lab_wire.sym} 20 280 0 0 {name=p45 sig_type=std_logic lab=clk_gen
}
C {s2d.sym} 320 460 0 0 {name=x4}
C {devices/lab_wire.sym} 510 410 0 0 {name=p49 sig_type=std_logic lab=VDD
}
C {devices/lab_wire.sym} 550 440 0 0 {name=p50 sig_type=std_logic lab=VSS
}
C {devices/lab_wire.sym} 170 430 0 0 {name=p46 sig_type=std_logic lab=clk_gen
}
C {d_latch.sym} 650 700 0 0 {name=x8}
C {devices/lab_wire.sym} 500 700 0 0 {name=p48 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 500 720 0 0 {name=p51 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 870 760 0 0 {name=p52 sig_type=std_logic lab=VDD
}
C {devices/lab_wire.sym} 830 780 0 0 {name=p53 sig_type=std_logic lab=VSS
}
C {devices/lab_wire.sym} 500 680 0 0 {name=p54 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} 500 660 0 0 {name=p55 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 500 740 0 0 {name=p56 sig_type=std_logic lab=vbias
}
C {devices/opin.sym} 800 660 0 0 {name=p57 lab=d+}
C {devices/opin.sym} 800 680 0 0 {name=p58 lab=d-}
