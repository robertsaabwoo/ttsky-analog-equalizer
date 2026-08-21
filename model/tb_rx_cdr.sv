// ---------------------------------------------------------------------------
// tb_rx_cdr.sv -- self-checking testbench for the RNM receiver model.
//
// Drives PRBS7 at 600.6 Mb/s (UI = 1.665 ns) into the pad, 200 mV
// differential, and checks three things:
//
//   1. the loop FREQUENCY-LOCKS -- the recovered clock, averaged over a long
//      settled window, is within tolerance of the data rate;
//   2. vctrl SETTLES -- two separated late windows agree. This is the check
//      §C26 skipped, which is why its phase number was unusable;
//   3. the data is actually RECOVERED -- recovered bits are compared against
//      the transmitted PRBS7 after searching for the sampling latency, and
//      the bit-error count must be zero.
//
// Exits non-zero on failure so CI and pytest can gate on it.
// ---------------------------------------------------------------------------
`timescale 1ps/1ps

module tb_rx_cdr;
    localparam real UI      = 1.665e-9;
    localparam integer UI_PS = 1665;
    localparam real AMP     = 0.1;        // +/-100 mV = 200 mV differential
    localparam integer NBITS = 2000;

    real vin;
    wire rclk, rdata;

    rx_cdr_rnm dut (.vin_diff(vin), .rclk(rclk), .rdata(rdata));

    // ---- PRBS7 source, x^7 + x^6 + 1 -- same polynomial as gen_prbs.py ----
    reg [6:0] lfsr = 7'h7F;
    reg txbit [0:NBITS-1];
    integer i, fb;
    initial begin
        for (i = 0; i < NBITS; i = i + 1) begin
            fb   = ((lfsr >> 6) ^ (lfsr >> 5)) & 1;
            lfsr = ((lfsr << 1) | fb[0]) & 7'h7F;
            txbit[i] = fb[0];
        end
    end

    // drive the pad from the bit stream
    integer bidx;
    initial begin
        vin = 0.0;
        forever begin
            bidx = ($time / UI_PS);
            if (bidx >= NBITS) bidx = NBITS - 1;
            vin  = txbit[bidx] ? AMP : -AMP;
            #10;
        end
    end

    // ---- capture recovered bits ------------------------------------------
    reg rxbit [0:NBITS-1];
    integer rxn = 0;
    real    rxt [0:NBITS-1];
    always @(posedge rclk) begin
        if (rxn < NBITS) begin
            rxbit[rxn] = rdata;
            rxt[rxn]   = $realtime * 1e-12;
            rxn = rxn + 1;
        end
    end

    // ---- measurement ------------------------------------------------------
    integer n_start, n_end, off, best_off, errs, best_errs, k, checked;
    real t_start, t_end, freq, v_w1, v_w2, dv;
    integer nfail = 0;

    // vctrl averaged over a window, sampled by polling
    real acc1 = 0.0, acc2 = 0.0; integer c1 = 0, c2 = 0;
    always #10 begin
        if ($realtime > 2000000.0 && $realtime <= 2200000.0) begin
            acc1 = acc1 + dut.vctrl; c1 = c1 + 1;
        end
        if ($realtime > 2700000.0 && $realtime <= 2900000.0) begin
            acc2 = acc2 + dut.vctrl; c2 = c2 + 1;
        end
    end

    initial begin
        #3000000;   // 3 us

        $display("--- rx_cdr_rnm : PRBS7 @ 600.6 Mb/s, 200 mV diff at the pad ---");
        $display("recovered clock edges captured : %0d", rxn);

        // 1. frequency over a settled span (skip the first 1.5 us)
        n_start = 0;
        while (n_start < rxn && rxt[n_start] < 1.5e-6) n_start = n_start + 1;
        n_end = rxn - 1;
        if (n_end - n_start < 200) begin
            $display("FAIL: too few settled edges (%0d)", n_end - n_start);
            nfail = nfail + 1;
        end else begin
            t_start = rxt[n_start];
            t_end   = rxt[n_end];
            freq    = (n_end - n_start) / (t_end - t_start);
            $display("recovered clock frequency      : %.2f MHz (data rate %.2f MHz)",
                     freq / 1e6, 1.0 / UI / 1e6);
            if (freq < 0.98 / UI || freq > 1.02 / UI) begin
                $display("FAIL: not frequency-locked (outside +/-2%%)");
                nfail = nfail + 1;
            end
        end

        // 2. vctrl settled: the two late windows must agree
        v_w1 = (c1 > 0) ? acc1 / c1 : 0.0;
        v_w2 = (c2 > 0) ? acc2 / c2 : 0.0;
        dv   = (v_w1 > v_w2) ? (v_w1 - v_w2) : (v_w2 - v_w1);
        $display("vctrl 2.0-2.2us / 2.7-2.9us    : %.4f V / %.4f V  (drift %.2f mV)",
                 v_w1, v_w2, dv * 1e3);
        if (dv > 0.010) begin
            $display("FAIL: vctrl still moving (>10 mV between late windows)");
            nfail = nfail + 1;
        end

        // 3. bit recovery: search the sampling latency, then require 0 errors
        best_errs = 1000000; best_off = -1;
        for (off = 0; off < 24; off = off + 1) begin
            errs = 0; checked = 0;
            for (k = n_start; k < n_end; k = k + 1) begin
                if ((k + off) < NBITS) begin
                    checked = checked + 1;
                    if (rxbit[k] !== txbit[k + off]) errs = errs + 1;
                end
            end
            if (checked > 100 && errs < best_errs) begin
                best_errs = errs; best_off = off;
            end
        end
        $display("bit errors (best latency = %0d)  : %0d over %0d bits",
                 best_off, best_errs, n_end - n_start);
        if (best_errs != 0) begin
            $display("FAIL: recovered data does not match the transmitted PRBS7");
            nfail = nfail + 1;
        end

        if (nfail == 0) $display("RESULT: PASS");
        else begin
            $display("RESULT: FAIL (%0d checks failed)", nfail);
            $fatal(1);
        end
        $finish;
    end
endmodule
