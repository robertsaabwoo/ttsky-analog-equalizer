/*
 * Copyright (c) 2026 robertsaabwoo
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// ---------------------------------------------------------------------------
// Analog receiver front end: CTLE + reference-less bang-bang CDR.
//
// This is a custom-GDS analog project (see .github/workflows/gds.yaml, which
// uses tt-gds-action/custom_gds).  The signal path is hand-drawn in
// xschem/magic, not synthesized -- so this file is *structural blackbox*
// Verilog whose only jobs are:
//
//   1. give the Tiny Tapeout harness a top module with the standard port list;
//   2. describe the pad <-> analog-macro wiring, so `make lvs` in mag/ can
//      check the layout against it.  netgen reads this file as the source-side
//      top and picks up `ctle_cdr_rx` from the xschem netlist
//      (xschem/simulation/ctle_cdr_rx_lvs.spice) -- see mag/tcl/lvs_netgen.tcl.
//
// The names and wires below must therefore match the intended layout exactly.
// ---------------------------------------------------------------------------
module tt_um_robertsaabwoo_ctle_clock_recovery (
    input  wire       VGND,
    input  wire       VDPWR,    // 1.8v power supply
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    inout  wire [7:0] ua,       // Analog pins, only ua[5:0] can be used
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock (unused: the clock is RECOVERED, not supplied)
    input  wire       rst_n     // reset_n - low to reset
);

  // The whole receiver.  ua[0]/ua[1] are the differential input pair straight
  // off the analog mux; ua[2] is the external bias reference.  Both recovered
  // clock phases are buffered out -- clkout_n is not decorative, it keeps the
  // ring oscillator's two legs symmetrically loaded.
  ctle_cdr_rx u_rx (
      .vinp    (ua[0]),
      .vinm    (ua[1]),
      .vbias   (ua[2]),
      .clkout_p(uo_out[0]),
      .clkout_n(uo_out[1]),
      .VDPWR   (VDPWR),
      .VGND    (VGND)
  );

  // uo_out[7:2], uio_* and the digital inputs are physically unconnected in the
  // layout -- this is an analog tile with no digital logic in it.  They are left
  // undriven here rather than tied off, so that this Verilog keeps matching a
  // layout that contains no tie cells.

endmodule

// Blackbox declaration of the hand-laid-out analog macro.  Its contents come
// from the GDS; for LVS the matching subcircuit comes from the xschem netlist.
(* blackbox *)
module ctle_cdr_rx (
    input  wire vinp,      // ua[0]  differential input +
    input  wire vinm,      // ua[1]  differential input -
    input  wire vbias,     // ua[2]  external bias reference (~0.9 V)
    output wire clkout_p,  // recovered clock, true
    output wire clkout_n,  // recovered clock, inverted (see docs: not a true complement)
    // Declared `input` to match how the TT harness hands VDPWR/VGND to the user
    // module. They are of course the macro's supply rails; netgen matches the
    // power pins by name, so the Verilog direction here does not affect LVS.
    input  wire VDPWR,
    input  wire VGND
);
endmodule

`default_nettype wire
