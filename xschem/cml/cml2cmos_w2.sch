v {xschem version=3.4.5 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
C {devices/iopin.sym} -400 0 0 0 {name=p1 lab=out}
C {devices/iopin.sym} -400 40 0 0 {name=p2 lab=inp}
C {devices/iopin.sym} -400 80 0 0 {name=p3 lab=inm}
C {devices/iopin.sym} -400 120 0 0 {name=p4 lab=VDD}
C {devices/iopin.sym} -400 160 0 0 {name=p5 lab=VSS}
C {devices/iopin.sym} -400 200 0 0 {name=p6 lab=vbias}
C {devices/lab_pin.sym} 220 -30 0 0 {name=l1 sig_type=std_logic lab=x}
C {devices/lab_pin.sym} 180 0 0 0 {name=l2 sig_type=std_logic lab=inp}
C {devices/lab_pin.sym} 220 30 0 0 {name=l3 sig_type=std_logic lab=t}
C {devices/lab_pin.sym} 220 0 0 0 {name=l4 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 200 0 0 0 {name=M1
L=0.15
W=2
nf=1
mult=1
ad="'2*0.29'"
as="'2*0.29'"
pd="'2*(2+0.29)'"
ps="'2*(2+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 480 -30 0 0 {name=l5 sig_type=std_logic lab=y}
C {devices/lab_pin.sym} 440 0 0 0 {name=l6 sig_type=std_logic lab=inm}
C {devices/lab_pin.sym} 480 30 0 0 {name=l7 sig_type=std_logic lab=t}
C {devices/lab_pin.sym} 480 0 0 0 {name=l8 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 460 0 0 0 {name=M2
L=0.15
W=2
nf=1
mult=1
ad="'2*0.29'"
as="'2*0.29'"
pd="'2*(2+0.29)'"
ps="'2*(2+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 740 30 0 0 {name=l9 sig_type=std_logic lab=x}
C {devices/lab_pin.sym} 700 0 0 0 {name=l10 sig_type=std_logic lab=x}
C {devices/lab_pin.sym} 740 -30 0 0 {name=l11 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 740 0 0 0 {name=l12 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 720 0 0 0 {name=P1
L=0.15
W=1
nf=1
mult=1
ad="'1*0.29'"
as="'1*0.29'"
pd="'2*(1+0.29)'"
ps="'2*(1+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=pfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 1000 30 0 0 {name=l13 sig_type=std_logic lab=y}
C {devices/lab_pin.sym} 960 0 0 0 {name=l14 sig_type=std_logic lab=x}
C {devices/lab_pin.sym} 1000 -30 0 0 {name=l15 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1000 0 0 0 {name=l16 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 980 0 0 0 {name=P2
L=0.15
W=1
nf=1
mult=1
ad="'1*0.29'"
as="'1*0.29'"
pd="'2*(1+0.29)'"
ps="'2*(1+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=pfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 1260 -30 0 0 {name=l17 sig_type=std_logic lab=t}
C {devices/lab_pin.sym} 1220 0 0 0 {name=l18 sig_type=std_logic lab=vbias}
C {devices/lab_pin.sym} 1260 30 0 0 {name=l19 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 1260 0 0 0 {name=l20 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 1240 0 0 0 {name=Mt
L=0.5
W=2
nf=1
mult=1
ad="'2*0.29'"
as="'2*0.29'"
pd="'2*(2+0.29)'"
ps="'2*(2+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 1520 30 0 0 {name=l21 sig_type=std_logic lab=z}
C {devices/lab_pin.sym} 1480 0 0 0 {name=l22 sig_type=std_logic lab=y}
C {devices/lab_pin.sym} 1520 -30 0 0 {name=l23 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 1520 0 0 0 {name=l24 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 1500 0 0 0 {name=Pi1
L=0.15
W=1
nf=1
mult=1
ad="'1*0.29'"
as="'1*0.29'"
pd="'2*(1+0.29)'"
ps="'2*(1+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=pfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 220 170 0 0 {name=l25 sig_type=std_logic lab=z}
C {devices/lab_pin.sym} 180 200 0 0 {name=l26 sig_type=std_logic lab=y}
C {devices/lab_pin.sym} 220 230 0 0 {name=l27 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 220 200 0 0 {name=l28 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 200 200 0 0 {name=Ni1
L=0.15
W=0.5
nf=1
mult=1
ad="'0.5*0.29'"
as="'0.5*0.29'"
pd="'2*(0.5+0.29)'"
ps="'2*(0.5+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 480 230 0 0 {name=l29 sig_type=std_logic lab=out}
C {devices/lab_pin.sym} 440 200 0 0 {name=l30 sig_type=std_logic lab=z}
C {devices/lab_pin.sym} 480 170 0 0 {name=l31 sig_type=std_logic lab=VDD}
C {devices/lab_pin.sym} 480 200 0 0 {name=l32 sig_type=std_logic lab=VDD}
C {sky130_fd_pr/pfet_01v8.sym} 460 200 0 0 {name=Pi2
L=0.15
W=2
nf=1
mult=1
ad="'2*0.29'"
as="'2*0.29'"
pd="'2*(2+0.29)'"
ps="'2*(2+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=pfet_01v8
spiceprefix=X}
C {devices/lab_pin.sym} 740 170 0 0 {name=l33 sig_type=std_logic lab=out}
C {devices/lab_pin.sym} 700 200 0 0 {name=l34 sig_type=std_logic lab=z}
C {devices/lab_pin.sym} 740 230 0 0 {name=l35 sig_type=std_logic lab=VSS}
C {devices/lab_pin.sym} 740 200 0 0 {name=l36 sig_type=std_logic lab=VSS}
C {sky130_fd_pr/nfet_01v8.sym} 720 200 0 0 {name=Ni2
L=0.15
W=1
nf=1
mult=1
ad="'1*0.29'"
as="'1*0.29'"
pd="'2*(1+0.29)'"
ps="'2*(1+0.29)'"
nrd=0
nrs=0
sa=0
sb=0
sd=0
model=nfet_01v8
spiceprefix=X}
