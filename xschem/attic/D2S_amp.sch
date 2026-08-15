v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -60 140 130 140 {
lab=#net1}
N 30 200 30 260 {
lab=#net2}
N -80 -110 -80 -70 {
lab=VDD}
N -80 -110 60 -110 {
lab=VDD}
N 60 -110 140 -110 {
lab=VDD}
N 140 -110 140 -70 {
lab=VDD}
N -60 0 -60 80 {
lab=#net3}
N -80 -0 -60 0 {
lab=#net3}
N -80 -10 -80 -0 {
lab=#net3}
N 130 -10 130 80 {
lab=final_out}
N 130 -10 140 -10 {
lab=final_out}
N 130 30 200 30 {
lab=final_out}
N 40 -130 40 -110 {
lab=VDD}
N -40 -40 100 -40 {
lab=#net3}
N -60 20 0 20 {
lab=#net3}
N 0 -40 0 20 {
lab=#net3}
N 10 170 30 170 {
lab=#net2}
N 10 170 10 220 {
lab=#net2}
N 10 220 30 220 {
lab=#net2}
N 70 170 70 190 {
lab=vbias}
N 70 190 140 190 {
lab=vbias}
C {devices/iopin.sym} -370 90 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -370 120 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} 30 260 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/pfet_01v8.sym} -60 -40 0 1 {name=M1
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
C {sky130_fd_pr/pfet_01v8.sym} 120 -40 0 0 {name=M2
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
C {sky130_fd_pr/nfet_01v8.sym} -40 110 0 1 {name=M4
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
C {sky130_fd_pr/nfet_01v8.sym} 110 110 0 0 {name=M5
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
C {devices/opin.sym} 200 30 0 0 {name=p8 lab=final_out}
C {devices/ipin.sym} -20 110 0 1 {name=p3 lab=vin+
}
C {devices/ipin.sym} 90 110 0 0 {name=p9 lab=vin-
}
C {devices/lab_wire.sym} 130 110 0 1 {name=p10 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -80 -40 0 0 {name=p11 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} -60 110 0 0 {name=p12 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 140 -40 0 1 {name=p13 sig_type=std_logic lab=VDD}
C {devices/ipin.sym} 140 190 0 1 {name=p4 lab=vbias
}
C {devices/lab_wire.sym} 40 -130 0 1 {name=p6 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} 50 170 0 1 {name=M3
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
