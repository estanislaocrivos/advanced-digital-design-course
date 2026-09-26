`timescale 1ns / 1ps

module tb_iir_filter ();

    localparam NB_INPUT   = 8;
    localparam NB_OUTPUT  = 12;
    localparam CLK_PERIOD = 10;

    logic                        clock = 0;
    logic                        i_reset_n;
    logic signed [ NB_INPUT-1:0] i_x;
    logic signed [NB_OUTPUT-1:0] o_y;

    integer                      n;

    always #(CLK_PERIOD / 2) clock = ~clock;

    iir_filter #(
        .NB_INPUT (NB_INPUT),
        .NB_OUTPUT(NB_OUTPUT)
    ) u_iir_filter (
        .clock    (clock),
        .i_reset_n(i_reset_n),
        .i_x      (i_x),
        .o_y      (o_y)
    );

    // Assert reset for two full cycles, release it away from the rising edge.
    task automatic do_reset();
        begin
            i_reset_n = 1'b0;
            i_x       = '0;
            repeat (2) @(negedge clock);
            i_reset_n = 1'b1;
            n         = 0;
        end
    endtask

    // Drive the input on the falling edge so it is stable well before the DUT
    // samples it. The #1 lets the combinational output settle before printing.
    task automatic step(input signed [NB_INPUT-1:0] value);
        begin
            @(negedge clock);
            i_x = value;
            #1;
            $display("  n=%0d\tx=%0d\ty=%0d", n, i_x, o_y);
            n = n + 1;
        end
    endtask

    task automatic run_impulse(input signed [NB_INPUT-1:0] amplitude,
                               input integer length);
        integer k;
        begin
            do_reset();
            step(amplitude);
            for (k = 1; k < length; k = k + 1) step(0);
        end
    endtask

    task automatic run_step(input signed [NB_INPUT-1:0] amplitude,
                            input integer length);
        integer k;
        begin
            do_reset();
            for (k = 0; k < length; k = k + 1) step(amplitude);
        end
    endtask

    integer k;

    initial begin
        $dumpfile("tb_iir_filter.vcd");
        $dumpvars(0, tb_iir_filter);

        $display(
            "\n=== impulse, amplitude 1 (expected h[k] = 1, -0.5, 1, 1.375, ...) ==="
                );
        run_impulse(1, 12);

        $display("\n=== impulse, amplitude 127 ===");
        run_impulse(127, 12);

        $display("\n=== step, amplitude 127 (ideal steady state = 1016) ===");
        run_step(127, 24);

        $display(
            "\n=== zero input after a step: does the state decay to 0? ===");
        for (k = 0; k < 40; k = k + 1) step(0);

        $display(
            "\n=== same thing from a NEGATIVE state: run_step(-128), then zero input ==="
                );
        run_step(-128, 24);
        for (k = 0; k < 40; k = k + 1) step(0);

        $finish;
    end

endmodule
