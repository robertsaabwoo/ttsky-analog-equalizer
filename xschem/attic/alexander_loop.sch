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
N 710 50 740 50 {
lab=Vdd}
N 740 30 740 50 {
lab=Vdd}
N 710 70 790 70 {
lab=Vss}
N 790 50 790 70 {
lab=Vss}
N 20 280 20 300 {
lab=clk+}
N 330 310 330 330 {
lab=clk-}
C {devices/vsource.sym} -240 220 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -240 250 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -240 190 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -150 220 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -150 250 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -150 190 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/vsource.sym} -60 130 0 0 {name=V2 value="PULSE(0 1.8 0 50p 50p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -60 160 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -60 80 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 740 30 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 790 50 0 0 {name=p4 sig_type=std_logic lab=Vss
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
C {devices/opin.sym} 710 90 0 0 {name=p6 lab=vout+}
C {devices/opin.sym} 710 110 0 0 {name=p7 lab=vout-}
C {devices/vsource.sym} 190 180 0 0 {name=V4 value="PULSE(1.8 0 0 50p 50p 0.5n 1n)" savecurrent=false
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
C {devices/lab_wire.sym} 410 110 0 0 {name=p2 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} 410 70 0 0 {name=p12 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 410 130 0 0 {name=p13 sig_type=std_logic lab=vbias
}
C {devices/vsource.sym} 20 330 0 0 {name=V6 value="PULSE(0 1.8 0 50p 50p 0.8n 1.6n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} 20 360 0 0 {name=l6 lab=GND}
C {devices/lab_wire.sym} 20 280 0 0 {name=p10 sig_type=std_logic lab=clk+
}
C {devices/vsource.sym} 330 360 0 0 {name=V7 value="PULSE(1.8 0 0 50p 50p 0.8n 1.6n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} 330 390 0 0 {name=l7 lab=GND}
C {devices/lab_wire.sym} 330 310 0 0 {name=p11 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 410 50 0 0 {name=p14 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 410 90 0 0 {name=p15 sig_type=std_logic lab=clk-
}
C {alexander_phase_detector.sym} 560 90 0 0 {name=x1}
