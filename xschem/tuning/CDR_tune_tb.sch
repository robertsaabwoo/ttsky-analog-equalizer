v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
B 2 -400 -1180 800 -960 {flags=graph
y1=0.6
y2=0.9
ypos1=0
ypos2=2
divy=6
subdivy=1
unity=1
x1=0
x2=1.5e-6
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="vctrl"
color=4
dataset=-1
unitx=1
logx=0
logy=0
rainbow=0
}
B 2 -400 -940 800 -720 {flags=graph
y1=-0.2
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=300e-9
divx=6
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="prech
nbias
vctrl"
color="4 6 7"
dataset=-1
unitx=1
logx=0
logy=0
rainbow=0
}
B 2 -400 -700 800 -480 {flags=graph
y1=-0.2
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=1.4e-6
x2=1.41e-6
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
node="clkp
datap"
color="4 6"
dataset=-1
unitx=1
logx=0
logy=0
rainbow=0
}
T {Graph 1: vctrl over the whole run -- precharge hold (~0.80 V) -> release
at ~127 ns -> loop pulls to its own lock point 0.792 V.
y range is 0.6..0.9 on purpose; the locked bang-bang dither is ~45 mV pk-pk,
which is invisible on a 0..1.8 V scale.  Measured: vctrl_lock 0.7920 V.} -400 -1210 0 0 0.4 0.4 {}
T {Graph 2: the precharge one-shot itself (first 300 ns).
prech goes 1.8 -> 0 at t_release; nbias is the ~0.79 V seed; vctrl follows it.} -400 -970 0 0 0.4 0.4 {}
T {Graph 3: recovered clock + data, ZOOMED to a 10 ns window.
clkp must be rail-to-rail here.  Over the full 1.5 us this is ~900 cycles and
renders as a solid band -- which is the other way to mistakenly read "no swing".} -400 -730 0 0 0.4 0.4 {}
N -190 70 -160 70 {
lab=vin+}
N -190 90 -160 90 {
lab=#net1}
N -320 -130 -300 -130 {
lab=vbias}
N -300 -70 -300 -20 {
lab=Vss}
N -300 -180 -300 -130 {
lab=vbias}
N -300 -230 -300 -180 {
lab=vbias}
N -350 -230 -300 -230 {
lab=vbias}
N -350 -270 -350 -230 {
lab=vbias}
N -390 -130 -380 -130 {
lab=#net2}
N -390 -130 -390 -110 {
lab=#net2}
N -160 90 -120 90 {
lab=#net1}
N -160 70 -80 70 {
lab=vin+}
N -120 90 -80 90 {
lab=#net1}
N -70 230 200 230 {
lab=#net1}
N -70 90 -70 230 {
lab=#net1}
N -80 90 -70 90 {
lab=#net1}
N 90 190 200 190 {
lab=vin+}
N 90 70 90 190 {
lab=vin+}
N -80 70 90 70 {
lab=vin+}
N -350 75 -190 75 {
lab=vin+}
N -190 70 -190 75 {
lab=vin+}
N -65 30 -65 70 {
lab=vin+}
N 200 230 220 230 {
lab=#net1}
N 200 190 200 200 {
lab=vin+}
N 200 200 300 200 {
lab=vin+}
N 220 220 300 220 {
lab=#net1}
N 220 220 220 230 {
lab=#net1}
N 270 270 300 270 {
lab=vbias}
N 300 240 300 270 {
lab=vbias}
N 600 200 630 200 {
lab=Vdd}
N 630 190 630 200 {
lab=Vdd}
N 600 220 670 220 {
lab=Vss}
N 670 200 670 220 {
lab=Vss}
C {devices/vsource.sym} -560 -520 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -560 -490 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -560 -550 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -470 -520 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -470 -490 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -470 -550 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} 60 -220 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
* ---------------------------------------------------------------------------
* Plain-named copies of the two signals whose real names contain a '+'.
* `let clkp = v(clk+)` does NOT work: ngspice's expression parser reads the '+'
* as an operator and the assignment silently produces nothing (the vector just
* never appears in the .raw).  A unity VCVS sidesteps it -- a netlist line is
* plain tokens, no expression parsing -- and an ideal VCVS has infinite input
* impedance, so it cannot load the node it copies.
* ---------------------------------------------------------------------------
Eclkp  clkp  0 clk+ 0 1
Edatap datap 0 vin+ 0 1
* ---------------------------------------------------------------------------
* The startup precharge (x20) needs this ONE initial condition to work.
* .op treats a capacitor as an OPEN, so without it the POR node nrc solves to
* Vdd, `pre` sits at 0, the one-shot never fires and the cell is completely
* inert -- vctrl then seeds at ~0.663 V, right on the VCO dead-zone cliff.
* This is NOT a seed on vctrl: it just says the POR cap is discharged at
* power-up, which is physically true.  (See NOTES.md 17e.)
* ---------------------------------------------------------------------------
.ic v(x1.x20.nrc)=0
.op
.control
* `save` keeps the .raw small.  The bare `write` stored EVERY node of the whole
* CDR for 75000 timepoints, which is what OOM-crashed the VM.  Add nodes here
* if you want to probe something else.
  save v(x1.net1) v(clk+) v(clkp) v(datap) v(x1.x20.pre) v(x1.x20.nbias) v(x1.x20.nrc)
  tran 20p 1500n
* Hierarchical nodes are safe to alias with `let` (no '+' in the name); clkp and
* datap already exist as real nodes, courtesy of the two VCVS above.
  let vctrl = v(x1.net1)
  let prech = v(x1.x20.pre)
  let nbias = v(x1.x20.nbias)
  write CDR_tune_tb.raw
* --- numeric summary, printed in the ngspice log ---
  meas tran vctrl_lock AVG v(x1.net1) FROM=1300n TO=1400n
  meas tran vctrl_ripp PP  v(x1.net1) FROM=1300n TO=1400n
  meas tran clk_swing  PP  v(clk+)    FROM=1300n TO=1400n
  meas tran t_release  WHEN v(x1.x20.pre)=0.9 FALL=1
  meas tran c600 WHEN v(clk+)=0.9 RISE=600
  meas tran c660 WHEN v(clk+)=0.9 RISE=660
  let f_MHz = 60/(c660-c600)/1e6
  print f_MHz
.endc
"}
C {devices/launcher.sym} -560 -1100 0 0 {name=h_load
descr="Load waves"
tclcommand="
xschem raw_read $netlist_dir/[file tail [file rootname [xschem get current_name]]].raw tran
"
}
C {devices/vsource.sym} -350 105 0 0 {name=V2 value="PULSE(0 1.8 0 10p 10p 1.67n 3.33n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -350 135 0 0 {name=l2 lab=GND}
C {devices/vsource.sym} -190 120 0 0 {name=V4 value="PULSE(1.8 0 0 10p 10p 1.67n 3.33n)" savecurrent=false}
C {devices/gnd.sym} -190 150 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} -390 -80 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -390 -50 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -350 -270 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -350 -130 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -300 -100 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -300 -20 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {devices/opin.sym} 600 260 0 0 {name=p17 lab=clk-}
C {devices/opin.sym} 600 240 0 0 {name=p32 lab=clk+}
C {devices/lab_wire.sym} -65 30 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {CDR_tune.sym} 450 230 0 0 {name=x1}
C {devices/lab_wire.sym} 270 270 0 0 {name=p2 sig_type=std_logic lab=vbias
}
C {devices/lab_wire.sym} 630 190 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 670 200 0 0 {name=p4 sig_type=std_logic lab=Vss
}
