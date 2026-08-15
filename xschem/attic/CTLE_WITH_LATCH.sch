v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 150 -80 180 -80 {
lab=vout+_temp}
N 150 -60 180 -60 {
lab=vout-_temp}
N -360 -80 -330 -80 {
lab=vin+_bad}
N -330 -80 -260 -80 {
lab=vin+_bad}
N -330 -10 -310 -10 {
lab=vin-_bad}
N -260 -80 -150 -80 {
lab=vin+_bad}
N -310 50 -310 100 {
lab=Vss}
N -310 -60 -310 -10 {
lab=vin-_bad}
N -310 -60 -150 -60 {
lab=vin-_bad}
N -150 -40 -150 -30 {
lab=vbias}
N 150 -40 210 -40 {
lab=Vdd}
N 210 -40 210 10 {
lab=Vdd}
N 150 -20 150 20 {
lab=Vss}
N -260 -60 -260 70 {
lab=vin-_bad}
N -220 -110 -220 -80 {
lab=vin+_bad}
N -770 -240 -770 -220 {
lab=vin+}
N -770 -160 -770 -140 {
lab=#net1}
N -150 -30 -150 10 {
lab=vbias}
N 180 -120 180 -80 {
lab=vout+_temp}
N 220 -60 220 100 {
lab=vout-_temp}
N 180 -80 310 -80 {
lab=vout+_temp}
N -710 370 -690 370 {
lab=vbias}
N -690 430 -690 480 {
lab=Vss}
N -690 320 -690 370 {
lab=vbias}
N -690 270 -690 320 {
lab=vbias}
N -740 270 -690 270 {
lab=vbias}
N -740 230 -740 270 {
lab=vbias}
N -780 370 -770 370 {
lab=#net2}
N -780 370 -780 390 {
lab=#net2}
N 180 -60 370 -60 {
lab=vout-_temp}
N 310 -80 370 -80 {
lab=vout+_temp}
N -1330 -10 -1330 10 {
lab=clk+}
N 860 80 920 80 {
lab=Vdd}
N 920 80 920 130 {
lab=Vdd}
N 860 100 860 140 {
lab=Vss}
N 870 -180 880 -180 {
lab=#net3}
N 490 -160 570 -160 {
lab=clk-}
N 490 -140 570 -140 {
lab=clk+}
N 520 100 560 100 {
lab=clk-}
N 510 80 560 80 {
lab=clk+}
N 370 -200 370 -80 {
lab=vout+_temp}
N 370 -200 570 -200 {
lab=vout+_temp}
N 390 -180 570 -180 {
lab=vout-_temp}
N 390 -180 390 -60 {
lab=vout-_temp}
N 370 -60 390 -60 {
lab=vout-_temp}
N 350 -80 350 40 {
lab=vout+_temp}
N 350 40 560 40 {
lab=vout+_temp}
N 320 60 560 60 {
lab=vout-_temp}
N 320 -60 320 60 {
lab=vout-_temp}
N 870 -160 930 -160 {
lab=Vdd}
N 930 -160 930 -110 {
lab=Vdd}
N 870 -140 870 -100 {
lab=Vss}
N 950 20 950 60 {
lab=#net4}
N 950 20 980 20 {
lab=#net4}
N 860 40 980 40 {
lab=v1t}
N 860 60 950 60 {
lab=#net4}
N 1280 20 1340 20 {
lab=Vdd}
N 1340 20 1340 70 {
lab=Vdd}
N 1280 40 1280 80 {
lab=Vss}
N 1800 -220 1860 -220 {
lab=Vdd}
N 1860 -220 1860 -170 {
lab=Vdd}
N 1800 -200 1800 -160 {
lab=Vss}
N 1800 -240 1900 -240 {
lab=#net5}
N 1280 -0 1380 0 {
lab=#net6}
N 2210 -270 2210 -240 {
lab=Vdd}
N 2200 -240 2210 -240 {
lab=Vdd}
N 2200 -220 2240 -220 {
lab=Vss}
N 2240 -270 2240 -220 {
lab=Vss}
N 1690 -30 1690 0 {
lab=Vdd}
N 1680 0 1690 0 {
lab=Vdd}
N 1680 20 1720 20 {
lab=Vss}
N 1720 -30 1720 20 {
lab=Vss}
N 930 -280 930 -200 {
lab=v0t}
N 890 0 890 40 {
lab=v1t}
N 1400 -220 1500 -220 {
lab=#net7}
N 1400 -220 1400 -180 {
lab=#net7}
N 1360 -180 1370 -180 {
lab=#net7}
N 980 -160 1060 -160 {
lab=clk+}
N 980 -140 1060 -140 {
lab=clk-}
N 860 -200 1060 -200 {
lab=v0t}
N 880 -180 1060 -180 {
lab=#net3}
N 1360 -160 1420 -160 {
lab=Vdd}
N 1420 -160 1420 -110 {
lab=Vdd}
N 1360 -140 1360 -100 {
lab=Vss}
N 1370 -180 1400 -180 {
lab=#net7}
N 1360 -200 1420 -200 {
lab=#net8}
N 1420 -200 1500 -200 {
lab=#net8}
C {devices/vsource.sym} -950 -20 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -950 10 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -950 -50 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -860 -20 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -860 10 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -860 -50 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/res.sym} -390 -80 1 0 {name=R1
value=500
footprint=1206
device=resistor
m=1}
C {devices/res.sym} -360 -10 1 0 {name=R2
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -330 -110 0 0 {name=C1
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} -310 20 0 0 {name=C2
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -330 -140 0 0 {name=p10 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -310 100 0 0 {name=p11 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -1030 -400 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=0.001 abstol=1e-3
.op
.control
  tran 10p 20n
  write CTLE_WITH_LATCH.raw
.endc
"}
C {devices/vsource.sym} -770 -110 0 0 {name=V2 value="PWL(0 1.8 2n 1.8 2.05n 0 3n 0 3.05n 1.8 4n 1.8 4.05n 0 6n 0 6.05n 1.8 8n 1.8)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -770 -80 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -770 -240 0 0 {name=p3 sig_type=std_logic lab=vin+
}
C {devices/vsource.sym} -660 60 0 0 {name=V4 value="PWL(0 0 2n 0 2.05n 1.8 3n 1.8 3.05n 0 4n 0 4.05n 1.8 6n 1.8 6.05n 0 8n 0)" savecurrent=false}
C {devices/gnd.sym} -660 90 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -660 -30 0 0 {name=p6 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} -420 -80 0 0 {name=p12 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} -390 -10 0 0 {name=p13 sig_type=std_logic lab=vin-
}
C {devices/vsource.sym} -780 420 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -780 450 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} 210 10 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 150 20 0 0 {name=p8 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -220 -110 0 0 {name=p17 sig_type=std_logic lab=vin+_bad
}
C {devices/lab_wire.sym} -260 70 0 0 {name=p18 sig_type=std_logic lab=vin-_bad
}
C {devices/vsource.sym} -770 -190 0 0 {name=V6 value="TRNOISE(10m 50p 0 0)" savecurrent=false
lab=vin+}
C {devices/vsource.sym} -660 0 0 0 {name=V7 value="TRNOISE(10m 50p 0 0)" savecurrent=false
lab=vin+}
C {CTLE.sym} 0 -50 0 0 {name=x1}
C {devices/lab_wire.sym} 180 -120 0 1 {name=p21 sig_type=std_logic lab=vout+_temp
}
C {devices/lab_wire.sym} 220 100 0 1 {name=p24 sig_type=std_logic lab=vout-_temp
}
C {devices/lab_wire.sym} -740 230 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -740 370 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -690 400 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -690 480 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -150 10 0 0 {name=p14 sig_type=std_logic lab=vbias
}
C {devices/vsource.sym} -1200 180 0 0 {name=V8 value="PULSE(1.8 0 0 20p 20p 0.98n 2n)" savecurrent=false}
C {devices/gnd.sym} -1200 210 0 0 {name=l6 lab=GND}
C {devices/lab_wire.sym} -1200 150 0 0 {name=p2 sig_type=std_logic lab=clk-
}
C {devices/vsource.sym} -1330 40 0 0 {name=V9 value="PULSE(0 1.8 0 20p 20p 0.98n 2n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -1330 70 0 0 {name=l7 lab=GND}
C {devices/lab_wire.sym} -1330 -10 0 0 {name=p7 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 490 -140 0 0 {name=p9 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 490 -160 0 0 {name=p15 sig_type=std_logic lab=clk-
}
C {d_latch.sym} 710 80 0 0 {name=x3}
C {devices/lab_wire.sym} 920 130 0 0 {name=p27 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 860 140 0 0 {name=p30 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 560 120 0 0 {name=p81 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 510 80 0 0 {name=p98 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 520 100 0 0 {name=p99 sig_type=std_logic lab=clk-
}
C {devices/lab_wire.sym} 570 -120 0 0 {name=p16 sig_type=std_logic lab=vbias
}
C {d_latch.sym} 720 -160 0 0 {name=x4}
C {devices/lab_wire.sym} 930 -110 0 0 {name=p19 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 870 -100 0 0 {name=p20 sig_type=std_logic lab=Vss
}
C {D2S_amp.sym} 1650 -220 0 0 {name=x2}
C {D2S_amp.sym} 1130 20 0 0 {name=x5}
C {devices/lab_wire.sym} 980 0 0 0 {name=p22 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 1500 -240 0 0 {name=p25 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 1340 70 0 0 {name=p26 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1280 80 0 0 {name=p31 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1860 -170 0 0 {name=p33 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1800 -160 0 0 {name=p34 sig_type=std_logic lab=Vss
}
C {inverter_chain.sym} 2050 -220 0 0 {name=x6}
C {inverter_chain.sym} 1530 20 0 0 {name=x7}
C {devices/lab_wire.sym} 2210 -270 0 0 {name=p32 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 2240 -270 0 0 {name=p36 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1690 -30 0 0 {name=p37 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1720 -30 0 0 {name=p38 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 930 -280 0 0 {name=p39 sig_type=std_logic lab=v0t
}
C {devices/lab_wire.sym} 890 0 0 0 {name=p40 sig_type=std_logic lab=v1t
}
C {devices/lab_wire.sym} 1060 -120 0 0 {name=p41 sig_type=std_logic lab=vbias
}
C {d_latch.sym} 1210 -160 0 0 {name=x8}
C {devices/lab_wire.sym} 1420 -110 0 0 {name=p42 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1360 -100 0 0 {name=p43 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 980 -160 0 0 {name=p45 sig_type=std_logic lab=clk+
}
C {devices/lab_wire.sym} 980 -140 0 0 {name=p46 sig_type=std_logic lab=clk-
}
C {devices/opin.sym} 2200 -200 0 0 {name=p23 lab=vout1}
C {devices/opin.sym} 1680 40 0 0 {name=p35 lab=vout0}
