v {xschem version=3.4.5 file_version=1.2
}
G {}
K {}
V {}
S {}
E {}
T {CTLE + CDR receiver -- the analog macro that Tiny Tapeout instantiates.

  ua[0]/ua[1] --> CTLE --> CDR (Alexander PD + charge pump + loop filter
  + ring VCO + startup precharge) --> recovered clock --> inverter chains.

Validated end to end in tuning/e2e_ctle_cdr_tb.spice (NOTES_CTLE C23/C24):
locks at 600.64 MHz through the 500ohm/5pF TinyTapeout analog-pin LPF.

BOTH recovered-clock phases are buffered, so the ring sees a SYMMETRIC
load.  Driving only rclk+ would load one leg of a differential oscillator
and skew its duty cycle.} -830 -320 0 0 0.4 0.4 {}
N -830 -30 -750 -30 {
lab=vinp}
N -830 -10 -750 -10 {
lab=vinm}
N -830 10 -750 10 {
lab=vbias}
N -450 -30 -370 -30 {
lab=eq_p}
N -450 -10 -370 -10 {
lab=eq_m}
N -450 10 -370 10 {
lab=VDPWR}
N -450 30 -370 30 {
lab=VGND}
N -230 -30 -150 -30 {
lab=eq_p}
N -230 -10 -150 -10 {
lab=eq_m}
N -230 10 -150 10 {
lab=vbias}
N 150 -30 230 -30 {
lab=VDPWR}
N 150 -10 230 -10 {
lab=VGND}
N 150 10 230 10 {
lab=rclk_p}
N 150 30 230 30 {
lab=rclk_m}
N 370 -120 450 -120 {
lab=rclk_p}
N 750 -120 830 -120 {
lab=VDPWR}
N 750 -100 830 -100 {
lab=VGND}
N 750 -80 830 -80 {
lab=clkout_p}
N 370 80 450 80 {
lab=rclk_m}
N 750 80 830 80 {
lab=VDPWR}
N 750 100 830 100 {
lab=VGND}
N 750 120 830 120 {
lab=clkout_n}
C {CTLE.sym} -600 0 0 0 {name=x1}
C {CDR.sym} 0 0 0 0 {name=x2}
C {inverter_chain.sym} 600 -100 0 0 {name=x3}
C {inverter_chain.sym} 600 100 0 0 {name=x4}
C {devices/ipin.sym} -830 -30 0 0 {name=p1 lab=vinp}
C {devices/ipin.sym} -830 -10 0 0 {name=p2 lab=vinm}
C {devices/ipin.sym} -830 10 0 0 {name=p3 lab=vbias}
C {devices/opin.sym} 830 -80 0 0 {name=p4 lab=clkout_p}
C {devices/opin.sym} 830 120 0 0 {name=p5 lab=clkout_n}
C {devices/iopin.sym} -830 -180 0 0 {name=p6 lab=VDPWR}
C {devices/iopin.sym} -830 -150 0 0 {name=p7 lab=VGND}
C {devices/lab_wire.sym} -370 -30 0 0 {name=l1 sig_type=std_logic lab=eq_p}
C {devices/lab_wire.sym} -370 -10 0 0 {name=l2 sig_type=std_logic lab=eq_m}
C {devices/lab_wire.sym} -370 10 0 0 {name=l3 sig_type=std_logic lab=VDPWR}
C {devices/lab_wire.sym} -370 30 0 0 {name=l4 sig_type=std_logic lab=VGND}
C {devices/lab_wire.sym} -230 -30 0 0 {name=l5 sig_type=std_logic lab=eq_p}
C {devices/lab_wire.sym} -230 -10 0 0 {name=l6 sig_type=std_logic lab=eq_m}
C {devices/lab_wire.sym} -230 10 0 0 {name=l7 sig_type=std_logic lab=vbias}
C {devices/lab_wire.sym} 230 -30 0 0 {name=l8 sig_type=std_logic lab=VDPWR}
C {devices/lab_wire.sym} 230 -10 0 0 {name=l9 sig_type=std_logic lab=VGND}
C {devices/lab_wire.sym} 230 10 0 0 {name=l10 sig_type=std_logic lab=rclk_p}
C {devices/lab_wire.sym} 230 30 0 0 {name=l11 sig_type=std_logic lab=rclk_m}
C {devices/lab_wire.sym} 370 -120 0 0 {name=l12 sig_type=std_logic lab=rclk_p}
C {devices/lab_wire.sym} 830 -120 0 0 {name=l13 sig_type=std_logic lab=VDPWR}
C {devices/lab_wire.sym} 830 -100 0 0 {name=l14 sig_type=std_logic lab=VGND}
C {devices/lab_wire.sym} 370 80 0 0 {name=l15 sig_type=std_logic lab=rclk_m}
C {devices/lab_wire.sym} 830 80 0 0 {name=l16 sig_type=std_logic lab=VDPWR}
C {devices/lab_wire.sym} 830 100 0 0 {name=l17 sig_type=std_logic lab=VGND}
