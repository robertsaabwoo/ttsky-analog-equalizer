v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 90 -580 890 -180 {flags=graph
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
N -880 -220 -880 -200 {
lab=clk}
N -880 -200 -880 -180 {
lab=clk}
N -860 -40 -860 -20 {
lab=vin}
N -860 -20 -860 0 {
lab=vin}
N -350 -100 -310 -100 {
lab=clk}
N -310 -120 -220 -120 {
lab=clk}
N -310 -120 -310 -100 {
lab=clk}
N -310 -100 -310 0 {
lab=clk}
N -310 0 -220 0 {
lab=clk}
N -300 -160 -220 -160 {
lab=vin}
N -270 -160 -270 -40 {
lab=vin}
N -270 -40 -220 -40 {
lab=vin}
N -100 -160 -20 -160 {
lab=vout0}
N -100 -40 -30 -40 {
lab=vout1}
C {stdcells/LATCH.sym} -160 -140 0 0 {name=x5 VCCPIN=VCC VSSPIN=VSS VCCBPIN=VCC VSSBPIN=VSS}
C {stdcells/LATCHI.sym} -160 -20 0 0 {name=x6 VCCPIN=VCC VSSPIN=VSS VCCBPIN=VCC VSSBPIN=VSS}
C {devices/simulator_commands_shown.sym} -1140 -440 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
*.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
*.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice

.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 10n
  write demux.raw
.endc
"}
C {devices/vsource.sym} -880 -150 0 0 {name=V2 value="PULSE(0 1.8 0 20p 20p 0.48n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -880 -120 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -880 -220 0 0 {name=p3 sig_type=std_logic lab=clk
}
C {devices/vsource.sym} -860 30 0 0 {name=V4 value="PWL(0 0 20p 1.8 2n 1.8 2.02n 0 3n 0 3.02n 1.8 4n 1.8 4.02n 0)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -860 60 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -860 -40 0 0 {name=p2 sig_type=std_logic lab=vin
}
C {devices/lab_wire.sym} -350 -100 0 0 {name=p4 sig_type=std_logic lab=clk
}
C {devices/lab_wire.sym} -300 -160 0 0 {name=p6 sig_type=std_logic lab=vin
}
C {devices/lab_wire.sym} -20 -160 0 1 {name=p7 sig_type=std_logic lab=vout0
}
C {devices/lab_wire.sym} -30 -40 0 1 {name=p8 sig_type=std_logic lab=vout1
}
C {/home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice} -1220 -150 0 0 {}
C {devices/code.sym} -180 -490 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt

"
spice_ignore=false}
C {devices/launcher.sym} -200 -330 0 0 {name=h17 
descr="Load waves" 
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw tran

"
}
