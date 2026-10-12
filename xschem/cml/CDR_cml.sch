v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=Vdd}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=Vss}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=vin+}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=vin-}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=vbias}
C {devices/iopin.sym} -400 200 0 0 {name=p6 lab=rclk+}
C {devices/iopin.sym} -400 240 0 0 {name=p7 lab=rclk-}
C {devices/lab_pin.sym} 140 -200 0 0 {name=l1 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 160 -200 0 0 {name=l2 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 140 200 0 0 {name=l3 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 160 200 0 0 {name=l4 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 280 0 0 0 {name=l5 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 100 -40 0 0 {name=l6 sig_type=std_logic lab=net2}
C {devices/lab_pin.sym} 100 40 0 0 {name=l7 sig_type=std_logic lab=net3}
C {devices/lab_pin.sym} 100 100 0 0 {name=l8 sig_type=std_logic lab=bias_n}
C {devices/lab_pin.sym} 100 -100 0 0 {name=l9 sig_type=std_logic lab=bias_p}
C {tiny_pll_charge_pump.sym} 200 0 0 0 {name=x6}
C {devices/lab_pin.sym} 320 0 0 0 {name=l10 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 320 20 0 0 {name=l11 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 320 40 0 0 {name=l12 sig_type=std_logic lab=bias_n}
C {devices/lab_pin.sym} 320 60 0 0 {name=l13 sig_type=std_logic lab=bias_p}
C {cml/cp_bias.sym} 460 0 0 0 {name=x8}
C {devices/lab_pin.sym} 580 0 0 0 {name=l14 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 580 20 0 0 {name=l15 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 580 40 0 0 {name=l16 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 580 60 0 0 {name=l17 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 580 80 0 0 {name=l18 sig_type=std_logic lab=net1}
C {cml/cml_loop_filter.sym} 720 0 0 0 {name=x2}
C {devices/lab_pin.sym} 840 0 0 0 {name=l19 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 840 20 0 0 {name=l20 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 840 40 0 0 {name=l21 sig_type=std_logic lab=net1}
C {devices/lab_pin.sym} 840 60 0 0 {name=l22 sig_type=std_logic lab=t7}
C {devices/lab_pin.sym} 840 80 0 0 {name=l23 sig_type=std_logic lab=t8}
C {cml/ring_core.sym} 980 0 0 0 {name=x1}
C {devices/lab_pin.sym} 1100 0 0 0 {name=l24 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 1100 20 0 0 {name=l25 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 1100 40 0 0 {name=l26 sig_type=std_logic lab=ck}
C {devices/lab_pin.sym} 1100 60 0 0 {name=l27 sig_type=std_logic lab=ckb}
C {devices/lab_pin.sym} 1100 80 0 0 {name=l28 sig_type=std_logic lab=t7}
C {devices/lab_pin.sym} 1100 100 0 0 {name=l29 sig_type=std_logic lab=t8}
C {devices/lab_pin.sym} 1100 120 0 0 {name=l30 sig_type=std_logic lab=vbn}
C {cml/cml_clkbuf.sym} 1240 0 0 0 {name=x9}
C {devices/lab_pin.sym} 1360 0 0 0 {name=l31 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 1360 20 0 0 {name=l32 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 1360 40 0 0 {name=l33 sig_type=std_logic lab=vbn}
C {cml/cml_bias.sym} 1500 0 0 0 {name=xref}
C {devices/lab_pin.sym} 60 200 0 0 {name=l34 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 60 220 0 0 {name=l35 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 60 240 0 0 {name=l36 sig_type=std_logic lab=net3}
C {devices/lab_pin.sym} 60 260 0 0 {name=l37 sig_type=std_logic lab=net2}
C {devices/lab_pin.sym} 60 280 0 0 {name=l38 sig_type=std_logic lab=ck}
C {devices/lab_pin.sym} 60 300 0 0 {name=l39 sig_type=std_logic lab=ckb}
C {devices/lab_pin.sym} 60 320 0 0 {name=l40 sig_type=std_logic lab=vin+}
C {devices/lab_pin.sym} 60 340 0 0 {name=l41 sig_type=std_logic lab=vin-}
C {devices/lab_pin.sym} 60 360 0 0 {name=l42 sig_type=std_logic lab=vbn}
C {cml/cml_pd_cx3w.sym} 200 200 0 0 {name=x3}
C {devices/lab_pin.sym} 320 200 0 0 {name=l43 sig_type=std_logic lab=rclk+}
C {devices/lab_pin.sym} 320 220 0 0 {name=l44 sig_type=std_logic lab=ck}
C {devices/lab_pin.sym} 320 240 0 0 {name=l45 sig_type=std_logic lab=ckb}
C {devices/lab_pin.sym} 320 260 0 0 {name=l46 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 320 280 0 0 {name=l47 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 320 300 0 0 {name=l48 sig_type=std_logic lab=vbn}
C {cml/cml2cmos.sym} 460 200 0 0 {name=x11}
C {devices/lab_pin.sym} 580 200 0 0 {name=l49 sig_type=std_logic lab=rclk-}
C {devices/lab_pin.sym} 580 220 0 0 {name=l50 sig_type=std_logic lab=ckb}
C {devices/lab_pin.sym} 580 240 0 0 {name=l51 sig_type=std_logic lab=ck}
C {devices/lab_pin.sym} 580 260 0 0 {name=l52 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 580 280 0 0 {name=l53 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 580 300 0 0 {name=l54 sig_type=std_logic lab=vbn}
C {cml/cml2cmos.sym} 720 200 0 0 {name=x12}
C {devices/lab_pin.sym} 830 180 0 0 {name=l55 sig_type=std_logic lab=Vdd}
C {devices/lab_pin.sym} 830 220 0 0 {name=l56 sig_type=std_logic lab=Vss}
C {devices/lab_pin.sym} 1130 200 0 0 {name=l57 sig_type=std_logic lab=net1}
C {vctrl_precharge.sym} 980 200 0 0 {name=x20}
