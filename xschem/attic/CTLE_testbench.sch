v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 130 -110 160 -110 {
lab=vout+_temp}
N 130 -90 160 -90 {
lab=vout-_temp}
N -380 -110 -350 -110 {
lab=vin+_bad}
N -350 -110 -280 -110 {
lab=vin+_bad}
N -350 -40 -330 -40 {
lab=vin-_bad}
N -280 -110 -170 -110 {
lab=vin+_bad}
N -330 20 -330 70 {
lab=Vss}
N -330 -90 -330 -40 {
lab=vin-_bad}
N -330 -90 -170 -90 {
lab=vin-_bad}
N -170 -70 -170 -60 {
lab=vbias}
N 130 -70 190 -70 {
lab=Vdd}
N 190 -70 190 -20 {
lab=Vdd}
N 130 -50 130 -10 {
lab=Vss}
N -280 -90 -280 40 {
lab=vin-_bad}
N -240 -140 -240 -110 {
lab=vin+_bad}
N -790 -270 -790 -250 {
lab=vin+}
N -790 -190 -790 -170 {
lab=#net1}
N -170 -60 -170 -20 {
lab=vbias}
N 160 -150 160 -110 {
lab=vout+_temp}
N 200 -90 200 70 {
lab=vout-_temp}
N 160 -110 290 -110 {
lab=vout+_temp}
N -730 340 -710 340 {
lab=vbias}
N -710 400 -710 450 {
lab=Vss}
N -710 290 -710 340 {
lab=vbias}
N -710 240 -710 290 {
lab=vbias}
N -760 240 -710 240 {
lab=vbias}
N -760 200 -760 240 {
lab=vbias}
N -800 340 -790 340 {
lab=#net2}
N -800 340 -800 360 {
lab=#net2}
N 650 -110 700 -110 {
lab=d2s_probe}
N 1050 -110 1110 -110 {
lab=Vdd}
N 1110 -110 1110 -60 {
lab=Vdd}
N 1050 -90 1050 -50 {
lab=Vss}
N 1000 -110 1050 -110 {
lab=Vdd}
N 1000 -90 1050 -90 {
lab=Vss}
N 1000 -70 1000 -40 {
lab=vout}
N 1000 20 1000 60 {
lab=Vss}
N 990 60 1000 60 {
lab=Vss}
N 900 0 930 0 {
lab=vout}
N 930 -40 930 0 {
lab=vout}
N 930 -50 930 -40 {
lab=vout}
N 930 -50 1000 -50 {
lab=vout}
N 290 -70 350 -70 {
lab=vout+_temp}
N 290 -110 290 -70 {
lab=vout+_temp}
N 160 -90 350 -90 {
lab=vout-_temp}
N 340 -160 340 -110 {
lab=vbias}
N 340 -110 350 -110 {
lab=vbias}
N 650 -90 710 -90 {
lab=Vdd}
N 710 -90 710 -40 {
lab=Vdd}
N 680 -70 680 -30 {
lab=Vss}
N 650 -70 680 -70 {
lab=Vss}
N 680 -170 680 -110 {
lab=d2s_probe}
C {devices/vsource.sym} -970 -50 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -970 -20 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -970 -80 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -880 -50 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -880 -20 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -880 -80 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/res.sym} -410 -110 1 0 {name=R1
value=500
footprint=1206
device=resistor
m=1}
C {devices/res.sym} -380 -40 1 0 {name=R2
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -350 -140 0 0 {name=C1
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} -330 -10 0 0 {name=C2
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -350 -170 0 0 {name=p10 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -330 70 0 0 {name=p11 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -1050 -430 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 20n
  write CTLE_testbench.raw
.endc
"}
C {devices/vsource.sym} -790 -140 0 0 {name=V2 value="PULSE(0 1.8 0 50p 50p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -790 -110 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -790 -270 0 0 {name=p3 sig_type=std_logic lab=vin+
}
C {devices/vsource.sym} -680 30 0 0 {name=V4 value="PULSE(1.8 0 0 50p 50p 0.5n 1n)" savecurrent=false}
C {devices/gnd.sym} -680 60 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -680 -60 0 0 {name=p6 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} -440 -110 0 0 {name=p12 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} -410 -40 0 0 {name=p13 sig_type=std_logic lab=vin-
}
C {devices/vsource.sym} -800 390 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -800 420 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} 190 -20 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 130 -10 0 0 {name=p8 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -240 -140 0 0 {name=p17 sig_type=std_logic lab=vin+_bad
}
C {devices/lab_wire.sym} -280 40 0 0 {name=p18 sig_type=std_logic lab=vin-_bad
}
C {devices/vsource.sym} -790 -220 0 0 {name=V6 value="TRNOISE(100m 50p 0 0)" savecurrent=false
lab=vin+}
C {devices/vsource.sym} -680 -30 0 0 {name=V7 value="TRNOISE(100m 50p 0 0)" savecurrent=false
lab=vin+}
C {CTLE.sym} -20 -80 0 0 {name=x1}
C {devices/lab_wire.sym} 160 -150 0 1 {name=p21 sig_type=std_logic lab=vout+_temp
}
C {devices/lab_wire.sym} 200 70 0 1 {name=p24 sig_type=std_logic lab=vout-_temp
}
C {devices/lab_wire.sym} -760 200 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -760 340 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -710 370 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -710 450 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -170 -20 0 0 {name=p14 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 1110 -60 0 0 {name=p2 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1050 -50 0 0 {name=p7 sig_type=std_logic lab=Vss
}
C {devices/res.sym} 1000 -10 0 0 {name=R3
value=500
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} 990 60 0 0 {name=p9 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 900 0 0 0 {name=p15 sig_type=std_logic lab=vout
}
C {D2S_amp.sym} 500 -90 0 0 {name=x3}
C {devices/lab_wire.sym} 340 -160 0 0 {name=p16 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 710 -40 0 0 {name=p19 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 680 -30 0 0 {name=p20 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 680 -170 0 0 {name=p22 sig_type=std_logic lab=d2s_probe
}
C {inverter_chain.sym} 850 -90 0 0 {name=x2}
