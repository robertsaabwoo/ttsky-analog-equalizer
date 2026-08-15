v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N 310 180 310 210 {
lab=#net1}
N 290 290 310 290 {
lab=VSS}
N 310 270 310 290 {
lab=VSS}
N 310 240 340 240 {
lab=VSS}
N 340 240 340 280 {
lab=VSS}
N 310 280 340 280 {
lab=VSS}
N 210 150 210 170 {
lab=#net1}
N 210 170 310 170 {
lab=#net1}
N 310 170 310 180 {
lab=#net1}
N 310 170 420 170 {
lab=#net1}
N 420 150 420 170 {
lab=#net1}
N 210 120 260 120 {
lab=VSS}
N 200 -60 200 -40 {
lab=VDD}
N 200 -60 320 -60 {
lab=VDD}
N 320 -70 320 -60 {
lab=VDD}
N 320 -60 410 -60 {
lab=VDD}
N 410 -60 410 -40 {
lab=VDD}
N 410 20 410 80 {
lab=vo+}
N 410 80 420 80 {
lab=vo+}
N 420 80 420 90 {
lab=vo+}
N 200 20 200 80 {
lab=vo-}
N 200 80 210 80 {
lab=vo-}
N 210 80 210 90 {
lab=vo-}
N -240 180 -240 210 {
lab=#net2}
N -260 290 -240 290 {
lab=VSS}
N -240 270 -240 290 {
lab=VSS}
N -240 240 -210 240 {
lab=VSS}
N -210 240 -210 280 {
lab=VSS}
N -240 280 -210 280 {
lab=VSS}
N -340 150 -340 170 {
lab=#net2}
N -340 170 -240 170 {
lab=#net2}
N -240 170 -240 180 {
lab=#net2}
N -240 170 -130 170 {
lab=#net2}
N -130 150 -130 170 {
lab=#net2}
N -340 120 -290 120 {
lab=VSS}
N -350 -60 -350 -40 {
lab=VDD}
N -350 -60 -230 -60 {
lab=VDD}
N -230 -70 -230 -60 {
lab=VDD}
N -230 -60 -140 -60 {
lab=VDD}
N -140 -60 -140 -40 {
lab=VDD}
N -140 20 -140 80 {
lab=#net3}
N -140 80 -130 80 {
lab=#net3}
N -130 80 -130 90 {
lab=#net3}
N -350 20 -350 80 {
lab=#net4}
N -350 80 -340 80 {
lab=#net4}
N -340 80 -340 90 {
lab=#net4}
N -350 50 60 50 {
lab=#net4}
N 60 50 60 120 {
lab=#net4}
N 60 120 170 120 {
lab=#net4}
N -140 40 40 40 {
lab=#net3}
N 40 40 40 310 {
lab=#net3}
N 40 310 520 310 {
lab=#net3}
N 520 110 520 310 {
lab=#net3}
N 470 110 520 110 {
lab=#net3}
N 470 110 470 120 {
lab=#net3}
N 460 120 470 120 {
lab=#net3}
C {devices/iopin.sym} 130 -210 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} 130 -180 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} 320 -70 0 0 {name=p3 sig_type=std_logic lab=VDD}
C {devices/opin.sym} 410 60 0 0 {name=p10 lab=vo+}
C {sky130_fd_pr/nfet_01v8.sym} 190 120 0 0 {name=M4
L=0.15
W=10
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
C {devices/lab_wire.sym} 290 290 0 0 {name=p6 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 290 240 0 0 {name=M5
L=0.15
W=30
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
C {sky130_fd_pr/nfet_01v8.sym} 440 120 0 1 {name=M1
L=0.15
W=10
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
C {devices/opin.sym} 200 50 0 0 {name=p4 lab=vo-}
C {sky130_fd_pr/res_high_po.sym} 410 -10 0 0 {name=R1
W=5
L=2
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 390 -10 0 0 {name=p8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} 200 -10 0 0 {name=R2
W=5
L=2
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} 180 -10 0 0 {name=p9 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 420 120 0 0 {name=p11 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 260 120 0 1 {name=p12 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -230 -70 0 0 {name=p14 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/nfet_01v8.sym} -360 120 0 0 {name=M2
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
C {devices/lab_wire.sym} -260 290 0 0 {name=p16 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -380 120 0 0 {name=p17 lab=vin-

}
C {sky130_fd_pr/nfet_01v8.sym} -260 240 0 0 {name=M3
L=0.5
W=10
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
C {devices/ipin.sym} -280 240 0 0 {name=p18 lab=vctrl

}
C {sky130_fd_pr/nfet_01v8.sym} -110 120 0 1 {name=M6
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
C {devices/ipin.sym} -90 120 0 1 {name=p20 lab=vin+

}
C {sky130_fd_pr/res_high_po.sym} -140 -10 0 0 {name=R3
W=1
L=10
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -160 -10 0 0 {name=p21 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/res_high_po.sym} -350 -10 0 0 {name=R4
W=1
L=10
model=res_high_po
spiceprefix=X
mult=1}
C {devices/lab_wire.sym} -370 -10 0 0 {name=p22 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -130 120 0 0 {name=p23 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -290 120 0 1 {name=p24 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 270 240 0 0 {name=p5 sig_type=std_logic lab=vctrl}
