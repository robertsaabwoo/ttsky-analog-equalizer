v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 600 -270 650 -270 {
lab=#net1}
N 690 -330 720 -330 {
lab=#net1}
N 690 -330 690 -220 {
lab=#net1}
N 690 -220 720 -220 {
lab=#net1}
N 650 -270 690 -270 {
lab=#net1}
N 760 -300 760 -280 {
lab=#net2}
N 760 -280 760 -250 {
lab=#net2}
N 760 -280 820 -280 {
lab=#net2}
N 750 -150 760 -150 {
lab=VSS}
N 760 -190 760 -150 {
lab=VSS}
N 760 -220 780 -220 {
lab=VSS}
N 780 -220 780 -170 {
lab=VSS}
N 760 -170 780 -170 {
lab=VSS}
N 760 -390 760 -360 {
lab=VDD}
N 760 -330 780 -330 {
lab=VDD}
N 780 -380 780 -330 {
lab=VDD}
N 760 -380 780 -380 {
lab=VDD}
N 820 -280 830 -280 {
lab=#net2}
N 830 -280 880 -280 {
lab=#net2}
N 710 -650 740 -650 {
lab=#net3}
N 710 -650 710 -540 {
lab=#net3}
N 710 -540 740 -540 {
lab=#net3}
N 670 -590 710 -590 {
lab=#net3}
N 780 -620 780 -600 {
lab=clk_out-}
N 780 -600 780 -570 {
lab=clk_out-}
N 780 -600 840 -600 {
lab=clk_out-}
N 770 -470 780 -470 {
lab=VSS}
N 780 -510 780 -470 {
lab=VSS}
N 780 -540 800 -540 {
lab=VSS}
N 800 -540 800 -490 {
lab=VSS}
N 780 -490 800 -490 {
lab=VSS}
N 780 -710 780 -680 {
lab=VDD}
N 780 -650 800 -650 {
lab=VDD}
N 800 -700 800 -650 {
lab=VDD}
N 780 -700 800 -700 {
lab=VDD}
N 840 -600 850 -600 {
lab=clk_out-}
N 850 -600 900 -600 {
lab=clk_out-}
N -30 -250 30 -250 {
lab=VDD}
N -30 -230 60 -230 {
lab=VSS}
N 500 -250 560 -250 {
lab=VDD}
N 500 -230 590 -230 {
lab=VSS}
N -30 -290 200 -290 {
lab=#net4}
N -30 -270 200 -270 {
lab=#net5}
N 500 -270 600 -270 {
lab=#net1}
N 600 -390 600 -270 {
lab=#net1}
N -460 -390 600 -390 {
lab=#net1}
N -460 -390 -460 -310 {
lab=#net1}
N -460 -310 -460 -300 {
lab=#net1}
N -460 -300 -460 -290 {
lab=#net1}
N -460 -290 -330 -290 {
lab=#net1}
N 500 -340 500 -290 {
lab=#net3}
N -390 -340 500 -340 {
lab=#net3}
N -390 -340 -390 -270 {
lab=#net3}
N -390 -270 -330 -270 {
lab=#net3}
N 490 -590 490 -340 {
lab=#net3}
N 490 -590 670 -590 {
lab=#net3}
C {devices/opin.sym} 880 -280 0 0 {name=p12 lab=clk_out+}
C {devices/iopin.sym} -520 60 0 0 {name=p3 lab=VDD


}
C {devices/iopin.sym} -500 140 0 0 {name=p16 lab=VSS


}
C {devices/opin.sym} 900 -600 0 0 {name=p20 lab=clk_out-}
C {sky130_fd_pr/pfet_01v8.sym} 740 -330 0 0 {name=M14
L=0.15
W=8
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 740 -220 0 0 {name=M15
L=0.15
W=4
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_wire.sym} 750 -150 0 0 {name=p21 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 760 -390 0 0 {name=p22 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 760 -650 0 0 {name=M16
L=0.15
W=8
nf=1
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 760 -540 0 0 {name=M17
L=0.15
W=4
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_wire.sym} 770 -470 0 0 {name=p23 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 780 -710 0 0 {name=p24 sig_type=std_logic lab=VDD}
C {d_latch.sym} -180 -250 0 0 {name=x1}
C {devices/ipin.sym} -330 -250 0 0 {name=p25 lab=clk+
}
C {devices/ipin.sym} -330 -230 0 0 {name=p26 lab=clk-
}
C {devices/ipin.sym} -330 -210 0 0 {name=p27 lab=vbias
}
C {devices/lab_wire.sym} 30 -250 0 0 {name=p28 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 60 -230 0 0 {name=p29 sig_type=std_logic lab=VSS}
C {d_latch.sym} 350 -250 0 0 {name=x2}
C {devices/lab_wire.sym} 560 -250 0 0 {name=p33 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 590 -230 0 0 {name=p34 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 200 -250 0 0 {name=p30 sig_type=std_logic lab=clk-}
C {devices/lab_wire.sym} 200 -230 0 0 {name=p31 sig_type=std_logic lab=clk+}
C {devices/lab_wire.sym} 200 -210 0 0 {name=p32 sig_type=std_logic lab=vbias}
