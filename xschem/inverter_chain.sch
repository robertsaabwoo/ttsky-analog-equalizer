v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 80 -50 80 -10 {
lab=STRONG_OUT1}
N 40 -80 40 20 {
lab=weak_in}
N 40 -80 40 20 {
lab=weak_in}
N 80 -140 80 -110 {
lab=VDD}
N 80 -80 160 -80 {
lab=VDD}
N 160 -140 160 -80 {
lab=VDD}
N 80 -140 160 -140 {
lab=VDD}
N 80 20 150 20 {
lab=VSS}
N 150 20 150 50 {
lab=VSS}
N 150 50 150 70 {
lab=VSS}
N 80 70 150 70 {
lab=VSS}
N 80 50 80 70 {
lab=VSS}
N -10 -30 40 -30 {
lab=weak_in}
N 80 -20 220 -20 {
lab=STRONG_OUT1}
N 310 -40 310 0 {
lab=STRONG_OUT2}
N 270 -70 270 30 {
lab=STRONG_OUT1}
N 270 -70 270 30 {
lab=STRONG_OUT1}
N 310 -130 310 -100 {
lab=VDD}
N 310 -70 390 -70 {
lab=VDD}
N 390 -130 390 -70 {
lab=VDD}
N 310 -130 390 -130 {
lab=VDD}
N 310 30 380 30 {
lab=VSS}
N 380 30 380 60 {
lab=VSS}
N 380 60 380 80 {
lab=VSS}
N 310 80 380 80 {
lab=VSS}
N 310 60 310 80 {
lab=VSS}
N 220 -20 270 -20 {
lab=STRONG_OUT1}
N 530 -30 530 10 {
lab=STRONG_OUT}
N 490 -60 490 40 {
lab=STRONG_OUT2}
N 490 -60 490 40 {
lab=STRONG_OUT2}
N 530 -120 530 -90 {
lab=VDD}
N 530 -60 610 -60 {
lab=VDD}
N 610 -120 610 -60 {
lab=VDD}
N 530 -120 610 -120 {
lab=VDD}
N 530 40 600 40 {
lab=VSS}
N 600 40 600 70 {
lab=VSS}
N 600 70 600 90 {
lab=VSS}
N 530 90 600 90 {
lab=VSS}
N 530 70 530 90 {
lab=VSS}
N 530 0 670 0 {
lab=STRONG_OUT}
N 310 -10 490 -10 {
lab=STRONG_OUT2}
N 210 -200 210 -20 {
lab=STRONG_OUT1}
N 210 -200 690 -200 {
lab=STRONG_OUT1}
N 430 -170 430 -10 {
lab=STRONG_OUT2}
N 430 -170 690 -170 {
lab=STRONG_OUT2}
C {devices/iopin.sym} -260 -90 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -260 -60 0 0 {name=p2 lab=VSS


}
C {sky130_fd_pr/pfet_01v8.sym} 60 -80 0 0 {name=M1
L=0.15
W=2
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
C {sky130_fd_pr/nfet_01v8.sym} 60 20 0 0 {name=M2
L=0.15
W=1
nf=1 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/lab_wire.sym} 80 -140 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 80 70 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -10 -30 0 0 {name=p9 lab=weak_in
}
C {sky130_fd_pr/pfet_01v8.sym} 290 -70 0 0 {name=M3
L=0.15
W=6
nf=4
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
C {sky130_fd_pr/nfet_01v8.sym} 290 30 0 0 {name=M4
L=0.15
W=3
nf=2 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/lab_wire.sym} 310 -130 0 0 {name=p5 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 310 80 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_01v8.sym} 510 -60 0 0 {name=M5
L=0.15
W=16
nf=8
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
C {sky130_fd_pr/nfet_01v8.sym} 510 40 0 0 {name=M6
L=0.15
W=8
nf=4 
mult=1
ad="'int((nf+1)/2) * W/nf * 0.29'" 
pd="'2*int((nf+1)/2) * (W/nf + 0.29)'"
as="'int((nf+2)/2) * W/nf * 0.29'" 
ps="'2*int((nf+2)/2) * (W/nf + 0.29)'"
nrd="'0.29 / W'" nrs="'0.29 / W'"
sa=0 sb=0 sd=0
model=nfet_01v8
spiceprefix=X
}
C {devices/lab_wire.sym} 530 -120 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 530 90 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {devices/opin.sym} 670 0 0 0 {name=p10 lab=STRONG_OUT3}
C {devices/opin.sym} 690 -170 0 0 {name=p11 lab=STRONG_OUT2}
C {devices/opin.sym} 690 -200 0 0 {name=p12 lab=STRONG_OUT1}
