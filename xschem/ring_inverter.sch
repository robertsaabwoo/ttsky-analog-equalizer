v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -200 430 -200 460 {
lab=#net1}
N -220 540 -200 540 {
lab=VSS}
N -200 520 -200 540 {
lab=VSS}
N -200 490 -170 490 {
lab=VSS}
N -170 490 -170 530 {
lab=VSS}
N -200 530 -170 530 {
lab=VSS}
N -300 400 -300 420 {
lab=#net1}
N -300 420 -200 420 {
lab=#net1}
N -200 420 -200 430 {
lab=#net1}
N -200 420 -90 420 {
lab=#net1}
N -90 400 -90 420 {
lab=#net1}
N -300 370 -250 370 {
lab=VSS}
N -310 190 -310 210 {
lab=VDD}
N -310 190 -190 190 {
lab=VDD}
N -190 180 -190 190 {
lab=VDD}
N -190 190 -100 190 {
lab=VDD}
N -100 190 -100 210 {
lab=VDD}
N -100 270 -100 330 {
lab=vo+}
N -100 330 -90 330 {
lab=vo+}
N -90 330 -90 340 {
lab=vo+}
N -310 270 -310 330 {
lab=vo-}
N -310 330 -300 330 {
lab=vo-}
N -300 330 -300 340 {
lab=vo-}
C {devices/iopin.sym} -490 -80 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -490 -50 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} -190 180 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/opin.sym} -100 310 0 0 {name=p10 lab=vo+}
C {sky130_fd_pr/nfet_01v8.sym} -320 370 0 0 {name=M4
L=0.15
W=6
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
C {devices/lab_wire.sym} -220 540 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -340 370 0 0 {name=p7 lab=vin-

}
C {sky130_fd_pr/nfet_01v8.sym} -220 490 0 0 {name=M5
L=0.5
W=6
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
C {devices/ipin.sym} -240 490 0 0 {name=p13 lab=vctrl

}
C {sky130_fd_pr/nfet_01v8.sym} -70 370 0 1 {name=M1
L=0.15
W=6
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
C {devices/opin.sym} -310 300 0 0 {name=p4 lab=vo-}
C {devices/ipin.sym} -50 370 0 1 {name=p5 lab=vin+

}
C {sky130_fd_pr/res_high_po.sym} -100 240 0 0 {name=R1
W=1
L=25
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -120 240 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} -310 240 0 0 {name=R2
W=1
L=25
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -330 240 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -90 370 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -250 370 0 1 {name=p12 sig_type=std_logic lab=VSS}
