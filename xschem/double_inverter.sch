v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 40 0 40 40 {
lab=AFTER_INVERT}
N 0 -30 0 70 {
lab=BEFORE_INVERT}
N -0 -30 -0 70 {
lab=BEFORE_INVERT}
N 40 -90 40 -60 {
lab=VDD}
N 40 -30 120 -30 {
lab=VDD}
N 120 -90 120 -30 {
lab=VDD}
N 40 -90 120 -90 {
lab=VDD}
N 40 70 110 70 {
lab=VSS}
N 110 70 110 100 {
lab=VSS}
N 110 100 110 120 {
lab=VSS}
N 40 120 110 120 {
lab=VSS}
N 40 100 40 120 {
lab=VSS}
N -50 20 -0 20 {
lab=BEFORE_INVERT}
N 220 10 220 50 {
lab=UNDO_INVERT}
N 180 -20 180 80 {
lab=AFTER_INVERT}
N 180 -20 180 80 {
lab=AFTER_INVERT}
N 220 -80 220 -50 {
lab=VDD}
N 220 -20 300 -20 {
lab=VDD}
N 300 -80 300 -20 {
lab=VDD}
N 220 -80 300 -80 {
lab=VDD}
N 220 80 290 80 {
lab=VSS}
N 290 80 290 110 {
lab=VSS}
N 290 110 290 130 {
lab=VSS}
N 220 130 290 130 {
lab=VSS}
N 220 110 220 130 {
lab=VSS}
N 40 30 180 30 {
lab=AFTER_INVERT}
N 220 30 320 30 {
lab=UNDO_INVERT}
C {devices/iopin.sym} -300 -40 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -300 -10 0 0 {name=p2 lab=VSS


}
C {sky130_fd_pr/pfet_01v8.sym} 20 -30 0 0 {name=M1
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
model=pfet_01v8
spiceprefix=X
}
C {sky130_fd_pr/nfet_01v8.sym} 20 70 0 0 {name=M2
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
C {devices/lab_wire.sym} 40 -90 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 40 120 0 0 {name=p4 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_01v8.sym} 200 -20 0 0 {name=M3
L=0.15
W=20
nf=20
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
C {sky130_fd_pr/nfet_01v8.sym} 200 80 0 0 {name=M4
L=0.15
W=20
nf=20 
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
C {devices/lab_wire.sym} 220 -80 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} 220 130 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -50 20 0 0 {name=p9 lab=BEFORE_INVERT
}
C {devices/lab_wire.sym} 170 30 0 0 {name=p5 sig_type=std_logic lab=AFTER_INVERT}
C {devices/opin.sym} 320 30 0 0 {name=p8 lab=UNDO_INVERT}
