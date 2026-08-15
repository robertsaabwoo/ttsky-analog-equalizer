v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -340 500 -320 500 {
lab=vbias}
N -320 450 -320 500 {
lab=vbias}
N -320 400 -320 450 {
lab=vbias}
N -370 400 -320 400 {
lab=vbias}
N -370 360 -370 400 {
lab=vbias}
N -410 500 -400 500 {
lab=vbias}
N -410 500 -410 520 {
lab=vbias}
N 470 -20 510 -20 {
lab=Vss}
N 510 -40 510 -20 {
lab=Vss}
N 420 -120 510 -120 {
lab=vbias}
N 510 -120 510 -80 {
lab=vbias}
N 570 -190 570 -180 {
lab=Vdd}
N 570 -190 600 -190 {
lab=Vdd}
N 600 -210 600 -190 {
lab=Vdd}
N 550 40 550 60 {
lab=Vss}
N 550 60 570 60 {
lab=Vss}
N 570 40 570 60 {
lab=Vss}
N -400 500 -340 500 {
lab=vbias}
N 1020 -100 1080 -100 {
lab=Vdd}
N 1080 -100 1080 -50 {
lab=Vdd}
N 1020 -80 1020 -40 {
lab=Vss}
N 970 -100 1020 -100 {
lab=Vdd}
N 970 -80 1020 -80 {
lab=Vss}
N 900 -40 900 -30 {
lab=vout}
N 900 -40 970 -40 {
lab=vout}
N 970 -60 970 -40 {
lab=vout}
N 970 -40 970 -20 {
lab=vout}
N 900 -30 900 -10 {
lab=vout}
N 890 -10 900 -10 {
lab=vout}
N 960 70 970 70 {
lab=Vss}
N 970 40 970 70 {
lab=Vss}
C {devices/vsource.sym} -580 110 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -580 140 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -580 80 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -490 110 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -490 140 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -490 80 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -660 -270 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 50n
  write vco_testbench.raw
.endc
"}
C {devices/vsource.sym} -410 550 0 0 {name=V5 value=1.2 savecurrent=false}
C {devices/gnd.sym} -410 580 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} 890 -10 0 0 {name=p17 sig_type=std_logic lab=vout
}
C {devices/lab_wire.sym} -370 360 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 420 -120 0 0 {name=p14 sig_type=std_logic lab=vbias
}
C {tiny_pll_vco.sym} 590 -80 0 0 {name=x1}
C {devices/lab_wire.sym} 470 -20 0 0 {name=p2 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 510 -60 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 550 -180 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 600 -210 0 0 {name=p6 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 550 60 0 0 {name=p8 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1080 -50 0 0 {name=p23 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1020 -40 0 0 {name=p25 sig_type=std_logic lab=Vss
}
C {inverter_chain.sym} 820 -80 0 0 {name=x4}
C {devices/res.sym} 970 10 0 1 {name=R3
value=500
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} 960 70 0 0 {name=p7 sig_type=std_logic lab=Vss
}
