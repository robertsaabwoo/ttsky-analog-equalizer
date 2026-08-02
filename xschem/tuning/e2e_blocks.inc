.subckt CDR_tune Vdd Vss vin+ vin- vbias rclk+ rclk-
*.iopin Vdd
*.iopin Vss
*.ipin vin+
*.ipin vin-
*.ipin vbias
*.opin rclk+
*.opin rclk-
x6 Vdd Vdd Vss Vss net1 net2 net3 bias_n bias_p tiny_pll_charge_pump
x8 Vss Vss Vdd Vdd bias_n Vdd Vss bias_p tiny_pll_bias_gen
x2 Vss Vss Vdd Vdd net1 tiny_pll_loop_filter_tune
x3 Vdd Vss net3 net2 rclk+ vin+ rclk- vin- vbias alexander_phase_detector_tune
x1 Vdd Vss net1 net4 net5 ring_oscillator_tune
x4 Vdd Vss clkraw- clkraw+ net4 net5 Vdd diff_amp_inv_tune
x11 Vdd Vss clkraw+ rclk+ inverter_buffer_tune
x12 Vdd Vss rclk+ rclk- single_inverter_tune
x20 Vdd Vss net1 vctrl_precharge_tune
.ends
.subckt tiny_pll_charge_pump VPWR VPB VGND VNB out up down bias_n bias_p
*.ipin up
*.ipin down
*.iopin VNB
*.iopin VGND
*.iopin VPB
*.iopin VPWR
*.opin out
*.ipin bias_n
*.ipin bias_p
XMNSRC src_n bias_n VGND VNB sky130_fd_pr__nfet_01v8 L=1 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMNSW out down src_n VNB sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPSW out upb src_p VPB sky130_fd_pr__pfet_01v8 L=0.15 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPSRC src_p bias_p VPWR VPB sky130_fd_pr__pfet_01v8 L=1 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XINV up VGND VNB VPB VPWR upb sky130_fd_sc_hd__inv_1
.ends
.subckt tiny_pll_bias_gen VGND VNB VPWR VPB bias_n en enb bias_p
*.iopin VNB
*.iopin VGND
*.iopin VPB
*.iopin VPWR
*.opin bias_n
*.ipin enb
*.ipin en
*.opin bias_p
XMNMIR bias_p bias_n VGND VNB sky130_fd_pr__nfet_01v8 L=1 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMNDIO bias_n bias_n VGND VNB sky130_fd_pr__nfet_01v8 L=1 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPDIO bias_p bias_p VPWR VPB sky130_fd_pr__pfet_01v8 L=1 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPMIR bias_n bias_p res_bot VPB sky130_fd_pr__pfet_01v8 L=1 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=2 m=2
* noconn VPB
XMNEN1 bias_n enb VGND VNB sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPEN1 bias_p en VPWR VPB sky130_fd_pr__pfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XRES VGND VNB VPWR VPB VPWR res_bot tiny_pll_bias_gen_res
XMNSU1 kick bias_n VGND VNB sky130_fd_pr__nfet_01v8 L=1 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMNSU2 bias_p kick kick_sw VNB sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf
+ * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMNEN2 kick_sw en VGND VNB sky130_fd_pr__nfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPEN2 kick en VPWR VPB sky130_fd_pr__pfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPSU2 kick kick dio_mid VPB sky130_fd_pr__pfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf *
+ 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMPSU1 dio_mid dio_mid VPWR VPB sky130_fd_pr__pfet_01v8 L=0.15 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf
+ * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
.subckt tiny_pll_loop_filter_tune VGND VNB VPWR VPB vctl
*.iopin vctl
*.iopin VGND
*.iopin VNB
*.iopin VPWR
*.iopin VPB
XC1 VGND VNB VPWR VPB cap_plus VGND tiny_pll_loop_filter_cap1_tune
XR VGND VNB VPWR VPB vctl cap_plus tiny_pll_loop_filter_res
XC2 VGND VNB VPWR VPB vctl VGND tiny_pll_loop_filter_cap2_tune
.ends
.subckt alexander_phase_detector_tune VDD VSS down up clk+ vin+ clk- vin- vbias
*.opin down
*.opin up
*.ipin vin+
*.ipin vin-
*.ipin clk+
*.ipin clk-
*.ipin vbias
*.iopin VDD
*.iopin VSS
x6 net1 VDD B- VSS down net2 B+ robs_xor_tune
x7 net5 VDD B- VSS up net6 B+ robs_xor_tune
x5 VDD VSS net1 net2 vin+ clk+ clk- vin- vbias d_flip_flop_tune
x1 VDD VSS net3 net4 vin+ clk- clk+ vin- vbias d_flip_flop_tune
x2 VDD VSS net5 net6 net1 clk+ clk- net2 vbias d_flip_flop_tune
x3 VDD VSS B+ B- net3 clk+ clk- net4 vbias d_flip_flop_tune
.ends
.subckt ring_oscillator_tune Vdd Vss vctrl vo+ vo-
*.iopin Vdd
*.iopin Vss
*.ipin vctrl
*.opin vo+
*.opin vo-
x1 Vdd Vss net7 net1 net8 net2 vctrl ring_inverter_tune
x2 Vdd Vss net1 net4 net2 net3 vctrl ring_inverter_tune
x3 Vdd Vss net4 net5 net3 net6 vctrl ring_inverter_tune
x5 Vdd Vss net5 net9 net6 net10 vctrl ring_inverter_tune
x4 Vdd Vss net9 net7 net10 net8 vctrl ring_inverter_tune
x6 Vdd Vss vo- vo+ net7 net8 Vdd diff_amp_inv_tune
.ends
.subckt diff_amp_inv_tune VDD VSS vo- vo+ vin- vin+ vctrl
*.iopin VDD
*.iopin VSS
*.ipin vin-
*.ipin vctrl
*.ipin vin+
*.opin vo+
*.opin vo-
XM2 vo-_temp vin- net1 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM3 net1 vctrl VSS VSS sky130_fd_pr__nfet_01v8 L=1 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM6 vo+_temp vin+ net1 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR3 vo+_temp VDD VSS sky130_fd_pr__res_high_po W=0.5 L=10 mult=1 m=1
XR4 vo-_temp VDD VSS sky130_fd_pr__res_high_po W=0.5 L=10 mult=1 m=1
XM1 vo- vo-_temp net2 VSS sky130_fd_pr__nfet_01v8 L=0.5 W=6 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 net2 vctrl VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=8 nf=4 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM5 vo+ vo+_temp net2 VSS sky130_fd_pr__nfet_01v8 L=0.5 W=6 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR1 vo+ VDD VSS sky130_fd_pr__res_high_po W=1 L=17.5 mult=1 m=1
XR2 vo- VDD VSS sky130_fd_pr__res_high_po W=1 L=17.5 mult=1 m=1
.ends
.subckt inverter_buffer_tune VDD VSS weak_in STRONG_OUT
*.iopin VDD
*.iopin VSS
*.ipin weak_in
*.opin STRONG_OUT
XM3 net1 weak_in VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=6 nf=4 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 net1 weak_in VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=7 nf=2 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM5 STRONG_OUT net1 VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=16 nf=8 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM6 STRONG_OUT net1 VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=8 nf=4 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
.subckt single_inverter_tune VDD VSS IN OUT
*.iopin VDD
*.iopin VSS
*.ipin IN
*.opin OUT
XM1 OUT IN VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=16 nf=8 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM2 OUT IN VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=8 nf=4 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
.subckt vctrl_precharge_tune VDD VSS VCTL
*.iopin VDD
*.iopin VSS
*.iopin VCTL
XR1 nrc VDD VSS sky130_fd_pr__res_xhigh_po_0p35 L=120 mult=1 m=1
XMCPOR VSS nrc VSS VSS sky130_fd_pr__nfet_01v8 L=8 W=8 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMP1 pre nrc VDD VDD sky130_fd_pr__pfet_01v8 L=1 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMN1 pre nrc VSS VSS sky130_fd_pr__nfet_01v8 L=1 W=0.5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMP2 preb pre VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMN2 preb pre VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMBP nbias preb VDD VDD sky130_fd_pr__pfet_01v8 L=1 W=6 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMBD nbias nbias VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=6 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XMSW nbias pre VCTL VSS sky130_fd_pr__nfet_01v8 L=0.6 W=8 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
.subckt tiny_pll_bias_gen_res VGND VNB VPWR VPB plus minus
*.iopin minus
*.iopin plus
*.iopin VNB
*.iopin VGND
*.iopin VPB
*.iopin VPWR
XR2 mid1 plus VNB sky130_fd_pr__res_xhigh_po_0p35 L=1.8 mult=1 m=1
XR1 mid0 mid1 VNB sky130_fd_pr__res_xhigh_po_0p35 L=1.8 mult=1 m=1
XR0 minus mid0 VNB sky130_fd_pr__res_xhigh_po_0p35 L=1.8 mult=1 m=1
* noconn VPB
* noconn VPWR
* noconn VGND
.ends
.subckt tiny_pll_loop_filter_cap1_tune VGND VNB VPWR VPB plus minus
*.iopin VGND
*.iopin VNB
*.iopin VPWR
*.iopin VPB
*.iopin plus
*.iopin minus
* noconn VPWR
* noconn VPB
* noconn VGND
* noconn VNB
XMCAP minus plus minus VNB sky130_fd_pr__nfet_01v8 L=0.6 W=4 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=6 m=6
.ends
.subckt tiny_pll_loop_filter_res VGND VNB VPWR VPB plus minus
*.iopin VGND
*.iopin VNB
*.iopin VPWR
*.iopin VPB
*.iopin plus
*.iopin minus
XR minus plus VNB sky130_fd_pr__res_xhigh_po_0p35 L=15 mult=1 m=1
* noconn VGND
* noconn VPWR
* noconn VPB
.ends
.subckt tiny_pll_loop_filter_cap2_tune VGND VNB VPWR VPB plus minus
*.iopin VGND
*.iopin VNB
*.iopin VPWR
*.iopin VPB
*.iopin plus
*.iopin minus
* noconn VPWR
* noconn VPB
XMCAP minus plus minus VNB sky130_fd_pr__nfet_01v8 L=2 W=1.1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
.subckt robs_xor_tune A VDD B- VSS xor_out A- B
*.opin xor_out
*.ipin A
*.ipin B-
*.ipin A-
*.ipin B
*.iopin VDD
*.iopin VSS
XM5 net1 A VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM6 xor_out A- net3 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM1 xor_out B- net1 VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM2 net2 A- VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM3 xor_out B net2 VDD sky130_fd_pr__pfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 net3 B- VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM7 xor_out A net4 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM8 net4 B VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=2 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
.ends
.subckt d_flip_flop_tune Vdd Vss Q Qn vin+ clk+ clk- vin- vbias
*.opin Qn
*.opin Q
*.ipin vin+
*.ipin vin-
*.ipin clk+
*.ipin clk-
*.ipin vbias
*.iopin Vdd
*.iopin Vss
x1 net1 net2 vin+ vin- Vdd Vss clk- clk+ vbias d_latch_tune
x2 Q Qn net1 net2 Vdd Vss clk+ clk- vbias d_latch_tune
.ends
.subckt ring_inverter_tune VDD VSS vin+ vo+ vin- vo- vctrl
*.iopin VDD
*.iopin VSS
*.opin vo+
*.ipin vin-
*.ipin vctrl
*.opin vo-
*.ipin vin+
XM4 vo- vin- net1 VSS sky130_fd_pr__nfet_01v8 L=1 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM5 net1 vctrl VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=9 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM1 vo+ vin+ net1 VSS sky130_fd_pr__nfet_01v8 L=1 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR1 vo+ VDD VSS sky130_fd_pr__res_high_po W=1 L=23 mult=1 m=1
XR2 vo- VDD VSS sky130_fd_pr__res_high_po W=1 L=23 mult=1 m=1
.ends
.subckt d_latch_tune vout+ vout- vin+ vin- VDD VSS clk+ clk- vbias
*.iopin VDD
*.iopin VSS
*.ipin vin+
*.ipin clk-
*.ipin vbias
*.opin vout+
*.ipin clk+
*.opin vout-
*.ipin vin-
XM1 net1 vin+ net3 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM2 net4 vbias VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=8 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 net2 vin- net3 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM3 net2 net1 net5 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM5 net1 net2 net5 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM6 net3 clk+ net4 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM7 net5 clk- net4 VSS sky130_fd_pr__nfet_01v8 L=0.15 W=5 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM8 vout+ net1 VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM9 vout+ net1 VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM10 vout- net2 VDD VDD sky130_fd_pr__pfet_01v8 L=0.15 W=3 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM11 vout- net2 VSS VSS sky130_fd_pr__nfet_01v8 L=0.15 W=1 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2)
+ * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR3 net1 VDD VSS sky130_fd_pr__res_high_po_0p69 L=7 mult=1 m=1
XR1 net2 VDD VSS sky130_fd_pr__res_high_po_0p69 L=7 mult=1 m=1
.ends
* --- CTLE_tune (from ctle/chain_blocks.inc) ---
.subckt CTLE_tune vout+ vout- vin+ vin- VDD VSS vbias
*.iopin VDD
*.iopin VSS
*.ipin vin+
*.ipin vin-
*.ipin vbias
*.opin vout-
*.opin vout+
XM1 vout+ vin+ net1 VSS sky130_fd_pr__nfet_01v8 L=0.3 W=10 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)'
+ ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM2 net2 vbias VSS VSS sky130_fd_pr__nfet_01v8 L=0.5 W=20 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29' pd='2*int((nf+1)/2) * (W/nf + 0.29)'
+ ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XM4 vout- vin- sdegm VSS sky130_fd_pr__nfet_01v8 L=0.3 W=10 nf=1 ad='int((nf+1)/2) * W/nf * 0.29' as='int((nf+2)/2) * W/nf * 0.29'
+ pd='2*int((nf+1)/2) * (W/nf + 0.29)' ps='2*int((nf+2)/2) * (W/nf + 0.29)' nrd='0.29 / W' nrs='0.29 / W' sa=0 sb=0 sd=0 mult=1 m=1
XR1 vout+ VDD VSS sky130_fd_pr__res_high_po W=1 L=20 mult=1 m=1
XR2 vout- VDD VSS sky130_fd_pr__res_high_po W=1 L=20 mult=1 m=1
XR3 net1 net2 VSS sky130_fd_pr__res_high_po W=1 L=1.5 mult=1 m=1
XCS net1 sdegm sky130_fd_pr__cap_mim_m3_1 W=18 L=18 MF=1 m=1
XR4 sdegm net2 VSS sky130_fd_pr__res_high_po W=1 L=1.5 mult=1 m=1
.ends
