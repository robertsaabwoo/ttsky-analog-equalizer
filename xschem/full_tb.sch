v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -690 480 -660 480 {
lab=vin+}
N -690 500 -660 500 {
lab=#net1}
N -820 280 -800 280 {
lab=vbias}
N -800 340 -800 390 {
lab=Vss}
N -800 230 -800 280 {
lab=vbias}
N -800 180 -800 230 {
lab=vbias}
N -850 180 -800 180 {
lab=vbias}
N -850 140 -850 180 {
lab=vbias}
N -890 280 -880 280 {
lab=#net2}
N -890 280 -890 300 {
lab=#net2}
N -660 500 -620 500 {
lab=#net1}
N -660 480 -580 480 {
lab=vin+}
N -620 500 -580 500 {
lab=#net1}
N -570 640 -300 640 {
lab=#net1}
N -570 500 -570 640 {
lab=#net1}
N -580 500 -570 500 {
lab=#net1}
N -410 600 -300 600 {
lab=vin+}
N -410 480 -410 600 {
lab=vin+}
N -580 480 -410 480 {
lab=vin+}
N -850 485 -690 485 {
lab=vin+}
N -690 480 -690 485 {
lab=vin+}
N -565 440 -565 480 {
lab=vin+}
N -300 640 -280 640 {
lab=#net1}
N -300 600 -300 610 {
lab=vin+}
N -300 610 -200 610 {
lab=vin+}
N -280 630 -200 630 {
lab=#net1}
N -280 630 -280 640 {
lab=#net1}
N -230 680 -200 680 {
lab=vbias}
N -200 650 -200 680 {
lab=vbias}
N 100 610 130 610 {
lab=Vdd}
N 130 600 130 610 {
lab=Vdd}
N 100 630 170 630 {
lab=Vss}
N 170 610 170 630 {
lab=Vss}
N 100 670 260 670 {
lab=#net3}
N 100 650 160 650 {
lab=#net4}
N 160 650 160 690 {
lab=#net4}
N 160 690 260 690 {
lab=#net4}
N 250 630 250 650 {
lab=vbias}
N 250 650 260 650 {
lab=vbias}
N 560 670 660 670 {}
N 560 690 660 690 {}
N 660 670 690 670 {
lab=Vdd}
N 690 660 690 670 {
lab=Vdd}
N 660 690 730 690 {
lab=Vss}
N 730 670 730 690 {
lab=Vss}
C {devices/vsource.sym} -1060 -110 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -1060 -80 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -1060 -140 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -970 -110 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -970 -80 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -970 -140 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -440 190 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 30n
  write full_tb.raw
.endc
"}
C {devices/vsource.sym} -850 515 0 0 {name=V2 value="PULSE(0 1.8 0 10p 10p 1.67n 3.33n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -850 545 0 0 {name=l2 lab=GND}
C {devices/vsource.sym} -690 530 0 0 {name=V4 value="PULSE(1.8 0 0 10p 10p 1.67n 3.33n)" savecurrent=false}
C {devices/gnd.sym} -690 560 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} -890 330 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -890 360 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -850 140 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -850 280 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -800 310 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -800 390 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/opin.sym} 560 650 0 0 {name=p32 lab=clk+}
C {devices/lab_wire.sym} -565 440 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {CDR.sym} -50 640 0 0 {name=x1}
C {devices/lab_wire.sym} -230 680 0 0 {name=p2 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 130 600 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 170 610 0 0 {name=p4 sig_type=std_logic lab=Vss
}
C {D2S_amp.sym} 410 670 0 0 {name=x2}
C {devices/lab_wire.sym} 250 630 0 0 {name=p6 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 690 660 0 0 {name=p7 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 730 670 0 0 {name=p8 sig_type=std_logic lab=Vss
}
