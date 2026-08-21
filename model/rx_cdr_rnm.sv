// ---------------------------------------------------------------------------
// rx_cdr_rnm.sv -- real-number (RNM) behavioural model of the CTLE + CDR
// receiver front end drawn in xschem/ctle_cdr_rx.sch.
//
// WHY THIS EXISTS
//   The silicon is a custom analog macro; the only synthesisable Verilog in the
//   project is src/project.v, a blackbox wrapper. That is correct for tapeout
//   but useless for system-level work -- you cannot drop a SPICE deck into a
//   link simulation. This expresses the analog behaviour as a discrete-time
//   real-number model, so the receiver closes in a testbench that runs in
//   seconds instead of the ~7-20 minutes a SPICE transient of the real chain
//   costs on this machine.
//
//   Every constant is MEASURED and cites the design-log section it came from,
//   EXCEPT the loop-filter R and C -- see the LOOP FILTER note below, which is
//   explicit that those two are fitted, not extracted.
//
// APPROACH
//   Fixed-step explicit Euler at TS (10 ps default = 166 steps per UI). One
//   always block advances channel, CTLE, phase detector, charge pump and VCO
//   together. Analog nodes are `real`; the recovered clock and the phase
//   decisions are the only genuinely digital signals.
//
// LIMITS -- read before quoting any number out of this model
//   * first-order channel, first-order CTLE. Real silicon has more poles.
//   * the ring oscillator is a phase accumulator: it models frequency and
//     phase but NOT the ring's own phase noise, so this model UNDERSTATES
//     jitter. Measured jitter is in NOTES_CTLE.md §C26/§C27, never from here.
//   * no noise, no mismatch, no PVT. Corner data comes from the SPICE PVT
//     harness in xschem/tuning/pvt/.
//   * the CDR is modelled as an ideal bang-bang loop: the real phase detector
//     is eight d_latch stages with finite setup time and a real metastability
//     window, none of which is here.
// ---------------------------------------------------------------------------
`timescale 1ps/1ps

module rx_cdr_rnm #(
    // ---- solver -----------------------------------------------------------
    parameter real TS    = 10e-12,     // Euler step. 10 ps = 166 steps/UI.
    parameter integer TS_PS = 10,      // same value in ps, for the delay ctrl

    // ---- channel: the Tiny Tapeout analog pin path ------------------------
    // <500 ohm series / <5 pF pad (tinytapeout.com/specs/analog). tau = 2.5 ns
    // -> pole at 63.7 MHz, far below the 300 MHz Nyquist of 600 Mb/s data.
    parameter real RPAD  = 500.0,
    parameter real CPAD  = 5e-12,

    // ---- CTLE -------------------------------------------------------------
    // FZ sits ON the pad pole so the zero cancels it by construction -- that
    // is the design intent. With FP = 1.2 GHz the gain at 300 MHz is
    //   sqrt(1+(300/63.7)^2)/sqrt(1+(300/1200)^2) = 4.67x = +13.4 dB,
    // matching the +13.5 dB at Nyquist measured in AC simulation.
    parameter real A0    = 1.0,
    parameter real FZ    = 63.7e6,
    parameter real FP    = 1.2e9,

    // ---- ring oscillator (VCO) -------------------------------------------
    // NOTES_CTLE.md:973 / NOTES.md §20b: 514-621 MHz over vctrl 0.65-0.95 V,
    // slope near lock ~357 MHz/V. F0 is the frequency at V0.
    parameter real KVCO  = 357e6,      // Hz per volt
    parameter real V0    = 0.80,       // vctrl at lock (§C26 measured ~0.80 V)
    parameter real F0    = 600.6e6,    // Hz at V0 -- the measured lock point
    parameter real FMIN  = 514e6,
    parameter real FMAX  = 621e6,

    // ---- charge pump ------------------------------------------------------
    // Directly measured in §C25-E: up 1.263 uA, down 1.284 uA (1.6% mismatch).
    // The mismatch is modelled because §C25-E exists specifically to refute a
    // hypothesis about it -- keeping it here lets that be re-tested cheaply.
    parameter real ICP_UP = 1.263e-6,
    parameter real ICP_DN = 1.284e-6,

    // ---- LOOP FILTER -- FITTED, NOT MEASURED ------------------------------
    // These two are the only non-measured constants in this file. They are
    // chosen so the model reproduces the measured closed-loop behaviour:
    // R*Icp sets the proportional step, and 2*R*Icp = 94 mV matches the
    // 93.8 mV pp residual vctrl ripple measured on PRBS7 in §C25-B. C sets
    // the integrator rate and hence acquisition time. Do NOT cite these as
    // the silicon's component values -- read them off the schematic for that.
    parameter real RLF   = 37.0e3,
    parameter real CLF   = 1.0e-12,

    parameter real VCTRL_INIT = 0.75   // precharge seeds vctrl into the
                                       // oscillator's active region (§17)
)(
    input  real  vin_diff,   // differential input AT THE PAD, volts
    output reg   rclk,       // recovered clock
    output reg   rdata       // recovered data (rising-edge sample)
    // vctrl and vctle are deliberately NOT ports: iverilog does not accept
    // `output real`. They are plain internal reals; a testbench reads them
    // hierarchically as dut.vctrl / dut.vctle, which is the usual RNM idiom.
);
    localparam real PI  = 3.14159265358979;
    localparam real TAU = RPAD * CPAD;
    localparam real WZ  = 2.0 * PI * FZ;
    localparam real WP  = 2.0 * PI * FP;
    localparam real DFF = A0 * WP / WZ;          // direct feedthrough term
    localparam real KLP = A0 * (1.0 - WP / WZ);  // low-pass branch gain

    real ypad   = 0.0;   // channel state
    real u      = 0.0;   // CTLE low-pass state
    real vcap   = VCTRL_INIT;
    real phase  = 0.0;   // VCO phase, normalised 0..1
    real fvco;
    real icp;
    real vctrl;              // ring oscillator control voltage
    real vctle;              // CTLE differential output (post-equalisation)

    reg  dsamp = 1'b0, esamp = 1'b0, dnew = 1'b0;
    reg  rclk_prev = 1'b0;
    // The decision is REGISTERED and made ONCE PER UI, at the rising edge,
    // using the edge sample taken half a UI earlier. It must NOT be a
    // continuous function of dsamp/esamp: those update at different instants,
    // so for the half-UI after each falling edge a combinational PD compares
    // the NEW edge sample against the OLD data pair -- which pumps the loop in
    // an arbitrary direction and walks vctrl into the rail. (Found exactly
    // that way: the first version of this model railed to 1.19 V.)
    reg  up = 1'b0, dn = 1'b0;

    initial begin
        rclk  = 1'b0;
        rdata = 1'b0;
        vctrl = VCTRL_INIT;
        vctle = 0.0;
    end

    always #(TS_PS) begin
        // ---- 1. channel: first-order RC ----------------------------------
        ypad  = ypad + (vin_diff - ypad) * (TS / TAU);

        // ---- 2. CTLE: zero+pole, split so the input is never differentiated
        u     = u + TS * WP * (KLP * ypad - u);
        vctle = DFF * ypad + u;

        // ---- 3. charge pump into the loop filter -------------------------
        // Asymmetric by construction: up and down currents differ by 1.6%.
        icp   = up ? ICP_UP : (dn ? -ICP_DN : 0.0);
        vcap  = vcap + icp * TS / CLF;
        // series R gives the proportional (bang-bang) term; the cap integrates
        vctrl = vcap + icp * RLF;

        // ---- 4. ring oscillator: phase accumulator -----------------------
        fvco  = F0 + KVCO * (vctrl - V0);
        if (fvco < FMIN) fvco = FMIN;            // the ring has a real range
        if (fvco > FMAX) fvco = FMAX;
        phase = phase + fvco * TS;
        if (phase >= 1.0) phase = phase - 1.0;
        rclk  = (phase < 0.5);

        // ---- 5. Alexander sampling, on BOTH clock edges ------------------
        // rising edge = the data sample (nominally the eye centre);
        // falling edge = the edge sample (nominally the data crossing).
        if (rclk && !rclk_prev) begin
            dnew  = (vctle > 0.0);               // D(n)
            // dsamp still holds D(n-1); esamp holds E taken between them.
            if (dnew !== dsamp) begin
                up = (esamp === dnew);           // E saw the NEW bit  -> LATE
                dn = (esamp === dsamp);          // E saw the OLD bit  -> EARLY
            end else begin
                up = 1'b0;                       // no transition, no
                dn = 1'b0;                       // information (run-length
            end                                  // blindness -- §C25-B)
            dsamp = dnew;
            rdata = dnew;
        end
        if (!rclk && rclk_prev) begin
            esamp = (vctle > 0.0);               // E(n)
        end
        rclk_prev = rclk;
    end
endmodule
