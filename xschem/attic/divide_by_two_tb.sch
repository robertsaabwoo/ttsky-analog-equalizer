v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -660 20 -660 40 {
lab=vin+}
N 80 -70 130 -70 {
lab=Vss}
N -410 70 -410 90 {
lab=vin-}
N -940 100 -920 100 {
lab=vbias}
N -920 160 -920 210 {
lab=Vss}
N -920 50 -920 100 {
lab=vbias}
N -920 0 -920 50 {
lab=vbias}
N -970 0 -920 0 {
lab=vbias}
N -970 -40 -970 0 {
lab=vbias}
N -1010 100 -1000 100 {
lab=#net1}
N -1010 100 -1010 120 {
lab=#net1}
N 80 -130 150 -130 {
lab=vout+}
N 130 -90 130 -70 {
lab=Vss}
N 80 -90 90 -90 {
lab=Vdd}
N 90 -90 100 -90 {
lab=Vdd}
N 100 -90 100 -40 {
lab=Vdd}
N 80 -110 150 -110 {
lab=vout-}
C {devices/vsource.sym} -840 160 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -840 190 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -840 130 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -750 160 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -750 190 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -750 130 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/vsource.sym} -660 70 0 0 {name=V2 value="PULSE(0 1.8 0 50p 50p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -660 100 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -660 20 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} -220 -130 0 0 {name=p2 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 100 -40 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 130 -90 0 0 {name=p4 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -1140 -280 0 0 {name=COMMANDS1
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
C {devices/opin.sym} 150 -130 0 0 {name=p6 lab=vout+}
C {devices/opin.sym} 150 -110 0 0 {name=p7 lab=vout-}
C {devices/vsource.sym} -410 120 0 0 {name=V4 value="PULSE(1.8 0 0 50p 50p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -410 150 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -410 70 0 0 {name=p8 sig_type=std_logic lab=vin-
}
C {devices/vsource.sym} -1010 150 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -1010 180 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -970 -40 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -970 100 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -920 130 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -920 210 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {divide_by_two.sym} -70 -100 0 0 {name=x1}
C {devices/lab_wire.sym} -220 -110 0 0 {name=p10 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} -220 -90 0 0 {name=p11 sig_type=std_logic lab=vbias
}
