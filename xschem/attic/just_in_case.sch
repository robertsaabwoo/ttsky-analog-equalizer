v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -450 -140 -420 -140 {
lab=vin+}
N -450 -120 -420 -120 {
lab=#net1}
N -1310 310 -1290 310 {
lab=vbias}
N -1290 370 -1290 420 {
lab=Vss}
N -1290 260 -1290 310 {
lab=vbias}
N -1290 210 -1290 260 {
lab=vbias}
N -1340 210 -1290 210 {
lab=vbias}
N -1340 170 -1340 210 {
lab=vbias}
N -1380 310 -1370 310 {
lab=#net2}
N -1380 310 -1380 330 {
lab=#net2}
N -420 -120 -380 -120 {
lab=#net1}
N -420 -140 -340 -140 {
lab=vin+}
N -380 -120 -340 -120 {
lab=#net1}
N 760 570 800 570 {
lab=Vss}
N 800 550 800 570 {
lab=Vss}
N 710 470 800 470 {
lab=v_ctrl}
N 800 470 800 510 {
lab=v_ctrl}
N 860 400 860 410 {
lab=Vdd}
N 860 400 890 400 {
lab=Vdd}
N 890 380 890 400 {
lab=Vdd}
N 840 630 840 650 {
lab=Vss}
N 840 650 860 650 {
lab=Vss}
N 860 630 860 650 {
lab=Vss}
N 710 30 710 470 {
lab=v_ctrl}
N 460 -190 460 -170 {
lab=Vdd}
N 460 -190 480 -190 {
lab=Vdd}
N 480 -190 480 -170 {
lab=Vdd}
N 470 -200 470 -190 {
lab=Vdd}
N 460 230 460 250 {
lab=Vss}
N 460 250 480 250 {
lab=Vss}
N 480 230 480 250 {
lab=Vss}
N 960 490 990 490 {
lab=single}
N 600 30 710 30 {
lab=v_ctrl}
N -20 -550 -20 -530 {
lab=Vdd}
N -20 -550 0 -550 {
lab=Vdd}
N 0 -550 0 -530 {
lab=Vdd}
N -10 -560 -10 -550 {
lab=Vdd}
N -20 -250 -20 -230 {
lab=Vss}
N -20 -230 0 -230 {
lab=Vss}
N 0 -250 0 -230 {
lab=Vss}
N 240 0 360 0 {
lab=down}
N 240 -40 280 -40 {
lab=Vdd}
N 280 -60 280 -40 {
lab=Vdd}
N 240 -20 320 -20 {
lab=Vss}
N 320 -30 320 -20 {
lab=Vss}
N -100 40 -60 40 {
lab=vbias}
N -100 40 -100 90 {
lab=vbias}
N -100 90 -60 90 {
lab=vbias}
N 880 0 890 0 {
lab=Vdd}
N 880 0 880 20 {
lab=Vdd}
N 880 20 890 20 {
lab=Vdd}
N 840 10 880 10 {
lab=Vdd}
N 880 40 890 40 {
lab=Vss}
N 880 40 880 60 {
lab=Vss}
N 880 60 890 60 {
lab=Vss}
N 840 50 880 50 {
lab=Vss}
N 990 -140 990 -80 {
lab=v_ctrl}
N 660 -140 990 -140 {
lab=v_ctrl}
N 660 -140 660 30 {
lab=v_ctrl}
N 990 490 1080 490 {
lab=single}
N -330 20 -60 20 {
lab=#net1}
N -330 -120 -330 20 {
lab=#net1}
N -340 -120 -330 -120 {
lab=#net1}
N 360 -0 370 -0 {
lab=down}
N 370 -20 370 -0 {
lab=down}
N 310 20 310 50 {
lab=up}
N 300 50 310 50 {
lab=up}
N 990 440 990 490 {
lab=single}
N 670 380 710 380 {
lab=v_ctrl}
N 420 -10 420 0 {
lab=up}
N 240 20 310 20 {
lab=up}
N 310 20 360 20 {
lab=up}
N 1760 530 1800 530 {
lab=Vdd}
N 1800 510 1800 530 {
lab=Vdd}
N 1760 550 1840 550 {
lab=Vss}
N 1840 540 1840 550 {
lab=Vss}
N 370 0 400 -0 {
lab=down}
N 360 20 420 20 {
lab=up}
N 1380 490 1420 490 {
lab=Vdd}
N 1420 470 1420 490 {
lab=Vdd}
N 1380 510 1460 510 {
lab=Vss}
N 1460 500 1460 510 {
lab=Vss}
N 1380 530 1460 530 {
lab=singie}
N 1405 530 1405 595 {
lab=singie}
N -170 -20 -60 -20 {
lab=vin+}
N -170 -140 -170 -20 {
lab=vin+}
N -340 -140 -170 -140 {
lab=vin+}
N -610 -135 -450 -135 {
lab=vin+}
N -450 -140 -450 -135 {
lab=vin+}
N -325 -180 -325 -140 {
lab=vin+}
N 360 -110 360 -70 {
lab=bias_p}
N 360 -70 420 -70 {
lab=bias_p}
N 360 120 360 130 {
lab=bias_n}
N 360 130 420 130 {
lab=bias_n}
N 420 20 420 70 {}
N 400 -0 420 0 {}
C {devices/vsource.sym} -1550 -80 0 0 {name=V3 value=1.8 savecurrent=false}
C {devices/gnd.sym} -1550 -50 0 0 {name=l3 lab=GND}
C {devices/lab_wire.sym} -1550 -110 0 0 {name=p5 sig_type=std_logic lab=Vdd
}
C {devices/vsource.sym} -1460 -80 0 0 {name=V1 value=0 savecurrent=false}
C {devices/gnd.sym} -1460 -50 0 0 {name=l1 lab=GND}
C {devices/lab_wire.sym} -1460 -110 0 0 {name=p1 sig_type=std_logic lab=Vss
}
C {devices/simulator_commands_shown.sym} -1660 -620 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="
.lib /home/ttuser/pdk/sky130A/libs.tech/ngspice/sky130.lib.spice tt
.include /home/ttuser/pdk/sky130A/libs.ref/sky130_fd_sc_hd/spice/sky130_fd_sc_hd.spice
.options method=gear reltol=0.001 abstol=1e-12
.op
.control
  tran 10p 100n
  write CDR_tb.raw
.endc
"}
C {devices/vsource.sym} -610 -105 0 0 {name=V2 value="PULSE(0 1.8 0 10p 10p 0.5n 1n)" savecurrent=false
lab=vin+}
C {devices/gnd.sym} -610 -75 0 0 {name=l2 lab=GND}
C {devices/vsource.sym} -450 -90 0 0 {name=V4 value="PULSE(1.8 0 0 10p 10p 0.5n 1n)" savecurrent=false}
C {devices/gnd.sym} -450 -60 0 0 {name=l4 lab=GND}
C {devices/vsource.sym} -1380 360 0 0 {name=V5 value=0.9 savecurrent=false}
C {devices/gnd.sym} -1380 390 0 0 {name=l5 lab=GND
value=vbias}
C {devices/lab_wire.sym} -1340 170 0 0 {name=p28 sig_type=std_logic lab=vbias
}
C {devices/res.sym} -1340 310 1 0 {name=R8
value=500
footprint=1206
device=resistor
m=1}
C {devices/capa.sym} -1290 340 0 0 {name=C5
m=1
value=1p
footprint=1206
device="ceramic capacitor"}
C {devices/lab_wire.sym} -1290 420 0 0 {name=p29 sig_type=std_logic lab=Vss
}
C {tiny_pll_vco.sym} 880 510 0 0 {name=x1}
C {devices/lab_wire.sym} 760 570 0 0 {name=p2 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 800 530 0 0 {name=p4 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 840 410 0 0 {name=p3 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 890 380 0 0 {name=p6 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 840 650 0 0 {name=p8 sig_type=std_logic lab=Vss
}
C {tiny_pll_charge_pump.sym} 520 30 0 0 {name=x6}
C {devices/lab_wire.sym} 470 -200 0 0 {name=p14 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 460 250 0 0 {name=p35 sig_type=std_logic lab=Vss
}
C {tiny_pll_bias_gen.sym} -100 -370 0 0 {name=x8}
C {devices/lab_wire.sym} -10 -560 0 0 {name=p43 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -20 -230 0 0 {name=p44 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 40 -390 0 1 {name=p47 sig_type=std_logic lab=bias_p
}
C {devices/lab_wire.sym} 40 -330 0 1 {name=p48 sig_type=std_logic lab=bias_n
}
C {devices/opin.sym} 1760 570 0 0 {name=p17 lab=rclk-}
C {tiny_pll_loop_filter.sym} 990 40 0 0 {name=x3}
C {alexander_phase_detector.sym} 90 0 0 0 {name=x4}
C {devices/lab_wire.sym} 280 -60 0 0 {name=p23 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 320 -30 0 0 {name=p25 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 840 10 0 0 {name=p30 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 840 50 0 0 {name=p31 sig_type=std_logic lab=Vss
}
C {s2d.sym} 1610 560 0 0 {name=x5}
C {devices/opin.sym} 1760 590 0 0 {name=p32 lab=rclk+}
C {devices/lab_wire.sym} -60 -40 0 0 {name=p33 sig_type=std_logic lab=rclk+
}
C {devices/lab_wire.sym} -60 0 0 0 {name=p34 sig_type=std_logic lab=rclk-
}
C {devices/lab_wire.sym} -220 -370 0 0 {name=p45 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} -220 -350 0 0 {name=p46 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 370 -20 0 0 {name=p7 sig_type=std_logic lab=down
}
C {devices/lab_wire.sym} 300 50 0 0 {name=p26 sig_type=std_logic lab=up
}
C {devices/lab_wire.sym} 990 440 0 0 {name=p51 sig_type=std_logic lab=single
}
C {devices/lab_wire.sym} 670 380 0 0 {name=p56 sig_type=std_logic lab=v_ctrl
}
C {devices/lab_wire.sym} 1800 510 0 0 {name=p38 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1840 540 0 0 {name=p39 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} -60 90 0 0 {name=p40 sig_type=std_logic lab=vbias
}
C {inverter_chain.sym} 1230 510 0 0 {name=x7}
C {devices/lab_wire.sym} 1420 470 0 0 {name=p27 sig_type=std_logic lab=Vdd
}
C {devices/lab_wire.sym} 1460 500 0 0 {name=p36 sig_type=std_logic lab=Vss
}
C {devices/lab_wire.sym} 1405 595 0 0 {name=p41 sig_type=std_logic lab=singie
}
C {devices/lab_wire.sym} -325 -180 0 0 {name=p9 sig_type=std_logic lab=vin+
}
C {devices/lab_wire.sym} 360 -110 0 1 {name=p10 sig_type=std_logic lab=bias_p
}
C {devices/lab_wire.sym} 360 120 0 1 {name=p11 sig_type=std_logic lab=bias_n
}
