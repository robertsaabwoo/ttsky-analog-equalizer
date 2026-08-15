v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -110 -90 -110 -50 {
lab=#net1}
N -110 -180 -110 -150 {
lab=VDD}
N -110 -120 -30 -120 {
lab=VDD}
N -30 -180 -30 -120 {
lab=VDD}
N -110 -180 -30 -180 {
lab=VDD}
N -110 40 -40 40 {
lab=VSS}
N -40 40 -40 70 {
lab=VSS}
N -40 70 -40 90 {
lab=VSS}
N -110 90 -40 90 {
lab=VSS}
N -110 70 -110 90 {
lab=VSS}
N 120 -180 120 -150 {
lab=VDD}
N 120 -120 200 -120 {
lab=VDD}
N 200 -180 200 -120 {
lab=VDD}
N 120 -180 200 -180 {
lab=VDD}
N 120 50 190 50 {
lab=VSS}
N 190 50 190 80 {
lab=VSS}
N 190 80 190 100 {
lab=VSS}
N 120 100 190 100 {
lab=VSS}
N 120 80 120 100 {
lab=VSS}
N -110 -20 -60 -20 {
lab=VSS}
N -60 -20 -60 40 {
lab=VSS}
N 120 -30 190 -30 {
lab=VSS}
N 190 -30 190 0 {
lab=VSS}
N 190 0 190 20 {
lab=VSS}
N 120 0 120 20 {
lab=#net2}
N 190 20 190 50 {
lab=VSS}
N 120 -90 120 -60 {
lab=#net3}
N 40 -120 80 -120 {
lab=#net1}
N 40 -120 40 50 {
lab=#net1}
N 40 50 80 50 {
lab=#net1}
N -110 -70 40 -70 {
lab=#net1}
N -240 -120 -150 -120 {
lab=D}
N -240 -120 -240 40 {
lab=D}
N -240 40 -150 40 {
lab=D}
N 120 -70 180 -70 {}
C {sky130_fd_pr/pfet_01v8.sym} -130 -120 0 0 {name=M1
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
C {sky130_fd_pr/nfet_01v8.sym} -130 40 0 0 {name=M2
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
C {devices/lab_wire.sym} -110 -180 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} -110 90 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -240 -20 0 0 {name=p9 lab=D
}
C {sky130_fd_pr/pfet_01v8.sym} 100 -120 0 0 {name=M3
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
C {sky130_fd_pr/nfet_01v8.sym} 100 50 0 0 {name=M4
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
C {devices/lab_wire.sym} 120 -180 0 0 {name=p5 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 120 100 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} -130 -20 0 0 {name=M5
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
C {sky130_fd_pr/nfet_01v8.sym} 100 -30 0 0 {name=M6
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
C {devices/ipin.sym} -150 -20 0 0 {name=p1 lab=E
}
C {devices/lab_wire.sym} 80 -30 0 0 {name=p2 sig_type=std_logic lab=E}
C {devices/opin.sym} 180 -70 0 0 {name=p10 lab=Q}
