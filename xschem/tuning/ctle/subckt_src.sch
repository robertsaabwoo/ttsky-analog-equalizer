v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {Netlist-source schematic only.  It exists so that xschem emits .subckt
definitions for CTLE_tune, LA_Limiter and D2S_amp that the hand-written
chain decks can .include.  Not a testbench - do not simulate it.} -400 -300 0 0 0.4 0.4 {}
C {CTLE_tune.sym} 0 0 0 0 {name=x1}
C {devices/lab_wire.sym} -150 -30 0 0 {name=p1 sig_type=std_logic lab=vinp}
C {devices/lab_wire.sym} -150 -10 0 0 {name=p2 sig_type=std_logic lab=vinm}
C {devices/lab_wire.sym} -150 10 0 0 {name=p3 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 150 -30 0 1 {name=p4 sig_type=std_logic lab=coutp}
C {devices/lab_wire.sym} 150 -10 0 1 {name=p5 sig_type=std_logic lab=coutm}
C {devices/lab_wire.sym} 150 10 0 1 {name=p6 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 150 30 0 1 {name=p7 sig_type=std_logic lab=VSS}
C {LA_Limiter.sym} 600 0 0 0 {name=x2}
C {devices/lab_wire.sym} 450 -30 0 0 {name=p8 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 450 -10 0 0 {name=p9 sig_type=std_logic lab=coutp}
C {devices/lab_wire.sym} 450 10 0 0 {name=p10 sig_type=std_logic lab=coutm}
C {devices/lab_wire.sym} 750 -30 0 1 {name=p11 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 750 -10 0 1 {name=p12 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 750 10 0 1 {name=p13 sig_type=std_logic lab=laoutm}
C {devices/lab_wire.sym} 750 30 0 1 {name=p14 sig_type=std_logic lab=laoutp}
C {D2S_amp.sym} 600 200 0 0 {name=x3}
C {devices/lab_wire.sym} 450 180 0 0 {name=p15 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 450 200 0 0 {name=p16 sig_type=std_logic lab=coutm}
C {devices/lab_wire.sym} 450 220 0 0 {name=p17 sig_type=std_logic lab=coutp}
C {devices/lab_wire.sym} 750 180 0 1 {name=p18 sig_type=std_logic lab=d2sout}
C {devices/lab_wire.sym} 750 200 0 1 {name=p19 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 750 220 0 1 {name=p20 sig_type=std_logic lab=VSS}
