v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -190 70 -160 70 {
lab=vin+}
N -190 90 -160 90 {
lab=#net1}
N -320 -130 -300 -130 {
lab=vbias}
N -300 -70 -300 -20 {
lab=Vss}
N -300 -180 -300 -130 {
lab=vbias}
N -300 -230 -300 -180 {
lab=vbias}
N -350 -230 -300 -230 {
lab=vbias}
N -350 -270 -350 -230 {
lab=vbias}
N -390 -130 -380 -130 {
lab=#net2}
N -390 -130 -390 -110 {
lab=#net2}
N -160 90 -120 90 {
lab=#net1}
N -160 70 -80 70 {
lab=vin+}
N -120 90 -80 90 {
lab=#net1}
N -70 230 200 230 {
lab=#net1}
N -70 90 -70 230 {
lab=#net1}
N -80 90 -70 90 {
lab=#net1}
N 90 190 200 190 {
lab=vin+}
N 90 70 90 190 {
lab=vin+}
N -80 70 90 70 {
lab=vin+}
N -350 75 -190 75 {
lab=vin+}
N -190 70 -190 75 {
lab=vin+}
N -65 30 -65 70 {
lab=vin+}
N 200 230 220 230 {
lab=#net1}
N 200 190 200 200 {
lab=vin+}
N 200 200 300 200 {
lab=vin+}
N 220 220 300 220 {
lab=#net1}
N 220 220 220 230 {
lab=#net1}
N 270 270 300 270 {
lab=vbias}
N 300 240 300 270 {
lab=vbias}
N 600 200 630 200 {
lab=Vdd}
N 630 190 630 200 {
lab=Vdd}
N 600 220 670 220 {
lab=Vss}
N 670 200 670 220 {
lab=Vss}
C {devices/vsource.sym} -560 -520 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -560 -490 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -560 -550 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -470 -520 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -470 -490 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -470 -550 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} 60 -220 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 20p 1500n
  write CDR_tune_tb.raw
.endc
"}
C {devices/vsource.sym} -350 105 0 0 {name=V2 value="PULSE(0 1.8 0 10p 10p 1.67n 3.33n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -350 135 0 0 {name=l2 lab=GND}
C {devices/vsource.sym} -190 120 0 0 {name=V4 value="PULSE(1.8 0 0 10p 10p 1.67n 3.33n)" savecurrent=false}
C {devices/gnd.sym} -190 150 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} -390 -80 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -390 -50 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -350 -270 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -350 -130 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -300 -100 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -300 -20 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/opin.sym} 600 260 0 0 {name=p17 lab=clk-}
C {devices/opin.sym} 600 240 0 0 {name=p32 lab=clk+}
C {devices/lab_wire.sym} -65 30 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {CDR_tune.sym} 450 230 0 0 {name=x1}
C {devices/lab_wire.sym} 270 270 0 0 {name=p2 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 630 190 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 670 200 0 0 {name=p4 sig_type=std_logic lab=Vss
}
