`timescale 1ns / 1ps

module tb_fir_filter ();

    localparam int WW_DATA    = 8;
    localparam int N_SAMPLES  = 1024;
    localparam int LATENCY    = 3;   //! prod_d + sum_d + sum3_d
    localparam int CLK_PERIOD = 10;

    logic                      clk = 0;
    logic                      i_srst;
    logic                      i_en;
    logic signed [WW_DATA-1:0] i_data;
    logic signed [WW_DATA-1:0] o_data;

    logic signed [WW_DATA-1:0] stimulus   [        0:N_SAMPLES-1];
    logic signed [WW_DATA-1:0] golden     [        0:N_SAMPLES-1];
    logic signed [WW_DATA-1:0] captured   [0:N_SAMPLES+LATENCY-1];

    integer                    n;
    integer                    errors = 0;

    always #(CLK_PERIOD / 2) clk = ~clk;

    fir_filter #(
        .WW_INPUT (WW_DATA),
        .WW_OUTPUT(WW_DATA)
    ) u_fir_filter (
        .clk   (clk),
        .i_en  (i_en),
        .i_srst(i_srst),
        .i_data(i_data),
        .o_data(o_data)
    );

    //! $readmemh reads bit patterns; the arrays are signed, so FF reads as -1.
    initial begin
        $readmemh("mem.hex", stimulus);
        $readmemh("golden.hex", golden);
    end

    initial begin
        $dumpfile("tb_fir_filter.vcd");
        $dumpvars(0, tb_fir_filter);

        i_srst = 1'b1;
        i_en   = 1'b1;
        i_data = '0;
        repeat (4) @(negedge clk);
        i_srst = 1'b0;

        //! One sample per clock, driven on the falling edge.
        for (n = 0; n < N_SAMPLES + LATENCY; n = n + 1) begin
            @(negedge clk);
            i_data = (n < N_SAMPLES) ? stimulus[n] : '0;
            #1;
            captured[n] = o_data;
        end

        //! captured[n + LATENCY] is the response to stimulus[n].
        for (n = 0; n < N_SAMPLES; n = n + 1) begin
            if (captured[n+LATENCY] !== golden[n]) begin
                if (errors < 10)
                    $display(
                        "  MISMATCH n=%0d  x=%0d  rtl=%0d  golden=%0d",
                        n,
                        stimulus[n],
                        captured[n+LATENCY],
                        golden[n]
                    );
                errors = errors + 1;
            end
        end

        $display("\n  samples checked : %0d", N_SAMPLES);
        $display("  mismatches      : %0d", errors);
        if (errors == 0) $display("  RESULT: PASS\n");
        else $display("  RESULT: FAIL\n");
        $finish;
    end

endmodule
