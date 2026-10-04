module top #(
    parameter int NB_DATA = 8,
    parameter int N_PROBE = 8
) (
    input clock
);

    //! Active low, as the original: the design uses ~reset internally.
    //! Driven by the VIO when it is instantiated; tied deasserted otherwise.
    wire                      reset = 1'b1;

    wire signed [NB_DATA-1:0] w_signal;
    wire signed [NB_DATA-1:0] w_filtered_signal;

    signal_generator #(
        .NB_DATA(NB_DATA)
    ) u_signal_generator (
        .i_clock (clock),
        .i_reset (~reset),
        .o_signal(w_signal)
    );

    fir_filter #(
        .WW_INPUT (NB_DATA),
        .WW_OUTPUT(NB_DATA)
    ) u_fir_filter (
        .clk   (clock),
        .i_srst(~reset),
        .i_en  (1'b1),
        .i_data(w_signal),
        .o_data(w_filtered_signal)
    );

    //////////////////////////////////////////
    // Descomentar para instanciar ILA y VIO.
    // Al habilitar el VIO, borrar el `wire reset = 1'b1;` de arriba y dejar que
    // probe_out0_0 maneje la senal.
    //////////////////////////////////////////

    // ilaDDA u_ilaDDA (
    //     .clk_0   (clock),
    //     .probe0_0(w_signal),          // Bits: 8
    //     .probe1_0(w_filtered_signal)  // Bits: 8
    // );

    // vioDDA u_vioDDA (
    //     .clk_0       (clock),
    //     .probe_in0_0 (w_filtered_signal),  // Bits: 8
    //     .probe_out0_0(reset)               // Bits: 1
    // );

endmodule
