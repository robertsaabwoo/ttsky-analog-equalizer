v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -10 370 20 370 {
lab=Vdd}
N 20 340 20 370 {
lab=Vdd}
N -10 390 70 390 {
lab=Vss}
N 70 340 70 390 {
lab=Vss}
C {devices/vsource.sym} -980 190 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -980 220 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -980 160 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -890 190 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -890 220 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -890 160 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -1100 -350 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 30n
  write VCO_tb.raw
.endc
"}
C {devices/vsource.sym} -960 500 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -960 530 0 0 {name=l5 lab=GND}
C {devices/lab_wire.sym} -960 470 0 0 {name=p9 sig_type=std_logic lab=vctrl
}
C {devices/opin.sym} -10 410 0 0 {name=p10 lab=vo+}
C {devices/opin.sym} -10 430 0 0 {name=p11 lab=vo-}
C {ring_oscillator.sym} -160 400 0 0 {name=x1}
C {devices/lab_wire.sym} -310 370 0 0 {name=p2 sig_type=std_logic lab=vctrl
}
C {devices/lab_wire.sym} 20 340 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 70 340 0 0 {name=p4 sig_type=std_logic lab=Vss
}
