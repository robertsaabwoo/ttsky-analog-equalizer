v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 80 -780 880 -380 {flags=graph
y1=-0.23
y2=2.1
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vin+
vin-
vin+_bad
vin-_bad"
color="12 12 6 7"
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 940 -790 1740 -390 {flags=graph
y1=-0.23
y2=2.1
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0


dataset=-1
unitx=1
logx=0
logy=0
color="7 6 12"
node="vout-_temp
vout+_temp
d2s_probe"}
B 2 1760 -780 2560 -380 {flags=graph
y1=0
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=2e-08
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vout
d2s_probe"
color="13 12"
dataset=-1
unitx=1
logx=0
logy=0
}
N 930 -120 960 -120 {
lab=vout+_temp}
N 930 -100 960 -100 {
lab=vout-_temp}
N 420 -120 450 -120 {
lab=vin+_bad}
N 450 -120 520 -120 {
lab=vin+_bad}
N 450 -50 470 -50 {
lab=vin-_bad}
N 520 -120 630 -120 {
lab=vin+_bad}
N 470 10 470 60 {
lab=Vss}
N 470 -100 470 -50 {
lab=vin-_bad}
N 470 -100 630 -100 {
lab=vin-_bad}
N 630 -80 630 -70 {
lab=vbias}
N 930 -80 990 -80 {
lab=Vdd}
N 990 -80 990 -30 {
lab=Vdd}
N 930 -60 930 -20 {
lab=Vss}
N 520 -100 520 30 {
lab=vin-_bad}
N 560 -150 560 -120 {
lab=vin+_bad}
N 10 -280 10 -260 {
lab=vin+}
N 10 -200 10 -180 {
lab=#net1}
N 630 -70 630 -30 {
lab=vbias}
N 960 -160 960 -120 {
lab=vout+_temp}
N 1000 -100 1000 60 {
lab=vout-_temp}
N 960 -120 1090 -120 {
lab=vout+_temp}
N 70 250 90 250 {
lab=vbias}
N 90 310 90 360 {
lab=Vss}
N 90 200 90 250 {
lab=vbias}
N 90 150 90 200 {
lab=vbias}
N 40 150 90 150 {
lab=vbias}
N 40 110 40 150 {
lab=vbias}
N 0 250 10 250 {
lab=#net2}
N 0 250 0 270 {
lab=#net2}
N 1450 -120 1500 -120 {
lab=d2s_probe}
N 1850 -120 1910 -120 {
lab=Vdd}
N 1910 -120 1910 -70 {
lab=Vdd}
N 1850 -100 1850 -60 {
lab=Vss}
N 1800 -120 1850 -120 {
lab=Vdd}
N 1800 -100 1850 -100 {
lab=Vss}
N 1800 -80 1800 -50 {
lab=vout}
N 1800 10 1800 50 {
lab=Vss}
N 1790 50 1800 50 {
lab=Vss}
N 1700 -10 1730 -10 {
lab=vout}
N 1730 -50 1730 -10 {
lab=vout}
N 1730 -60 1730 -50 {
lab=vout}
N 1730 -60 1800 -60 {
lab=vout}
N 1090 -80 1150 -80 {
lab=vout+_temp}
N 1090 -120 1090 -80 {
lab=vout+_temp}
N 960 -100 1150 -100 {
lab=vout-_temp}
N 1140 -170 1140 -120 {
lab=vbias}
N 1140 -120 1150 -120 {
lab=vbias}
N 1450 -100 1510 -100 {
lab=Vdd}
N 1510 -100 1510 -50 {
lab=Vdd}
N 1480 -80 1480 -40 {
lab=Vss}
N 1450 -80 1480 -80 {
lab=Vss}
N 1480 -180 1480 -120 {
lab=d2s_probe}
N 1800 -50 1860 -50 {
lab=vout}
N 1860 10 1860 30 {
lab=Vss}
N 1800 30 1860 30 {
lab=Vss}
N 1500 -140 1500 -120 {
lab=d2s_probe}
C {devices/vsource.sym} -170 -60 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -170 -30 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -170 -90 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -80 -60 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -80 -30 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -80 -90 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/res.sym} 390 -120 1 0 {name=R1
value=500
footprint=1206
device=resistor
m=1}
C {devices/res.sym} 420 -50 1 0 {name=R2
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} 450 -150 0 0 {name=C1
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/capa.sym} 470 -20 0 0 {name=C2
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} 450 -180 0 0 {name=p10 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 470 60 0 0 {name=p11 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -1040 -440 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
*.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  save all
  tran 10p 20n
  write CTLE_testbench.raw
.endc
"}
C {devices/vsource.sym} 10 -150 0 0 {name=V2 value="PULSE(0 1.8 0 50p 50p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} 10 -120 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} 10 -280 0 0 {name=p3 sig_type=std_logic lab=vin+
}
C {devices/vsource.sym} 120 20 0 0 {name=V4 value="PULSE(1.8 0 0 50p 50p 0.5n 1n)" savecurrent=false}
C {devices/gnd.sym} 120 50 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} 120 -70 0 0 {name=p6 sig_type=std_logic lab=vin-
}
C {devices/lab_wire.sym} 360 -120 0 0 {name=p12 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 390 -50 0 0 {name=p13 sig_type=std_logic lab=vin-
}
C {devices/vsource.sym} 0 300 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} 0 330 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} 990 -30 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 930 -20 0 0 {name=p8 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 560 -150 0 0 {name=p17 sig_type=std_logic lab=vin+_bad
}
C {devices/lab_wire.sym} 520 30 0 0 {name=p18 sig_type=std_logic lab=vin-_bad
}
C {devices/vsource.sym} 10 -230 0 0 {name=V6 value="TRNOISE(100m 50p 0 0)" savecurrent=false
lab=vin+}
C {devices/vsource.sym} 120 -40 0 0 {name=V7 value="TRNOISE(100m 50p 0 0)" savecurrent=false
lab=vin+}
C {CTLE.sym} 780 -90 0 0 {name=x1}
C {devices/lab_wire.sym} 960 -160 0 1 {name=p21 sig_type=std_logic lab=vout+_temp
}
C {devices/lab_wire.sym} 1000 60 0 1 {name=p24 sig_type=std_logic lab=vout-_temp
}
C {devices/lab_wire.sym} 40 110 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} 40 250 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} 90 280 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} 90 360 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 630 -30 0 0 {name=p14 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 1910 -70 0 0 {name=p2 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1850 -60 0 0 {name=p7 sig_type=std_logic lab=Vss
}
C {devices/res.sym} 1800 -20 0 0 {name=R3
value=500
footprint=1206
device=resistor
m=1}
C {devices/lab_wire.sym} 1790 50 0 0 {name=p9 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1700 -10 0 0 {name=p15 sig_type=std_logic lab=vout
}
C {D2S_amp.sym} 1300 -100 0 0 {name=x3}
C {devices/lab_wire.sym} 1140 -170 0 0 {name=p16 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 1510 -50 0 0 {name=p19 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1480 -40 0 0 {name=p20 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1480 -180 0 0 {name=p22 sig_type=std_logic lab=d2s_probe
}
C {inverter_chain.sym} 1650 -100 0 0 {name=x2}
C {devices/code.sym} -1010 -730 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt

"
spice_ignore=false}
C {devices/launcher.sym} -1030 -570 0 0 {name=h17 
descr="Load waves" 
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw tran

"
}
C {devices/capa.sym} 1860 -20 0 0 {name=C3
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
