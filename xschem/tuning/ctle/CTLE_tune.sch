v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -30 260 20 260 {
lab=VSS}
N 20 260 20 330 {
lab=VSS}
N -30 330 20 330 {
lab=VSS}
N -30 290 -30 330 {
lab=VSS}
N -130 -100 -100 -100 {
lab=VSS}
N -130 -160 -130 -130 {
lab=vout+}
N 60 -170 60 -130 {
lab=vout-}
N -130 -70 -130 -40 {
lab=#net1}
N 60 -70 60 -40 {
lab=#net2}
N 60 -40 60 -0 {
lab=#net2}
N 0 130 60 130 {
lab=#net3}
N -130 130 -60 130 {
lab=#net3}
N -130 -40 -130 -0 {
lab=#net1}
N -130 -240 -130 -220 {
lab=VDD}
N -130 -240 60 -240 {
lab=VDD}
N 60 -240 60 -230 {
lab=VDD}
N -30 -260 -30 -240 {
lab=VDD}
N 60 -140 90 -140 {
lab=vout-}
N -160 -150 -130 -150 {
lab=vout+}
N -60 130 -50 130 {
lab=#net3}
N -10 130 0 130 {
lab=#net3}
N -30 140 -30 230 {
lab=#net3}
N -30 130 -10 130 {
lab=#net3}
N -30 130 -30 140 {
lab=#net3}
N -50 130 -30 130 {
lab=#net3}
N 60 60 60 70 {
lab=#net3}
N -130 60 -130 70 {
lab=#net3}
N 40 -100 60 -100 {
lab=VSS}
N 60 -180 60 -170 {
lab=vout-}
N -250 -20 -250 0 {
lab=#net1}
N -250 -20 -130 -20 {
lab=#net1}
N -250 60 -250 80 {
lab=sdegm}
N -180 80 -130 80 {
lab=#net3}
N -130 70 -130 80 {
lab=#net3}
N -180 80 -180 130 {
lab=#net3}
N -180 130 -130 130 {
lab=#net3}
N 60 -20 130 -20 {
lab=sdegm}
N 60 70 130 70 {
lab=#net3}
N 100 70 100 130 {
lab=#net3}
N 60 130 100 130 {
lab=#net3}
C {devices/iopin.sym} -420 -90 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -420 -60 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} -30 -260 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} -30 330 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -170 -100 0 0 {name=p3 lab=vin+
}
C {devices/ipin.sym} 100 -100 0 1 {name=p7 lab=vin-
}
C {devices/ipin.sym} -70 260 0 0 {name=p11 lab=vbias
}
C {devices/opin.sym} 90 -140 0 0 {name=p8 lab=vout-}
C {devices/opin.sym} -160 -150 0 1 {name=p12 lab=vout+}
C {sky130_fd_pr/nfet_01v8.sym} -150 -100 0 0 {name=M1
L=0.3
W=20
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
C {sky130_fd_pr/nfet_01v8.sym} -50 260 0 0 {name=M2
L=0.5
W=20
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
C {sky130_fd_pr/nfet_01v8.sym} 80 -100 0 1 {name=M4
L=0.3
W=20
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
C {sky130_fd_pr/res_high_po.sym} -130 -190 0 0 {name=R1
W=1
L=20
model=res_high_po
spiceprefix=X
mult=1}
C {sky130_fd_pr/res_high_po.sym} 60 -210 0 0 {name=R2
W=1
L=20
model=res_high_po
spiceprefix=X
mult=1}
C {sky130_fd_pr/res_high_po.sym} -130 30 2 0 {name=R3
W=1
L=5.0
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 40 -210 0 0 {name=p13 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -150 -190 0 0 {name=p14 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/cap_mim_m3_1.sym} -250 30 0 0 {name=CS model=cap_mim_m3_1 W=18 L=18 MF=1 spiceprefix=X}
C {devices/lab_wire.sym} -110 30 0 1 {name=p6 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 60 30 2 0 {name=R4
W=1
L=5.0
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 80 30 0 1 {name=p9 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 40 -100 0 0 {name=p10 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -100 -100 0 1 {name=p15 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -250 80 0 0 {name=p16 sig_type=std_logic lab=sdegm}
C {devices/lab_wire.sym} 130 -20 0 0 {name=p17 sig_type=std_logic lab=sdegm}
