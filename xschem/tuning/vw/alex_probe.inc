* frozen alexander_phase_detector with B+/B- (as bp/bm) and Q5 (net1/net2), Q2 (net5/net6) brought out
.subckt alex_probe VDD VSS down up clk+ vin+ clk- vin- vbias bp bm net1 net2 net5 net6
x6 net1 VDD bm VSS down net2 bp robs_xor
x7 net5 VDD bm VSS up net6 bp robs_xor
x5 VDD VSS net1 net2 vin+ clk+ clk- vin- vbias d_flip_flop
x1 VDD VSS net3 net4 vin+ clk- clk+ vin- vbias d_flip_flop
x2 VDD VSS net5 net6 net1 clk+ clk- net2 vbias d_flip_flop
x3 VDD VSS bp bm net3 clk+ clk- net4 vbias d_flip_flop
.ends
