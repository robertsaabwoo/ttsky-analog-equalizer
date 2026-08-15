v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 330 -140 330 -110 {
lab=#net1}
N 330 -50 330 -20 {
lab=vout+}
N 520 -50 520 -20 {
lab=vout-}
N 420 -160 420 -140 {
lab=#net1}
N 520 -40 550 -40 {
lab=vout-}
N 300 -30 330 -30 {
lab=vout+}
N 520 40 520 130 {
lab=VSS}
N 330 40 330 130 {
lab=VSS}
N 450 -100 450 -80 {
lab=VDD}
N 450 -80 520 -80 {
lab=VDD}
N 330 -80 450 -80 {
lab=VDD}
N 420 -240 420 -220 {
lab=VDD}
N 330 -140 520 -140 {
lab=#net1}
N 420 -190 470 -190 {
lab=VDD}
N 470 -220 470 -190 {
lab=VDD}
N 420 -220 470 -220 {
lab=VDD}
N 310 10 310 70 {
lab=VSS}
N 310 70 330 70 {
lab=VSS}
N 500 10 500 50 {
lab=VSS}
N 500 50 520 50 {
lab=VSS}
N 140 -80 180 -80 {
lab=vin+}
N 100 -80 140 -80 {
lab=vin+}
N 560 -80 710 -80 {
lab=#net2}
N 180 -80 290 -80 {
lab=vin+}
N 120 70 180 70 {
lab=vout+}
N 180 -30 180 70 {
lab=vout+}
N 180 -30 300 -30 {
lab=vout+}
N 550 -40 660 -40 {
lab=vout-}
N 660 -40 660 40 {
lab=vout-}
N 660 40 670 40 {
lab=vout-}
N 520 -140 520 -110 {
lab=#net1}
N 40 -80 100 -80 {
lab=vin+}
C {devices/iopin.sym} -210 -60 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -210 -30 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} 420 -240 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 520 130 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} 40 -80 0 0 {name=p3 lab=vin+
}
C {devices/ipin.sym} 710 -80 0 1 {name=p7 lab=vin-
}
C {devices/opin.sym} 670 40 0 0 {name=p8 lab=vout-}
C {devices/opin.sym} 120 70 0 1 {name=p12 lab=vout+}
C {sky130_fd_pr/pfet_01v8.sym} 310 -80 0 0 {name=M3
L=0.15
W=10
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
C {sky130_fd_pr/res_high_po.sym} 330 10 0 0 {name=R3
W=1
L=4
model=res_high_po
spiceprefix=X
mult=1}
C {sky130_fd_pr/res_high_po.sym} 520 10 0 0 {name=R4
W=1
L=8
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 330 130 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_01v8.sym} 540 -80 0 1 {name=M1
L=0.15
W=10
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
C {devices/lab_wire.sym} 450 -100 0 0 {name=p9 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 400 -190 0 0 {name=M2
L=0.15
W=10
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
C {devices/ipin.sym} 380 -190 0 0 {name=p10 lab=vbias
}
