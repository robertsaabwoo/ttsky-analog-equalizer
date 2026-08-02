/*
 * Copyright (c) 2026 robertsaabwoo
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// This is an analog project: the signal path (CTLE equalizer -> retiming
// latch pair -> differential-to-single-ended amp -> inverter chain) lives
// entirely in the xschem schematic / hand-drawn layout under ./xschem, not
// in synthesizable RTL. ua[0]/ua[1] (vin+/vin-) and ua[2] (vbias) are wired
// straight into that analog block, and its recovered digital clock output
// is bonded directly to the uo_out[0] pad at the layout level.
//
// This module is intentionally left empty -- it exists only as a stub so
// the Tiny Tapeout digital toolchain has a top module to instantiate, as is
// standard practice for pure-analog Tiny Tapeout submissions.
module tt_um_robertsaabwoo_ctle_clock_recovery (
    input  wire       VGND,
    input  wire       VDPWR,    // 1.8v power supply
//    input  wire       VAPWR,    // 3.3v power supply
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    inout  wire [7:0] ua,       // Analog pins, only ua[5:0] can be used
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

endmodule
