v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 1120 -260 1260 -260 {
lab=VDD}
N 1120 -110 1260 -110 {
lab=xor_out}
N 1120 -200 1120 -170 {
lab=#net1}
N 1260 -200 1260 -170 {
lab=#net2}
N 1200 -280 1200 -260 {
lab=VDD}
N 1120 -230 1170 -230 {
lab=VDD}
N 1170 -260 1170 -230 {
lab=VDD}
N 1210 -260 1210 -230 {
lab=VDD}
N 1210 -230 1260 -230 {
lab=VDD}
N 1120 -140 1160 -140 {
lab=VDD}
N 1160 -230 1160 -140 {
lab=VDD}
N 1220 -230 1220 -140 {
lab=VDD}
N 1220 -140 1260 -140 {
lab=VDD}
N 1120 20 1120 40 {
lab=#net3}
N 1270 20 1270 40 {
lab=#net4}
N 1120 -40 1270 -40 {
lab=xor_out}
N 1120 100 1270 100 {
lab=VSS}
N 1180 100 1180 140 {
lab=VSS}
N 1180 140 1200 140 {
lab=VSS}
N 1120 70 1160 70 {
lab=VSS}
N 1160 70 1160 100 {
lab=VSS}
N 1240 70 1240 100 {
lab=VSS}
N 1240 70 1270 70 {
lab=VSS}
N 1240 -10 1270 -10 {
lab=VSS}
N 1120 -10 1160 -10 {
lab=VSS}
N 1190 -110 1190 -40 {
lab=xor_out}
N 1240 -10 1240 70 {
lab=VSS}
N 1160 -10 1160 70 {
lab=VSS}
N 1190 -80 1230 -80 {
lab=xor_out}
C {sky130_fd_pr/pfet_01v8.sym} 1100 -230 0 0 {name=M5
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
C {sky130_fd_pr/nfet_01v8.sym} 1100 -10 0 0 {name=M6
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
model=nfet_01v8
spiceprefix=X
}
C {devices/lab_wire.sym} 1200 -280 0 0 {name=p23 sig_type=std_logic lab=VDD}
C {devices/opin.sym} 1230 -80 0 0 {name=p24 lab=xor_out}
C {sky130_fd_pr/pfet_01v8.sym} 1100 -140 0 0 {name=M1
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
C {sky130_fd_pr/pfet_01v8.sym} 1280 -230 0 1 {name=M2
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
C {sky130_fd_pr/pfet_01v8.sym} 1280 -140 0 1 {name=M3
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
C {sky130_fd_pr/nfet_01v8.sym} 1100 70 0 0 {name=M4
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
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 1290 -10 0 1 {name=M7
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
model=nfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 1290 70 0 1 {name=M8
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
model=nfet_01v8
spiceprefix=X
}
C {devices/lab_wire.sym} 1200 140 0 1 {name=p25 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 1300 -230 0 1 {name=p28 sig_type=std_logic lab=A-}
C {devices/lab_wire.sym} 1300 -140 0 1 {name=p30 sig_type=std_logic lab=B}
C {devices/lab_wire.sym} 1310 -10 0 1 {name=p31 sig_type=std_logic lab=A}
C {devices/ipin.sym} 1080 -230 0 0 {name=p7 lab=A
}
C {devices/ipin.sym} 1080 -140 0 0 {name=p1 lab=B-
}
C {devices/ipin.sym} 1080 -10 0 0 {name=p2 lab=A-
}
C {devices/ipin.sym} 1310 70 0 1 {name=p4 lab=B
}
C {devices/lab_wire.sym} 1080 70 0 0 {name=p3 sig_type=std_logic lab=B-}
C {devices/iopin.sym} 810 -160 0 0 {name=p5 lab=VDD


}
C {devices/iopin.sym} 810 -130 0 0 {name=p6 lab=VSS


}
