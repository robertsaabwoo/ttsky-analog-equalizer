v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 170 -10 170 30 {
lab=OUT}
N 130 -40 130 60 {
lab=IN}
N 30 10 130 10 {
lab=IN}
N 170 -100 170 -70 {
lab=VDD}
N 170 -40 250 -40 {
lab=VDD}
N 250 -100 250 -40 {
lab=VDD}
N 170 -100 250 -100 {
lab=VDD}
N 170 60 240 60 {
lab=VSS}
N 240 60 240 90 {
lab=VSS}
N 240 90 240 110 {
lab=VSS}
N 170 110 240 110 {
lab=VSS}
N 170 90 170 110 {
lab=VSS}
N 170 20 310 20 {
lab=OUT}
C {devices/iopin.sym} -100 -70 0 0 {name=p1 lab=VDD
}
C {devices/iopin.sym} -100 -40 0 0 {name=p2 lab=VSS
}
C {devices/ipin.sym} 30 10 0 0 {name=p9 lab=IN
}
C {sky130_fd_pr/pfet_01v8.sym} 150 -40 0 0 {name=M1
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
C {sky130_fd_pr/nfet_01v8.sym} 150 60 0 0 {name=M2
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
C {devices/lab_wire.sym} 170 -100 0 0 {name=p7 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 170 110 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {devices/opin.sym} 310 20 0 0 {name=p10 lab=OUT}
