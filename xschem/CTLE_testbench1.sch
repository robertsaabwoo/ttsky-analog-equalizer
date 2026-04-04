v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 0 170 800 570 {flags=graph
y1=0
y2=1.8
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-1.5e-09
x2=2.85e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vin-_bad
vin+_bad
vin+
vin-"
color="4 5 12 6"
dataset=-1
unitx=1
logx=0
logy=0
hilight_wave=-1
sim_type=tran}
B 2 860 170 1660 570 {flags=graph
y1=3.5e-14
y2=1.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-1.5e-09
x2=2.85e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0


dataset=-1
unitx=1
logx=0
logy=0
color="4 5 6 8"
node="vin+_bad
vin-_bad
vout+
vout-"}
B 2 830 670 1630 1070 {flags=graph
y1=-1.9e-11
y2=1.9
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-1.5e-09
x2=2.85e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0


dataset=-1
unitx=1
logx=0
logy=0
color="4 5"
node="vin+_bad
vout+"}
N -430 390 -410 390 {
lab=vbias}
N -410 450 -410 500 {
lab=Vss}
N -500 390 -490 390 {
lab=#net1}
N -500 390 -500 410 {
lab=#net1}
N -410 390 -330 390 {
lab=vbias}
N -650 140 -650 160 {
lab=vin+}
N -90 -20 -70 -20 {
lab=vin+_bad}
N -90 0 -70 0 {
lab=vin-_bad}
N -90 20 -70 20 {
lab=vbias}
N 230 -20 290 -20 {
lab=vout+}
N 230 0 290 0 {
lab=vout-}
N 230 20 250 20 {
lab=Vdd}
N 230 40 250 40 {
lab=Vss}
N -610 -50 -580 -50 {
lab=vin+}
N -490 90 -490 100 {
lab=vin-_bad}
N -520 100 -490 100 {
lab=vin-_bad}
N -610 100 -580 100 {
lab=vin-}
N -490 10 -490 40 {
lab=GND}
N -490 20 -450 20 {
lab=GND}
N -490 100 -450 100 {
lab=vin-_bad}
N -490 -60 -490 -50 {
lab=vin+_bad}
N -490 -60 -450 -60 {
lab=vin+_bad}
N -520 -60 -490 -60 {
lab=vin+_bad}
N -520 -60 -520 -50 {
lab=vin+_bad}
N -670 260 -670 270 {
lab=vin-}
N -160 740 -120 740 {
lab=vbias}
N 180 740 200 740 {
lab=Vdd}
N 180 760 200 760 {
lab=Vss}
N 180 700 240 700 {
lab=vout1+}
N 180 720 240 720 {
lab=vout1-}
N -520 780 -490 780 {
lab=vin1+}
N -400 920 -400 930 {
lab=vin1-_bad}
N -430 930 -400 930 {
lab=vin1-_bad}
N -520 930 -490 930 {
lab=vin1-}
N -400 840 -400 870 {
lab=GND}
N -400 850 -360 850 {
lab=GND}
N -400 930 -360 930 {
lab=vin1-_bad}
N -400 770 -400 780 {
lab=vin1+_bad}
N -400 770 -360 770 {
lab=vin1+_bad}
N -430 770 -400 770 {
lab=vin1+_bad}
N -430 770 -430 780 {
lab=vin1+_bad}
C {CTLE.sym} 80 10 0 0 {name=x1}
C {devices/vsource.sym} -660 440 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -660 470 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -660 410 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -570 440 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -570 470 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -570 410 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/vsource.sym} -500 440 0 0 {name=V5 value=0.95 savecurrent=false}
C {devices/gnd.sym} -500 470 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -330 390 2 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -460 390 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -410 420 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -410 500 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/vsource.sym} -650 190 0 0 {name=V2 value="DC 0.9 PWL(0 1.8 5n 1.8 8.33333n 1.8 8.38333n 0 10n 0 10.05n 1.8 13.3333n 1.8 13.3833n 0 16.6667n 0) AC 1" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -650 220 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -650 150 0 0 {name=p3 sig_type=std_logic lab=vin+
}
C {devices/vsource.sym} -670 300 0 0 {name=V4 value="DC 0.9 PWL(0 0 5n 0 8.33333n 0 8.38333n 1.8 10n 1.8 10.05n 0 13.3333n 0 13.3833n 1.8 16.6667n 1.8) AC 1 180" savecurrent=false}
C {devices/gnd.sym} -670 330 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -670 270 0 0 {name=p6 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} -90 20 0 0 {name=p2 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} -610 100 0 0 {name=p4 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} -610 -50 0 0 {name=p7 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 250 20 2 0 {name=p8 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 250 40 2 0 {name=p9 sig_type=std_logic lab=Vss
}
C {devices/res.sym} -550 -50 3 0 {name=R1
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -490 -20 0 0 {name=C1
m=1
value=5p
footprint=1206
device="ceramic capacitor"}
C {devices/res.sym} -550 100 3 0 {name=R2
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -490 60 2 0 {name=C2
m=1
value=5p
footprint=1206
device="ceramic capacitor"}
C {devices/gnd.sym} -450 20 3 0 {name=l6 lab=GND}
C {devices/lab_wire.sym} -450 -60 2 0 {name=p17 sig_type=std_logic lab=vin+_bad
}
C {devices/lab_wire.sym} -450 100 2 0 {name=p18 sig_type=std_logic lab=vin-_bad
}
C {devices/lab_wire.sym} -90 -20 0 0 {name=p10 sig_type=std_logic lab=vin+_bad
}
C {devices/lab_wire.sym} -90 0 0 0 {name=p11 sig_type=std_logic lab=vin-_bad
}
C {devices/simulator_commands_shown.sym} 460 -680 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
*.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=0.001 abstol=1e-12
*.options savecurrents

.param c0=10

.control
save all
set appendwrite

op
write CTLE_testbench1.raw

tran 10p 30n
write CTLE_testbench1.raw

ac dec 20 1 1e11
write CTLE_testbench1.raw
plot db(v(vout1+))
plot db(v(vin+_bad)) db(v(vout+)/v(vin+_bad)) db(v(vout+))
plot db(v(vin-_bad)) db(v(vout-)/v(vin-_bad)) db(v(vout-))

*foreach val 0.7 0.8 0.9 1 1.1 1.2 1.3

*alterparam c0 = $val
*reset
*alter v5 = $val

*tran 10p 20n
*ac dec 20 1 1e11
*write CTLE_testbench1.raw

*end

*plot tran1.v(vout+) tran2.v(vout+) tran3.v(vout+) tran4.v(vout+) tran5.v(vout+) tran6.v(vout+) tran7.v(vout+)
*plot tran1.v(vout-) tran2.v(vout-) tran3.v(vout-) tran4.v(vout-) tran5.v(vout-) tran6.v(vout-) tran7.v(vout-)
*plot db(v(vin+_bad)) db(ac1.v(vout1+)) db(ac2.v(vout1+)) db(ac3.v(vout1+)) db(ac4.v(vout1+)) db(ac5.v(vout1+)) db(ac6.v(vout1+)) db(ac7.v(vout1+))
*plot db(v(vin-_bad)) db(ac1.v(vout+)) db(ac2.v(vout+)) db(ac3.v(vout+))  db(ac4.v(vout+)) db(ac5.v(vout+)) db(ac6.v(vout+)) db(ac7.v(vout+))

.endc
"}
C {devices/code.sym} -180 330 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt

"
spice_ignore=false}
C {devices/launcher.sym} -200 490 0 0 {name=h17 
descr="Load waves" 
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw tran

"
}
C {devices/lab_wire.sym} 290 -20 2 0 {name=p12 sig_type=std_logic lab=vout+
}
C {devices/lab_wire.sym} 290 0 2 0 {name=p13 sig_type=std_logic lab=vout-
}
C {CTLE.sym} 30 730 0 0 {name=x2}
C {devices/lab_wire.sym} -160 740 0 0 {name=p14 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 200 740 2 0 {name=p15 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 200 760 2 0 {name=p16 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 240 700 2 0 {name=p19 sig_type=std_logic lab=vout1+
}
C {devices/lab_wire.sym} 240 720 2 0 {name=p20 sig_type=std_logic lab=vout1-
}
C {devices/vsource.sym} -610 660 0 0 {name=V8 value="0.9 AC 1" savecurrent=false
lab=vin1-}
C {devices/lab_wire.sym} -610 630 0 0 {name=p21 sig_type=std_logic lab=vin1+

}
C {devices/vsource.sym} -460 660 0 0 {name=V9 value="0.9 AC 1 180" savecurrent=false
lab=vin1-}
C {devices/lab_wire.sym} -460 630 0 0 {name=p22 sig_type=std_logic lab=vin1-
}
C {devices/gnd.sym} -610 690 0 0 {name=l8 lab=GND}
C {devices/gnd.sym} -460 690 0 0 {name=l9 lab=GND}
C {devices/lab_wire.sym} -520 930 0 0 {name=p25 sig_type=std_logic lab=vin1-
}
C {devices/lab_wire.sym} -520 780 0 0 {name=p26 sig_type=std_logic lab=vin1+
}
C {devices/res.sym} -460 780 3 0 {name=R3
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -400 810 0 0 {name=C3
m=1
value=5p
footprint=1206
device="ceramic capacitor"}
C {devices/res.sym} -460 930 3 0 {name=R4
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -400 890 2 0 {name=C4
m=1
value=5p
footprint=1206
device="ceramic capacitor"}
C {devices/gnd.sym} -360 850 3 0 {name=l10 lab=GND}
C {devices/lab_wire.sym} -360 770 2 0 {name=p27 sig_type=std_logic lab=vin1+_bad
}
C {devices/lab_wire.sym} -360 930 2 0 {name=p30 sig_type=std_logic lab=vin1-_bad
}
C {devices/lab_wire.sym} -120 700 0 0 {name=p23 sig_type=std_logic lab=vin1+

}
C {devices/lab_wire.sym} -120 720 0 0 {name=p24 sig_type=std_logic lab=vin1-
}
C {devices/launcher.sym} -200 530 0 0 {name=h1
descr="Annotate OP" 
tclcommand="set show_hidden_texts 1; xschem annotate_op"
}
