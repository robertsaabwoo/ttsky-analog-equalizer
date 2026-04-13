v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -550 130 -550 160 {
lab=#net1}
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
lab=#net1}
N -650 120 -550 120 {
lab=#net1}
N -550 120 -550 130 {
lab=#net1}
N -550 120 -440 120 {
lab=#net1}
N -440 100 -440 120 {
lab=#net1}
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
lab=vo+_temp}
N -450 30 -440 30 {
lab=vo+_temp}
N -440 30 -440 40 {
lab=vo+_temp}
N -660 -30 -660 30 {
lab=vo-_temp}
N -660 30 -650 30 {
lab=vo-_temp}
N -650 30 -650 40 {
lab=vo-_temp}
N -10 90 -10 120 {
lab=#net2}
N -30 200 -10 200 {
lab=VSS}
N -10 180 -10 200 {
lab=VSS}
N -10 150 20 150 {
lab=VSS}
N 20 150 20 190 {
lab=VSS}
N -10 190 20 190 {
lab=VSS}
N -110 60 -110 80 {
lab=#net2}
N -110 80 -10 80 {
lab=#net2}
N -10 80 -10 90 {
lab=#net2}
N -10 80 100 80 {
lab=#net2}
N 100 60 100 80 {
lab=#net2}
N -110 30 -60 30 {
lab=VSS}
N -120 -150 -120 -130 {
lab=VDD}
N -120 -150 0 -150 {
lab=VDD}
N 0 -160 0 -150 {
lab=VDD}
N 0 -150 90 -150 {
lab=VDD}
N 90 -150 90 -130 {
lab=VDD}
N 90 -70 90 -10 {
lab=vo+}
N 90 -10 100 -10 {
lab=vo+}
N 100 -10 100 0 {
lab=vo+}
N -120 -70 -120 -10 {
lab=vo-}
N -120 -10 -110 -10 {
lab=vo-}
N -110 -10 -110 0 {
lab=vo-}
C {devices/iopin.sym} -180 -260 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -180 -230 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} -540 -120 0 0 {name=p14 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} -670 70 0 0 {name=M2
L=0.15
W=3
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
L=1
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
C {devices/ipin.sym} -590 190 0 0 {name=p18 lab=vctrl

}
C {sky130_fd_pr/nfet_01v8.sym} -420 70 0 1 {name=M6
L=0.15
W=3
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
W=0.5
L=1
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -470 -60 0 0 {name=p21 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} -660 -60 0 0 {name=R4
W=0.5
L=1
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -680 -60 0 0 {name=p22 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -440 70 0 0 {name=p23 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -600 70 0 1 {name=p24 sig_type=std_logic lab=VSS}
C {devices/opin.sym} 90 -30 0 0 {name=p3 lab=vo+}
C {devices/opin.sym} -120 -40 0 0 {name=p5 lab=vo-}
C {devices/lab_wire.sym} 0 -160 0 0 {name=p6 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} -130 30 0 0 {name=M1
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
C {devices/lab_wire.sym} -30 200 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} -30 150 0 0 {name=M4
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
C {sky130_fd_pr/nfet_01v8.sym} 120 30 0 1 {name=M5
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
C {sky130_fd_pr/res_high_po.sym} 90 -100 0 0 {name=R1
W=1
L=1.75
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 70 -100 0 0 {name=p12 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} -120 -100 0 0 {name=R2
W=1
L=1.75
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -140 -100 0 0 {name=p13 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 100 30 0 0 {name=p15 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -60 30 0 1 {name=p19 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -450 0 0 0 {name=p8 sig_type=std_logic lab=vo+_temp}
C {devices/lab_wire.sym} -660 20 0 0 {name=p25 sig_type=std_logic lab=vo-_temp}
C {devices/lab_wire.sym} 140 30 0 1 {name=p4 sig_type=std_logic lab=vo+_temp}
C {devices/lab_wire.sym} -150 30 0 0 {name=p10 sig_type=std_logic lab=vo-_temp}
C {devices/lab_wire.sym} -50 150 0 0 {name=p9 sig_type=std_logic lab=vctrl}
