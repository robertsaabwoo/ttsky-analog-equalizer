v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
C {devices/vsource.sym} -800 0 0 0 {name=VDD value=1.8 savecurrent=false}
C {devices/gnd.sym} -800 30 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -800 -30 0 0 {name=p1 sig_type=std_logic lab=Vdd}
C {devices/vsource.sym} -700 0 0 0 {name=VSSS value=0 savecurrent=false}
C {devices/gnd.sym} -700 30 0 0 {name=l2 lab=GND}
C {devices/lab_wire.sym} -700 -30 0 0 {name=p2 sig_type=std_logic lab=Vss}
C {devices/vsource.sym} -600 0 0 0 {name=VB value=0.9 savecurrent=false}
C {devices/gnd.sym} -600 30 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -600 -30 0 0 {name=p3 sig_type=std_logic lab=vbias}
C {devices/vsource.sym} -500 0 0 0 {name=VSP value="dc 0.9 ac 0.5 0" savecurrent=false}
C {devices/gnd.sym} -500 30 0 0 {name=l4 lab=GND}
C {devices/lab_wire.sym} -500 -30 0 0 {name=p4 sig_type=std_logic lab=srcp}
C {devices/vsource.sym} -400 0 0 0 {name=VSM value="dc 0.9 ac 0.5 180" savecurrent=false}
C {devices/gnd.sym} -400 30 0 0 {name=l5 lab=GND}
C {devices/lab_wire.sym} -400 -30 0 0 {name=p5 sig_type=std_logic lab=srcm}
C {devices/res.sym} -300 -110 1 0 {name=RCHP value=500 m=1}
C {devices/lab_wire.sym} -330 -110 0 0 {name=p6 sig_type=std_logic lab=srcp}
C {devices/lab_wire.sym} -270 -110 0 0 {name=p7 sig_type=std_logic lab=vinp}
C {devices/res.sym} -300 -50 1 0 {name=RCHM value=500 m=1}
C {devices/lab_wire.sym} -330 -50 0 0 {name=p8 sig_type=std_logic lab=srcm}
C {devices/lab_wire.sym} -270 -50 0 0 {name=p9 sig_type=std_logic lab=vinm}
C {devices/capa.sym} -200 -140 0 0 {name=CCHP value=1p m=1}
C {devices/lab_wire.sym} -200 -170 0 0 {name=p10 sig_type=std_logic lab=vinp}
C {devices/lab_wire.sym} -200 -110 0 0 {name=p11 sig_type=std_logic lab=Vss}
C {devices/capa.sym} -140 -140 0 0 {name=CCHM value=1p m=1}
C {devices/lab_wire.sym} -140 -170 0 0 {name=p12 sig_type=std_logic lab=vinm}
C {devices/lab_wire.sym} -140 -110 0 0 {name=p13 sig_type=std_logic lab=Vss}
C {CTLE_tune.sym} 100 0 0 0 {name=x1}
C {devices/lab_wire.sym} -50 -30 0 0 {name=p14 sig_type=std_logic lab=vinp}
C {devices/lab_wire.sym} -50 -10 0 0 {name=p15 sig_type=std_logic lab=vinm}
C {devices/lab_wire.sym} -50 10 0 0 {name=p16 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 250 -30 0 1 {name=p17 sig_type=std_logic lab=voutp}
C {devices/lab_wire.sym} 250 -10 0 1 {name=p18 sig_type=std_logic lab=voutm}
C {devices/lab_wire.sym} 250 10 0 1 {name=p19 sig_type=std_logic lab=Vdd}
C {devices/lab_wire.sym} 250 30 0 1 {name=p20 sig_type=std_logic lab=Vss}
C {devices/capa.sym} 350 -140 0 0 {name=CLP value=50f m=1}
C {devices/lab_wire.sym} 350 -170 0 0 {name=p21 sig_type=std_logic lab=voutp}
C {devices/lab_wire.sym} 350 -110 0 0 {name=p22 sig_type=std_logic lab=Vss}
C {devices/capa.sym} 420 -140 0 0 {name=CLM value=50f m=1}
C {devices/lab_wire.sym} 420 -170 0 0 {name=p23 sig_type=std_logic lab=voutm}
C {devices/lab_wire.sym} 420 -110 0 0 {name=p24 sig_type=std_logic lab=Vss}
C {devices/simulator_commands_shown.sym} -800 -400 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.options method=gear reltol=1e-4 abstol=1e-13 vntol=1e-7
.control
  op
  print v(voutp) v(voutm) v(x1.net1) v(x1.net2) v(x1.sdegm)
  ac dec 60 1e5 3e10
  let gdb  = db(v(voutp)-v(voutm))
  let gind = db(v(vinp)-v(vinm))
  wrdata tmp.dat gdb gind
  shell echo \\"#PT CTLE_tune_tb netlisted\\"
  shell cat tmp.dat
  shell rm -f tmp.dat
.endc
"}
