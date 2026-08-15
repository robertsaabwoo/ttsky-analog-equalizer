v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 -70 -880 730 -480 {flags=graph
y1=0
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=10e-6
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node=""
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
N -230 -240 -110 -240 {
lab=OUT}
N -110 -250 -110 -240 {
lab=OUT}
N -50 -250 10 -250 {
lab=ACTUAL_OUT}
N 10 -250 90 -250 {
lab=ACTUAL_OUT}
C {devices/code.sym} -910 -590 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt

"
spice_ignore=false}
C {devices/launcher.sym} -920 -350 0 0 {name=h17 
descr="Load waves" 
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw tran

"
}
C {double_inverter.sym} -380 -260 0 0 {name=x1}
C {devices/vsource.sym} -510 -460 0 0 {name=V1 value=1.8 savecurrent=false}
C {devices/lab_wire.sym} -510 -490 0 0 {name=p1 sig_type=std_logic lab=VDD
}
C {devices/gnd.sym} -510 -430 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -230 -280 0 1 {name=p6 sig_type=std_logic lab=VDD
}
C {devices/lab_wire.sym} -230 -260 0 1 {name=p7 sig_type=std_logic lab=VSS
}
C {devices/lab_wire.sym} -230 -240 0 1 {name=p8 sig_type=std_logic lab=OUT
}
C {devices/vsource.sym} -300 -470 0 0 {name=V2 value=0 savecurrent=false}
C {devices/gnd.sym} -300 -440 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -300 -500 0 0 {name=p2 sig_type=std_logic lab=VSS
}
C {devices/res.sym} -80 -250 1 0 {name=R1
value=1k
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} 10 -220 0 0 {name=C1
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/gnd.sym} 10 -190 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} 90 -250 0 1 {name=p3 sig_type=std_logic lab=ACTUAL_OUT
}
C {devices/simulator_commands_shown.sym} -770 -230 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.control

tran 100n 200n

write testbench.raw

.endc
"}
C {devices/ipin.sym} -530 -280 0 0 {name=p4 lab=IN}
