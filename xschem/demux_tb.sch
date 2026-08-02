v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 300 50 330 50 {
lab=vin+}
N 300 70 330 70 {
lab=vin-}
N -560 500 -540 500 {
lab=vbias}
N -540 560 -540 610 {
lab=Vss}
N -540 450 -540 500 {
lab=vbias}
N -540 400 -540 450 {
lab=vbias}
N -590 400 -540 400 {
lab=vbias}
N -590 360 -590 400 {
lab=vbias}
N -630 500 -620 500 {
lab=#net1}
N -630 500 -630 520 {
lab=#net1}
N 330 70 370 70 {
lab=vin-}
N 330 50 410 50 {
lab=vin+}
N 370 70 410 70 {
lab=vin-}
N 420 70 420 210 {
lab=vin-}
N 410 70 420 70 {
lab=vin-}
N 820 50 860 50 {
lab=Vdd}
N 860 30 860 50 {
lab=Vdd}
N 820 70 900 70 {
lab=Vss}
N 900 60 900 70 {
lab=Vss}
N 140 55 300 55 {
lab=vin+}
N 300 50 300 55 {
lab=vin+}
N 390 220 420 220 {
lab=vin-}
N 420 210 420 220 {
lab=vin-}
N 410 50 420 50 {
lab=vin+}
N 400 10 400 50 {
lab=vin+}
N 420 50 520 50 {
lab=vin+}
N 420 70 520 70 {
lab=vin-}
N 520 90 520 180 {
lab=vbias}
N 500 180 520 180 {
lab=vbias}
N 1160 450 1190 450 {
lab=Vss}
N 1190 450 1190 480 {
lab=Vss}
N 1220 430 1220 500 {
lab=Vdd}
N 1160 430 1220 430 {
lab=Vdd}
C {devices/vsource.sym} -800 110 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -800 140 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -800 80 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -710 110 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -710 140 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -710 80 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -910 -430 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 20n
  write demux_tb.raw
.endc
"}
C {devices/vsource.sym} 140 85 0 0 {name=V2 value="PULSE(0 1.8 0 10p 10p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} 140 115 0 0 {name=l2 lab=GND}
C {devices/vsource.sym} 300 100 0 0 {name=V4 value="PULSE(1.8 0 0 10p 10p 0.5n 1n)" savecurrent=false}
C {devices/gnd.sym} 300 130 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} -630 550 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -630 580 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -590 360 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -590 500 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -540 530 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -540 610 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/opin.sym} 820 110 0 0 {name=p17 lab=rclk-}
C {devices/opin.sym} 820 90 0 0 {name=p32 lab=rclk+}
C {devices/lab_wire.sym} 860 30 0 0 {name=p38 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 900 60 0 0 {name=p39 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 400 10 0 0 {name=p2 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 390 220 0 0 {name=p3 sig_type=std_logic lab=vin-
}
C {CDR.sym} 670 80 0 0 {name=x1}
C {devices/lab_wire.sym} 500 180 0 0 {name=p4 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 860 430 0 0 {name=p16 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 860 390 0 0 {name=p19 sig_type=std_logic lab=vin+
}
C {devices/opin.sym} 1160 410 0 0 {name=p21 lab=clk-}
C {devices/opin.sym} 1160 390 0 0 {name=p22 lab=clk+}
C {devices/lab_wire.sym} 1220 500 0 0 {name=p23 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1190 480 0 0 {name=p24 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 860 410 0 0 {name=p15 sig_type=std_logic lab=vin-
}
C {divide_by_two.sym} 1010 420 0 0 {name=x4}
