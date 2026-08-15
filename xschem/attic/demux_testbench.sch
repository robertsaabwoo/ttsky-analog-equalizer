v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -390 0 -390 20 {
lab=clk}
N -390 20 -390 40 {
lab=clk}
N -370 180 -370 200 {
lab=vin}
N -370 200 -370 220 {
lab=vin}
C {devices/simulator_commands_shown.sym} -650 -220 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice

.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 10n
  write demux.raw
.endc
"}
C {devices/vsource.sym} -390 70 0 0 {name=V2 value=PULSE(0 1.8 0 20p 20p 0.98n 2n) savecurrent=false
lab=vin+}
C {devices/gnd.sym} -390 100 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -390 0 0 0 {name=p3 sig_type=std_logic lab=clk
}
C {devices/vsource.sym} -370 250 0 0 {name=V4 value="PWL(0 0 20p 1.8 2n 1.8 2.02n 0 3n 0 3.02n 1.8 4n 1.8 4.02n 0)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -370 280 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -370 180 0 0 {name=p2 sig_type=std_logic lab=vin
}
C {/home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice} -730 70 0 0 {}
