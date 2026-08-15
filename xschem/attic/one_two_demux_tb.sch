v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -520 -330 -520 -310 {
lab=vin+}
N -520 -250 -520 -230 {
lab=#net1}
N -460 280 -440 280 {
lab=vbias}
N -440 340 -440 390 {
lab=Vss}
N -440 230 -440 280 {
lab=vbias}
N -440 180 -440 230 {
lab=vbias}
N -490 180 -440 180 {
lab=vbias}
N -490 140 -490 180 {
lab=vbias}
N -530 280 -520 280 {
lab=#net2}
N -530 280 -530 300 {
lab=#net2}
N -1080 -100 -1080 -80 {
lab=in_clk+}
N 330 -60 370 -60 {
lab=Vdd}
N 400 -60 400 -50 {
lab=Vss}
N 400 -50 400 -40 {
lab=Vss}
N 330 -40 400 -40 {
lab=Vss}
N 450 -100 450 10 {
lab=vout0}
N 330 -100 450 -100 {
lab=vout0}
N 890 -70 930 -70 {
lab=Vdd}
N 960 -70 960 -60 {
lab=Vss}
N 960 -60 960 -50 {
lab=Vss}
N 890 -50 960 -50 {
lab=Vss}
N 330 -20 490 -20 {
lab=#net3}
N 490 -90 490 -20 {
lab=#net3}
N 490 -90 590 -90 {
lab=#net3}
N 590 -70 590 0 {
lab=#net4}
N 330 0 590 0 {
lab=#net4}
N 330 -140 530 -140 {
lab=inv}
N 530 -140 530 -130 {
lab=inv}
N 530 -130 590 -130 {
lab=inv}
N 330 -120 480 -120 {
lab=#net5}
N 480 -120 480 -110 {
lab=#net5}
N 480 -110 590 -110 {
lab=#net5}
N 420 -190 420 -140 {
lab=inv}
C {one_to_two_demux.sym} 180 -70 0 0 {name=x1}
C {devices/vsource.sym} -700 -110 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -700 -80 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -700 -140 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -610 -110 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -610 -80 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -610 -140 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -780 -490 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=0.001 abstol=1e-3
.op
.control
  tran 10p 20n
  write one_to_two_demux.raw
.endc
"}
C {devices/vsource.sym} -520 -200 0 0 {name=V2 value="PWL(0 1.8 2n 1.8 2.05n 0 3n 0 3.05n 1.8 4n 1.8 4.05n 0 6n 0 6.05n 1.8 8n 1.8)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -520 -170 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -520 -330 0 0 {name=p7 sig_type=std_logic lab=vin+
}
C {devices/vsource.sym} -410 -30 0 0 {name=V4 value="PWL(0 0 2n 0 2.05n 1.8 3n 1.8 3.05n 0 4n 0 4.05n 1.8 6n 1.8 6.05n 0 8n 0)" savecurrent=false}
C {devices/gnd.sym} -410 0 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -410 -120 0 0 {name=p8 sig_type=std_logic lab=vin-
}
C {devices/vsource.sym} -530 330 0 0 {name=V5 value=1.2 savecurrent=false}
C {devices/gnd.sym} -530 360 0 0 {name=l5 lab=GND
value=vbias}
C {devices/vsource.sym} -520 -280 0 0 {name=V6 value="TRNOISE(10m 50p 0 0)" savecurrent=false
lab=vin+}
C {devices/vsource.sym} -410 -90 0 0 {name=V7 value="TRNOISE(10m 50p 0 0)" savecurrent=false
lab=vin+}
C {devices/lab_wire.sym} -490 140 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -490 280 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -440 310 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -440 390 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/vsource.sym} -950 90 0 0 {name=V8 value="PULSE(1.8 0 0 10p 10p 0.24n 0.5n)" savecurrent=false}
C {devices/gnd.sym} -950 120 0 0 {name=l6 lab=GND}
C {devices/lab_wire.sym} -950 60 0 0 {name=p9 sig_type=std_logic lab=in_clk-
}
C {devices/vsource.sym} -1080 -50 0 0 {name=V9 value="PULSE(0 1.8 0 10p 10p 0.24n 0.5n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -1080 -20 0 0 {name=l7 lab=GND}
C {devices/lab_wire.sym} -1080 -100 0 0 {name=p10 sig_type=std_logic lab=in_clk+
}
C {devices/lab_wire.sym} 30 -140 0 0 {name=p2 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 30 -120 0 0 {name=p3 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 30 -100 0 0 {name=p4 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} 370 -60 0 0 {name=p6 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 400 -60 0 0 {name=p11 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 30 -80 0 0 {name=p12 sig_type=std_logic lab=in_clk+
}
C {devices/lab_wire.sym} 30 -60 0 0 {name=p13 sig_type=std_logic lab=in_clk-
}
C {devices/opin.sym} 450 10 0 0 {name=p19 lab=vout0}
C {one_to_two_demux.sym} 740 -80 0 0 {name=x2}
C {devices/lab_wire.sym} 590 -150 0 0 {name=p14 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 930 -70 0 0 {name=p17 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 960 -70 0 0 {name=p18 sig_type=std_logic lab=Vss
}
C {devices/opin.sym} 890 -30 0 0 {name=p27 lab=clk+}
C {devices/opin.sym} 890 -10 0 0 {name=p30 lab=clk-}
C {devices/opin.sym} 890 -150 0 0 {name=p20 lab=vout1}
C {devices/lab_wire.sym} 420 -190 0 0 {name=p15 sig_type=std_logic lab=inv
}
C {devices/lab_wire.sym} 480 -190 0 0 {name=p16 sig_type=std_logic lab=inv
}
