v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 0 130 0 160 {
lab=#net1}
N -20 240 0 240 {
lab=VSS}
N 0 220 0 240 {
lab=VSS}
N 0 190 30 190 {
lab=VSS}
N 30 190 30 230 {
lab=VSS}
N 0 230 30 230 {
lab=VSS}
N -100 100 -100 120 {
lab=#net1}
N -100 120 0 120 {
lab=#net1}
N 0 120 0 130 {
lab=#net1}
N 0 120 110 120 {
lab=#net1}
N 110 100 110 120 {
lab=#net1}
N -100 70 -50 70 {
lab=VSS}
N -110 -110 -110 -90 {
lab=VDD}
N -110 -110 10 -110 {
lab=VDD}
N 10 -120 10 -110 {
lab=VDD}
N 10 -110 100 -110 {
lab=VDD}
N 100 -110 100 -90 {
lab=VDD}
N 100 -30 100 30 {
lab=vo+}
N 100 30 110 30 {
lab=vo+}
N 110 30 110 40 {
lab=vo+}
N -110 -30 -110 30 {
lab=vo-}
N -110 30 -100 30 {
lab=vo-}
N -100 30 -100 40 {
lab=vo-}
N -550 130 -550 160 {
lab=#net2}
N -570 240 -550 240 {
lab=VSS}
N -550 220 -550 240 {
lab=VSS}
N -550 190 -520 190 {
lab=VSS}
N -520 190 -520 230 {
lab=VSS}
N -550 230 -520 230 {
lab=VSS}
N -650 100 -650 120 {
lab=#net2}
N -650 120 -550 120 {
lab=#net2}
N -550 120 -550 130 {
lab=#net2}
N -550 120 -440 120 {
lab=#net2}
N -440 100 -440 120 {
lab=#net2}
N -650 70 -600 70 {
lab=VSS}
N -660 -110 -660 -90 {
lab=VDD}
N -660 -110 -540 -110 {
lab=VDD}
N -540 -120 -540 -110 {
lab=VDD}
N -540 -110 -450 -110 {
lab=VDD}
N -450 -110 -450 -90 {
lab=VDD}
N -450 -30 -450 30 {
lab=#net3}
N -450 30 -440 30 {
lab=#net3}
N -440 30 -440 40 {
lab=#net3}
N -660 -30 -660 30 {
lab=#net4}
N -660 30 -650 30 {
lab=#net4}
N -650 30 -650 40 {
lab=#net4}
N -660 0 -250 0 {
lab=#net4}
N -250 0 -250 70 {
lab=#net4}
N -250 70 -140 70 {
lab=#net4}
N -450 -10 -270 -10 {
lab=#net3}
N -270 -10 -270 260 {
lab=#net3}
N -270 260 210 260 {
lab=#net3}
N 210 60 210 260 {
lab=#net3}
N 160 60 210 60 {
lab=#net3}
N 160 60 160 70 {
lab=#net3}
N 150 70 160 70 {
lab=#net3}
C {devices/iopin.sym} -180 -260 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -180 -230 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} 10 -120 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/opin.sym} 100 10 0 0 {name=p10 lab=vo+}
C {sky130_fd_pr/nfet_01v8.sym} -120 70 0 0 {name=M4
L=0.15
W=10
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
C {devices/lab_wire.sym} -20 240 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} -20 190 0 0 {name=M5
L=0.5
W=30
nf=3
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
C {sky130_fd_pr/nfet_01v8.sym} 130 70 0 1 {name=M1
L=0.15
W=10
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
C {devices/opin.sym} -110 0 0 0 {name=p4 lab=vo-}
C {sky130_fd_pr/res_high_po.sym} 100 -60 0 0 {name=R1
W=1
L=2
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 80 -60 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} -110 -60 0 0 {name=R2
W=1
L=2
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -130 -60 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 110 70 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -50 70 0 1 {name=p12 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -540 -120 0 0 {name=p14 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} -670 70 0 0 {name=M2
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
spiceprefix=X
}
C {devices/lab_wire.sym} -570 240 0 0 {name=p16 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -690 70 0 0 {name=p17 lab=vin-

}
C {sky130_fd_pr/nfet_01v8.sym} -570 190 0 0 {name=M3
L=0.5
W=10
nf=3
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
C {devices/ipin.sym} -590 190 0 0 {name=p18 lab=vctrl

}
C {sky130_fd_pr/nfet_01v8.sym} -420 70 0 1 {name=M6
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
spiceprefix=X
}
C {devices/ipin.sym} -400 70 0 1 {name=p20 lab=vin+

}
C {sky130_fd_pr/res_high_po.sym} -450 -60 0 0 {name=R3
W=1
L=10
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -470 -60 0 0 {name=p21 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} -660 -60 0 0 {name=R4
W=1
L=10
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -680 -60 0 0 {name=p22 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -440 70 0 0 {name=p23 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -600 70 0 1 {name=p24 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -40 190 0 0 {name=p5 sig_type=std_logic lab=vctrl}
