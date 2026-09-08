/* Xilinx-specific wrapper around `top`: adds VIO/ILA debug cores for
   bring-up on hardware. Only this file is tied to Vivado — `top.v` stays
   portable. Set this module (not `top`) as the synthesis/implementation
   top in Vivado; simulation keeps targeting `top` via `tb_top`. */

module top_debug #(
    parameter NB_LEDS    = 4,
    parameter NB_SW      = 4,
    parameter NB_COUNTER = 32
) (
    output [NB_LEDS-1:0] o_led,
    output [NB_LEDS-1:0] o_led_b,
    output [NB_LEDS-1:0] o_led_g,

    input [NB_SW-1:0] i_sw,
    input             i_reset,
    input             clock
);

    wire             selMux;
    wire [NB_SW-1:0] w_vio_sw;
    wire             w_vio_reset;
    wire [NB_SW-1:0] w_sw;
    wire             w_reset;

    assign w_sw    = (selMux) ? w_vio_sw : i_sw;
    assign w_reset = (selMux) ? w_vio_reset : i_reset;

    top #(
        .NB_LEDS   (NB_LEDS),
        .NB_SW     (NB_SW),
        .NB_COUNTER(NB_COUNTER)
    ) u_top (
        .o_led  (o_led),
        .o_led_b(o_led_b),
        .o_led_g(o_led_g),
        .i_sw   (w_sw),
        .i_reset(w_reset),
        .clock  (clock)
    );

    ila u_ila (
        .clk_0   (clock),
        .probe0_0(o_led)
    );

    vio u_vio (
        .clk_0       (clock),
        .probe_in0_0 (o_led),
        .probe_in1_0 (o_led_b),
        .probe_in2_0 (o_led_g),
        .probe_out0_0(selMux),
        .probe_out1_0(w_vio_reset),
        .probe_out2_0(w_vio_sw)
    );

endmodule
