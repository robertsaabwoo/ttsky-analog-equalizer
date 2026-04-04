v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
N -180 260 -130 260 {
lab=VSS}
N -130 260 -130 330 {
lab=VSS}
N -30 330 20 330 {
lab=VSS}
N -180 290 -180 330 {
lab=VSS}
N -130 -100 -100 -100 {
lab=VSS}
N -130 -160 -130 -130 {
lab=vout+}
N 60 -170 60 -130 {
lab=vout-}
N -130 -70 -130 -40 {
lab=bl_vDL}
N 60 -70 60 -40 {
lab=bl_vDR}
N 60 -40 60 -0 {
lab=bl_vDR}
N -130 -40 -130 -0 {
lab=bl_vDL}
N -130 -240 -130 -220 {
lab=VDD}
N -130 -240 60 -240 {
lab=VDD}
N -30 -260 -30 -240 {
lab=VDD}
N 60 -140 90 -140 {
lab=vout-}
N -160 -150 -130 -150 {
lab=vout+}
N -180 140 -180 230 {
lab=bl_vDL}
N -80 30 -70 30 {
lab=bl_vDL}
N 40 -100 60 -100 {
lab=VSS}
N 60 -180 60 -170 {
lab=vout-}
N -180 80 -180 130 {
lab=bl_vDL}
N 10 30 10 100 {
lab=bl_vDR}
N -10 100 10 100 {
lab=bl_vDR}
N -80 30 -80 100 {
lab=bl_vDL}
N -80 100 -70 100 {
lab=bl_vDL}
N 100 70 100 130 {
lab=bl_vDR}
N -180 330 -30 330 {
lab=VSS}
N -180 130 -180 140 {
lab=bl_vDL}
N 100 130 100 140 {
lab=bl_vDR}
N -30 330 -30 430 {
lab=VSS}
N 100 280 100 330 {
lab=VSS}
N 70 250 100 250 {
lab=VSS}
N 70 250 70 330 {
lab=VSS}
N 20 330 100 330 {
lab=VSS}
N 100 140 100 220 {
lab=bl_vDR}
N -20 450 -20 470 {
lab=vbias}
N -220 440 -20 450 {
lab=vbias}
N -220 260 -220 440 {
lab=vbias}
N -20 450 150 440 {
lab=vbias}
N 140 250 150 440 {
lab=vbias}
N -130 -0 -80 30 {
lab=bl_vDL}
N -180 80 -80 60 {
lab=bl_vDL}
N 10 30 60 -0 {
lab=bl_vDR}
N -10 30 10 30 {
lab=bl_vDR}
N 10 60 100 70 {
lab=bl_vDR}
N -70 100 -70 130 {
lab=bl_vDL}
N -10 100 -10 130 {
lab=bl_vDR}
C {devices/iopin.sym} -420 -90 0 0 {name=p1 lab=VDD


}
C {devices/iopin.sym} -420 -60 0 0 {name=p2 lab=VSS


}
C {devices/lab_wire.sym} -30 -260 0 0 {name=p4 sig_type=std_logic lab=VDD}
C {devices/lab_wire.sym} -30 430 0 0 {name=p5 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -170 -100 0 0 {name=p3 lab=vin+
}
C {devices/ipin.sym} 100 -100 0 1 {name=p7 lab=vin-
}
C {devices/opin.sym} 90 -140 0 0 {name=p8 lab=vout-}
C {devices/opin.sym} -160 -150 0 1 {name=p12 lab=vout+}
C {devices/lab_wire.sym} 40 -210 0 0 {name=p13 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -150 -190 0 0 {name=p14 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -40 50 1 1 {name=p9 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} 40 -100 0 0 {name=p10 sig_type=std_logic lab=VSS}
C {devices/lab_wire.sym} -100 -100 0 1 {name=p15 sig_type=std_logic lab=VSS}
C {devices/ipin.sym} -20 470 0 0 {name=p16 lab=vbias
}
C {devices/lab_wire.sym} -130 -20 2 0 {name=p6 sig_type=std_logic lab=bl_vDL}
C {devices/lab_wire.sym} 60 -20 2 0 {name=p11 sig_type=std_logic lab=bl_vDR}
C {sky130_fd_pr/res_xhigh_po_0p35.sym} -40 30 3 0 {name=R4
L=1
model=res_xhigh_po_0p35
spiceprefix=X
mult=1}
C {sky130_fd_pr/res_high_po_0p35.sym} -130 -190 0 0 {name=R1
L=2
model=res_high_po_0p35
spiceprefix=X
mult=1}
C {sky130_fd_pr/res_high_po_0p35.sym} 60 -210 0 0 {name=R2
L=2
model=res_high_po_0p35
spiceprefix=X
mult=1}
C {sky130_fd_pr/cap_mim_m3_1.sym} -40 130 1 0 {name=C1 model=cap_mim_m3_1 W=30 L=30 MF=7 spiceprefix=X}
C {sky130_fd_pr/nfet_01v8.sym} -150 -100 0 0 {name=M1
L=0.15
W=40
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
C {sky130_fd_pr/nfet_01v8.sym} 80 -100 2 0 {name=M4
L=0.15
W=40
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
C {sky130_fd_pr/nfet_01v8.sym} -200 260 0 0 {name=M2
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
C {sky130_fd_pr/nfet_01v8.sym} 120 250 2 0 {name=M3
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
