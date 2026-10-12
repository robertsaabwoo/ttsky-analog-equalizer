* cp_bias -- charge-pump bias from a resistor reference (item 2, 2026-10-12)
* Replaces tiny_pll_bias_gen as the source of bias_n / bias_p for the (taped-out,
* unchanged) tiny_pll_charge_pump. Iref = (VDD - Vgs) / R in xhigh_po_0p35,
* the loop filter's resistor material, so the proportional kick Icp x R_filter
* should hold over PVT. XND is a copy of the pump's current source (XMNSRC,
* W=1 L=1) and XPD of its PMOS source's mirror (bias_gen's XMPDIO, W=2 L=1).
* No start-up circuit: the resistor starts it.
.subckt cp_bias VDD VSS bias_n bias_p
XR bias_n VDD VSS sky130_fd_pr__res_xhigh_po_0p35 L=163 mult=1
XND bias_n bias_n VSS VSS sky130_fd_pr__nfet_01v8 L=1 W=1
XNM bias_p bias_n VSS VSS sky130_fd_pr__nfet_01v8 L=1 W=1
XPD bias_p bias_p VDD VDD sky130_fd_pr__pfet_01v8 L=1 W=2
.ends
